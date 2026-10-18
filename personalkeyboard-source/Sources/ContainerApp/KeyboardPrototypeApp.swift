import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Visual system

enum NaqraColors {
    static let accent = Color(red: 0.84, green: 0.72, blue: 0.48)
    static let background = Color(red: 0.055, green: 0.065, blue: 0.09)
    static let surface = Color(red: 0.105, green: 0.12, blue: 0.16)
    static let surfaceRaised = Color(red: 0.15, green: 0.16, blue: 0.19)
    static let textPrimary = Color(red: 0.96, green: 0.95, blue: 0.92)
    static let textSecondary = Color(red: 0.68, green: 0.69, blue: 0.72)
    static let border = Color.white.opacity(0.09)
}

enum NaqraSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
}

enum NaqraRadius {
    static let key: CGFloat = 7
    static let card: CGFloat = 20
    static let button: CGFloat = 14
}

private struct NaqraBackground: View {
    var body: some View {
        LinearGradient(
            colors: [NaqraColors.background, Color(red: 0.075, green: 0.075, blue: 0.115)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct SettingsCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: NaqraSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(NaqraColors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(NaqraColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            content
        }
        .padding(NaqraSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: NaqraRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: NaqraRadius.card, style: .continuous)
                .stroke(NaqraColors.border, lineWidth: 1)
        }
    }
}

// MARK: - App lifecycle and icons

@main
struct KeyboardPrototypeApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.layoutDirection, .rightToLeft)
                .onAppear { AppIconSwitcher.applyAutomaticIfNeeded() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { AppIconSwitcher.applyAutomaticIfNeeded() }
        }
    }
}

@MainActor
enum AppIconSwitcher {
    static let eveningIconName = "AppIconEvening"
    static let morningStartHour = 6
    static let morningEndHour = 18

    static var isMorningNow: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= morningStartHour && hour < morningEndHour
    }

    static func applyAutomaticIfNeeded() {
        guard (ThemeStore.string("iconMode") ?? "auto") == "auto" else { return }
        setIcon(isMorningNow ? nil : eveningIconName)
    }

    static func apply(mode: String) {
        ThemeStore.write("iconMode", value: mode)
        switch mode {
        case "morning": setIcon(nil)
        case "evening": setIcon(eveningIconName)
        default: applyAutomaticIfNeeded()
        }
    }

    private static func setIcon(_ name: String?) {
        guard UIApplication.shared.supportsAlternateIcons,
              UIApplication.shared.alternateIconName != name else { return }
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error { print("Naqra icon change failed: \(error.localizedDescription)") }
        }
    }
}

// MARK: - Theme catalog

struct ThemeSwatch: Identifiable {
    let id: String
    let title: String
    let key: Color
    let ink: Color
    let accent: Color
}

struct ThemeGroup: Identifiable {
    let id: String
    let title: String
    let themes: [ThemeSwatch]
}

