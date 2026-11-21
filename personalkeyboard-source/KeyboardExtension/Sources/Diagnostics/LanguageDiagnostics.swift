import Darwin
import UIKit

/// One language-path variable at a time. Default is the current in-place path.
enum LanguagePathMode: String {
    case baseline
    case systemFont
    case rebuild

    var title: String {
        switch self {
        case .baseline: return "الحالي"
        case .systemFont: return "خط النظام"
        case .rebuild: return "إعادة بناء"
        }
    }

    var next: LanguagePathMode {
        switch self {
        case .baseline: return .rebuild
        case .rebuild: return .systemFont
        case .systemFont: return .baseline
        }
    }
}

/// In-keyboard footprint report. Samples this process only. Not a Jetsam log.
enum LanguageDiagnostics {
    private static let modeKey = "naqra.diag.languageMode"
    private static var peak: UInt64 = 0
    private static var surfaceCount = 0
    private static var remountCount = 0
    private static var rebuildCount = 0
    private static var themeCount = 0
    private static var lastLines: [String] = []

    static var mode: LanguagePathMode {
        get {
            let raw = UserDefaults.standard.string(forKey: modeKey) ?? LanguagePathMode.baseline.rawValue
            return LanguagePathMode(rawValue: raw) ?? .baseline
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: modeKey)
            KeyboardTypography.plainSystemFontForArabic = (newValue == .systemFont)
            KeyboardTypography.clearFontCache()
        }
    }

    static func syncFontFlag() {
        KeyboardTypography.plainSystemFontForArabic = (mode == .systemFont)
    }

    static func begin() -> UInt64 {
        footprint()
    }

    static func mark(_ kind: String, before: UInt64) {
        switch kind {
        case "surface": surfaceCount += 1
        case "remount": remountCount += 1
        case "rebuild": rebuildCount += 1
        case "theme": themeCount += 1
        default: break
        }
        let after = footprint()
        if after > peak { peak = after }
        let line = "\(kind) \(mib(before))→\(mib(after))"
        lastLines.append(line)
        if lastLines.count > 6 { lastLines.removeFirst(lastLines.count - 6) }
        NSLog("[Naqra.Mem] %@ mode=%@", line, mode.rawValue)
    }

    static func resetCounts() {
        peak = footprint()
        surfaceCount = 0
        remountCount = 0
        rebuildCount = 0
        themeCount = 0
        lastLines.removeAll()
    }

    static func report() -> String {
        let now = footprint()
        if now > peak { peak = now }
        let recent = lastLines.isEmpty ? "—" : lastLines.joined(separator: "\n")
        return """
        نقرة ذاكرة
        mode \(mode.title)
        footprint \(mib(now)) MiB
        peak \(mib(peak)) MiB
        available \(mib(os_proc_available_memory())) MiB
        surface \(surfaceCount) · remount \(remountCount) · rebuild \(rebuildCount) · theme \(themeCount)
        \(recent)
        """
    }

    static func oneLine() -> String {
        report().replacingOccurrences(of: "\n", with: " | ")
    }

    private static func mib(_ bytes: UInt64) -> String {
        String(format: "%.1f", Double(bytes) / 1_048_576)
    }

    private static func footprint() -> UInt64 {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.stride / MemoryLayout<integer_t>.stride)
        let result = withUnsafeMutablePointer(to: &info) { pointer -> kern_return_t in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), rebound, &count)
            }
        }
        if result == KERN_SUCCESS {
            return info.phys_footprint
        }
        return 0
    }
}
