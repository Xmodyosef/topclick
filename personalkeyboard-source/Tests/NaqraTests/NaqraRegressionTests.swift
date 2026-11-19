import XCTest
import CoreText
@testable import PersonalKeyboard

final class ClipboardHistoryCodecTests: XCTestCase {
    func testJSONRoundTripPreservesUnicodeAndLegacySeparatorCharacters() throws {
        let original = ["before\u{1F}inside", "مرحبا 👋", "English"]
        let encoded = try XCTUnwrap(ClipboardHistoryCodec.encode(original))
        XCTAssertEqual(ClipboardHistoryCodec.decode(encoded), original)
    }

    func testLegacyFormatMigrationKeepsOriginalItemOrder() {
        XCTAssertEqual(
            ClipboardHistoryCodec.decodeLegacy("first\u{1F}second\u{1F}third"),
            ["first", "second", "third"]
        )
    }

    func testMalformedAndOversizedDocumentsAreRejected() {
        XCTAssertNil(ClipboardHistoryCodec.decode("{not-json"))
        XCTAssertNil(ClipboardHistoryCodec.encode([String(repeating: "x", count: 5_001)]))
        XCTAssertNil(ClipboardHistoryCodec.encode(Array(repeating: "x", count: 21)))
    }
}

final class LatestSelectionGateTests: XCTestCase {
    func testLateRequestAIsRejectedAfterRequestBStarts() async throws {
        let gate = LatestSelectionGate()
        let maybeRequestA = await gate.begin()
        let requestA = try XCTUnwrap(maybeRequestA)

        let lateA = Task {
            try? await Task.sleep(nanoseconds: 80_000_000)
            return await gate.isCurrent(requestA)
        }

        let maybeRequestB = await gate.begin()
        let requestB = try XCTUnwrap(maybeRequestB)
        let bIsCurrent = await gate.isCurrent(requestB)
        let aIsStillCurrent = await lateA.value

        XCTAssertTrue(bIsCurrent)
        XCTAssertFalse(aIsStillCurrent)
    }
}


final class SymbolPageCountTests: XCTestCase {
    func testArabicSymbolsContainExactlyTwoPages() {
        XCTAssertEqual(KeyboardSymbolCatalog.builtinArabicSymbols.count, 2)
    }

    func testEnglishSymbolsContainExactlyTwoPages() {
        XCTAssertEqual(KeyboardSymbolCatalog.builtinEnglishSymbols.count, 2)
    }
}


final class KeyboardGlyphMetricsTests: XCTestCase {
    func testArabicAndUnicodeSymbolsUseReducedGlyphScale() {
        XCTAssertTrue(KeyboardGlyphMetrics.usesSymbolScale("﷼"))
        XCTAssertTrue(KeyboardGlyphMetrics.usesSymbolScale("٪"))
        XCTAssertTrue(KeyboardGlyphMetrics.usesSymbolScale("∞"))
        XCTAssertTrue(KeyboardGlyphMetrics.usesSymbolScale("؟"))
    }

    func testDigitsAndLettersKeepTheLetterGlyphScale() {
        XCTAssertFalse(KeyboardGlyphMetrics.usesSymbolScale("1"))
        XCTAssertFalse(KeyboardGlyphMetrics.usesSymbolScale("a"))
        XCTAssertFalse(KeyboardGlyphMetrics.usesSymbolScale("م"))
    }

    func testSymbolScaleIsSmallerThanLetterScale() {
        XCTAssertEqual(KeyboardGlyphMetrics.symbolPointSize, 24)
        XCTAssertLessThan(KeyboardGlyphMetrics.symbolPointSize, 26)
    }
}

final class SoundPackCatalogTests: XCTestCase {
    func testPianoAndDedicatedTypewriterPacksAreSelectable() {
        XCTAssertTrue(SoundPackStore.knownIDs.contains("piano"))
        XCTAssertTrue(SoundPackStore.knownIDs.contains("typewriter"))
        XCTAssertEqual(SoundPackStore.title(for: "piano"), "بيانو")
    }
}


final class KeyboardTypographyTests: XCTestCase {
    func testArabicKeyGlyphsResolveToAppleSystemArabicFamily() {
        for character in ["ا", "ب", "م", "ي", "ع", "ة", "َ", "ّ"] {
            let font = KeyboardTypography.font(for: character, size: 26, weight: .medium)
            XCTAssertEqual(font.pointSize, 26, "Unexpected point size for \\(character)")
            XCTAssertTrue(KeyboardTypography.containsArabicScript(character))
            XCTAssertTrue(
                font.familyName.localizedCaseInsensitiveContains("Arabic"),
                "Expected Apple SF Arabic system fallback for \\(character), got \\(font.familyName)"
            )
            let coreTextFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
            var characters = Array(character.utf16)
            var glyphs = [CGGlyph](repeating: 0, count: characters.count)
            XCTAssertTrue(
                CTFontGetGlyphsForCharacters(coreTextFont, &characters, &glyphs, characters.count),
                "System font cascade did not resolve \\(character)"
            )
            XCTAssertTrue(glyphs.allSatisfy { $0 != 0 }, "Missing glyph for \\(character)")
        }
    }

    func testLatinKeysRemainOnTheDefaultSystemFont() {
        XCTAssertFalse(KeyboardTypography.containsArabicScript("A"))
        XCTAssertFalse(KeyboardTypography.containsArabicScript("7"))
        let font = KeyboardTypography.font(for: "A", size: 26, weight: .medium)
        XCTAssertEqual(font.fontName, UIFont.systemFont(ofSize: 26, weight: .medium).fontName)
    }
}
