import Foundation

/// Single theme table for the container app and the keyboard extension.
/// Paint formulas stay in NaqraPalette; this file is only id, name, RGB, legacy.
struct SharedThemeSpec {
    let id: String
    let title: String
    let red: Double
    let green: Double
    let blue: Double
    let dark: Bool
    let legacy: Bool
}

enum SharedThemeCatalog {
    static let specs: [SharedThemeSpec] = [
        .init(id: "auto", title: "تلقائي", red: 0.16, green: 0.18, blue: 0.23, dark: true, legacy: false),
        .init(id: "light", title: "فاتح", red: 0.9, green: 0.95, blue: 0.99, dark: false, legacy: false),
        .init(id: "dark", title: "داكن", red: 0.1, green: 0.16, blue: 0.28, dark: true, legacy: false),
        .init(id: "glass", title: "منشور", red: 0.86, green: 0.82, blue: 0.96, dark: false, legacy: false),
        .init(id: "ocean", title: "بحر", red: 0.06, green: 0.22, blue: 0.32, dark: true, legacy: false),
        .init(id: "cobalt", title: "كوبالت", red: 0.1, green: 0.18, blue: 0.42, dark: true, legacy: false),
        .init(id: "violet", title: "بنفسج", red: 0.18, green: 0.1, blue: 0.32, dark: true, legacy: false),
        .init(id: "orchid", title: "أوركيد", red: 0.32, green: 0.08, blue: 0.18, dark: true, legacy: false),
        .init(id: "hailey", title: "دم", red: 0.22, green: 0.05, blue: 0.08, dark: true, legacy: false),
        .init(id: "ember", title: "جمر", red: 0.24, green: 0.12, blue: 0.05, dark: true, legacy: false),
        .init(id: "forest", title: "غابة", red: 0.06, green: 0.18, blue: 0.12, dark: true, legacy: false),
        .init(id: "matrix", title: "ماتريكس", red: 0.02, green: 0.07, blue: 0.03, dark: true, legacy: false),
        .init(id: "nord", title: "نورد", red: 0.78, green: 0.82, blue: 0.86, dark: false, legacy: false),
        .init(id: "morning", title: "صباح", red: 0.96, green: 0.9, blue: 0.78, dark: false, legacy: false),
        .init(id: "evening", title: "مساء", red: 0.08, green: 0.12, blue: 0.24, dark: true, legacy: false),
        .init(id: "m1", title: "رملي", red: 0.93, green: 0.86, blue: 0.72, dark: false, legacy: true),
        .init(id: "m2", title: "قش", red: 0.9, green: 0.82, blue: 0.62, dark: false, legacy: true),
        .init(id: "m3", title: "خوخ", red: 0.96, green: 0.78, blue: 0.68, dark: false, legacy: true),
        .init(id: "m4", title: "مشمش", red: 0.96, green: 0.72, blue: 0.48, dark: false, legacy: true),
        .init(id: "m5", title: "عاج", red: 0.95, green: 0.92, blue: 0.84, dark: false, legacy: true),
        .init(id: "m6", title: "حليب", red: 0.96, green: 0.94, blue: 0.9, dark: false, legacy: true),
        .init(id: "m7", title: "نعناع", red: 0.74, green: 0.9, blue: 0.82, dark: false, legacy: true),
        .init(id: "m8", title: "مريمية", red: 0.7, green: 0.8, blue: 0.72, dark: false, legacy: true),
        .init(id: "m9", title: "سماء", red: 0.7, green: 0.84, blue: 0.94, dark: false, legacy: true),
        .init(id: "m10", title: "بحيرة", red: 0.55, green: 0.78, blue: 0.86, dark: false, legacy: true),
        .init(id: "m11", title: "لافندر", red: 0.82, green: 0.76, blue: 0.9, dark: false, legacy: true),
        .init(id: "m12", title: "ورد", red: 0.94, green: 0.74, blue: 0.8, dark: false, legacy: true),
        .init(id: "m13", title: "ذهب", red: 0.9, green: 0.76, blue: 0.4, dark: false, legacy: true),
        .init(id: "m14", title: "عسل", red: 0.88, green: 0.68, blue: 0.36, dark: false, legacy: true),
        .init(id: "m15", title: "زيتون", red: 0.62, green: 0.66, blue: 0.4, dark: false, legacy: true),
        .init(id: "m16", title: "طين", red: 0.72, green: 0.52, blue: 0.4, dark: false, legacy: true),
        .init(id: "m17", title: "ورق", red: 0.78, green: 0.84, blue: 0.72, dark: false, legacy: true),
        .init(id: "m18", title: "ضباب", red: 0.82, green: 0.84, blue: 0.86, dark: false, legacy: true),
        .init(id: "m19", title: "مرجان", red: 0.92, green: 0.55, blue: 0.5, dark: false, legacy: true),
        .init(id: "m20", title: "فستق", red: 0.7, green: 0.82, blue: 0.58, dark: false, legacy: true),
        .init(id: "e1", title: "فحم", red: 0.12, green: 0.12, blue: 0.13, dark: true, legacy: true),
        .init(id: "e2", title: "كحلي", red: 0.08, green: 0.12, blue: 0.22, dark: true, legacy: true),
        .init(id: "e3", title: "ليل", red: 0.07, green: 0.09, blue: 0.16, dark: true, legacy: true),
        .init(id: "e4", title: "حبر", red: 0.1, green: 0.12, blue: 0.18, dark: true, legacy: false),
        .init(id: "e5", title: "برقوق", red: 0.18, green: 0.1, blue: 0.22, dark: true, legacy: false),
        .init(id: "e6", title: "نبيذ", red: 0.24, green: 0.08, blue: 0.14, dark: true, legacy: false),
        .init(id: "e7", title: "غابة", red: 0.08, green: 0.16, blue: 0.12, dark: true, legacy: false),
        .init(id: "e8", title: "زمرد", red: 0.06, green: 0.18, blue: 0.16, dark: true, legacy: false),
        .init(id: "e9", title: "محيط", red: 0.06, green: 0.14, blue: 0.22, dark: true, legacy: false),
        .init(id: "e10", title: "كوبالت ليلي", red: 0.1, green: 0.16, blue: 0.32, dark: true, legacy: false),
        .init(id: "e11", title: "جمر", red: 0.22, green: 0.1, blue: 0.08, dark: true, legacy: false),
        .init(id: "e12", title: "نحاس", red: 0.28, green: 0.16, blue: 0.1, dark: true, legacy: false),
        .init(id: "e13", title: "بنفسج ليلي", red: 0.16, green: 0.1, blue: 0.28, dark: true, legacy: false),
        .init(id: "e14", title: "أوركيد ليلي", red: 0.26, green: 0.08, blue: 0.18, dark: true, legacy: false),
        .init(id: "e15", title: "رماد", red: 0.16, green: 0.18, blue: 0.22, dark: true, legacy: false),
        .init(id: "e16", title: "دخان", red: 0.14, green: 0.14, blue: 0.16, dark: true, legacy: false),
        .init(id: "e17", title: "قهوة", red: 0.18, green: 0.12, blue: 0.08, dark: true, legacy: false),
        .init(id: "e18", title: "صحراء", red: 0.2, green: 0.14, blue: 0.1, dark: true, legacy: false),
        .init(id: "e19", title: "ملكي", red: 0.12, green: 0.08, blue: 0.2, dark: true, legacy: false),
        .init(id: "e20", title: "فجر", red: 0.18, green: 0.1, blue: 0.12, dark: true, legacy: false),
        .init(id: "aurora", title: "شفق", red: 0.1, green: 0.28, blue: 0.3, dark: true, legacy: false),
        .init(id: "lavender", title: "لافندر ليلي", red: 0.28, green: 0.2, blue: 0.42, dark: true, legacy: false),
        .init(id: "sunset", title: "غروب", red: 0.38, green: 0.14, blue: 0.16, dark: true, legacy: false),
        .init(id: "mint", title: "نعناع ليلي", red: 0.08, green: 0.24, blue: 0.22, dark: true, legacy: false),
        .init(id: "rose", title: "وردي", red: 0.36, green: 0.12, blue: 0.24, dark: true, legacy: false),
        .init(id: "mono", title: "أحادي", red: 0.22, green: 0.23, blue: 0.25, dark: true, legacy: false),
        .init(id: "custom", title: "مخصص", red: 0.55, green: 0.62, blue: 0.7, dark: true, legacy: false),
    ]

    static func spec(_ id: String) -> SharedThemeSpec? {
        specs.first { $0.id == id }
    }

    static var titles: [String: String] {
        Dictionary(uniqueKeysWithValues: specs.map { ($0.id, $0.title) })
    }

    static let order: [String] = specs.map(\.id)

    /// m1…m20 and e1…e3: exact key RGB, painted with the historical delta.
    static var legacyRGB: [String: (Double, Double, Double, Bool)] {
        var out: [String: (Double, Double, Double, Bool)] = [:]
        for spec in specs where spec.legacy {
            out[spec.id] = (spec.red, spec.green, spec.blue, spec.dark)
        }
        return out
    }
}
