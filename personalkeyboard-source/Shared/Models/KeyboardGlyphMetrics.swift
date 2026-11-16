import Foundation

/// Shared visual sizing rules for the keyboard's letter and symbol key labels.
enum KeyboardGlyphMetrics {
    static let letterPointSize: CGFloat = 26
    static let symbolPointSize: CGFloat = 24

    /// Digits retain the letter size; punctuation and Unicode symbols use a
    /// slightly smaller point size to compensate for their larger visual forms.
    static func usesSymbolScale(_ text: String) -> Bool {
        text.unicodeScalars.contains {
            CharacterSet.symbols.contains($0) || CharacterSet.punctuationCharacters.contains($0)
        }
    }
}
