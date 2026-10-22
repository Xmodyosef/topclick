import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Keyboard preview

struct KeyboardPreviewTab: View {
    @State private var themeID = ThemeStore.themeID
    @State private var showNumberRow = ThemeStore.bool("showNumberRow") ?? true
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.lg) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("مساحة كتابة أهدأ")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundStyle(NaqraColors.textPrimary)
                            Text("لوحة نقرة، بتفاصيل تناسبك")
                                .font(.system(size: 14))
                                .foregroundStyle(NaqraColors.textSecondary)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "sparkle")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundStyle(NaqraColors.accent)
                            .padding(12)
                            .background(NaqraColors.accent.opacity(0.12), in: Circle())
                    }
                    .padding(.top, NaqraSpacing.sm)

                    SettingsCard(title: "معاينة اللوحة", subtitle: "شكل قريب من لوحة الكتابة الفعلية") {
                        MiniKeyboardView(themeID: themeID, showNumberRow: showNumberRow)
                            .accessibilityLabel("معاينة لوحة مفاتيح نقرة العربية")
                    }

                    HStack(spacing: NaqraSpacing.sm) {
                        statusPill(icon: "sun.max.fill", title: themeID == "auto" ? (TimeTheme.isMorning() ? "صباح" : "مساء") : ThemeCatalog.swatch(for: themeID).title)
                        statusPill(icon: "number", title: showNumberRow ? "صف الأرقام ظاهر" : "صف الأرقام مخفي")
                    }

                    SettingsCard(title: "لمسة سريعة", subtitle: "الثيم المختار يصل إلى لوحة المفاتيح مباشرة") {
                        HStack {
                            Label("المجموعة النشطة", systemImage: "paintpalette")
                                .foregroundStyle(NaqraColors.textPrimary)
                            Spacer()
                            Text(ThemeCatalog.swatch(for: themeID).title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(NaqraColors.accent)
                        }
                    }
                }
                .padding(.horizontal, NaqraSpacing.md)
                .padding(.vertical, NaqraSpacing.md)
            }
            .background(NaqraBackground())
            .navigationTitle("نقرة")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: reload)
        }
    }

    private func statusPill(icon: String, title: String) -> some View {
        Label(title, systemImage: icon)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(NaqraColors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(NaqraColors.surface, in: Capsule())
    }

    private func reload() {
        themeID = ThemeStore.themeID
        showNumberRow = ThemeStore.bool("showNumberRow") ?? true
    }

}

struct MiniKeyboardView: View {
    let themeID: String
    let showNumberRow: Bool
    @Binding private var previewText: String
    @State private var previewNumberRow = false

    private let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let row1 = ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج"]
    private let row2 = ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ة"]

    init(themeID: String? = nil, showNumberRow: Bool? = nil, previewText: Binding<String> = .constant("")) {
        self.themeID = themeID ?? ThemeStore.themeID
        self.showNumberRow = showNumberRow ?? ThemeStore.bool("showNumberRow") ?? true
        self._previewText = previewText
    }
    private func insertPreview(_ title: String) {
        TapSoundEngine.shared.setEnabled(true)
        ThemeStore.write("sounds", value: true)
        ThemeStore.write("soundChoice", value: "system")
        if title == "123" {
            TapSoundEngine.shared.play(.rowMid)
            previewNumberRow.toggle()
        } else if title == "⌫" {
            TapSoundEngine.shared.play(.delete)
            if !previewText.isEmpty { previewText.removeLast() }
        } else if title == "↵" {
            TapSoundEngine.shared.play(.enter)
            previewText.append("\n")
        } else if title == "😊" {
            TapSoundEngine.shared.play(.emoji)
            previewText.append(title)
        } else if title == "مسافة" {
            TapSoundEngine.shared.play(.space)
            previewText.append(" ")
        } else if title.count == 1 {
            TapSoundEngine.shared.play(.rowMid)
            previewText.append(title)
        }
    }

    private var style: ThemeSwatch { ThemeCatalog.swatch(for: themeID) }

    var body: some View {
        VStack(spacing: 4) {
            if showNumberRow || previewNumberRow { keyRow(numbers, height: 23, font: 10) }
            keyRow(row1, height: 29, font: 12)
            keyRow(row2, height: 29, font: 12)
            HStack(spacing: 3) {
                keyButton("123", width: 31, height: 30, font: 9, emphasized: true)
                keyButton("⌫", width: 29, height: 30, font: 12, emphasized: true)
                keyButton("😊", width: 25, height: 30, font: 12)
                keyButton("مسافة", height: 30, font: 9)
                keyButton(".", width: 22, height: 30, font: 12)
                keyButton("↵", width: 31, height: 30, font: 11, emphasized: true)
            }
        }
        .padding(7)
        .background(style.key.opacity(0.25), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(style.accent.opacity(0.22), lineWidth: 1)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func keyRow(_ keys: [String], height: CGFloat, font: CGFloat) -> some View {
        HStack(spacing: 3) {
            ForEach(Array(keys.enumerated()), id: \.offset) { item in
                keyButton(item.element, height: height, font: font)
            }
        }
    }

    private func keyButton(
        _ title: String,
        width: CGFloat? = nil,
        height: CGFloat,
        font: CGFloat,
        emphasized: Bool = false
    ) -> some View {
        Button { insertPreview(title) } label: {
            Text(title)
                .font(.system(size: font, weight: .medium, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(style.ink)
                .frame(maxWidth: width == nil ? .infinity : nil)
                .frame(width: width, height: height)
                .background(emphasized ? style.accent.opacity(0.42) : style.key.opacity(0.78), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

