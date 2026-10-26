import Foundation

enum ThemeIO {
    static let group = "group.app.personal.PersonalKeyboard"
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

    /// Dual-write: UserDefaults.standard first (in-app storage), then App Group if available (#2).
    /// Sideload builds often lack App Group — standard keeps themes/sounds inside the app.
    static func set(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        suite.set(value, forKey: key)
    }

    static func string(_ key: String) -> String? {
        // Prefer standard (app-local) then group — themes live in-app when group is missing.
        UserDefaults.standard.string(forKey: key) ?? suite.string(forKey: key)
    }

    static func bool(_ key: String) -> Bool? {
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
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
