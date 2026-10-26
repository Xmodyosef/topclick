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
        "m7": "نعناع", "m12": "ورد", "m4": "مشمش", "m9": "سماء",
        "e5": "برقوق", "e11": "جمر ليلي", "e2": "كحلي", "e8": "زمرد",
        "aurora": "شفق", "lavender": "لافندر", "sunset": "غروب", "mint": "نعناع ليلي",
        "rose": "وردي", "mono": "أحادي"
    ]

    /// Distinct surfaces only — no near-duplicates.
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
        "m4": (0.97, 0.82, 0.64, false), "m7": (0.84, 0.93, 0.88, false),
        "m9": (0.78, 0.88, 0.96, false), "m12": (0.96, 0.86, 0.90, false),
        "e2": (0.08, 0.12, 0.24, true), "e5": (0.18, 0.10, 0.22, true),
        "e8": (0.06, 0.18, 0.16, true), "e11": (0.22, 0.10, 0.08, true),
        "aurora": (0.10, 0.28, 0.30, true), "lavender": (0.28, 0.20, 0.42, true),
        "sunset": (0.38, 0.14, 0.16, true), "mint": (0.08, 0.24, 0.22, true),
        "rose": (0.36, 0.12, 0.24, true), "mono": (0.22, 0.23, 0.25, true)
    ]

    static let all: [ThemeSwatch] = {
        let order = [
            "auto", "morning", "evening", "light", "dark", "glass",
            "ocean", "cobalt", "forest", "violet", "orchid", "ember", "hailey", "matrix", "nord",
            "m4", "m7", "m9", "m12", "e2", "e5", "e8", "e11",
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
            "m4", "m7", "m9", "m12", "e2", "e5", "e8", "e11"
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
        // Distinct ink + accent per theme so tiles don't look repeated
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
        // App-local first, then App Group (#2 themes/sounds inside app for sideload).
        UserDefaults.standard.set(value, forKey: key)
        suite.set(value, forKey: key)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil, nil, true
        )
    }

    static func string(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key) ?? suite.string(forKey: key)
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
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        return nil
    }

    static func int(_ key: String) -> Int? {
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.integer(forKey: key) }
        if suite.object(forKey: key) != nil { return suite.integer(forKey: key) }
        return nil
    }

    static var groupAlive: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) != nil
    }

    static func clearClipboardHistory() { write("clipboardHistory", value: "") }
}

