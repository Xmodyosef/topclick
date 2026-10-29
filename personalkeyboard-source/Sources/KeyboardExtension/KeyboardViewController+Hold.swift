import UIKit

// MARK: - KeyboardViewController + Hold (long-press + char press)
extension KeyboardViewController {
    func charKey(_ t: String, rowIdx: Int) -> UIButton {
        let b = KeyButton(type: .system)
        b.setTitle(t, for: .normal)
        b.titleLabel?.font = letterFont
        b.titleLabel?.adjustsFontSizeToFitWidth = true
        b.titleLabel?.minimumScaleFactor = 0.7
        paint(b)
        b.tag = rowIdx
        b.accessibilityLabel = t
        let alts = holdChoices(for: t)
        if alts.count > 1 {
            b.accessibilityHint = language == .arabic
                ? "اضغط مطولاً لبدائل وحركات"
                : "Long press for alternates"
        }
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
        let timer = Timer(timeInterval: SharedKeyboardData.holdDelaySeconds(), repeats: false) { [weak self] _ in
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
            b.backgroundColor = inside ? palette.accent.withAlphaComponent(0.40) : .clear
            if inside { holdChoice = b.title(for: .normal) ?? holdChoice }
        }
    }

    /// Drops the letter typed on touch-down so a long-press choice replaces it instead of repeating it.
    func undoProvisionalInsert() {
        guard !downText.isEmpty else {
            pendingInserted = false
            return
        }
        let before = textDocumentProxy.documentContextBeforeInput ?? ""
        if before.hasSuffix(downText) {
            for _ in 0..<downText.count {
                textDocumentProxy.deleteBackward()
            }
        } else if pendingInserted {
            textDocumentProxy.deleteBackward()
        }
        pendingInserted = false
    }

    @objc func charUp(_ sender: UIButton) {
        holdTimer?.invalidate()
        holdTimer = nil
        if holdPopup != nil {
            let text = holdChoice.isEmpty ? downText : holdChoice
            hideHoldPopup()
            undoProvisionalInsert()
            if !text.isEmpty { textDocumentProxy.insertText(text) }
            tapHaptic(.action)
        } else if !pendingInserted {
            let text = sender.title(for: .normal) ?? downText
            if !text.isEmpty { textDocumentProxy.insertText(text) }
        }
        pendingInserted = false
        if page == .letters, language == .english, isShifted {
            isShifted = false
            applyShiftSurface()
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

    func showHoldPopup(from button: UIButton) {
        guard let key = button.title(for: .normal) else { return }
        let items = holdChoices(for: key)
        guard items.count > 1 else { return }
        undoProvisionalInsert()
        hideHoldPopup()
        let bar = UIStackView()
        bar.axis = .horizontal
        bar.spacing = 4
        bar.alignment = .center
        bar.translatesAutoresizingMaskIntoConstraints = false
        let popupBG = mix(palette.key, palette.background, t: 0.18).withAlphaComponent(1)
        let popupFG = palette.text
        bar.backgroundColor = popupBG
        bar.layer.cornerRadius = 10
        bar.layer.cornerCurve = .continuous
        bar.layer.borderWidth = 1
        bar.layer.borderColor = (palette.blurDark ? UIColor.white.withAlphaComponent(0.18) : UIColor.black.withAlphaComponent(0.12)).cgColor
        bar.isLayoutMarginsRelativeArrangement = true
        bar.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        holdChoice = items[0]
        for (i, item) in items.enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(item, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
            b.setTitleColor(popupFG, for: .normal)
            b.backgroundColor = i == 0 ? palette.accent.withAlphaComponent(0.35) : .clear
            b.layer.cornerRadius = 10
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            b.configuration = config
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
}
