import Foundation

/// Diagnostic-only stamp. Does not read or write theme colors.
enum NaqraBuildStamp {
    /// Short commit injected by CI into Info.plist (`NaqraGitSHA`). `dev` locally.
    static var short: String {
        let raw = Bundle.main.object(forInfoDictionaryKey: "NaqraGitSHA") as? String
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmed.isEmpty || trimmed.hasPrefix("$(") { return "dev" }
        return String(trimmed.prefix(7))
    }
}

/// On unless the user explicitly sets UserDefaults `themeTrace` to 0 / false.
/// Default-on so a Release sideload IPA shows the strips without a Mac console.
enum ThemeTrace {
    static var isEnabled: Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "themeTrace") == nil { return true }
        if let number = defaults.object(forKey: "themeTrace") as? NSNumber {
            return number.boolValue
        }
        if let text = defaults.string(forKey: "themeTrace") {
            let lowered = text.lowercased()
            return lowered != "0" && lowered != "false" && lowered != "off"
        }
        return true
    }
}
