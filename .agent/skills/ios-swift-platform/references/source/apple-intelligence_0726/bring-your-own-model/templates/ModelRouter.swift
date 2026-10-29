import Foundation
import CoreAI
import FoundationModels

// MARK: - Core AI: load a bundled .aimodel with cache-aware specialization

enum ModelLoadState: Equatable, Sendable { case idle, specializing, ready, failed(String) }

actor ClassifierModel {
    private var function: InferenceFunction?

    /// Fast path: cached specialization. Slow path: specialize now (can take a while on first launch).
    func load(from url: URL, onSlowPath: @Sendable () async -> Void) async throws {
        let model: AIModel
        if let cached = try AIModelCache.default.model(for: url, options: .default) {
            model = cached
        } else {
            await onSlowPath()                                       // show "Preparing…" UI
            model = try await AIModel(contentsOf: url, options: .default)
        }
        guard let fn = try model.loadFunction(named: "main") else { throw CocoaError(.featureUnsupported) }
        // Verify the contract you coded against before running anything.
        guard case .ndArray(let d)? = fn.descriptor.inputDescriptor(of: "input"),
              d.scalarType == .float32 else { throw CocoaError(.coderInvalidValue) }
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

/// Call after downloading a model, so the first use doesn't stall.
func prepareDownloadedModel(at url: URL) async throws {
    try await AIModel.specialize(contentsOf: url, options: .default)
}

// MARK: - One session API, many models

enum ModelChoice: String, CaseIterable, Sendable {
    case system        // Apple on-device (Apple Intelligence devices)
    case cloud         // Private Cloud Compute (entitlement, network, quota)
    case local         // your open model via Core AI or MLX (any LanguageModel)
}

struct ModelRouter: Sendable {
    /// Inject the open model (CoreAILanguageModel / MLXLanguageModel) from the package you chose.
    var localModel: (any LanguageModel)?

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

    /// Ask before you rely on structured output or tools; capabilities differ per backend.
    func supports(_ choice: ModelChoice, _ capability: LanguageModelCapabilities.Capability) -> Bool {
        switch choice {
        case .system: SystemLanguageModel.default.capabilities.contains(capability)
        case .cloud: PrivateCloudComputeLanguageModel().capabilities.contains(capability)
        case .local: localModel?.capabilities.contains(capability) ?? false
        }
    }
}

@Generable
struct Tags { var tags: [String] }

func tag(_ text: String, router: ModelRouter, preferring order: [ModelChoice] = [.system, .local, .cloud]) async throws -> [String] {
    for choice in order where router.supports(choice, .guidedGeneration) {
        guard let session = router.session(for: choice, instructions: "Return up to 3 lowercase tags.") else { continue }
        do {
            return try await session.respond(to: text, generating: Tags.self).content.tags
        } catch let error as LanguageModelError {
            if case .unsupportedCapability = error { continue }      // backend can't do this; try the next
            throw error
        }
    }
    return []
}
