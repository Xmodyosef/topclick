import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Design Tokens
enum NaqraColors {
    static let accent = Color(red: 0.79, green: 0.66, blue: 0.38)
    static let surface = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let border = Color.white.opacity(0.15)
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum Radius {
    static let key: CGFloat = 10
    static let card: CGFloat = 18
    static let button: CGFloat = 12
}


@main
struct KeyboardPrototypeApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear { AppIconSwitcher.applyAutomatic() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { AppIconSwitcher.applyAutomatic() }
        }
    }
}

/// يبدّل أيقونة التطبيق تلقائياً: صباح (6–18) / مساء (باقي اليوم)
enum AppIconSwitcher {
    /// اسم الأيقونة البديلة في Info.plist → CFBundleAlternateIcons
    static let morningName = "Morning"
    /// بداية الصباح ونهايته (ساعة محلية)
    static let morningStartHour = 6
    static let morningEndHour = 18

    static var isMorningNow: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= morningStartHour && hour < morningEndHour
    }

    /// nil = الأيقونة الأساسية (المساء)
    static var desiredIconName: String? {
        isMorningNow ? morningName : nil
    }

    static func applyAutomatic() {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        let target = desiredIconName
        let current = UIApplication.shared.alternateIconName
        // لا تغيّر إن كانت نفس الأيقونة — يقلل تنبيه النظام
        if current == target { return }
        UIApplication.shared.setAlternateIconName(target) { error in
            if let error {
                print("AppIconSwitcher: \(error.localizedDescription)")
            }
        }
    }

    /// يدوي: "morning" | "evening" | "auto"
    static func apply(mode: String) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        let target: String?
        switch mode {
        case "morning": target = morningName
        case "evening": target = nil
        default: target = desiredIconName
        }
        if UIApplication.shared.alternateIconName == target { return }
        UIApplication.shared.setAlternateIconName(target) { _ in }
    }
}

struct ThemeSwatch: Identifiable {
    let id: String
    let title: String
    let key: Color
    let ink: Color
}

enum ThemeCatalog {
    static let core: [ThemeSwatch] = [
        .init(id: "auto", title: "تلقائي", key: Color(red: 0.30, green: 0.32, blue: 0.36), ink: .white),
        .init(id: "light", title: "فاتح", key: Color(red: 0.92, green: 0.95, blue: 0.98), ink: Color(red: 0.16, green: 0.20, blue: 0.26)),
        .init(id: "dark", title: "داكن", key: Color(red: 0.16, green: 0.20, blue: 0.28), ink: .white),
        .init(id: "ocean", title: "بحر", key: Color(red: 0.10, green: 0.28, blue: 0.36), ink: .white),
        .init(id: "cobalt", title: "كوبالت", key: Color(red: 0.14, green: 0.22, blue: 0.46), ink: .white),
        .init(id: "violet", title: "بنفسج", key: Color(red: 0.24, green: 0.16, blue: 0.38), ink: .white),
        .init(id: "orchid", title: "أوركيد", key: Color(red: 0.36, green: 0.14, blue: 0.24), ink: .white),
        .init(id: "hailey", title: "دم", key: Color(red: 0.28, green: 0.10, blue: 0.12), ink: .white),
        .init(id: "ember", title: "جمر", key: Color(red: 0.32, green: 0.18, blue: 0.10), ink: .white),
        .init(id: "forest", title: "غابة", key: Color(red: 0.10, green: 0.24, blue: 0.16), ink: .white),
        .init(id: "midnight_gold", title: "ذهب ليلي", key: Color(red: 0.12, green: 0.10, blue: 0.08), ink: Color(red: 0.85, green: 0.70, blue: 0.30)),
        .init(id: "cocoa", title: "كاكاو", key: Color(red: 0.25, green: 0.15, blue: 0.10), ink: Color(red: 0.95, green: 0.85, blue: 0.75)),
        .init(id: "cherry", title: "كرز", key: Color(red: 0.40, green: 0.18, blue: 0.22), ink: Color(red: 1.0, green: 0.85, blue: 0.88)),
        .init(id: "matcha", title: "ماتشا", key: Color(red: 0.20, green: 0.28, blue: 0.18), ink: Color(red: 0.85, green: 0.95, blue: 0.80)),
        .init(id: "neon", title: "نيون", key: Color(red: 0.08, green: 0.10, blue: 0.15), ink: Color(red: 0.0, green: 1.0, blue: 0.8)),
        // مستوحاة من KeyboardKit (MIT) — ليست نسخاً
        .init(id: "cotton_candy", title: "غزل", key: Color(red: 0.95, green: 0.75, blue: 0.85), ink: Color(red: 0.3, green: 0.15, blue: 0.35)),
        .init(id: "neon_nights", title: "ليالي", key: Color(red: 0.1, green: 0.05, blue: 0.2), ink: Color(red: 0.0, green: 1.0, blue: 0.9)),
        .init(id: "tron", title: "ترون", key: Color(red: 0.02, green: 0.05, blue: 0.1), ink: Color(red: 0.0, green: 0.8, blue: 1.0)),
        .init(id: "candy_shop", title: "حلوى", key: Color(red: 0.9, green: 0.4, blue: 0.5), ink: .white),
        .init(id: "minimal_light", title: "بسيط", key: Color(red: 0.95, green: 0.95, blue: 0.96), ink: Color(red: 0.2, green: 0.2, blue: 0.22)),
        // Catppuccin (MIT)
        .init(id: "catppuccin_latte", title: "لاتيه", key: Color(red: 0.94, green: 0.94, blue: 0.96), ink: Color(red: 0.30, green: 0.30, blue: 0.42)),
        .init(id: "catppuccin_frappe", title: "فرابيه", key: Color(red: 0.19, green: 0.20, blue: 0.26), ink: Color(red: 0.78, green: 0.78, blue: 0.85)),
        .init(id: "catppuccin_macchiato", title: "ماكياتو", key: Color(red: 0.14, green: 0.15, blue: 0.20), ink: Color(red: 0.80, green: 0.82, blue: 0.90)),
        .init(id: "catppuccin_mocha", title: "موكا", key: Color(red: 0.12, green: 0.12, blue: 0.16), ink: Color(red: 0.80, green: 0.82, blue: 0.90)),
        // Dracula (MIT)
        .init(id: "dracula", title: "دراكولا", key: Color(red: 0.16, green: 0.16, blue: 0.21), ink: Color(red: 0.97, green: 0.97, blue: 0.95)),
    ]

