import UIKit

// MARK: - NaqraPalette presets
extension NaqraPalette {
    /// Key RGB copied from ThemeCatalog.rgb so every app tile paints the same color.
    static let catalogRGB: [String: (CGFloat, CGFloat, CGFloat, Bool)] = [
        "auto": (0.16, 0.18, 0.23, true),
        "light": (0.90, 0.95, 0.99, false),
        "dark": (0.10, 0.16, 0.28, true),
        "glass": (0.86, 0.82, 0.96, false),
        "ocean": (0.06, 0.22, 0.32, true),
        "cobalt": (0.10, 0.18, 0.42, true),
        "violet": (0.18, 0.10, 0.32, true),
        "orchid": (0.32, 0.08, 0.18, true),
        "hailey": (0.22, 0.05, 0.08, true),
        "ember": (0.24, 0.12, 0.05, true),
        "forest": (0.06, 0.18, 0.12, true),
        "matrix": (0.02, 0.07, 0.03, true),
        "nord": (0.78, 0.82, 0.86, false),
        "morning": (0.96, 0.90, 0.78, false),
        "evening": (0.08, 0.12, 0.24, true),
        "m4": (0.97, 0.82, 0.64, false),
        "m7": (0.84, 0.93, 0.88, false),
        "m9": (0.78, 0.88, 0.96, false),
        "m12": (0.96, 0.86, 0.90, false),
        "e2": (0.08, 0.12, 0.24, true),
        "e5": (0.18, 0.10, 0.22, true),
        "e8": (0.06, 0.18, 0.16, true),
        "e11": (0.22, 0.10, 0.08, true),
        "aurora": (0.10, 0.28, 0.30, true),
        "lavender": (0.28, 0.20, 0.42, true),
        "sunset": (0.38, 0.14, 0.16, true),
        "mint": (0.08, 0.24, 0.22, true),
        "rose": (0.36, 0.12, 0.24, true),
        "mono": (0.22, 0.23, 0.25, true)
    ]

    static func preset(_ id: String) -> NaqraPalette {
        if let (r, g, b, dark) = catalogRGB[id] {
            return catalogMatch(r, g, b, dark: dark)
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
        case "morning","m1": return Self.tone(0.96, 0.90, 0.78, dark: false)
        case "m2": return Self.tone(0.94, 0.89, 0.72, dark: false)
        case "m3": return Self.tone(0.98, 0.86, 0.76, dark: false)
        case "m4": return Self.tone(0.97, 0.82, 0.64, dark: false)
        case "m5": return Self.tone(0.96, 0.94, 0.88, dark: false)
        case "m6": return Self.tone(0.93, 0.94, 0.96, dark: false)
        case "m7": return Self.tone(0.84, 0.93, 0.88, dark: false)
        case "m8": return Self.tone(0.78, 0.86, 0.76, dark: false)
        case "m9": return Self.tone(0.78, 0.88, 0.96, dark: false)
        case "m10": return Self.tone(0.72, 0.86, 0.90, dark: false)
        case "m11": return Self.tone(0.90, 0.86, 0.96, dark: false)
        case "m12": return Self.tone(0.96, 0.86, 0.90, dark: false)
        case "m13": return Self.tone(0.93, 0.86, 0.68, dark: false)
        case "m14": return Self.tone(0.92, 0.78, 0.52, dark: false)
        case "m15": return Self.tone(0.82, 0.84, 0.68, dark: false)
        case "m16": return Self.tone(0.86, 0.74, 0.62, dark: false)
        case "m17": return Self.tone(0.95, 0.93, 0.89, dark: false)
        case "m18": return Self.tone(0.86, 0.88, 0.90, dark: false)
        case "m19": return Self.tone(0.96, 0.78, 0.74, dark: false)
        case "m20": return Self.tone(0.80, 0.90, 0.78, dark: false)
        case "evening","e2": return Self.tone(0.08, 0.12, 0.24, dark: true, amber: true)
        case "e1": return Self.tone(0.22, 0.23, 0.26, dark: true)
        case "e3": return Self.tone(0.07, 0.09, 0.16, dark: true, amber: true)
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

    /// Same ink and accent math as ThemeCatalog.make, so the keyboard matches the app tile.
    static func catalogMatch(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, dark: Bool) -> NaqraPalette {
        let text: UIColor = dark
            ? UIColor(red: min(1, r + 0.75), green: min(1, g + 0.75), blue: min(1, b + 0.78), alpha: 1)
            : UIColor(red: max(0, r - 0.55), green: max(0, g - 0.55), blue: max(0, b - 0.50), alpha: 1)
        let accent: UIColor = dark
            ? UIColor(red: min(1, r + 0.35), green: min(1, g + 0.25), blue: min(1, b + 0.15), alpha: 1)
            : UIColor(red: max(0.2, r - 0.25), green: max(0.15, g - 0.30), blue: max(0.1, b - 0.20), alpha: 1)
        let key = UIColor(red: r, green: g, blue: b, alpha: 1)
        let shift: CGFloat = dark ? 0.06 : 0.12
        let background = UIColor(red: max(0, r - shift), green: max(0, g - shift), blue: max(0, b - shift), alpha: 1)
        return .init(background: background, key: key, text: text, accent: accent, blurDark: dark)
    }
