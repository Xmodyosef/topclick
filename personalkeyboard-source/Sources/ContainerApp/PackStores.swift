import Foundation

// MARK: - Theme pack install store
//
// Each theme pack installs independently. Applying theme B never uninstalls theme A.
// Free packs are always "installed". Optional packs require one install then free switch.

enum ThemePackStore {
    static let installedKey = "installedThemePacks"
    /// Always available — no download step.
    static let freeIDs: Set<String> = [
        "auto", "morning", "evening", "light", "dark", "glass"
    ]

    static func installedIDs() -> Set<String> {
        var set = freeIDs
        if let arr = ThemeStore.stringArray(installedKey) {
            set.formUnion(arr)
        } else if let arr = UserDefaults.standard.array(forKey: installedKey) as? [String] {
            set.formUnion(arr)
        } else if let arr = ThemeStore.suite.array(forKey: installedKey) as? [String] {
            set.formUnion(arr)
        }
        return set
    }

    static func isInstalled(_ id: String) -> Bool {
        freeIDs.contains(id) || installedIDs().contains(id)
    }

    static func isFree(_ id: String) -> Bool { freeIDs.contains(id) }

    /// Persist install without changing the active theme.
    static func markInstalled(_ id: String) {
        guard !freeIDs.contains(id) else { return }
        var set = installedIDs()
        set.insert(id)
        // Store only non-free ids to keep list small
        let paid = Array(set.subtracting(freeIDs)).sorted()
        ThemeStore.write(installedKey, value: paid)
        UserDefaults.standard.set(paid, forKey: installedKey)
        ThemeStore.suite.set(paid, forKey: installedKey)
    }

    /// Switch active theme. Requires pack to be installed. Does NOT remove other packs.
    @discardableResult
    static func apply(_ id: String) -> Bool {
        guard isInstalled(id) else { return false }
        ThemeStore.write("themeId", value: id)
        ThemeStore.write("themeAppliedAt", value: Date().timeIntervalSince1970)
        UserDefaults(suiteName: ThemeStore.suiteName)?.set(id, forKey: "themeId")
        return true
    }
}

// MARK: - Sound pack install store
//
// Same independence model as themes. Active choice is soundChoice;
// installed packs stay available when switching.

enum SoundPackStore {
    static let installedKey = "installedSoundPacks"
    static let freeIDs: Set<String> = ["system", "none"]

    struct Pack: Identifiable, Hashable {
        let id: String
        let title: String
        let blurb: String
    }

    static let catalog: [Pack] = [
        .init(id: "system", title: "النظام", blurb: "نقرة iOS الافتراضية"),
        .init(id: "creamy", title: "كريمي", blurb: "نغمات دافئة"),
        .init(id: "thocky", title: "ثوكي", blurb: "عمق منخفض"),
        .init(id: "soft", title: "ناعم", blurb: "خفيف وهادئ"),
        .init(id: "typewriter", title: "آلة كاتبة", blurb: "طقطقة حادة"),
        .init(id: "none", title: "صامت", blurb: "بدون صوت")
    ]

    static func installedIDs() -> Set<String> {
        var set = freeIDs
        if let arr = ThemeStore.stringArray(installedKey) {
            set.formUnion(arr)
        } else if let arr = UserDefaults.standard.array(forKey: installedKey) as? [String] {
            set.formUnion(arr)
        } else if let arr = ThemeStore.suite.array(forKey: installedKey) as? [String] {
            set.formUnion(arr)
        }
        return set
    }

    static func isInstalled(_ id: String) -> Bool {
        freeIDs.contains(id) || installedIDs().contains(id)
    }

    static func isFree(_ id: String) -> Bool { freeIDs.contains(id) }

    static func markInstalled(_ id: String) {
        guard !freeIDs.contains(id) else { return }
        var set = installedIDs()
        set.insert(id)
        let paid = Array(set.subtracting(freeIDs)).sorted()
        ThemeStore.write(installedKey, value: paid)
        UserDefaults.standard.set(paid, forKey: installedKey)
        ThemeStore.suite.set(paid, forKey: installedKey)
    }

    /// Apply sound pack. Independent of which other packs are installed.
    @discardableResult
    static func apply(_ id: String) -> Bool {
        guard isInstalled(id) else { return false }
        ThemeStore.write("soundChoice", value: id)
        ThemeStore.write("sounds", value: id != "none")
        return true
    }
}

// MARK: - ThemeStore helpers for arrays

extension ThemeStore {
    static func stringArray(_ key: String) -> [String]? {
        if let a = UserDefaults.standard.array(forKey: key) as? [String] { return a }
        if let a = suite.array(forKey: key) as? [String] { return a }
        return nil
    }
}
