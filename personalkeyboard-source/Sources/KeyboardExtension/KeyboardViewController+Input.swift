import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Input
extension KeyboardViewController {
    func saveLanguage() { ThemeIO.set("lastLanguage", value: language == .english ? "en" : "ar") }
    func makeSuggestionsRow(words: [String]? = nil) -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        s.semanticContentAttribute = .forceLeftToRight
        s.backgroundColor = .clear
        suggestionButtons = []
        let list = (words ?? suggestions()).filter { !$0.isEmpty }
        for (i, word) in list.enumerated() {
            let b = UIButton(type: .system)
            b.tag = i
            b.setTitle(word, for: .normal)
            b.isEnabled = true
            b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            b.titleLabel?.adjustsFontSizeToFitWidth = true
            b.titleLabel?.minimumScaleFactor = 0.7
            b.setTitleColor(palette.text, for: .normal)
            b.backgroundColor = palette.key.withAlphaComponent(1)
            b.layer.cornerRadius = 8
            b.layer.cornerCurve = .continuous
            b.clipsToBounds = true
            b.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
            suggestionButtons.append(b)
            s.addArrangedSubview(b)
        }
        lockHeight(s, 34)
        return s
    }
    func suggestions() -> [String] {
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = before.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" }).last.map(String.init) ?? ""
        if token.count < 1 { return ["", "", ""] }
        var out: [String] = []
        if language == .arabic {
            let folded = Self.fold(token)
            for w in Self.arabicLexicon {
                if out.count == 3 { break }
                if Self.fold(w).hasPrefix(folded) && Self.fold(w) != folded && !out.contains(w) {
                    out.append(w)
                }
            }
        }
        if out.count < 3 {
            let code = language == .english ? "en_US" : "ar"
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: token.utf16.count)
            let completions = checker.completions(forPartialWordRange: range, in: token, language: code) ?? []
            let guesses = checker.guesses(forWordRange: range, in: token, language: code) ?? []
            for w in (completions + guesses) where !out.contains(w) && w.caseInsensitiveCompare(token) != .orderedSame {
                out.append(w)
                if out.count == 3 { break }
            }
        }
        while out.count < 3 { out.append("") }
        return out
    }
    func refreshSuggestions() {
        guard page == .letters else { return }
        let words = suggestions().filter { !$0.isEmpty }
        let current = suggestionButtons.compactMap { $0.title(for: .normal) }.filter { !$0.isEmpty }
        // Only rebuild toolbar when the visible suggestion set actually changes shape.
        if current == words { return }
        if current.isEmpty && words.isEmpty { return }
        // Replace just the toolbar (first arranged subview) without stacking ghosts.
        guard !rootStack.arrangedSubviews.isEmpty else { return }
        let old = rootStack.arrangedSubviews[0]
        rootStack.removeArrangedSubview(old)
        old.removeFromSuperview()
        let bar = makeToolbar()
        rootStack.insertArrangedSubview(bar, at: 0)
    }
    @objc func suggestionTapped(_ sender: UIButton) {
        guard let word = sender.title(for: .normal), !word.isEmpty else { return }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = before.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" }).last.map(String.init) ?? ""
        if !token.isEmpty { for _ in 0..<token.count { textDocumentProxy.deleteBackward() } }
        textDocumentProxy.insertText(word)
        playSystemSound()
        tapHaptic()
    }
    func charKey(_ t: String, rowIdx: Int) -> UIButton {
        let b = KeyButton(type: .system)
        b.setTitle(t, for: .normal)
        b.titleLabel?.font = letterFont
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.7
        paint(b)
        b.tag = rowIdx
        b.addTarget(self, action: #selector(charDown(_:)), for: .touchDown)
        b.addTarget(self, action: #selector(charDrag(_:event:)), for: .touchDragInside)
        b.addTarget(self, action: #selector(charDrag(_:event:)), for: .touchDragOutside)
        b.addTarget(self, action: #selector(charUp(_:)), for: [.touchUpInside, .touchUpOutside])
        b.addTarget(self, action: #selector(charCancel(_:)), for: .touchCancel)
        return b
    }
    @objc func charDown(_ sender: UIButton) {
        let key = sender.title(for: .normal) ?? ""
        holdChoice = key
        downText = key
        pendingInserted = false
        holdTimer?.invalidate()
        holdTimer = nil
        hideHoldPopup()
        guard !key.isEmpty else { return }
        textDocumentProxy.insertText(key)
        pendingInserted = true
        let row = sender.tag
        let sound: TapSoundEngine.Sound = row == 0 ? .rowTop : (row == 1 ? .rowMid : .rowBot)
        playSystemClick(sound)
        tapHaptic()
        guard holdChoices(for: key).count > 1 else { return }
        let timer = Timer(timeInterval: 0.32, repeats: false) { [weak self] _ in
            self?.showHoldPopup(from: sender)
        }
        holdTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    @objc func charDrag(_ sender: UIButton, event: UIEvent) {
        guard let popup = holdPopup, let touch = event.allTouches?.first else { return }
        let p = touch.location(in: popup)
        for v in popup.subviews {
            guard let b = v as? UIButton else { continue }
            let inside = b.frame.insetBy(dx: -4, dy: -10).contains(p)
            b.backgroundColor = inside ? UIColor.white.withAlphaComponent(0.28) : .clear
            if inside { holdChoice = b.title(for: .normal) ?? holdChoice }
        }
    }
    @objc func charUp(_ sender: UIButton) {
        holdTimer?.invalidate()
        holdTimer = nil
        if holdPopup != nil {
            let text = holdChoice.isEmpty ? downText : holdChoice
            hideHoldPopup()
            if !text.isEmpty { textDocumentProxy.insertText(text) }
            pendingInserted = false
            tapHaptic(.action)
        } else if !pendingInserted {
            let text = sender.title(for: .normal) ?? downText
            if !text.isEmpty { textDocumentProxy.insertText(text) }
        }
        pendingInserted = false
        if page == .letters, language == .english, isShifted {
            isShifted = false
            rebuild()
        }
    }
    @objc func charCancel(_ sender: UIButton) {
        holdTimer?.invalidate()
        holdTimer = nil
        let restore = holdPopup != nil && !pendingInserted
        hideHoldPopup()
        if restore, !downText.isEmpty {
            textDocumentProxy.insertText(downText)
        }
        pendingInserted = false
    }
    @objc func languageTapped() {
        language = language == .arabic ? .english : .arabic
        isShifted = false
        symbolPageIndex = 0
        if page == .emoji { page = .letters }
        saveLanguage()
        rebuild()
        tapHaptic(.action)
    }
    func showHoldPopup(from button: UIButton) {
        guard let key = button.title(for: .normal) else { return }
        let items = holdChoices(for: key)
        guard items.count > 1 else { return }
        if pendingInserted {
            textDocumentProxy.deleteBackward()
            pendingInserted = false
        }
        hideHoldPopup()
        let bar = UIStackView()
        bar.axis = .horizontal
        bar.spacing = 4
        bar.alignment = .center
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.black.withAlphaComponent(0.82)
        bar.layer.cornerRadius = 10
        bar.layer.cornerCurve = .continuous
        bar.isLayoutMarginsRelativeArrangement = true
        bar.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        // First item is the base key — release without sliding keeps the original character.
        holdChoice = items[0]
        for (i, item) in items.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(item, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
            b.setTitleColor(.white, for: .normal)
            b.backgroundColor = i == 0 ? UIColor.white.withAlphaComponent(0.28) : .clear
            b.layer.cornerRadius = 10 // Radius.key
            var config = UIButton.Configuration.plain(); config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8); b.configuration = config
            bar.addArrangedSubview(b)
        }
        view.addSubview(bar)
        let frame = button.convert(button.bounds, to: view)
        let popupH: CGFloat = 46
        var top = frame.minY - 8 - popupH
        if top < 4 {
            top = min(frame.maxY + 6, max(view.bounds.height - popupH - 4, 4))
        }
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor, constant: top),
            bar.heightAnchor.constraint(equalToConstant: popupH)
        ])
        // `frame.midX` is measured from the physical left edge. Using the
        // directional `leadingAnchor` mirrors that coordinate in Arabic RTL,
        // moving the long-press popup away from the key that was pressed.
        let center = bar.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: frame.midX)
        center.priority = .defaultHigh
        center.isActive = true
        bar.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 6).isActive = true
        bar.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -6).isActive = true
        holdPopup = bar
        tapHaptic()
    }
    func hideHoldPopup() {
        holdPopup?.removeFromSuperview()
        holdPopup = nil
    }
    @objc func shiftTapped() {
        isShifted.toggle()
        rebuild()
        tapHaptic(.action)
    }
    @objc func deleteTouchDown() {
        textDocumentProxy.deleteBackward()
        playSystemClick(.delete)
        tapHaptic(.del)
        deleteTimer?.invalidate()
        let arm = Timer(timeInterval: 0.35, repeats: false) { [weak self] _ in
            let repeatTimer = Timer(timeInterval: 0.07, repeats: true) { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
            }
            self?.deleteTimer = repeatTimer
            RunLoop.main.add(repeatTimer, forMode: .common)
        }
        deleteTimer = arm
        RunLoop.main.add(arm, forMode: .common)
    }
    @objc func deleteTouchUp() {
        deleteTimer?.invalidate()
        deleteTimer = nil
        deleteStartX = 0
    }
    @objc func deleteDrag(_ sender: UIButton, event: UIEvent) {
        guard let touch = event.allTouches?.first else { return }
        let x = touch.location(in: sender).x
        if deleteStartX == 0 { deleteStartX = x }
        if deleteStartX - x > 28 {
            deleteStartX = x
            let before = textDocumentProxy.documentContextBeforeInput ?? ""
            let token = String(before.split { $0 == " " || $0 == "\n" }.last ?? "")
            let n = max(token.count + 1, 1)
            for _ in 0..<n { textDocumentProxy.deleteBackward() }
        }
    }
    @objc func deleteTouchCancel() {
        deleteTimer?.invalidate()
        deleteTimer = nil
        deleteStartX = 0
    }
    @objc func spaceTouchDown(_ sender: UIButton, event: UIEvent) {
        spaceIsTrackpad = false
        if let t = event.allTouches?.first {
            spaceStart = t.location(in: view)
            lastTrackpadX = spaceStart.x
        }
    }
    @objc func spaceDrag(_ sender: UIButton, event: UIEvent) {
        guard trackpadOn, let t = event.allTouches?.first else { return }
        let p = t.location(in: view)
        if abs(p.x - spaceStart.x) > 10 { spaceIsTrackpad = true }
        guard spaceIsTrackpad else { return }
        let delta = p.x - lastTrackpadX
        if abs(delta) >= 8 {
            textDocumentProxy.adjustTextPosition(byCharacterOffset: delta > 0 ? 1 : -1)
            lastTrackpadX = p.x
            tapHaptic(.move)
        }
    }

    static func arabicLexiconFix(_ token: String) -> String? {
        let folded = fold(token)
        guard folded.count >= 3 else { return nil }
        let words = arabicLexicon
        if words.contains(where: { fold($0) == folded }) { return nil }
        let prefixHits = words.filter {
            let word = fold($0)
            return word.hasPrefix(folded) && word != folded && word.count - folded.count <= 2
        }
        if prefixHits.count == 1 { return prefixHits[0] }
        let near = words.filter {
            let word = fold($0)
            return word != folded && abs(word.count - folded.count) <= 1 && editDistance(word, folded) == 1
        }
        if near.count == 1 { return near[0] }
        return nil
    }

    static func editDistance(_ a: String, _ b: String) -> Int {
        let left = Array(a)
        let right = Array(b)
        if abs(left.count - right.count) > 1 { return 2 }
        var prev = Array(0...right.count)
        for i in 1...left.count {
            var cur = [i]
            var rowMin = i
            for j in 1...right.count {
                let cost = left[i - 1] == right[j - 1] ? 0 : 1
                let value = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
                cur.append(value)
                rowMin = min(rowMin, value)
            }
            if rowMin > 1 { return 2 }
            prev = cur
        }
        return prev[right.count]
    }

    func autocorrectOnSpace() {
        guard ThemeIO.bool("autocorrect") ?? true else { return }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let token = before.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "'" }).last.map(String.init) ?? ""
        guard token.count >= 2 else { return }
        let fix: String?
        if language == .english {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: token.utf16.count)
            let misspelling = checker.rangeOfMisspelledWord(in: token, range: range, startingAt: 0, wrap: false, language: "en_US")
            fix = misspelling.location != NSNotFound ? checker.guesses(forWordRange: range, in: token, language: "en_US")?.first : nil
        } else {
            let arabicFixes = [
                "هاذا": "هذا", "هاذه": "هذه", "هاذ": "هذا", "هذة": "هذه",
                "الذيي": "الذي", "اللذي": "الذي", "الذى": "الذي",
                "انشاءالله": "إن شاء الله", "ماشاءالله": "ما شاء الله", "الحمدلله": "الحمد لله",
                "شكراا": "شكرًا", "مساءا": "مساءً", "لاكن": "لكن",
                "انت": "أنت", "انتا": "أنت", "انتي": "أنتِ",
                "فى": "في", "الى": "إلى"
            ]
            fix = arabicFixes[token] ?? Self.arabicLexiconFix(token)
        }
        guard let fix, fix.caseInsensitiveCompare(token) != .orderedSame else { return }
        for _ in 0..<token.count { textDocumentProxy.deleteBackward() }
        textDocumentProxy.insertText(fix)
        tapHaptic(.action)
        refreshSuggestions()
    }
    @objc func spaceTouchUp() {
        if spaceIsTrackpad { spaceIsTrackpad = false; return }
        let now = Date()
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        let isAfterSpace = before.hasSuffix(" ")
        if isAfterSpace, let last = lastSpaceTap, now.timeIntervalSince(last) <= spaceSwitchInterval {
            lastSpaceTap = nil
            language = language == .arabic ? .english : .arabic
            isShifted = false
            symbolPageIndex = 0
            saveLanguage()
            if page != .emoji { page = .letters }
            rebuild()
            tapHaptic()
            return
        }
        lastSpaceTap = now
        autocorrectOnSpace()
        textDocumentProxy.insertText(" ")
        playSystemClick(.space)
        tapHaptic()
    }
    @objc func enterTapped() {
        textDocumentProxy.insertText("\n")
        playSystemClick(.enter)
        tapHaptic(.action)
    }
    @objc func copyPasteHold(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            clipboardLongPressInProgress = true
            guard hasFullAccess else {
                showNotice("الحافظة تحتاج تفعيل الوصول الكامل للوحة")
                return
            }
            // Toggle: long-press again closes the in-keyboard panel.
            if isClipboardPanelVisible {
                hideClipboardPanel()
                return
            }
            showClipboardPanel()
        case .ended, .cancelled, .failed:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.clipboardLongPressInProgress = false
            }
        default:
            break
        }
    }

    /// In-keyboard clipboard strip (system alerts are unreliable inside keyboard extensions).
    func showClipboardPanel() {
        hideClipboardPanel()
        hideHoldPopup()

        let panel = UIView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.backgroundColor = UIColor.black.withAlphaComponent(0.90)
        panel.layer.cornerRadius = 12
        panel.layer.cornerCurve = .continuous
        panel.clipsToBounds = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        panel.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            stack.topAnchor.constraint(equalTo: panel.topAnchor),
            stack.bottomAnchor.constraint(equalTo: panel.bottomAnchor)
        ])

        // Header: title + paste live + clear + close
        let header = UIStackView()
        header.axis = .horizontal
        header.spacing = 6
        header.alignment = .center

        let title = UILabel()
        title.text = "الحافظة"
        title.textColor = .white
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let pasteLive = makeClipboardActionButton(title: "لصق", action: #selector(clipboardPasteLiveTapped))
        let clearBtn = makeClipboardActionButton(title: "مسح", action: #selector(clipboardClearTapped), destructive: true)
        let closeBtn = makeClipboardActionButton(title: "إغلاق", action: #selector(clipboardCloseTapped))

        header.addArrangedSubview(title)
        header.addArrangedSubview(pasteLive)
        header.addArrangedSubview(clearBtn)
        header.addArrangedSubview(closeBtn)
        stack.addArrangedSubview(header)

        let historyEnabled = ThemeIO.bool("clipboardHistoryEnabled") ?? false
        let items = ClipboardHistory.shared.items

        if !historyEnabled {
            let hint = UILabel()
            hint.text = "فعّل سجل الحافظة من إعدادات نقرة لحفظ العناصر"
            hint.textColor = UIColor.white.withAlphaComponent(0.72)
            hint.font = .systemFont(ofSize: 11)
            hint.numberOfLines = 2
            stack.addArrangedSubview(hint)
        } else if items.isEmpty {
            let hint = UILabel()
            hint.text = "لا عناصر محفوظة — انسخ نصًا محددًا أو الصق من الحافظة الحية"
            hint.textColor = UIColor.white.withAlphaComponent(0.72)
            hint.font = .systemFont(ofSize: 11)
            hint.numberOfLines = 2
            stack.addArrangedSubview(hint)
        } else {
            let scroller = UIScrollView()
            scroller.showsVerticalScrollIndicator = true
            scroller.alwaysBounceVertical = true
            scroller.translatesAutoresizingMaskIntoConstraints = false
            lockHeight(scroller, 132)

            let list = UIStackView()
            list.axis = .vertical
            list.spacing = 4
            list.translatesAutoresizingMaskIntoConstraints = false
            scroller.addSubview(list)
            NSLayoutConstraint.activate([
                list.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor),
                list.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor),
                list.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
                list.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor),
                list.widthAnchor.constraint(equalTo: scroller.frameLayoutGuide.widthAnchor)
            ])

            for (index, item) in items.prefix(12).enumerated() {
                let row = UIButton(type: .system)
                let preview = item.count > 56 ? String(item.prefix(56)) + "…" : item
                row.setTitle(preview, for: .normal)
                row.setTitleColor(.white, for: .normal)
                row.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
                row.titleLabel?.lineBreakMode = .byTruncatingTail
                row.contentHorizontalAlignment = .leading
                row.backgroundColor = UIColor.white.withAlphaComponent(0.10)
                row.layer.cornerRadius = 8
                row.layer.cornerCurve = .continuous
                row.tag = index
                row.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
                row.addTarget(self, action: #selector(clipboardItemTapped(_:)), for: .touchUpInside)
                row.heightAnchor.constraint(greaterThanOrEqualToConstant: 36).isActive = true
                list.addArrangedSubview(row)
            }
            stack.addArrangedSubview(scroller)
        }

        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            panel.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            panel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -6)
        ])
        clipboardPanel = panel
        isClipboardPanelVisible = true
        tapHaptic(.action)
    }

    func hideClipboardPanel() {
        clipboardPanel?.removeFromSuperview()
        clipboardPanel = nil
        isClipboardPanelVisible = false
    }

    func makeClipboardActionButton(title: String, action: Selector, destructive: Bool = false) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        b.setTitleColor(destructive ? UIColor(red: 1, green: 0.45, blue: 0.45, alpha: 1) : .white, for: .normal)
        b.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        b.layer.cornerRadius = 8
        b.layer.cornerCurve = .continuous
        b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    @objc func clipboardItemTapped(_ sender: UIButton) {
        let items = ClipboardHistory.shared.items
        guard items.indices.contains(sender.tag) else { return }
        let text = items[sender.tag]
        textDocumentProxy.insertText(text)
        playSystemClick(.rowMid)
        tapHaptic()
        hideClipboardPanel()
    }

    @objc func clipboardPasteLiveTapped() {
        pasteNow()
        hideClipboardPanel()
    }

    @objc func clipboardClearTapped() {
        ClipboardHistory.shared.clear()
        showClipboardPanel() // refresh empty state
        showNotice("تم مسح سجل الحافظة")
    }

    @objc func clipboardCloseTapped() {
        hideClipboardPanel()
    }

    @objc func dismissKeyboardAction() { dismissKeyboard() }
}
