import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Theme catalog

struct ThemeSwatch: Identifiable {
    let id: String
    let title: String
    let key: Color
    let ink: Color
    let accent: Color
}

struct ThemeGroup: Identifiable {
    let id: String
    let title: String
    let themes: [ThemeSwatch]
}

enum ThemeCatalog {
    /// Arabic titles aligned with extension NaqraPalette.titles
    private static let titles: [String: String] = [
        "auto": "يتبدّل مع الوقت", "light": "لؤلؤي", "dark": "فحمي", "glass": "منشور",
        "ocean": "محيط", "cobalt": "كوبالت", "violet": "بنفسج", "orchid": "أوركيد",
        "hailey": "دم", "ember": "جمر", "forest": "غابة", "matrix": "ماتريكس", "nord": "نورد",
        "morning": "صباح هادئ", "evening": "مساء مخملي",
        "m1": "رملي", "m2": "قش", "m3": "خوخ", "m4": "مشمش", "m5": "عاج", "m6": "حليب",
        "m7": "نعناع", "m8": "مريمية", "m9": "سماء", "m10": "بحيرة", "m11": "لافندر صباحي",
        "m12": "ورد", "m13": "ذهب", "m14": "عسل", "m15": "زيتون", "m16": "طين",
        "m17": "ورق", "m18": "ضباب", "m19": "مرجان", "m20": "فستق",
        "e1": "فحم", "e2": "كحلي", "e3": "ليل", "e4": "حبر", "e5": "برقوق", "e6": "نبيذ",
        "e7": "غابة ليلية", "e8": "زمرد", "e9": "محيط ليلي", "e10": "كوبالت ليلي",
        "e11": "جمر ليلي", "e12": "نحاس", "e13": "بنفسج ليلي", "e14": "أوركيد ليلي",
        "e15": "رماد", "e16": "دخان", "e17": "قهوة", "e18": "صحراء", "e19": "ملكي", "e20": "فجر",
        "aurora": "شفق", "lavender": "لافندر", "sunset": "غروب", "mint": "نعناع ليلي",
        "rose": "وردي", "mono": "أحادي"
    ]

    /// RGB key surfaces matching extension presets / tones (approximate for tiles + board).
    private static let rgb: [String: (Double, Double, Double, Bool)] = [
        "auto": (0.16, 0.18, 0.23, true),
        "light": (0.90, 0.95, 0.99, false),
        "dark": (0.10, 0.16, 0.28, true),
        "glass": (0.86, 0.82, 0.96, false),
        "ocean": (0.06, 0.22, 0.32, true),
        "cobalt": (0.10, 0.18, 0.42, true),
        "violet": (0.18, 0.10, 0.32, true),
        "orchid": (0.32, 0.08, 0.18, true),
        "hailey": (0.22, 0.05, 0.08, true),
        "ember": (0.24, 0.12, 0.05, true),
        "forest": (0.06, 0.18, 0.12, true),
        "matrix": (0.02, 0.07, 0.03, true),
        "nord": (0.78, 0.82, 0.86, false),
        "morning": (0.96, 0.90, 0.78, false),
        "evening": (0.08, 0.12, 0.24, true),
        "m1": (0.96, 0.90, 0.78, false), "m2": (0.94, 0.89, 0.72, false), "m3": (0.98, 0.86, 0.76, false),
        "m4": (0.97, 0.82, 0.64, false), "m5": (0.96, 0.94, 0.88, false), "m6": (0.93, 0.94, 0.96, false),
        "m7": (0.84, 0.93, 0.88, false), "m8": (0.78, 0.86, 0.76, false), "m9": (0.78, 0.88, 0.96, false),
        "m10": (0.72, 0.86, 0.90, false), "m11": (0.90, 0.86, 0.96, false), "m12": (0.96, 0.86, 0.90, false),
        "m13": (0.93, 0.86, 0.68, false), "m14": (0.92, 0.78, 0.52, false), "m15": (0.82, 0.84, 0.68, false),
        "m16": (0.86, 0.74, 0.62, false), "m17": (0.95, 0.93, 0.89, false), "m18": (0.86, 0.88, 0.90, false),
        "m19": (0.96, 0.78, 0.74, false), "m20": (0.80, 0.90, 0.78, false),
        "e1": (0.22, 0.23, 0.26, true), "e2": (0.08, 0.12, 0.24, true), "e3": (0.07, 0.09, 0.16, true),
        "e4": (0.10, 0.12, 0.18, true), "e5": (0.18, 0.10, 0.22, true), "e6": (0.24, 0.08, 0.14, true),
        "e7": (0.08, 0.16, 0.12, true), "e8": (0.06, 0.18, 0.16, true), "e9": (0.06, 0.14, 0.22, true),
        "e10": (0.10, 0.16, 0.32, true), "e11": (0.22, 0.10, 0.08, true), "e12": (0.28, 0.16, 0.10, true),
        "e13": (0.16, 0.10, 0.28, true), "e14": (0.26, 0.08, 0.18, true), "e15": (0.16, 0.18, 0.22, true),
        "e16": (0.14, 0.14, 0.16, true), "e17": (0.18, 0.12, 0.08, true), "e18": (0.20, 0.14, 0.10, true),
        "e19": (0.12, 0.08, 0.20, true), "e20": (0.18, 0.10, 0.12, true),
        "aurora": (0.10, 0.28, 0.30, true), "lavender": (0.28, 0.20, 0.42, true),
        "sunset": (0.38, 0.14, 0.16, true), "mint": (0.08, 0.24, 0.22, true),
        "rose": (0.36, 0.12, 0.24, true), "mono": (0.22, 0.23, 0.25, true)
    ]

