import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - LTR emoji grid layout (never mirror cell order under Arabic UI)
final class LTREmojiFlowLayout: UICollectionViewFlowLayout {
    /// Keep leading→trailing order fixed even when the keyboard is Arabic RTL
    /// (PrefersRightToLeft=true on the extension does not mirror the emoji grid).
    override var flipsHorizontallyInOppositeLayoutDirection: Bool { false }
    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection { .leftToRight }
}

// MARK: - KeyboardViewController + Emoji
extension KeyboardViewController {
    /// One grid only (current category). Multiple CollectionViews exhaust keyboard-extension memory
    /// and silently drop categories — that is why emoji looked "incomplete".
    func makeEmojiTabs() -> UIView {
        let wrap = UIStackView()
        wrap.axis = .horizontal
        wrap.spacing = 6
        // Tabs follow keyboard language (RTL Arabic, LTR English).
        wrap.semanticContentAttribute = language == .arabic ? .forceRightToLeft : .forceLeftToRight
        let scroller = UIScrollView()
        scroller.showsHorizontalScrollIndicator = false
        scroller.semanticContentAttribute = wrap.semanticContentAttribute
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.semanticContentAttribute = wrap.semanticContentAttribute
        s.translatesAutoresizingMaskIntoConstraints = false
        scroller.addSubview(s)
        emojiTabs = s
        for (i, pack) in emojiPack.enumerated() {
            let b = control(pack.icon, #selector(emojiTab(_:)), font: 18, chrome: .emoji)
            b.tag = i
            b.backgroundColor = i == emojiCategoryIndex
                ? palette.accent.withAlphaComponent(0.55)
                : palette.key.withAlphaComponent(0.55)
            b.widthAnchor.constraint(equalToConstant: 38).isActive = true
            s.addArrangedSubview(b)
        }
        NSLayoutConstraint.activate([
            s.leadingAnchor.constraint(equalTo: scroller.contentLayoutGuide.leadingAnchor, constant: 2),
            s.trailingAnchor.constraint(equalTo: scroller.contentLayoutGuide.trailingAnchor, constant: -2),
            s.topAnchor.constraint(equalTo: scroller.contentLayoutGuide.topAnchor),
            s.bottomAnchor.constraint(equalTo: scroller.contentLayoutGuide.bottomAnchor),
            s.heightAnchor.constraint(equalTo: scroller.frameLayoutGuide.heightAnchor)
        ])
        wrap.addArrangedSubview(scroller)
        lockHeight(wrap, 32)
        return wrap
    }

    func makeEmojiPager() -> UIView {
        let host = UIView()
        host.translatesAutoresizingMaskIntoConstraints = false
        host.clipsToBounds = true
        host.semanticContentAttribute = .forceLeftToRight
        lockHeight(host, emojiPagerHeight())

        let layout = LTREmojiFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.tag = 0
        cv.alwaysBounceVertical = true
        // Grid stays LTR in every language (Apple-like; never mirror in Arabic).
        cv.semanticContentAttribute = .forceLeftToRight
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: "e")
        cv.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: host.topAnchor),
            cv.bottomAnchor.constraint(equalTo: host.bottomAnchor),
            cv.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: host.trailingAnchor)
        ])
        emojiCollection = cv
        emojiPager = host
        // Horizontal pan switches categories — single CV only (no multi-CV / Jetsam).
        let pan = UIPanGestureRecognizer(target: self, action: #selector(emojiCategoryPanned(_:)))
        pan.delegate = self
        pan.maximumNumberOfTouches = 1
        pan.cancelsTouchesInView = false
        cv.addGestureRecognizer(pan)

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(emojiSkinLongPressed(_:)))
        longPress.minimumPressDuration = 0.40
        longPress.allowableMovement = 10
        longPress.delegate = self
        longPress.cancelsTouchesInView = true
        cv.addGestureRecognizer(longPress)
        emojiSkinLongPress = longPress

        return host
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Single vertical grid — no page index sync.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard emojiPack.indices.contains(emojiCategoryIndex) else { return 0 }
        return emojiPack[emojiCategoryIndex].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "e", for: indexPath) as! EmojiCell
        guard emojiPack.indices.contains(emojiCategoryIndex),
              emojiPack[emojiCategoryIndex].items.indices.contains(indexPath.item) else {
            cell.label.text = ""
            cell.paint(palette)
            return cell
        }
        cell.label.text = emojiPack[emojiCategoryIndex].items[indexPath.item]
        cell.paint(palette)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard emojiPack.indices.contains(emojiCategoryIndex),
              emojiPack[emojiCategoryIndex].items.indices.contains(indexPath.item) else { return }
        let base = emojiPack[emojiCategoryIndex].items[indexPath.item]
        hideEmojiSkinBar()
        let item = KeyboardDataLoader.resolvedEmoji(base)
        textDocumentProxy.insertText(item)
        playSystemClick(.emoji)
        rememberEmoji(item)
        tapHaptic()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = max(collectionView.bounds.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right, 1)
        let columns = max(1, Int(floor(width / 42)))
        let side = floor(width / CGFloat(columns))
        return CGSize(width: side, height: side)
    }

    @objc func emojiTab(_ sender: UIButton) {
        guard emojiPack.indices.contains(sender.tag) else { return }
        hideEmojiSkinBar()
        emojiCategoryIndex = sender.tag
        refreshTabs()
        resetEmojiGridTransform(animated: false)
        emojiCollection?.setContentOffset(.zero, animated: false)
        emojiCollection?.collectionViewLayout.invalidateLayout()
        emojiCollection?.reloadData()
    }

    @objc func emojiTapped() {
        if page == .emoji {
            page = .letters
        } else {
            page = .emoji
            emojiPack = Self.catalog()
            emojiCategoryIndex = min(emojiCategoryIndex, max(emojiPack.count - 1, 0))
        }
        rebuild()
        tapHaptic()
    }

    func refreshTabs() {
        guard let emojiTabs else { return }
        for (index, view) in emojiTabs.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }
            button.backgroundColor = index == emojiCategoryIndex
                ? palette.accent.withAlphaComponent(0.55)
                : palette.key.withAlphaComponent(0.55)
            button.accessibilityTraits = index == emojiCategoryIndex ? [.button, .selected] : [.button]
        }
        // Keep the selected tab visible in the horizontal strip.
        guard emojiTabs.arrangedSubviews.indices.contains(emojiCategoryIndex),
              let button = emojiTabs.arrangedSubviews[emojiCategoryIndex] as? UIButton,
              let scroll = button.superview?.superview as? UIScrollView else { return }
        let frame = button.convert(button.bounds, to: scroll)
        scroll.scrollRectToVisible(frame.insetBy(dx: -12, dy: 0), animated: true)
    }

    private func resetEmojiGridTransform(animated: Bool) {
        guard let host = emojiPager else { return }
        let apply = { host.transform = .identity }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.4, options: [.allowUserInteraction]) {
                apply()
            }
        } else {
            apply()
        }
    }

    /// Interactive horizontal scrub: full-width exit/enter, single CV, no reload while dragging.
    @objc func emojiCategoryPanned(_ gesture: UIPanGestureRecognizer) {
        guard let host = emojiPager else { return }
        let translation = gesture.translation(in: host)
        let velocity = gesture.velocity(in: host)
        let width = max(host.bounds.width, 1)

        switch gesture.state {
        case .began:
            hideEmojiSkinBar()
            emojiCollection?.isScrollEnabled = false
            // Lightweight snapshot rides with the pan; live grid reloads only after the swipe ends.
            if emojiSwipeSnapshot == nil, let snap = host.snapshotView(afterScreenUpdates: false) {
                snap.frame = host.bounds
                snap.isUserInteractionEnabled = false
                host.addSubview(snap)
                emojiSwipeSnapshot = snap
            }

        case .changed:
            var tx = translation.x
            let atStart = emojiCategoryIndex <= 0
            let atEnd = emojiCategoryIndex >= emojiPack.count - 1
            if (atStart && tx > 0) || (atEnd && tx < 0) {
                tx = tx * 0.28
            }
            host.transform = CGAffineTransform(translationX: tx, y: 0)

        case .ended, .cancelled:
            let dx = abs(velocity.x) > 280 ? velocity.x : translation.x
            let threshold = min(56, width * 0.18)
            var next = emojiCategoryIndex
            if dx <= -threshold, emojiCategoryIndex < emojiPack.count - 1 {
                next = emojiCategoryIndex + 1
            } else if dx >= threshold, emojiCategoryIndex > 0 {
                next = emojiCategoryIndex - 1
            }

            let finish = { [weak self] in
                guard let self else { return }
                self.emojiSwipeSnapshot?.removeFromSuperview()
                self.emojiSwipeSnapshot = nil
                self.emojiCollection?.isScrollEnabled = true
            }

            if next != emojiCategoryIndex {
                // Full-width exit, then enter from the opposite side (one reload only).
                let outX: CGFloat = dx < 0 ? -width : width
                UIView.animate(withDuration: 0.16, delay: 0, options: [.curveEaseIn]) {
                    host.transform = CGAffineTransform(translationX: outX, y: 0)
                } completion: { [weak self] _ in
                    guard let self else { return }
                    self.emojiCategoryIndex = next
                    self.refreshTabs()
                    self.emojiCollection?.setContentOffset(.zero, animated: false)
                    self.emojiCollection?.collectionViewLayout.invalidateLayout()
                    self.emojiCollection?.reloadData()
                    self.emojiSwipeSnapshot?.removeFromSuperview()
                    self.emojiSwipeSnapshot = nil
                    host.transform = CGAffineTransform(translationX: -outX, y: 0)
                    UIView.animate(withDuration: 0.22, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.35, options: [.curveEaseOut]) {
                        host.transform = .identity
                    } completion: { _ in
                        self.emojiCollection?.isScrollEnabled = true
                        self.tapHaptic(.action)
                        if self.emojiPack.indices.contains(next) {
                            UIAccessibility.post(notification: .announcement, argument: self.emojiPack[next].icon)
                        }
                    }
                }
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.86, initialSpringVelocity: 0.4, options: [.allowUserInteraction]) {
                    host.transform = .identity
                } completion: { _ in
                    finish()
                }
            }

        default:
            break
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UILongPressGestureRecognizer {
            // Allow long-press only when the grid is not mid-deceleration.
            if let cv = emojiCollection, cv.isDragging || cv.isDecelerating { return false }
            return true
        }
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        // Category pan must not steal vertical scroll.
        if gestureRecognizer !== emojiSkinLongPress {
            let v = pan.velocity(in: pan.view)
            let tr = pan.translation(in: pan.view)
            if abs(v.x) + abs(v.y) > 0 {
                return abs(v.x) > abs(v.y) * 1.25
            }
            return abs(tr.x) > abs(tr.y) * 1.25
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Skin long-press never shares with scroll/pan.
        if gestureRecognizer is UILongPressGestureRecognizer || otherGestureRecognizer is UILongPressGestureRecognizer {
            return false
        }
        return false
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView === emojiCollection {
            hideEmojiSkinBar()
        }
    }

    // MARK: - Emoji skin tones (Apple-like long-press)

    @objc func emojiSkinLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard page == .emoji, let cv = emojiCollection else { return }
        let loc = gesture.location(in: cv)
        switch gesture.state {
        case .began:
            guard let indexPath = cv.indexPathForItem(at: loc),
                  emojiPack.indices.contains(emojiCategoryIndex),
                  emojiPack[emojiCategoryIndex].items.indices.contains(indexPath.item) else {
                return
            }
            let base = emojiPack[emojiCategoryIndex].items[indexPath.item]
            guard let tones = KeyboardDataLoader.skinTones(for: base) else { return }
            emojiSkinBase = base
            cv.isScrollEnabled = false
            showEmojiSkinBar(tones: tones, from: indexPath, in: cv)
            tapHaptic(.action)
        case .changed:
            guard let bar = emojiSkinBar else { return }
            let p = gesture.location(in: bar)
            highlightSkinTone(at: p, in: bar)
        case .ended, .cancelled:
            defer {
                emojiCollection?.isScrollEnabled = true
            }
            guard let bar = emojiSkinBar else { return }
            let p = gesture.location(in: bar)
            if gesture.state == .ended, let idx = skinToneIndex(at: p, in: bar),
               let tones = KeyboardDataLoader.skinTones(for: emojiSkinBase),
               tones.indices.contains(idx) {
                KeyboardDataLoader.setPreferredSkinToneIndex(idx)
                let chosen = tones[idx]
                textDocumentProxy.insertText(chosen)
                playSystemClick(.emoji)
                rememberEmoji(chosen)
                tapHaptic()
            }
            hideEmojiSkinBar()
        default:
            break
        }
    }

    func showEmojiSkinBar(tones: [String], from indexPath: IndexPath, in cv: UICollectionView) {
        hideEmojiSkinBar()
        guard let cell = cv.cellForItem(at: indexPath) else { return }
        let host = view!
        let bar = UIView()
        bar.backgroundColor = palette.key
        bar.isOpaque = true
        bar.layer.cornerRadius = 12
        bar.layer.cornerCurve = .continuous
        bar.layer.borderWidth = 1
        bar.layer.borderColor = palette.accent.withAlphaComponent(0.35).cgColor
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOpacity = 0.18
        bar.layer.shadowRadius = 6
        bar.layer.shadowOffset = CGSize(width: 0, height: 2)
        bar.translatesAutoresizingMaskIntoConstraints = true

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(stack)

        var buttons: [UIButton] = []
        let preferred = KeyboardDataLoader.preferredSkinToneIndex()
        for (i, tone) in tones.prefix(6).enumerated() {
            let b = UIButton(type: .system)
            b.setTitle(tone, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 28)
            b.tag = i
            b.backgroundColor = (i == min(preferred, tones.count - 1))
                ? palette.accent.withAlphaComponent(0.28)
                : .clear
            b.layer.cornerRadius = 8
            b.addTarget(self, action: #selector(emojiSkinToneTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(b)
            buttons.append(b)
        }
        emojiSkinButtons = buttons

        let pad: CGFloat = 6
        let barW = min(host.bounds.width - 16, CGFloat(max(tones.count, 1)) * 44 + pad * 2)
        let barH: CGFloat = 48
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: pad),
            stack.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -pad),
            stack.topAnchor.constraint(equalTo: bar.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -4)
        ])

        let cellFrame = cell.convert(cell.bounds, to: host)
        var x = cellFrame.midX - barW / 2
        x = max(8, min(x, host.bounds.width - barW - 8))
        // Prefer above the cell; if not enough room (top row), place below.
        var y = cellFrame.minY - barH - 6
        if y < 4 {
            y = min(cellFrame.maxY + 6, host.bounds.height - barH - 4)
        }
        bar.frame = CGRect(x: x, y: y, width: barW, height: barH)
        host.addSubview(bar)
        emojiSkinBar = bar
    }

    @objc func emojiSkinToneTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard let tones = KeyboardDataLoader.skinTones(for: emojiSkinBase),
              tones.indices.contains(idx) else {
            hideEmojiSkinBar()
            return
        }
        KeyboardDataLoader.setPreferredSkinToneIndex(idx)
        let chosen = tones[idx]
        textDocumentProxy.insertText(chosen)
        playSystemClick(.emoji)
        rememberEmoji(chosen)
        tapHaptic()
        emojiCollection?.isScrollEnabled = true
        hideEmojiSkinBar()
    }

    func highlightSkinTone(at point: CGPoint, in bar: UIView) {
        guard let idx = skinToneIndex(at: point, in: bar) else { return }
        for (i, b) in emojiSkinButtons.enumerated() {
            b.backgroundColor = (i == idx)
                ? palette.accent.withAlphaComponent(0.28)
                : .clear
        }
    }

    func skinToneIndex(at point: CGPoint, in bar: UIView) -> Int? {
        for b in emojiSkinButtons {
            let f = b.convert(b.bounds, to: bar).insetBy(dx: -4, dy: -4)
            if f.contains(point) { return b.tag }
        }
        return nil
    }

    func hideEmojiSkinBar() {
        emojiSkinBar?.removeFromSuperview()
        emojiSkinBar = nil
        emojiSkinButtons = []
        emojiSkinBase = ""
    }

    func rememberEmoji(_ item: String) {
        var items = (ThemeIO.string("frequentEmoji") ?? "").split(separator: " ").map(String.init)
        items.removeAll { $0 == item }
        items.insert(item, at: 0)
        ThemeIO.set("frequentEmoji", value: items.prefix(32).joined(separator: " "))
    }
}
