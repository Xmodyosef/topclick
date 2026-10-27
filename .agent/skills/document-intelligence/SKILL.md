---
name: document-intelligence
description: Turn photos of receipts, invoices, forms, labels, and menus into typed Swift data on-device — Vision RecognizeDocumentsRequest for structure (tables, lists, paragraphs), the DataDetection framework for money/dates/addresses, Foundation Models @Generable extraction for semantic fields, and validation that catches hallucinated numbers before the user confirms. Use when the user wants receipt scanning, expense capture, invoice or form parsing, "scan and fill", nutrition labels, or structured data from documents without a cloud OCR API.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27
---

# Document Intelligence

The reliable way to get *structured* data from a document is a **four-stage
pipeline**. Each stage does what it's best at, and only one stage needs Apple
Intelligence:

| Stage | Tool | Runs on | Gives you |
|---|---|---|---|
| 1. Structure | Vision `RecognizeDocumentsRequest` (iOS 26+) | All devices | Title, paragraphs, **tables (rows × cells)**, lists, barcodes |
| 2. Facts | DataDetection `DataDetector` (iOS 26+) | All devices | Typed money (`Decimal` + currency), dates, phones, addresses, tracking and flight numbers |
| 3. Meaning | Foundation Models `@Generable` | Apple Intelligence | "Which number is the total?", line items, merchant, category |
| 4. Trust | Your validation plus a review screen | — | Flags hallucinated or inconsistent values before saving |

Capture (camera, document scanner, photo picker) is covered in `ios/camera-scanning`.
This skill starts from a `CGImage`. Code is in `templates/DocumentAI.swift` and
`DocumentAITests.swift`, which typecheck in Swift 6 and under default MainActor isolation.

## When This Skill Activates

- Receipt or expense scanning, invoice or bill capture, "scan and fill the form"
- Nutrition labels, business cards, menus, prescriptions, shipping labels
- Replacing a cloud OCR or document-AI API
- "The AI made up a total": validating model-extracted numbers

## Stage 1: Structure

```swift
func scanDocument(_ image: CGImage, languages: [Locale.Language] = []) async throws -> ScannedDocument? {
    var request = RecognizeDocumentsRequest()
    request.textRecognitionOptions.useLanguageCorrection = true
    if !languages.isEmpty {
        request.textRecognitionOptions.automaticallyDetectLanguage = false
        request.textRecognitionOptions.recognitionLanguages = languages
    }
    request.barcodeDetectionOptions.enabled = false     // enable for tickets and boarding passes

    guard let doc = try await request.perform(on: image, orientation: nil).first?.document else { return nil }

    let tables = doc.tables.map { table in
        table.rows.map { row in row.map { $0.content.text.transcript } }
    }
    return ScannedDocument(
        title: doc.title?.transcript,
        fullText: doc.text.transcript,
        tables: tables,
        listItems: doc.lists.flatMap { $0.items.map(\.itemString) },
        detected: doc.text.detectedData.map(\.match)      // DataDetector matches for free
    )
}
```

- ✅ `RecognizeDocumentsRequest` over `RecognizeTextRequest` for anything with columns. It returns **tables with cells aligned**, which is exactly what flat OCR loses on receipts.
- Cells can span (`rowRange` / `columnRange`). Use `table.cell(row:col:)` for lookups.
- Every container has a `boundingRegion` (normalized, lower-left origin). Use it to highlight the source of each extracted field in the review UI.
- `textRecognitionOptions.customWords` boosts domain vocabulary (drug names, SKUs).

## Stage 2: Facts

Each document text block exposes `detectedData`. For plain strings (pasted text, PDF
text), call the detector directly:

```swift
for await match in text.dataDetectorMatches([.moneyAmount, .calendarEvent, .phoneNumber, .postalAddress]) {
    switch match.details {
    case .moneyAmount(let m): print(m.amount, m.currency)          // Decimal + Locale.Currency
    case .calendarEvent(let e): print(e.startDate as Any)
    case .postalAddress(let a): print(a.city as Any, a.postalCode as Any)
    default: break
    }
}
```

- Also detected: `.link`, `.emailAddress`, `.measurement`, `.flightNumber`, `.shipmentTrackingNumber`, and `.paymentIdentifier`.
- Set `DataDetector.Options().documentDate`, `.documentRegion`, and `.documentLanguageCode` so "Tuesday" and "03/04" resolve correctly.
- `DataDetector.Match` and its details are `Codable` and `Hashable` from iOS 27, so you can store them as-is.
- ❌ Regexes for amounts and dates. They break on locales ("1.234,56 €"); the detector doesn't.

## Stage 3: Meaning

