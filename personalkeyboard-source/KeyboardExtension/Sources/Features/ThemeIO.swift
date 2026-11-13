import Foundation

enum ThemeIO {
    /// Must match a group stamped by the Azor profile (group.Mark1…Mark7).
    static let group = "group.Mark1"
    static let themeKey = "naqra.themeId"
    static let notificationName = "app.personal.PersonalKeyboard.prefs"
    static var suite: UserDefaults { UserDefaults(suiteName: group) ?? .standard }

    /// Disk copy inside the App Group. UserDefaults caches the suite per process,
    /// so a keyboard that stays alive keeps reading the old theme until it is killed.
    static var themeFileURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?
            .appendingPathComponent("naqra-theme-id.txt")
    }

    static func flushShared() {
        // Validator forbids UserDefaults.synchronize. Preferences sync reloads the
        // group plist; the theme file is the source the keyboard actually trusts.
        CFPreferencesAppSynchronize(group as CFString)
    }

    static func write(_ key: String, value: Any) {
        set(key, value: value)
        if key == themeKey, let text = value as? String {
            writeThemeFile(text)
        }
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

    static func writeThemeFile(_ id: String) {
        guard let url = themeFileURL else { return }
        try? Data(id.utf8).write(to: url, options: .atomic)
    }

    static func themeFileValue() -> String? {
        guard let url = themeFileURL,
              let data = try? Data(contentsOf: url),
              let text = String(data: data, encoding: .utf8) else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    /// Sideload fallback: app dual-writes naqra.themeId to standard when the group is dead.
    static func string(_ key: String) -> String? {
        flushShared()
        if key == themeKey, let file = themeFileValue() {
            return file
        }
        return suite.string(forKey: key) ?? UserDefaults.standard.string(forKey: key)
    }

    static func bool(_ key: String) -> Bool? {
        flushShared()
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
