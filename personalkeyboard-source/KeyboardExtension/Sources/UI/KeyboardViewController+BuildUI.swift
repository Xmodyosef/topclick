import UIKit
import AudioToolbox

/// A key with a slightly taller hit area, so a light tap still lands.
final class KeyButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -2, dy: -8).contains(point)
    }
}

enum RowLeading { case shift, symbols, letters, symbolPage, none }

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
    /// Key rows grow so each page fills that height. The stack stays top-pinned;
    /// pinning the bottom previously stacked ghost rows.
    func computedBoardHeight() -> CGFloat {
        boardHeight
    }

    /// Height of one flexible key row so the page fills `boardHeight`.
    func filledRowHeight(flexibleRows: Int, fixedHeight: CGFloat, arrangedCount: Int) -> CGFloat {
        let spacing: CGFloat = 6
        let topInset: CGFloat = 12
        let gaps = CGFloat(max(arrangedCount - 1, 0)) * spacing
        let available = boardHeight - topInset - gaps - fixedHeight
        return max(36, available / CGFloat(max(flexibleRows, 1)))
    }

    func letterKeyRowHeight() -> CGFloat {
        let flex = showNumberRow ? 4 : 3
        return filledRowHeight(flexibleRows: flex, fixedHeight: 34 + 44, arrangedCount: flex + 2)
    }

    func symbolKeyRowHeight() -> CGFloat {
        // Symbols now share the full 34pt task toolbar and 44pt bottom row.
        // Four symbol rows therefore use the same 51pt key-row height as letters.
        let flex = symbolRowsCount()
        return filledRowHeight(flexibleRows: flex, fixedHeight: 34 + 44, arrangedCount: flex + 2)
    }

    /// How many symbol rows to show. Four rows: three full + one action (delete).
    func symbolRowsCount() -> Int {
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

    /// Emoji grid fills the rest of the 324 board: top 12 + tabs 32 + two gaps + bottom 44.
    func emojiPagerHeight() -> CGFloat {
        let used: CGFloat = 12 + 32 + 6 + 6 + 44
        return max(160, boardHeight - used)
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
    /// Cancel transient emoji overlays and stale animation callbacks before replacing the page.
    func cancelEmojiTransientInteractions() {
        emojiTransitionGeneration &+= 1
        if let pager = emojiPager {
            pager.layer.removeAllAnimations()
            pager.transform = .identity
        }
        emojiSwipeSnapshot?.removeFromSuperview()
        emojiSwipeSnapshot = nil
        emojiCollection?.isScrollEnabled = true
        closeSkinPicker()
    }

    /// Shell identity. Language is applied by retitling EN/ع and ؟+#, not by rebuilding chrome.
    func surfaceChromeKey() -> String {
        let globe = needsInputModeSwitchKey ? "globe" : "noglobe"
        let shell: String
        switch page {
        case .letters: shell = "letters"
        case .symbols: shell = "symbols"
        case .emoji: shell = "emoji"
        }
        return "\(shell)|\(globe)|\(themeSignature)"
    }

    func releaseEmojiSurface() {
        emojiCollection?.dataSource = nil
        emojiCollection?.delegate = nil
        emojiCollection = nil
        emojiTabs = nil
        emojiPager = nil
        emojiSkinLongPress = nil
    }

    func clearMiddle() {
        middleStack.arrangedSubviews.forEach { view in
            middleStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    func fillMiddle() {
        switch page {
        case .letters:
            if showNumberRow {
                middleStack.addArrangedSubview(makeRow(numberRow, rowIdx: 0))
            }
            let rows = activeLetterLayout()
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 {
                    middleStack.addArrangedSubview(makeLastLetterRow(row))
                } else {
                    middleStack.addArrangedSubview(makeRow(row, rowIdx: i + 1, trackAsLetters: true))
                }
            }
        case .symbols:
            let pages = symbolPages
            let pageIdx = min(max(symbolPageIndex, 0), max(pages.count - 1, 0))
            let allRows = pages.isEmpty ? [] : pages[pageIdx]
            var rows = packedSymbolRows(from: allRows)
            if rows.isEmpty {
                let fallback = language == .arabic ? KeyboardDataLoader.builtinArabicSymbols : KeyboardDataLoader.builtinEnglishSymbols
                let fi = min(pageIdx, max(fallback.count - 1, 0))
                rows = fallback.isEmpty ? [] : fallback[fi]
            }
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 {
                    middleStack.addArrangedSubview(makeSymbolLastRow(row))
                } else {
                    middleStack.addArrangedSubview(makeRow(row, rowIdx: i + 1))
                }
            }
        case .emoji:
            if emojiPack.isEmpty {
                emojiPack = Self.catalog()
            }
            middleStack.addArrangedSubview(makeEmojiTabs())
            middleStack.addArrangedSubview(makeEmojiPager())
        }
    }

    /// Same EN/ع and ؟+# the full bottom build would show, without allocating a new bar.
    func refreshKeptChromeTitles() {
        if let lang = languageKeyButton {
            let title = language == .arabic ? "EN" : "ع"
            lang.setTitle(title, for: .normal)
            lang.titleLabel?.font = KeyboardTypography.font(for: title, size: language == .arabic ? 14 : 16, weight: .semibold)
        }
        guard page == .letters, let mode = symbolsModeButton else { return }
        let symbolsTitle = language == .arabic ? "؟+#" : "#+="
        mode.setTitle(symbolsTitle, for: .normal)
        let font = KeyboardTypography.font(for: symbolsTitle, size: 13, weight: .semibold)
        mode.setAttributedTitle(ltrAttributedTitle(symbolsTitle, font: font, color: .white), for: .normal)
    }

    func mountFullSurface() {
        // Drop the previous page before allocating the next one.
        autoreleasepool {
            rootStack.arrangedSubviews.forEach { view in
                rootStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            clearMiddle()
        }
        rootStack.spacing = 6
        languageKeyButton = nil
        symbolsModeButton = nil
        if page == .emoji {
            topChrome = nil
        } else {
            let bar = makeToolbar()
            rootStack.addArrangedSubview(bar)
            topChrome = bar
        }
        rootStack.addArrangedSubview(middleStack)
        fillMiddle()
        let bottom = makeBottom(emojiOn: page == .emoji)
        rootStack.addArrangedSubview(bottom)
        bottomChrome = bottom
    }

    func rebuild() {
        hideKeyPreview()
        hideClipboardPanel()
        cancelEmojiTransientInteractions()
        releaseEmojiSurface()
        letterKeyButtons = []
        shiftKeyButton = nil
        palette = NaqraPalette.current()
        view.clipsToBounds = false
        view.backgroundColor = palette.background
        blurView.effect = nil
        blurView.backgroundColor = palette.background
        heightConstraint?.constant = computedBoardHeight()

        let key = surfaceChromeKey()
        let chromeAlive = mountedChromeKey == key
            && bottomChrome?.superview === rootStack
            && middleStack.superview === rootStack
            && (page == .emoji ? topChrome == nil : topChrome?.superview === rootStack)

        if chromeAlive {
            autoreleasepool { clearMiddle() }
            fillMiddle()
            let langTitle = language == .arabic ? "EN" : "ع"
            let languageChanged = languageKeyButton?.title(for: .normal) != langTitle
            refreshKeptChromeTitles()
            if page == .letters {
                refreshSuggestions()
            } else if languageChanged, let old = topChrome, old.superview === rootStack {
                rootStack.removeArrangedSubview(old)
                old.removeFromSuperview()
                let bar = makeToolbar()
                rootStack.insertArrangedSubview(bar, at: 0)
                topChrome = bar
            }
        } else {
            mountFullSurface()
            mountedChromeKey = key
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
