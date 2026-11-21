import UIKit

/// Official iOS UI Arabic: `UIFont.systemFont` (SF Arabic via the system cascade).
/// No private font names, no bundled Arabic face, no per-key CTFont resolution.
enum KeyboardTypography {
    static func containsArabicScript(_ text: String) -> Bool {
        text.unicodeScalars.contains { scalar in
            let value = scalar.value
            return (0x0600...0x06FF).contains(value)
                || (0x0750...0x077F).contains(value)
                || (0x0870...0x089F).contains(value)
                || (0x08A0...0x08FF).contains(value)
                || (0xFB50...0xFDFF).contains(value)
                || (0xFE70...0xFEFF).contains(value)
                || (0x10E60...0x10E7F).contains(value)
                || (0x1EE00...0x1EEFF).contains(value)
        }
    }

    static func font(
        for text: String,
        size: CGFloat,
        weight: UIFont.Weight = .medium
    ) -> UIFont {
        // Same path for Arabic and Latin: Apple’s system UI font.
        // SF Arabic is selected by the cascade when glyphs need it.
        _ = text
        return UIFont.systemFont(ofSize: size, weight: weight)
    }

    /// Kept for call sites under memory pressure. No cache remains.
    static func clearFontCache() {}
}
