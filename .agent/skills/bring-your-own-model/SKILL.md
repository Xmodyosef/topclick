---
name: bring-your-own-model
description: Run your own or open-source AI models in an iOS 27 app — the new Core AI framework (.aimodel files, AIModel, InferenceFunction, NDArray, specialization caching, coreai-build), open LLMs through Foundation Models with CoreAILanguageModel (apple/coreai-models) or MLXLanguageModel (mlx-swift-lm), server models via the LanguageModel protocol, and a capability-aware router with fallbacks. Use when the user wants Qwen/Gemma/Llama/Mistral on-device, a custom PyTorch model in the app, AI on iPhones without Apple Intelligence, model downloads, or one API across on-device, PCC, and server models.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27 / macOS 27
---

# Bring Your Own Model

iOS 27 opens the model layer up in two ways:

1. **Core AI**, a new framework that runs any converted neural network (`.aimodel`) on the
   CPU, GPU, and Neural Engine. It's the new home for neural networks; Apple points non-neural
   models (trees, tabular feature engineering) to Core ML.
2. **The `LanguageModel` protocol.** Any LLM, local or remote, plugs into
   `LanguageModelSession`, so guided generation, tools, streaming, and profiles work unchanged.

Router and Core AI code is in `templates/ModelRouter.swift`, which typechecks against the
iOS 27 SDK in Swift 6 and under default MainActor isolation. Package-based snippets
(`CoreAILanguageModel`, `MLXLanguageModel`) are quoted from those packages' READMEs.

## When This Skill Activates

- "Run Qwen / Gemma / Llama / Mistral / Phi on the phone", "use my own model"
- A custom PyTorch model (classifier, detector, segmenter, embedder) in the app
- AI features for iPhones **without** Apple Intelligence
- One code path across Apple on-device, PCC, and a third-party model
- Shipping or downloading large model files

## Pick the Backend

| Need | Use | Runs on | Notes |
|---|---|---|---|
| General chat/extraction, free, private | `SystemLanguageModel` | Apple Intelligence devices | Start here (`foundation-models`) |
| Bigger reasoning or context | `PrivateCloudComputeLanguageModel` | Online; AI devices; entitlement | Quota per user |
| A specific open LLM, offline, **any** iOS 27 device with enough RAM | `CoreAILanguageModel` (`apple/coreai-models`) | CPU/GPU/ANE via Core AI | You ship or download the weights |
| Hugging Face MLX checkpoints, fast iteration | `MLXLanguageModel` (`ml-explore/mlx-swift-lm`) | GPU (Metal) | Huge model zoo; Mac-first, works on iOS |
| Frontier server model | `ChatCompletionsLanguageModel` (utilities package) or vendor packages | Network | You own auth and billing (`foundation-models/utilities-package.md`) |
| Non-LLM network (vision, audio, embeddings) | Core AI `AIModel` directly | CPU/GPU/ANE | Below |
| Trees, tabular, Create ML models | Core ML | All | `core-ml` |

**Decide by capability, not by brand.** The same session code runs on all of them, but
`capabilities` differ: `.guidedGeneration`, `.toolCalling`, `.reasoning`, `.vision`.

## 1. Open LLMs Through Foundation Models

### Core AI (Apple's package)

```bash
# Export once on your Mac (uv; Xcode 27). Use --platform iOS for phone builds.
uv run coreai.llm.export Qwen/Qwen3-0.6B --platform iOS
```

```swift
// Package: https://github.com/apple/coreai-models   product: CoreAILM
import FoundationModels
import CoreAILanguageModels

let model = try await CoreAILanguageModel(resourcesAt: modelFolderURL)   // .lazy load by default
let session = LanguageModelSession(model: model)
let answer = try await session.respond(to: "Summarize this note: …")
```

- `mode: .eager` loads the tokenizer and engine concurrently at init. Use `try await model.load()` / `model.unload()` to control memory.
- Capabilities are **derived from the model**: tool calling and reasoning if the chat template supports them, and guided generation via the bundled grammar engine.
- The catalog includes Qwen3 (0.6B–8B, all with iOS variants), Gemma, Phi, Mistral, SmolLM2, and more. Check each model's README for iOS support (`uv run coreai.model.registry --list-models`).
- Large models can exceed the iOS memory limit. Add the `com.apple.developer.kernel.increased-memory-limit` entitlement, and still pick the smallest model that passes your evals.

