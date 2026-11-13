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
        guard let spec = SharedThemeCatalog.spec(id) else { return nil }
        let r = spec.red, g = spec.green, b = spec.blue, dark = spec.dark
        let key = Color(red: r, green: g, blue: b)
        let ink: Color = dark
            ? Color(red: min(1, r + 0.75), green: min(1, g + 0.75), blue: min(1, b + 0.78))
            : Color(red: max(0, r - 0.55), green: max(0, g - 0.55), blue: max(0, b - 0.50))
        let accent: Color = dark
            ? Color(red: min(1, r + 0.35), green: min(1, g + 0.25), blue: min(1, b + 0.15))
            : Color(red: max(0.2, r - 0.25), green: max(0.15, g - 0.30), blue: max(0.1, b - 0.20))
        return ThemeSwatch(
            id: id,
            title: spec.title,
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
    static let suiteName = "group.Mark1"
    static let notificationName = "app.personal.PersonalKeyboard.prefs"
    static var suite: UserDefaults { UserDefaults(suiteName: suiteName) ?? .standard }

    static func write(_ key: String, value: Any) {
        // App Group suite first (extension sync), then standard fallback for sideload.
        suite.set(value, forKey: key)
        UserDefaults.standard.set(value, forKey: key)
        suite.synchronize()
        // UserDefaults keeps a per-process cache. The file is what a live keyboard reads
        // on the next open, without killing the extension or toggling Full Access.
        if key == "naqra.themeId", let text = value as? String,
           let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) {
            try? Data(text.utf8).write(to: url.appendingPathComponent("naqra-theme-id.txt"), options: .atomic)
        }
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
        let raw = string("naqra.themeId") ?? "auto"
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
