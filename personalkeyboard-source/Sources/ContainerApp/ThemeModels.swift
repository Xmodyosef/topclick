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
    static let all: [ThemeSwatch] = [
        .init(id: "auto", title: "يتبدّل مع الوقت", key: Color(red: 0.16, green: 0.18, blue: 0.23), ink: .white, accent: NaqraColors.accent),
        .init(id: "morning", title: "صباح هادئ", key: Color(red: 0.96, green: 0.90, blue: 0.78), ink: Color(red: 0.22, green: 0.16, blue: 0.10), accent: Color(red: 0.72, green: 0.48, blue: 0.22)),
        .init(id: "evening", title: "مساء مخملي", key: Color(red: 0.08, green: 0.12, blue: 0.24), ink: Color(red: 0.96, green: 0.78, blue: 0.42), accent: Color(red: 0.82, green: 0.58, blue: 0.22)),
        .init(id: "light", title: "لؤلؤي", key: Color(red: 0.90, green: 0.95, blue: 0.99), ink: Color(red: 0.14, green: 0.27, blue: 0.40), accent: Color(red: 0.28, green: 0.52, blue: 0.86)),
        .init(id: "dark", title: "فحمي", key: Color(red: 0.10, green: 0.16, blue: 0.28), ink: Color(red: 0.93, green: 0.96, blue: 1), accent: Color(red: 0.36, green: 0.60, blue: 1)),
        .init(id: "ocean", title: "محيط", key: Color(red: 0.06, green: 0.22, blue: 0.32), ink: Color(red: 0.62, green: 0.96, blue: 0.98), accent: Color(red: 0.16, green: 0.78, blue: 0.84)),
        .init(id: "forest", title: "مريمية", key: Color(red: 0.06, green: 0.18, blue: 0.12), ink: Color(red: 0.70, green: 0.96, blue: 0.76), accent: Color(red: 0.22, green: 0.78, blue: 0.42)),
        .init(id: "violet", title: "بنفسج", key: Color(red: 0.18, green: 0.10, blue: 0.32), ink: Color(red: 0.90, green: 0.78, blue: 1), accent: Color(red: 0.70, green: 0.42, blue: 1)),
        .init(id: "m7", title: "نعناع", key: Color(red: 0.84, green: 0.93, blue: 0.88), ink: Color(red: 0.22, green: 0.16, blue: 0.10), accent: Color(red: 0.72, green: 0.48, blue: 0.22)),
        .init(id: "m12", title: "ورد", key: Color(red: 0.96, green: 0.86, blue: 0.90), ink: Color(red: 0.22, green: 0.16, blue: 0.10), accent: Color(red: 0.72, green: 0.48, blue: 0.22)),
        .init(id: "e5", title: "برقوق ليلي", key: Color(red: 0.18, green: 0.10, blue: 0.22), ink: Color.white.opacity(0.94), accent: Color(red: 0.82, green: 0.58, blue: 0.22)),
        .init(id: "e11", title: "جمر", key: Color(red: 0.22, green: 0.10, blue: 0.08), ink: Color(red: 0.96, green: 0.78, blue: 0.42), accent: Color(red: 0.82, green: 0.58, blue: 0.22)),
        .init(id: "aurora", title: "شفق", key: Color(red: 0.10, green: 0.28, blue: 0.30), ink: Color(red: 0.80, green: 1.0, blue: 0.92), accent: Color(red: 0.32, green: 0.86, blue: 0.74)),
        .init(id: "lavender", title: "لافندر", key: Color(red: 0.28, green: 0.20, blue: 0.42), ink: Color(red: 0.94, green: 0.88, blue: 1.0), accent: Color(red: 0.70, green: 0.58, blue: 1.0)),
        .init(id: "sunset", title: "غروب", key: Color(red: 0.38, green: 0.14, blue: 0.16), ink: Color(red: 1.0, green: 0.86, blue: 0.72), accent: Color(red: 1.0, green: 0.48, blue: 0.28)),
        .init(id: "mint", title: "نعناع ليلي", key: Color(red: 0.08, green: 0.24, blue: 0.22), ink: Color(red: 0.76, green: 1.0, blue: 0.90), accent: Color(red: 0.24, green: 0.82, blue: 0.62)),
        .init(id: "rose", title: "وردي", key: Color(red: 0.36, green: 0.12, blue: 0.24), ink: Color(red: 1.0, green: 0.84, blue: 0.92), accent: Color(red: 0.96, green: 0.42, blue: 0.68)),
        .init(id: "mono", title: "أحادي", key: Color(red: 0.22, green: 0.23, blue: 0.25), ink: Color.white, accent: Color(red: 0.70, green: 0.74, blue: 0.80))
    ]

    static let groups: [ThemeGroup] = [
        .init(id: "daily", title: "اليومي", themes: selected(["auto", "light", "dark", "ocean"])),
        .init(id: "morning", title: "ألوان الصباح", themes: selected(["morning", "m7", "m12"])),
        .init(id: "evening", title: "ألوان المساء", themes: selected(["evening", "forest", "violet", "e5", "e11", "aurora", "lavender", "sunset", "mint", "rose", "mono"]))
    ]

    static func swatch(for id: String) -> ThemeSwatch {
        let resolvedID = id == "auto" ? TimeTheme.preferredThemeId() : id
        return all.first(where: { $0.id == resolvedID })
            ?? all.first(where: { $0.id == "dark" })!
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

