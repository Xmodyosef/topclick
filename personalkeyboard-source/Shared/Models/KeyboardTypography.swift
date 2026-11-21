import CoreText
import UIKit

/// Uses Apple's language-aware system UI font selection for Arabic glyphs.
/// SF Arabic is supplied by iOS; it must not be bundled or loaded by private name.
enum KeyboardTypography {
    /// EXP-1 (jetsam): cap Core Text resolve cost across language flips.
    /// Key titles are a small fixed set; unbounded CTFontCreate per key was a memory suspect.
    private static var arabicFontCache: [String: UIFont] = [:]
    private static let arabicFontCacheLimit = 64

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

        let cacheKey = "\(size)|\(weight.rawValue)|\(text)"
        if let cached = arabicFontCache[cacheKey] {
            return cached
        }

        // Start with the normal system UI font so its system cascade is retained.
        // Core Text resolves the actual font that covers this Arabic key in that cascade.
        let resolvedFont = CTFontCreateForStringWithLanguage(
            systemFont as CTFont,
            text as CFString,
            CFRange(location: 0, length: (text as NSString).length),
            "ar" as CFString
        )

        let uiFont = resolvedFont as UIFont
        if arabicFontCache.count >= arabicFontCacheLimit {
            arabicFontCache.removeAll(keepingCapacity: true)
        }
        arabicFontCache[cacheKey] = uiFont
        return uiFont
    }

    /// Optional release path under memory pressure (not required for correctness).
    static func clearArabicFontCache() {
        arabicFontCache.removeAll(keepingCapacity: false)
    }
}
