import UIKit

// MARK: - KeyboardViewController + Bottom bar
extension KeyboardViewController {
    func makeBottom(emojiOn: Bool = false) -> UIView {
        let showsNextKeyboard = needsInputModeSwitchKey
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = .fill
        row.alignment = .fill
        row.semanticContentAttribute = .forceLeftToRight

        var leading: [UIButton] = []
        if page == .symbols {
            // Single symbols page — back to letters only.
            let backTitle = language == .arabic ? "حروف" : "ABC"
            let back = control(backTitle, #selector(symbolsOrLettersTapped), font: 13, chrome: .symbols)
            back.accessibilityLabel = "العودة إلى لوحة الحروف"
            leading.append(back)
        } else if page == .emoji {
            let back = control(language == .arabic ? "حروف" : "ABC", #selector(symbolsOrLettersTapped), font: 13, chrome: .symbols)
            back.accessibilityLabel = "العودة إلى لوحة الحروف"
            leading.append(back)
        } else {
            // Letters → single symbols page (titles match iOS style; force LTR so ؟+# never mirrors).
            let symbolsTitle = language == .arabic ? "؟+#" : "#+="
            let symbols = control(symbolsTitle, #selector(symbolsOrLettersTapped), font: 13, chrome: .symbols)
            symbols.semanticContentAttribute = .forceLeftToRight
            symbols.titleLabel?.semanticContentAttribute = .forceLeftToRight
            symbols.titleLabel?.textAlignment = .center
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
        let sideKeyWidth: CGFloat = showsNextKeyboard ? 36 : 44
        for button in leading {
            button.widthAnchor.constraint(equalToConstant: sideKeyWidth).isActive = true
        }


        let emoji = UIButton(type: .system)
        emoji.setTitle("😊", for: .normal)
        emoji.titleLabel?.font = .systemFont(ofSize: 19)
        paint(emoji, chrome: .emoji)
        emoji.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)
        emoji.widthAnchor.constraint(equalToConstant: showsNextKeyboard ? 30 : 32).isActive = true
        emoji.accessibilityLabel = "لوحة الرموز التعبيرية"

        let space = control("", #selector(spaceTouchUp), font: 14)
        space.addTarget(self, action: #selector(spaceTouchDown(_:event:)), for: .touchDown)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragInside)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragOutside)
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        space.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let minimumSpace: CGFloat = page == .symbols ? (showsNextKeyboard ? 44 : 58) : (showsNextKeyboard ? 58 : 74)
        let minimumSpaceConstraint = space.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumSpace)
        minimumSpaceConstraint.priority = UILayoutPriority(999)
        minimumSpaceConstraint.isActive = true
        space.accessibilityLabel = "مسافة"

        let enter = iconKey("arrow.down.to.line", #selector(enterTapped))
        enter.widthAnchor.constraint(equalToConstant: showsNextKeyboard ? 38 : 42).isActive = true
        enter.accessibilityLabel = "إدخال سطر جديد"

        leading.forEach { row.addArrangedSubview($0) }
        row.addArrangedSubview(emoji)
        row.addArrangedSubview(space)
        if emojiOn {
            row.addArrangedSubview(makeDeleteKey())
        } else {
            if page == .symbols {
                row.addArrangedSubview(makeDeleteKey(width: showsNextKeyboard ? 30 : 34))
            }
            let period = control(".", #selector(periodTapped), font: 18, chrome: .period)
            period.widthAnchor.constraint(equalToConstant: showsNextKeyboard ? 28 : 32).isActive = true
            row.addArrangedSubview(period)
        }
        row.addArrangedSubview(enter)
        lockHeight(row, 44)
        return row
    }
}
