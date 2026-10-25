import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Settings

struct SettingsTab: View {
    @State private var showNumberRow = ThemeStore.bool("showNumberRow") ?? true
    @State private var autocorrect = ThemeStore.bool("autocorrect") ?? true
    @State private var suggestions = ThemeStore.bool("suggestions") ?? true
    @State private var haptics = ThemeStore.bool("haptics") ?? true
    @State private var sounds = ThemeStore.bool("sounds") ?? true
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"
    @State private var hapticLevel = ThemeStore.string("hapticLevel") ?? "medium"
    @State private var trackpad = ThemeStore.bool("trackpad") ?? true
    @State private var symbolRows = Int(ThemeStore.string("symbolRows") ?? "4") ?? 4
    @State private var clipboardHistoryEnabled = ThemeStore.bool("clipboardHistoryEnabled") ?? false
    @State private var iconMode = ThemeStore.string("iconMode") ?? "auto"
    @State private var hasFullAccess = ThemeStore.bool("hasFullAccess") ?? false
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
                        Text("اضبط اللوحة مرة، وستحفظ اختياراتك تلقائيًا")
                            .font(.system(size: 13))
                            .foregroundStyle(NaqraColors.textSecondary)
                    }
                    .padding(.top, NaqraSpacing.sm)

                    accessCard
                    iconCard
                    keyboardCard
                    typingCard
                    feelCard
                    soundCard
                    privacyCard
                    if #available(iOS 18.0, *) {
                        TranslationPrepCard()
                    } else {
                        SettingsCard(title: "الترجمة", subtitle: "تتطلب ميزة الترجمة iOS 18 أو أحدث") {
                            Label("حدّث النظام لتفعيل الترجمة داخل اللوحة", systemImage: "translate")
                                .font(.system(size: 12))
                                .foregroundStyle(NaqraColors.textSecondary)
                        }
                    }
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

    private var iconCard: some View {
        SettingsCard(title: "أيقونة التطبيق", subtitle: "الصباحية من 6 صباحًا إلى 6 مساءً، والمسائية في بقية الوقت") {
            HStack(spacing: 10) {
                iconOption(name: "MorningArtwork", title: "صباح", mode: "morning")
                iconOption(name: "EveningArtwork", title: "مساء", mode: "evening")
            }
            Picker("تبديل الأيقونة", selection: $iconMode) {
                Text("تلقائي").tag("auto")
                Text("صباحية ثابتة").tag("morning")
                Text("مسائية ثابتة").tag("evening")
            }
            .pickerStyle(.segmented)
            .tint(NaqraColors.accent)
            .onChange(of: iconMode) { _, value in AppIconSwitcher.apply(mode: value) }
            Text("يطبّق iOS التبديل عند فتح التطبيق أو عودته للمقدمة؛ لا يمكن تشغيل التطبيق بالخلفية لمجرد تغيير الأيقونة.")
                .font(.system(size: 11))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func iconOption(name: String, title: String, mode: String) -> some View {
        HStack(spacing: 8) {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: 42, height: 42)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundStyle(NaqraColors.textPrimary)
                Text(mode == "morning" ? "لؤلؤي وذهبي" : "نيلي وهادئ")
                    .font(.system(size: 10)).foregroundStyle(NaqraColors.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(9)
        .background(NaqraColors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var keyboardCard: some View {
        SettingsCard(title: "شكل اللوحة", subtitle: "الخيارات تنعكس على لوحة المفاتيح نفسها") {
            Toggle("إظهار صف الأرقام", isOn: $showNumberRow)
                .onChange(of: showNumberRow) { _, value in ThemeStore.write("showNumberRow", value: value) }
            Toggle("إظهار شريط الاقتراحات", isOn: $suggestions)
                .onChange(of: suggestions) { _, value in ThemeStore.write("suggestions", value: value) }
            Stepper("صفوف الرموز: \(symbolRows)", value: $symbolRows, in: 1...4)
                .onChange(of: symbolRows) { _, value in ThemeStore.write("symbolRows", value: String(value)) }
        }
    }

    private var typingCard: some View {
        SettingsCard(title: "الكتابة", subtitle: "الكلمات العربية لا تُستبدل تلقائيًا؛ يمكنك اختيار الاقتراح بنفسك") {
            Toggle("تصحيح تلقائي", isOn: $autocorrect)
                .onChange(of: autocorrect) { _, value in ThemeStore.write("autocorrect", value: value) }
            Toggle("تحريك المؤشر بسحب زر المسافة", isOn: $trackpad)
                .onChange(of: trackpad) { _, value in ThemeStore.write("trackpad", value: value) }
        }
    }

    private var feelCard: some View {
        SettingsCard(title: "الاهتزاز", subtitle: "اختر استجابة لمسية مريحة") {
            Toggle("اهتزاز المفاتيح", isOn: $haptics)
                .onChange(of: haptics) { _, value in ThemeStore.write("haptics", value: value) }
            Picker("قوة الاهتزاز", selection: $hapticLevel) {
                Text("خفيف").tag("light")
                Text("متوسط").tag("medium")
                Text("قوي").tag("strong")
                Text("بدون").tag("none")
            }
            .pickerStyle(.segmented)
            .onChange(of: hapticLevel) { _, value in ThemeStore.write("hapticLevel", value: value) }
            .disabled(!haptics)
            Text("قد يقيّد iOS الاهتزاز في لوحات المفاتيح الخارجية حسب الجهاز وإعداداته.")
                .font(.system(size: 11))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var soundCard: some View {
        SettingsCard(title: "صوت النقر", subtitle: "اختر صوتًا للنقر أو أوقفه") {
            Toggle("تفعيل صوت النقر", isOn: $sounds)
                .onChange(of: sounds) { _, isEnabled in
                    let nextChoice = isEnabled
                        ? (soundChoice == "none" ? "system" : soundChoice)
                        : "none"
                    soundChoice = nextChoice
                    ThemeStore.write("sounds", value: isEnabled)
                    ThemeStore.write("soundChoice", value: nextChoice)
                }

            Picker("نوع الصوت", selection: $soundChoice) {
                Text("النظام").tag("system")
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
        }
    }

    private var privacyCard: some View {
        SettingsCard(title: "الخصوصية والحافظة", subtitle: "الحافظة اختيارية؛ لا تُحفظ العناصر الجديدة ما لم تفعّل السجل") {
            Toggle("حفظ سجل الحافظة على هذا الجهاز", isOn: $clipboardHistoryEnabled)
                .onChange(of: clipboardHistoryEnabled) { _, value in
                    ThemeStore.write("clipboardHistoryEnabled", value: value)
                    if !value { ThemeStore.clearClipboardHistory() }
                }
            Button(role: .destructive) { showClearHistoryConfirmation = true } label: {
                Label("مسح سجل الحافظة الآن", systemImage: "trash")
                    .font(.system(size: 13, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(!clipboardHistoryEnabled)
            Text("النسخ اليدوي يعمل على النص المحدد فقط. لا تنسخ نقرة سياق الكتابة تلقائيًا.")
                .font(.system(size: 11))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var accessCard: some View {
        SettingsCard(
            title: "تفعيل لوحة نقرة",
            subtitle: hasFullAccess
                ? "الوصول الكامل مفعّل — النسخ والترجمة والحافظة جاهزة."
                : "فعّل اللوحة يدويًا مرة واحدة (iOS لا يسمح بالتفعيل التلقائي)."
        ) {
            HStack(spacing: 10) {
                Image(systemName: hasFullAccess ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(hasFullAccess ? Color.green : NaqraColors.accent)
                Text(hasFullAccess ? "جاهز" : "يحتاج تفعيل")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NaqraColors.textPrimary)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 8) {
                instruction(1, "الإعدادات ← عام ← لوحة المفاتيح")
                instruction(2, "لوحات المفاتيح ← إضافة لوحة ← نقرة")
                instruction(3, "فعّل «السماح بالوصول الكامل» داخل نقرة")
                instruction(4, "في أي تطبيق: اضغط 🌐 للتبديل إلى نقرة")
            }
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("فتح إعدادات النظام", systemImage: "gear")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(NaqraColors.accent)
            Text("زر «فتح الإعدادات» يفتح صفحة التطبيق؛ التفعيل النهائي من عام ← لوحة المفاتيح.")
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
            Text("نقرة · إصدار 0.2")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(NaqraColors.textSecondary)
            Text(ThemeStore.groupAlive ? "إعدادات التطبيق واللوحة تتشارك مجموعة التطبيق." : "تعذّر العثور على App Group؛ لن تتزامن الإعدادات حتى توقيع التطبيق باستحقاقاته الصحيحة.")
                .font(.system(size: 10))
                .foregroundStyle(ThemeStore.groupAlive ? NaqraColors.textSecondary : .orange)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NaqraSpacing.sm)
    }

    private func reload() {
        showNumberRow = ThemeStore.bool("showNumberRow") ?? true
        autocorrect = ThemeStore.bool("autocorrect") ?? true
        suggestions = ThemeStore.bool("suggestions") ?? true
        haptics = ThemeStore.bool("haptics") ?? true
        let knownSoundChoices: Set<String> = ["system", "none"]
        let storedChoice = ThemeStore.string("soundChoice") ?? "system"
        let requestedChoice = knownSoundChoices.contains(storedChoice) ? storedChoice : "system"
        let soundsEnabled = ThemeStore.bool("sounds") ?? (requestedChoice != "none")
        soundChoice = soundsEnabled && requestedChoice != "none" ? requestedChoice : "none"
        sounds = soundChoice != "none"
        if ThemeStore.string("soundChoice") != soundChoice {
            ThemeStore.write("soundChoice", value: soundChoice)
        }
        if ThemeStore.bool("sounds") != sounds {
            ThemeStore.write("sounds", value: sounds)
        }
        hapticLevel = ThemeStore.string("hapticLevel") ?? "medium"
        trackpad = ThemeStore.bool("trackpad") ?? true
        symbolRows = min(4, max(1, Int(ThemeStore.string("symbolRows") ?? "3") ?? 3))
        iconMode = ThemeStore.string("iconMode") ?? "auto"
        hasFullAccess = ThemeStore.bool("hasFullAccess") ?? false
        clipboardHistoryEnabled = ThemeStore.bool("clipboardHistoryEnabled") ?? false
        if ThemeStore.bool("clipboardHistoryEnabled") == nil {
            ThemeStore.write("clipboardHistoryEnabled", value: false)
        }
        if !clipboardHistoryEnabled, !(ThemeStore.string("clipboardHistory") ?? "").isEmpty {
            ThemeStore.clearClipboardHistory()
        }
    }
}
