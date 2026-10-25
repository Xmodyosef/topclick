import SwiftUI
import Translation
import UIKit
import AudioToolbox

final class KeyboardViewController: UIInputViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { return true }
    var language: KeyboardLanguage = .arabic
    var page: KeyboardPage = .letters
    var isShifted = false
    var symbolPageIndex = 0
    var emojiCategoryIndex = 0
    var palette = NaqraPalette.current()

    // Keep the extension light: a solid background avoids a live blur pass.
    let blurView = UIVisualEffectView(effect: nil)
    let rootStack = UIStackView()
    var heightConstraint: NSLayoutConstraint?
    var deleteTimer: Timer?
    var deleteStartX: CGFloat = 0
    var lastSpaceTap: Date?
    let spaceSwitchInterval: TimeInterval = 0.25
    var spaceStart: CGPoint = .zero
    var spaceIsTrackpad = false
    var lastTrackpadX: CGFloat = 0
    var holdTimer: Timer?
    var downText = ""
    var pendingInserted = false
    var holdPopup: UIView?
    var holdChoice = ""

    let translationModel = TranslationBridgeModel()
    var translationHost: UIHostingController<TranslationBridgeView>?
    var emojiPager: UIScrollView?
    var emojiTabs: UIStackView?
    var suggestionButtons: [UIButton] = []
    var appliedThemeId = ""
    var noticeLabel: UILabel?
    var pendingTranslationText = ""
    var clipboardLongPressInProgress = false
    weak var clipboardPanel: UIView?
    var isClipboardPanelVisible = false


    var letterFont: UIFont {
        // One compact, predictable font keeps Arabic and English aligned.
        .systemFont(ofSize: 26, weight: .medium)
    }
    let iconConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    let boardHeight: CGFloat = 324
    let numberRow = ["1","2","3","4","5","6","7","8","9","0"]
    var showNumberRow: Bool { ThemeIO.bool("showNumberRow") ?? true }
    var themeSignature: String {
        let id = ThemeIO.string("themeId") ?? "auto"
        return id == "auto" ? "auto-\(TimeTheme.preferredThemeId())" : id
    }

    // Arabic letter rows contain 11 / 11 / 9 keys, kept simple and predictable.
    var arabicRows: [[String]] { KeyboardDataLoader.layouts().arabicRows }
    var arabicShiftRows: [[String]] { KeyboardDataLoader.layouts().arabicShiftRows }
    var englishLower: [[String]] { KeyboardDataLoader.layouts().englishLower }
    var englishUpper: [[String]] { KeyboardDataLoader.layouts().englishUpper }
    var symbolPages: [[[String]]] {
        language == .arabic
            ? KeyboardDataLoader.layouts().arabicSymbolPages
            : KeyboardDataLoader.layouts().englishSymbolPages
    }
    var emojiPack: [(icon: String, items: [String])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        emojiPack = Self.catalog()
        view.backgroundColor = .clear
        configureRoot()
        attachBridge()
        loadPrefs()
        listenPrefs()
        translationModel.onResult = { [weak self] t in self?.applyTranslation(t) }
        translationModel.onError = { [weak self] message in self?.showNotice(message) }
        ClipboardHistory.shared.ensurePrivacyDefault()
        TapSoundEngine.shared.setEnabled(ThemeIO.bool("sounds") ?? true)
        armHaptics()
        rebuild()
    }

    deinit {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), Unmanaged.passUnretained(self).toOpaque(), CFNotificationName("app.personal.PersonalKeyboard.prefs" as CFString), nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.clipsToBounds = false
        updateHeightForCurrentSize()
        if themeSignature != appliedThemeId {
            appliedThemeId = themeSignature
            palette = NaqraPalette.current()
            rebuild()
        }
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        refreshSuggestions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deleteTimer?.invalidate()
        deleteTimer = nil
        holdTimer?.invalidate()
        holdTimer = nil
        hideHoldPopup()
        hideClipboardPanel()
        pendingInserted = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeightForCurrentSize()
    }



    var hapticsOn: Bool {
        (ThemeIO.bool("haptics") ?? true) && ThemeIO.string("hapticLevel") != "none"
    }
    var trackpadOn: Bool { ThemeIO.bool("trackpad") ?? true }
    enum Pulse { case key, action, del, move }
    let selectionFeedback = UISelectionFeedbackGenerator()

    var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch ThemeIO.string("hapticLevel") ?? "medium" {
        case "light": return .light
        case "strong": return .heavy
        default: return .medium
        }
    }



    func playSystemClick(_ sound: TapSoundEngine.Sound = .rowMid) {
        guard enableInputClicksWhenVisible else { return }
        TapSoundEngine.shared.setEnabled(ThemeIO.bool("sounds") ?? true)
        TapSoundEngine.shared.play(sound)
    }













    static func fold(_ s: String) -> String {
        let map: [Character: Character] = ["أ":"ا","إ":"ا","آ":"ا","ى":"ي","ة":"ه","ؤ":"و","ئ":"ي","ٱ":"ا"]
        return String(s.lowercased().map { map[$0] ?? $0 })
    }

    static var arabicLexicon: [String] { KeyboardDataLoader.arabicLexicon() }
















    func refreshTabs() {
        guard let tabs = emojiTabs else { return }
        for (i, view) in tabs.arrangedSubviews.enumerated() {
            view.backgroundColor = i == emojiCategoryIndex ? UIColor.white.withAlphaComponent(0.22) : .clear
        }
    }



    var holdMap: [String: [String]] { KeyboardDataLoader.layouts().holdMap }


    func alts(for key: String) -> [String] {
        holdMap[key] ?? []
    }

    /// Long-press menu: base key first, then alternates (no duplicates).
    func holdChoices(for key: String) -> [String] {
        let extras = alts(for: key)
        guard !extras.isEmpty else { return [] }
        var out: [String] = [key]
        for item in extras where item != key && !out.contains(item) {
            out.append(item)
        }
        return out
    }


    func control(_ t: String, _ a: Selector, font: CGFloat) -> UIButton {
        let b = KeyButton(type: .system)
        b.setTitle(t, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: font, weight: .semibold)
        paint(b)
        b.addTarget(self, action: a, for: .touchUpInside)
        return b
    }


    func fallbackSymbol(_ name: String) -> String {
        switch name {
        case "translate": return "globe"
        case "doc.on.clipboard": return "doc.on.doc"
        case "arrow.down.to.line": return "arrow.down"
        default: return "circle"
        }
    }
















    @objc func periodTapped() {
        textDocumentProxy.insertText(".")
        tapHaptic(.action)
    }



    @objc func symbolsOrLettersTapped() {
        if page == .symbols {
            page = .letters
        } else if page == .emoji {
            page = .letters
        } else {
            page = .symbols
        }
        symbolPageIndex = 0
        rebuild()
    }








    static func loadFrequent() -> [String] {
        let raw = ThemeIO.string("frequentEmoji") ?? "😀 😂 ❤️ 😍 🔥 👍 🙏 😊 ✨ 😭 👏 💕 🌹 🇾🇪 🎉 😎"
        return raw.split(separator: " ").map(String.init)
    }

    static func catalog() -> [(icon: String, items: [String])] {
        KeyboardDataLoader.emojiCatalog(frequent: loadFrequent())
    }
}
