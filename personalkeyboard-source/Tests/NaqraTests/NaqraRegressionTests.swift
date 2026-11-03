import XCTest
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
