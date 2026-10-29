---
name: camera-scanning
description: On-device camera input for iPhone apps — live text and barcode scanning (VisionKit DataScannerViewController), multi-page document capture (VNDocumentCameraViewController), OCR on any image with the Swift Vision API (RecognizeTextRequest), and permission-free photo import (PhotosPicker). Use when the user wants to scan receipts, labels, documents, QR codes, or extract text from photos without a server.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# Camera & Scanning

Apple ships three production-grade scanners and an OCR engine. All of them run on
device, cost nothing, and replace what used to be a cloud OCR subscription.
Every snippet below compiles against the iOS 27 SDK (Swift 6 and default-MainActor modes).

Image *classification* / custom models → `core-ml`. Feeding an image to the
on-device LLM → `apple-intelligence/foundation-models` (models-and-agents.md, vision input).

## When This Skill Activates

- Scan receipts, nutrition labels, business cards, serial numbers, QR/barcodes
- "Scan a document", multi-page capture with auto-crop
- Extract text from photos the user already has
- Choosing between the live scanner, document camera, and OCR-after-capture

## Pick the Tool

| Need | Tool | Permission |
|---|---|---|
| Point camera, tap text/barcode live | `DataScannerViewController` (VisionKit) | Camera |
| Flatbed-style pages, auto edge-detect, multi-page | `VNDocumentCameraViewController` (VisionKit) | Camera |
| Text from an existing photo/scan | `RecognizeTextRequest` (Vision) | none |
| Pick photos from the library | `PhotosPicker` (PhotosUI) | **none**, out-of-process picker |

✅ Start with `PhotosPicker` + OCR when the use case allows it: no permission prompt, works in the Simulator.
❌ Requesting full photo-library access to import one image. The picker already returns only what the user chose.

Setup: `NSCameraUsageDescription` ("MyApp scans food labels to log meals.") for the two camera tools.

## Live Scanner (text + barcodes)

```swift
import SwiftUI
import VisionKit

struct LiveScanner: UIViewControllerRepresentable {
    var onFound: (String) -> Void

    static var isUsable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [.text(), .barcode(symbologies: [.qr, .ean13])],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {
        if !vc.isScanning { try? vc.startScanning() }
    }

    static func dismantleUIViewController(_ vc: DataScannerViewController, coordinator: Coordinator) {
        vc.stopScanning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(onFound: onFound) }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onFound: (String) -> Void
        init(onFound: @escaping (String) -> Void) { self.onFound = onFound }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text): onFound(text.transcript)
            case .barcode(let code): onFound(code.payloadStringValue ?? "")
            @unknown default: break
            }
        }
    }
}
```

- `isSupported`: device has the Neural Engine (A12+). `isAvailable`: camera permission granted and not restricted. Check both, and fall back to `PhotosPicker` + OCR.
- `.text(textContentType: .URL)` (also `.telephoneNumber`, `.emailAddress`, `.dateTimeDuration`…) narrows recognition.
- **Simulator: not supported.** Test on device.

## Document Camera

```swift
import SwiftUI
import VisionKit

struct DocumentScanner: UIViewControllerRepresentable {
    var onScan: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ vc: VNDocumentCameraViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    @MainActor final class Coordinator: NSObject, @MainActor VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScanner
        init(parent: DocumentScanner) { self.parent = parent }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.onScan((0..<scan.pageCount).map { scan.imageOfPage(at: $0) })
            parent.dismiss()
        }
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
    }
}
```

Present it with `.fullScreenCover`. Note the **isolated conformance**
(`@MainActor VNDocumentCameraViewControllerDelegate`, Swift 6.2+) on a `@MainActor` class:

❌ Plain `final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate` → Swift 6 warnings touching `dismiss`/`onScan`.
❌ `@MainActor final class … VNDocumentCameraViewControllerDelegate` without the isolated conformance → **error**: "conformance crosses into main actor-isolated code".

## OCR on Any Image (Swift Vision API)

```swift
import Vision

func recognizeText(in imageData: Data) async throws -> [String] {
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    let observations = try await request.perform(on: imageData)
    return observations.compactMap { $0.topCandidates(1).first?.string }
}
```

`perform(on:)` also accepts `CGImage`, `CIImage`, `CVPixelBuffer`, and a file `URL`.
Set `request.recognitionLanguages` for non-English text. `.fast` suits live preview; `.accurate` suits a captured page.

✅ Use the struct-based Swift Vision API (`RecognizeTextRequest`, iOS 18+).
❌ New code on `VNRecognizeTextRequest` + `VNImageRequestHandler`. That's the older callback API, wordier and not concurrency-native.

## Photo Import (no permission)

```swift
import SwiftUI
import PhotosUI

struct PhotoImport: View {
    @State private var selection: PhotosPickerItem?
    @State private var lines: [String] = []

    var body: some View {
        PhotosPicker("Import receipt", selection: $selection, matching: .images)
            .onChange(of: selection) { _, item in
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                    lines = (try? await recognizeText(in: data)) ?? []
                }
            }
    }
}
```

## Turning Text Into Data

OCR gives you lines; the app usually wants fields (merchant, total, date). Options,
cheapest first:

1. `NSDataDetector` / regex for dates, amounts, phone numbers. Works on every device.
2. **Foundation Models** `@Generable` extraction, gated on availability (`apple-intelligence/on-device-ai-kit`):

```swift
// @Generable struct Receipt { var merchant: String; var total: Double; var date: String }
// let receipt = try await session.respond(to: lines.joined(separator: "\n"), generating: Receipt.self).content
```

Fall back to option 1 on devices without Apple Intelligence. Never block the core flow on the LLM.

## Checklist

- [ ] `NSCameraUsageDescription` if a camera tool is used
- [ ] `DataScannerViewController.isSupported && .isAvailable` checked, with fallback
- [ ] PhotosPicker path exists (Simulator, older devices, denied camera)
- [ ] Document camera coordinator uses `@MainActor` class + `@MainActor` conformance
- [ ] OCR on Swift Vision API; recognition languages set when non-English
- [ ] Scanned images stored locally; never uploaded without consent

## References

- VisionKit DataScannerViewController: https://developer.apple.com/documentation/visionkit/datascannerviewcontroller
- VNDocumentCameraViewController: https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller
- RecognizeTextRequest: https://developer.apple.com/documentation/vision/recognizetextrequest
- PhotosPicker: https://developer.apple.com/documentation/photosui/photospicker
- Related: `core-ml`, `apple-intelligence/on-device-ai-kit`, `apple-intelligence/visual-intelligence`
