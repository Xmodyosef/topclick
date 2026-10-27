import Testing
import Foundation
import FoundationModels

actor FakeTaskStore: TaskStore {
    private(set) var items: [TaskItem] = []
    func add(_ item: TaskItem) async throws { items.append(item) }
    func delete(id: UUID) async throws { items.removeAll { $0.id == id } }
    func open() async -> [TaskItem] { items }
}

@MainActor
struct AgentToolTests {
    @Test func addTaskParsesDueDate() async throws {
        let store = FakeTaskStore()
        let out = try await AddTaskTool(store: store).call(arguments: .init(title: "Pay rent", due: "2026-11-01"))
        #expect(out.contains("Pay rent"))
        let saved = await store.items
        #expect(saved.first?.due != nil)
    }

    @Test func deleteOnlyProposes() async throws {
        let store = FakeTaskStore()
        let item = TaskItem(id: UUID(), title: "Old", due: nil)
        try await store.add(item)
        let orchestrator = AgentOrchestrator()
        _ = try await DeleteTaskTool(store: store, orchestrator: orchestrator)
            .call(arguments: .init(id: item.id.uuidString, title: "Old"))
        #expect(await store.items.count == 1)          // nothing deleted yet
        #expect(orchestrator.pending.count == 1)
        await orchestrator.confirm(orchestrator.pending[0].id)
        #expect(await store.items.isEmpty)
    }
}
