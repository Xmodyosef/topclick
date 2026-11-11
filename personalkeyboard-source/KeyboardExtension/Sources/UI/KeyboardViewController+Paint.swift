import UIKit

// MARK: - KeyboardViewController + Paint
extension KeyboardViewController {
    func paint(_ b: UIButton, chrome: KeyChrome = .letter, emphasized: Bool = false) {
        // Action keys take accent/special colors. Emoji stays neutral (letter-like).
        let action: Set<KeyChrome> = [.shift, .language, .symbols, .enter, .danger, .period]
        let isAction = action.contains(chrome)
        let bg: UIColor
        let fg: UIColor
        if chrome == .letter || chrome == .emoji {
            bg = palette.key.withAlphaComponent(1)
            fg = palette.text
        } else if chrome == .control {
            bg = mix(palette.key, palette.background, t: 0.28)
            fg = palette.text.withAlphaComponent(0.92)
        } else if isAction {
            let special: NaqraPalette.SpecialKey
            switch chrome {
            case .shift: special = .shift
            case .language: special = .language
            case .enter: special = .enter
            case .danger: special = .delete
            case .symbols: special = .symbols
            case .period: special = .period
            default: special = .symbols
            }
            bg = palette.color(for: special)
            fg = .white
        } else {
            bg = palette.key
            fg = palette.text
        }
        b.backgroundColor = bg
        b.setTitleColor(fg, for: .normal)
        b.tintColor = fg
        b.layer.cornerRadius = 8
        b.layer.cornerCurve = .continuous
        b.layer.borderWidth = isAction ? 1.0 : (palette.blurDark ? 0.5 : 0.8)
        b.layer.borderColor = (isAction
            ? UIColor.white.withAlphaComponent(0.28)
            : (palette.blurDark ? UIColor.white.withAlphaComponent(0.16) : UIColor.black.withAlphaComponent(0.12))
        ).cgColor
        b.layer.shadowOpacity = 0
        b.clipsToBounds = true
        b.isOpaque = true
        b.isAccessibilityElement = true
        b.accessibilityTraits = .button
        if (b.accessibilityLabel == nil || b.accessibilityLabel?.isEmpty == true),
           let title = b.title(for: .normal), !title.isEmpty {
            b.accessibilityLabel = title
        }
        _ = emphasized
    }

    /// Linear mix of two colors (t = amount of `b`).
    func mix(_ a: UIColor, _ b: UIColor, t: CGFloat) -> UIColor {
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        let u = min(1, max(0, t))
        return UIColor(
            red: ar * (1 - u) + br * u,
            green: ag * (1 - u) + bg * u,
            blue: ab * (1 - u) + bb * u,
            alpha: 1
        )
    }

    func iconKey(_ name: String, _ a: Selector, chrome: KeyChrome = .control) -> UIButton {
        let b = UIButton(type: .system)
        let symbol = UIImage(systemName: name, withConfiguration: iconConfig)
            ?? UIImage(systemName: fallbackSymbol(name), withConfiguration: iconConfig)
        b.setImage(symbol, for: .normal)
        let resolved: KeyChrome
        if name.contains("shift") {
            resolved = .shift
        } else if name.contains("arrow.down") {
            resolved = .enter
        } else if name.contains("delete") {
            resolved = .danger
        } else {
            resolved = chrome
        }
        paint(b, chrome: resolved, emphasized: name.contains("shift.fill") && isShifted)
        b.addTarget(self, action: a, for: .touchUpInside)
        return b
    }
}