enum ThemeCatalog {
    static let all: [ThemeSwatch] = [
        .init(id: "auto", title: "يتبدّل مع الوقت", key: Color(red: 0.16, green: 0.18, blue: 0.23), ink: .white, accent: NaqraColors.accent),
        .init(id: "morning", title: "صباح هادئ", key: Color(red: 0.96, green: 0.90, blue: 0.78), ink: Color(red: 0.22, green: 0.16, blue: 0.10), accent: Color(red: 0.72, green: 0.48, blue: 0.22)),
        .init(id: "evening", title: "مساء مخملي", key: Color(red: 0.08, green: 0.12, blue: 0.24), ink: Color(red: 0.96, green: 0.78, blue: 0.42), accent: Color(red: 0.82, green: 0.58, blue: 0.22)),
        .init(id: "light", title: "لؤلؤي", key: Color(red: 0.90, green: 0.95, blue: 0.99), ink: Color(red: 0.14, green: 0.27, blue: 0.40), accent: Color(red: 0.28, green: 0.52, blue: 0.86)),
        .init(id: "dark", title: "فحمي", key: Color(red: 0.10, green: 0.16, blue: 0.28), ink: Color(red: 0.93, green: 0.96, blue: 1), accent: Color(red: 0.36, green: 0.60, blue: 1)),
        .init(id: "ocean", title: "محيط", key: Color(red: 0.06, green: 0.22, blue: 0.32), ink: Color(red: 0.62, green: 0.96, blue: 0.98), accent: Color(red: 0.16, green: 0.78, blue: 0.84)),
        .init(id: "forest", title: "مريمية", key: Color(red: 0.06, green: 0.18, blue: 0.12), ink: Color(red: 0.70, green: 0.96, blue: 0.76), accent: Color(red: 0.22, green: 0.78, blue: 0.42)),
        .init(id: "violet", title: "بنفسج", key: Color(red: 0.18, green: 0.10, blue: 0.32), ink: Color(red: 0.90, green: 0.78, blue: 1), accent: Color(red: 0.70, green: 0.42, blue: 1)),
        .init(id: "m7", title: "نعناع", key: Color(red: 0.84, green: 0.93, blue: 0.88), ink: Color(red: 0.22, green: 0.16, blue: 0.10), accent: Color(red: 0.72, green: 0.48, blue: 0.22)),
        .init(id: "m12", title: "ورد", key: Color(red: 0.96, green: 0.86, blue: 0.90), ink: Color(red: 0.22, green: 0.16, blue: 0.10), accent: Color(red: 0.72, green: 0.48, blue: 0.22)),
        .init(id: "e5", title: "برقوق ليلي", key: Color(red: 0.18, green: 0.10, blue: 0.22), ink: Color.white.opacity(0.94), accent: Color(red: 0.82, green: 0.58, blue: 0.22)),
        .init(id: "e11", title: "جمر", key: Color(red: 0.22, green: 0.10, blue: 0.08), ink: Color(red: 0.96, green: 0.78, blue: 0.42), accent: Color(red: 0.82, green: 0.58, blue: 0.22)),
        .init(id: "aurora", title: "شفق", key: Color(red: 0.10, green: 0.28, blue: 0.30), ink: Color(red: 0.80, green: 1.0, blue: 0.92), accent: Color(red: 0.32, green: 0.86, blue: 0.74)),
        .init(id: "lavender", title: "لافندر", key: Color(red: 0.28, green: 0.20, blue: 0.42), ink: Color(red: 0.94, green: 0.88, blue: 1.0), accent: Color(red: 0.70, green: 0.58, blue: 1.0)),
        .init(id: "sunset", title: "غروب", key: Color(red: 0.38, green: 0.14, blue: 0.16), ink: Color(red: 1.0, green: 0.86, blue: 0.72), accent: Color(red: 1.0, green: 0.48, blue: 0.28)),
        .init(id: "mint", title: "نعناع ليلي", key: Color(red: 0.08, green: 0.24, blue: 0.22), ink: Color(red: 0.76, green: 1.0, blue: 0.90), accent: Color(red: 0.24, green: 0.82, blue: 0.62)),
        .init(id: "rose", title: "وردي", key: Color(red: 0.36, green: 0.12, blue: 0.24), ink: Color(red: 1.0, green: 0.84, blue: 0.92), accent: Color(red: 0.96, green: 0.42, blue: 0.68)),
        .init(id: "mono", title: "أحادي", key: Color(red: 0.22, green: 0.23, blue: 0.25), ink: Color.white, accent: Color(red: 0.70, green: 0.74, blue: 0.80))
    ]

    static let groups: [ThemeGroup] = [
        .init(id: "daily", title: "اليومي", themes: selected(["auto", "light", "dark", "ocean"])),
        .init(id: "morning", title: "ألوان الصباح", themes: selected(["morning", "m7", "m12"])),
        .init(id: "evening", title: "ألوان المساء", themes: selected(["evening", "forest", "violet", "e5", "e11", "aurora", "lavender", "sunset", "mint", "rose", "mono"]))
    ]

    static func swatch(for id: String) -> ThemeSwatch {
        let resolvedID = id == "auto" ? TimeTheme.preferredThemeId() : id
        return all.first(where: { $0.id == resolvedID })
            ?? all.first(where: { $0.id == "dark" })!
    }

    private static func selected(_ ids: [String]) -> [ThemeSwatch] {
        ids.compactMap { id in all.first(where: { $0.id == id }) }
    }
}

enum TimeTheme {
    static func isMorning(at date: Date = Date()) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        return hour >= 6 && hour < 18
    }

    static func preferredThemeId() -> String { isMorning() ? "morning" : "evening" }
}

// MARK: - Shared preferences

enum ThemeStore {
    static let suiteName = "group.app.personal.PersonalKeyboard"
    static let notificationName = "app.personal.PersonalKeyboard.prefs"
    static var suite: UserDefaults { UserDefaults(suiteName: suiteName) ?? .standard }

