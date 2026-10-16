import SwiftUI
import Translation
import UIKit
import AudioToolbox

// Official system click (lightest, respects system mute)


enum KeyboardLanguage { case arabic, english }

enum ThemeIO {
    static let group = "group.app.personal.PersonalKeyboard"
    static var suite: UserDefaults { UserDefaults(suiteName: group) ?? .standard }
    static var fileURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?
            .appendingPathComponent("naqra-prefs.json")
    }
    static func fileDict() -> [String: Any] {
        guard let url = fileURL, let data = try? Data(contentsOf: url),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
        return obj
    }
    static let boardName = UIPasteboard.Name("group.app.personal.PersonalKeyboard")
    static func write(_ key: String, value: Any) {
        suite.set(value, forKey: key)
        UserDefaults.standard.set(value, forKey: key)
        suite.synchronize()
        UserDefaults.standard.synchronize()
        var d = fileDict()
        d[key] = value
        if let url = fileURL, let data = try? JSONSerialization.data(withJSONObject: d, options: []) {
            try? data.write(to: url, options: .atomic)
        }
        if let text = value as? String, key == "themeId" {
            let pb = UIPasteboard(name: boardName, create: true)
            pb?.string = "naqra|themeId|" + text
        }
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName("app.personal.PersonalKeyboard.prefs" as CFString), nil, nil, true)
    }
    static func string(_ key: String) -> String? {
        if let v = fileDict()[key] as? String { return v }
        if let v = suite.string(forKey: key) { return v }
        if let v = UserDefaults.standard.string(forKey: key) { return v }
        if key == "themeId",
           let raw = UIPasteboard(name: boardName, create: false)?.string,
           raw.hasPrefix("naqra|themeId|") {
            return String(raw.dropFirst("naqra|themeId|".count))
        }
        return nil
    }
    static func bool(_ key: String) -> Bool? {
        if let v = fileDict()[key] as? Bool { return v }
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
        return nil
    }
}

enum KeyboardPage { case letters, symbols, emoji }
