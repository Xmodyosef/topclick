import SwiftUI
import UIKit                 // needed for Attachment(UIImage) — the cross-import overlay keys off UIKit
import FoundationModels
import CoreSpotlight
import Vision

// MARK: - App seam (protocol so tests and previews use fakes)

struct TaskItem: Sendable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var due: Date?
}

protocol TaskStore: Sendable {
    func add(_ item: TaskItem) async throws
    func delete(id: UUID) async throws
    func open() async -> [TaskItem]
}

// MARK: - Session state the profile reads on every prompt

enum AgentMode: String, Sendable { case assist, plan }

// Session properties are thread-safe and Observable. Profiles and tools read and write them with
// @SessionProperty, and the UI reads them through `session.properties`.
nonisolated extension SessionPropertyValues {
    @SessionPropertyEntry var mode: AgentMode = .assist
    @SessionPropertyEntry var cloudEnabled: Bool = false
}

// MARK: - Orchestrator: UI-facing state (confirmations, activity log)

struct PendingAction: Identifiable, Sendable {
    let id = UUID()
    let summary: String
    let run: @Sendable () async throws -> Void
}

@MainActor @Observable
final class AgentOrchestrator {
    private(set) var pending: [PendingAction] = [] // destructive actions waiting for a tap
    private(set) var activity: [String] = []       // tool-call log for the UI

    func log(_ line: String) { activity.append(line) }
    func propose(_ action: PendingAction) { pending.append(action) }

    func confirm(_ id: PendingAction.ID) async {
        guard let i = pending.firstIndex(where: { $0.id == id }) else { return }
        let action = pending.remove(at: i)
        do { try await action.run(); log("Done: \(action.summary)") }
        catch { log("Failed: \(action.summary)") }
    }

    func dismiss(_ id: PendingAction.ID) { pending.removeAll { $0.id == id } }
}

// MARK: - Tools

struct AddTaskTool: Tool {
    let store: any TaskStore
    let name = "addTask"
    let description = "Adds a to-do item for the user."

    @Generable
    struct Arguments {
        @Guide(description: "Short imperative title, e.g. Call the plumber")
        var title: String
        @Guide(description: "Due date as ISO 8601 (yyyy-MM-dd), or empty if none")
        var due: String
    }

    func call(arguments: Arguments) async throws -> String {
        let due = try? Date(arguments.due, strategy: .iso8601.year().month().day())
        try await store.add(TaskItem(id: UUID(), title: arguments.title, due: due))
        return "Added \"\(arguments.title)\"."
    }
}

struct ListTasksTool: Tool {
    let store: any TaskStore
    let name = "listTasks"
    let description = "Lists the user's open to-do items with their ids."

    @Generable struct Arguments {}

    func call(arguments: Arguments) async throws -> String {
        let items = await store.open()
        return items.isEmpty ? "No open tasks." : items.map { "\($0.id): \($0.title)" }.joined(separator: "\n")
    }
}

/// Destructive: never executes. It proposes, and the user confirms in the UI.
struct DeleteTaskTool: Tool {
    let store: any TaskStore
    let orchestrator: AgentOrchestrator
    let name = "deleteTask"
    let description = "Asks the user to confirm deleting a to-do item. Use ids from listTasks."

    @Generable struct Arguments {
        @Guide(description: "The task id from listTasks")
        var id: String
        @Guide(description: "The task title, shown to the user")
        var title: String
    }

    func call(arguments: Arguments) async throws -> String {
        guard let id = UUID(uuidString: arguments.id) else { return "Unknown id. Call listTasks first." }
        let store = self.store
        await orchestrator.propose(PendingAction(summary: "Delete \"\(arguments.title)\"") {
            try await store.delete(id: id)
        })
        return "Asked the user to confirm deleting \"\(arguments.title)\". Do not claim it is deleted."
    }
}

/// Lets the model hand off to the planning profile when a request needs multi-step reasoning.
struct SwitchModeTool: Tool {
    @SessionProperty(\.mode) var mode
    let name = "switchToPlanning"
    let description = "Switch to planning mode for requests that need a multi-step plan or long documents."

    @Generable struct Arguments {}

    func call(arguments: Arguments) async throws -> String {
        mode = .plan                     // the profile re-evaluates before the next generation
        return "Planning mode on."
    }
}

