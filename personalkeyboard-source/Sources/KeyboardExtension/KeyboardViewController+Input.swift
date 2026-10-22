import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Input
extension KeyboardViewController {
    func saveLanguage() { ThemeIO.write("lastLanguage", value: language == .english ? "en" : "ar") }
    func makeSuggestionsRow() -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        s.semanticContentAttribute = .forceLeftToRight
        suggestionButtons = []
        for (i, word) in suggestions().enumerated() {
            let b = UIButton(type: .system)
            b.tag = i
            b.setTitle(word, for: .normal)
            b.isEnabled = !word.isEmpty
            b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            b.titleLabel?.adjustsFontSizeToFitWidth = true
            b.titleLabel?.minimumScaleFactor = 0.7
            b.setTitleColor(palette.text, for: .normal)
            b.backgroundColor = palette.key.withAlphaComponent(word.isEmpty ? 0.35 : 1)
            b.layer.cornerRadius = 10 // Radius.key
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
        let code = language == .english ? "en_US" : "ar"
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: token.utf16.count)
        let completions = checker.completions(forPartialWordRange: range, in: token, language: code) ?? []
        let guesses = checker.guesses(forWordRange: range, in: token, language: code) ?? []
        var out: [String] = []
        for w in (completions + guesses) where !out.contains(w) && w.caseInsensitiveCompare(token) != .orderedSame {
            out.append(w)
            if out.count == 3 { break }
        }
        if language == .arabic {
            let folded = Self.fold(token)
            for w in Self.arabicLexicon {
                if out.count == 3 { break }
                if Self.fold(w).hasPrefix(folded) && Self.fold(w) != folded && !out.contains(w) {
                    out.append(w)
                }
            }
        }
        while out.count < 3 { out.append("") }
        return out
    }
    func refreshSuggestions() {
        let words = suggestions()
        guard suggestionButtons.count == words.count else { return }
        for (button, word) in zip(suggestionButtons, words) {
            button.setTitle(word, for: .normal)
            button.isEnabled = !word.isEmpty
            button.backgroundColor = word.isEmpty ? .clear : palette.key
        }
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
        let b = UIButton(type: .system)
        b.setTitle(t, for: .normal)
        b.titleLabel?.font = letterFont
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.7
        paint(b)
        b.tag = rowIdx
        b.addTarget(self, action: #selector(charDown(_:)), for: .touchDown)
        b.addTarget(self, action: #selector(charDrag(_:event:)), for: .touchDragInside)
        b.addTarget(self, action: #selector(charDrag(_:event:)), for: .touchDragOutside)
        b.addTarget(self, action: #selector(charUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return b
    }
    @objc func charDown(_ sender: UIButton) {
        holdChoice = sender.title(for: .normal) ?? ""
        holdTimer?.invalidate()
        hideHoldPopup()
        guard let key = sender.title(for: .normal), !alts(for: key).isEmpty else { return }
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.38, repeats: false) { [weak self] _ in
            self?.showHoldPopup(from: sender)
        }
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
        let text = holdPopup != nil ? holdChoice : (sender.title(for: .normal) ?? "")
        hideHoldPopup()
        guard !text.isEmpty else { return }
        textDocumentProxy.insertText(text)
        let row = sender.tag
        let sound: TapSoundEngine.Sound = row == 0 ? .rowTop : (row == 1 ? .rowMid : .rowBot)
        playSystemClick(sound)
        tapHaptic()
        if page == .letters, language == .english, isShifted {
            isShifted = false
            rebuild()
        }
    }
    func showHoldPopup(from button: UIButton) {
        guard let key = button.title(for: .normal) else { return }
        let items = alts(for: key)
        guard !items.isEmpty else { return }
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
        NSLayoutConstraint.activate([
            bar.bottomAnchor.constraint(equalTo: view.topAnchor, constant: max(frame.minY - 6, 50)),
            bar.heightAnchor.constraint(equalToConstant: 44)
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
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            self?.deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { [weak self] _ in
                self?.textDocumentProxy.deleteBackward()
            }
        }
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
            let arabicFixes = ["هاذا": "هذا", "هاذه": "هذه", "هاذ": "هذا", "الذيي": "الذي", "اللذي": "الذي", "انشاءالله": "إن شاء الله", "شكراا": "شكرًا", "مساءا": "مساءً"]
            fix = arabicFixes[token]
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
                showNotice("لصق الحافظة يحتاج تفعيل الوصول الكامل للوحة")
                return
            }
            let items = ClipboardHistory.shared.items
            guard !items.isEmpty else {
                pasteNow()
                return
            }
            let sheet = UIAlertController(title: "الحافظة المحفوظة", message: "تُخزّن محليًا على هذا الجهاز", preferredStyle: .actionSheet)
            for item in items.prefix(8) {
                let title = item.count > 40 ? String(item.prefix(40)) + "…" : item
                sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                    self?.textDocumentProxy.insertText(item)
                })
            }
            sheet.addAction(UIAlertAction(title: "مسح السجل", style: .destructive) { _ in
                ClipboardHistory.shared.clear()
            })
            sheet.addAction(UIAlertAction(title: "إلغاء", style: .cancel))
            if let pop = sheet.popoverPresentationController {
                pop.sourceView = view
                pop.sourceRect = CGRect(x: view.bounds.midX, y: 40, width: 1, height: 1)
            }
            present(sheet, animated: true)
        case .ended, .cancelled, .failed:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.clipboardLongPressInProgress = false
            }
        default:
            break
        }
    }
    @objc func dismissKeyboardAction() { dismissKeyboard() }
}
