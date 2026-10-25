import SwiftUI
import UIKit

// MARK: - Themes

struct ThemesTab: View {
    @State private var themeID = ThemeStore.themeID

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.lg) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("اختر إحساس لوحتك")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .foregroundStyle(NaqraColors.textPrimary)
                        Text("لوحة كاملة من 4 صفوف — نفس هيكل لوحة نقرة (أرقام + 3 صفوف حروف)")
                            .font(.system(size: 13))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                    .padding(.top, NaqraSpacing.sm)

                    // Live full board (4 rows) — not a separate "preview tab"
                    SettingsCard(title: "الثيم على اللوحة", subtitle: "\(ThemeCatalog.swatch(for: themeID).title) · يُطبَّق فورًا داخل لوحة المفاتيح") {
                        ThemeBoardCanvas(theme: ThemeCatalog.swatch(for: themeID))
                    }

                    ForEach(ThemeCatalog.groups) { group in
                        VStack(alignment: .leading, spacing: NaqraSpacing.sm) {
                            Text(group.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(NaqraColors.textPrimary)
                                .padding(.horizontal, 2)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(alignment: .top, spacing: 10) {
                                    ForEach(group.themes) { theme in
                                        themeTile(theme)
                                            .frame(width: 108)
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                        }
                    }
                }
                .padding(.horizontal, NaqraSpacing.md)
                .padding(.vertical, NaqraSpacing.md)
            }
            .background(NaqraBackground())
            .navigationTitle("الثيمات")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { themeID = ThemeStore.themeID }
        }
    }

    private func themeTile(_ theme: ThemeSwatch) -> some View {
        Button {
            themeID = theme.id
            ThemeStore.write("themeId", value: theme.id)
        } label: {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.key)
                    .frame(height: 52)
                    .overlay {
                        // Mini 4-line hint
                        VStack(spacing: 2) {
                            ForEach(0..<4, id: \.self) { _ in
                                HStack(spacing: 2) {
                                    ForEach(0..<5, id: \.self) { _ in
                                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                                            .fill(theme.ink.opacity(0.35))
                                            .frame(height: 6)
                                    }
                                }
                            }
                        }
                        .padding(8)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(themeID == theme.id ? NaqraColors.accent : NaqraColors.border, lineWidth: themeID == theme.id ? 2 : 1)
                    }
                HStack(spacing: 4) {
                    Text(theme.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(NaqraColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    if themeID == theme.id {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(NaqraColors.accent)
                    }
                }
            }
            .padding(4)
            .background(NaqraColors.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("ثيم \(theme.title)")
        .accessibilityAddTraits(themeID == theme.id ? .isSelected : [])
    }
}

// MARK: - Full 4-row keyboard board canvas (matches real Naqra letter layout)

struct ThemeBoardCanvas: View {
    let theme: ThemeSwatch

    private let numberRow = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let row1 = ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج"]
    private let row2 = ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ة"]
    private let row3 = ["ء", "ظ", "ط", "ذ", "د", "ز", "ر", "و", "ى"]

    var body: some View {
        VStack(spacing: 5) {
            keyRow(numberRow, height: 28, font: 11)
            keyRow(row1, height: 32, font: 13)
            keyRow(row2, height: 32, font: 13)
            HStack(spacing: 4) {
                controlKey("⇧", width: 34)
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
                .fill(Color.black.opacity(0.35))
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
            .foregroundStyle(theme.ink)
            .frame(width: width, height: 32)
            .background(theme.accent.opacity(0.35), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
    }

    private var spaceKey: some View {
        Text("مسافة")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(theme.ink.opacity(0.85))
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(theme.key.opacity(0.9), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