    static let all: [ThemeSwatch] = {
        let order = [
            "auto", "light", "dark", "glass", "ocean", "cobalt", "violet", "orchid", "hailey", "ember",
            "forest", "matrix", "nord", "morning", "evening",
            "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10",
            "m11", "m12", "m13", "m14", "m15", "m16", "m17", "m18", "m19", "m20",
            "e1", "e2", "e3", "e4", "e5", "e6", "e7", "e8", "e9", "e10",
            "e11", "e12", "e13", "e14", "e15", "e16", "e17", "e18", "e19", "e20",
            "aurora", "lavender", "sunset", "mint", "rose", "mono"
        ]
        return order.compactMap { make($0) }
    }()

    static let groups: [ThemeGroup] = [
        .init(id: "daily", title: "اليومي والأساسي", themes: selected([
            "auto", "light", "dark", "glass", "ocean", "cobalt", "nord", "mono"
        ])),
        .init(id: "morning", title: "ألوان الصباح (20)", themes: selected(
            ["morning"] + (1...20).map { "m\($0)" }
        )),
        .init(id: "evening", title: "ألوان المساء (20)", themes: selected(
            ["evening"] + (1...20).map { "e\($0)" }
        )),
        .init(id: "special", title: "خاص ومميز", themes: selected([
            "violet", "orchid", "hailey", "ember", "forest", "matrix",
            "aurora", "lavender", "sunset", "mint", "rose"
        ]))
    ]

    static func swatch(for id: String) -> ThemeSwatch {
        let resolvedID = id == "auto" ? TimeTheme.preferredThemeId() : id
        return all.first(where: { $0.id == resolvedID })
            ?? all.first(where: { $0.id == "dark" })
            ?? make("dark")!
    }

    private static func make(_ id: String) -> ThemeSwatch? {
        guard let (r, g, b, dark) = rgb[id] else { return nil }
        let key = Color(red: r, green: g, blue: b)
        let ink: Color = dark
            ? Color(red: 0.96, green: 0.96, blue: 0.98)
            : Color(red: 0.18, green: 0.16, blue: 0.12)
        let accent: Color = dark
            ? Color(red: 0.82, green: 0.58, blue: 0.28)
            : Color(red: 0.55, green: 0.42, blue: 0.28)
        return ThemeSwatch(
            id: id,
            title: titles[id] ?? id,
            key: key,
            ink: ink,
            accent: accent
        )
    }

    private static func selected(_ ids: [String]) -> [ThemeSwatch] {
        ids.compactMap { id in all.first(where: { $0.id == id }) }
    }
}

enum TimeTheme {
    static func isMorning(at date: Date = Date()) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 6 && hour < 18
    }

    static func preferredThemeId() -> String { isMorning() ? "morning" : "evening" }
}

// MARK: - Shared preferences

enum ThemeStore {
    static let suiteName = "group.app.personal.PersonalKeyboard"
    static let notificationName = "app.personal.PersonalKeyboard.prefs"
    static var suite: UserDefaults { UserDefaults(suiteName: suiteName) ?? .standard }

    static func write(_ key: String, value: Any) {
        suite.set(value, forKey: key)
        UserDefaults.standard.set(value, forKey: key)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil, nil, true
        )
    }

    static func string(_ key: String) -> String? {
        return suite.string(forKey: key) ?? UserDefaults.standard.string(forKey: key)
    }

    static var themeID: String {
        let raw = string("themeId") ?? "auto"
        let legacy: [String: String] = [
            "charcoal": "dark", "smoke": "dark", "catppuccin_frappe": "dark", "catppuccin_macchiato": "dark",
            "teal": "ocean", "midnight": "cobalt", "midnight_gold": "cobalt", "neon_nights": "cobalt", "tron": "cobalt",
            "snow": "light", "minimal_light": "light", "catppuccin_latte": "light", "matcha": "m7",
            "cotton_candy": "m12", "candy_shop": "m12", "cherry": "e5", "cocoa": "e5",
            "neon": "forest", "catppuccin_mocha": "e2", "dracula": "violet"
        ]
        return legacy[raw] ?? raw
    }

    static func bool(_ key: String) -> Bool? {
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
        return nil
    }

    static func int(_ key: String) -> Int? {
        if suite.object(forKey: key) != nil { return suite.integer(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.integer(forKey: key) }
        return nil
    }

    static var groupAlive: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) != nil
    }

    static func clearClipboardHistory() { write("clipboardHistory", value: "") }
}

