import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Settings (slim: only controls that actually affect the keyboard)

struct SettingsTab: View {
    @State private var showNumberRow = ThemeStore.bool("showNumberRow") ?? true
    @State private var haptics = ThemeStore.bool("haptics") ?? true
    @State private var sounds = ThemeStore.bool("sounds") ?? true
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"
    @State private var hapticLevel = ThemeStore.string("hapticLevel") ?? "medium"
    @State private var clipboardHistoryEnabled = ThemeStore.bool("clipboardHistoryEnabled") ?? false
    @State private var iconMode = ThemeStore.string("iconMode") ?? "auto"
    @State private var showClearHistoryConfirmation = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.md) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("إعدادات على ذوقك")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .foregroundStyle(NaqraColors.textPrimary)
                        Text("ما يظهر هنا يؤثر فعليًا على اللوحة")
                            .font(.system(size: 13))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                    .padding(.top, NaqraSpacing.sm)

                    accessCard
                    iconCard
                    keyboardCard
                    feelCard
                    privacyCard
                    footer
                }
                .padding(.horizontal, NaqraSpacing.md)
                .padding(.vertical, NaqraSpacing.md)
            }
            .background(NaqraBackground())
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: reload)
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { reload() }
            }
            .confirmationDialog("مسح سجل الحافظة؟", isPresented: $showClearHistoryConfirmation, titleVisibility: .visible) {
                Button("مسح السجل", role: .destructive) { ThemeStore.clearClipboardHistory() }
                Button("إلغاء", role: .cancel) { }
            } message: {
                Text("سيُحذف السجل المحفوظ داخل التطبيق واللوحة.")
            }
        }
    }

    /// Icon switcher only — no decorative second artwork image.
    private var iconCard: some View {
        SettingsCard(title: "أيقونة التطبيق", subtitle: "صباح = لون سكري/كريمي · مساء = نفس الصورة بلون مسائي") {
            // صورة واحدة فقط (صباح). المساء = نفس الأيقونة بفلتر لون — بدون صورة ثانية زائدة.
            HStack(spacing: 10) {
                iconChip(asset: "MorningArtwork", title: "صباح", eveningTint: false)
                iconChip(asset: "MorningArtwork", title: "مساء", eveningTint: true)
            }
            Picker("تبديل الأيقونة", selection: $iconMode) {
                Text("تلقائي").tag("auto")
                Text("صباح").tag("morning")
                Text("مساء").tag("evening")
            }
            .pickerStyle(.segmented)
            .tint(NaqraColors.accent)
            .onChange(of: iconMode) { _, value in AppIconSwitcher.apply(mode: value) }
            Text("يطبّق iOS التبديل عند فتح التطبيق. لا يوجد زر «تفعيل وصول» داخل التطبيق — ذلك من إعدادات النظام فقط.")
                .font(.system(size: 11))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func iconChip(asset: String, title: String, eveningTint: Bool) -> some View {
        HStack(spacing: 8) {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                .colorMultiply(eveningTint ? Color(red: 0.55, green: 0.62, blue: 0.95) : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                )
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(NaqraColors.textPrimary)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(NaqraColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var keyboardCard: some View {
        SettingsCard(title: "إعدادات اللوحة", subtitle: "خيارات تنعكس على لوحة المفاتيح") {
            // Master mute only — pack picker lives in Themes tab (single owner).
            Toggle("تفعيل صوت النقر", isOn: $sounds)
                .onChange(of: sounds) { _, isEnabled in
                    SoundPackStore.setEnabled(isEnabled)
                    soundChoice = ThemeStore.string(ContentPackKeys.soundChoice) ?? "system"
                    sounds = soundChoice != "none"
                    if sounds { AudioServicesPlaySystemSound(1104) }
                }
            HStack {
                Text("الحزمة الحالية")
                    .font(.system(size: 13))
                    .foregroundStyle(NaqraColors.textPrimary)
                Spacer()
                Text(SoundPackStore.title(for: soundChoice))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(NaqraColors.accent)
            }
            Text("اختيار وتحميل حزم الصوت من تبويب «الثيمات» — كل حزمة لوحدها ولا تُحذف عند التبديل.")
                .font(.system(size: 11))
                .foregroundStyle(NaqraColors.textSecondary)
            Toggle("إظهار صف الأرقام", isOn: $showNumberRow)
                .onChange(of: showNumberRow) { _, value in ThemeStore.write("showNumberRow", value: value) }
            Toggle("حفظ سجل الحافظة", isOn: $clipboardHistoryEnabled)
                .onChange(of: clipboardHistoryEnabled) { _, value in
                    ThemeStore.write("clipboardHistoryEnabled", value: value)
                    if !value { ThemeStore.clearClipboardHistory() }
                }
        }
    }

    private var feelCard: some View {
        SettingsCard(title: "الاهتزاز", subtitle: "استجابة لمسية عند الضغط") {
            Toggle("اهتزاز المفاتيح", isOn: $haptics)
                .onChange(of: haptics) { _, value in ThemeStore.write("haptics", value: value) }
            Picker("القوة", selection: $hapticLevel) {
                Text("خفيف").tag("light")
                Text("متوسط").tag("medium")
                Text("قوي").tag("strong")
            }
            .pickerStyle(.segmented)
            .onChange(of: hapticLevel) { _, value in ThemeStore.write("hapticLevel", value: value) }
            .disabled(!haptics)
        }
    }

    private var privacyCard: some View {
        SettingsCard(title: "الحافظة", subtitle: "مسح السجل المحفوظ على الجهاز") {
            Button(role: .destructive) { showClearHistoryConfirmation = true } label: {
                Label("مسح سجل الحافظة", systemImage: "trash")
                    .font(.system(size: 13, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(!clipboardHistoryEnabled)
        }
    }

    private var accessCard: some View {
        SettingsCard(
            title: "تفعيل لوحة نقرة",
            subtitle: "iOS لا يسمح للتطبيق بتفعيل اللوحة أو «الوصول الكامل» بزر داخلي — الخطوات يدوية مرة واحدة."
        ) {
            VStack(alignment: .leading, spacing: 8) {
                instruction(1, "الإعدادات ← عام ← لوحة المفاتيح")
                instruction(2, "لوحات المفاتيح ← إضافة لوحة ← نقرة")
                instruction(3, "فعّل «السماح بالوصول الكامل» داخل نقرة")
                instruction(4, "في أي تطبيق: 🌐 للتبديل إلى نقرة")
            }
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("فتح إعدادات التطبيق", systemImage: "gear")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(NaqraColors.accent)
            Text("الزر يفتح صفحة التطبيق في الإعدادات. مسار اللوحة: عام ← لوحة المفاتيح (لا يوجد رابط مباشر من Apple).")
                .font(.system(size: 11))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func instruction(_ number: Int, _ text: String) -> some View {
        HStack(spacing: 9) {
            Text("\(number)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(NaqraColors.background)
                .frame(width: 22, height: 22)
                .background(NaqraColors.accent, in: Circle())
            Text(text).font(.system(size: 12)).foregroundStyle(NaqraColors.textPrimary)
            Spacer(minLength: 0)
        }
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Text("نقرة · إصدار 0.2.6")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(NaqraColors.textSecondary)
            // Soft note — unsigned/sideload often has no App Group; dual-write still saves prefs.
            if ThemeStore.groupAlive {
                Text("App Group جاهز — الإعدادات تتزامن مع اللوحة.")
                    .font(.system(size: 10))
                    .foregroundStyle(NaqraColors.textSecondary)
            } else {
                Text("ملاحظة: هذا البناء غير موقّع باستحقاق App Group. الإعدادات تُحفظ محليًا؛ للمزامنة الفورية مع اللوحة وقّع التطبيق بـ App Group (group.app.personal.PersonalKeyboard).")
                    .font(.system(size: 10))
                    .foregroundStyle(NaqraColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NaqraSpacing.sm)
    }

    private func reload() {
        showNumberRow = ThemeStore.bool("showNumberRow") ?? true
        haptics = ThemeStore.bool("haptics") ?? true
        let storedChoice = ThemeStore.string(ContentPackKeys.soundChoice) ?? "system"
        let requestedChoice = SoundPackStore.knownIDs.contains(storedChoice) ? storedChoice : "system"
        let soundsEnabled = ThemeStore.bool("sounds") ?? (requestedChoice != "none")
        soundChoice = soundsEnabled && requestedChoice != "none" ? requestedChoice : "none"
        sounds = soundChoice != "none"
        hapticLevel = ThemeStore.string("hapticLevel") ?? "medium"
        iconMode = ThemeStore.string("iconMode") ?? "auto"
        clipboardHistoryEnabled = ThemeStore.bool("clipboardHistoryEnabled") ?? false
        // Defaults that used to bloat the keyboard for no benefit:
        if ThemeStore.bool("suggestions") == nil {
            ThemeStore.write("suggestions", value: false)
        }
        if ThemeStore.bool("clipboardHistoryEnabled") == nil {
            ThemeStore.write("clipboardHistoryEnabled", value: false)
        }
        if !clipboardHistoryEnabled, !(ThemeStore.string("clipboardHistory") ?? "").isEmpty {
            ThemeStore.clearClipboardHistory()
        }
    }
}
