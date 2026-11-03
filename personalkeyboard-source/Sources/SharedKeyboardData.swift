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


struct ClipboardHistoryPayload: Codable, Equatable {
    let version: Int
    let items: [String]
}

enum ClipboardHistoryCodec {
    static let currentVersion = 1
    static let maximumItems = 20
    static let maximumItemCharacters = 5_000
    static let maximumTotalCharacters = 50_000

    static func encode(_ items: [String]) -> String? {
        let payload = ClipboardHistoryPayload(version: currentVersion, items: items)
        guard isValid(payload),
              let data = try? JSONEncoder().encode(payload),
              let string = String(data: data, encoding: .utf8),
              decode(string) == items else {
            return nil
        }
        return string
    }

    static func decode(_ string: String) -> [String]? {
        guard let data = string.data(using: .utf8),
              let payload = try? JSONDecoder().decode(ClipboardHistoryPayload.self, from: data),
              isValid(payload) else {
            return nil
        }
        return payload.items
    }

    /// The legacy U+001F format cannot recover a separator already embedded in an item.
    static func decodeLegacy(_ string: String) -> [String] {
        var accepted: [String] = []
        var totalCharacters = 0
        for item in string.split(separator: "\u{1F}").map(String.init) {
            guard !item.isEmpty,
                  item.count <= maximumItemCharacters,
                  accepted.count < maximumItems,
                  totalCharacters + item.count <= maximumTotalCharacters else {
                continue
            }
            accepted.append(item)
            totalCharacters += item.count
        }
        return accepted
    }

    static func looksLikeVersionedJSON(_ string: String) -> Bool {
        string.hasPrefix("{") && string.contains("\"version\"")
    }

    private static func isValid(_ payload: ClipboardHistoryPayload) -> Bool {
        guard payload.version == currentVersion,
              payload.items.count <= maximumItems,
              payload.items.allSatisfy({ !$0.isEmpty && $0.count <= maximumItemCharacters }) else {
            return false
        }
        return payload.items.reduce(0) { $0 + $1.count } <= maximumTotalCharacters
    }
}

actor LatestSelectionGate {
    private var current = UUID()

    func begin() -> UUID? {
        guard !Task.isCancelled else { return nil }
        current = UUID()
        return current
    }

    func isCurrent(_ token: UUID) -> Bool {
        current == token
    }

    func cancel() {
        current = UUID()
    }
}