    static let morning: [ThemeSwatch] = [
        ("رملي", 0.93, 0.86, 0.72), ("قش", 0.90, 0.82, 0.62), ("خوخ", 0.96, 0.78, 0.68),
        ("مشمش", 0.96, 0.72, 0.48), ("عاج", 0.95, 0.92, 0.84), ("حليب", 0.96, 0.94, 0.90),
        ("نعناع", 0.74, 0.90, 0.82), ("مريمية", 0.70, 0.80, 0.72), ("سماء", 0.70, 0.84, 0.94),
        ("بحيرة", 0.55, 0.78, 0.86), ("لافندر", 0.82, 0.76, 0.90), ("ورد", 0.94, 0.74, 0.80),
        ("ذهب", 0.90, 0.76, 0.40), ("عسل", 0.88, 0.68, 0.36), ("زيتون", 0.62, 0.66, 0.40),
        ("طين", 0.72, 0.52, 0.40), ("ورق", 0.78, 0.84, 0.72), ("ضباب", 0.82, 0.84, 0.86),
        ("مرجان", 0.92, 0.55, 0.50), ("فستق", 0.70, 0.82, 0.58)
    ].enumerated().map { i, item in
        ThemeSwatch(id: "m\(i + 1)", title: item.0, key: Color(red: item.1, green: item.2, blue: item.3), ink: Color(red: 0.16, green: 0.16, blue: 0.14))
    }

    static let evening: [ThemeSwatch] = [
        ("فحم", 0.12, 0.12, 0.13), ("كحلي", 0.08, 0.12, 0.22), ("ليل", 0.07, 0.09, 0.16),
        ("حبر", 0.08, 0.10, 0.18), ("برقوق", 0.16, 0.08, 0.16), ("نبيذ", 0.22, 0.08, 0.12),
        ("غابة", 0.06, 0.14, 0.10), ("زمرد", 0.05, 0.16, 0.12), ("محيط", 0.05, 0.12, 0.18),
        ("كوبالت ليلي", 0.08, 0.12, 0.28), ("جمر", 0.22, 0.10, 0.06), ("نحاس", 0.24, 0.14, 0.08),
        ("بنفسج ليلي", 0.14, 0.08, 0.22), ("أوركيد ليلي", 0.18, 0.08, 0.16), ("رماد", 0.16, 0.18, 0.22),
        ("دخان", 0.14, 0.14, 0.16), ("قهوة", 0.18, 0.12, 0.08), ("صحراء", 0.20, 0.14, 0.10),
        ("ملكي", 0.12, 0.08, 0.20), ("فجر", 0.18, 0.10, 0.12)
    ].enumerated().map { i, item in
        ThemeSwatch(id: "e\(i + 1)", title: item.0, key: Color(red: item.1, green: item.2, blue: item.3), ink: .white)
    }

