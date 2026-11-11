import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Translation availability

@available(iOS 18.0, *)
struct TranslationPrepCard: View {
    @State private var status = "جاري فحص حزم الترجمة…"

    var body: some View {
        SettingsCard(title: "ترجمة iOS 18", subtitle: "ترجمة عربية وإنجليزية داخل الجهاز") {
            Text(status)
                .font(.system(size: 12))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .task {
            let availability = LanguageAvailability()
            let arEn = await availability.status(from: Locale.Language(identifier: "ar"), to: Locale.Language(identifier: "en"))
            let enAr = await availability.status(from: Locale.Language(identifier: "en"), to: Locale.Language(identifier: "ar"))
            switch (arEn, enAr) {
            case (.installed, .installed): status = "حزمتا العربية والإنجليزية جاهزتان."
            case (.unsupported, _), (_, .unsupported): status = "هذا الجهاز لا يدعم زوج اللغات المطلوب."
            default: status = "اللغتان مدعومتان؛ قد تُنزّل الحزم عند أول ترجمة."
            }
        }
    }
}
