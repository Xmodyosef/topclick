import SwiftUI
import Translation
import UIKit
import AudioToolbox

// Official system click (lightest, respects system mute)


enum KeyboardLanguage { case arabic, english }

enum ThemeIO {
    static let group = "group.app.personal.PersonalKeyboard"
    static let notificationName = "app.personal.PersonalKeyboard.prefs"
    static var suite: UserDefaults { UserDefaults(suiteName: group) ?? .standard }

    static func write(_ key: String, value: Any) {
        suite.set(value, forKey: key)
        suite.synchronize()
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil, nil, true
        )
    }

    static func string(_ key: String) -> String? {
        suite.synchronize()
        return suite.string(forKey: key) ?? UserDefaults.standard.string(forKey: key)
    }

    static func bool(_ key: String) -> Bool? {
        suite.synchronize()
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
        return nil
    }
}

enum TimeTheme {
    static func isMorning() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 6 && hour < 18
    }
    static func preferredThemeId() -> String {
        isMorning() ? "morning" : "evening"
    }
}

enum KeyboardPage { case letters, symbols, emoji }

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

struct NaqraPalette {
    var background: UIColor
    var key: UIColor
    var text: UIColor
    var accent: UIColor
    var blurDark: Bool

    static let order = [
        "auto","light","dark","glass","ocean","cobalt","violet","orchid","hailey","ember","forest","matrix","nord",
        "morning","evening",
        "m1","m2","m3","m4","m5","m6","m7","m8","m9","m10",
        "m11","m12","m13","m14","m15","m16","m17","m18","m19","m20",
        "e1","e2","e3","e4","e5","e6","e7","e8","e9","e10",
        "e11","e12","e13","e14","e15","e16","e17","e18","e19","e20",
        "custom"
    ]
    static let titles = [
        "auto":"تلقائي","light":"فاتح","dark":"داكن","glass":"منشور","ocean":"بحر","cobalt":"كوبالت",
        "violet":"بنفسج","orchid":"أوركيد","hailey":"دم","ember":"جمر","forest":"غابة","matrix":"ماتريكس","nord":"نورد",
        "morning":"صباح","evening":"مساء",
        "m1":"رملي","m2":"قش","m3":"خوخ","m4":"مشمش","m5":"عاج","m6":"حليب","m7":"نعناع","m8":"مريمية",
        "m9":"سماء","m10":"بحيرة","m11":"لافندر","m12":"ورد","m13":"ذهب","m14":"عسل","m15":"زيتون",
        "m16":"طين","m17":"ورق","m18":"ضباب","m19":"مرجان","m20":"فستق",
        "e1":"فحم","e2":"كحلي","e3":"ليل","e4":"حبر","e5":"برقوق","e6":"نبيذ","e7":"غابة","e8":"زمرد",
        "e9":"محيط","e10":"كوبالت ليلي","e11":"جمر","e12":"نحاس","e13":"بنفسج ليلي","e14":"أوركيد ليلي",
        "e15":"رماد","e16":"دخان","e17":"قهوة","e18":"صحراء","e19":"ملكي","e20":"فجر",
        "custom":"مخصص"
    ]

    static func current() -> NaqraPalette {
        let raw = ThemeIO.string("themeId") ?? "auto"
        let id = normalizeThemeId(raw)
        if id == "custom" { return solid(customPalette()) }
        if id == "auto" { return solid(preset(TimeTheme.preferredThemeId())) }
        return solid(preset(id))
    }

