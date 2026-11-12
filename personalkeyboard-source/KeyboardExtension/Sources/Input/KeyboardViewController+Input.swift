import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Input (suggestions, language, shift, delete, space, enter; no autocorrect)
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
        if current == words { return }
        if current.isEmpty && words.isEmpty { return }
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

    @objc func languageTapped() {
        language = language == .arabic ? .english : .arabic
        isShifted = false
        symbolPageIndex = 0
        if page == .emoji { page = .letters }
        saveLanguage()
        rebuild()
        tapHaptic(.action)
        let announce = language == .arabic ? "العربية" : "English"
        UIAccessibility.post(notification: .announcement, argument: announce)
    }

    @objc func shiftTapped() {
        isShifted.toggle()
        applyShiftSurface()
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
        textDocumentProxy.insertText(" ")
        playSystemClick(.space)
        tapHaptic()
    }

    @objc func enterTapped() {
        textDocumentProxy.insertText("\n")
        playSystemClick(.enter)
        tapHaptic(.action)
    }

    @objc func dismissKeyboardAction() { dismissKeyboard() }
}
