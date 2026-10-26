import Foundation

// MARK: - Pref keys for content packs (app-owned install state)
//
// Architecture (team placement):
// - ContainerApp owns install UX + installed* lists (PackStores).
// - KeyboardExtension only reads active keys via ThemeIO:
//     themeId, soundChoice, sounds, showNumberRow, specialKey.*
// - Applying pack B never uninstalls pack A.

enum ContentPackKeys {
    static let installedThemes = "installedThemePacks"
    static let installedSounds = "installedSoundPacks"
    static let themeId = "themeId"
    static let themeAppliedAt = "themeAppliedAt"
    static let soundChoice = "soundChoice"
    static let sounds = "sounds"
}

// MARK: - Generic install set (non-free IDs only persisted)

private enum PackInstallBook {
    static func installed(free: Set<String>, key: String) -> Set<String> {
        var set = free
        if let arr = ThemeStore.stringArray(key) {
            set.formUnion(arr)
        }
        return set
    }

    static func markInstalled(_ id: String, free: Set<String>, key: String) {
        guard !free.contains(id) else { return }
        var set = installed(free: free, key: key)
        set.insert(id)
        let paid = Array(set.subtracting(free)).sorted()
        // One dual-write path only (standard + App Group + Darwin).
        ThemeStore.write(key, value: paid)
    }
}

// MARK: - Theme packs

enum ThemePackStore {
    /// Always unlocked — no download step.
    static let freeIDs: Set<String> = [
        "auto", "morning", "evening", "light", "dark", "glass"
    ]

    static func isFree(_ id: String) -> Bool { freeIDs.contains(id) }

    static func isInstalled(_ id: String) -> Bool {
        PackInstallBook.installed(free: freeIDs, key: ContentPackKeys.installedThemes).contains(id)
    }

    /// Persist install only — does not change active theme.
    static func markInstalled(_ id: String) {
        PackInstallBook.markInstalled(id, free: freeIDs, key: ContentPackKeys.installedThemes)
    }

    /// Switch active theme. Other installed packs stay.
    @discardableResult
    static func apply(_ id: String) -> Bool {
        guard isInstalled(id) else { return false }
        ThemeStore.write(ContentPackKeys.themeId, value: id)
        ThemeStore.write(ContentPackKeys.themeAppliedAt, value: Date().timeIntervalSince1970)
        return true
    }
}

// MARK: - Sound packs (catalog lives with install store — engine has frequencies only)

enum SoundPackStore {
    static let freeIDs: Set<String> = ["system", "none"]

    struct Pack: Identifiable, Hashable {
        let id: String
        let title: String
        let blurb: String
    }

    /// Single source of truth for sound IDs shown in the app.
    /// Must stay aligned with TapSoundEngine.customFrequencies keys.
    static let catalog: [Pack] = [
        .init(id: "system", title: "النظام", blurb: "نقرة iOS الافتراضية"),
        .init(id: "creamy", title: "كريمي", blurb: "نغمات دافئة"),
        .init(id: "thocky", title: "ثوكي", blurb: "عمق منخفض"),
        .init(id: "soft", title: "ناعم", blurb: "خفيف وهادئ"),
        .init(id: "typewriter", title: "آلة كاتبة", blurb: "طقطقة حادة"),
        .init(id: "none", title: "صامت", blurb: "بدون صوت")
    ]

    static var knownIDs: Set<String> { Set(catalog.map(\.id)) }

    static func title(for id: String) -> String {
        catalog.first(where: { $0.id == id })?.title ?? id
    }

    static func isFree(_ id: String) -> Bool { freeIDs.contains(id) }

    static func isInstalled(_ id: String) -> Bool {
        PackInstallBook.installed(free: freeIDs, key: ContentPackKeys.installedSounds).contains(id)
    }

    static func markInstalled(_ id: String) {
        PackInstallBook.markInstalled(id, free: freeIDs, key: ContentPackKeys.installedSounds)
    }

    /// Apply sound. Other installed packs stay.
    @discardableResult
    static func apply(_ id: String) -> Bool {
        guard knownIDs.contains(id), isInstalled(id) else { return false }
        ThemeStore.write(ContentPackKeys.soundChoice, value: id)
        ThemeStore.write(ContentPackKeys.sounds, value: id != "none")
        return true
    }

    /// Master mute/unmute without losing last non-none choice.
    static func setEnabled(_ enabled: Bool) {
        if enabled {
            let current = ThemeStore.string(ContentPackKeys.soundChoice) ?? "system"
            let next = (current == "none") ? "system" : current
            if isInstalled(next) {
                apply(next)
            } else {
                apply("system")
            }
        } else {
            apply("none")
        }
    }
}

// MARK: - ThemeStore array helper

extension ThemeStore {
    static func stringArray(_ key: String) -> [String]? {
        if let a = UserDefaults.standard.array(forKey: key) as? [String] { return a }
        if let a = suite.array(forKey: key) as? [String] { return a }
        return nil
    }
}
