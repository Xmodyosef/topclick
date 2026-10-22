import SwiftUI
import Translation
import UIKit
import AudioToolbox

final class EmojiCell: UICollectionViewCell {
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        contentView.backgroundColor = .clear
    }
    required init?(coder: NSCoder) { fatalError() }
    func paint(_ p: NaqraPalette) {
        contentView.backgroundColor = .clear
        label.textColor = p.text
    }
}
