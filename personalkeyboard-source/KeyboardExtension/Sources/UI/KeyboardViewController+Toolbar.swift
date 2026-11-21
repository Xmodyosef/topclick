import UIKit

// MARK: - KeyboardViewController + Toolbar
extension KeyboardViewController {
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

        // Suggestions: three stable slots when enabled so language/text updates retitle
        // in place. Empty slots stay hidden (no blank white strip, no toolbar rebuild).
        let showSuggestions = ThemeIO.bool("suggestions") ?? false
        if showSuggestions {
            let suggRow = makeSuggestionsRow(words: suggestions())
            suggRow.setContentHuggingPriority(.defaultLow, for: .horizontal)
            s.addArrangedSubview(suggRow)
        } else {
            suggestionButtons = []
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
        let mem = iconKey("speedometer", #selector(memoryReportTapped))
        mem.accessibilityLabel = "تقرير الذاكرة"
        mem.widthAnchor.constraint(equalToConstant: 36).isActive = true
        let memHold = UILongPressGestureRecognizer(target: self, action: #selector(memoryReportHold(_:)))
        memHold.minimumPressDuration = 0.38
        memHold.cancelsTouchesInView = true
        mem.addGestureRecognizer(memHold)
        s.addArrangedSubview(mem)

        let hide = iconKey("keyboard.chevron.compact.down", #selector(dismissKeyboardAction))
        hide.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(hide)
        lockHeight(s, 34)
        return s
    }

}
