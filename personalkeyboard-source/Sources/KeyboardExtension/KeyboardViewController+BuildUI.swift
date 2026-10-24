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
        guard view.bounds.width > 0 else { return }
        let compact = view.bounds.width < 500
        let desiredHeight: CGFloat
        if page == .emoji { desiredHeight = compact ? 300 : 280 }
        else { desiredHeight = compact ? boardHeight : 270 }
        if heightConstraint == nil {
            let c = view.heightAnchor.constraint(equalToConstant: desiredHeight)
            c.priority = UILayoutPriority(999)
            c.isActive = true
            heightConstraint = c
        } else if abs((heightConstraint?.constant ?? 0) - desiredHeight) > 0.5 {
            heightConstraint?.constant = desiredHeight
        }
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
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        rootStack.axis = .vertical
        rootStack.spacing = 5
        rootStack.distribution = .fill
        rootStack.alignment = .fill
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            rootStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
            rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4)
        ])
        rootStack.setContentHuggingPriority(.defaultHigh, for: .vertical)
        rootStack.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    func rebuild() {
        emojiPager?.delegate = nil
        emojiPager = nil
        emojiTabs = nil
        palette = NaqraPalette.current()
        view.backgroundColor = palette.background
        blurView.effect = nil
        blurView.backgroundColor = palette.background
        rootStack.arrangedSubviews.forEach { rootStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        rootStack.spacing = 4
        let h: CGFloat = page == .letters ? boardHeight : 300
        heightConstraint?.constant = h
        switch page {
        case .letters:
            rootStack.addArrangedSubview(makeToolbar())
            if showNumberRow {
                rootStack.addArrangedSubview(makeRow(numberRow, rowIdx: 0))
            }
            let rows = language == .arabic
                ? (isShifted ? arabicShiftRows : arabicRows)
                : (isShifted ? englishUpper : englishLower)
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 { rootStack.addArrangedSubview(makeLastLetterRow(row)) }
                else { rootStack.addArrangedSubview(makeRow(row, rowIdx: i + 1)) }
            }
            addFlexSpace()
            rootStack.addArrangedSubview(makeBottom())
        case .symbols:
            let rowsCount: Int = {
                if let str = ThemeIO.string("symbolRows"), let n = Int(str) { return max(1, min(n, 4)) }
                let n = UserDefaults(suiteName: ThemeIO.group)?.integer(forKey: "symbolRows") ?? 0
                return n > 0 ? max(1, min(n, 4)) : 3
            }()
            let pages = symbolPages
            let pageIdx = min(max(symbolPageIndex, 0), max(pages.count - 1, 0))
            let allRows = pages.isEmpty ? [] : pages[pageIdx]
            var rows = Array(allRows.prefix(rowsCount)).filter { !$0.isEmpty }
            if rows.isEmpty {
                rows = language == .arabic ? KeyboardDataLoader.builtinArabicSymbols[0] : KeyboardDataLoader.builtinEnglishSymbols[0]
            }
            for (i, row) in rows.enumerated() {
                if i == rows.count - 1 { rootStack.addArrangedSubview(makeSymbolLastRow(row)) }
                else { rootStack.addArrangedSubview(makeRow(row, rowIdx: i + 1)) }
            }
            addFlexSpace()
            rootStack.addArrangedSubview(makeBottom())
        case .emoji:
            rootStack.addArrangedSubview(makeEmojiTabs())
            rootStack.addArrangedSubview(makeEmojiPager())
            addFlexSpace()
            rootStack.addArrangedSubview(makeBottom(emojiOn: true))
        }
    }
    func makeToolbar() -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.distribution = .fill
        s.semanticContentAttribute = .forceLeftToRight
        let clip = iconKey("doc.on.clipboard", #selector(copyPasteTapped))
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(copyPasteHold(_:)))
        holdGesture.minimumPressDuration = 0.38
        holdGesture.cancelsTouchesInView = true
        clip.addGestureRecognizer(holdGesture)
        clip.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(clip)

        // Suggestions in the middle of the toolbar
        let showSuggestions = ThemeIO.bool("suggestions") ?? true
        if showSuggestions {
            let sugg = suggestions()
            if !sugg.allSatisfy({ $0.isEmpty }) {
                let suggRow = makeSuggestionsRow()
                suggRow.setContentHuggingPriority(.defaultLow, for: .horizontal)
                s.addArrangedSubview(suggRow)
            } else {
                let spacer = UIView()
                s.addArrangedSubview(spacer)
            }
        } else {
            let spacer = UIView()
            s.addArrangedSubview(spacer)
        }

        let tr = iconKey("translate", #selector(translateTapped))
        tr.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(tr)
        let hide = iconKey("keyboard.chevron.compact.down", #selector(dismissKeyboardAction))
        hide.widthAnchor.constraint(equalToConstant: 36).isActive = true
        s.addArrangedSubview(hide)
        s.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return s
    }
    func makeRow(_ keys: [String], rowIdx: Int) -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        s.heightAnchor.constraint(equalToConstant: 46).isActive = true
        s.distribution = .fillEqually
        s.semanticContentAttribute = .forceLeftToRight
        keys.forEach { s.addArrangedSubview(charKey($0, rowIdx: rowIdx)) }
        lockHeight(s, 46)
        return s
    }
    func addFlexSpace() {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.init(1), for: .vertical)
        spacer.setContentCompressionResistancePriority(.init(1), for: .vertical)
        rootStack.addArrangedSubview(spacer)
    }
    func makeLastLetterRow(_ keys: [String]) -> UIView {
        makeActionRow(keys, leading: language == .arabic ? .symbols : .shift)
    }
    func makeSymbolLastRow(_ keys: [String]) -> UIView {
        // Back-to-letters stays on the bottom bar, so these keys keep a full width.
        makeActionRow(keys, leading: .none)
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
            paint(shift, emphasized: isShifted)
            wrap.addArrangedSubview(shift)
        case .symbols:
            let symbols = control("١٢٣", #selector(symbolsOrLettersTapped), font: 13)
            symbols.widthAnchor.constraint(equalToConstant: 46).isActive = true
            symbols.accessibilityLabel = "رموز"
            wrap.addArrangedSubview(symbols)
        case .letters:
            let letters = control("أبج", #selector(symbolsOrLettersTapped), font: 14)
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
        keys.forEach { mid.addArrangedSubview(charKey($0, rowIdx: 2)) }
        wrap.addArrangedSubview(mid)
        wrap.addArrangedSubview(makeDeleteKey())
        lockHeight(wrap, 44)
        return wrap
    }
    func makeDeleteKey() -> UIButton {
        let del = iconKey("delete.left", #selector(deleteTouchUp))
        del.addTarget(self, action: #selector(deleteTouchDown), for: .touchDown)
        del.addTarget(self, action: #selector(deleteTouchCancel), for: [.touchUpOutside, .touchCancel])
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragInside)
        del.addTarget(self, action: #selector(deleteDrag(_:event:)), for: .touchDragOutside)
        del.widthAnchor.constraint(equalToConstant: 54).isActive = true
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
        if page == .emoji || page == .symbols {
            let backTitle = page == .emoji ? "رجوع" : (language == .arabic ? "أبج" : "ABC")
            let back = control(backTitle, #selector(symbolsOrLettersTapped), font: 12)
            back.accessibilityLabel = "رجوع للحروف"
            leading.append(back)
        } else if language == .english {
            let symbols = control("123", #selector(symbolsOrLettersTapped), font: 12)
            symbols.accessibilityLabel = "رموز"
            leading.append(symbols)
        }
        let langTitle = language == .arabic ? "EN" : "ع"
        let lang = control(langTitle, #selector(languageTapped), font: language == .arabic ? 14 : 16)
        lang.accessibilityLabel = "تغيير اللغة"
        leading.append(lang)
        for button in leading {
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        }


        let emoji = UIButton(type: .system)
        emoji.setTitle("😊", for: .normal)
        emoji.titleLabel?.font = .systemFont(ofSize: 19)
        paint(emoji)
        emoji.addTarget(self, action: #selector(emojiTapped), for: .touchUpInside)
        emoji.widthAnchor.constraint(equalToConstant: 32).isActive = true
        emoji.accessibilityLabel = "لوحة الرموز التعبيرية"

        let space = control("", #selector(spaceTouchUp), font: 14)
        space.addTarget(self, action: #selector(spaceTouchDown(_:event:)), for: .touchDown)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragInside)
        space.addTarget(self, action: #selector(spaceDrag(_:event:)), for: .touchDragOutside)
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        space.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let minimumSpace = space.widthAnchor.constraint(greaterThanOrEqualToConstant: 74)
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
            let period = control(".", #selector(periodTapped), font: 18)
            period.widthAnchor.constraint(equalToConstant: 32).isActive = true
            row.addArrangedSubview(period)
        }
        row.addArrangedSubview(enter)
        lockHeight(row, 44)
        return row
    }
    func paint(_ b: UIButton, emphasized: Bool = false) {
        b.backgroundColor = emphasized ? palette.accent.withAlphaComponent(0.72) : palette.key
        b.setTitleColor(emphasized ? .white : palette.text, for: .normal)
        b.tintColor = emphasized ? .white : palette.text
        b.layer.cornerRadius = 10 // Radius.key
        b.layer.cornerCurve = .continuous
        b.layer.borderWidth = 0.6
        let line = palette.blurDark ? UIColor.white.withAlphaComponent(0.20) : UIColor.black.withAlphaComponent(0.10)
        b.layer.borderColor = line.cgColor
        // Shadows on every key force extra offscreen compositing in the extension.
        b.layer.shadowOpacity = 0
        b.clipsToBounds = true
    }
    func iconKey(_ name: String, _ a: Selector) -> UIButton {
        let b = UIButton(type: .system)
        let symbol = UIImage(systemName: name, withConfiguration: iconConfig)
            ?? UIImage(systemName: fallbackSymbol(name), withConfiguration: iconConfig)
        b.setImage(symbol, for: .normal)
        paint(b, emphasized: name.contains("shift.fill") && isShifted)
        b.addTarget(self, action: a, for: .touchUpInside)
        return b
    }
}