### MLX

```swift
// Package: https://github.com/ml-explore/mlx-swift-lm   product: MLXFoundationModels (+ MLXHuggingFace)
let model = #huggingFaceLanguageModel(
    configuration: LLMRegistry.qwen3_0_6b_4bit,
    capabilities: [.reasoning])                        // DECLARED, not inferred
let session = LanguageModelSession(model: model)
```

- MLX **does not infer capabilities**. The default is `[.guidedGeneration]`. Declare `.toolCalling`, `.reasoning`, and `.vision` only if the checkpoint truly supports them.
- `model.availability` reports `.available`, `.downloading`, or `.unavailable(…)`, so gate the UI on it while weights download.
- The adapter compiles to an empty module on SDKs older than 27.0 (the `FoundationModelsIntegration` trait).

## 2. Route With Capabilities and Fallbacks

```swift
struct ModelRouter: Sendable {
    var localModel: (any LanguageModel)?            // CoreAILanguageModel or MLXLanguageModel

    func session(for choice: ModelChoice, instructions: String, tools: [any Tool] = []) -> LanguageModelSession? {
        switch choice {
        case .system:
            guard SystemLanguageModel.default.isAvailable else { return nil }
            return LanguageModelSession(tools: tools, instructions: instructions)
        case .cloud:
            let pcc = PrivateCloudComputeLanguageModel()
            guard pcc.isAvailable else { return nil }
            return LanguageModelSession(model: pcc, tools: tools, instructions: instructions)
        case .local:
            guard let localModel else { return nil }
            return LanguageModelSession(model: localModel, tools: tools, instructions: instructions)
        }
    }

    func supports(_ choice: ModelChoice, _ capability: LanguageModelCapabilities.Capability) -> Bool {
        switch choice {
        case .system: SystemLanguageModel.default.capabilities.contains(capability)
        case .cloud: PrivateCloudComputeLanguageModel().capabilities.contains(capability)
        case .local: localModel?.capabilities.contains(capability) ?? false
        }
    }
}
```

The template's `tag(_:router:preferring:)` walks a preference order, skips backends
without `.guidedGeneration`, and continues past `LanguageModelError.unsupportedCapability`.
That gives you **Apple Intelligence devices → Apple model, older iPhones → your open
model**, with one call site.

- ✅ Ship the open model as the **fallback** for non-Apple-Intelligence devices. It's the cleanest way to give every tester the feature (`on-device-ai-kit`).
- ❌ Assuming `@Generable` output from a backend that doesn't declare `.guidedGeneration`. The framework throws `unsupportedCapability`, so handle it.
- Prompts tuned for Apple's model don't transfer 1:1. Keep one eval set and run it per backend.

## 3. Core AI for Any Neural Network

```swift
import CoreAI

actor ClassifierModel {
    private var function: InferenceFunction?

    func load(from url: URL, onSlowPath: @Sendable () async -> Void) async throws {
        let model: AIModel
        if let cached = try AIModelCache.default.model(for: url, options: .default) {
            model = cached                                             // instant
        } else {
            await onSlowPath()                                         // "Preparing AI features…"
            model = try await AIModel(contentsOf: url, options: .default)   // specializes + caches
        }
        guard let fn = try model.loadFunction(named: "main") else { throw CocoaError(.featureUnsupported) }
        guard case .ndArray(let d)? = fn.descriptor.inputDescriptor(of: "input"),
              d.scalarType == .float32 else { throw CocoaError(.coderInvalidValue) }   // verify the contract
        function = fn
    }

    func predict(_ features: [Float]) async throws -> [Float] {
        guard let function else { throw CocoaError(.featureUnsupported) }
        var input = NDArray(shape: [1, features.count], scalarType: .float32)
        let view = input.mutableView(as: Float.self)
        guard var elements = view.contiguousElements else { throw CocoaError(.coderInvalidValue) }
        for i in features.indices { elements[i] = features[i] }
        var outputs = try await function.run(inputs: ["input": input])
        guard let out = outputs.remove("prediction")?.ndArray else { throw CocoaError(.coderValueNotFound) }
        let read = out.view(as: Float.self)
        guard let values = read.contiguousElements else { throw CocoaError(.coderInvalidValue) }
        return (0..<values.count).map { values[$0] }
    }
}
```

