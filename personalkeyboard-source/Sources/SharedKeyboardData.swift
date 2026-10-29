import Foundation

/// Shared keys + defaults used by ContainerApp and KeyboardExtension.
/// Added from connectors review (Context7 / Exa / Firecrawl) — single source of truth.
/// Wire this file into both targets in project.yml when ready.
enum SharedKeyboardData {
    static let appGroup = "group.app.personal.PersonalKeyboard"
    static let prefsNotification = "app.personal.PersonalKeyboard.prefs"

    enum PrefKey {
        static let themeId = "themeId"
        static let soundChoice = "soundChoice"
        static let sounds = "sounds"
        static let showNumberRow = "showNumberRow"
        static let holdDelayMs = "holdDelayMs"
        static let clipboardHistory = "clipboardHistory"
    }

    /// Default long-press delay before popup (ms). User can tune later in Settings.
    static let defaultHoldDelayMs: Double = 320

    static func holdDelaySeconds() -> TimeInterval {
        let suite = UserDefaults(suiteName: appGroup) ?? .standard
        let ms = suite.object(forKey: PrefKey.holdDelayMs) as? Double ?? defaultHoldDelayMs
        return max(0.20, min(1.50, ms / 1000.0))
    }
}
