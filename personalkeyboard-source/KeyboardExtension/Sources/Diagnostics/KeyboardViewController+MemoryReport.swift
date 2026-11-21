import UIKit

extension KeyboardViewController {
    @objc func memoryReportTapped() {
        if memoryPanel != nil {
            dismissMemoryPanel()
            return
        }
        presentMemoryPanel()
    }

    @objc func memoryReportHold(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        textDocumentProxy.insertText(LanguageDiagnostics.oneLine())
        showNotice("أُدخل التقرير في النص")
    }

    func presentMemoryPanel() {
        dismissMemoryPanel()
        let panel = UIView()
        panel.backgroundColor = UIColor.black.withAlphaComponent(0.92)
        panel.layer.cornerRadius = 14
        panel.layer.cornerCurve = .continuous
        panel.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.tag = 7701
        label.text = LanguageDiagnostics.report()
        label.textColor = .white
        label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false

        let insert = reportButton("أدخل", #selector(memoryInsertTapped))
        let cycle = reportButton(LanguageDiagnostics.mode.title, #selector(memoryModeTapped))
        cycle.tag = 7702
        let reset = reportButton("صفر", #selector(memoryResetTapped))
        let row = UIStackView(arrangedSubviews: [insert, cycle, reset])
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false

        panel.addSubview(label)
        panel.addSubview(row)
        view.addSubview(panel)
        NSLayoutConstraint.activate([
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            panel.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: panel.topAnchor, constant: 10),
            row.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -12),
            row.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            row.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -10),
            row.heightAnchor.constraint(equalToConstant: 32)
        ])
        memoryPanel = panel
    }

    func dismissMemoryPanel() {
        memoryPanel?.removeFromSuperview()
        memoryPanel = nil
    }

    @objc func memoryInsertTapped() {
        textDocumentProxy.insertText(LanguageDiagnostics.oneLine())
        showNotice("أُدخل التقرير في النص")
    }

    @objc func memoryModeTapped() {
        let next = LanguageDiagnostics.mode.next
        LanguageDiagnostics.mode = next
        reapplyVisibleFonts()
        if let label = memoryPanel?.viewWithTag(7701) as? UILabel {
            label.text = LanguageDiagnostics.report()
        }
        if let cycle = memoryPanel?.viewWithTag(7702) as? UIButton {
            cycle.setTitle(next.title, for: .normal)
        }
        showNotice(next.title)
    }

    @objc func memoryResetTapped() {
        LanguageDiagnostics.resetCounts()
        if let label = memoryPanel?.viewWithTag(7701) as? UILabel {
            label.text = LanguageDiagnostics.report()
        }
    }

    func reapplyVisibleFonts() {
        for row in letterKeyButtons {
            for button in row {
                guard let title = button.title(for: .normal), !title.isEmpty, !button.isHidden else { continue }
                button.titleLabel?.font = keyDisplayFont(for: title)
            }
        }
        for button in suggestionButtons {
            guard let word = button.title(for: .normal), !word.isEmpty else { continue }
            button.titleLabel?.font = KeyboardTypography.font(for: word, size: 14, weight: .semibold)
        }
    }

    func reportButton(_ title: String, _ action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
