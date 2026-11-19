import CoreText
import UIKit

/// Resolves Arabic keys through Apple's installed script-aware system font cascade.
/// Do not bundle SF Arabic or address Apple's reserved font by a private name.
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

        // Core Text resolves the actual system face that contains the Arabic glyphs.
        // On Apple platforms this selects SF Arabic rather than an embedded third-party font.
        let baseFont = CTFontCreateWithName(systemFont.fontName as CFString, size, nil)
        let resolvedFont = CTFontCreateForString(
            baseFont,
            text as CFString,
            CFRange(location: 0, length: text.utf16.count)
        )
        return resolvedFont as UIFont
    }
}
