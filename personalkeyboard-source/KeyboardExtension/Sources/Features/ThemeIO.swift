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

    /// App Group only. The container app writes themeId into this suite.
    static func set(_ key: String, value: Any) {
        suite.set(value, forKey: key)
    }

    static func string(_ key: String) -> String? {
        suite.string(forKey: key)
    }

    static func bool(_ key: String) -> Bool? {
        guard suite.object(forKey: key) != nil else { return nil }
        return suite.bool(forKey: key)
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
