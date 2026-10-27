---
name: in-app-agent
description: Generate a working in-app AI agent on Foundation Models (iOS 27) — a DynamicProfile that switches between an on-device assistant and a Private Cloud Compute planner, app tools behind a protocol, Vision OCR/barcode tools for photos, human-in-the-loop confirmation for destructive actions, session properties for state, streaming chat UI, error mapping, and Swift Testing fakes. Use when the user wants an assistant/agent/copilot inside their app that takes actions, reads images, or plans multi-step tasks without a server.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27 / macOS 27
---

# In-App Agent

A generator for an assistant that **does things in the app**: it calls your code
through tools, reads photos, hands hard problems to a bigger model, and asks before
anything destructive. It's built on the iOS 27 `DynamicProfile` API.

This skill is the **build recipe**. API depth (profile precedence, orchestration
patterns, KV-cache rules, PCC quotas) is in
`apple-intelligence/foundation-models/models-and-agents.md`.

Templates (typecheck clean in Swift 6 and under default MainActor isolation):
`templates/Agent.swift` and `templates/AgentTests.swift`.

## When This Skill Activates

- "Add an assistant / agent / copilot / chat that can do X in my app"
- The model should create, edit, or delete app data through tools
- "Snap a photo and have the AI handle it" (receipts, labels, barcodes)
- A feature needs the on-device model for quick turns and PCC for heavy reasoning

## Before Generating, Ask

1. **Which actions?** List each as read-only, additive, or destructive. Destructive actions get a confirmation step (below).
2. **Images?** If yes, include `OCRTool` / `BarcodeReaderTool` and the photo attachment path.
3. **PCC?** It needs the `com.apple.developer.private-cloud-compute` managed entitlement. If they don't have it, generate the on-device profile only.

## Architecture

```
AgentChat (@MainActor @Observable) ── LanguageModelSession(profile: AssistantProfile)
     │ streams turns                         │ body re-evaluated before EVERY generation
     │                                       ├─ .assist → on-device · app tools · OCR/Barcode · SwitchModeTool
AgentOrchestrator (@MainActor)               └─ .plan   → .model(pcc) · .reasoningLevel(.moderate)
     pending confirmations, activity log
Session properties (@SessionPropertyEntry): mode, cloudEnabled ← tools + UI read/write
TaskStore protocol ← real store in the app, actor fake in tests
```

## 1. State the Profile Reads: Session Properties

