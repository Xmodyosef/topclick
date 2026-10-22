import SwiftUI
import Translation
import UIKit
import AudioToolbox

struct NaqraPalette {
    var background: UIColor
    var key: UIColor
    var text: UIColor
    var accent: UIColor
    var blurDark: Bool

    static let order = [
        "auto","light","dark","glass","ocean","cobalt","violet","orchid","hailey","ember","forest","matrix","nord",
        "morning","evening",
        "m1","m2","m3","m4","m5","m6","m7","m8","m9","m10",
        "m11","m12","m13","m14","m15","m16","m17","m18","m19","m20",
        "e1","e2","e3","e4","e5","e6","e7","e8","e9","e10",
        "e11","e12","e13","e14","e15","e16","e17","e18","e19","e20",
        "custom"
    ]
    static let titles = [
        "auto":"تلقائي","light":"فاتح","dark":"داكن","glass":"منشور","ocean":"بحر","cobalt":"كوبالت",
        "violet":"بنفسج","orchid":"أوركيد","hailey":"دم","ember":"جمر","forest":"غابة","matrix":"ماتريكس","nord":"نورد",
        "morning":"صباح","evening":"مساء",
        "m1":"رملي","m2":"قش","m3":"خوخ","m4":"مشمش","m5":"عاج","m6":"حليب","m7":"نعناع","m8":"مريمية",
        "m9":"سماء","m10":"بحيرة","m11":"لافندر","m12":"ورد","m13":"ذهب","m14":"عسل","m15":"زيتون",
        "m16":"طين","m17":"ورق","m18":"ضباب","m19":"مرجان","m20":"فستق",
        "e1":"فحم","e2":"كحلي","e3":"ليل","e4":"حبر","e5":"برقوق","e6":"نبيذ","e7":"غابة","e8":"زمرد",
        "e9":"محيط","e10":"كوبالت ليلي","e11":"جمر","e12":"نحاس","e13":"بنفسج ليلي","e14":"أوركيد ليلي",
        "e15":"رماد","e16":"دخان","e17":"قهوة","e18":"صحراء","e19":"ملكي","e20":"فجر",
        "custom":"مخصص"
    ]

    static func current() -> NaqraPalette {
        let raw = ThemeIO.string("themeId") ?? "auto"
        let id = normalizeThemeId(raw)
        if id == "custom" { return solid(customPalette()) }
        if id == "auto" { return solid(preset(TimeTheme.preferredThemeId())) }
        return solid(preset(id))
    }

    static func solid(_ p: NaqraPalette) -> NaqraPalette {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard p.key.getRed(&r, green: &g, blue: &b, alpha: &a) else { return p }
        let amount: CGFloat = p.blurDark ? 0.05 : 0.08
        let background = UIColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: 1)
        return .init(background: background, key: p.key.withAlphaComponent(1), text: p.text, accent: p.accent, blurDark: p.blurDark)
    }

    static func preset(_ id: String) -> NaqraPalette {
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
        let text: UIColor = dark ? (amber ? UIColor(red: 0.96, green: 0.78, blue: 0.42, alpha: 1) : UIColor(white: 0.94, alpha: 1)) : UIColor(red: 0.22, green: 0.16, blue: 0.10, alpha: 1)
        let accent: UIColor = dark ? UIColor(red: 0.82, green: 0.58, blue: 0.22, alpha: 1) : UIColor(red: 0.72, green: 0.48, blue: 0.22, alpha: 1)
        let amount: CGFloat = dark ? 0.05 : 0.08
        let key = UIColor(red: r, green: g, blue: b, alpha: dark ? 0.88 : 0.90)
        let background = UIColor(red: max(0, r - amount), green: max(0, g - amount), blue: max(0, b - amount), alpha: 1)
        return .init(background: background, key: key, text: text, accent: accent, blurDark: dark)
    }

    static func customPalette() -> NaqraPalette {
        let key = storedColor("customKey") ?? UIColor(white: 1.0, alpha: 0.16)
        let text = storedColor("customText") ?? UIColor(white: 0.96, alpha: 1)
        let accent = storedColor("customAccent") ?? UIColor(red: 0.55, green: 0.62, blue: 0.70, alpha: 1)
        let dark = storedBool("customBlurDark") ?? true
        return .init(background: .clear, key: key, text: text, accent: accent, blurDark: dark)
    }

    static func storedColor(_ key: String) -> UIColor? {
        guard let raw = ThemeIO.string(key) else { return nil }
        let p = raw.split(separator: ",").compactMap { Double($0) }
        guard p.count == 4 else { return nil }
        return UIColor(red: CGFloat(p[0]), green: CGFloat(p[1]), blue: CGFloat(p[2]), alpha: CGFloat(p[3]))
    }

    static func storedBool(_ key: String) -> Bool? { ThemeIO.bool(key) }
    static func saveColor(_ color: UIColor, key: String) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        ThemeIO.write(key, value: "\(r),\(g),\(b),\(a)")
    }
    static func saveTheme(_ id: String) { ThemeIO.write("themeId", value: id) }
    static func normalizeThemeId(_ raw: String) -> String {
        switch raw {
        case "charcoal","smoke","catppuccin_frappe","catppuccin_macchiato": return "dark"
        case "teal": return "ocean"
        case "midnight","midnight_gold","neon_nights","tron","cobalt_night": return "cobalt"
        case "snow","minimal_light","catppuccin_latte": return "light"
        case "clear": return "glass"
        case "matcha": return "m7"
        case "cotton_candy","candy_shop": return "m12"
        case "cherry": return "e5"
        case "cocoa": return "e5"
        case "neon": return "forest"
        case "catppuccin_mocha": return "e2"
        case "dracula": return "violet"
        default: return raw
        }
    }
    static func saveBool(_ value: Bool, key: String) { ThemeIO.write(key, value: value) }
    static func applyHarmony(from base: UIColor) {
        let lum = luminance(base)
        let darkGlass = lum < 0.55
        let text = darkGlass ? UIColor(white: 0.97, alpha: 1) : UIColor(red: 0.16, green: 0.20, blue: 0.26, alpha: 1)
        let accent = relatedAccent(base, dark: darkGlass)
        saveColor(base, key: "customKey")
        saveColor(text, key: "customText")
        saveColor(accent, key: "customAccent")
        saveBool(darkGlass, key: "customBlurDark")
        saveTheme("custom")
    }
    static func luminance(_ color: UIColor) -> CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    static func relatedAccent(_ color: UIColor, dark: Bool) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let ns = min(0.55, max(0.18, s * 0.75))
            let nb = dark ? min(0.86, max(0.55, b + 0.28)) : min(0.62, max(0.38, b * 0.72))
            return UIColor(hue: h, saturation: ns, brightness: nb, alpha: 1)
        }
        return dark ? UIColor(red: 0.55, green: 0.62, blue: 0.70, alpha: 1) : UIColor(red: 0.42, green: 0.58, blue: 0.74, alpha: 1)
    }
}

