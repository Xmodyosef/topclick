import UIKit

// MARK: - KeyboardViewController + Clipboard
extension KeyboardViewController {
    @objc func copyPasteHold(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            clipboardLongPressInProgress = true
            guard hasFullAccess else {
                showNotice("الحافظة تحتاج تفعيل الوصول الكامل للوحة")
                return
            }
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

    func showClipboardPanel() {
        hideClipboardPanel()
        hideHoldPopup()

        let panel = UIView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.backgroundColor = UIColor(white: 0.07, alpha: 0.94)
        panel.layer.cornerRadius = 12
        panel.layer.cornerCurve = .continuous
        panel.clipsToBounds = true
        panel.accessibilityViewIsModal = true

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

        let header = UIStackView()
        header.axis = .horizontal
        header.spacing = 6
        header.alignment = .center

        let title = UILabel()
        title.text = "الحافظة"
        title.textColor = .white
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let pasteLive = makeClipboardActionButton(title: "لصق", action: #selector(clipboardPasteLiveTapped))
        pasteLive.accessibilityLabel = "لصق من الحافظة الحية"
        let clearBtn = makeClipboardActionButton(title: "مسح", action: #selector(clipboardClearTapped), destructive: true)
        clearBtn.accessibilityLabel = "مسح سجل الحافظة"
        let closeBtn = makeClipboardActionButton(title: "إغلاق", action: #selector(clipboardCloseTapped))
        closeBtn.accessibilityLabel = "إغلاق لوحة الحافظة"

        header.addArrangedSubview(title)
        header.addArrangedSubview(pasteLive)
        header.addArrangedSubview(clearBtn)
        header.addArrangedSubview(closeBtn)
        stack.addArrangedSubview(header)

        if hasFullAccess, let live = UIPasteboard.general.string, !live.isEmpty {
            let livePreview = live.count > 64 ? String(live.prefix(64)) + "…" : live
            let liveBtn = UIButton(type: .system)
            var liveCfg = UIButton.Configuration.plain()
            liveCfg.title = "حية: \(livePreview)"
            liveCfg.baseForegroundColor = UIColor(red: 0.55, green: 0.82, blue: 1.0, alpha: 1)
            liveCfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.font = .systemFont(ofSize: 12, weight: .medium)
                return out
            }
            liveCfg.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10)
            liveCfg.background.backgroundColor = UIColor.white.withAlphaComponent(0.08)
            liveCfg.background.cornerRadius = 8
            liveBtn.configuration = liveCfg
            liveBtn.contentHorizontalAlignment = .leading
            liveBtn.accessibilityLabel = "لصق محتوى الحافظة الحية"
            liveBtn.addTarget(self, action: #selector(clipboardPasteLiveTapped), for: .touchUpInside)
            liveBtn.heightAnchor.constraint(greaterThanOrEqualToConstant: 34).isActive = true
            stack.addArrangedSubview(liveBtn)
        }

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
                var rowCfg = UIButton.Configuration.plain()
                rowCfg.title = preview
                rowCfg.baseForegroundColor = .white
                rowCfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var out = incoming
                    out.font = .systemFont(ofSize: 13, weight: .medium)
                    return out
                }
                rowCfg.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
                rowCfg.background.backgroundColor = UIColor.white.withAlphaComponent(0.10)
                rowCfg.background.cornerRadius = 8
                row.configuration = rowCfg
                row.contentHorizontalAlignment = .leading
                row.tag = index
                row.accessibilityLabel = "لصق عنصر محفوظ"
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
        let maxH = panel.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.72)
        maxH.priority = .required
        maxH.isActive = true

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
        let color = destructive ? UIColor(red: 1, green: 0.45, blue: 0.45, alpha: 1) : UIColor.white
        var cfg = UIButton.Configuration.plain()
        cfg.title = title
        cfg.baseForegroundColor = color
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 12, weight: .semibold)
            return out
        }
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        cfg.background.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        cfg.background.cornerRadius = 8
        b.configuration = cfg
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    @objc func clipboardItemTapped(_ sender: UIButton) {
        let items = ClipboardHistory.shared.items
        guard items.indices.contains(sender.tag) else { return }
        let text = items[sender.tag]
        textDocumentProxy.insertText(text)
        playSystemClick(.rowMid)
        showNotice("تم اللصق")
        tapHaptic()
    }

    @objc func clipboardPasteLiveTapped() {
        pasteNow()
    }

    @objc func clipboardClearTapped() {
        ClipboardHistory.shared.clear()
        showClipboardPanel()
        showNotice("تم مسح سجل الحافظة")
    }

    @objc func clipboardCloseTapped() {
        hideClipboardPanel()
    }
}
