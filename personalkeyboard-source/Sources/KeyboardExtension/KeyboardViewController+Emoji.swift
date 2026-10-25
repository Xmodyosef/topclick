import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - KeyboardViewController + Emoji
extension KeyboardViewController {
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
            let b = control(pack.icon, #selector(emojiTab(_:)), font: 18)
            b.tag = i
            b.backgroundColor = i == emojiCategoryIndex ? UIColor.white.withAlphaComponent(0.22) : .clear
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
        let pager = UIScrollView()
        pager.isPagingEnabled = true
        pager.showsHorizontalScrollIndicator = false
        pager.delegate = self
        pager.translatesAutoresizingMaskIntoConstraints = false
        emojiPager = pager
        lockHeight(pager, emojiPagerHeight())
        let host = UIView()
        host.translatesAutoresizingMaskIntoConstraints = false
        pager.addSubview(host)
        NSLayoutConstraint.activate([
            host.topAnchor.constraint(equalTo: pager.contentLayoutGuide.topAnchor),
            host.bottomAnchor.constraint(equalTo: pager.contentLayoutGuide.bottomAnchor),
            host.leadingAnchor.constraint(equalTo: pager.contentLayoutGuide.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: pager.contentLayoutGuide.trailingAnchor),
            host.heightAnchor.constraint(equalTo: pager.frameLayoutGuide.heightAnchor)
        ])
        var previous: UIView?
        for i in 0..<emojiPack.count {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .clear
            cv.dataSource = self
            cv.delegate = self
            cv.tag = i
            cv.register(EmojiCell.self, forCellWithReuseIdentifier: "e")
            cv.translatesAutoresizingMaskIntoConstraints = false
            host.addSubview(cv)
            NSLayoutConstraint.activate([
                cv.topAnchor.constraint(equalTo: host.topAnchor),
                cv.bottomAnchor.constraint(equalTo: host.bottomAnchor),
                cv.widthAnchor.constraint(equalTo: pager.frameLayoutGuide.widthAnchor),
                cv.heightAnchor.constraint(equalTo: host.heightAnchor)
            ])
            if let previous { cv.leadingAnchor.constraint(equalTo: previous.trailingAnchor).isActive = true }
            else { cv.leadingAnchor.constraint(equalTo: host.leadingAnchor).isActive = true }
            if i == emojiPack.count - 1 { cv.trailingAnchor.constraint(equalTo: host.trailingAnchor).isActive = true }
            previous = cv
        }
        return pager
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === emojiPager, scrollView.bounds.width > 0 else { return }
        let idx = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        guard !emojiPack.isEmpty else { return }
        emojiCategoryIndex = min(max(idx, 0), emojiPack.count - 1)
        refreshTabs()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard emojiPack.indices.contains(collectionView.tag) else { return 0 }
        return emojiPack[collectionView.tag].items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "e", for: indexPath) as! EmojiCell
        guard emojiPack.indices.contains(collectionView.tag),
              emojiPack[collectionView.tag].items.indices.contains(indexPath.item) else {
            cell.label.text = ""
            cell.paint(palette)
            return cell
        }
        cell.label.text = emojiPack[collectionView.tag].items[indexPath.item]
        cell.paint(palette)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard emojiPack.indices.contains(collectionView.tag),
              emojiPack[collectionView.tag].items.indices.contains(indexPath.item) else { return }
        let item = emojiPack[collectionView.tag].items[indexPath.item]
        textDocumentProxy.insertText(item)
        playSystemClick(.emoji)
        rememberEmoji(item)
        tapHaptic()
        // Do not rebuild the whole emoji surface on every tap — keeps the full grid responsive
        // and avoids extension memory spikes. Frequent list applies next time emoji opens.
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cols: CGFloat = 8
        let w = floor(collectionView.bounds.width / cols)
        let side = max(w, 36)
        return CGSize(width: side, height: side)
    }
    @objc func emojiTab(_ sender: UIButton) {
        guard emojiPack.indices.contains(sender.tag) else { return }
        emojiCategoryIndex = sender.tag
        refreshTabs()
        guard let pager = emojiPager else { return }
        pager.setContentOffset(CGPoint(x: CGFloat(sender.tag) * pager.bounds.width, y: 0), animated: true)
    }
    @objc func emojiTapped() {
        page = (page == .emoji) ? .letters : .emoji
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
