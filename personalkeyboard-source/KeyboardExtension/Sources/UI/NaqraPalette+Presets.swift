import UIKit

// MARK: - NaqraPalette presets
extension NaqraPalette {
    /// Exact key colors from the shipping old app (m1…m20 light, e1…e3 dark).
    /// Painted with the old formula: key = RGB, background = RGB − (dark ? 0.05 : 0.08).
    static var legacyRGB: [String: (CGFloat, CGFloat, CGFloat, Bool)] {
        var out: [String: (CGFloat, CGFloat, CGFloat, Bool)] = [:]
        for (id, row) in SharedThemeCatalog.legacyRGB {
            out[id] = (CGFloat(row.0), CGFloat(row.1), CGFloat(row.2), row.3)
        }
        return out
    }

    static func isLegacyTheme(_ id: String) -> Bool {
        legacyRGB[id] != nil
    }

    /// Old app paint path — key stays raw; background uses the historical delta only once.
    static func legacyPalette(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, dark: Bool) -> NaqraPalette {
        let delta: CGFloat = dark ? 0.05 : 0.08
        let key = UIColor(red: r, green: g, blue: b, alpha: 1)
        let background = UIColor(
            red: max(0, r - delta),
            green: max(0, g - delta),
            blue: max(0, b - delta),
            alpha: 1
        )
        // Readable ink/accent derived from the same base (old snippet had no separate text RGB).
        let text: UIColor
        let accent: UIColor
        if dark {
            text = UIColor(white: 0.96, alpha: 1)
            accent = UIColor(
                red: min(1, r + 0.35),
                green: min(1, g + 0.30),
                blue: min(1, b + 0.40),
                alpha: 1
            )
        } else {
            text = UIColor(red: max(0, r - 0.55), green: max(0, g - 0.55), blue: max(0, b - 0.50), alpha: 1)
            accent = UIColor(
                red: max(0.2, r - 0.25),
                green: max(0.15, g - 0.30),
                blue: max(0.1, b - 0.20),
                alpha: 1
            )
        }
        return .init(background: background, key: key, text: text, accent: accent, blurDark: dark)
    }