    static var all: [ThemeSwatch] { core + morning + evening }
}

enum ThemeStore {
    static let suiteName = "group.app.personal.PersonalKeyboard"
    static var suite: UserDefaults { UserDefaults(suiteName: suiteName) ?? .standard }
    static var fileURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)?
            .appendingPathComponent("naqra-prefs.json")
    }
    static func fileDict() -> [String: Any] {
        guard let url = fileURL, let data = try? Data(contentsOf: url),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
        return obj
    }
    static let boardName = UIPasteboard.Name("group.app.personal.PersonalKeyboard")
    static func write(_ key: String, value: Any) {
        suite.set(value, forKey: key)
        UserDefaults.standard.set(value, forKey: key)
        suite.synchronize()
        UserDefaults.standard.synchronize()
        var d = fileDict()
        d[key] = value
        if let url = fileURL, let data = try? JSONSerialization.data(withJSONObject: d, options: []) {
            try? data.write(to: url, options: .atomic)
        }
        let pb = UIPasteboard(name: boardName, create: true)
        if let text = value as? String {
            pb?.string = "naqra|" + key + "|" + text
        } else if let flag = value as? Bool {
            pb?.string = "naqra|" + key + "|" + (flag ? "1" : "0")
        }
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("app.personal.PersonalKeyboard.prefs" as CFString),
            nil, nil, true
        )
    }
    static func string(_ key: String) -> String? {
        if let v = fileDict()[key] as? String { return v }
        if let v = suite.string(forKey: key) { return v }
        if let v = UserDefaults.standard.string(forKey: key) { return v }
        if let raw = UIPasteboard(name: boardName, create: false)?.string,
           raw.hasPrefix("naqra|" + key + "|") {
            return String(raw.dropFirst(("naqra|" + key + "|").count))
        }
        return nil
    }
    static func int(_ key: String) -> Int? {
        if let v = suite.object(forKey: key) as? Int { return v }
        return fileDict()[key] as? Int
    }

    static func bool(_ key: String) -> Bool? {
        if let v = fileDict()[key] as? Bool { return v }
        if suite.object(forKey: key) != nil { return suite.bool(forKey: key) }
        if UserDefaults.standard.object(forKey: key) != nil { return UserDefaults.standard.bool(forKey: key) }
        return nil
    }
    static var groupAlive: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) != nil
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            KeyboardPreviewTab()
                .tabItem { Label("معاينة", systemImage: "keyboard") }
            ThemesTab()
                .tabItem { Label("الثيمات", systemImage: "paintpalette") }
            SettingsTab()
                .tabItem { Label("الإعدادات", systemImage: "gear") }
        }
        .tint(NaqraColors.accent)
        .preferredColorScheme(.dark)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

struct KeyboardPreviewTab: View {
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"
    @State private var hapticLevel = ThemeStore.string("hapticLevel") ?? "medium"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    MiniKeyboardView()
                        .frame(height: 200)
                        .padding(.horizontal)
                    soundPicker
                    hapticPicker
                }
                .padding(.vertical)
            }
            .background(LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.12)], startPoint: .top, endPoint: .bottom))
            .navigationTitle("معاينة")
            .animation(.spring(response: 0.3), value: soundChoice)
        }
    }

    private var soundPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("الصوت").font(.headline).foregroundStyle(.white)
            Picker("الصوت", selection: $soundChoice) {
                Text("نظامي").tag("system")
                Text("كريمي").tag("creamy")
                Text("ثوكي").tag("thocky")
                Text("هادي").tag("soft")
                Text("آلة كاتبة").tag("typewriter")
                Text("بدون").tag("none")
            }
            .pickerStyle(.menu)
            .onChange(of: soundChoice) { _, v in
                ThemeStore.write("soundChoice", value: v)
                TapSoundEngine.shared.play(.rowMid)
            }
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card))
        .padding(.horizontal)
    }

    private var hapticPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("الاهتزاز").font(.headline).foregroundStyle(.white)
            Picker("الاهتزاز", selection: $hapticLevel) {
                Text("خفيف").tag("light")
                Text("وسط").tag("medium")
                Text("قوي").tag("strong")
                Text("بدون").tag("none")
            }
            .pickerStyle(.segmented)
            .onChange(of: hapticLevel) { _, v in ThemeStore.write("hapticLevel", value: v) }
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card))
        .padding(.horizontal)
    }
}

