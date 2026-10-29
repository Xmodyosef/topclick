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

    /// Unified board height: letters, symbols, and emoji share the same compact board (268).
    /// Content is top-stacked; empty space (if any) stays at the bottom — no flex ghost layers.
    func computedBoardHeight() -> CGFloat {
        boardHeight
    }

    /// How many symbol rows to show (1…4). Default 4 so the symbols page fills like letters.
    func symbolRowsCount() -> Int {
        // Four symbol rows fit the compact board without adding filler keys.
        return 4
    }

    /// Preserve every valid symbol row in the supplied layout. Do not silently drop rows
    /// just because a key contains an emoji-like Unicode scalar or a combining mark.
    func packedSymbolRows(from allRows: [[String]]) -> [[String]] {
        let validRows = allRows.filter { row in
            !row.isEmpty && row.allSatisfy { !$0.isEmpty }
        }
        return Array(validRows.prefix(symbolRowsCount()))
    }

    /// Emoji grid height inside the fixed 268 board (tabs + bottom + pads reserved).
    func emojiPagerHeight() -> CGFloat {
        // Board 268 − topPad12 − tabs32 − two gaps12 − bottom44 = 168.
        return max(120, boardHeight - 100)
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
            let pages = symbolPages
            let pageIdx = min(max(symbolPageIndex, 0), max(pages.count - 1, 0))
            let allRows = pages.isEmpty ? [] : pages[pageIdx]
            var rows = packedSymbolRows(from: allRows)
            if rows.isEmpty {
                rows = language == .arabic ? KeyboardDataLoader.builtinArabicSymbols[0] : KeyboardDataLoader.builtinEnglishSymbols[0]
            }
            for (i, row) in rows.enumerated() {
                rootStack.addArrangedSubview(makeRow(row, rowIdx: i + 1))
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
        // Arabic: Shift key removed — always base rows; diacritics via long-press (#12/#13).
        // English: Shift toggles upper/lower in-place.
        if language == .arabic {
            return arabicRows
        }
        return isShifted ? englishUpper : englishLower
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
        let rowHeight: CGFloat = page == .symbols ? 46 : 37
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
        lockHeight(s, rowHeight)
        return s
    }
    func addFlexSpace() {
        // Removed: flex spacer + bottom-pinned rootStack caused ghost stacked layers.
    }
    func makeLastLetterRow(_ keys: [String]) -> UIView {
        // Arabic: no Shift key — diacritics/forms via long-press (AGENTS 16-point #12/#13).
        // English: keep Shift for upper case (in-place applyShiftSurface).
        makeActionRow(keys, leading: language == .arabic ? .none : .shift)
    }
    func makeSymbolLastRow(_ keys: [String]) -> UIView {
        // Keep symbol rows uniform; the delete action lives in the bottom action row.
        makeRow(keys, rowIdx: 4)
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
        lockHeight(wrap, page == .symbols ? 46 : 37)
        return wrap
    }
    func makeDeleteKey(width: CGFloat = 54) -> UIButton {
        let del = iconKey("delete.left", #selector(deleteTouchUp))
        del.addTarget(self, action: #selector(deleteTouchDown), for: .touchDown)
        del.addTarget(self, action: #selector(deleteTouchCancel), for: [.touchUpOutside, .touchCancel])
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragInside)
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragOutside)
        del.widthAnchor.constraint(equalToConstant: width).isActive = true
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
            // Letters → single symbols page (icon only).
            let symbols = iconKey("textformat.123", #selector(symbolsOrLettersTapped))
            paint(symbols, chrome: .symbols)
            symbols.accessibilityLabel = "لوحة الرموز والأرقام"
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
        let minimumSpace = space.widthAnchor.constraint(greaterThanOrEqualToConstant: page == .symbols ? 58 : 74)
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
            if page == .symbols {
                row.addArrangedSubview(makeDeleteKey(width: 34))
            }
            let period = control(".", #selector(periodTapped), font: 18, chrome: .period)
            period.widthAnchor.constraint(equalToConstant: 32).isActive = true
            row.addArrangedSubview(period)
        }
        row.addArrangedSubview(enter)
        lockHeight(row, 44)
        return row
    }
}
