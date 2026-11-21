import SwiftUI
import Translation
import UIKit
import AudioToolbox

struct SkinSession {
    let base: String
    let tones: [String]
    var armedIndex: Int?
}

final class KeyboardViewController: UIInputViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { return true }
    var language: KeyboardLanguage = .arabic
    var page: KeyboardPage = .letters
    var isShifted = false
    var symbolPageIndex = 0
    var emojiCategoryIndex = 0
    /// Invalidates callbacks from emoji animations when the page is rebuilt or hidden.
    var emojiTransitionGeneration: UInt64 = 0
    var palette = NaqraPalette.current()

    // Keep the extension light: a solid background avoids a live blur pass.
    let blurView = UIVisualEffectView(effect: nil)
    let rootStack = UIStackView()
    var heightConstraint: NSLayoutConstraint?
    var deleteTimer: Timer?
    var deleteStartX: CGFloat = 0
    var lastSpaceTap: Date?
    let spaceSwitchInterval: TimeInterval = 0.40
    var spaceStart: CGPoint = .zero
    var spaceIsTrackpad = false
    var lastTrackpadX: CGFloat = 0
    var holdTimer: Timer?
    var downText = ""
    var pendingInserted = false
    var holdPopup: UIView?
    var holdChoice = ""
    /// One reused magnified-key bubble. Never allocated per key.
    var keyPreview: UILabel?
    /// Diagnostic overlay. Not part of the key stack.
    var themeTraceLabel: UILabel?

    let translationModel = TranslationBridgeModel()
    var translationHost: UIHostingController<TranslationBridgeView>?
    var emojiPager: UIView?
    weak var emojiCollection: UICollectionView?
    /// Transient snapshot while scrubbing emoji categories (single CV, low memory).
    var emojiSwipeSnapshot: UIView?
    var emojiTabs: UIStackView?
    /// One reused skin-tone strip (6 tones). Never allocated per cell.
    var emojiSkinBar: UIView?
    var emojiSkinButtons: [UIButton] = []
    var emojiSkinBase: String = ""
    /// Tone under the finger during the same long-press. Committed on lift.
    var emojiSkinArmedIndex: Int?
    /// Long-press session. Survives dismissSkinBar(); cleared only by endSkinSession().
    var skinSession: SkinSession?
    weak var emojiSkinLongPress: UILongPressGestureRecognizer?
    var suggestionButtons: [UIButton] = []
    var appliedThemeId = ""
    var noticeLabel: UILabel?
    /// On-keyboard memory report. Overlay only; not part of the key stack height.
    var memoryPanel: UIView?
    var pendingTranslationText = ""
    var clipboardLongPressInProgress = false
    weak var clipboardPanel: UIView?
    var isClipboardPanelVisible = false
    /// Letter-key buttons on the letters page (for in-place shift without rebuild).
    /// Each row is allocated at the wider Arabic/English capacity; spare keys stay hidden.
    var letterKeyButtons: [[UIButton]] = []
    /// Digit keys, retitled in place when the language changes. Empty when that row is off.
    var numberRowButtons: [UIButton] = []
    /// Set only after the wide letter grid is mounted. Language switches retitle it.
    var letterGridStable = false
    weak var shiftKeyButton: UIButton?
    var displayedNeedsInputModeSwitchKey: Bool?
    /// Coalesces language changes and lets the current touch event finish before rebuilding.
    var languageRebuildScheduled = false
    /// Page body only. Toolbar and bottom stay when the page shell is unchanged.
    let middleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.distribution = .fill
        stack.alignment = .fill
        return stack
    }()
    weak var topChrome: UIView?
    weak var bottomChrome: UIView?
    weak var languageKeyButton: UIButton?
    weak var symbolsModeButton: UIButton?
    /// Both live in the bottom bar. One is hidden so emoji does not allocate a new bar.
    weak var bottomPeriodButton: UIButton?
    weak var bottomDeleteButton: UIButton?
    /// page + globe + theme. Language is retitled in place and is not part of this key.
    var mountedChromeKey = ""

    let iconConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    let boardHeight: CGFloat = 324
    /// Number row matches active language; long-press still offers the other script via hold_map.
    var numberRow: [String] {
        language == .arabic
            ? ["١","٢","٣","٤","٥","٦","٧","٨","٩","٠"]
            : ["1","2","3","4","5","6","7","8","9","0"]
    }
    var showNumberRow: Bool { ThemeIO.bool("showNumberRow") ?? true }
    var themeSignature: String {
        let id = ThemeIO.string("naqra.themeId") ?? "auto"
        let base = id == "auto" ? "auto-\(TimeTheme.preferredThemeId())" : id
        // Special-key overrides (shift/lang/symbols/enter/delete/period/emoji) must force repaint.
        let specials = ["shift", "language", "enter", "delete", "symbols", "period", "emoji"]
            .map { ThemeIO.string("specialKey.\($0)") ?? "" }
            .joined(separator: "|")
        return "\(base)|\(specials)"
    }

    // Arabic letter rows contain 11 / 11 / 9 keys, kept simple and predictable.
    var arabicRows: [[String]] { KeyboardDataLoader.layouts().arabicRows }
    var arabicShiftRows: [[String]] { KeyboardDataLoader.layouts().arabicShiftRows }
    var englishLower: [[String]] { KeyboardDataLoader.layouts().englishLower }
    var englishUpper: [[String]] { KeyboardDataLoader.layouts().englishUpper }
    var symbolPages: [[[String]]] {
        let configured = language == .arabic
            ? KeyboardDataLoader.layouts().arabicSymbolPages
            : KeyboardDataLoader.layouts().englishSymbolPages
        let fallback = language == .arabic
            ? KeyboardDataLoader.builtinArabicSymbols
            : KeyboardDataLoader.builtinEnglishSymbols
        var pages = Array(configured.prefix(2))
        if pages.isEmpty {
            pages = Array(fallback.prefix(2))
        } else if pages.count == 1, fallback.count > 1 {
            pages.append(fallback[1])
        }
        return pages
    }
    var emojiPack: [(icon: String, items: [String])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        displayedNeedsInputModeSwitchKey = needsInputModeSwitchKey
        view.backgroundColor = .clear
        configureRoot()
        // Translation UIHostingController is created on first translate tap (lazy).
        // Eager attach paid for Translation framework cost on every keyboard open.
        loadPrefs()
        LanguageDiagnostics.syncFontFlag()
        listenPrefs()
        translationModel.onResult = { [weak self] t in self?.applyTranslation(t) }
        translationModel.onError = { [weak self] message in self?.showNotice(message) }
        ClipboardHistory.shared.ensurePrivacyDefault()
        TapSoundEngine.shared.configure(enabled: ThemeIO.bool("sounds") ?? false, choice: ThemeIO.string("soundChoice") ?? "system")
        armHaptics()
        rebuild()
    }

    deinit {
        CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), Unmanaged.passUnretained(self).toOpaque(), CFNotificationName("app.personal.PersonalKeyboard.prefs" as CFString), nil)
        KeyboardDataLoader.clearEmojiCache()
        // UIInputViewController's view can outlive the controller. Drop the tree next turn.
        let retained = viewIfLoaded
        DispatchQueue.main.async {
            retained?.subviews.forEach { $0.removeFromSuperview() }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.clipsToBounds = false
        syncInputModeSwitchKey()
        updateHeightForCurrentSize()
        // Opening the keyboard must show the theme just chosen in the app.
        applyThemeFromGroupIfNeeded()
    }

    /// Read naqra.themeId from group.Mark1 (file first, then the suite) and recolor if it changed.
    func applyThemeFromGroupIfNeeded() {
        ThemeIO.flushShared()
        let sig = themeSignature
        let next = NaqraPalette.current()
        if sig != appliedThemeId || !paletteMatches(next) {
            appliedThemeId = sig
            palette = next
            let before = LanguageDiagnostics.begin()
            let themeBefore = sig
            rebuild()
            view.layoutIfNeeded()
            let themeNote = themeBefore == themeSignature ? "theme same" : "theme CHANGED"
            LanguageDiagnostics.mark("theme", before: before, note: themeNote)
        }
    }

    func paletteMatches(_ other: NaqraPalette) -> Bool {
        func components(_ c: UIColor) -> [CGFloat] {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            c.getRed(&r, green: &g, blue: &b, alpha: &a)
            return [r, g, b, a]
        }
        guard palette.blurDark == other.blurDark else { return false }
        let k = zip(components(palette.key), components(other.key)).allSatisfy { abs($0 - $1) < 0.02 }
        let a = zip(components(palette.accent), components(other.accent)).allSatisfy { abs($0 - $1) < 0.02 }
        return k && a
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        syncInputModeSwitchKey()
        refreshSuggestions()
    }

    func syncInputModeSwitchKey() {
        let required = needsInputModeSwitchKey
        guard displayedNeedsInputModeSwitchKey != required else { return }
        displayedNeedsInputModeSwitchKey = required
        rebuild()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetSpaceTapSequence()
        deleteTimer?.invalidate()
        deleteTimer = nil
        holdTimer?.invalidate()
        holdTimer = nil
        hideHoldPopup()
        cancelEmojiTransientInteractions()
        hideKeyPreview()
        hideClipboardPanel()
        pendingInserted = false
        discardEmojiIfLeaving()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        KeyboardTypography.clearFontCache()
        TapSoundEngine.shared.clearCache()
        detachTranslationBridge()
        if page != .emoji {
            emojiPack = []
            KeyboardDataLoader.clearEmojiCache()
        }
    }

    /// Emoji is not part of the resting keyboard. Drop it when the extension hides.
    /// If the in-place swap cannot restore the letter surface (e.g. toolbar was
    /// never mounted because emoji used a full surface), rebuild so middle is
    /// not left holding the emoji collection under Jetsam pressure.
    func discardEmojiIfLeaving() {
        if page == .emoji {
            page = .letters
            if !swapEmojiSurface() {
                releaseEmojiSurface()
                rebuild()
            }
        }
        emojiPack = []
        KeyboardDataLoader.clearEmojiCache()
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
        TapSoundEngine.shared.play(sound)
    }













    static func fold(_ s: String) -> String {
        let map: [Character: Character] = ["أ":"ا","إ":"ا","آ":"ا","ى":"ي","ة":"ه","ؤ":"و","ئ":"ي","ٱ":"ا"]
        return String(s.lowercased().map { map[$0] ?? $0 })
    }

















    // refreshTabs lives in KeyboardViewController+Emoji (single implementation).



    var holdMap: [String: [String]] { KeyboardDataLoader.layouts().holdMap }


    func alts(for key: String) -> [String] {
        if let direct = holdMap[key], !direct.isEmpty { return direct }
        // English shift: map "A" → hold of "a"
        if key.count == 1, let ch = key.unicodeScalars.first, CharacterSet.uppercaseLetters.contains(ch) {
            let lower = key.lowercased()
            if let v = holdMap[lower], !v.isEmpty {
                return v.map { $0.uppercased() }
            }
        }
        if key.count == 1, let ch = key.unicodeScalars.first, CharacterSet.lowercaseLetters.contains(ch) {
            let upper = key.uppercased()
            if let v = holdMap[upper], !v.isEmpty { return v }
        }
        return []
    }

    /// Long-press menu: alternates only (no base key — avoids visual duplicate of the pressed letter).
    func holdChoices(for key: String) -> [String] {
        let extras = alts(for: key)
        guard !extras.isEmpty else { return [] }
        var out: [String] = []
        for item in extras where item != key && !out.contains(item) {
            out.append(item)
        }
        return out
    }


    enum KeyChrome { case letter, control, symbols, emoji, language, shift, enter, danger, period }

    func control(_ t: String, _ a: Selector, font: CGFloat, chrome: KeyChrome = .control) -> UIButton {
        let b = KeyButton(type: .system)
        b.setTitle(t, for: .normal)
        b.titleLabel?.font = KeyboardTypography.font(for: t, size: font, weight: .semibold)
        paint(b, chrome: chrome)
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
        playSystemClick(.rowMid)
        tapHaptic(.action)
    }



    @objc func symbolPageToggled() {
        guard page == .symbols, symbolPages.count > 1 else { return }
        resetSpaceTapSequence()
        symbolPageIndex = (symbolPageIndex + 1) % symbolPages.count
        rebuild()
        tapHaptic(.action)
    }

    @objc func symbolsOrLettersTapped() {
        resetSpaceTapSequence()
        if page == .emoji {
            page = .letters
            if !swapEmojiSurface() { rebuild() }
            return
        }
        if page == .symbols {
            page = .letters
            symbolPageIndex = 0
        } else {
            page = .symbols
            symbolPageIndex = 0
        }
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
