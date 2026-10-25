import SwiftUI
import UIKit

// MARK: - Keyboard activation / first-run setup (item 4)

struct SetupTab: View {
    @State private var hasFullAccess = ThemeStore.bool("hasFullAccess") ?? false
    @State private var setupDone = ThemeStore.bool("setupGuideSeen") ?? false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NaqraSpacing.lg) {
                    header
                    statusCard
                    stepsCard
                    tipsCard
                    openSettingsButton
                    if !setupDone {
                        Button {
                            setupDone = true
                            ThemeStore.write("setupGuideSeen", value: true)
                        } label: {
                            Text("فهمت — المتابعة للثيمات")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(NaqraColors.accent)
                    }
                }
                .padding(.horizontal, NaqraSpacing.md)
                .padding(.vertical, NaqraSpacing.md)
            }
            .background(NaqraBackground())
            .navigationTitle("التفعيل")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { reload() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { reload() }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("فعّل لوحة نقرة")
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .foregroundStyle(NaqraColors.textPrimary)
            Text("iOS لا يسمح لأي تطبيق بتفعيل لوحة المفاتيح تلقائيًا — الخطوات يدوية لمرة واحدة.")
                .font(.system(size: 13))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, NaqraSpacing.sm)
    }

    private var statusCard: some View {
        SettingsCard(
            title: "حالة الوصول الكامل",
            subtitle: hasFullAccess
                ? "اللوحة رصدت الوصول الكامل — النسخ والترجمة والحافظة متاحة."
                : "الوصول الكامل غير مفعّل بعد — النسخ/اللصق/الترجمة تحتاج تفعيله."
        ) {
            HStack(spacing: 10) {
                Image(systemName: hasFullAccess ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(hasFullAccess ? Color.green : NaqraColors.accent)
                Text(hasFullAccess ? "جاهز" : "يحتاج تفعيل")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NaqraColors.textPrimary)
                Spacer()
            }
        }
    }

    private var stepsCard: some View {
        SettingsCard(title: "خطوات التفعيل", subtitle: "اتبع الترتيب حرفيًا") {
            VStack(alignment: .leading, spacing: 10) {
                step(1, "افتح إعدادات iPhone ← عام ← لوحة المفاتيح")
                step(2, "لوحات المفاتيح ← إضافة لوحة مفاتيح جديدة")
                step(3, "اختر «نقرة» / PersonalKeyboard")
                step(4, "فعّل «السماح بالوصول الكامل» داخل لوحة نقرة")
                step(5, "ارجع لأي تطبيق واضغط على أيقونة الكرة الأرضية للتبديل إلى نقرة")
            }
        }
    }

    private var tipsCard: some View {
        SettingsCard(title: "ملاحظات مهمة", subtitle: nil) {
            VStack(alignment: .leading, spacing: 8) {
                tip("النسخ واللصق يحتاجان الوصول الكامل.")
                tip("سجل الحافظة اختياري — عطّله من الإعدادات إن رغبت.")
                tip("الثيمات تُطبَّق فورًا على اللوحة بعد اختيارها من تبويب الثيمات.")
            }
        }
    }

    private var openSettingsButton: some View {
        Button {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        } label: {
            Label("فتح إعدادات النظام", systemImage: "gear")
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(NaqraColors.accent)
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(n)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(NaqraColors.background)
                .frame(width: 24, height: 24)
                .background(NaqraColors.accent, in: Circle())
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(NaqraColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    private func tip(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 12))
                .foregroundStyle(NaqraColors.accent)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func reload() {
        hasFullAccess = ThemeStore.bool("hasFullAccess") ?? false
        setupDone = ThemeStore.bool("setupGuideSeen") ?? false
    }
}