    static func write(_ key: String, value: Any) {
        suite.set(value, forKey: key)
        suite.synchronize()
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(notificationName as CFString),
            nil, nil, true
        )
    }

    static func string(_ key: String) -> String? {
        suite.synchronize()
        return suite.string(forKey: key) ?? UserDefaults.standard.string(forKey: key)
    }

    static var themeID: String {
        let raw = string("themeId") ?? "auto"
        let legacy: [String: String] = [
            "charcoal": "dark", "smoke": "dark", "catppuccin_frappe": "dark", "catppuccin_macchiato": "dark",
            "teal": "ocean", "midnight": "cobalt", "midnight_gold": "cobalt", "neon_nights": "cobalt", "tron": "cobalt",
            "snow": "light", "minimal_light": "light", "catppuccin_latte": "light", "matcha": "m7",
            "cotton_candy": "m12", "candy_shop": "m12", "cherry": "e5", "cocoa": "e5",
            "neon": "forest", "catppuccin_mocha": "e2", "dracula": "violet"
        ]
        return legacy[raw] ?? raw
    }

    static func bool(_ key: String) -> Bool? {
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
        return nil
    }

    static func int(_ key: String) -> Int? {
        if suite.object(forKey: key) != nil { return suite.integer(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.integer(forKey: key) }
        return nil
    }

    static var groupAlive: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) != nil
    }

    static func clearClipboardHistory() { write("clipboardHistory", value: "") }
}

// MARK: - Main navigation

