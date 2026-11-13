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
    /// Arabic titles aligned with extension NaqraPalette.titles + legacy names.
    private static let titles: [String: String] = [
        "auto": "يتبدّل مع الوقت", "light": "لؤلؤي", "dark": "فحمي", "glass": "منشور",
        "ocean": "محيط", "cobalt": "كوبالت", "violet": "بنفسج", "orchid": "أوركيد",
        "hailey": "دم", "ember": "جمر", "forest": "غابة", "matrix": "ماتريكس", "nord": "نورد",
        "morning": "صباح هادئ", "evening": "مساء مخملي",
        "m1": "رملي", "m2": "قش", "m3": "خوخ", "m4": "مشمش", "m5": "عاج",
        "m6": "حليب", "m7": "نعناع", "m8": "مريمية", "m9": "سماء", "m10": "بحيرة",
        "m11": "لافندر", "m12": "ورد", "m13": "ذهب", "m14": "عسل", "m15": "زيتون",
        "m16": "طين", "m17": "ورق", "m18": "ضباب", "m19": "مرجان", "m20": "فستق",
        "e1": "فحم", "e2": "كحلي", "e3": "ليل",
        "e5": "برقوق", "e8": "زمرد", "e11": "جمر ليلي",
        "aurora": "شفق", "lavender": "لافندر", "sunset": "غروب", "mint": "نعناع ليلي",
        "rose": "وردي", "mono": "أحادي"
    ]

    /// Swatch RGB must match keyboard legacyRGB for m1…m20 / e1…e3.
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
        // Legacy soft (owner table)
        "m1": (0.93, 0.86, 0.72, false),
        "m2": (0.90, 0.82, 0.62, false),
        "m3": (0.96, 0.78, 0.68, false),
        "m4": (0.96, 0.72, 0.48, false),
        "m5": (0.95, 0.92, 0.84, false),
        "m6": (0.96, 0.94, 0.90, false),
        "m7": (0.74, 0.90, 0.82, false),
        "m8": (0.70, 0.80, 0.72, false),
        "m9": (0.70, 0.84, 0.94, false),
        "m10": (0.55, 0.78, 0.86, false),
        "m11": (0.82, 0.76, 0.90, false),
        "m12": (0.94, 0.74, 0.80, false),
        "m13": (0.90, 0.76, 0.40, false),
        "m14": (0.88, 0.68, 0.36, false),
        "m15": (0.62, 0.66, 0.40, false),
        "m16": (0.72, 0.52, 0.40, false),
        "m17": (0.78, 0.84, 0.72, false),
        "m18": (0.82, 0.84, 0.86, false),
        "m19": (0.92, 0.55, 0.50, false),
        "m20": (0.70, 0.82, 0.58, false),
        // Legacy night
        "e1": (0.12, 0.12, 0.13, true),
        "e2": (0.08, 0.12, 0.22, true),
        "e3": (0.07, 0.09, 0.16, true),
        // Extra dark accents still shown in catalog
        "e5": (0.18, 0.10, 0.22, true),
        "e8": (0.06, 0.18, 0.16, true),
        "e11": (0.22, 0.10, 0.08, true),
        "aurora": (0.10, 0.28, 0.30, true),
        "lavender": (0.28, 0.20, 0.42, true),
        "sunset": (0.38, 0.14, 0.16, true),
        "mint": (0.08, 0.24, 0.22, true),
        "rose": (0.36, 0.12, 0.24, true),
        "mono": (0.22, 0.23, 0.25, true)
    ]

    static let all: [ThemeSwatch] = {
        let order = [
            "auto", "morning", "evening", "light", "dark", "glass",
            "ocean", "cobalt", "forest", "violet", "orchid", "ember", "hailey", "matrix", "nord",
            "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10",
            "m11", "m12", "m13", "m14", "m15", "m16", "m17", "m18", "m19", "m20",
            "e1", "e2", "e3", "e5", "e8", "e11",
            "aurora", "lavender", "sunset", "mint", "rose", "mono"
        ]
        return order.compactMap { make($0) }
    }()

    static let groups: [ThemeGroup] = [
        .init(id: "daily", title: "اليومي", themes: selected([
            "auto", "morning", "evening", "light", "dark", "glass", "nord"
        ])),
        .init(id: "nature", title: "طبيعة وإحساس", themes: selected([
            "ocean", "forest", "mint", "aurora", "sunset", "ember", "rose"
        ])),
        .init(id: "bold", title: "جريء وواضح", themes: selected([
            "cobalt", "violet", "orchid", "hailey", "matrix", "lavender", "mono"
        ])),
        .init(id: "soft", title: "ناعم مميز", themes: selected([
            "m1", "m2", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "m10",
            "m11", "m12", "m13", "m14", "m15", "m16", "m17", "m18", "m19", "m20"
        ])),
        .init(id: "night", title: "ليلي كلاسيكي", themes: selected([
            "e1", "e2", "e3", "e5", "e8", "e11"
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
            ? Color(red: min(1, r + 0.75), green: min(1, g + 0.75), blue: min(1, b + 0.78))
            : Color(red: max(0, r - 0.55), green: max(0, g - 0.55), blue: max(0, b - 0.50))
        let accent: Color = dark
            ? Color(red: min(1, r + 0.35), green: min(1, g + 0.25), blue: min(1, b + 0.15))
            : Color(red: max(0.2, r - 0.25), green: max(0.15, g - 0.30), blue: max(0.1, b - 0.20))
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
        // App Group suite first (extension sync), then standard fallback for sideload.
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