```swift
@Generable
struct Receipt: Equatable {
    @Guide(description: "Store or merchant name as printed") var merchant: String
    @Guide(description: "Purchase date as yyyy-MM-dd, or empty if not printed") var date: String
    @Guide(description: "Each purchased item; skip subtotal, tax, tip, and total lines") var items: [LineItem]
    @Guide(description: "Tax amount, 0 if none") var tax: Double
    @Guide(description: "Grand total actually charged") var total: Double
    @Guide(description: "ISO 4217 currency code, e.g. USD") var currency: String
}

struct OnDeviceReceiptExtractor: ReceiptExtractor {
    func extract(_ doc: ScannedDocument) async throws -> Receipt {
        let session = LanguageModelSession(instructions: """
            Extract a receipt from OCR text. Copy names and numbers exactly as printed. \
            Never invent items or amounts that are not in the text.
            """)
        let tableText = doc.tables.map { $0.map { $0.joined(separator: " | ") }.joined(separator: "\n") }
            .joined(separator: "\n\n")
        return try await session.respond(
            to: "TITLE: \(doc.title ?? "")\nTABLES:\n\(tableText)\nTEXT:\n\(doc.fullText)",
            generating: Receipt.self,
            options: GenerationOptions(samplingMode: .greedy)          // deterministic extraction
        ).content
    }
}
```

- ✅ **Feed tables as `cell | cell` rows** before the raw text. Vision already did the column alignment, so the model only has to label it.
- ✅ Greedy sampling for extraction: the same receipt should produce the same JSON.
- ✅ Property order matters in `@Generable`. Fields are generated top-down, so put context (merchant, items) before conclusions (total).
- `GenerationOptions(sampling:)` is **deprecated in iOS 27**; use `samplingMode:`.
- Keep the prompt under the on-device context window. For long invoices, extract per page or per table and merge.
- No Apple Intelligence? Keep stages 1, 2, and 4. Prefill the largest detected money amount as the total and the first date as the date, and let the user correct them.
- iOS 27 alternative: attach the photo directly (`Attachment(image)`) with `OCRTool()` in the session (`apple-intelligence/in-app-agent`). It's simpler, but you lose table structure and bounding regions for the review UI.

## Stage 4: Trust

Models misread digits and occasionally invent plausible totals. Check model output
against what the deterministic stages saw:

```swift
func validate(_ r: Receipt, against facts: Facts) -> [ReceiptIssue] {
    var issues: [ReceiptIssue] = []
    let sum = r.items.reduce(0) { $0 + $1.price } + r.tax
    if abs(sum - r.total) > 0.02 { issues.append(.itemsDontAddUp(expected: r.total, actual: sum)) }
    let printed = facts.amounts.map { NSDecimalNumber(decimal: $0.0).doubleValue }
    if !printed.isEmpty, !printed.contains(where: { abs($0 - r.total) < 0.005 }) {
        issues.append(.totalNotOnReceipt(r.total))          // the model's total isn't printed anywhere
    }
    if r.date.isEmpty { issues.append(.missingDate) }
    return issues
}
```

Review screen: show the image with each field's `boundingRegion` highlighted, mark
flagged fields 🟠, and **require a tap to save**. Never auto-save extracted money.

## Testing

- `validate` and table flattening are pure, so cover them with Swift Testing (`DocumentAITests.swift`). `@Generable` structs keep their memberwise init, which makes fixtures easy.
- `ReceiptExtractor` is a protocol. Previews and UI tests use `FakeReceiptExtractor`.
- Build an eval set of 30+ real receipt photos (crumpled, thermal, angled, foreign currency) with expected JSON, and re-run it on every OS update.

## Common Mistakes

| ❌ | ✅ |
|---|---|
| Flat OCR text → LLM | `RecognizeDocumentsRequest` tables → LLM |
| Regex for money and dates | `DataDetector` (`moneyAmount` gives a `Decimal` + `Locale.Currency`) |
| Trusting the model's total | Cross-check against detected amounts and the item sum |
| `Double` for stored money | Store a `Decimal` (convert from the detector's value), and only use `Double` inside `@Generable` |
| Auto-saving extracted data | A review screen with source highlights and a confirm button |
| `GenerationOptions(sampling:)` | `GenerationOptions(samplingMode: .greedy)` |

## Checklist

- [ ] Stage 1 uses `RecognizeDocumentsRequest` (tables and lists), with languages set when known
- [ ] Stage 2 facts from `detectedData` / `dataDetectorMatches`, with document options set
- [ ] Stage 3 behind a `ReceiptExtractor` protocol, greedy sampling, tables in the prompt
- [ ] Non-Apple-Intelligence path still useful (prefill from stage 2)
- [ ] Stage 4 validation; flagged fields shown; explicit confirm
- [ ] Unit tests for validation; eval set of real documents

## References

- RecognizeDocumentsRequest: https://developer.apple.com/documentation/vision/recognizedocumentsrequest
- DocumentObservation: https://developer.apple.com/documentation/vision/documentobservation
- DataDetection: https://developer.apple.com/documentation/datadetection
- Generating Swift data structures with guided generation: https://developer.apple.com/documentation/foundationmodels/generating-swift-data-structures-with-guided-generation
- Related: `ios/camera-scanning` (capture), `apple-intelligence/foundation-models`, `apple-intelligence/in-app-agent`, `apple-intelligence/on-device-ai-kit`
