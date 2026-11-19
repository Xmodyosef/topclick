import UIKit

// MARK: - KeyboardViewController + Rows
extension KeyboardViewController {
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
        let rowHeight: CGFloat = page == .symbols ? symbolKeyRowHeight() : letterKeyRowHeight()
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
        // Same contract as letters: page toggle (or none) + keys + delete on the right.
        makeActionRow(keys, leading: .symbolPage)
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
        case .symbolPage:
            // Page 0 shows #+= (go to page 1); page 1 shows 123 (back to numbers).
            let title = symbolPageIndex == 0 ? "#+=" : "123"
            let toggle = control(title, #selector(symbolPageToggled), font: 13, chrome: .control)
            toggle.widthAnchor.constraint(equalToConstant: 46).isActive = true
            toggle.accessibilityLabel = symbolPageIndex == 0 ? "المزيد من الرموز" : "الأرقام والرموز اليومية"
            wrap.addArrangedSubview(toggle)
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
        lockHeight(wrap, page == .symbols ? symbolKeyRowHeight() : letterKeyRowHeight())
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

    /// Number row tracked so a language change rewrites ١↔1 without a new stack.
    func makeTrackedNumberRow() -> UIView {
        let row = makeRow(numberRow, rowIdx: 0, trackAsLetters: false)
        if let stack = row as? UIStackView {
            numberRowButtons = stack.arrangedSubviews.compactMap { $0 as? UIButton }
        }
        return row
    }

    /// Wider of the Arabic and English grids. Spare slots stay hidden and take no width.
    func makeStableLetterRow(capacity: Int, titles: [String], rowIdx: Int) -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        s.semanticContentAttribute = .forceLeftToRight
        var rowButtons: [UIButton] = []
        for col in 0..<capacity {
            let title = col < titles.count ? titles[col] : ""
            let button = charKey(title, rowIdx: rowIdx)
            let spare = col >= titles.count
            button.isHidden = spare
            button.accessibilityElementsHidden = spare
            button.isUserInteractionEnabled = !spare
            s.addArrangedSubview(button)
            rowButtons.append(button)
        }
        letterKeyButtons.append(rowButtons)
        lockHeight(s, letterKeyRowHeight())
        return s
    }

    /// Same last-row contract as `makeLastLetterRow`, but the Shift key and spare letters
    /// are hidden instead of omitted, so the next language does not allocate a new row.
    func makeStableLastLetterRow(capacity: Int, titles: [String]) -> UIView {
        let wrap = UIStackView()
        wrap.axis = .horizontal
        wrap.spacing = 4
        wrap.semanticContentAttribute = .forceLeftToRight
        let shift = iconKey(isShifted ? "shift.fill" : "shift", #selector(shiftTapped))
        shift.widthAnchor.constraint(equalToConstant: 40).isActive = true
        paint(shift, chrome: .shift, emphasized: isShifted)
        shift.accessibilityLabel = language == .arabic ? "حرف كبير" : "Shift"
        let hideShift = language == .arabic
        shift.isHidden = hideShift
        shift.accessibilityElementsHidden = hideShift
        shiftKeyButton = shift
        wrap.addArrangedSubview(shift)
        let mid = UIStackView()
        mid.axis = .horizontal
        mid.spacing = 6
        mid.distribution = .fillEqually
        mid.semanticContentAttribute = .forceLeftToRight
        var midButtons: [UIButton] = []
        for col in 0..<capacity {
            let title = col < titles.count ? titles[col] : ""
            let button = charKey(title, rowIdx: 2)
            let spare = col >= titles.count
            button.isHidden = spare
            button.accessibilityElementsHidden = spare
            button.isUserInteractionEnabled = !spare
            mid.addArrangedSubview(button)
            midButtons.append(button)
        }
        letterKeyButtons.append(midButtons)
        wrap.addArrangedSubview(mid)
        wrap.addArrangedSubview(makeDeleteKey())
        lockHeight(wrap, letterKeyRowHeight())
        return wrap
    }
}
