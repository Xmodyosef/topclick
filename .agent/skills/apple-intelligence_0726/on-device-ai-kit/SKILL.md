---
name: on-device-ai-kit
description: Choose and wire Apple's on-device AI for a small app — which framework fits each feature (Foundation Models, Image Playground, Writing Tools, NaturalLanguage, Vision, Speech, Translation, Core ML), an availability gate that works for testers on non-Apple-Intelligence iPhones, protocol-based fallbacks, and the iOS 27 ImageCreator deprecation. Use when the user wants "AI features" without a server or API key, asks which Apple model to use, or needs AI to degrade gracefully across TestFlight testers' devices.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# On-Device AI Kit

The router for "add AI" in a local-first app. It picks the right Apple framework per
feature, gates on device capability, and keeps the app useful on iPhones without
Apple Intelligence (a large share of any TestFlight group). Deep API detail lives in
the specialist skills; this one covers decisions, gating, and wiring.

All code compiles against the iOS 27 SDK in Swift 6 and default-MainActor modes.

## When This Skill Activates

- "Add AI", "summarize", "auto-tag", "generate", "smart" anything, with no backend
- Which Apple model/framework to use for a feature
- AI features missing or broken for some testers
- Migrating off `ImageCreator` (deprecated iOS 27)

## Pick the Framework

| Feature | Framework | Runs on | Skill |
|---|---|---|---|
| Summarize, extract fields, classify, rewrite, chat, tool-calling | **Foundation Models** | Apple Intelligence devices | `apple-intelligence/foundation-models` |
| Proofread / rewrite user-typed text | **Writing Tools** (free on text views) | Apple Intelligence devices | below |
| Generate images / avatars | **Image Playground** sheet | Apple Intelligence devices | below |
| Sentiment, language ID, tokenizing, lemmas, embeddings | **NaturalLanguage** | **All devices** | `core-ml` |
| Text/barcodes from camera or photos | **Vision / VisionKit** | All (live scanner: A12+) | `ios/camera-scanning` |
| Speech → text | **SpeechAnalyzer** | Broad (Dictation fallback) | `apple-intelligence/speech-translation` |
| Translate | **Translation** | Broad | `apple-intelligence/speech-translation` |
| Custom classifier (your labels, your data) | **Core ML / Create ML** | All devices | `core-ml` |
| Expose app actions to Siri / Shortcuts | **App Intents** | All; Siri AI features on AI devices | `apple-intelligence/app-intents` |

Rule of thumb: **reach for the all-devices row first**, and use Foundation Models when
the task needs language *understanding or generation*. A sentiment score from
NaturalLanguage beats an LLM call that half your testers can't run.

## The Gate

```swift
import SwiftUI
import FoundationModels

enum AIStatus: Equatable {
    case ready
    case deviceNotEligible   // hardware can't run Apple Intelligence
    case turnedOff           // eligible, but off in Settings
    case downloading         // model assets not ready yet
    case unavailable         // other/future reasons
}

@MainActor @Observable
final class AIGate {
    private(set) var status: AIStatus = .unavailable

    func refresh() {
        switch SystemLanguageModel.default.availability {
        case .available: status = .ready
        case .unavailable(.deviceNotEligible): status = .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled): status = .turnedOff
        case .unavailable(.modelNotReady): status = .downloading
        case .unavailable: status = .unavailable
        }
    }
}
```

Call `refresh()` at launch and on `scenePhase == .active`. Users toggle Apple
Intelligence in Settings and the model downloads in the background.

### UX per status

| Status | Show |
|---|---|
| `.ready` | The feature |
| `.deviceNotEligible` | Fallback feature (below), or a quiet "Requires Apple Intelligence" label. Never an error |
| `.turnedOff` | One-line explainer: "Turn on Apple Intelligence in Settings to get summaries" |
| `.downloading` | "Getting ready…" and re-check later |

✅ Explain AI-gated features. Testers on an iPhone 13 filing "summary button missing" is a UX bug.
❌ Hiding the feature silently, or showing an error alert for `.deviceNotEligible`.

## Protocol Seam + Fallback

```swift
import FoundationModels
import NaturalLanguage

protocol Summarizer: Sendable {
    func summarize(_ text: String) async throws -> String
}

struct OnDeviceSummarizer: Summarizer {
    func summarize(_ text: String) async throws -> String {
        let session = LanguageModelSession(instructions: "Summarize the user's note in one or two sentences. Plain text only.")
        return try await session.respond(to: text).content
    }
}

/// Works on every device: first sentence via NLTokenizer.
struct ExtractiveSummarizer: Summarizer {
    func summarize(_ text: String) async throws -> String {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        var first: String?
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            first = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            return false
        }
        return first ?? text
    }
}

@MainActor
func makeSummarizer(_ gate: AIGate) -> any Summarizer {
    gate.status == .ready ? OnDeviceSummarizer() : ExtractiveSummarizer()
}
```

