import Foundation

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
        // Disable capture by default, but preserve pre-existing bytes untouched.
        ThemeIO.set("clipboardHistoryEnabled", value: false)
        // Migration runs only after the user explicitly enables clipboard history.
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
        while list.reduce(0, { $0 + $1.count }) > ClipboardHistoryCodec.maximumTotalCharacters {
            list.removeLast()
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
        let hasBackup = ThemeIO.suite.object(forKey: backupKey) != nil
            || UserDefaults.standard.object(forKey: backupKey) != nil
        guard hasBackup,
              let deleteAfter = ThemeIO.suite.object(forKey: backupDeleteAfterKey) as? Double,
              Date().timeIntervalSince1970 >= deleteAfter,
              let raw = ThemeIO.string(key),
              ClipboardHistoryCodec.decode(raw) != nil else {
            return
        }

        ThemeIO.suite.removeObject(forKey: backupKey)
        UserDefaults.standard.removeObject(forKey: backupKey)
        // Keep migration metadata as an audit trail and record the backup deletion time.
        let deletedAt = Date().timeIntervalSince1970
        ThemeIO.set("clipboardHistory.backupDeletedAt", value: deletedAt)
    }
}
