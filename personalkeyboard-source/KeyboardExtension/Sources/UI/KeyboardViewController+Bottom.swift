import UIKit

// MARK: - KeyboardViewController + Bottom bar
extension KeyboardViewController {
    /// Fixed width ladder for a balanced iOS-like bottom row (height 44).
    private enum BottomWidth {
        static let side: CGFloat = 40
        static let globe: CGFloat = 36
        static let emoji: CGFloat = 34
        static let delete: CGFloat = 42
        static let enter: CGFloat = 42
        static let period: CGFloat = 32
        static let spaceMin: CGFloat = 48
        static let spaceMinCrowded: CGFloat = 40
    }

    /// Title that must not bidi-reorder (e.g. ؟+#).
    func ltrAttributedTitle(_ text: String, font: UIFont, color: UIColor) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.baseWritingDirection = .leftToRight
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style
        ])
    }

    func makeBottom(emojiOn: Bool = false) -> UIView {
        let showsNextKeyboard = needsInputModeSwitchKey
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = .fill
        row.alignment = .fill
        row.semanticContentAttribute = .forceLeftToRight

        var leading: [UIButton] = []
        if page == .symbols || page == .emoji {
            // Unified ABC (no Arabic «حروف» — avoids bidi/width issues; a11y stays Arabic).
            let back = control("ABC", #selector(symbolsOrLettersTapped), font: 13, chrome: .symbols)
            back.accessibilityLabel = "العودة إلى لوحة الحروف"
            back.semanticContentAttribute = .forceLeftToRight
            back.titleLabel?.semanticContentAttribute = .forceLeftToRight
            leading.append(back)
        } else {
            // Letters → symbols. Logical string ؟+# with forced LTR rendering.
            let symbolsTitle = language == .arabic ? "؟+#" : "#+="
            let symbols = control(symbolsTitle, #selector(symbolsOrLettersTapped), font: 13, chrome: .symbols)
            symbols.semanticContentAttribute = .forceLeftToRight
            symbols.titleLabel?.semanticContentAttribute = .forceLeftToRight
            symbols.titleLabel?.textAlignment = .center
            let font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            symbols.setAttributedTitle(ltrAttributedTitle(symbolsTitle, font: font, color: .white), for: .normal)
            symbols.accessibilityLabel = "لوحة الرموز والأرقام"
            leading.append(symbols)
        }
        let langTitle = language == .arabic ? "EN" : "ع"
        let lang = control(langTitle, #selector(languageTapped), font: language == .arabic ? 14 : 16, chrome: .language)
        lang.accessibilityLabel = "تغيير اللغة"
        leading.append(lang)
        if showsNextKeyboard {
            let next = UIButton(type: .system)
            next.setImage(UIImage(systemName: "globe", withConfiguration: iconConfig), for: .normal)
            paint(next, chrome: .language)
            next.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            next.accessibilityLabel = "تبديل لوحة المفاتيح"
            next.accessibilityHint = "التبديل إلى لوحة مفاتيح أخرى في النظام"
            leading.append(next)
        }
        for (idx, button) in leading.enumerated() {
            let isGlobe = showsNextKeyboard && idx == leading.count - 1 && button.image(for: .normal) != nil
            let w = isGlobe ? BottomWidth.globe : BottomWidth.side
            button.widthAnchor.constraint(equalToConstant: w).isActive = true
        }

        let emoji = UIButton(type: .system)
        emoji.setTitle("😊", for: .normal)
        emoji.titleLabel?.font = .systemFont(ofSize: 19)
        paint(emoji, chrome: .emoji)
        emoji.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)
        emoji.widthAnchor.constraint(equalToConstant: BottomWidth.emoji).isActive = true
        emoji.setContentCompressionResistancePriority(.required, for: .horizontal)
        emoji.setContentHuggingPriority(.required, for: .horizontal)
        emoji.accessibilityLabel = "لوحة الرموز التعبيرية"

        let space = control("", #selector(spaceTouchUp), font: 14)
        space.addTarget(self, action: #selector(spaceTouchDown(_:event:)), for: .touchDown)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragInside)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragOutside)
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        space.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        // Min width is a preference only. Priority 999 fought the side keys and crushed the emoji key.
        let minSpace = showsNextKeyboard ? BottomWidth.spaceMinCrowded : BottomWidth.spaceMin
        let minimumSpaceConstraint = space.widthAnchor.constraint(greaterThanOrEqualToConstant: minSpace)
        minimumSpaceConstraint.priority = UILayoutPriority(750)
        minimumSpaceConstraint.isActive = true
        space.accessibilityLabel = "مسافة"

        let enter = iconKey("arrow.down.to.line", #selector(enterTapped))
        enter.widthAnchor.constraint(equalToConstant: BottomWidth.enter).isActive = true
        enter.accessibilityLabel = "إدخال سطر جديد"

        leading.forEach { row.addArrangedSubview($0) }
        row.addArrangedSubview(emoji)
        row.addArrangedSubview(space)
        if emojiOn {
            row.addArrangedSubview(makeDeleteKey(width: BottomWidth.delete))
        } else {
            if page == .symbols {
                row.addArrangedSubview(makeDeleteKey(width: BottomWidth.delete))
            }
            let period = control(".", #selector(periodTapped), font: 18, chrome: .period)
            period.widthAnchor.constraint(equalToConstant: BottomWidth.period).isActive = true
            row.addArrangedSubview(period)
        }
        row.addArrangedSubview(enter)
        lockHeight(row, 44)
        return row
    }
}
