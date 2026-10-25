import SwiftUI
import Translation
import UIKit
import AudioToolbox

/// A key with a slightly taller hit area, so a light tap still lands.
final class KeyButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -2, dy: -8).contains(point)
    }
}

enum RowLeading { case shift, symbols, letters, none }

// MARK: - KeyboardViewController + BuildUI
extension KeyboardViewController {
    func updateHeightForCurrentSize() {
        let desiredHeight = computedBoardHeight()
        if heightConstraint == nil {
            let c = view.heightAnchor.constraint(equalToConstant: desiredHeight)
            c.priority = UILayoutPriority(999)
            c.isActive = true
            heightConstraint = c
        } else if abs((heightConstraint?.constant ?? 0) - desiredHeight) > 0.5 {
            heightConstraint?.constant = desiredHeight
        }
    }

    /// Unified board height: letters / symbols / emoji all pin to `boardHeight` (324).
    /// Content is top-stacked; empty space (if any) stays at the bottom — no flex ghost layers.
    func computedBoardHeight() -> CGFloat {
        boardHeight
    }

    /// How many symbol rows to show (1…4). Default 4 so the symbols page fills like letters.
    func symbolRowsCount() -> Int {
        // Always 4 rows so symbols fill the 324 board like the letters page (iOS-style).
        return 4
    }

