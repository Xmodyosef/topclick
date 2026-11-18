import Foundation

enum KeyboardGlyphMetrics {
    static let symbolPointSize: CGFloat = 24

    static func usesSymbolScale(_ text: String) -> Bool {
        text.unicodeScalars.contains {
            CharacterSet.symbols.contains($0) || CharacterSet.punctuationCharacters.contains($0)
        }
    }
}
