import SwiftUI
import UIKit

// MARK: - Themes

struct ThemesTab: View {
    @State private var themeID = ThemeStore.themeID
    @State private var sounds = ThemeStore.bool("sounds") ?? true
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"
    @State private var showNumberRow = ThemeStore.bool("showNumberRow") ?? true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.lg) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("اختر إحساس لوحتك")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .foregroundStyle(NaqraColors.textPrimary)
                        Text("معاينة حية بجانب كل ثيم. الأزرار الأساسية (لغة/رموز/إدخال/حذف/إيموجي) بلون موحّد. العربية بلا شيفت — البدائل بالضغط المطوّل.")
                            .font(.system(size: 13))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                    .padding(.top, NaqraSpacing.sm)

                    // Live full board (4 rows) — not a separate "preview tab"
                    SettingsCard(title: "الثيم على اللوحة", subtitle: "\(ThemeCatalog.swatch(for: themeID).title) · يُطبَّق فورًا داخل لوحة المفاتيح") {
                        ThemeBoardCanvas(theme: ThemeCatalog.swatch(for: themeID), showNumbers: showNumberRow)
                    }

                    SettingsCard(title: "صوت النقرة · صف الأرقام", subtitle: "نفس مكان الثيمات — أنيق ومباشر") {
                        Toggle("تفعيل صوت النقر", isOn: $sounds)
                            .onChange(of: sounds) { _, isEnabled in
                                let next = isEnabled ? (soundChoice == "none" ? "system" : soundChoice) : "none"
                                soundChoice = next
                                ThemeStore.write("sounds", value: isEnabled)
                                ThemeStore.write("soundChoice", value: next)
                            }
                        Picker("مكتبة الأصوات", selection: $soundChoice) {
                            Text("النظام").tag("system")
                            Text("كريمي").tag("creamy")
                            Text("ثوكي").tag("thocky")
                            Text("ناعم").tag("soft")
                            Text("آلة كاتبة").tag("typewriter")
                            Text("بدون").tag("none")
                        }
                        .pickerStyle(.menu)
                        .disabled(!sounds)
                        .onChange(of: soundChoice) { _, choice in
                            let isEnabled = choice != "none"
                            sounds = isEnabled
                            ThemeStore.write("soundChoice", value: choice)
                            ThemeStore.write("sounds", value: isEnabled)
                        }
                        Toggle("إظهار صف الأرقام", isOn: $showNumberRow)
                            .onChange(of: showNumberRow) { _, value in ThemeStore.write("showNumberRow", value: value) }
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
            // App Group + standard + Darwin (ThemeStore.write). Also stamp appliedAt.
            ThemeStore.write("themeId", value: theme.id)
            ThemeStore.write("themeAppliedAt", value: Date().timeIntervalSince1970)
            // Ensure UserDefaults suite flush for suspended keyboard extension.
            UserDefaults(suiteName: ThemeStore.suiteName)?.set(theme.id, forKey: "themeId")
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
            // Arabic preview: no Shift — delete only (#12)
            HStack(spacing: 4) {
                keyRow(row3, height: 32, font: 13)
                controlKey("⌫", width: 40, kind: .unified)
            }
            HStack(spacing: 4) {
                controlKey("١٢٣", width: 40, kind: .unified)
                controlKey("EN", width: 36, kind: .unified)
                spaceKey
                controlKey("😊", width: 32, kind: .unified)
                controlKey("⏎", width: 40, kind: .unified)
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

    private func controlKey(_ title: String, width: CGFloat, kind: ControlKind = .unified) -> some View {
        // Unified action color for shift/lang/symbols/enter/delete/emoji (#1)
        let bg = theme.accent
        let fg = Color.white.opacity(0.95)
        return Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(fg)
            .frame(width: width, height: 32)
            .background(bg, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
            )
    }

    private enum ControlKind { case unified }

    private var spaceKey: some View {
        Text("مسافة")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(theme.ink.opacity(0.85))
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(theme.key.opacity(0.55), in: RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