struct MiniKeyboardView: View {
    let row1 = ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح"]
    let row2 = ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م"]
    let row3 = ["ك", "ط", "ذ", "د", "ز", "ر", "و"]
    let row4 = ["123", "😊", "مسافة", ".", "↵"]

    var body: some View {
        VStack(spacing: 4) {
            keyRow(row1)
            keyRow(row2)
            HStack(spacing: 4) {
                keyButton("⇧", width: 40)
                keyRow(row3)
                keyButton("⌫", width: 40)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func keyRow(_ keys: [String]) -> some View {
        HStack(spacing: 4) {
            ForEach(keys, id: \.self) { k in keyButton(k) }
        }
    }

    private func keyButton(_ k: String, width: CGFloat? = nil) -> some View {
        Button {
            TapSoundEngine.shared.play(.rowMid)
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            Text(k)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: width == nil ? .infinity : nil)
                .frame(width: width, height: 32)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
    }
}

struct ThemesTab: View {
    @State private var themeID = ThemeStore.string("themeId") ?? "dark"

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(ThemeCatalog.core + ThemeCatalog.morning + ThemeCatalog.evening) { swatch in
                        Button {
                            themeID = swatch.id
                            ThemeStore.write("themeId", value: swatch.id)
                        } label: {
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(swatch.key)
                                    .frame(height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(themeID == swatch.id ? NaqraColors.accent : Color.clear, lineWidth: 2)
                                    )
                                Text(swatch.title)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.12)], startPoint: .top, endPoint: .bottom))
            .navigationTitle("الثيمات")
            .animation(.spring(response: 0.3), value: themeID)
        }
    }
}

struct SettingsTab: View {
    @State private var autocorrect = ThemeStore.bool("autocorrect") ?? true
    @State private var suggestions = ThemeStore.bool("suggestions") ?? true
    @State private var symbolRows = Int(ThemeStore.string("symbolRows") ?? "3") ?? 3

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    guideCard
                    togglesCard
                    repairCard
                    versionFooter
                }
                .padding()
            }
            .background(LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.12)], startPoint: .top, endPoint: .bottom))
            .navigationTitle("الإعدادات")
        }
    }

    private var guideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("تفعيل اللوحة").font(.headline).foregroundStyle(.white)
            StepRow(number: 1, text: "افتح الإعدادات", done: true)
            StepRow(number: 2, text: "عام → لوحة المفاتيح", done: true)
            StepRow(number: 3, text: "لوحات المفاتيح → إضافة", done: false)
            StepRow(number: 4, text: "اختر نقرة", done: false)
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card))
    }

    private var togglesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("تصحيح تلقائي", isOn: $autocorrect)
                .onChange(of: autocorrect) { _, v in ThemeStore.write("autocorrect", value: v) }
            Toggle("اقتراحات", isOn: $suggestions)
                .onChange(of: suggestions) { _, v in ThemeStore.write("suggestions", value: v) }
            Stepper("صفوف الرموز: \(symbolRows)", value: $symbolRows, in: 1...4)
                .onChange(of: symbolRows) { _, v in ThemeStore.write("symbolRows", value: String(v)) }
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card))
        .foregroundStyle(.white)
    }

    private var repairCard: some View {
        Button {
            ThemeStore.write("themeId", value: "dark")
            ThemeStore.write("lastLanguage", value: "ar")
        } label: {
            Text("إصلاح اللوحة")
                .frame(maxWidth: .infinity)
                .padding()
                .background(NaqraColors.accent)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: Radius.button))
        }
    }

    private var versionFooter: some View {
        Text("نقرة 0.1")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.4))
    }
}

