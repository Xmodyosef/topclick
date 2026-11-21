import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Actions
extension KeyboardViewController {
    func persistAccess() { ThemeIO.set("hasFullAccess", value: hasFullAccess) }
    func loadPrefs() {
        persistAccess()
        if page != .emoji { page = .letters }
        let raw = ThemeIO.string("lastLanguage") ?? "ar"
        language = raw == "en" ? .english : .arabic
        primaryLanguage = language == .arabic ? "ar" : "en"
    }
    func listenPrefs() {
        let me = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            me,
            { _, observer, _, _, _ in
                guard let observer else { return }
                let vc = Unmanaged<KeyboardViewController>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    TapSoundEngine.shared.configure(
                        enabled: ThemeIO.bool("sounds") ?? false,
                        choice: ThemeIO.string("soundChoice") ?? "system"
                    )
                    vc.applyThemeFromGroupIfNeeded()
                }
            },
            "app.personal.PersonalKeyboard.prefs" as CFString,
            nil,
            .deliverImmediately
        )
    }
    func playSystemSound() { playSystemClick(.rowMid) }

    /// EXP-2 (jetsam): do not host SwiftUI/Translation for every keyboard session.
    /// Attach only when the user requests translation.
    func ensureTranslationBridge() {
        guard translationHost == nil else { return }
        attachBridge()
    }

    func detachTranslationBridge() {
        guard let host = translationHost else { return }
        host.willMove(toParent: nil)
        host.view.removeFromSuperview()
        host.removeFromParent()
        translationHost = nil
        // Drop pending text so a stale host cannot fire after detach.
        translationModel.sourceText = ""
    }

    func attachBridge() {
        let host = UIHostingController(rootView: TranslationBridgeView(model: translationModel))
        translationHost = host
        addChild(host)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.widthAnchor.constraint(equalToConstant: 1),
            host.view.heightAnchor.constraint(equalToConstant: 1),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        host.didMove(toParent: self)
    }
    @objc func copyPasteTapped() {
        guard !clipboardLongPressInProgress else { return }
        // Short tap: copy selection OR paste live with iOS-style toast — never open the history list.
        if let selected = textDocumentProxy.selectedText, !selected.isEmpty {
            copyNow()
            return
        }
        pasteNow()
    }
    func copyNow() {
        guard hasFullAccess else {
            showNotice("النسخ يحتاج تفعيل الوصول الكامل للوحة")
            return
        }
        persistAccess()
        guard let text = textDocumentProxy.selectedText, !text.isEmpty else {
            showNotice("حدّد النص أولًا، ثم اضغط زر النسخ")
            return
        }
        UIPasteboard.general.string = text
        ClipboardHistory.shared.add(text)
        showNotice("تم النسخ")
        tapHaptic()
    }
    func pasteNow() {
        guard hasFullAccess else {
            showNotice("اللصق يحتاج تفعيل الوصول الكامل للوحة")
            return
        }
        persistAccess()
        if let text = UIPasteboard.general.string, !text.isEmpty {
            textDocumentProxy.insertText(text)
            playSystemClick(.rowMid)
            showNotice("تم اللصق")
            tapHaptic()
        } else {
            showNotice("الحافظة فارغة")
        }
    }
    @objc func translateTapped() {
        guard hasFullAccess else {
            showNotice("الترجمة تحتاج تفعيل الوصول الكامل للوحة")
            return
        }
        persistAccess()
        guard #available(iOS 18.0, *) else {
            showNotice("الترجمة تتطلب iOS 18 أو أحدث")
            return
        }
        guard let text = textDocumentProxy.selectedText, !text.isEmpty else {
            showNotice("حدّد النص الذي تريد ترجمته أولًا")
            return
        }
        // EXP-2: host is allocated only on the translate path.
        ensureTranslationBridge()
        pendingTranslationText = text
        let arabicCount = text.unicodeScalars.filter { $0.value >= 0x0600 && $0.value <= 0x06FF }.count
        let translateToEnglish = arabicCount >= max(1, text.count / 4)
        translationModel.sourceLang = translateToEnglish ? "ar" : "en"
        translationModel.targetLang = translateToEnglish ? "en" : "ar"
        translationModel.sourceText = text
        translationModel.token += 1
    }
    func applyTranslation(_ text: String) {
        guard !text.isEmpty else {
            showNotice("لم تصل نتيجة ترجمة")
            return
        }
        guard textDocumentProxy.selectedText == pendingTranslationText else {
            showNotice("تغيّر التحديد؛ حدّد النص مرة أخرى وأعد المحاولة")
            return
        }
        textDocumentProxy.insertText(text)
        pendingTranslationText = ""
        // Free the Translation host after a successful result; next tap re-attaches.
        detachTranslationBridge()
        tapHaptic(.action)
    }
}
