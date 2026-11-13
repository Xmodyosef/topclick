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
        // Legacy m1…m20 / e1…e3: exact key RGB and old delta; never pass through solid().
        if isLegacyTheme(id) { return preset(id) }
        return solid(preset(id))
    }

    static func solid(_ p: NaqraPalette) -> NaqraPalette {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard p.key.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return .init(background: p.background.withAlphaComponent(1), key: p.key.withAlphaComponent(1), text: p.text, accent: p.accent, blurDark: p.blurDark)
        }
        // Background slightly darker than keys so rows don't blend into white slabs.
        let bgShift: CGFloat = p.blurDark ? 0.06 : 0.12
        let background = UIColor(
            red: max(0, r - bgShift),
            green: max(0, g - bgShift),
            blue: max(0, b - bgShift),
            alpha: 1
        )
        // Keys fully opaque and a touch lifted on light themes for separation.
        let keyLift: CGFloat = p.blurDark ? 0 : 0.03
        let key = UIColor(
            red: min(1, r + keyLift),
            green: min(1, g + keyLift),
            blue: min(1, b + keyLift),
            alpha: 1
        )
        return .init(background: background, key: key, text: p.text, accent: p.accent, blurDark: p.blurDark)
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


extension NaqraPalette {
    /// Optional per-control colors (#3). When unset, all special keys share `accent` (#1).
    enum SpecialKey: String, CaseIterable {
        case shift, language, enter, delete, emoji, symbols, period
    }

    func color(for special: SpecialKey) -> UIColor {
        if let custom = NaqraPalette.storedColor("specialKey.\(special.rawValue)") {
            return custom
        }
        return accent
    }
}