- **Pipeline:** PyTorch → `coreai-opt` (compress) → `coreai-torch` (export `.aimodel`) → Xcode. Apple's agent skills for this live in `apple/coreai-models/skills`.
- **Xcode needs the Metal Toolchain** (Settings ▸ Components, or `xcodebuild -downloadComponent MetalToolchain`). Without it, builds containing `.aimodel` files fail with a missing Metal compiler error.
- **Specialization** happens on first load and is cached per OS version. Check `AIModelCache.default.model(for:options:)` first, and call `AIModel.specialize(contentsOf:options:)` right after a download so first use isn't slow.
- **Ahead-of-time:** `xcrun coreai-build compile M.aimodel --platform iOS --min-deployment-version 27.0 --output compiled/` emits one `.aimodelc` per device architecture. Host them and download only `M.\(AIModel.deviceArchitectureName).aimodelc` (Background Assets).
- **Cache policy:** if you delete the source file to save space, specialize with `cachePolicy: .persistent`. Call `AIModelCache.default.deleteEntries(for:)` when replacing a model.
- **Images:** inputs and outputs marked as images use `CVMutablePixelBuffer`. Read the `ImageDescriptor` (−1 = dynamic dimension).
- **LLM-style dynamic shapes:** `expectFrequentReshapes` skips per-shape optimization.
- **Background:** running on the Neural Engine from a background task needs the Background Inference entitlement.
- Profile with the Core AI instrument and debug gauge. Inspect tensors in the Core AI Debugger app.

## 4. Shipping Model Files

| Size | Strategy |
|---|---|
| < ~100 MB | Bundle in the app target |
| Larger, or several variants | Download after install (Background Assets / Apple-hosted asset packs), then `specialize` |
| Per-architecture `.aimodelc` | Always download, matching only `deviceArchitectureName` |

- ✅ Show download size, progress, and a Wi-Fi-only option. Models are hundreds of MB to several GB.
- ✅ Check the license of open weights (Gemma, Llama, and Qwen all differ) and list it in your app's acknowledgements.
- ❌ Downloading code or models that change app functionality in ways App Review didn't see. Weights for a feature you shipped are fine; a new feature isn't (Guideline 2.5.2).

## Checklist

- [ ] Backend chosen per feature; capability checks before guided generation or tools
- [ ] Fallback order defined (system → local → cloud, or whatever fits the feature)
- [ ] One eval set run against every backend you ship
- [ ] Core AI: Metal Toolchain installed; cache-first load; specialize after download
- [ ] Memory: smallest passing model; increased-memory-limit entitlement if needed; `unload()` when idle
- [ ] Downloads: size disclosed, resumable, Wi-Fi option; licenses acknowledged

## References

- Core AI: https://developer.apple.com/documentation/coreai
- Integrating on-device AI models in your app with Core AI: https://developer.apple.com/documentation/coreai/integrating-on-device-ai-models-in-your-app-with-core-ai
- Managing model specialization and caching: https://developer.apple.com/documentation/coreai/managing-model-specialization-and-caching
- Compiling Core AI models ahead of time: https://developer.apple.com/documentation/coreai/compiling-core-ai-models-ahead-of-time
- LanguageModel protocol: https://developer.apple.com/documentation/foundationmodels/languagemodel
- Meet Core AI (WWDC26): https://developer.apple.com/videos/play/wwdc2026/324/
- Bring an LLM provider to the Foundation Models framework (WWDC26): https://developer.apple.com/videos/play/wwdc2026/339/
- Packages: https://github.com/apple/coreai-models · https://github.com/ml-explore/mlx-swift-lm
- Related: `apple-intelligence/foundation-models` (`models-and-agents.md`, `utilities-package.md`), `apple-intelligence/on-device-ai-kit`, `core-ml`
