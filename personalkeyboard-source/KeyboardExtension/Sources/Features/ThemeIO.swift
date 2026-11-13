import Foundation

enum ThemeIO {
    static let group = "group.app.personal.PersonalKeyboard"
    static let notificationName = "app.personal.PersonalKeyboard.prefs"
    static var suite: UserDefaults { UserDefaults(suiteName: group) ?? .standard }

    /// True only when the App Group container exists (signed install with the entitlement).
    /// Unsigned / sideloaded builds strip groups, so suite is a private non-shared domain.
    static var groupAlive: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) != nil
    }

    static func write(_ key: String, value: Any) {
        set(key, value: value)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil, nil, true
        )
    }

    /// Always write both: standard (sideload-safe) and the shared suite (signed builds).
    static func set(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        suite.set(value, forKey: key)
    }

    /// Always try the shared suite first, then fall back to standard.
    /// This restores the pre-#115 behavior that made app-to-keyboard theme transfer work.
    static func string(_ key: String) -> String? {
        suite.string(forKey: key) ?? UserDefaults.standard.string(forKey: key)
    }

    static func bool(_ key: String) -> Bool? {
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
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
