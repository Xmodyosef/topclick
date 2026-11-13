import Foundation

enum ThemeIO {
    /// Must match a group stamped by the Azor profile (group.Mark1…Mark7).
    static let group = "group.Mark1"
    static let notificationName = "app.personal.PersonalKeyboard.prefs"
    static var suite: UserDefaults { UserDefaults(suiteName: group) ?? .standard }

    static func write(_ key: String, value: Any) {
        set(key, value: value)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil, nil, true
        )
    }

    /// Prefer App Group. Writes stay on the suite only (CI forbids standard.set in the extension).
    static func set(_ key: String, value: Any) {
        suite.set(value, forKey: key)
    }

    /// Sideload fallback: app dual-writes naqra.themeId to standard when the group is dead.
    static func string(_ key: String) -> String? {
        suite.string(forKey: key) ?? UserDefaults.standard.string(forKey: key)
    }

    static func bool(_ key: String) -> Bool? {
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil {
            return UserDefaults.standard.bool(forKey: key)
        }
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
