import SwiftUI
import UIKit

// MARK: - Themes (downloadable packs + independent apply)

struct ThemesTab: View {
    @State private var themeID = ThemeStore.themeID
    @State private var sounds = ThemeStore.bool("sounds") ?? true
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"
    @State private var loadingThemeIDs: Set<String> = []
    @State private var loadingSoundIDs: Set<String> = []
    @State private var installedThemesTick = 0
    @State private var installedSoundsTick = 0
    @State private var specialColor = SpecialKeyColorStore.loadColor()
    @State private var themeTask: Task<Void, Never>?
    @State private var soundTask: Task<Void, Never>?
    @State private var themeGate = LatestSelectionGate()
    @State private var soundGate = LatestSelectionGate()

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
                        ThemeBoardCanvas(theme: ThemeCatalog.swatch(for: themeID), showNumbers: ThemeStore.bool("showNumberRow") ?? true)
                    }

                    // STEP 3: one system ColorPicker — no 6-swatch raft
                    SettingsCard(
                        title: "لون الأزرار الأساسية",
                        subtitle: "شيفت · لغة · رموز · إدخال · حذف · نقطة — بدون إيموجي"
                    ) {
                        ColorPicker("اختر اللون", selection: $specialColor, supportsOpacity: false)
                            .onChange(of: specialColor) { _, color in
                                SpecialKeyColorStore.applyUnified(color)
                            }
                        Button {
                            SpecialKeyColorStore.clearToThemeAccent()
                            specialColor = SpecialKeyColorStore.loadColor()
                        } label: {
                            Label("إرجاع للون الثيم (accent)", systemImage: "arrow.uturn.backward")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.bordered)
                        Text("الضغطة تفتح منتقي الألوان النظامي المجاني. النقطة تتلوّن · الإيموجي يبقى محايدًا.")
                            .font(.system(size: 11))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }

                    // Sound packs — each independent
                    SettingsCard(title: "حزم الصوت", subtitle: "كل صوت يُحمَّل مرة ثم يُبدَّل بحرية · يحتاج الوصول الكامل داخل اللوحة") {
                        Toggle("تفعيل صوت النقر", isOn: $sounds)
                            .onChange(of: sounds) { _, isEnabled in
                                SoundPackStore.setEnabled(isEnabled)
                                soundChoice = ThemeStore.string(ContentPackKeys.soundChoice) ?? "system"
                                sounds = soundChoice != "none"
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
            .onDisappear {
                themeTask?.cancel()
                soundTask?.cancel()
                themeTask = nil
                soundTask = nil
                loadingThemeIDs.removeAll()
                loadingSoundIDs.removeAll()
            }
            .onAppear {
                themeID = ThemeStore.themeID
                soundChoice = ThemeStore.string("soundChoice") ?? "system"
                sounds = ThemeStore.bool("sounds") ?? true
                specialColor = SpecialKeyColorStore.loadColor()
            }
        }
    }

    // MARK: Theme tile — load once, then free switch

    private func themeTile(_ theme: ThemeSwatch) -> some View {
        let installed = ThemePackStore.isInstalled(theme.id)
        let loading = loadingThemeIDs.contains(theme.id)
        let active = themeID == theme.id

        return Button {
            startThemeLoad(theme)
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

    private func startThemeLoad(_ theme: ThemeSwatch) {
        themeTask?.cancel()
        loadingThemeIDs.removeAll()
        themeTask = Task {
            guard !Task.isCancelled else { return }
            guard let requestID = await themeGate.begin() else { return }
            await onThemeTap(theme, requestID: requestID)
        }
    }

    private func onThemeTap(_ theme: ThemeSwatch, requestID: UUID) async {
        guard !Task.isCancelled, await themeGate.isCurrent(requestID) else { return }
        if ThemePackStore.isInstalled(theme.id) {
            if ThemePackStore.apply(theme.id) { themeID = theme.id }
            return
        }

        loadingThemeIDs.insert(theme.id)
        // The packs are bundled locally; yield once for cancellation without faking a download delay.
        await Task.yield()
        guard !Task.isCancelled, await themeGate.isCurrent(requestID) else { return }

        ThemePackStore.markInstalled(theme.id)
        guard !Task.isCancelled, await themeGate.isCurrent(requestID) else { return }
        loadingThemeIDs.remove(theme.id)
        installedThemesTick += 1
        if ThemePackStore.apply(theme.id) { themeID = theme.id }
    }

    // MARK: Sound tile

    private func soundTile(_ pack: SoundPackStore.Pack) -> some View {
        let installed = SoundPackStore.isInstalled(pack.id)
        let loading = loadingSoundIDs.contains(pack.id)
        let active = soundChoice == pack.id

        return Button {
            startSoundLoad(pack)
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

    private func startSoundLoad(_ pack: SoundPackStore.Pack) {
        soundTask?.cancel()
        loadingSoundIDs.removeAll()
        soundTask = Task {
            guard !Task.isCancelled else { return }
            guard let requestID = await soundGate.begin() else { return }
            await onSoundTap(pack, requestID: requestID)
        }
    }

    private func onSoundTap(_ pack: SoundPackStore.Pack, requestID: UUID) async {
        guard !Task.isCancelled, await soundGate.isCurrent(requestID) else { return }
        if SoundPackStore.isInstalled(pack.id) {
            if SoundPackStore.apply(pack.id) {
                soundChoice = pack.id
                sounds = pack.id != "none"
            }
            return
        }

        loadingSoundIDs.insert(pack.id)
        await Task.yield()
        guard !Task.isCancelled, await soundGate.isCurrent(requestID) else { return }

        SoundPackStore.markInstalled(pack.id)
        guard !Task.isCancelled, await soundGate.isCurrent(requestID) else { return }
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
