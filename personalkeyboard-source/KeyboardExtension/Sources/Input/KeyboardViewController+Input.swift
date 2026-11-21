import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Input (language, shift, delete, space, enter)
extension KeyboardViewController {
    func saveLanguage() { ThemeIO.set("lastLanguage", value: language == .english ? "en" : "ar") }
    func resetSpaceTapSequence() { lastSpaceTap = nil }

    /// Suggestions and autocorrect are removed. Call sites stay as no-ops.
    func refreshSuggestions() {}

    func scheduleLanguageRebuild() {
        guard !languageRebuildScheduled else { return }
        languageRebuildScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.languageRebuildScheduled = false
            // One variable: rebuild() instead of in-place retitle. Font path stays as-is.
            if LanguageDiagnostics.mode == .rebuild {
                let before = LanguageDiagnostics.begin()
                let themeBefore = self.themeSignature
                let chromeBefore = self.mountedChromeKey
                self.rebuild()
                self.view.layoutIfNeeded()
                LanguageDiagnostics.mark("rebuild", before: before, note: self.stabilityNote(themeBefore: themeBefore, chromeBefore: chromeBefore))
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
        let themeBefore = themeSignature
        let chromeBefore = mountedChromeKey
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
        view.layoutIfNeeded()
        LanguageDiagnostics.mark("remount", before: before, note: stabilityNote(themeBefore: themeBefore, chromeBefore: chromeBefore))
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
