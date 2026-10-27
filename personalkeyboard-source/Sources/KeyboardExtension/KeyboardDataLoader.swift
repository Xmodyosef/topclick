import Foundation

/// Loads heavy keyboard data from JSON resources (lazy, cached).
enum KeyboardDataLoader {
    private static let lock = NSLock()
    private static var layoutsCache: Layouts?
    private static var lexiconCache: [String]?
    private static var emojiCache: [(icon: String, items: [String])]?
    private static let arabicShiftFallbackRows = [
        ["َ", "ً", "ُ", "ٌ", "ْ", "ّ", "ٍ", "ِ", "ـ", "«", "»"],
        ["ئ", "ء", "ؤ", "إ", "أ", "آ", "ة", "ى", "؛", "،", "؟"],
        ["١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"]
    ]

    struct Layouts {
        let arabicRows: [[String]]
        let arabicShiftRows: [[String]]
        let englishLower: [[String]]
        let englishUpper: [[String]]
        let arabicSymbolPages: [[[String]]]
        let englishSymbolPages: [[[String]]]
        let holdMap: [String: [String]]
    }

    private static func data(named name: String) -> Data? {
        let n = name.replacingOccurrences(of: ".json", with: "")
        if let url = Bundle.main.url(forResource: n, withExtension: "json") {
            return try? Data(contentsOf: url)
        }
        // Some hosts put resources next to the extension binary without subfolder registration.
        if let url = Bundle.main.url(forResource: n, withExtension: "json", subdirectory: "Resources") {
            return try? Data(contentsOf: url)
        }
        return nil
    }

    static func layouts() -> Layouts {
        lock.lock(); defer { lock.unlock() }
        if let layoutsCache { return layoutsCache }
        guard let data = data(named: "keyboard_layouts"),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            let fb = Layouts(
                arabicRows: [["ض","ص","ث","ق","ف","غ","ع","ه","خ","ح","ج"],["ش","س","ي","ب","ل","ا","ت","ن","م","ك","ة"],["ء","ظ","ط","ذ","د","ز","ر","و","ى"]],
                arabicShiftRows: arabicShiftFallbackRows,
                englishLower: [["q","w","e","r","t","y","u","i","o","p"],["a","s","d","f","g","h","j","k","l"],["z","x","c","v","b","n","m"]],
                englishUpper: [["Q","W","E","R","T","Y","U","I","O","P"],["A","S","D","F","G","H","J","K","L"],["Z","X","C","V","B","N","M"]],
                arabicSymbolPages: builtinArabicSymbols,
                englishSymbolPages: builtinEnglishSymbols,
                holdMap: [
                    "ا": ["أ","إ","آ"], "و": ["ؤ"], "ي": ["ئ","ى"], "ه": ["ة"],
                    "ل": ["لا","لأ","لإ","لآ"], "س": ["ش"], "ص": ["ض"], "ط": ["ظ"],
                    "ع": ["غ"], "ج": ["چ"], "ح": ["خ"], "ز": ["ژ"], "د": ["ذ"]
                ]
            )
            layoutsCache = fb
            return fb
        }
        func rows2(_ key: String) -> [[String]] {
            (obj[key] as? [[String]]) ?? []
        }
        func rows3(_ key: String) -> [[[String]]] {
            (obj[key] as? [[[String]]]) ?? []
        }
        func map(_ key: String) -> [String: [String]] {
            (obj[key] as? [String: [String]]) ?? [:]
        }
        var arabicSymbols = rows3("arabic_symbol_pages")
        var englishSymbols = rows3("english_symbol_pages")
        // Prefer bundled layouts; fall back when JSON missing/thin.
        if arabicSymbols.isEmpty || arabicSymbols.flatMap({ $0 }).flatMap({ $0 }).count < 20 {
            arabicSymbols = Self.builtinArabicSymbols
        }
        if englishSymbols.isEmpty || englishSymbols.flatMap({ $0 }).flatMap({ $0 }).count < 20 {
            englishSymbols = Self.builtinEnglishSymbols
        }
        let value = Layouts(
            arabicRows: rows2("arabic_rows"),
            arabicShiftRows: rows2("arabic_shift_rows").isEmpty ? arabicShiftFallbackRows : rows2("arabic_shift_rows"),
            englishLower: rows2("english_lower"),
            englishUpper: rows2("english_upper"),
            arabicSymbolPages: arabicSymbols,
            englishSymbolPages: englishSymbols,
            holdMap: map("hold_map")
        )
        layoutsCache = value
        return value
    }

    /// Single uncrowded symbols page: 3 solid rows + faces row (#11).
    static let builtinArabicSymbols: [[[String]]] = [
        [
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            ["-", "/", ":", "؛", "(", ")", "﷼", "&", "@", "\""],
            [".", "،", "؟", "!", "[", "]", "{", "}", "=", "_"],
            ["😀", "😁", "😂", "🤣", "😊", "😍", "🥰", "😎", "🤔", "🙌"]
        ]
    ]

    /// English: same packing — 3 solid + faces (#11).
    static let builtinEnglishSymbols: [[[String]]] = [
        [
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
            ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
            [".", ",", "?", "!", "[", "]", "{", "}", "=", "_"],
            ["😀", "😁", "😂", "🤣", "😊", "😍", "🥰", "😎", "🤔", "🙌"]
        ]
    ]

    static func arabicLexicon() -> [String] {
        lock.lock(); defer { lock.unlock() }
        if let lexiconCache { return lexiconCache }
        if let data = data(named: "arabic_lexicon"),
           let words = try? JSONSerialization.jsonObject(with: data) as? [String] {
            lexiconCache = words
            return words
        }
        lexiconCache = ["السلام", "عليكم", "الله", "صباح", "الخير"]
        return lexiconCache!
    }

    static func clearEmojiCache() {
        lock.lock(); defer { lock.unlock() }
        emojiCache = nil
    }

    static func emojiCatalog(frequent: [String] = []) -> [(icon: String, items: [String])] {
        lock.lock(); defer { lock.unlock() }
        if emojiCache == nil {
            if let data = data(named: "emoji_catalog"),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                emojiCache = arr.compactMap { row in
                    guard let icon = row["icon"] as? String,
                          let items = row["items"] as? [String] else { return nil }
                    return (icon, items)
                }
            } else {
                // Dense fallback if JSON missing from bundle.
                emojiCache = [
                    ("😀", ["😀", "😂", "🥰", "😍", "😊", "😅", "😭", "😡", "🤔", "😎", "🤩", "😴", "😷", "🤯", "🫡"]),
                    ("⬛", ["⬛", "⬜", "⚫", "⚪", "🔴", "🔵", "🟢", "🟡", "⭐", "✨", "❤️", "🖤", "🤍", "💜", "💙"]),
                    ("👋", ["👋", "👍", "👎", "👏", "🙏", "💪", "✌️", "🤞", "🤝", "🖐️"])
                ]
            }
        }
        guard var packs = emojiCache, !packs.isEmpty else { return emojiCache ?? [] }
        // Merge frequent into first category without mutating the cache permanently for empty frequent.
        if !frequent.isEmpty {
            var seen = Set<String>()
            let merged = (Array(frequent.prefix(24)) + packs[0].items).filter { seen.insert($0).inserted }
            packs[0] = (packs[0].icon, merged)
            return packs
        }
        return packs
    }
}