    static func solid(_ p: NaqraPalette) -> NaqraPalette {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard p.key.getRed(&r, green: &g, blue: &b, alpha: &a) else { return p }
        let amount: CGFloat = p.blurDark ? 0.05 : 0.08
        let background = UIColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: 1)
        return .init(background: background, key: p.key.withAlphaComponent(1), text: p.text, accent: p.accent, blurDark: p.blurDark)
    }

    static func preset(_ id: String) -> NaqraPalette {
        switch id {
        case "dark": return .init(background: .clear, key: UIColor(red: 0.10, green: 0.16, blue: 0.28, alpha: 0.62), text: UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1), accent: UIColor(red: 0.36, green: 0.60, blue: 1.0, alpha: 1), blurDark: true)
        case "light": return .init(background: .clear, key: UIColor(red: 0.90, green: 0.95, blue: 0.99, alpha: 0.82), text: UIColor(red: 0.14, green: 0.27, blue: 0.40, alpha: 1), accent: UIColor(red: 0.28, green: 0.52, blue: 0.86, alpha: 1), blurDark: false)
        case "glass": return .init(background: .clear, key: UIColor(red: 0.86, green: 0.82, blue: 0.96, alpha: 0.38), text: UIColor(red: 0.18, green: 0.16, blue: 0.28, alpha: 1), accent: UIColor(red: 0.62, green: 0.42, blue: 0.88, alpha: 1), blurDark: false)
        case "ocean": return .init(background: .clear, key: UIColor(red: 0.06, green: 0.22, blue: 0.32, alpha: 0.55), text: UIColor(red: 0.62, green: 0.96, blue: 0.98, alpha: 1), accent: UIColor(red: 0.16, green: 0.78, blue: 0.84, alpha: 1), blurDark: true)
        case "cobalt": return .init(background: .clear, key: UIColor(red: 0.10, green: 0.18, blue: 0.42, alpha: 0.62), text: UIColor(red: 0.82, green: 0.90, blue: 1.0, alpha: 1), accent: UIColor(red: 0.32, green: 0.56, blue: 1.0, alpha: 1), blurDark: true)
        case "violet": return .init(background: .clear, key: UIColor(red: 0.18, green: 0.10, blue: 0.32, alpha: 0.50), text: UIColor(red: 0.90, green: 0.78, blue: 1.0, alpha: 1), accent: UIColor(red: 0.70, green: 0.42, blue: 1.0, alpha: 1), blurDark: true)
        case "orchid": return .init(background: .clear, key: UIColor(red: 0.32, green: 0.08, blue: 0.18, alpha: 0.58), text: UIColor(red: 1.0, green: 0.78, blue: 0.86, alpha: 1), accent: UIColor(red: 0.92, green: 0.32, blue: 0.52, alpha: 1), blurDark: true)
        case "hailey": return .init(background: .clear, key: UIColor(red: 0.22, green: 0.05, blue: 0.08, alpha: 0.58), text: UIColor(red: 1.0, green: 0.78, blue: 0.80, alpha: 1), accent: UIColor(red: 0.86, green: 0.16, blue: 0.22, alpha: 1), blurDark: true)
        case "ember": return .init(background: .clear, key: UIColor(red: 0.24, green: 0.12, blue: 0.05, alpha: 0.58), text: UIColor(red: 1.0, green: 0.84, blue: 0.58, alpha: 1), accent: UIColor(red: 0.96, green: 0.50, blue: 0.18, alpha: 1), blurDark: true)
        case "forest": return .init(background: .clear, key: UIColor(red: 0.06, green: 0.18, blue: 0.12, alpha: 0.58), text: UIColor(red: 0.70, green: 0.96, blue: 0.76, alpha: 1), accent: UIColor(red: 0.22, green: 0.78, blue: 0.42, alpha: 1), blurDark: true)
        case "matrix": return .init(background: .clear, key: UIColor(red: 0.02, green: 0.07, blue: 0.03, alpha: 0.62), text: UIColor(red: 0.28, green: 0.98, blue: 0.36, alpha: 1), accent: UIColor(red: 0.12, green: 0.78, blue: 0.22, alpha: 1), blurDark: true)
        case "nord": return .init(background: .clear, key: UIColor(red: 0.78, green: 0.82, blue: 0.86, alpha: 0.72), text: UIColor(red: 0.16, green: 0.20, blue: 0.26, alpha: 1), accent: UIColor(red: 0.36, green: 0.56, blue: 0.70, alpha: 1), blurDark: false)
        case "morning","m1": return Self.tone(0.96, 0.90, 0.78, dark: false)
        case "m2": return Self.tone(0.94, 0.89, 0.72, dark: false)
        case "m3": return Self.tone(0.98, 0.86, 0.76, dark: false)
        case "m4": return Self.tone(0.97, 0.82, 0.64, dark: false)
        case "m5": return Self.tone(0.96, 0.94, 0.88, dark: false)
        case "m6": return Self.tone(0.93, 0.94, 0.96, dark: false)
        case "m7": return Self.tone(0.84, 0.93, 0.88, dark: false)
        case "m8": return Self.tone(0.78, 0.86, 0.76, dark: false)
        case "m9": return Self.tone(0.78, 0.88, 0.96, dark: false)
        case "m10": return Self.tone(0.72, 0.86, 0.90, dark: false)
        case "m11": return Self.tone(0.90, 0.86, 0.96, dark: false)
        case "m12": return Self.tone(0.96, 0.86, 0.90, dark: false)
        case "m13": return Self.tone(0.93, 0.86, 0.68, dark: false)
        case "m14": return Self.tone(0.92, 0.78, 0.52, dark: false)
        case "m15": return Self.tone(0.82, 0.84, 0.68, dark: false)
        case "m16": return Self.tone(0.86, 0.74, 0.62, dark: false)
        case "m17": return Self.tone(0.95, 0.93, 0.89, dark: false)
        case "m18": return Self.tone(0.86, 0.88, 0.90, dark: false)
        case "m19": return Self.tone(0.96, 0.78, 0.74, dark: false)
        case "m20": return Self.tone(0.80, 0.90, 0.78, dark: false)
        case "evening","e2": return Self.tone(0.08, 0.12, 0.24, dark: true, amber: true)
        case "e1": return Self.tone(0.22, 0.23, 0.26, dark: true)
        case "e3": return Self.tone(0.07, 0.09, 0.16, dark: true, amber: true)
        case "e4": return Self.tone(0.10, 0.12, 0.18, dark: true)
        case "e5": return Self.tone(0.18, 0.10, 0.22, dark: true)
        case "e6": return Self.tone(0.24, 0.08, 0.14, dark: true)
        case "e7": return Self.tone(0.08, 0.16, 0.12, dark: true)
        case "e8": return Self.tone(0.06, 0.18, 0.16, dark: true)
        case "e9": return Self.tone(0.06, 0.14, 0.22, dark: true)
        case "e10": return Self.tone(0.10, 0.16, 0.32, dark: true)
        case "e11": return Self.tone(0.22, 0.10, 0.08, dark: true, amber: true)
        case "e12": return Self.tone(0.28, 0.16, 0.10, dark: true, amber: true)
        case "e13": return Self.tone(0.16, 0.10, 0.28, dark: true)
        case "e14": return Self.tone(0.26, 0.08, 0.18, dark: true)
        case "e15": return Self.tone(0.16, 0.18, 0.22, dark: true)
        case "e16": return Self.tone(0.14, 0.14, 0.16, dark: true)
        case "e17": return Self.tone(0.18, 0.12, 0.08, dark: true, amber: true)
        case "e18": return Self.tone(0.20, 0.14, 0.10, dark: true, amber: true)
        case "e19": return Self.tone(0.12, 0.08, 0.20, dark: true)
        case "e20": return Self.tone(0.18, 0.10, 0.12, dark: true, amber: true)
        case "aurora": return Self.tone(0.10, 0.28, 0.30, dark: true)
        case "lavender": return Self.tone(0.28, 0.20, 0.42, dark: true)
        case "sunset": return Self.tone(0.38, 0.14, 0.16, dark: true, amber: true)
        case "mint": return Self.tone(0.08, 0.24, 0.22, dark: true)
        case "rose": return Self.tone(0.36, 0.12, 0.24, dark: true)
        case "mono": return Self.tone(0.22, 0.23, 0.25, dark: true)
        default: return .init(background: .clear, key: UIColor(red: 0.10, green: 0.16, blue: 0.28, alpha: 0.62), text: UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1), accent: UIColor(red: 0.36, green: 0.60, blue: 1.0, alpha: 1), blurDark: true)
        }
    }

    static func tone(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, dark: Bool, amber: Bool = false) -> NaqraPalette {
        let text: UIColor = dark ? (amber ? UIColor(red: 0.96, green: 0.78, blue: 0.42, alpha: 1) : UIColor(white: 0.94, alpha: 1)) : UIColor(red: 0.22, green: 0.16, blue: 0.10, alpha: 1)
        let accent: UIColor = dark ? UIColor(red: 0.82, green: 0.58, blue: 0.22, alpha: 1) : UIColor(red: 0.72, green: 0.48, blue: 0.22, alpha: 1)
        let amount: CGFloat = dark ? 0.05 : 0.08
        let key = UIColor(red: r, green: g, blue: b, alpha: dark ? 0.88 : 0.90)
        let background = UIColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: 1)
        return .init(background: background, key: key, text: text, accent: accent, blurDark: dark)
    }

    static func customPalette() -> NaqraPalette {
        let key = storedColor("customKey") ?? UIColor(white: 1.0, alpha: 0.16)
        let text = storedColor("customText") ?? UIColor(white: 0.96, alpha: 1)
        let accent = storedColor("customAccent") ?? UIColor(red: 0.55, green: 0.62, blue: 0.70, alpha: 1)
        let dark = storedBool("customBlurDark") ?? true
        return .init(background: .clear, key: key, text: text, accent: accent, blurDark: dark)
    }

    static func storedColor(_ key: String) -> UIColor? {
        guard let raw = ThemeIO.string(key) else { return nil }
        let p = raw.split(separator: ",").compactMap { Double($0) }
        guard p.count == 4 else { return nil }
        return UIColor(red: CGFloat(p[0]), green: CGFloat(p[1]), blue: CGFloat(p[2]), alpha: CGFloat(p[3]))
    }

    static func storedBool(_ key: String) -> Bool? { ThemeIO.bool(key) }
    static func saveColor(_ color: UIColor, key: String) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        ThemeIO.write(key, value: "\(r),\(g),\(b),\(a)")
    }
    static func saveTheme(_ id: String) { ThemeIO.write("themeId", value: id) }
    static func normalizeThemeId(_ raw: String) -> String {
        switch raw {
        case "charcoal","smoke","catppuccin_frappe","catppuccin_macchiato": return "dark"
        case "teal": return "ocean"
        case "midnight","midnight_gold","neon_nights","tron","cobalt_night": return "cobalt"
        case "snow","minimal_light","catppuccin_latte": return "light"
        case "clear": return "glass"
        case "matcha": return "m7"
        case "cotton_candy","candy_shop": return "m12"
        case "cherry": return "e5"
        case "cocoa": return "e5"
        case "neon": return "forest"
        case "catppuccin_mocha": return "e2"
        case "dracula": return "violet"
        default: return raw
        }
    }
    static func saveBool(_ value: Bool, key: String) { ThemeIO.write(key, value: value) }
    static func applyHarmony(from base: UIColor) {
        let lum = luminance(base)
        let darkGlass = lum < 0.55
        let text = darkGlass ? UIColor(white: 0.97, alpha: 1) : UIColor(red: 0.16, green: 0.20, blue: 0.26, alpha: 1)
        let accent = relatedAccent(base, dark: darkGlass)
        saveColor(base, key: "customKey")
        saveColor(text, key: "customText")
        saveColor(accent, key: "customAccent")
        saveBool(darkGlass, key: "customBlurDark")
        saveTheme("custom")
    }
    static func luminance(_ color: UIColor) -> CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    static func relatedAccent(_ color: UIColor, dark: Bool) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let ns = min(0.55, max(0.18, s * 0.75))
            let nb = dark ? min(0.86, max(0.55, b + 0.28)) : min(0.62, max(0.38, b * 0.72))
            return UIColor(hue: h, saturation: ns, brightness: nb, alpha: 1)
        }
        return dark ? UIColor(red: 0.55, green: 0.62, blue: 0.70, alpha: 1) : UIColor(red: 0.42, green: 0.58, blue: 0.74, alpha: 1)
    }
}

final class ClipboardHistory {
    static let shared = ClipboardHistory()
    private let key = "clipboardHistory"
    private let max = 20

    var items: [String] {
        guard ThemeIO.bool("clipboardHistoryEnabled") ?? false else { return [] }
        return ThemeIO.string(key)?.split(separator: "\u{1F}").map(String.init) ?? []
    }

    func ensurePrivacyDefault() {
        guard ThemeIO.bool("clipboardHistoryEnabled") == nil else { return }
        ThemeIO.write("clipboardHistoryEnabled", value: false)
        ThemeIO.write(key, value: "")
    }

    func clear() { ThemeIO.write(key, value: "") }

    func add(_ text: String) {
        guard ThemeIO.bool("clipboardHistoryEnabled") ?? false, !text.isEmpty else { return }
        var list = items
        list.removeAll { $0 == text }
        list.insert(text, at: 0)
        if list.count > max { list = Array(list.prefix(max)) }
        ThemeIO.write(key, value: list.joined(separator: "\u{1F}"))
    }
}