The profile `body` is evaluated by the framework before every generation. Don't read
`@MainActor` state there; it fails to compile in plain Swift 6 mode ("main
actor-isolated property … nonisolated context"). Use **session properties**, which are
thread-safe and `Observable`:

```swift
// `nonisolated` is required under default MainActor isolation; without it the
// key path in @SessionProperty(\.mode) is main-actor-isolated and won't compile.
nonisolated extension SessionPropertyValues {
    @SessionPropertyEntry var mode: AgentMode = .assist
    @SessionPropertyEntry var cloudEnabled: Bool = false
}
```

Tools and profiles use `@SessionProperty(\.mode) var mode`. The UI uses
`session.properties.mode`.

## 2. Tools

```swift
struct AddTaskTool: Tool {
    let store: any TaskStore                   // protocol seam → fake in tests
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
```

- Tool `call` runs **off the main actor** (`@concurrent` in the protocol). Reach UI state with `await`.
- Return short, factual strings. Tool output goes into the context window.
- ✅ Give a *list* tool that returns ids before any tool that needs an id. Models invent ids otherwise.
- ❌ One giant `doAnything(action: String)` tool. Use one tool per verb, with typed `@Generable` arguments.

### Destructive actions: propose, don't execute

```swift
struct DeleteTaskTool: Tool {
    let store: any TaskStore
    let orchestrator: AgentOrchestrator
    let name = "deleteTask"
    let description = "Asks the user to confirm deleting a to-do item. Use ids from listTasks."

    @Generable struct Arguments {
        @Guide(description: "The task id from listTasks") var id: String
        @Guide(description: "The task title, shown to the user") var title: String
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
```

The UI renders `orchestrator.pending` as Confirm/Cancel rows. ✅ The tool output tells
the model the action is *pending*, so it doesn't report success. App Review and users
both expect this for delete, send, purchase, and share actions.

### Built-in Vision tools

`OCRTool()` and `BarcodeReaderTool()` come from the Vision + Foundation Models
cross-import (`import Vision` + `import FoundationModels`). Add them to a profile and
attach the photo to the prompt:

```swift
import UIKit   // required: Attachment(UIImage) lives in the UIKit cross-import overlay

let stream = session.streamResponse {
    text
    if let image { Attachment(image).label("photo from the user") }
}
```

- ❌ Importing only SwiftUI. The `Attachment(UIImage)` initializer lives in the UIKit cross-import
  overlay. Without `import UIKit` you get "no exact matches in call to initializer". Inside a
  prompt builder, Xcode 27.0 instead **crashes the type checker** ("failed to produce diagnostic
  for expression"), so the import is the first thing to check.
- Core `Attachment` also takes `CGImage`, `CIImage`, `CVPixelBuffer`, and `imageURL:`. Downscale large photos, because image tokens cost latency.

## 3. The Profile

```swift
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
                Instructions { "You are a concise to-do assistant inside the app. Use tools for every change. …" }
                AddTaskTool(store: store)
                ListTasksTool(store: store)
                DeleteTaskTool(store: store, orchestrator: orchestrator)
                OCRTool()
                BarcodeReaderTool()
                if cloudEnabled && pcc.isAvailable { SwitchModeTool() }   // conditional tools LAST (KV cache)
            }
            .temperature(0.3)
            .onToolCall { call in
                let name = call.toolName
                await MainActor.run { orchestrator.log("→ \(name)") }
            }
        case .plan:
            Profile {
                Instructions { "Break the user's goal into dated, concrete tasks and add each with addTask. Then summarize." }
                AddTaskTool(store: store)
                ListTasksTool(store: store)
            }
            .model(pcc)
            .reasoningLevel(.moderate)
            .onResponse { mode = .assist }        // one planning turn, then back on-device
        }
    }
}
```

- **Exactly one `Profile` is active.** Use `switch` or `if/else`, never two parallel `if`s. The builder enforces this at compile time.
- **Model handoff** happens by flipping `mode`, either from a tool (`SwitchModeTool` sets `mode = .plan`) or from code. The new profile applies to the next generation.
- **Precedence:** call-site `GenerationOptions` > the innermost profile modifier > outer dynamic-profile modifiers. Lifecycle callbacks (`onToolCall`, `onResponse`, …) **accumulate** across levels.
- Keep stable instructions and tools first and conditional ones last. Appending in place preserves the KV cache.

## 4. Chat and Errors

```swift
for try await snapshot in stream { turns[index].text = snapshot.content }
// …
} catch let error as LanguageModelError {
    turns[index].text = switch error {
    case .contextSizeExceeded: "This conversation got too long. Start a new one."
    case .rateLimited: "Daily limit reached. Try again later."            // PCC quota
    case .guardrailViolation, .refusal: "I can't help with that."
    default: "Something went wrong."
    }
}
```

- ❌ Catching `LanguageModelSession.GenerationError`. It's deprecated in iOS 27 and unavailable when building with Xcode 27.
- Long chats: trim with `.historyTransform { … }` on the profile, or start a new session. Details are in `models-and-agents.md`.
- Gate the whole feature on `SystemLanguageModel.default.availability` (`apple-intelligence/on-device-ai-kit`).

## 5. Tests

Unit-test **tools and orchestration**, not the model:

```swift
actor FakeTaskStore: TaskStore { /* in-memory */ }

@Test func deleteOnlyProposes() async throws {
    let store = FakeTaskStore()
    let item = TaskItem(id: UUID(), title: "Old", due: nil)
    try await store.add(item)
    let orchestrator = AgentOrchestrator()
    _ = try await DeleteTaskTool(store: store, orchestrator: orchestrator)
        .call(arguments: .init(id: item.id.uuidString, title: "Old"))
    #expect(await store.items.count == 1)        // nothing deleted until confirmed
    await orchestrator.confirm(orchestrator.pending[0].id)
    #expect(await store.items.isEmpty)
}
```

`@Generable` argument structs keep their memberwise initializer, so tests construct
arguments directly. Test model *behavior* with an eval set (prompts → expected tool
calls), re-run after each OS update. Profile it with the Foundation Models
instrument, which shows tokens per prompt, tool calls, and latency.

## Common Mistakes

| ❌ | ✅ |
|---|---|
| Reading `@MainActor` view-model state in `body` | `@SessionPropertyEntry` state, read via `@SessionProperty` |
| `extension SessionPropertyValues` under default MainActor isolation | `nonisolated extension SessionPropertyValues` |
| A destructive tool that executes immediately | Propose → user confirms → execute; the tool output says "pending" |
| `.toolCallingMode(.required)` with no exit | Flip it to `.disallowed` after the needed call, or use a throwing final-answer tool |
| One session per mode with manual transcript copying | One session and a `DynamicProfile` switching on state |
| PCC profile shipped without the entitlement | Offer `cloudEnabled` only when entitled; check `pcc.isAvailable` |
| Testing by calling the real model | Call tools directly with fakes; use evals for model behavior |

## Checklist

- [ ] Every action classified; destructive ones go through `PendingAction` confirmation
- [ ] Tools behind a protocol store; a list tool before any id-taking tool
- [ ] Profile state in session properties (`nonisolated extension`)
- [ ] Exactly one active `Profile`; conditional tools appended last
- [ ] PCC path behind entitlement plus `isAvailable`; quota (`rateLimited`) handled
- [ ] `LanguageModelError` mapped to friendly copy; no `GenerationError`
- [ ] Photo input via `Attachment` with `import UIKit`; images downscaled
- [ ] Tool unit tests with fakes; an eval set for model behavior

## References

- Composing dynamic sessions with instructions and profiles: https://developer.apple.com/documentation/foundationmodels/composing-dynamic-sessions-with-instructions-and-profiles
- LanguageModelSession.DynamicProfile: https://developer.apple.com/documentation/foundationmodels/languagemodelsession/dynamicprofile
- Expanding generation with tool calling: https://developer.apple.com/documentation/foundationmodels/expanding-generation-with-tool-calling
- Adding server-side intelligence with Private Cloud Compute: https://developer.apple.com/documentation/foundationmodels/adding-server-side-intelligence-with-private-cloud-compute
- Analyzing the runtime performance of your Foundation Models app: https://developer.apple.com/documentation/foundationmodels/analyzing-the-runtime-performance-of-your-foundation-models-app
- Related: `apple-intelligence/foundation-models` (`models-and-agents.md`), `apple-intelligence/ai-search` (add `SpotlightSearchTool` to a profile), `apple-intelligence/on-device-ai-kit`, `apple-intelligence/bring-your-own-model`
