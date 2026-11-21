import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Input (suggestions, language, shift, delete, space, enter; no autocorrect)
extension KeyboardViewController {
    func saveLanguage() { ThemeIO.set("lastLanguage", value: language == .english ? "en" : "ar") }
    func resetSpaceTapSequence() { lastSpaceTap = nil }

    func makeSuggestionsRow(words: [String]? = nil) -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        s.semanticContentAttribute = .forceLeftToRight
        s.backgroundColor = .clear
        suggestionButtons = []
        // Always three slots so refreshSuggestions can retitle in place (no toolbar rebuild).
        var list = words ?? suggestions()
        while list.count < 3 { list.append("") }
        if list.count > 3 { list = Array(list.prefix(3)) }
        for (i, word) in list.enumerated() {
            let b = UIButton(type: .system)
            b.tag = i
            let empty = word.isEmpty
            b.setTitle(empty ? "" : word, for: .normal)
            b.isEnabled = !empty
            b.isHidden = empty
            b.accessibilityElementsHidden = empty
            if !empty {
                b.titleLabel?.font = KeyboardTypography.font(for: word, size: 14, weight: .semibold)
            }
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
            let checker = textChecker
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

    /// Update suggestion titles on existing buttons. Never tears down the toolbar.
    /// A one-time toolbar rebuild is allowed only when suggestions are enabled and
    /// the three stable slots were never created (first enable after launch).
    func refreshSuggestions() {
        guard page == .letters else { return }
        let show = ThemeIO.bool("suggestions") ?? false
        if !show {
            if !suggestionButtons.isEmpty {
                for button in suggestionButtons {
                    button.setTitle("", for: .normal)
                    button.isHidden = true
                    button.isEnabled = false
                    button.accessibilityElementsHidden = true
                }
            }
            return
        }
        var words = suggestions()
        while words.count < 3 { words.append("") }
        if words.count > 3 { words = Array(words.prefix(3)) }

        if suggestionButtons.count >= 3 {
            applySuggestionTitles(words)
            return
        }

        // Structure missing (toolbar used a spacer). Build once; later updates stay in place.
        let anyWord = words.contains { !$0.isEmpty }
        guard anyWord, let old = topChrome, old.superview === rootStack else { return }
        rootStack.removeArrangedSubview(old)
        old.removeFromSuperview()
        let bar = makeToolbar()
        rootStack.insertArrangedSubview(bar, at: 0)
        topChrome = bar
    }

    func applySuggestionTitles(_ words: [String]) {
        let count = min(3, suggestionButtons.count)
        for i in 0..<count {
            let word = i < words.count ? words[i] : ""
            let button = suggestionButtons[i]
            let empty = word.isEmpty
            let previous = button.title(for: .normal) ?? ""
            if previous != word {
                button.setTitle(empty ? "" : word, for: .normal)
                if !empty {
                    button.titleLabel?.font = KeyboardTypography.font(for: word, size: 14, weight: .semibold)
                    button.setTitleColor(palette.text, for: .normal)
                }
            }
            button.isHidden = empty
            button.isEnabled = !empty
            button.accessibilityElementsHidden = empty
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

    func scheduleLanguageRebuild() {
        guard !languageRebuildScheduled else { return }
        languageRebuildScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.languageRebuildScheduled = false
            // One variable: rebuild() instead of in-place retitle. Font path stays as-is.
            if LanguageDiagnostics.mode == .rebuild {
                let before = LanguageDiagnostics.begin()
                self.rebuild()
                LanguageDiagnostics.mark("rebuild", before: before)
                NSLog("[Naqra.Keyboard] language full rebuild: %@", String(describing: self.language))
                return
            }
            if self.applyLanguageSurface() {
                NSLog("[Naqra.Keyboard] language surface retitle: %@", String(describing: self.language))
                return
            }
            // Letters and symbols: replace the middle rows only.
            // Full chrome rebuild() is intentionally not invoked on this path.
            if self.page == .letters || self.page == .symbols {
                NSLog("[Naqra.Keyboard] language middle remount: %@", String(describing: self.language))
                self.remountLetterMiddleForLanguage()
                return
            }
            self.refreshKeptChromeTitles()
        }
    }

    /// Re-fill the letter grid in place without discarding the top/bottom chrome.
    func remountLetterMiddleForLanguage() {
        let before = LanguageDiagnostics.begin()
        hideKeyPreview()
        hideHoldPopup()
        hideClipboardPanel()
        autoreleasepool {
            clearMiddle()
            fillMiddle()
        }
        refreshKeptChromeTitles()
        refreshSuggestions()
        mountedChromeKey = surfaceChromeKey()
        updateHeightForCurrentSize()
        view.setNeedsLayout()
        LanguageDiagnostics.mark("remount", before: before)
    }

    func toggleLanguage(returnToLetters: Bool = false) {
        language = language == .arabic ? .english : .arabic
        primaryLanguage = language == .arabic ? "ar" : "en"
        isShifted = false
        symbolPageIndex = 0
        if returnToLetters && page != .emoji {
            page = .letters
        }
        saveLanguage()
        scheduleLanguageRebuild()
    }

    @objc func languageTapped() {
        resetSpaceTapSequence()
        toggleLanguage()
        tapHaptic(.action)
        let announce = language == .arabic ? "العربية" : "English"
        UIAccessibility.post(notification: .announcement, argument: announce)
    }

    @objc func shiftTapped() {
        resetSpaceTapSequence()
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
            // Dynamic sign: Arabic/RTL keyboard flips visual drag vs logical caret offset.
            let writingDirectionSign = language == .arabic ? -1 : 1
            let step = (delta > 0 ? 1 : -1) * writingDirectionSign
            textDocumentProxy.adjustTextPosition(byCharacterOffset: step)
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
            // Drop the space the first tap already inserted — language switch only.
            textDocumentProxy.deleteBackward()
            toggleLanguage(returnToLetters: true)
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