struct StepRow: View {
    let number: Int
    let text: String
    let done: Bool
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(done ? NaqraColors.accent : Color.white.opacity(0.1))
                    .frame(width: 28, height: 28)
                if done {
                    Image(systemName: "checkmark").font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.black)
                } else {
                    Text("\(number)").font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
                }
            }
            Text(text).font(.system(size: 14)).foregroundStyle(.white)
            Spacer()
        }
    }
}

// MARK: - Old ContentView (kept for reference)
struct OldContentView: View {
    @State private var themeID = ThemeStore.string("themeId") ?? "dark"
    @State private var autocorrect = ThemeStore.bool("autocorrect") ?? true
    @State private var haptics = ThemeStore.bool("haptics") ?? true
    @State private var hapticLevel = ThemeStore.string("hapticLevel") ?? "medium"
    @State private var trackpad = ThemeStore.bool("trackpad") ?? true
    @State private var sounds = ThemeStore.bool("sounds") ?? true
    @State private var hasFullAccess = ThemeStore.bool("hasFullAccess") ?? false
    @State private var showThemePreview = false
    @State private var soundChoice = ThemeStore.string("soundChoice") ?? "system"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    accessCard
                    Button {
                        showThemePreview = true
                    } label: {
                        Label("معاينة الثيمات", systemImage: "paintpalette")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.md)
                            .background(NaqraColors.border)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                    }
                    .sheet(isPresented: $showThemePreview) {
                        ThemePreviewScreen(themeID: $themeID)
                    }
                    soundCard
                    extrasCard
                    repairCard
                    if #available(iOS 18.0, *) {
                        TranslationPrepCard()
                    }
                    Text(ThemeStore.groupAlive
                         ? "الثيم يُختار هنا ويصل للوحة عند فتحها."
                         : "التوقيع العام قد يمنع المشاركة. أبقِ App Groups.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.62))
                }
                .padding(Spacing.md)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.05, blue: 0.08),
                             Color(red: 0.08, green: 0.06, blue: 0.12)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()
            )
            .navigationTitle("نقرة")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
        .onAppear(perform: reload)
    }

    private var accessCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(hasFullAccess ? "الوصول الكامل مفعّل" : "الوصول الكامل غير مفعّل")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
            Text("يلزم للنسخ واللصق والترجمة.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("فتح الإعدادات")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.white)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .stroke(NaqraColors.border, lineWidth: 1)
                )
    }

    private var soundCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("الصوت").font(.headline)
            ForEach(["system", "creamy", "thocky", "soft", "typewriter", "none"], id: \.self) { id in
                HStack {
                    Button {
                        TapSoundEngine.shared.play(.rowMid)
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                            .foregroundStyle(NaqraColors.accent)
                    }
                    .buttonStyle(.plain)
                    Text(titleForSound(id))
                        .font(.system(size: 15))
                    Spacer()
                    if soundChoice == id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(NaqraColors.accent)
                    }
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    soundChoice = id
                    ThemeStore.write("soundChoice", value: id)
                    TapSoundEngine.shared.play(.rowMid)
                }
            }
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card)
                .stroke(NaqraColors.border, lineWidth: 1)
        )
    }

    private func titleForSound(_ id: String) -> String {
        switch id {
        case "system": return "نظامي"
        case "creamy": return "كريمي"
        case "thocky": return "ثوكي"
        case "soft": return "هادي"
        case "typewriter": return "آلة كاتبة"
        case "none": return "بدون"
        default: return id
        }
    }

    private var extrasCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("الأيقونة")
                .font(.headline)
            Text(AppIconSwitcher.isMorningNow
                 ? "الآن: صباح (سكري) — تتبدل تلقائياً 6ص–6م"
                 : "الآن: مساء (داكن) — تتبدل تلقائياً 6ص–6م")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
            HStack(spacing: Spacing.sm) {
                Button("صباح") { AppIconSwitcher.apply(mode: "morning") }
                    .buttonStyle(.bordered)
                Button("مساء") { AppIconSwitcher.apply(mode: "evening") }
                    .buttonStyle(.bordered)
                Button("تلقائي") { AppIconSwitcher.apply(mode: "auto") }
                    .buttonStyle(.borderedProminent)
            }
            Text("اللمس")
                .font(.headline)
            Toggle("تصحيح تلقائي", isOn: $autocorrect)
                .onChange(of: autocorrect) { _, v in ThemeStore.write("autocorrect", value: v) }
            Toggle("اهتزاز المفاتيح", isOn: $haptics)
                .onChange(of: haptics) { _, v in ThemeStore.write("haptics", value: v) }
            if haptics {
                Picker("شدة الاهتزاز", selection: $hapticLevel) {
                    Text("خفيف").tag("light")
                    Text("وسط").tag("medium")
                    Text("قوي").tag("strong")
                }
                .pickerStyle(.segmented)
                .onChange(of: hapticLevel) { _, v in ThemeStore.write("hapticLevel", value: v) }
            }
            Toggle("سحب المسافة لتحريك المؤشر", isOn: $trackpad)
                .onChange(of: trackpad) { _, v in ThemeStore.write("trackpad", value: v) }
            Toggle("أصوات النقرة", isOn: $sounds)
                .onChange(of: sounds) { _, v in ThemeStore.write("sounds", value: v) }
            Text("لوحات iOS قد لا تهتز حتى مع تفعيل المفتاح.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .stroke(NaqraColors.border, lineWidth: 1)
                )
    }

    private var repairCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("إصلاح")
                .font(.headline)
            Text("يعيد الثيم الداكن، ويمسح اللغة المحفوظة، ويوقف الاهتزاز.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.62))
            Button("إصلاح اللوحة") {
                themeID = "dark"
                haptics = false
                ThemeStore.write("themeId", value: "dark")
                ThemeStore.write("lastLanguage", value: "ar")
                ThemeStore.write("haptics", value: false)
            }
            .buttonStyle(.bordered)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .stroke(NaqraColors.border, lineWidth: 1)
                )
    }

    private func reload() {
        hasFullAccess = ThemeStore.bool("hasFullAccess") ?? false
        if let raw = ThemeStore.string("themeId") { themeID = raw }
        if let v = ThemeStore.bool("autocorrect") { autocorrect = v }
        if let v = ThemeStore.bool("haptics") { haptics = v }
        if let v = ThemeStore.bool("trackpad") { trackpad = v }
        if let v = ThemeStore.bool("sounds") { sounds = v }
        if let v = ThemeStore.string("hapticLevel"), ["light", "medium", "strong"].contains(v) { hapticLevel = v }
        AppIconSwitcher.applyAutomatic()
    }
}

