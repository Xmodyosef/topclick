import Foundation
import UIKit
import SwiftUI

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
        // Suite first so extension and container agree (connectors review 2026-10-29).
        if let a = suite.array(forKey: key) as? [String] { return a }
        if let a = UserDefaults.standard.array(forKey: key) as? [String] { return a }
        return nil
    }
}

// MARK: - Special action-key color (one system ColorPicker → all control keys)
// Emoji is intentionally excluded (stays letter/neutral on the board).

enum SpecialKeyColorStore {
    /// Keys that accept a shared accent override. No emoji.
    static let slots = ["shift", "language", "enter", "delete", "symbols", "period"]

    static func storedRGBA(for slot: String) -> String? {
        let key = "specialKey.\(slot)"
        let raw = ThemeStore.string(key) ?? ""
        return raw.isEmpty ? nil : raw
    }

    /// Prefer period/shift sample; fallback Naqra accent blue-ish.
    static func loadUIColor() -> UIColor {
        for slot in slots {
            if let raw = storedRGBA(for: slot) {
                let p = raw.split(separator: ",").compactMap { Double($0) }
                if p.count == 4 {
                    return UIColor(red: p[0], green: p[1], blue: p[2], alpha: p[3])
                }
            }
        }
        return UIColor(red: 0.36, green: 0.60, blue: 1.0, alpha: 1)
    }

    static func loadColor() -> Color { Color(loadUIColor()) }

    static func applyUnified(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return }
        let value = "\(r),\(g),\(b),\(a)"
        for slot in slots {
            ThemeStore.write("specialKey.\(slot)", value: value)
        }
        // Explicitly clear emoji override if any legacy value remains
        ThemeStore.write("specialKey.emoji", value: "")
    }

    /// Back to theme accent (empty slots → NaqraPalette.color uses accent).
    static func clearToThemeAccent() {
        for slot in slots + ["emoji"] {
            ThemeStore.write("specialKey.\(slot)", value: "")
            UserDefaults.standard.removeObject(forKey: "specialKey.\(slot)")
            ThemeStore.suite.removeObject(forKey: "specialKey.\(slot)")
        }
    }

    static var hasCustom: Bool {
        slots.contains { storedRGBA(for: $0) != nil }
    }
}