struct ContentView: View {
    var body: some View {
        TabView {
            KeyboardPreviewTab()
                .tabItem { Label("معاينة", systemImage: "keyboard") }
            ThemesTab()
                .tabItem { Label("الثيمات", systemImage: "paintpalette.fill") }
            SettingsTab()
                .tabItem { Label("الإعدادات", systemImage: "slider.horizontal.3") }
        }
        .tint(NaqraColors.accent)
        .preferredColorScheme(.dark)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

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

    private let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let row1 = ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج"]
    private let row2 = ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ة"]
    private let row3 = ["ئ", "ظ", "ط", "ذ", "د", "ز", "ر", "و", "ى"]

    init(themeID: String? = nil, showNumberRow: Bool? = nil, previewText: Binding<String> = .constant("")) {
        self.themeID = themeID ?? ThemeStore.themeID
        self.showNumberRow = showNumberRow ?? ThemeStore.bool("showNumberRow") ?? true
        self._previewText = previewText
    }
    private func insertPreview(_ title: String) {
        if title == "مسافة" { previewText.append(" ") }
        else if title.count == 1 || title.contains("😊") { previewText.append(title) }
    }

    private var style: ThemeSwatch { ThemeCatalog.swatch(for: themeID) }

    var body: some View {
        VStack(spacing: 4) {
            if showNumberRow { keyRow(numbers, height: 23, font: 10) }
            keyRow(row1, height: 29, font: 12)
            keyRow(row2, height: 29, font: 12)
            HStack(spacing: 3) {
                keyButton("⇧", width: 27, height: 29, font: 12, emphasized: true)
                keyRow(row3, height: 29, font: 12)
                keyButton("⌫", width: 29, height: 29, font: 12, emphasized: true)
            }
            HStack(spacing: 3) {
                keyButton("123", width: 31, height: 30, font: 9, emphasized: true)
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
        .environment(\.layoutDirection, .leftToRight)
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

// MARK: - Themes

struct ThemesTab: View {
    @State private var themeID = ThemeStore.themeID
    @State private var previewText = ""
    @State private var sounds = ThemeStore.bool("sounds") ?? true
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"
    @State private var fontStyle = ThemeStore.string("fontStyle") ?? "system"

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
                                            .frame(width: 142)
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
        SettingsCard(title: "صوت وخط الثيم", subtitle: "جرّب المظهر والصوت والحروف من مكان واحد") {
            Toggle("أصوات المفاتيح", isOn: $sounds)
                .onChange(of: sounds) { _, value in ThemeStore.write("sounds", value: value) }
            Picker("نوع الصوت", selection: $soundChoice) {
                Text("نظامي").tag("system")
                Text("كريمي").tag("creamy")
                Text("ثوكي").tag("thocky")
                Text("هادئ").tag("soft")
                Text("آلة كاتبة").tag("typewriter")
                Text("بدون").tag("none")
            }
            .onChange(of: soundChoice) { _, value in ThemeStore.write("soundChoice", value: value) }
            .disabled(!sounds)
            Picker("خط الحروف", selection: $fontStyle) {
                Text("بسيط").tag("system")
                Text("مستدير").tag("rounded")
                Text("نسخي").tag("serif")
                Text("أحادي").tag("mono")
            }
            .onChange(of: fontStyle) { _, value in ThemeStore.write("fontStyle", value: value) }
            Text("يُطبّق الخط على الحروف العربية والإنجليزية عند فتح اللوحة مجددًا.")
                .font(.system(size: 11))
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
                    .frame(height: 62)
                    .overlay(alignment: .center) {
                        HStack(spacing: 4) {
                            ForEach(["ض", "ص", "ث"], id: \.self) { letter in
                                Text(letter)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(theme.ink)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 31)
                                    .background(theme.accent.opacity(0.35), in: RoundedRectangle(cornerRadius: 5))
                            }
                        }
                        .padding(.horizontal, 7)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(themeID == theme.id ? NaqraColors.accent : NaqraColors.border, lineWidth: themeID == theme.id ? 2 : 1)
                    }
                HStack(spacing: 4) {
                    Text(theme.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(NaqraColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if themeID == theme.id {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(NaqraColors.accent)
                    }
                }
            }
            .padding(6)
            .background(NaqraColors.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("ثيم \(theme.title)")
        .accessibilityAddTraits(themeID == theme.id ? .isSelected : [])
    }
}

// MARK: - Settings

struct SettingsTab: View {
    @State private var showNumberRow = ThemeStore.bool("showNumberRow") ?? true
    @State private var autocorrect = ThemeStore.bool("autocorrect") ?? true
    @State private var suggestions = ThemeStore.bool("suggestions") ?? true
    @State private var haptics = ThemeStore.bool("haptics") ?? true
    @State private var hapticLevel = ThemeStore.string("hapticLevel") ?? "medium"
    @State private var trackpad = ThemeStore.bool("trackpad") ?? true
    @State private var symbolRows = Int(ThemeStore.string("symbolRows") ?? "3") ?? 3
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

                    iconCard
                    keyboardCard
                    typingCard
                    feelCard
                    privacyCard
                    accessCard
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
            Toggle("تصحيح تلقائي محافظ للإنجليزية", isOn: $autocorrect)
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
        SettingsCard(title: "تفعيل لوحة نقرة", subtitle: hasFullAccess ? "آخر حالة رصدتها اللوحة: الوصول الكامل مفعّل" : "آخر حالة رصدتها اللوحة: الوصول الكامل غير مفعّل") {
            VStack(alignment: .leading, spacing: 8) {
                instruction(1, "الإعدادات ← عام ← لوحة المفاتيح")
                instruction(2, "لوحات المفاتيح ← نقرة")
                instruction(3, "فعّل السماح بالوصول الكامل للنسخ والترجمة")
            }
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("فتح إعدادات لوحات المفاتيح", systemImage: "arrow.up.forward.app")
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(NaqraColors.accent)
            Text("يفتح iOS إعدادات التطبيق؛ التفعيل النهائي يدويًا من عام ← لوحة المفاتيح، ولا يسمح iOS لأي تطبيق بالتفعيل تلقائيًا.")
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
        ThemeStore.suite.synchronize()
        showNumberRow = ThemeStore.bool("showNumberRow") ?? true
        autocorrect = ThemeStore.bool("autocorrect") ?? true
        suggestions = ThemeStore.bool("suggestions") ?? true
        haptics = ThemeStore.bool("haptics") ?? true
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

// MARK: - Translation availability

@available(iOS 18.0, *)
struct TranslationPrepCard: View {
    @State private var status = "جاري فحص حزم الترجمة…"

    var body: some View {
        SettingsCard(title: "ترجمة iOS 18", subtitle: "ترجمة عربية وإنجليزية داخل الجهاز") {
            Text(status)
                .font(.system(size: 12))
                .foregroundStyle(NaqraColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .task {
            let availability = LanguageAvailability()
            let arEn = await availability.status(from: Locale.Language(identifier: "ar"), to: Locale.Language(identifier: "en"))
            let enAr = await availability.status(from: Locale.Language(identifier: "en"), to: Locale.Language(identifier: "ar"))
            switch (arEn, enAr) {
            case (.installed, .installed): status = "حزمتا العربية والإنجليزية جاهزتان."
            case (.unsupported, _), (_, .unsupported): status = "هذا الجهاز لا يدعم زوج اللغات المطلوب."
            default: status = "اللغتان مدعومتان؛ قد تُنزّل الحزم عند أول ترجمة."
            }
        }
    }
}