    static func preset(_ id: String) -> NaqraPalette {
        if let (r, g, b, dark) = legacyRGB[id] {
            return legacyPalette(r, g, b, dark: dark)
        }
        switch id {
        case "dark": return .init(background: .clear, key: UIColor(red: 0.10, green: 0.16, blue: 0.28, alpha: 0.62), text: UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1), accent: UIColor(red: 0.36, green: 0.60, blue: 1.0, alpha: 1), blurDark: true)
        case "light": return .init(background: .clear, key: UIColor(red: 0.90, green: 0.95, blue: 0.99, alpha: 0.82), text: UIColor(red: 0.14, green: 0.27, blue: 0.40, alpha: 1), accent: UIColor(red: 0.28, green: 0.52, blue: 0.86, alpha: 1), blurDark: false)
        case "glass": return .init(background: .clear, key: UIColor(red: 0.86, green: 0.82, blue: 0.96, alpha: 0.38), text: UIColor(red: 0.18, green: 0.16, blue: 0.28, alpha: 1), accent: UIColor(red: 0.62, green: 0.42, blue: 0.88, alpha: 1), blurDark: false)
        case "ocean": return .init(background: .clear, key: UIColor(red: 0.06, green: 0.22, blue: 0.32, alpha: 0.55), text: UIColor(red: 0.62, green: 0.96, blue: 0.98, alpha: 1), accent: UIColor(red: 0.16, green: 0.78, blue: 0.84, alpha: 1), blurDark: true)
        case "cobalt": return .init(background: .clear, key: UIColor(red: 0.10, green: 0.18, blue: 0.42, alpha: 0.62), text: UIColor(red: 0.82, green: 0.90, blue: 1.0, alpha: 1), accent: UIColor(red: 0.32, green: 0.56, blue: 1.0, alpha: 1), blurDark: true)
        case "violet": return .init(background: .clear, key: UIColor(red: 0.18, green: 0.10, blue: 0.32, alpha: 0.50), text: UIColor(red: 0.90, green: 0.78, blue: 1.0, alpha: 1), accent: UIColor(red: 0.70, green: 0.42, blue: 1.0, alpha: 1), blurDark: true)
        case "orchid": return .init(background: .clear, key: UIColor(red: 0.32, green: 0.08, blue: 0.18, alpha: 0.58), text: UIColor(red: 1.0, green: 0.78, blue: 0.86, alpha: 1), accent: UIColor(red: 0.92, green: 0.32, blue: 0.52, alpha: 1), blurDark: true)
        case "hailey": return .init(background: .clear, key: UIColor(red: 0.22, green: 0.05, blue: 0.08, alpha: 0.58), text: UIColor(red: 1.0, green: 0.78, blue: 0.80, alpha: 1), accent: UIColor(red: 0.86, green: 0.16, blue: 0.22, alpha: 1), blurDark: true)
        case "ember": return .init(background: .clear, key: UIColor(red: 0.24, green: 0.12, blue: 0.05, alpha: 0.58), text: UIColor(red: 1.0, green: 0.84, blue: 0.58, alpha: 1), accent: UIColor(red: 0.96, green: 0.50, blue: 0.18, alpha: 1), blurDark: true)
        case "forest": return .init(background: .clear, key: UIColor(red: 0.06, green: 0.18, blue: 0.12, alpha: 0.58), text: UIColor(red: 0.70, green: 0.96, blue: 0.76, alpha: 1), accent: UIColor(red: 0.22, green: 0.78, blue: 0.42, alpha: 1), blurDark: true)
        case "matrix": return .init(background: .clear, key: UIColor(red: 0.02, green: 0.07, blue: 0.03, alpha: 0.62), text: UIColor(red: 0.28, green: 0.98, blue: 0.36, alpha: 1), accent: UIColor(red: 0.12, green: 0.78, blue: 0.22, alpha: 1), blurDark: true)
        case "nord": return .init(background: .clear, key: UIColor(red: 0.78, green: 0.82, blue: 0.86, alpha: 0.72), text: UIColor(red: 0.16, green: 0.20, blue: 0.26, alpha: 1), accent: UIColor(red: 0.36, green: 0.56, blue: 0.70, alpha: 1), blurDark: false)
        // morning / evening stay on the modern tone path (not in the legacy table).
        case "morning": return Self.tone(0.96, 0.90, 0.78, dark: false)
        case "evening": return Self.tone(0.08, 0.12, 0.24, dark: true, amber: true)
        case "e4": return Self.tone(0.10, 0.12, 0.18, dark: true)
        case "e5": return Self.tone(0.18, 0.10, 0.22, dark: true)
        case "e6": return Self.tone(0.24, 0.08, 0.14, dark: true)
        case "e7": return Self.tone(0.08, 0.16, 0.12, dark: true)
        case "e8": return Self.tone(0.06, 0.18, 0.16, dark: true)
        case "e9": return Self.tone(0.06, 0.14, 0.22, dark: true)
        case "e10": return Self.tone(0.10, 0.16, 0.32, dark: true)
        case "e11": return Self.tone(0.22, 0.10, 0.08, dark: true, amber: true)
        case "e12": return Self.tone(0.28, 0.16, 0.10, dark: true, amber: true)
        case "e13": return Self.tone(0.16, 0.10, 0.28, dark: true)
        case "e14": return Self.tone(0.26, 0.08, 0.18, dark: true)
        case "e15": return Self.tone(0.16, 0.18, 0.22, dark: true)
        case "e16": return Self.tone(0.14, 0.14, 0.16, dark: true)
        case "e17": return Self.tone(0.18, 0.12, 0.08, dark: true, amber: true)
        case "e18": return Self.tone(0.20, 0.14, 0.10, dark: true, amber: true)
        case "e19": return Self.tone(0.12, 0.08, 0.20, dark: true)
        case "e20": return Self.tone(0.18, 0.10, 0.12, dark: true, amber: true)
        case "aurora": return Self.tone(0.10, 0.28, 0.30, dark: true)
        case "lavender": return Self.tone(0.28, 0.20, 0.42, dark: true)
        case "sunset": return Self.tone(0.38, 0.14, 0.16, dark: true, amber: true)
        case "mint": return Self.tone(0.08, 0.24, 0.22, dark: true)
        case "rose": return Self.tone(0.36, 0.12, 0.24, dark: true)
        case "mono": return Self.tone(0.22, 0.23, 0.25, dark: true)
        default: return .init(background: .clear, key: UIColor(red: 0.10, green: 0.16, blue: 0.28, alpha: 0.62), text: UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1), accent: UIColor(red: 0.36, green: 0.60, blue: 1.0, alpha: 1), blurDark: true)
        }
    }

    static func tone(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, dark: Bool, amber: Bool = false) -> NaqraPalette {
        // Text color derived from the key hue so themes are visibly different (not one shared amber).
        let base = UIColor(red: r, green: g, blue: b, alpha: 1)
        var h: CGFloat = 0, s: CGFloat = 0, br: CGFloat = 0, a: CGFloat = 0
        let ok = base.getHue(&h, saturation: &s, brightness: &br, alpha: &a)
        let accent: UIColor
        if amber {
            accent = UIColor(red: 0.96, green: 0.72, blue: 0.28, alpha: 1)
        } else if ok {
            let ns = min(0.75, max(0.35, s + 0.25))
            let nb = dark ? min(0.95, max(0.55, br + 0.35)) : min(0.65, max(0.40, br * 0.75))
            accent = UIColor(hue: h, saturation: ns, brightness: nb, alpha: 1)
        } else {
            accent = dark ? UIColor(red: 0.55, green: 0.70, blue: 1.0, alpha: 1) : UIColor(red: 0.30, green: 0.50, blue: 0.85, alpha: 1)
        }
        let text: UIColor
        if dark {
            text = amber
                ? UIColor(red: 0.98, green: 0.86, blue: 0.55, alpha: 1)
                : UIColor(white: 0.96, alpha: 1)
        } else {
            text = UIColor(red: max(0, r - 0.55), green: max(0, g - 0.55), blue: max(0, b - 0.50), alpha: 1)
        }
        let amount: CGFloat = dark ? 0.07 : 0.10
        let key = UIColor(red: r, green: g, blue: b, alpha: 1)
        let background = UIColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: 1)
        return .init(background: background, key: key, text: text, accent: accent, blurDark: dark)
    }
}