struct ThemePreviewScreen: View {
    @Binding var themeID: String
    @State private var draft: String = "dark"

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Button {
                    themeID = draft
                    ThemeStore.write("themeId", value: draft)
                } label: {
                    Text("تطبيق هذا الثيم")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.white)
                section("الأساسية", ThemeCatalog.core)
                section("صباح", ThemeCatalog.morning)
                section("مساء", ThemeCatalog.evening)
            }
            .padding(Spacing.md)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.08),
                         Color(red: 0.08, green: 0.06, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
        )
        .navigationTitle("معاينة الثيم")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear { draft = themeID }
    }

    private func section(_ title: String, _ items: [ThemeSwatch]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
            LazyVGrid(columns: columns, spacing: Spacing.xs) {
                ForEach(items) { item in
                    Button { draft = item.id } label: {
                        VStack(spacing: Spacing.xs) {
                            Text(item.title)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                .fill(item.key)
                                .frame(height: 54)
                                .overlay(
                                    Text("ض")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(item.ink)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                                        .stroke(draft == item.id ? Color.white : Color.white.opacity(0.12), lineWidth: draft == item.id ? 2 : 1)
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

@available(iOS 18.0, *)
struct TranslationPrepCard: View {
    @State private var status = "جاري فحص حزم الترجمة…"

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("تجهيز ترجمة iOS 18")
                .font(.headline)
            Text(status)
                .font(.subheadline)
            Text("الترجمة داخل اللوحة بين العربية والإنجليزية فقط.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.62))
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .stroke(NaqraColors.border, lineWidth: 1)
                )
        .task {
            let availability = LanguageAvailability()
            let arEn = await availability.status(from: Locale.Language(identifier: "ar"), to: Locale.Language(identifier: "en"))
            let enAr = await availability.status(from: Locale.Language(identifier: "en"), to: Locale.Language(identifier: "ar"))
            switch (arEn, enAr) {
            case (.installed, .installed): status = "حزم العربية والإنجليزية جاهزة."
            case (.unsupported, _), (_, .unsupported): status = "الجهاز لا يدعم هذا الزوج من اللغات."
            default: status = "اللغات مدعومة. قد تُنزَّل الحزم عند أول ترجمة."
            }
        }
    }
}
