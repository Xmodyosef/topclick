import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Emoji
extension KeyboardViewController {
    /// One grid only (current category). Multiple CollectionViews exhaust keyboard-extension memory
    /// and silently drop categories — that is why emoji looked "incomplete".
    func makeEmojiTabs() -> UIView {
        let wrap = UIStackView()
        wrap.axis = .horizontal
        wrap.spacing = 6
        wrap.semanticContentAttribute = .forceLeftToRight
        let scroller = UIScrollView()
        scroller.showsHorizontalScrollIndicator = false
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
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
        lockHeight(host, emojiPagerHeight())

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.tag = 0
        cv.alwaysBounceVertical = true
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
        emojiPager = nil
        return host
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Reserved for future horizontal emoji paging; single grid needs no index sync.
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
        let item = emojiPack[emojiCategoryIndex].items[indexPath.item]
        textDocumentProxy.insertText(item)
        playSystemClick(.emoji)
        rememberEmoji(item)
        tapHaptic()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // iOS-like dense grid (8–9 columns); never leave sparse holes.
        let width = max(collectionView.bounds.width, collectionView.superview?.bounds.width ?? 0, UIScreen.main.bounds.width - 16)
        let cols: CGFloat = width >= 390 ? 9 : 8
        let side = max(floor(width / cols), 32)
        return CGSize(width: side, height: side)
    }

    @objc func emojiTab(_ sender: UIButton) {
        guard emojiPack.indices.contains(sender.tag) else { return }
        emojiCategoryIndex = sender.tag
        refreshTabs()
        emojiCollection?.setContentOffset(.zero, animated: false)
        emojiCollection?.collectionViewLayout.invalidateLayout()
        emojiCollection?.reloadData()
    }

    @objc func emojiTapped() {
        if page == .emoji {
            page = .letters
        } else {
            page = .emoji
            // Keep cache; refresh only if empty so frequent stays complete without reloading every open.
            if emojiPack.isEmpty {
                emojiPack = Self.catalog()
            }
            emojiCategoryIndex = min(emojiCategoryIndex, max(emojiPack.count - 1, 0))
        }
        rebuild()
        tapHaptic()
    }

    func rememberEmoji(_ item: String) {
        var items = (ThemeIO.string("frequentEmoji") ?? "").split(separator: " ").map(String.init)
        items.removeAll { $0 == item }
        items.insert(item, at: 0)
        ThemeIO.set("frequentEmoji", value: items.prefix(32).joined(separator: " "))
    }
}
