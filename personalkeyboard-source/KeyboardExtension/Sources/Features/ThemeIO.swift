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

    /// Always write the current process's standard defaults (works in sideload).
    /// Also write the shared suite when the App Group is alive (signed builds).
    static func set(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
        if groupAlive {
            suite.set(value, forKey: key)
        }
    }

    static func string(_ key: String) -> String? {
        if groupAlive {
            // Signed: container → extension via App Group first.
            return suite.string(forKey: key) ?? UserDefaults.standard.string(forKey: key)
        }
        // Sideload: only local standard is trustworthy for preferences.
        return UserDefaults.standard.string(forKey: key)
    }

    static func bool(_ key: String) -> Bool? {
        if groupAlive {
            if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
            if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
            return nil
        }
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
