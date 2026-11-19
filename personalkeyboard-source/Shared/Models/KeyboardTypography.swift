import CoreText
import UIKit

/// Uses Apple's language-aware system UI font selection for Arabic glyphs.
/// SF Arabic is supplied by iOS; it must not be bundled or loaded by private name.
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
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        guard containsArabicScript(text), !text.isEmpty else {
            return systemFont
        }

        // This API selects the localized system UI face (SF Arabic for Arabic),
        // unlike recreating a font from UIKit's private .SFUI-* PostScript name.
        guard let arabicSystemFont = CTFontCreateUIFontForLanguage(
            .system,
            size,
            "ar" as CFString
        ) else {
            return systemFont
        }

        return arabicSystemFont as UIFont
    }
}
