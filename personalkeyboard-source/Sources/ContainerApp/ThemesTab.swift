import SwiftUI
import UIKit

// MARK: - Themes (downloadable packs + independent apply)

struct ThemesTab: View {
    @State private var themeID = ThemeStore.themeID
    @State private var sounds = ThemeStore.bool("sounds") ?? true
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"
    @State private var showNumberRow = ThemeStore.bool("showNumberRow") ?? true
    @State private var loadingThemeIDs: Set<String> = []
    @State private var loadingSoundIDs: Set<String> = []
    @State private var installedThemesTick = 0
    @State private var installedSoundsTick = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.lg) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("حزم الثيمات والأصوات")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .foregroundStyle(NaqraColors.textPrimary)
                        Text("كل حزمة تُحمَّل لوحدها. بعد التحميل يمكنك التبديل بينها بحرية دون فقدان الحزم الأخرى.")
                            .font(.system(size: 13))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                    .padding(.top, NaqraSpacing.sm)

                    SettingsCard(title: "الثيم على اللوحة", subtitle: "\(ThemeCatalog.swatch(for: themeID).title) · يُطبَّق فورًا") {
                        ThemeBoardCanvas(theme: ThemeCatalog.swatch(for: themeID), showNumbers: showNumberRow)
                    }

                    SettingsCard(title: "صف الأرقام", subtitle: "يظهر داخل اللوحة") {
                        Toggle("إظهار صف الأرقام", isOn: $showNumberRow)
                            .onChange(of: showNumberRow) { _, value in ThemeStore.write("showNumberRow", value: value) }
                    }

                    // Sound packs — each independent
                    SettingsCard(title: "حزم الصوت", subtitle: "كل صوت يُحمَّل مرة ثم يُبدَّل بحرية · يحتاج الوصول الكامل داخل اللوحة") {
                        Toggle("تفعيل صوت النقر", isOn: $sounds)
                            .onChange(of: sounds) { _, isEnabled in
                                if !isEnabled {
                                    soundChoice = "none"
                                    _ = SoundPackStore.apply("none")
                                } else if soundChoice == "none" {
                                    _ = SoundPackStore.apply("system")
                                    soundChoice = "system"
                                } else {
                                    ThemeStore.write("sounds", value: true)
                                }
                            }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(SoundPackStore.catalog) { pack in
                                soundTile(pack)
                            }
                        }
                        .id(installedSoundsTick)
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
                                            .frame(width: 118)
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .id(installedThemesTick)
                        }
                    }
                }
                .padding(.horizontal, NaqraSpacing.md)
                .padding(.vertical, NaqraSpacing.md)
            }
            .background(NaqraBackground())
            .navigationTitle("الثيمات")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                themeID = ThemeStore.themeID
                soundChoice = ThemeStore.string("soundChoice") ?? "system"
                sounds = ThemeStore.bool("sounds") ?? true
            }
        }
    }

    // MARK: Theme tile — load once, then free switch

    private func themeTile(_ theme: ThemeSwatch) -> some View {
        let installed = ThemePackStore.isInstalled(theme.id)
        let loading = loadingThemeIDs.contains(theme.id)
        let active = themeID == theme.id

        return Button {
            Task { await onThemeTap(theme) }
        } label: {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.key)
                    .frame(height: 52)
                    .overlay {
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
                            .stroke(active ? NaqraColors.accent : NaqraColors.border, lineWidth: active ? 2 : 1)
                    }
                    .overlay(alignment: .topTrailing) {
                        statusBadge(installed: installed, loading: loading, free: ThemePackStore.isFree(theme.id))
                            .padding(6)
                    }

                HStack(spacing: 4) {
                    Text(theme.title)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(NaqraColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    if active {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(NaqraColors.accent)
                    }
                }
                Text(statusLabel(installed: installed, loading: loading, free: ThemePackStore.isFree(theme.id), active: active))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(NaqraColors.textSecondary)
            }
            .padding(4)
            .background(NaqraColors.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(loading)
        .accessibilityLabel("ثيم \(theme.title)")
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private func onThemeTap(_ theme: ThemeSwatch) async {
        if ThemePackStore.isInstalled(theme.id) {
            // Safe switch — other packs stay installed
            if ThemePackStore.apply(theme.id) {
                themeID = theme.id
            }
            return
        }
        loadingThemeIDs.insert(theme.id)
        // Local "download": unlock pack (content already in app; flag persists)
        try? await Task.sleep(nanoseconds: 450_000_000)
        ThemePackStore.markInstalled(theme.id)
        loadingThemeIDs.remove(theme.id)
        installedThemesTick += 1
        if ThemePackStore.apply(theme.id) {
            themeID = theme.id
        }
    }

    // MARK: Sound tile

    private func soundTile(_ pack: SoundPackStore.Pack) -> some View {
        let installed = SoundPackStore.isInstalled(pack.id)
        let loading = loadingSoundIDs.contains(pack.id)
        let active = soundChoice == pack.id

        return Button {
            Task { await onSoundTap(pack) }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(pack.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(NaqraColors.textPrimary)
                    Spacer()
                    if loading {
                        ProgressView().scaleEffect(0.7)
                    } else if active {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(NaqraColors.accent)
                    } else if !installed {
                        Image(systemName: "arrow.down.circle")
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                }
                Text(pack.blurb)
                    .font(.system(size: 10))
                    .foregroundStyle(NaqraColors.textSecondary)
                Text(statusLabel(installed: installed, loading: loading, free: SoundPackStore.isFree(pack.id), active: active))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(NaqraColors.textSecondary)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(NaqraColors.surface.opacity(0.9), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(active ? NaqraColors.accent : NaqraColors.border, lineWidth: active ? 1.5 : 0.5)
            )
        }
        .buttonStyle(.plain)
        .disabled(loading)
        .accessibilityLabel("صوت \(pack.title)")
    }

    private func onSoundTap(_ pack: SoundPackStore.Pack) async {
        if SoundPackStore.isInstalled(pack.id) {
            if SoundPackStore.apply(pack.id) {
                soundChoice = pack.id
                sounds = pack.id != "none"
            }
            return
        }
        loadingSoundIDs.insert(pack.id)
        try? await Task.sleep(nanoseconds: 400_000_000)
        SoundPackStore.markInstalled(pack.id)
        loadingSoundIDs.remove(pack.id)
        installedSoundsTick += 1
        if SoundPackStore.apply(pack.id) {
            soundChoice = pack.id
            sounds = pack.id != "none"
        }
    }

    // MARK: Status chrome

    @ViewBuilder
    private func statusBadge(installed: Bool, loading: Bool, free: Bool) -> some View {
        if loading {
            ProgressView().scaleEffect(0.6)
                .padding(4)
                .background(.ultraThinMaterial, in: Circle())
        } else if free {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12))
                .foregroundStyle(.green)
        } else if installed {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(NaqraColors.accent)
        } else {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(NaqraColors.textSecondary)
        }
    }

    private func statusLabel(installed: Bool, loading: Bool, free: Bool, active: Bool) -> String {
        if loading { return "جاري التحميل…" }
        if active { return "مُطبَّق" }
        if free { return "جاهز" }
        if installed { return "محمّل · اضغط للتطبيق" }
        return "اضغط للتحميل"
    }
}

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
