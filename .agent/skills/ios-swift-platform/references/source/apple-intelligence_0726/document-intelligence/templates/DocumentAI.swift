import Foundation
import CoreGraphics
import Vision
import DataDetection
import FoundationModels

// MARK: - Stage 1: structure (Vision, all devices, iOS 26+)

struct ScannedDocument: Sendable {
    var title: String?
    var fullText: String
    var tables: [[[String]]]              // table → rows → cell text
    var listItems: [String]
    var detected: [DataDetector.Match]    // money, dates, phones, addresses… with semantics
}

func scanDocument(_ image: CGImage, languages: [Locale.Language] = []) async throws -> ScannedDocument? {
    var request = RecognizeDocumentsRequest()
    request.textRecognitionOptions.useLanguageCorrection = true
    if !languages.isEmpty {
        request.textRecognitionOptions.automaticallyDetectLanguage = false
        request.textRecognitionOptions.recognitionLanguages = languages
    }
    request.barcodeDetectionOptions.enabled = false     // turn on for tickets/boarding passes

    guard let doc = try await request.perform(on: image, orientation: nil).first?.document else { return nil }

    let tables = doc.tables.map { table in
        table.rows.map { row in row.map { $0.content.text.transcript } }
    }
    return ScannedDocument(
        title: doc.title?.transcript,
        fullText: doc.text.transcript,
        tables: tables,
        listItems: doc.lists.flatMap { $0.items.map(\.itemString) },
        detected: doc.text.detectedData.map(\.match)
    )
}

// MARK: - Stage 2: deterministic facts (DataDetection, all devices)

struct Facts: Sendable {
    var amounts: [(Decimal, Locale.Currency)] = []
    var dates: [Date] = []
    var phones: [String] = []
    var addresses: [String] = []
}

func facts(from matches: [DataDetector.Match]) -> Facts {
    var f = Facts()
    for m in matches {
        switch m.details {
        case .moneyAmount(let money): f.amounts.append((money.amount, money.currency))
        case .calendarEvent(let event): if let d = event.startDate { f.dates.append(d) }
        case .phoneNumber(let p): f.phones.append(p.phoneNumber)
        case .postalAddress(let a): f.addresses.append(a.fullAddress)
        default: break
        }
    }
    return f
}

/// For plain strings (pasted text, PDFs) — same detector without Vision.
func detect(in text: String) async -> [DataDetector.Match] {
    var out: [DataDetector.Match] = []
    for await match in text.dataDetectorMatches([.moneyAmount, .calendarEvent, .phoneNumber, .postalAddress]) {
        out.append(match)
    }
    return out
}

// MARK: - Stage 3: semantic fields (Foundation Models, Apple Intelligence devices)

@Generable
struct Receipt: Equatable {
    @Guide(description: "Store or merchant name as printed")
    var merchant: String
    @Guide(description: "Purchase date as yyyy-MM-dd, or empty if not printed")
    var date: String
    @Guide(description: "Each purchased item; skip subtotal, tax, tip, and total lines")
    var items: [LineItem]
    @Guide(description: "Tax amount, 0 if none")
    var tax: Double
    @Guide(description: "Grand total actually charged")
    var total: Double
    @Guide(description: "ISO 4217 currency code, e.g. USD")
    var currency: String
}

@Generable
struct LineItem: Equatable {
    var name: String
    @Guide(description: "Quantity, 1 if not shown", .range(1...999))
    var quantity: Int
    @Guide(description: "Line price as printed")
    var price: Double
}

protocol ReceiptExtractor: Sendable {
    func extract(_ doc: ScannedDocument) async throws -> Receipt
}

struct OnDeviceReceiptExtractor: ReceiptExtractor {
    func extract(_ doc: ScannedDocument) async throws -> Receipt {
        let session = LanguageModelSession(instructions: """
            Extract a receipt from OCR text. Copy names and numbers exactly as printed. \
            Never invent items or amounts that are not in the text.
            """)
        // Tables first: Vision already aligned item/price columns, which is the hard part for a model.
        let tableText = doc.tables.map { $0.map { $0.joined(separator: " | ") }.joined(separator: "\n") }
            .joined(separator: "\n\n")
        let prompt = """
            TITLE: \(doc.title ?? "")
            TABLES:
            \(tableText)
            TEXT:
            \(doc.fullText)
            """
        return try await session.respond(to: prompt, generating: Receipt.self,
                                         options: GenerationOptions(samplingMode: .greedy)).content
    }
}

// MARK: - Stage 4: validate, then let the user confirm

enum ReceiptIssue: Equatable, Sendable {
    case itemsDontAddUp(expected: Double, actual: Double)
    case totalNotOnReceipt(Double)
    case missingDate
}

func validate(_ r: Receipt, against facts: Facts) -> [ReceiptIssue] {
    var issues: [ReceiptIssue] = []
    let sum = r.items.reduce(0) { $0 + $1.price } + r.tax
    if abs(sum - r.total) > 0.02 { issues.append(.itemsDontAddUp(expected: r.total, actual: sum)) }
    // The model's total must be a number the detector actually saw on the page.
    let printed = facts.amounts.map { NSDecimalNumber(decimal: $0.0).doubleValue }
    if !printed.isEmpty, !printed.contains(where: { abs($0 - r.total) < 0.005 }) {
        issues.append(.totalNotOnReceipt(r.total))
    }
    if r.date.isEmpty { issues.append(.missingDate) }
    return issues
}
