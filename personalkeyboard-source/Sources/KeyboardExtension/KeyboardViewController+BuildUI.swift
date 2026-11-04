import UIKit
import AudioToolbox

/// A key with a slightly taller hit area, so a light tap still lands.
final class KeyButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -2, dy: -8).contains(point)
    }
}

enum RowLeading { case shift, symbols, letters, none }

// MARK: - KeyboardViewController + BuildUI (core metrics / root / rebuild)
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

    /// Unified board height: letters, symbols, and emoji share the same board (324).
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

    /// Emoji grid height inside the fixed 324 board (tabs + bottom + pads reserved).
    func emojiPagerHeight() -> CGFloat {
        // Board 324 − topPad12 − tabs32 − two gaps12 − bottom44 ≈ 224.
        return max(160, boardHeight - 100)
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
            // Always ensure full catalog (13 categories / ~1200+ emoji) before drawing.
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
}