Tests inject a `FakeSummarizer` that returns fixed text. Never call the model from unit tests.

## Recipes

### Structured extraction (Foundation Models)

```swift
@Generable
struct MealTags {
    @Guide(description: "Up to 3 short lowercase tags, e.g. high-protein")
    var tags: [String]
    @Guide(description: "Estimated calories", .range(0...3000))
    var calories: Int
}

func tagMeal(_ description: String) async throws -> MealTags {
    let session = LanguageModelSession(instructions: "You tag meals the user describes.")
    return try await session.respond(to: description, generating: MealTags.self).content
}
```

Error handling changed in iOS 27: `GenerationError` is deprecated and **unavailable when
building with Xcode 27**, split into `LanguageModelError` and friends. Follow
`apple-intelligence/foundation-models` → "Error Handling" / "Migrating off GenerationError".
Context window and Private Cloud Compute → same skill, `models-and-agents.md`.

### Sentiment on every device (NaturalLanguage)

```swift
func sentimentScore(_ text: String) -> Double {     // -1 (negative) … 1 (positive)
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
    return Double(tag?.rawValue ?? "0") ?? 0
}
```

### Writing Tools: free

```swift
struct NoteEditor: View {
    @Binding var text: String
    var body: some View {
        TextEditor(text: $text)
            .writingToolsBehavior(.complete)   // full inline experience; .limited = panel only, .disabled to opt out
    }
}
```

System text views get Writing Tools on eligible devices automatically. The modifier only tunes the behavior.

### Image generation (iOS 27: use the sheet)

```swift
import SwiftUI
import ImagePlayground

struct AvatarButton: View {
    @Environment(\.supportsImagePlayground) private var supportsImagePlayground
    @State private var showing = false
    @State private var avatarURL: URL?
    let name: String

    var body: some View {
        if supportsImagePlayground {
            Button("Create avatar") { showing = true }
                .imagePlaygroundSheet(
                    isPresented: $showing,
                    concepts: [.text("friendly cartoon of \(name)")]
                ) { url in
                    avatarURL = url        // temporary file — copy into your container
                }
        }
    }
}
```

❌ `ImageCreator` for new code. The whole class (initializer, `images(for:style:limit:)`,
error type) is deprecated in iOS 27 ("Use ImagePlaygroundViewController or imagePlaygroundSheet").
Programmatic, no-UI generation no longer has a supported path, so design the feature around the sheet.
iOS 27 adds `ImagePlaygroundOptions.sizeSpecification` (`.closest(to:)`),
`.creationStrategy` (`.automatic` / `.editExisting` / `.generateNew`), and a `.any` style.

## Simulator & TestFlight

- **Simulator**: Foundation Models availability follows the host Mac. If the Mac doesn't have Apple Intelligence enabled, expect `.unavailable`. That's a good way to exercise the fallback path.
- **TestFlight**: put "AI summaries need Apple Intelligence (iPhone 15 Pro or newer, turned on in Settings)" in *What to Test* so feedback separates bugs from ineligibility.
- **Privacy**: on-device inference sends nothing off the phone, so it doesn't add App Privacy "data collected" entries by itself. Anything you upload elsewhere still does.

## Checklist

- [ ] Each AI feature mapped to the cheapest framework that works on all devices
- [ ] `AIGate` refreshed on launch and foreground; all four unavailable states handled in UI
- [ ] Every Foundation Models feature behind a protocol with a non-AI fallback or explainer
- [ ] No `GenerationError` catches (Xcode 27 makes them unavailable)
- [ ] Image generation via `imagePlaygroundSheet`, not `ImageCreator`
- [ ] Unit tests use fakes; model behavior covered by evals (`foundation-models`)
- [ ] TestFlight notes call out Apple Intelligence requirements

## References

- Foundation Models: https://developer.apple.com/documentation/foundationmodels
- Image Playground: https://developer.apple.com/documentation/imageplayground
- Writing Tools: https://developer.apple.com/documentation/swiftui/view/writingtoolsbehavior(_:)
- NaturalLanguage: https://developer.apple.com/documentation/naturallanguage
- Local SDK truth: `ImagePlayground.swiftinterface` (iOS 27 deprecations), `FoundationModels.swiftinterface`
- Related: `apple-intelligence/foundation-models`, `apple-intelligence/speech-translation`, `ios/camera-scanning`, `core-ml`
