import CoreText
import UIKit

/// Uses Apple's language-aware system UI font selection for Arabic glyphs.
/// SF Arabic is supplied by iOS; it must not be bundled or loaded by private name.
enum KeyboardTypography {
    /// Bounded reuse of Core Text Arabic resolutions. Language retitle and suggestion
    /// refresh call this for every key; without a cap the extension recreates CTFont
    /// objects under Jetsam pressure (see per-process-limit rpages ~4928).
    private static let arabicFontCache: NSCache<NSString, UIFont> = {
        let cache = NSCache<NSString, UIFont>()
        // ~40 letter keys × 2 scripts + digits + hold alts + suggestions. Hard cap.
        cache.countLimit = 96
        return cache
    }()

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

    /// Trial switch. Off by default so the shipped path stays CTFont.
    /// The keyboard report button turns this on for one session variable: plain UIFont.
    static var plainSystemFontForArabic = false

    static func font(
        for text: String,
        size: CGFloat,
        weight: UIFont.Weight = .medium
    ) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        guard containsArabicScript(text), !text.isEmpty else {
            return systemFont
        }
        if plainSystemFontForArabic {
            return systemFont
        }

        let cacheKey = "\(text)|\(size)|\(weight.rawValue)" as NSString
        if let cached = arabicFontCache.object(forKey: cacheKey) {
            return cached
        }

        // Start with the normal system UI font so its system cascade is retained.
        // Core Text resolves the actual font that covers this Arabic key in that cascade.
        let resolvedFont = CTFontCreateForStringWithLanguage(
            systemFont as CTFont,
            text as CFString,
            CFRange(location: 0, length: (text as NSString).length),
            "ar" as CFString
        ) as UIFont

        arabicFontCache.setObject(resolvedFont, forKey: cacheKey)
        return resolvedFont
    }

    /// Drop cached CTFont wrappers under memory pressure. Safe to call often.
    static func clearFontCache() {
        arabicFontCache.removeAllObjects()
    }
}
