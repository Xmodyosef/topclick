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

    var letterFont: UIFont {
        // One compact, predictable font keeps Arabic and English aligned.
        .systemFont(ofSize: 26, weight: .medium)
    }
    let iconConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    let boardHeight: CGFloat = 324
    var themeSignature: String {
        let id = ThemeIO.string("themeId") ?? "auto"
        return id == "auto" ? "auto-\(TimeTheme.preferredThemeId())" : id
    }

    // Apple-style Arabic layout: 11 / 11 / 11 keys, kept simple and predictable.
    let arabicRows = [
        ["ض","ص","ث","ق","ف","غ","ع","ه","خ","ح","ج"],
        ["ش","س","ي","ب","ل","ا","ت","ن","م","ك","ة"],
        ["ع","ظ","ط","ذ","د","ز","ر","و","ي"]
    ]
    // Arabic has no upper-case layer; Shift keeps the same readable letters.
    var arabicShiftRows: [[String]] {
        arabicRows
    }
    let englishLower = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l"],
        ["z","x","c","v","b","n","m"]
    ]
    let englishUpper = [
        ["Q","W","E","R","T","Y","U","I","O","P"],
        ["A","S","D","F","G","H","J","K","L"],
        ["Z","X","C","V","B","N","M"]
    ]
    let numberRow = ["1","2","3","4","5","6","7","8","9","0"]
    var showNumberRow: Bool {
        ThemeIO.bool("showNumberRow") ?? true
    }
    var symbolPages: [[[String]]] { language == .arabic ? arabicSymbolPages : englishSymbolPages }
    let arabicSymbolPages = [[
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":","؛","(",")","؟","﷼","&","@"],
        [".","،","؟","!","'","«","»","٪","…","•"],
        ["[","]","{","}","#","*","+","=","_","~"],
    ]]
    let englishSymbolPages = [[
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/",":",";","(",")","$","&","@","\""],
        [".",",","?","!","'","\"","+","=","/","•"],
        ["[","]","{","}","#","*","_","~","^","%"],
    ]]
    var emojiPack: [(icon: String, items: [String])] = KeyboardViewController.catalog()

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

    static let arabicLexicon = [
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
















    func refreshTabs() {
        guard let tabs = emojiTabs else { return }
        for (i, view) in tabs.arrangedSubviews.enumerated() {
            view.backgroundColor = i == emojiCategoryIndex ? UIColor.white.withAlphaComponent(0.22) : .clear
        }
    }



    let holdMap: [String: [String]] = [
        "ا": ["أ", "إ", "آ"],
        "و": ["ؤ"],
        "ي": ["ئ", "ى"],
        "ه": ["ة"],
        "ل": ["لا", "لأ", "لإ", "لآ"],
        "س": ["ش"],
        "ص": ["ض"],
        "ط": ["ظ"],
        "ع": ["غ"],
        "ج": ["چ"],
        "ح": ["خ"],
        "ز": ["ژ"],
        "د": ["ذ"]
    ]


    func alts(for key: String) -> [String] {
        return holdMap[key] ?? []
    }


    func control(_ t: String, _ a: Selector, font: CGFloat) -> UIButton {
        let b = UIButton(type: .system)
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













    func knownWord(_ token: String) -> Bool {
        if language == .english {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: token.utf16.count)
            let miss = checker.rangeOfMisspelledWord(in: token, range: range, startingAt: 0, wrap: false, language: "en_US")
            return miss.location == NSNotFound
        }
        let folded = Self.fold(token)
        return Self.arabicLexicon.contains { Self.fold($0) == folded }
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
        let raw = ThemeIO.string("frequentEmoji") ?? "😀 😂 ❤️ 😍 🔥 👍 🙏 😊 ✨ 😭 👏 💕 🌹 🇾🇪 🎉 😎 🤔 😅 😁 😘 💪 ✌️ 💯 💙"
        return raw.split(separator: " ").map(String.init)
    }


    static func catalog() -> [(icon: String, items: [String])] {
        func s(_ t: String) -> [String] { t.split(separator: " ").map(String.init) }
        func merge(_ first: [String], _ second: [String]) -> [String] {
            var seen = Set<String>()
            return (first + second).filter { seen.insert($0).inserted }
        }
        return [
            ("😀", merge(Array(loadFrequent().prefix(24)), s("😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 😉 😌 😍 🥰 😘 😗 😙 😚 😋 😛 😝 😜 🤪 🤨 🧐 🤓 😎 🤩 🥳 😏 😒 😞 😔 😟 😕 🙁 ☹️ 😣 😖 😫 😩 🥺 😢 😭 😤 😠 😡 🤬 🤯 😳 🥵 🥶 😱 😨 😰 😥 😓 🤗 🤔 🤭 🤫 🤥 😶 😐 😑 🫠 🫡 🫢 🫣 🫤 🥹 🥲 😵‍💫 😬 🙄 😯 😦 😧 😮 😲 🥱 😴 🤤 😪 😵 🤐 🥴 🤢 🤮 🤧 😷 🤒 🤕 🤑 🤠 😈 👿 🤡 👻 💀 👽 🤖 🎃 😺 😸 😹 😻 😼 😽 🙀 😿 😾"))),
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

