import SwiftUI
import UIKit

// MARK: - Themes (downloadable packs + independent apply)

struct ThemesTab: View {
    @State private var themeID = ThemeStore.themeID
    @State private var loadingThemeIDs: Set<String> = []
    @State private var installedThemesTick = 0
    @State private var specialColor = SpecialKeyColorStore.loadColor()
    @State private var themeTask: Task<Void, Never>?
    @State private var themeGate = LatestSelectionGate()
    /// Diagnostic line only. Does not affect apply.
    @State private var themeTraceLine = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.lg) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("حزم الثيمات والأصوات")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .foregroundStyle(NaqraColors.textPrimary)
                        Text("كل الثيمات جاهزة داخل التطبيق. اضغط مرة واحدة للتطبيق على لوحة المفاتيح.")
                            .font(.system(size: 13))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                    .padding(.top, NaqraSpacing.sm)

                    SettingsCard(title: "الثيم على اللوحة", subtitle: "\(ThemeCatalog.swatch(for: themeID).title) · يُطبَّق فورًا") {
                        ThemeBoardCanvas(theme: ThemeCatalog.swatch(for: themeID), showNumbers: ThemeStore.bool("showNumberRow") ?? true)
                        if ThemeTrace.isEnabled, !themeTraceLine.isEmpty {
                            Text(themeTraceLine)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(NaqraColors.textSecondary)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    // Compact ColorPicker — control keys including emoji
                    SettingsCard(
                        title: "لون الأزرار",
                        subtitle: "شيفت · لغة · رموز · إدخال · حذف · نقطة · إيموجي"
                    ) {
                        HStack(spacing: 10) {
                            ColorPicker("", selection: $specialColor, supportsOpacity: false)
                                .labelsHidden()
                                .scaleEffect(0.9)
                                .frame(width: 36, height: 36)
                                .onChange(of: specialColor) { _, color in
                                    SpecialKeyColorStore.applyUnified(color)
                                }
                            Text("لون التحكم")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(NaqraColors.textPrimary)
                            Spacer(minLength: 0)
                            Button {
                                SpecialKeyColorStore.clearToThemeAccent()
                                specialColor = SpecialKeyColorStore.loadColor()
                            } label: {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("إرجاع للون الثيم")
                        }
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
                themeTask = nil
                loadingThemeIDs.removeAll()
            }
            .onAppear {
                themeID = ThemeStore.themeID
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
        // Themes ship with the app; first tap writes naqra.themeId (suite + standard for sideload).
        if ThemePackStore.apply(theme.id) {
            themeID = theme.id
            recordThemeTrace(wrote: theme.id)
        }
    }


    /// Display-only. Reads the suite directly (no standard fallback) so a dead group stays visible.
    private func recordThemeTrace(wrote: String) {
        guard ThemeTrace.isEnabled else {
            themeTraceLine = ""
            return
        }
        let suiteRead = UserDefaults(suiteName: ThemeStore.suiteName)?.string(forKey: "naqra.themeId") ?? "-"
        themeTraceLine = "wrote=\(wrote) | suiteRead=\(suiteRead) | build=\(NaqraBuildStamp.short)"
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