final class KeyboardViewController: UIInputViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool { return true }
    private var language: KeyboardLanguage = .arabic
    private var page: KeyboardPage = .letters
    private var isShifted = false
    private var symbolPageIndex = 0
    private var emojiCategoryIndex = 0
    private var palette = NaqraPalette.current()

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let rootStack = UIStackView()
    private var heightConstraint: NSLayoutConstraint?
    private var deleteTimer: Timer?
    private var deleteStartX: CGFloat = 0
    private var lastSpaceTap: Date?
    private let spaceSwitchInterval: TimeInterval = 0.25
    private var spaceStart: CGPoint = .zero
    private var spaceIsTrackpad = false
    private var lastTrackpadX: CGFloat = 0
    private var holdTimer: Timer?
    private var holdPopup: UIView?
    private var holdChoice = ""

    private let translationModel = TranslationBridgeModel()
    private var translationHost: UIHostingController<TranslationBridgeView>?
    private var emojiPager: UIScrollView?
    private var emojiTabs: UIStackView?
    private var suggestionButtons: [UIButton] = []
    private var appliedThemeId = ""
    private var noticeLabel: UILabel?
    private var pendingTranslationText = ""
    private var clipboardLongPressInProgress = false

    private let letterFont = UIFont.systemFont(ofSize: 26, weight: .medium)
    private let iconConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    private let boardHeight: CGFloat = 324
    private var themeSignature: String {
        let id = ThemeIO.string("themeId") ?? "auto"
        return id == "auto" ? "auto-\(TimeTheme.preferredThemeId())" : id
    }

    private let arabicRows = [
        ["ض","ص","ث","ق","ف","غ","ع","ه","خ","ح","ج"],
        ["ش","س","ي","ب","ل","ا","ت","ن","م","ك","ة"],
        ["ئ","ظ","ط","ذ","د","ز","ر","و","ى"]
    ]
    private let arabicShiftRows = [
        ["أ","إ","آ","ى","ء","ؤ","لا","ة","ئ","ؤ","ء"],
        ["أ","إ","آ","ى","ء","ؤ","لا","لآ","لأ","لإ","ة"],
        ["،","؛","؟","٪","…","ـ","ى","ئ"]
    ]
    private let englishLower = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"]
    ]
    private let englishUpper = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["Z","X","C","V","B","N","M"]
    ]
    private let numberRow = ["1","2","3","4","5","6","7","8","9","0"]
    private var showNumberRow: Bool {
        ThemeIO.bool("showNumberRow") ?? true
    }
    private var symbolPages: [[[String]]] { language == .arabic ? arabicSymbolPages : englishSymbolPages }
    private let arabicSymbolPages = [[
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":","؛","(",")","؟","﷼","&","@"],
        [".","،","؟","!","'","«","»","٪","…","•"],
        ["[","]","{","}","#","*","+","=","_","~"],
    ]]
    private let englishSymbolPages = [[
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","$","&","@","\""],
        [".",",","?","!","'","\"","+","=","/","•"],
        ["[","]","{","}","#","*","_","~","^","%"],
    ]]
    private var emojiPack: [(icon: String, items: [String])] = KeyboardViewController.catalog()

    override func viewDidLoad() {
        super.viewDidLoad()
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
        view.clipsToBounds = true
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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeightForCurrentSize()
    }
    private func updateHeightForCurrentSize() {
        guard view.bounds.width > 0 else { return }
        let compact = view.bounds.width < 500
        let desiredHeight: CGFloat
        if page == .emoji { desiredHeight = compact ? 300 : 280 }
        else { desiredHeight = compact ? boardHeight : 270 }
        if heightConstraint == nil {
            let c = view.heightAnchor.constraint(equalToConstant: desiredHeight)
            c.priority = UILayoutPriority(999)
            c.isActive = true
            heightConstraint = c
        } else if abs((heightConstraint?.constant ?? 0) - desiredHeight) > 0.5 {
            heightConstraint?.constant = desiredHeight
        }
    }

    private func persistAccess() { ThemeIO.write("hasFullAccess", value: hasFullAccess) }
    private func loadPrefs() {
        persistAccess()
        if page != .emoji { page = .letters }
        let raw = ThemeIO.string("lastLanguage") ?? "ar"
        language = raw == "en" ? .english : .arabic
    }
    private func saveLanguage() { ThemeIO.write("lastLanguage", value: language == .english ? "en" : "ar") }

    private func listenPrefs() {
        let me = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            CFNotificationCenterGetDarwinNotifyCenter(),
            me,
            { _, observer, _, _, _ in
                guard let observer else { return }
                let vc = Unmanaged<KeyboardViewController>.fromOpaque(observer).takeUnretainedValue()
                DispatchQueue.main.async {
                    vc.appliedThemeId = vc.themeSignature
                    vc.palette = NaqraPalette.current()
                    vc.rebuild()
                }
            },
            "app.personal.PersonalKeyboard.prefs" as CFString,
            nil,
            .deliverImmediately
        )
    }

    private var hapticsOn: Bool {
        (ThemeIO.bool("haptics") ?? true) && ThemeIO.string("hapticLevel") != "none"
    }
    private var trackpadOn: Bool { ThemeIO.bool("trackpad") ?? true }
    private enum Pulse { case key, action, del, move }
    private let selectionFeedback = UISelectionFeedbackGenerator()

    private var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch ThemeIO.string("hapticLevel") ?? "medium" {
        case "light": return .light
        case "strong": return .heavy
        default: return .medium
        }
    }

    private func armHaptics() {
        guard hapticsOn else { return }
        UIImpactFeedbackGenerator(style: impactStyle).prepare()
        selectionFeedback.prepare()
    }

    private func tapHaptic(_ pulse: Pulse = .key) {
        guard hapticsOn else { return }
        if case .move = pulse {
            selectionFeedback.selectionChanged()
            selectionFeedback.prepare()
        } else {
            let feedback = UIImpactFeedbackGenerator(style: impactStyle)
            feedback.impactOccurred()
            feedback.prepare()
        }
    }

    private func playSystemClick(_ sound: TapSoundEngine.Sound = .rowMid) {
        guard enableInputClicksWhenVisible else { return }
        TapSoundEngine.shared.setEnabled(ThemeIO.bool("sounds") ?? true)
        TapSoundEngine.shared.play(sound)
    }

    private func playSystemSound() { playSystemClick(.rowMid) }

    private func showNotice(_ message: String) {
        noticeLabel?.removeFromSuperview()
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.backgroundColor = UIColor.black.withAlphaComponent(0.88)
        label.layer.cornerRadius = 12
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -12),
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -24)
        ])
        label.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        label.isUserInteractionEnabled = false
        noticeLabel = label
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self, weak label] in
            label?.removeFromSuperview()
            if self?.noticeLabel === label { self?.noticeLabel = nil }
        }
    }

    private func lockHeight(_ v: UIView, _ h: CGFloat) {
        v.heightAnchor.constraint(equalToConstant: h).isActive = true
        v.setContentHuggingPriority(.required, for: .vertical)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func configureRoot() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        rootStack.axis = .vertical
        rootStack.spacing = 5
        rootStack.distribution = .fill
        rootStack.alignment = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4)
        ])
        rootStack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        rootStack.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func attachBridge() {
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


    private func loadPreparedTheme() {
        // Theme is prepared by the container app and stored in App Group
        // Keyboard only reads it — keeps extension light
        palette = NaqraPalette.current()
        blurView.effect = UIBlurEffect(style: palette.blurDark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
        view.backgroundColor = palette.background
    }

private func rebuild() {
        palette = NaqraPalette.current()
        view.backgroundColor = palette.background
        blurView.effect = nil
        blurView.backgroundColor = palette.background
        rootStack.arrangedSubviews.forEach { rootStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        let h: CGFloat = page == .letters ? boardHeight : 300
        heightConstraint?.constant = h
        switch page {
        case .letters:
            rootStack.addArrangedSubview(makeToolbar())
            if showNumberRow {
                rootStack.addArrangedSubview(makeRow(numberRow, rowIdx: 0))
            }
            let rows = language == .arabic
                ? (isShifted ? arabicShiftRows : arabicRows)
                : (isShifted ? englishUpper : englishLower)
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 { rootStack.addArrangedSubview(makeLastLetterRow(row)) }
                else { rootStack.addArrangedSubview(makeRow(row, rowIdx: i + 1)) }
            }
            rootStack.addArrangedSubview(makeBottom())
        case .symbols:
            let rowsCount: Int = {
                if let str = ThemeIO.string("symbolRows"), let n = Int(str) { return max(1, min(n, 4)) }
                let n = UserDefaults(suiteName: ThemeIO.group)?.integer(forKey: "symbolRows") ?? 0
                return n > 0 ? max(1, min(n, 4)) : 3
            }()
            let pages = symbolPages
            let pageIdx = min(max(symbolPageIndex, 0), max(pages.count - 1, 0))
            let allRows = pages.isEmpty ? [] : pages[pageIdx]
            let rows = Array(allRows.prefix(rowsCount))
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 { rootStack.addArrangedSubview(makeSymbolLastRow(row)) }
                else { rootStack.addArrangedSubview(makeRow(row, rowIdx: i + 1)) }
            }
            rootStack.addArrangedSubview(makeBottom())
        case .emoji:
            rootStack.addArrangedSubview(makeEmojiTabs())
            rootStack.addArrangedSubview(makeEmojiPager())
            rootStack.addArrangedSubview(makeBottom(emojiOn: true))
        }
    }

    private func makeToolbar() -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.distribution = .fill
        s.semanticContentAttribute = .forceLeftToRight
        let clip = iconKey("doc.on.clipboard", #selector(copyPasteTapped))
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(copyPasteHold(_:)))
        holdGesture.minimumPressDuration = 0.38
        holdGesture.cancelsTouchesInView = true
        clip.addGestureRecognizer(holdGesture)
        clip.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(clip)

        // Suggestions in the middle of the toolbar
        let showSuggestions = ThemeIO.bool("suggestions") ?? true
        if showSuggestions {
            let sugg = suggestions()
            if !sugg.allSatisfy({ $0.isEmpty }) {
                let suggRow = makeSuggestionsRow()
                suggRow.setContentHuggingPriority(.defaultLow, for: .horizontal)
                s.addArrangedSubview(suggRow)
            } else {
                let spacer = UIView()
                s.addArrangedSubview(spacer)
            }
        } else {
            let spacer = UIView()
            s.addArrangedSubview(spacer)
        }

        let tr = iconKey("translate", #selector(translateTapped))
        tr.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(tr)
        let hide = iconKey("keyboard.chevron.compact.down", #selector(dismissKeyboardAction))
        hide.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(hide)
        s.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return s
    }

    private func makeSuggestionsRow() -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        s.semanticContentAttribute = .forceLeftToRight
        suggestionButtons = []
        for (i, word) in suggestions().enumerated() {
            let b = UIButton(type: .system)
            b.tag = i
            b.setTitle(word, for: .normal)
            b.isEnabled = !word.isEmpty
            b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            b.titleLabel?.adjustsFontSizeToFitWidth = true
            b.titleLabel?.minimumScaleFactor = 0.7
            b.setTitleColor(palette.text, for: .normal)
            b.backgroundColor = palette.key.withAlphaComponent(word.isEmpty ? 0.35 : 1)
            b.layer.cornerRadius = 10 // Radius.key
            b.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionButtons.append(b)
            s.addArrangedSubview(b)
        }
        lockHeight(s, 34)
        return s
    }

    private func suggestions() -> [String] {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = before.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" }).last.map(String.init) ?? ""
        if token.count < 1 { return ["", "", ""] }
        let code = language == .english ? "en_US" : "ar"
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: token.utf16.count)
        let completions = checker.completions(forPartialWordRange: range, in: token, language: code) ?? []
        let guesses = checker.guesses(forWordRange: range, in: token, language: code) ?? []
        var out: [String] = []
        for w in (completions + guesses) where !out.contains(w) && w.caseInsensitiveCompare(token) != .orderedSame {
            out.append(w)
            if out.count == 3 { break }
        }
        if language == .arabic {
            let folded = Self.fold(token)
            for w in Self.arabicLexicon {
                if out.count == 3 { break }
                if Self.fold(w).hasPrefix(folded) && Self.fold(w) != folded && !out.contains(w) {
                    out.append(w)
                }
            }
        }
        while out.count < 3 { out.append("") }
        return out
    }

    private func refreshSuggestions() {
        let words = suggestions()
        guard suggestionButtons.count == words.count else { return }
        for (button, word) in zip(suggestionButtons, words) {
            button.setTitle(word, for: .normal)
            button.isEnabled = !word.isEmpty
            button.backgroundColor = word.isEmpty ? .clear : palette.key
        }
    }

    private static func fold(_ s: String) -> String {
        let map: [Character: Character] = ["أ":"ا","إ":"ا","آ":"ا","ى":"ي","ة":"ه","ؤ":"و","ئ":"ي","ٱ":"ا"]
        return String(s.lowercased().map { map[$0] ?? $0 })
    }

    private static let arabicLexicon = [
        "السلام","عليكم","ورحمة","الله","صباح","الخير","مساء","كيف","حالك",
        "الحمد","شكرا","عفوا","نعم","لا","ممكن","أريد","اليوم",
        "غدا","الآن","هنا","هناك","هذا","هذه","ذلك","التي","الذي","كان",
        "تكون","يكون","بعد","قبل","حتى","عند","بين","كل","بعض","جدا",
        "مرحبا","أهلا","وسهلا","تمام","زين","طيب","يعني","لكن","أيضا",
        "اليمن","صنعاء","كتاب","كتابة","كتب","مدرسة","جامعة","عمل",
        "كيفك","يا","أخي","أختي","وين","متى","ليش","عشان","بكرة","أمس",
        "البيت","الشغل","السيارة","الجوال","ماء","أكل","شرب","نوم","صحة",
        "أحب","أبغى","أقدر","ما","في","هذي","ذلك","سلام","آسف","موافق","الحين"
    ]

    @objc private func suggestionTapped(_ sender: UIButton) {
        guard let word = sender.title(for: .normal), !word.isEmpty else { return }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = before.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" }).last.map(String.init) ?? ""
        if !token.isEmpty { for _ in 0..<token.count { textDocumentProxy.deleteBackward() } }
        textDocumentProxy.insertText(word)
        playSystemSound()
        tapHaptic()
    }

    private func makeRow(_ keys: [String], rowIdx: Int) -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.distribution = .fillEqually
        s.heightAnchor.constraint(equalToConstant: 44).isActive = true
        s.distribution = .fillEqually
        s.semanticContentAttribute = rowIdx == 0
            ? .forceLeftToRight
            : (language == .arabic ? .forceRightToLeft : .forceLeftToRight)
        keys.forEach { s.addArrangedSubview(charKey($0, rowIdx: rowIdx)) }
        lockHeight(s, 44)
        return s
    }

    private func makeLastLetterRow(_ keys: [String]) -> UIView {
        return makeActionRow(keys, leadingShift: true)
    }

    private func makeSymbolLastRow(_ keys: [String]) -> UIView {
        return makeActionRow(keys, leadingShift: false)
    }

    private func makeActionRow(_ keys: [String], leadingShift: Bool) -> UIView {
        let wrap = UIStackView()
        wrap.axis = .horizontal
        wrap.spacing = 6
        wrap.semanticContentAttribute = .forceLeftToRight
        if leadingShift {
            let shift = iconKey(isShifted ? "shift.fill" : "shift", #selector(shiftTapped))
            shift.widthAnchor.constraint(equalToConstant: 40).isActive = true
            paint(shift, emphasized: isShifted)
            wrap.addArrangedSubview(shift)
        }
        let mid = UIStackView()
        mid.axis = .horizontal
        mid.spacing = 6
        mid.distribution = .fillEqually
        mid.semanticContentAttribute = language == .arabic ? .forceRightToLeft : .forceLeftToRight
        keys.forEach { mid.addArrangedSubview(charKey($0, rowIdx: 2)) }
        wrap.addArrangedSubview(mid)
        wrap.addArrangedSubview(makeDeleteKey())
        lockHeight(wrap, 44)
        return wrap
    }

    private func makeDeleteKey() -> UIButton {
        let del = iconKey("delete.left", #selector(deleteTouchUp))
        del.addTarget(self, action: #selector(deleteTouchDown), for: .touchDown)
        del.addTarget(self, action: #selector(deleteTouchCancel), for: [.touchUpOutside, .touchCancel])
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragInside)
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragOutside)
        del.widthAnchor.constraint(equalToConstant: 54).isActive = true
        return del
    }

    private func makeBottom(emojiOn: Bool = false) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = .fill
        row.alignment = .fill
        row.semanticContentAttribute = .forceLeftToRight

        let symbolsTitle = page == .symbols ? "ABC" : (page == .emoji ? "رجوع" : "123")
        let symbols = control(symbolsTitle, #selector(symbolsOrLettersTapped), font: 12)
        symbols.widthAnchor.constraint(equalToConstant: 42).isActive = true


        let emoji = UIButton(type: .system)
        emoji.setTitle("😊", for: .normal)
        emoji.titleLabel?.font = .systemFont(ofSize: 19)
        paint(emoji)
        emoji.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)
        emoji.widthAnchor.constraint(equalToConstant: 32).isActive = true
        emoji.accessibilityLabel = "لوحة الرموز التعبيرية"

        let space = control("", #selector(spaceTouchUp), font: 14)
        space.addTarget(self, action: #selector(spaceTouchDown(_:event:)), for: .touchDown)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragInside)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragOutside)
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        space.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let minimumSpace = space.widthAnchor.constraint(greaterThanOrEqualToConstant: 74)
        minimumSpace.priority = UILayoutPriority(999)
        minimumSpace.isActive = true
        space.accessibilityLabel = "مسافة"

        let enter = iconKey("arrow.down.to.line", #selector(enterTapped))
        enter.widthAnchor.constraint(equalToConstant: 42).isActive = true
        enter.accessibilityLabel = "إدخال سطر جديد"

        row.addArrangedSubview(symbols)
        row.addArrangedSubview(emoji)
        row.addArrangedSubview(space)
        if emojiOn {
            row.addArrangedSubview(makeDeleteKey())
        } else {
            let period = control(".", #selector(periodTapped), font: 18)
            period.widthAnchor.constraint(equalToConstant: 32).isActive = true
            row.addArrangedSubview(period)
        }
        row.addArrangedSubview(enter)
        lockHeight(row, 44)
        return row
    }


    private func makeEmojiTabs() -> UIView {
        let wrap = UIStackView()
        wrap.axis = .horizontal
        wrap.spacing = 6
        wrap.semanticContentAttribute = .forceLeftToRight
        let scroller = UIScrollView()
        scroller.showsHorizontalScrollIndicator = false
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.translatesAutoresizingMaskIntoConstraints = false
        scroller.addSubview(s)
        emojiTabs = s
        for (i, pack) in emojiPack.enumerated() {
            let b = control(pack.icon, #selector(emojiTab(_:)), font: 18)
            b.tag = i
            b.backgroundColor = i == emojiCategoryIndex ? UIColor.white.withAlphaComponent(0.22) : .clear
            b.widthAnchor.constraint(equalToConstant: 38).isActive = true
            s.addArrangedSubview(b)
        }
        NSLayoutConstraint.activate([
            s.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor, constant: 2),
            s.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor, constant: -2),
            s.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            s.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor),
            s.heightAnchor.constraint(equalTo: scroller.frameLayoutGuide.heightAnchor)
        ])
        wrap.addArrangedSubview(scroller)
        lockHeight(wrap, 32)
        return wrap
    }

    private func makeEmojiPager() -> UIView {
        let pager = UIScrollView()
        pager.isPagingEnabled = true
        pager.showsHorizontalScrollIndicator = false
        pager.delegate = self
        pager.translatesAutoresizingMaskIntoConstraints = false
        emojiPager = pager
        lockHeight(pager, 180)
        let host = UIView()
        host.translatesAutoresizingMaskIntoConstraints = false
        pager.addSubview(host)
        NSLayoutConstraint.activate([
            host.topAnchor.constraint(equalTo: pager.contentLayoutGuide.topAnchor),
            host.bottomAnchor.constraint(equalTo: pager.contentLayoutGuide.bottomAnchor),
            host.leadingAnchor.constraint(equalTo: pager.contentLayoutGuide.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: pager.contentLayoutGuide.trailingAnchor),
            host.heightAnchor.constraint(equalTo: pager.frameLayoutGuide.heightAnchor)
        ])
        var previous: UIView?
        for i in 0..<emojiPack.count {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .clear
            cv.dataSource = self
            cv.delegate = self
            cv.tag = i
            cv.register(EmojiCell.self, forCellWithReuseIdentifier: "e")
            cv.translatesAutoresizingMaskIntoConstraints = false
            host.addSubview(cv)
            NSLayoutConstraint.activate([
                cv.topAnchor.constraint(equalTo: host.topAnchor),
                cv.bottomAnchor.constraint(equalTo: host.bottomAnchor),
                cv.widthAnchor.constraint(equalTo: pager.frameLayoutGuide.widthAnchor),
                cv.heightAnchor.constraint(equalTo: host.heightAnchor)
            ])
            if let previous { cv.leadingAnchor.constraint(equalTo: previous.trailingAnchor).isActive = true }
            else { cv.leadingAnchor.constraint(equalTo: host.leadingAnchor).isActive = true }
            if i == emojiPack.count - 1 { cv.trailingAnchor.constraint(equalTo: host.trailingAnchor).isActive = true }
            previous = cv
        }
        return pager
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === emojiPager, scrollView.bounds.width > 0 else { return }
        let idx = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        emojiCategoryIndex = min(max(idx, 0), emojiPack.count - 1)
        refreshTabs()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojiPack[collectionView.tag].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "e", for: indexPath) as! EmojiCell
        cell.label.text = emojiPack[collectionView.tag].items[indexPath.item]
        cell.paint(palette)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = emojiPack[collectionView.tag].items[indexPath.item]
        textDocumentProxy.insertText(item)
        playSystemClick(.emoji)
        rememberEmoji(item)
        emojiPack = Self.catalog()
        collectionView.reloadData()
        tapHaptic()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = floor(collectionView.bounds.width / 8)
        return CGSize(width: max(w, 32), height: 32)
    }

    private func refreshTabs() {
        guard let tabs = emojiTabs else { return }
        for (i, view) in tabs.arrangedSubviews.enumerated() {
            view.backgroundColor = i == emojiCategoryIndex ? UIColor.white.withAlphaComponent(0.22) : .clear
        }
    }

    @objc private func emojiTab(_ sender: UIButton) {
        emojiCategoryIndex = sender.tag
        refreshTabs()
        guard let pager = emojiPager else { return }
        pager.setContentOffset(CGPoint(x: CGFloat(sender.tag) * pager.bounds.width, y: 0), animated: true)
    }

    private func paint(_ b: UIButton, emphasized: Bool = false) {
        b.backgroundColor = emphasized ? palette.accent.withAlphaComponent(0.72) : palette.key
        b.setTitleColor(emphasized ? .white : palette.text, for: .normal)
        b.tintColor = emphasized ? .white : palette.text
        b.layer.cornerRadius = 10 // Radius.key
        b.layer.cornerCurve = .continuous
        b.layer.borderWidth = 0.6
        let line = palette.blurDark ? UIColor.white.withAlphaComponent(0.20) : UIColor.black.withAlphaComponent(0.10)
        b.layer.borderColor = line.cgColor
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.08
        b.layer.shadowRadius = 1
        b.layer.shadowOffset = CGSize(width: 0, height: 1)
        b.clipsToBounds = false
    }

    private let holdMap: [String: [String]] = [
        "ا": ["أ", "إ", "آ", "ء"],
        "و": ["ؤ"],
        "ي": ["ئ", "ى"],
        "ى": ["ئ", "ي"],
        "ه": ["ة"],
        "ل": ["لا", "لأ", "لإ", "لآ"],
        "ة": ["ه"],
        "ئ": ["ء", "ي"],
        "أ": ["إ", "آ", "ا"],
        "ؤ": ["و", "ء"],
        ".": ["َ", "ُ", "ِ", "ْ", "ّ", "ً", "ٌ", "ٍ", "…"],
        ",": ["،"],
        ";": ["؛"],
        "?": ["؟"],
        "!": ["!"],
        "-": ["–", "—"]
    ]

    private func alts(for key: String) -> [String] {
        if key == "\"" { return ["«", "»"] }
        return holdMap[key] ?? []
    }

    private func charKey(_ t: String, rowIdx: Int) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(t, for: .normal)
        b.titleLabel?.font = letterFont
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.7
        paint(b)
        b.tag = rowIdx
        b.addTarget(self, action: #selector(charDown(_:)), for: .touchDown)
        b.addTarget(self, action: #selector(charDrag(_:event:)), for: .touchDragInside)
        b.addTarget(self, action: #selector(charDrag(_:event:)), for: .touchDragOutside)
        b.addTarget(self, action: #selector(charUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return b
    }

    private func control(_ t: String, _ a: Selector, font: CGFloat) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(t, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: font, weight: .semibold)
        paint(b)
        b.addTarget(self, action: a, for: .touchUpInside)
        return b
    }

    private func iconKey(_ name: String, _ a: Selector) -> UIButton {
        let b = UIButton(type: .system)
        let symbol = UIImage(systemName: name, withConfiguration: iconConfig)
            ?? UIImage(systemName: fallbackSymbol(name), withConfiguration: iconConfig)
        b.setImage(symbol, for: .normal)
        paint(b, emphasized: name.contains("shift.fill") && isShifted)
        b.addTarget(self, action: a, for: .touchUpInside)
        return b
    }

    private func fallbackSymbol(_ name: String) -> String {
        switch name {
        case "translate": return "globe"
        case "doc.on.clipboard": return "doc.on.doc"
        case "arrow.down.to.line": return "arrow.down"
        default: return "circle"
        }
    }

    @objc private func charDown(_ sender: UIButton) {
        holdChoice = sender.title(for: .normal) ?? ""
        holdTimer?.invalidate()
        hideHoldPopup()
        guard let key = sender.title(for: .normal), !alts(for: key).isEmpty else { return }
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.38, repeats: false) { [weak self] _ in
            self?.showHoldPopup(from: sender)
        }
    }

    @objc private func charDrag(_ sender: UIButton, event: UIEvent) {
        guard let popup = holdPopup, let touch = event.allTouches?.first else { return }
        let p = touch.location(in: popup)
        for v in popup.subviews {
            guard let b = v as? UIButton else { continue }
            let inside = b.frame.insetBy(dx: -4, dy: -10).contains(p)
            b.backgroundColor = inside ? UIColor.white.withAlphaComponent(0.28) : .clear
            if inside { holdChoice = b.title(for: .normal) ?? holdChoice }
        }
    }

    @objc private func charUp(_ sender: UIButton) {
        holdTimer?.invalidate()
        holdTimer = nil
        let text = holdPopup != nil ? holdChoice : (sender.title(for: .normal) ?? "")
        hideHoldPopup()
        guard !text.isEmpty else { return }
        textDocumentProxy.insertText(text)
        let row = sender.tag
        switch row {
        case 0: playSystemSound()
        case 1: playSystemSound()
        default: playSystemSound()
        }
        tapHaptic()
        if page == .letters, language == .english, isShifted {
            isShifted = false
            rebuild()
        }
    }

    private func showHoldPopup(from button: UIButton) {
        guard let key = button.title(for: .normal) else { return }
        let items = alts(for: key)
        guard !items.isEmpty else { return }
        hideHoldPopup()
        let bar = UIStackView()
        bar.axis = .horizontal
        bar.spacing = 4
        bar.alignment = .center
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.black.withAlphaComponent(0.82)
        bar.layer.cornerRadius = 10
        bar.layer.cornerCurve = .continuous
        bar.isLayoutMarginsRelativeArrangement = true
        bar.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        holdChoice = items[0]
        for (i, item) in items.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(item, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
            b.setTitleColor(.white, for: .normal)
            b.backgroundColor = i == 0 ? UIColor.white.withAlphaComponent(0.28) : .clear
            b.layer.cornerRadius = 10 // Radius.key
            var config = UIButton.Configuration.plain(); config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8); b.configuration = config
            bar.addArrangedSubview(b)
        }
        view.addSubview(bar)
        let frame = button.convert(button.bounds, to: view)
        NSLayoutConstraint.activate([
            bar.bottomAnchor.constraint(equalTo: view.topAnchor, constant: max(frame.minY - 6, 50)),
            bar.heightAnchor.constraint(equalToConstant: 44)
        ])
        let center = bar.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: frame.midX)
        center.priority = .defaultHigh
        center.isActive = true
        bar.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 6).isActive = true
        bar.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -6).isActive = true
        holdPopup = bar
        tapHaptic()
    }

    private func hideHoldPopup() {
        holdPopup?.removeFromSuperview()
        holdPopup = nil
    }

    @objc private func shiftTapped() {
        isShifted.toggle()
        rebuild()
        tapHaptic(.action)
    }

    @objc private func deleteTouchDown() {
        textDocumentProxy.deleteBackward()
        playSystemClick(.delete)
        tapHaptic(.del)
        deleteTimer?.invalidate()
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            self?.deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
            }
        }
    }

    @objc private func deleteTouchUp() {
        deleteTimer?.invalidate()
        deleteTimer = nil
        deleteStartX = 0
    }

    @objc private func deleteDrag(_ sender: UIButton, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        let x = touch.location(in: sender).x
        if deleteStartX == 0 { deleteStartX = x }
        if deleteStartX - x > 28 {
            deleteStartX = x
            let before = textDocumentProxy.documentContextBeforeInput ?? ""
            let token = String(before.split { $0 == " " || $0 == "\n" }.last ?? "")
            let n = max(token.count + 1, 1)
            for _ in 0..<n { textDocumentProxy.deleteBackward() }
        }
    }

    @objc private func deleteTouchCancel() {
        deleteTimer?.invalidate()
        deleteTimer = nil
        deleteStartX = 0
    }

    @objc private func spaceTouchDown(_ sender: UIButton, event: UIEvent) {
        spaceIsTrackpad = false
        if let t = event.allTouches?.first {
            spaceStart = t.location(in: view)
            lastTrackpadX = spaceStart.x
        }
    }

    @objc private func spaceDrag(_ sender: UIButton, event: UIEvent) {
        guard trackpadOn, let t = event.allTouches?.first else { return }
        let p = t.location(in: view)
        if abs(p.x - spaceStart.x) > 10 { spaceIsTrackpad = true }
        guard spaceIsTrackpad else { return }
        let delta = p.x - lastTrackpadX
        if abs(delta) >= 8 {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: delta > 0 ? 1 : -1)
            lastTrackpadX = p.x
            tapHaptic(.move)
        }
    }

    private func knownWord(_ token: String) -> Bool {
        if language == .english {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: token.utf16.count)
            let miss = checker.rangeOfMisspelledWord(in: token, range: range, startingAt: 0, wrap: false, language: "en_US")
            return miss.location == NSNotFound
        }
        let folded = Self.fold(token)
        return Self.arabicLexicon.contains { Self.fold($0) == folded }
    }

    private func autocorrectOnSpace() {
        guard ThemeIO.bool("autocorrect") ?? true else { return }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = before.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" }).last.map(String.init) ?? ""
        guard token.count >= 2 else { return }
        let fix: String?
        if language == .english {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: token.utf16.count)
            let misspelling = checker.rangeOfMisspelledWord(in: token, range: range, startingAt: 0, wrap: false, language: "en_US")
            fix = misspelling.location != NSNotFound ? checker.guesses(forWordRange: range, in: token, language: "en_US")?.first : nil
        } else {
            let arabicFixes = ["هاذا": "هذا", "هاذه": "هذه", "هاذ": "هذا", "الذيي": "الذي", "اللذي": "الذي", "انشاءالله": "إن شاء الله", "شكراا": "شكرًا", "مساءا": "مساءً"]
            fix = arabicFixes[token]
        }
        guard let fix, fix.caseInsensitiveCompare(token) != .orderedSame else { return }
        for _ in 0..<token.count { textDocumentProxy.deleteBackward() }
        textDocumentProxy.insertText(fix)
        tapHaptic(.action)
        refreshSuggestions()
    }
    @objc private func spaceTouchUp() {
        if spaceIsTrackpad { spaceIsTrackpad = false; return }
        let now = Date()
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let isAfterSpace = before.hasSuffix(" ")
        if isAfterSpace, let last = lastSpaceTap, now.timeIntervalSince(last) <= spaceSwitchInterval {
            lastSpaceTap = nil
            language = language == .arabic ? .english : .arabic
            isShifted = false
            symbolPageIndex = 0
            saveLanguage()
            if page != .emoji { page = .letters }
            rebuild()
            tapHaptic()
            return
        }
        lastSpaceTap = now
        autocorrectOnSpace()
        textDocumentProxy.insertText(" ")
        playSystemClick(.space)
        tapHaptic()
    }


    @objc private func periodTapped() {
        textDocumentProxy.insertText(".")
        tapHaptic(.action)
    }

    @objc private func enterTapped() {
        textDocumentProxy.insertText("\n")
        playSystemClick(.enter)
        tapHaptic(.action)
    }

    @objc private func emojiTapped() {
        page = (page == .emoji) ? .letters : .emoji
        rebuild()
        tapHaptic()
    }

    @objc private func symbolsOrLettersTapped() {
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

    @objc private func copyPasteTapped() {
        guard !clipboardLongPressInProgress else { return }
        copyNow()
    }

    @objc private func copyPasteHold(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            clipboardLongPressInProgress = true
            guard hasFullAccess else {
                showNotice("لصق الحافظة يحتاج تفعيل الوصول الكامل للوحة")
                return
            }
            let items = ClipboardHistory.shared.items
            guard !items.isEmpty else {
                pasteNow()
                return
            }
            let sheet = UIAlertController(title: "الحافظة المحفوظة", message: "تُخزّن محليًا على هذا الجهاز", preferredStyle: .actionSheet)
            for item in items.prefix(8) {
                let title = item.count > 40 ? String(item.prefix(40)) + "…" : item
                sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                    self?.textDocumentProxy.insertText(item)
                })
            }
            sheet.addAction(UIAlertAction(title: "مسح السجل", style: .destructive) { _ in
                ClipboardHistory.shared.clear()
            })
            sheet.addAction(UIAlertAction(title: "إلغاء", style: .cancel))
            if let pop = sheet.popoverPresentationController {
                pop.sourceView = view
                pop.sourceRect = CGRect(x: view.bounds.midX, y: 40, width: 1, height: 1)
            }
            present(sheet, animated: true)
        case .ended, .cancelled, .failed:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.clipboardLongPressInProgress = false
            }
        default:
            break
        }
    }

    private func copyNow() {
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
        tapHaptic()
    }

    private func pasteNow() {
        guard hasFullAccess else {
            showNotice("اللصق يحتاج تفعيل الوصول الكامل للوحة")
            return
        }
        persistAccess()
        if let text = UIPasteboard.general.string, !text.isEmpty {
            textDocumentProxy.insertText(text)
            tapHaptic()
        } else {
            showNotice("الحافظة فارغة")
        }
    }

    @objc private func translateTapped() {
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
        pendingTranslationText = text
        let arabicCount = text.unicodeScalars.filter { $0.value >= 0x0600 && $0.value <= 0x06FF }.count
        let translateToEnglish = arabicCount >= max(1, text.count / 4)
        translationModel.sourceLang = translateToEnglish ? "ar" : "en"
        translationModel.targetLang = translateToEnglish ? "en" : "ar"
        translationModel.sourceText = text
        translationModel.token += 1
    }

    private func applyTranslation(_ text: String) {
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
        tapHaptic(.action)
    }

    @objc private func dismissKeyboardAction() { dismissKeyboard() }

    private static func loadFrequent() -> [String] {
        let raw = ThemeIO.string("frequentEmoji") ?? "😀 😂 ❤️ 😍 🔥 👍 🙏 😊 ✨ 😭 👏 💕 🌹 🇾🇪 🎉 😎 🤔 😅 😁 😘 💪 ✌️ 💯 💙"
        return raw.split(separator: " ").map(String.init)
    }

    private func rememberEmoji(_ item: String) {
        var items = (ThemeIO.string("frequentEmoji") ?? "").split(separator: " ").map(String.init)
        items.removeAll { $0 == item }
        items.insert(item, at: 0)
        ThemeIO.write("frequentEmoji", value: items.prefix(32).joined(separator: " "))
    }

    private static func catalog() -> [(icon: String, items: [String])] {
        func s(_ t: String) -> [String] { t.split(separator: " ").map(String.init) }
        func merge(_ first: [String], _ second: [String]) -> [String] {
            var seen = Set<String>()
            return (first + second).filter { seen.insert($0).inserted }
        }
        return [
            ("😀", merge(Array(loadFrequent().prefix(24)), s("😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 😉 😌 😍 🥰 😘 😗 😙 😚 😋 😛 😝 😜 🤪 🤨 🧐 🤓 😎 🤩 🥳 😏 😒 😞 😔 😟 😕 🙁 ☹️ 😣 😖 😫 😩 🥺 😢 😭 😤 😠 😡 🤬 🤯 😳 🥵 🥶 😱 😨 😰 😥 😓 🤗 🤔 🤭 🤫 🤥 😶 😐 😑 🫠 🫡 🫢 🫣 🫤 🥹 🥲 😵‍💫 😬 🙄 😯 😦 😧 😮 😲 🥱 😴 🤤 😪 😵 🤐 🥴 🤢 🤮 🤧 😷 🤒 🤕 🤑 🤠 😈 👿 🤡 👻 💀 👽 🤖 🎃 😺 😸 😹 😻 😼 😽 🙀 😿 😾")),
            ("👋", s("👋 🤚 🖐️ ✋ 🖖 🫱 🫲 🫳 🫴 👌 🤌 🤏 ✌️ 🤞 🫰 🤟 🤘 🤙 👈 👉 👆 🖕 👇 ☝️ 🫵 👍 👎 ✊ 👊 🤛 🤜 👏 🙌 🫶 👐 🤲 🤝 🙏 ✍️ 💅 🤳 💪 🦾 🦿 🦵 🦶 👂 🦻 👃 🧠 🫀 🫁 🦷 🦴 👀 👁️ 👅 👄 🫦 👶 🧒 👦 👧 🧑 👱 👨 🧔 👩 🧓 👴 👵 🙍 🙎 🙅 🙆 💁 🙋 🧏 🙇 🤦 🤷 👮 🕵️ 💂 🥷 👷 🫅 🤴 👸 👳 👲 🧕 🤵 👰 🤰 🤱 👼 🎅 🤶 🧑‍🎄 🦸 🦹 🧙 🧚 🧛 🧜 🧝 🧞 🧟 💆 💇 🚶 🧍 🧎 🏃 💃 🕺 🕴️ 👯 🧖 🧗 🤺 🏇 ⛷️ 🏂 🏌️ 🏄 🏊 🤽 🚣 🧘 🛀 🛌 👭 👫 👬 💏 💑 👪")),
            ("❤️", s("❤️ 🧡 💛 💚 💙 💜 🖤 🤍 🤎 💔 ❤️‍🩹 ❣️ 💕 💞 💓 💗 💖 💘 💝 💟 🩷 🩵 🩶 ♥️ ♦️ ♣️ ♠️ 🃏 🎴 💯 💢 💥 💫 💦 💨 💬 💭 🗯️ 💤 ⭐ 🌟 ✨ ⚡ ☄️ 🔥 🌪️ 🌈 ☀️ 🌤️ ⛅ 🌥️ ☁️ 🌦️ 🌧️ ⛈️ 🌩️ 🌨️ ❄️ ☃️ ⛄ 🌬️ 💧 💦 ☔ ☂️ 🌊 🌫️")),
            ("🐻", s("🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐻‍❄️ 🐨 🐯 🦁 🐮 🐷 🐽 🐸 🐵 🙈 🙉 🙊 🐒 🐔 🐧 🐦 🐤 🐣 🐥 🦆 🦅 🦉 🦇 🐺 🐗 🐴 🦄 🐝 🪱 🐛 🦋 🐌 🐞 🐜 🪰 🪲 🪳 🦟 🦗 🕷️ 🕸️ 🦂 🐢 🐍 🦎 🦖 🦕 🐙 🦑 🦐 🦞 🦀 🐡 🐠 🐟 🐬 🐳 🐋 🦈 🐊 🐅 🐆 🦓 🦍 🦧 🐘 🦛 🦏 🐪 🐫 🦒 🦘 🦬 🐃 🐂 🐄 🐎 🐖 🐏 🐑 🦙 🐐 🦌 🐕 🐩 🦮 🐕‍🦺 🐈 🐈‍⬛ 🪶 🐓 🦃 🦤 🦚 🦜 🦢 🦩 🕊️ 🐇 🦝 🦨 🦡 🦫 🦦 🦥 🐁 🐀 🐿️ 🦔 🌵 🎄 🌲 🌳 🌴 🪴 🌱 🌿 ☘️ 🍀 🎍 🍃 🍂 🍁 🍄 🐚 🪨 🌾 💐 🌷 🌹 🥀 🌺 🌸 🌼 🌻")),
            ("🍔", s("🍏 🍎 🍐 🍊 🍋 🍌 🍉 🍇 🍓 🫐 🍈 🍒 🍑 🥭 🍍 🥥 🥝 🍅 🍆 🥑 🥦 🥬 🥒 🌶️ 🫑 🌽 🥕 🫒 🧄 🧅 🥔 🍠 🥐 🥯 🍞 🥖 🥨 🧀 🥚 🍳 🧈 🥞 🧇 🥓 🥩 🍗 🍖 🦴 🌭 🍔 🍟 🍕 🫓 🥪 🥙 🧆 🌮 🌯 🫔 🥗 🥘 🫕 🥫 🍝 🍜 🍲 🍛 🍣 🍱 🥟 🦪 🍤 🍙 🍚 🍘 🍥 🥠 🥮 🍢 🍡 🍧 🍨 🍦 🥧 🧁 🍰 🎂 🍮 🍭 🍬 🍫 🍿 🍩 🍪 🌰 🥜 🍯 🥛 🍼 🫖 ☕ 🍵 🧃 🥤 🧋 🍶 🍺 🍻 🥂 🍷 🥃 🍸 🍹 🧉 🍾 🧊 🥄 🍴 🍽️ 🥢 🧂")),
            ("✈️", s("🚗 🚕 🚙 🚌 🚎 🏎️ 🚓 🚑 🚒 🚐 🛻 🚚 🚛 🚜 🛴 🚲 🛵 🏍️ 🛺 🚨 🚔 🚍 🚘 🚖 🚡 🚠 🚟 🚃 🚋 🚞 🚝 🚄 🚅 🚈 🚂 🚆 🚇 🚊 🚉 ✈️ 🛫 🛬 🛩️ 💺 🛰️ 🚀 🛸 🚁 🛶 ⛵ 🚤 🛥️ 🛳️ ⛴️ 🚢 ⚓ ⛽ 🚧 🚦 🚥 🚏 🗺️ 🗿 🗽 🗼 🏰 🏯 🏟️ 🎡 🎢 🎠 ⛲ ⛱️ 🏖️ 🏝️ 🏜️ 🌋 ⛰️ 🏔️ 🗻 🏕️ ⛺ 🏠 🏡 🏘️ 🏚️ 🏗️ 🏭 🏢 🏬 🏣 🏤 🏥 🏦 🏨 🏪 🏫 🏩 💒 🏛️ ⛪ 🕌 🕍 🛕 🕋 ⛩️ 🛤️ 🛣️ 🗾 🎑 🏞️ 🌅 🌄 🌠 🎇 🎆 🌇 🌆 🏙️ 🌃 🌌 🌉 🌁")),
            ("⚽", s("⚽ 🏀 🏈 ⚾ 🥎 🎾 🏐 🏉 🥏 🎱 🪀 🏓 🏸 🏒 🏑 🥍 🏏 🥅 ⛳ 🪁 🏹 🎣 🤿 🥊 🥋 🎽 🛹 🛼 🛷 ⛸️ 🥌 🎿 ⛷️ 🏂 🪂 🏋️ 🤼 🤸 ⛹️ 🤺 🤾 🏌️ 🏇 🧘 🏄 🏊 🤽 🚣 🧗 🚵 🚴 🏆 🥇 🥈 🥉 🏅 🎖️ 🏵️ 🎗️ 🎫 🎟️ 🎪 🤹 🎭 🩰 🎨 🎬 🎤 🎧 🎼 🎹 🥁 🎷 🎺 🎸 🪕 🎻 🎲 ♟️ 🎯 🎳 🎮 🎰 🧩")),
            ("💡", s("⌚ 📱 📲 💻 ⌨️ 🖥️ 🖨️ 🖱️ 🖲️ 🕹️ 🗜️ 💽 💾 💿 📀 📼 📷 📸 📹 🎥 📽️ 🎞️ 📞 ☎️ 📟 📠 📺 📻 🎙️ 🎚️ 🎛️ 🧭 ⏱️ ⏲️ ⏰ 🕰️ ⌛ ⏳ 📡 🔋 🔌 💡 🔦 🕯️ 🪔 🧯 🛢️ 💸 💵 💴 💶 💷 💰 💳 💎 ⚖️ 🪜 🧰 🪛 🔧 🔨 ⚒️ 🛠️ ⛏️ 🪝 🔩 ⚙️ 🧱 ⛓️ 🧲 🔫 💣 🧨 🪓 🔪 🗡️ ⚔️ 🛡️ 🚬 ⚰️ 🪦 🏺 🔮 📿 🧿 💈 ⚗️ 🔭 🔬 🕳️ 🩹 🩺 💊 💉 🩸 🧬 🦠 🧫 🧪 🌡️ 🧹 🧺 🧻 🚽 🚰 🚿 🛁 🛀 🧼 🪥 🪒 🧽 🪣 🧴 🛎️ 🔑 🗝️ 🚪 🪑 🛋️ 🛏️ 🛌 🧸 🖼️ 🪞 🪟 🛍️ 🛒 🎁 🎈 🎏 🎀 🪄 🪅 🎊 🎉 🎎 🏮 🎐 🧧 ✉️ 📩 📨 📧 💌 📥 📤 📦 🏷️ 📪 📫 📬 📭 📮 📯 📜 📃 📄 📑 🧾 📊 📈 📉 🗒️ 🗓️ 📆 📅 🗑️ 📇 🗃️ 🗳️ 🗄️ 📋 📁 📂 🗂️ 🗞️ 📰 📓 📔 📒 📕 📗 📘 📙 📚 📖 🔖 🧷 🔗 📎 🖇️ 📐 📏 🧮 📌 📍 ✂️ 🖊️ 🖋️ ✒️ 🖌️ 🖍️ 📝 ✏️ 🔍 🔎 🔏 🔐 🔒 🔓")),
            ("⭐", s("✅ ❌ ❎ ✔️ ☑️ 🔘 🔴 🟠 🟡 🟢 🔵 🟣 ⚫ ⚪ 🟤 🔺 🔻 🔸 🔹 🔶 🔷 🔳 🔲 ▪️ ▫️ ◾ ◽ ◼️ ◻️ 🟥 🟧 🟨 🟩 🟦 🟪 ⬛ ⬜ 🟫 🔈 🔇 🔉 🔊 🔔 🔕 📣 📢 👁️‍🗨️ 🗨️ ♀️ ♂️ ⚧️ ♾️ ♻️ ⚜️ 🔱 📛 🔰 ⭕ ➕ ➖ ➗ ✖️ 🟰 ‼️ ⁉️ ❓ ❔ ❕ ❗ 〰️ 💱 💲")),
            ("🌙", s("🌙 🌛 🌜 🌝 🌞 ⭐ 🌟 🌠 🌌 🪐 🌍 🌎 🌏 🌐 🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘")),
            ("🇾🇪", s("🇾🇪 🇸🇦 🇦🇪 🇰🇼 🇶🇦 🇧🇭 🇴🇲 🇯🇴 🇱🇧 🇸🇾 🇮🇶 🇵🇸 🇪🇬 🇱🇾 🇹🇳 🇩🇿 🇲🇦 🇸🇩 🇸🇴 🇩🇯 🇰🇲 🇲🇷 🇺🇸 🇬🇧 🇨🇦 🇦🇺 🇳🇿 🇮🇪 🇫🇷 🇩🇪 🇮🇹 🇪🇸 🇵🇹 🇳🇱 🇧🇪 🇨🇭 🇦🇹 🇸🇪 🇳🇴 🇩🇰 🇫🇮 🇵🇱 🇨🇿 🇸🇰 🇭🇺 🇷🇴 🇧🇬 🇬🇷 🇹🇷 🇷🇺 🇺🇦 🇷🇸 🇭🇷 🇸🇮 🇧🇦 🇦🇱 🇲🇰 🇨🇳 🇯🇵 🇰🇷 🇰🇵 🇮🇳 🇵🇰 🇧🇩 🇱🇰 🇳🇵 🇧🇹 🇲🇲 🇹🇭 🇻🇳 🇰🇭 🇱🇦 🇲🇾 🇸🇬 🇮🇩 🇵🇭 🇧🇳 🇹🇱 🇲🇳 🇰🇿 🇺🇿 🇹🇲 🇹🇯 🇰🇬 🇦🇫 🇮🇷 🇦🇲 🇬🇪 🇦🇿 🇧🇷 🇦🇷 🇨🇱 🇨🇴 🇵🇪 🇻🇪 🇪🇨 🇧🇴 🇵🇾 🇺🇾 🇬🇾 🇸🇷 🇲🇽 🇬🇹 🇧🇿 🇸🇻 🇭🇳 🇳🇮 🇨🇷 🇵🇦 🇨🇺 🇩🇴 🇭🇹 🇯🇲 🇹🇹 🇧🇸 🇧🇧 🇿🇦 🇳🇬 🇰🇪 🇪🇹 🇬🇭 🇹🇿 🇺🇬 🇷🇼 🇸🇳 🇨🇮 🇨🇲 🇦🇴 🇿🇼 🇿🇲 🇲🇼 🇲🇿 🇳🇦 🇧🇼 🇲🇬 🇲🇺 🇸🇨 🏳️ 🏴 🏴‍☠️ 🏁 🚩 🎌 🏳️‍🌈 🇺🇳 🇪🇺"))
        ]
    }
}

final class EmojiCell: UICollectionViewCell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }
    func paint(_ p: NaqraPalette) {
        contentView.backgroundColor = .clear
        label.textColor = p.text
    }
}
