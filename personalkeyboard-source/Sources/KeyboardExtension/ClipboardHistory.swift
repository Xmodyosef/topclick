import Foundation

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

    /// The legacy U+001F format cannot recover a separator that was already embedded in an item.
    static func decodeLegacy(_ string: String) -> [String] {
        string.split(separator: "\u{1F}").map(String.init)
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

final class ClipboardHistory {
    static let shared = ClipboardHistory()

    private let key = "clipboardHistory"
    private let backupKey = "clipboardHistory.legacyBackup"
    private let migrationSucceededAtKey = "clipboardHistory.migrationSucceededAt"
    private let backupDeleteAfterKey = "clipboardHistory.backupDeleteAfter"
    private let backupRetention: TimeInterval = 7 * 24 * 60 * 60

    var items: [String] {
        guard ThemeIO.bool("clipboardHistoryEnabled") ?? false else { return [] }
        let stored = loadOrMigrate()
        deleteExpiredBackupIfSafe()
        return stored
    }

    func ensurePrivacyDefault() {
        guard ThemeIO.bool("clipboardHistoryEnabled") == nil else {
            deleteExpiredBackupIfSafe()
            return
        }
        ThemeIO.set("clipboardHistoryEnabled", value: false)
        ThemeIO.set(key, value: "")
    }

    func clear() {
        save([])
    }

    func add(_ text: String) {
        guard ThemeIO.bool("clipboardHistoryEnabled") ?? false,
              !text.isEmpty,
              text.count <= ClipboardHistoryCodec.maximumItemCharacters else {
            return
        }
        var list = items
        list.removeAll { $0 == text }
        list.insert(text, at: 0)
        if list.count > ClipboardHistoryCodec.maximumItems {
            list = Array(list.prefix(ClipboardHistoryCodec.maximumItems))
        }
        save(list)
    }

    private func loadOrMigrate() -> [String] {
        guard let raw = ThemeIO.string(key) else { return [] }
        if let decoded = ClipboardHistoryCodec.decode(raw) { return decoded }
        // Do not overwrite a damaged versioned document; the backup may be the only recovery path.
        guard !ClipboardHistoryCodec.looksLikeVersionedJSON(raw) else { return [] }

        let legacyItems = ClipboardHistoryCodec.decodeLegacy(raw)
        guard let encoded = ClipboardHistoryCodec.encode(legacyItems) else { return legacyItems }

        // Preserve the exact old bytes before replacing the old delimiter format.
        ThemeIO.set(backupKey, value: raw)
        ThemeIO.set(key, value: encoded)

        guard let verified = ThemeIO.string(key).flatMap(ClipboardHistoryCodec.decode),
              verified == legacyItems else {
            ThemeIO.set(key, value: raw)
            return legacyItems
        }

        let now = Date().timeIntervalSince1970
        ThemeIO.set(migrationSucceededAtKey, value: now)
        ThemeIO.set(backupDeleteAfterKey, value: now + backupRetention)
        return verified
    }

    private func save(_ items: [String]) {
        guard let encoded = ClipboardHistoryCodec.encode(items) else { return }
        let previous = ThemeIO.string(key)
        ThemeIO.set(key, value: encoded)
        guard ThemeIO.string(key).flatMap(ClipboardHistoryCodec.decode) == items else {
            ThemeIO.set(key, value: previous ?? "")
            return
        }
    }

    private func deleteExpiredBackupIfSafe() {
        guard let deleteAfter = ThemeIO.suite.object(forKey: backupDeleteAfterKey) as? Double,
              Date().timeIntervalSince1970 >= deleteAfter,
              let raw = ThemeIO.string(key),
              ClipboardHistoryCodec.decode(raw) != nil else {
            return
        }

        ThemeIO.suite.removeObject(forKey: backupKey)
        UserDefaults.standard.removeObject(forKey: backupKey)
        ThemeIO.suite.removeObject(forKey: migrationSucceededAtKey)
        UserDefaults.standard.removeObject(forKey: migrationSucceededAtKey)
        ThemeIO.suite.removeObject(forKey: backupDeleteAfterKey)
        UserDefaults.standard.removeObject(forKey: backupDeleteAfterKey)
    }
}