    /// Emoji grid height inside the fixed 324 board (tabs + bottom + pads reserved).
    func emojiPagerHeight() -> CGFloat {
        // 324 − topPad12 − tabs32 − sp6 − sp6 − bottom44 ≈ 224
        return max(210, boardHeight - 100)
    }
    func armHaptics() {
        guard hapticsOn else { return }
        UIImpactFeedbackGenerator(style: impactStyle).prepare()
        selectionFeedback.prepare()
    }
    func tapHaptic(_ pulse: Pulse = .key) {
        guard hapticsOn else { return }
        if case .move = pulse {
            selectionFeedback.selectionChanged()
            selectionFeedback.prepare()
        } else {
            let feedback = UIImpactFeedbackGenerator(style: impactStyle)
            feedback.impactOccurred()
            feedback.prepare()
        }
    }
    func showNotice(_ message: String) {
        noticeLabel?.removeFromSuperview()
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.backgroundColor = UIColor.black.withAlphaComponent(0.88)
        label.layer.cornerRadius = 12
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -12),
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -24)
        ])
        label.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        label.isUserInteractionEnabled = false
        noticeLabel = label
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self, weak label] in
            label?.removeFromSuperview()
            if self?.noticeLabel === label { self?.noticeLabel = nil }
        }
    }
    func lockHeight(_ v: UIView, _ h: CGFloat) {
        v.heightAnchor.constraint(equalToConstant: h).isActive = true
        v.setContentHuggingPriority(.required, for: .vertical)
        v.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    func configureRoot() {
        view.backgroundColor = palette.background
        view.clipsToBounds = false
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.isUserInteractionEnabled = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        rootStack.axis = .vertical
        rootStack.spacing = 6
        rootStack.distribution = .fill
        rootStack.alignment = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        rootStack.isLayoutMarginsRelativeArrangement = false
        view.addSubview(rootStack)
        // Pin top/leading/trailing only — NEVER pin bottom to height.
        // Bottom pinning + fixed heightConstraint caused stacked/ghost rows.
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 12)
        ])
        rootStack.setContentHuggingPriority(.required, for: .vertical)
        rootStack.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    func rebuild() {
        hideClipboardPanel()
        emojiPager?.delegate = nil
        emojiPager = nil
        emojiCollection?.dataSource = nil
        emojiCollection?.delegate = nil
        emojiCollection = nil
        emojiTabs = nil
        letterKeyButtons = []
        shiftKeyButton = nil
        palette = NaqraPalette.current()
        view.clipsToBounds = false
        view.backgroundColor = palette.background
        blurView.effect = nil
        blurView.backgroundColor = palette.background
        // Hard clear — avoid ghost layers from leftover arranged views.
        rootStack.arrangedSubviews.forEach { v in
            rootStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }
        rootStack.spacing = 6
        heightConstraint?.constant = computedBoardHeight()
        switch page {
        case .letters:
            rootStack.addArrangedSubview(makeToolbar())
            if showNumberRow {
                rootStack.addArrangedSubview(makeRow(numberRow, rowIdx: 0))
            }
            let rows = activeLetterLayout()
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 { rootStack.addArrangedSubview(makeLastLetterRow(row)) }
                else { rootStack.addArrangedSubview(makeRow(row, rowIdx: i + 1, trackAsLetters: true)) }
            }
            rootStack.addArrangedSubview(makeBottom())
        case .symbols:
            let rowsCount = symbolRowsCount()
            let pages = symbolPages
            let pageIdx = min(max(symbolPageIndex, 0), max(pages.count - 1, 0))
            let allRows = pages.isEmpty ? [] : pages[pageIdx]
            var rows = Array(allRows.prefix(rowsCount)).filter { !$0.isEmpty }
            if rows.isEmpty {
                rows = language == .arabic ? KeyboardDataLoader.builtinArabicSymbols[0] : KeyboardDataLoader.builtinEnglishSymbols[0]
            }
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 { rootStack.addArrangedSubview(makeSymbolLastRow(row)) }
                else { rootStack.addArrangedSubview(makeRow(row, rowIdx: i + 1)) }
            }
            rootStack.addArrangedSubview(makeBottom())
        case .emoji:
            if emojiPack.isEmpty {
                emojiPack = Self.catalog()
            }
            rootStack.addArrangedSubview(makeEmojiTabs())
            rootStack.addArrangedSubview(makeEmojiPager())
            rootStack.addArrangedSubview(makeBottom(emojiOn: true))
        }
        updateHeightForCurrentSize()
        view.setNeedsLayout()
    }

    /// Letter layouts for the current language/shift state.
    func activeLetterLayout() -> [[String]] {
        language == .arabic
            ? (isShifted ? arabicShiftRows : arabicRows)
            : (isShifted ? englishUpper : englishLower)
    }

    /// Toggle shift by rewriting titles on existing keys — no full stack rebuild.
    /// Falls back to `rebuild()` if the tracked key grid does not match the layout.
    @discardableResult
    func applyShiftSurface() -> Bool {
        guard page == .letters else {
            rebuild()
            return false
        }
        let rows = activeLetterLayout()
        guard letterKeyButtons.count == rows.count else {
            rebuild()
            return false
        }
        for (rowIndex, titles) in rows.enumerated() {
            let buttons = letterKeyButtons[rowIndex]
            guard buttons.count == titles.count else {
                rebuild()
                return false
            }
            for (col, title) in titles.enumerated() {
                buttons[col].setTitle(title, for: .normal)
            }
        }
        if let shift = shiftKeyButton {
            let name = isShifted ? "shift.fill" : "shift"
            let symbol = UIImage(systemName: name, withConfiguration: iconConfig)
                ?? UIImage(systemName: "shift", withConfiguration: iconConfig)
            shift.setImage(symbol, for: .normal)
            paint(shift, chrome: .shift, emphasized: isShifted)
        }
        return true
    }

    func makeToolbar() -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.distribution = .fill
        s.semanticContentAttribute = .forceLeftToRight
        s.backgroundColor = .clear

        let clip = iconKey("doc.on.clipboard", #selector(copyPasteTapped))
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(copyPasteHold(_:)))
        holdGesture.minimumPressDuration = 0.38
        holdGesture.cancelsTouchesInView = true
        clip.addGestureRecognizer(holdGesture)
        clip.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(clip)

        // Suggestions only when enabled AND non-empty — no blank white middle strip.
        let showSuggestions = ThemeIO.bool("suggestions") ?? false
        let words = showSuggestions ? suggestions().filter { !$0.isEmpty } : []
        if !words.isEmpty {
            let suggRow = makeSuggestionsRow(words: words)
            suggRow.setContentHuggingPriority(.defaultLow, for: .horizontal)
            s.addArrangedSubview(suggRow)
        } else {
            let spacer = UIView()
            spacer.backgroundColor = .clear
            spacer.isUserInteractionEnabled = false
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            s.addArrangedSubview(spacer)
        }

        // Translate: keep only when iOS 18+ (otherwise the button only shows "needs iOS 18").
        if #available(iOS 18.0, *) {
            let tr = iconKey("translate", #selector(translateTapped))
            tr.widthAnchor.constraint(equalToConstant: 36).isActive = true
            tr.accessibilityLabel = "ترجمة"
            s.addArrangedSubview(tr)
        }
        let hide = iconKey("keyboard.chevron.compact.down", #selector(dismissKeyboardAction))
        hide.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(hide)
        lockHeight(s, 34)
        return s
    }
    /// Fill short rows so the board never shows empty gaps (iOS-dense).
    /// Uses black/white geometric glyphs that still insert on tap.
    func padRowKeys(_ keys: [String], target: Int = 10) -> [String] {
        guard keys.count < target, !keys.isEmpty else { return keys }
        let fillers = ["⬜", "⬛", "◽", "◾", "○", "●"]
        var out = keys
        var i = 0
        while out.count < target {
            out.append(fillers[i % fillers.count])
            i += 1
        }
        return out
    }

    func makeRow(_ keys: [String], rowIdx: Int, trackAsLetters: Bool = false) -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        s.heightAnchor.constraint(equalToConstant: 46).isActive = true
        s.distribution = .fillEqually
        s.semanticContentAttribute = .forceLeftToRight
        // Symbols: keep exactly the designed keys (10×4) — no filler clutter when layout is complete.
        let displayKeys = keys
        if page == .symbols {
            s.spacing = 5  // slightly airier than letters (4)
        }
        var rowButtons: [UIButton] = []
        for key in displayKeys {
            let button = charKey(key, rowIdx: rowIdx)
            s.addArrangedSubview(button)
            if trackAsLetters { rowButtons.append(button) }
        }
        if trackAsLetters { letterKeyButtons.append(rowButtons) }
        lockHeight(s, 46)
        return s
    }
    func addFlexSpace() {
        // Removed: flex spacer + bottom-pinned rootStack caused ghost stacked layers.
    }
    func makeLastLetterRow(_ keys: [String]) -> UIView {
        // Shift on the last letter row for both languages so Arabic diacritic layer
        // is reachable without a full rebuild (applyShiftSurface).
        makeActionRow(keys, leading: .shift)
    }
    func makeSymbolLastRow(_ keys: [String]) -> UIView {
        // Back-to-letters stays on the bottom bar, so these keys keep a full width.
        makeActionRow(keys, leading: .none)
    }
    func makeActionRow(_ keys: [String], leading: RowLeading) -> UIView {
        let wrap = UIStackView()
        wrap.axis = .horizontal
        wrap.spacing = 4
        wrap.semanticContentAttribute = .forceLeftToRight
        switch leading {
        case .shift:
            let shift = iconKey(isShifted ? "shift.fill" : "shift", #selector(shiftTapped))
            shift.widthAnchor.constraint(equalToConstant: 40).isActive = true
            paint(shift, chrome: .shift, emphasized: isShifted)
            shiftKeyButton = shift
            wrap.addArrangedSubview(shift)
        case .symbols:
            let symbols = control("١٢٣", #selector(symbolsOrLettersTapped), font: 13, chrome: .control)
            symbols.widthAnchor.constraint(equalToConstant: 46).isActive = true
            symbols.accessibilityLabel = "رموز"
            wrap.addArrangedSubview(symbols)
        case .letters:
            let letters = control("أبج", #selector(symbolsOrLettersTapped), font: 14, chrome: .control)
            letters.widthAnchor.constraint(equalToConstant: 46).isActive = true
            letters.accessibilityLabel = "حروف"
            wrap.addArrangedSubview(letters)
        case .none:
            break
        }
        let mid = UIStackView()
        mid.axis = .horizontal
        mid.spacing = 6
        mid.distribution = .fillEqually
        mid.semanticContentAttribute = .forceLeftToRight
        let midKeys = keys
        var midButtons: [UIButton] = []
        for key in midKeys {
            let button = charKey(key, rowIdx: 2)
            mid.addArrangedSubview(button)
            midButtons.append(button)
        }
        // Letters last row only — track for in-place shift (not symbol last row).
        if page == .letters {
            letterKeyButtons.append(midButtons)
        }
        wrap.addArrangedSubview(mid)
        wrap.addArrangedSubview(makeDeleteKey())
        lockHeight(wrap, 44)
        return wrap
    }
    func makeDeleteKey() -> UIButton {
        let del = iconKey("delete.left", #selector(deleteTouchUp))
        del.addTarget(self, action: #selector(deleteTouchDown), for: .touchDown)
        del.addTarget(self, action: #selector(deleteTouchCancel), for: [.touchUpOutside, .touchCancel])
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragInside)
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragOutside)
        del.widthAnchor.constraint(equalToConstant: 54).isActive = true
        return del
    }
    func makeBottom(emojiOn: Bool = false) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.distribution = .fill
        row.alignment = .fill
        row.semanticContentAttribute = .forceLeftToRight

        var leading: [UIButton] = []
        if page == .symbols {
            // Multi-page symbols: 123 ↔ #+ = then letters via أبج/ABC.
            if symbolPages.count > 1 {
                // iOS-style cycle: 123 → #+= → #+=/more → …
                let pageTitle: String
                switch symbolPageIndex {
                case 0: pageTitle = "#+="
                case 1: pageTitle = (symbolPages.count > 2 ? "＃3" : (language == .arabic ? "١٢٣" : "123"))
                default: pageTitle = language == .arabic ? "١٢٣" : "123"
                }
                let pageBtn = control(pageTitle, #selector(symbolPageToggled), font: 11, chrome: .symbols)
                pageBtn.accessibilityLabel = "صفحة رموز أخرى"
                leading.append(pageBtn)
            }
            let backTitle = language == .arabic ? "أبج" : "ABC"
            let back = control(backTitle, #selector(symbolsOrLettersTapped), font: 12, chrome: .symbols)
            back.accessibilityLabel = "رجوع للحروف"
            leading.append(back)
        } else if page == .emoji {
            let back = control("رجوع", #selector(symbolsOrLettersTapped), font: 12, chrome: .symbols)
            back.accessibilityLabel = "رجوع للحروف"
            leading.append(back)
        } else {
            // Letters page: symbols entry (Shift lives on the last letter row).
            let symbols = control(language == .arabic ? "١٢٣" : "123", #selector(symbolsOrLettersTapped), font: 12, chrome: .symbols)
            symbols.accessibilityLabel = "رموز"
            leading.append(symbols)
        }
        let langTitle = language == .arabic ? "EN" : "ع"
        let lang = control(langTitle, #selector(languageTapped), font: language == .arabic ? 14 : 16, chrome: .language)
        lang.accessibilityLabel = "تغيير اللغة"
        leading.append(lang)
        for button in leading {
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        }


        let emoji = UIButton(type: .system)
        emoji.setTitle("😊", for: .normal)
        emoji.titleLabel?.font = .systemFont(ofSize: 19)
        paint(emoji, chrome: .emoji)
        emoji.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)
        emoji.widthAnchor.constraint(equalToConstant: 32).isActive = true
        emoji.accessibilityLabel = "لوحة الرموز التعبيرية"

        let space = control("", #selector(spaceTouchUp), font: 14)
        space.addTarget(self, action: #selector(spaceTouchDown(_:event:)), for: .touchDown)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragInside)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragOutside)
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        space.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let minimumSpace = space.widthAnchor.constraint(greaterThanOrEqualToConstant: 74)
        minimumSpace.priority = UILayoutPriority(999)
        minimumSpace.isActive = true
        space.accessibilityLabel = "مسافة"

        let enter = iconKey("arrow.down.to.line", #selector(enterTapped))
        enter.widthAnchor.constraint(equalToConstant: 42).isActive = true
        enter.accessibilityLabel = "إدخال سطر جديد"

        leading.forEach { row.addArrangedSubview($0) }
        row.addArrangedSubview(emoji)
        row.addArrangedSubview(space)
        if emojiOn {
            row.addArrangedSubview(makeDeleteKey())
        } else {
            let period = control(".", #selector(periodTapped), font: 18)
            period.widthAnchor.constraint(equalToConstant: 32).isActive = true
            row.addArrangedSubview(period)
        }
        row.addArrangedSubview(enter)
        lockHeight(row, 44)
        return row
    }
    func paint(_ b: UIButton, chrome: KeyChrome = .letter, emphasized: Bool = false) {
        // Role-colored keys: letters vs shift/lang/symbols/emoji/enter/delete.
        let bg: UIColor
        let fg: UIColor
        switch chrome {
        case .letter:
            bg = palette.key.withAlphaComponent(1)
            fg = palette.text
        case .control:
            bg = mix(palette.key, palette.background, t: 0.28)
            fg = palette.text.withAlphaComponent(0.92)
        case .symbols:
            // ١٢٣ / #+= / أبج — cooler accent mix so they differ from letters
            bg = mix(palette.key, palette.accent, t: 0.42)
            fg = palette.blurDark ? UIColor.white : palette.text
        case .emoji:
            bg = mix(palette.key, palette.accent, t: 0.30)
            fg = palette.text
        case .language:
            bg = mix(palette.key, palette.accent, t: 0.50)
            fg = palette.blurDark ? UIColor.white : palette.text
        case .shift:
            if emphasized {
                bg = palette.accent
                fg = .white
            } else {
                bg = mix(palette.key, palette.accent, t: 0.28)
                fg = palette.text
            }
        case .enter:
            bg = palette.accent
            fg = .white
        case .danger:
            // Delete: clearly reddish vs letter keys
            bg = mix(palette.key, UIColor(red: 0.85, green: 0.25, blue: 0.28, alpha: 1), t: 0.48)
            fg = palette.blurDark ? UIColor.white : palette.text
        }
        b.backgroundColor = bg
        b.setTitleColor(fg, for: .normal)
        b.tintColor = fg
        b.layer.cornerRadius = 8
        b.layer.cornerCurve = .continuous
        b.layer.borderWidth = ([KeyChrome.language, .shift, .enter, .symbols, .emoji, .danger].contains(chrome)) ? 1.0 : (palette.blurDark ? 0.5 : 0.8)
        let line: UIColor
        switch chrome {
        case .language, .enter, .symbols:
            line = palette.accent.withAlphaComponent(0.55)
        case .emoji:
            line = palette.accent.withAlphaComponent(0.35)
        case .danger:
            line = UIColor.systemRed.withAlphaComponent(0.40)
        case .shift where emphasized:
            line = UIColor.white.withAlphaComponent(0.25)
        default:
            line = palette.blurDark ? UIColor.white.withAlphaComponent(0.16) : UIColor.black.withAlphaComponent(0.12)
        }
        b.layer.borderColor = line.cgColor
        b.layer.shadowOpacity = 0
        b.clipsToBounds = true
        b.isOpaque = true
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
