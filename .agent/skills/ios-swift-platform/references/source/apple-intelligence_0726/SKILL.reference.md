---
name: apple-intelligence
description: Apple Intelligence skills for on-device AI features including Foundation Models, Visual Intelligence, App Intents, and intelligent assistants. Also covers choosing an on-device AI framework with availability gating and fallbacks, on-device speech-to-text and translation, natural-language search over app content, in-app agents, photo/video/document intelligence, and running open or custom models with Core AI and MLX. Use when implementing AI-powered features.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27 / macOS 27
---

# On-Device AI

Skills for implementing Apple Intelligence features including on-device LLMs, visual recognition, App Intents integration, and intelligent assistants.

## When This Skill Activates

Use this skill when the user:
- Wants to add AI/LLM features to their app
- Needs on-device text generation or understanding
- Asks about Foundation Models or Apple Intelligence
- Wants to implement structured AI output
- Needs prompt engineering guidance
- Wants camera-based visual intelligence features
- Needs Siri, Shortcuts, or Spotlight integration via App Intents
- Wants to expose app actions or content to the system
- Wants AI search over app content, an in-app agent, photo/video/document AI, or open-source models on-device

## Available Skills

### foundation-models/
On-device LLM integration with prompt engineering best practices.
- Model availability checking
- Session management
- @Generable structured output (property-order + schema-injection rules)
- Tool calling patterns
- Snapshot streaming
- Prompt engineering techniques
- `safety-and-guardrails.md` — model limits, the instructions-over-prompts hierarchy, guardrail handling, the four-layer safety stack, evals
- `models-and-agents.md` — Private Cloud Compute, LanguageModel protocol (third-party backends), vision input, DynamicProfile agents, tool-calling modes, KV-cache rules

### visual-intelligence/
Integrate with iOS Visual Intelligence for camera-based search.
- IntentValueQuery implementation
- SemanticContentDescriptor handling
- AppEntity for searchable content
- Display representations
- Deep linking from results

### app-intents/
App Intents for Siri, Shortcuts, Spotlight, and Apple Intelligence.
- AppIntent protocol, parameters, perform()
- AppEntity and entity queries
- App Shortcuts with voice phrases
- IndexedEntity and Spotlight indexing
- Intent modes (background, foreground)
- Interactive snippets with SnippetIntent
- Visual intelligence integration
- Onscreen entities for Siri/ChatGPT
- Multiple choice API
- Swift package support

### on-device-ai-kit/
Router for "add AI" without a backend — picks the framework per feature and gates it.
- Feature → framework table (Foundation Models, Writing Tools, Image Playground, NaturalLanguage, Vision, Speech, Translation, Core ML)
- `AIGate` availability model with UX for every unavailable state
- Protocol seam + non-AI fallback for testers on ineligible iPhones
- iOS 27: `ImageCreator` deprecated → `imagePlaygroundSheet`

### speech-translation/
On-device speech-to-text and translation.
- SpeechAnalyzer + SpeechTranscriber, DictationTranscriber fallback, asset download
- iOS 27 `CaptureInputSequenceProvider` / `AssetInputSequenceProvider` / `AnalyzerInputConverter` (no engine tap)
- Translation: system overlay, order-safe batch `translationTask`, installed-language sessions

### ai-search/
Natural-language "ask my app" search with `SpotlightSearchTool` (iOS 27).
- Core Spotlight indexing that the model can reason over (custom attributes, batches, hydration delegate)
- Guide per model: `.focused` + `.compact` on-device, `.complete` on Private Cloud Compute
- Streaming answer plus live result cards from `searchResults`; `CustomStage`, `ContactResolver`

### in-app-agent/
Generator for an assistant that takes actions in the app.
- `DynamicProfile` switching on-device assistant ↔ PCC planner; session-property state
- Tools behind a protocol, Vision `OCRTool` / `BarcodeReaderTool`, photo attachments
- Human-in-the-loop confirmation for destructive actions; `LanguageModelError` mapping; tool tests with fakes

### media-intelligence/
On-device photo and video AI (iOS 27).
- `FaceGroupAnalyzer`: people grouping, identify-without-storing, purge
- `VideoAnalyzer`: highlights, engagement levels, key frame in one decode
- Vision `GenerateIterativeSegmentationRequest`: tap-to-select cutouts

### document-intelligence/
Receipts, invoices, and forms → typed Swift data.
- Vision `RecognizeDocumentsRequest` tables → `DataDetector` facts → `@Generable` extraction
- Validation against detected amounts; review-before-save UI

### bring-your-own-model/
Open and custom models on-device.
- Core AI framework (`AIModel`, `InferenceFunction`, `NDArray`, specialization cache, `coreai-build`)
- `CoreAILanguageModel` / `MLXLanguageModel` through `LanguageModelSession`
- Capability-aware router with fallbacks across Apple, local, and PCC models

## Key Principles

### 1. Privacy First
- On-device processing by default; Private Cloud Compute extends capacity without storing prompts (no account/API keys — WWDC26 241)
- When routing to less-private backends, redact context first (see foundation-models/models-and-agents.md)

### 2. Graceful Degradation
- Always check model availability
- Provide fallback UI for unsupported devices
- Handle errors gracefully (incl. guardrail violations — silent for proactive features, explained for user-initiated)

### 3. Efficient Prompting
- Keep prompts focused and specific
- Use structured output when possible
- Respect context window limits — query `model.contextSize`, never hardcode (4,096 first-gen on-device; 8,192 iOS 27 on-device; 32,000 Private Cloud Compute)

## Reference Documentation

- [Foundation Models](https://developer.apple.com/documentation/foundationmodels)
- [Visual Intelligence](https://developer.apple.com/documentation/visualintelligence)
- [App Intents](https://developer.apple.com/documentation/appintents)
