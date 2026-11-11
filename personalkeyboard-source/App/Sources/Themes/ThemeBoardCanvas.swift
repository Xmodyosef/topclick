import SwiftUI

// MARK: - Full 4-row keyboard board canvas

struct ThemeBoardCanvas: View {
    let theme: ThemeSwatch
    var showNumbers: Bool = true

    private let numberRow = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let row1 = ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج"]
    private let row2 = ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ة"]
    private let row3 = ["ء", "ظ", "ط", "ذ", "د", "ز", "ر", "و", "ى"]

    var body: some View {
        VStack(spacing: 5) {
            if showNumbers {
                keyRow(numberRow, height: 28, font: 11)
            }
            keyRow(row1, height: 32, font: 13)
            keyRow(row2, height: 32, font: 13)
            HStack(spacing: 4) {
                keyRow(row3, height: 32, font: 13)
                controlKey("⌫", width: 40)
            }
            HStack(spacing: 4) {
                controlKey("١٢٣", width: 40)
                controlKey("EN", width: 36)
                spaceKey
                controlKey("😊", width: 32)
                controlKey("⏎", width: 40)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [theme.key.opacity(0.35), theme.accent.opacity(0.25), Color.black.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("لوحة بأربعة صفوف بالثيم \(theme.title)")
    }

    private func keyRow(_ keys: [String], height: CGFloat, font: CGFloat) -> some View {
        HStack(spacing: 3) {
            ForEach(keys, id: \.self) { key in
                Text(key)
                    .font(.system(size: font, weight: .semibold))
                    .foregroundStyle(theme.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(theme.key, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            }
        }
    }

    private func controlKey(_ title: String, width: CGFloat) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.95))
            .frame(width: width, height: 32)
            .background(theme.accent, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )
    }

    private var spaceKey: some View {
        Text("مسافة")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(theme.ink.opacity(0.85))
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(theme.key.opacity(0.55), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