// MARK: - Profile: re-evaluated before every prompt

struct AssistantProfile: LanguageModelSession.DynamicProfile {
    let orchestrator: AgentOrchestrator
    let store: any TaskStore
    let pcc: PrivateCloudComputeLanguageModel
    @SessionProperty(\.mode) var mode
    @SessionProperty(\.cloudEnabled) var cloudEnabled

    var body: some DynamicProfile {
        switch mode {
        case .assist:
            Profile {
                Instructions {
                    """
                    You are a concise to-do assistant inside the app. Use tools for every change. \
                    For images, read text with the OCR tool and codes with the barcode tool. \
                    Deletions only propose; tell the user to confirm.
                    """
                }
                AddTaskTool(store: store)
                ListTasksTool(store: store)
                DeleteTaskTool(store: store, orchestrator: orchestrator)
                OCRTool()
                BarcodeReaderTool()
                if cloudEnabled && pcc.isAvailable { SwitchModeTool() }
            }
            .temperature(0.3)
            .onToolCall { call in
                let name = call.toolName
                await MainActor.run { orchestrator.log("→ \(name)") }
            }

        case .plan:
            Profile {
                Instructions {
                    "Break the user's goal into dated, concrete tasks and add each with addTask. Then summarize."
                }
                AddTaskTool(store: store)
                ListTasksTool(store: store)
            }
            .model(pcc)
            .reasoningLevel(.moderate)
            .onResponse { mode = .assist }   // one planning turn, then back to the on-device assistant
        }
    }
}

// MARK: - Chat view model

@MainActor @Observable
final class AgentChat {
    struct Turn: Identifiable { let id = UUID(); let fromUser: Bool; var text: String }

    private(set) var turns: [Turn] = []
    private(set) var isResponding = false
    let orchestrator: AgentOrchestrator
    private let session: LanguageModelSession

    init(store: any TaskStore, orchestrator: AgentOrchestrator = AgentOrchestrator()) {
        self.orchestrator = orchestrator
        session = LanguageModelSession(profile: AssistantProfile(
            orchestrator: orchestrator, store: store, pcc: PrivateCloudComputeLanguageModel()))
    }

    /// Bound to a Settings toggle. Only offer it when the app has the PCC entitlement.
    var cloudEnabled: Bool {
        get { session.properties.cloudEnabled }
        set { session.properties.cloudEnabled = newValue }
    }
    var mode: AgentMode { session.properties.mode }

    func send(_ text: String, image: UIImage? = nil) async {
        turns.append(Turn(fromUser: true, text: text))
        turns.append(Turn(fromUser: false, text: ""))
        let index = turns.count - 1
        isResponding = true
        defer { isResponding = false }
        do {
            let stream = session.streamResponse {
                text
                if let image { Attachment(image).label("photo from the user") }
            }
            for try await snapshot in stream { turns[index].text = snapshot.content }
        } catch let error as LanguageModelError {
            turns[index].text = Self.message(for: error)
        } catch {
            turns[index].text = "Something went wrong."
        }
    }

    static func message(for error: LanguageModelError) -> String {
        switch error {
        case .contextSizeExceeded: "This conversation got too long. Start a new one."
        case .rateLimited: "Daily limit reached. Try again later."
        case .guardrailViolation, .refusal: "I can't help with that."
        default: "Something went wrong."
        }
    }
}

struct AgentView: View {
    @State var chat: AgentChat
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(chat.turns) { turn in
                    Text(turn.text.isEmpty ? "…" : turn.text)
                        .frame(maxWidth: .infinity, alignment: turn.fromUser ? .trailing : .leading)
                }
                ForEach(chat.orchestrator.pending) { action in
                    HStack {
                        Text(action.summary)
                        Spacer()
                        Button("Confirm", role: .destructive) { Task { await chat.orchestrator.confirm(action.id) } }
                        Button("Cancel") { chat.orchestrator.dismiss(action.id) }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                TextField("Ask…", text: $draft)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .onSubmit {
                        let text = draft; draft = ""
                        Task { await chat.send(text) }
                    }
                    .disabled(chat.isResponding)
            }
            .navigationTitle("Assistant")
        }
    }
}
