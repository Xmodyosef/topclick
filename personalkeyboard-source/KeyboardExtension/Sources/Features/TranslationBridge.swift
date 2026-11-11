import SwiftUI
import Translation
import UIKit
import AudioToolbox
import Combine

final class TranslationBridgeModel: ObservableObject {
    @Published var sourceText = ""
    @Published var token = 0
    var sourceLang = "ar"
    var targetLang = "en"
    var onResult: ((String) -> Void)?
    var onError: ((String) -> Void)?
}

struct TranslationBridgeView: View {
    @ObservedObject var model: TranslationBridgeModel
    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                Color.clear.frame(width: 1, height: 1)
                    .translationTask(
                        TranslationSession.Configuration(
                            source: Locale.Language(identifier: model.sourceLang),
                            target: Locale.Language(identifier: model.targetLang)
                        )
                    ) { session in
                        let text = model.sourceText
                        guard !text.isEmpty else { return }
                        do {
                            let response = try await session.translate(text)
                            await MainActor.run { model.onResult?(response.targetText) }
                        } catch {
                            await MainActor.run { model.onError?("تعذّرت الترجمة. تحقق من توفر حزمة اللغة وحاول مجددًا") }
                        }
                    }
                    .id(model.token)
            }
        }
    }
}

