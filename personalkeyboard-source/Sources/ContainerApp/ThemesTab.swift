import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Themes

struct ThemesTab: View {
    @State private var themeID = ThemeStore.themeID
    @State private var previewText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.lg) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("اختر إحساس لوحتك")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .foregroundStyle(NaqraColors.textPrimary)
                        Text("كل اختيار يُطبّق على لوحة المفاتيح مباشرة")
                            .font(.system(size: 13))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                    .padding(.top, NaqraSpacing.sm)

                    SettingsCard(title: "معاينة فعلية", subtitle: "اضغط المفاتيح واكتب قبل تفعيل اللوحة") {
                        TextField("اكتب للتجربة…", text: $previewText)
                            .textFieldStyle(.roundedBorder)
                            .environment(\.layoutDirection, .rightToLeft)
                        MiniKeyboardView(themeID: themeID, previewText: $previewText)
                    }
                    themeOptionsCard

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
                                            .frame(width: 112)
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

    private var themeOptionsCard: some View {
        SettingsCard(title: "صوت الكيبورد", subtitle: "صوت النظام يعمل تلقائيًا مع كل ثيم") {
            Label("الصوت الافتراضي مفعّل", systemImage: "speaker.wave.2.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(NaqraColors.textSecondary)
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
                    .frame(height: 48)
                    .overlay(alignment: .center) {
                        HStack(spacing: 4) {
                            ForEach(["ض", "ص", "ث"], id: \.self) { letter in
                                Text(letter)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(theme.ink)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 24)
                                    .background(theme.accent.opacity(0.35), in: RoundedRectangle(cornerRadius: 5))
                            }
                        }
                        .padding(.horizontal, 5)
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
                        .minimumScaleFactor(0.8)
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

