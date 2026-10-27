---
name: speech-translation
description: On-device speech-to-text with SpeechAnalyzer/SpeechTranscriber (DictationTranscriber fallback), microphone and file input via the iOS 27 CaptureInputSequenceProvider / AssetInputSequenceProvider / AnalyzerInputConverter, and on-device translation with the Translation framework (system overlay, in-app batch translation, installed-language sessions). Use when the user wants voice notes, dictation, live captions, transcribing audio, or translating text in-app without a cloud API.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27
---

# Speech & Translation (on-device)

Two frameworks that replace paid cloud APIs. Neither needs Apple Intelligence, so
they work on far more iPhones than Foundation Models. Language models download on
demand and then run offline. Code compiles against the iOS 27 SDK in Swift 6 and
default-MainActor modes.

## When This Skill Activates

- Voice notes, dictation into a text field, live captions, transcribing a recording
- Translate user content (notes, messages, labels) in the app
- Replacing `SFSpeechRecognizer` or a cloud speech/translation API

## Speech: Pick the Module

| Module | Use for | Availability |
|---|---|---|
| `SpeechTranscriber` | Long-form, high-accuracy notes, meetings, lectures | `SpeechTranscriber.isAvailable` (newer hardware) |
| `DictationTranscriber` | Short dictation; fallback where SpeechTranscriber isn't available | Broad device support |
| `SpeechDetector` | Voice-activity detection alongside a transcriber | — |

```swift
import Speech

func makeModule(locale: Locale) async -> (any SpeechModule)? {
    if SpeechTranscriber.isAvailable,
       let l = await SpeechTranscriber.supportedLocale(equivalentTo: locale) {
        return SpeechTranscriber(locale: l, preset: .progressiveTranscription)
    }
    if let l = await DictationTranscriber.supportedLocale(equivalentTo: locale) {
        return DictationTranscriber(locale: l, preset: .progressiveShortDictation)
    }
    return nil
}
```

Presets: `.transcription` (file, final only), `.progressiveTranscription` (live, with
volatile partials), `.timeIndexedProgressiveTranscription` (adds audio time ranges for captions/seek).

✅ SpeechAnalyzer for new code. ❌ `SFSpeechRecognizer` in new iOS 27 apps: the older API with server fallback and per-request limits.

Usage strings: `NSMicrophoneUsageDescription` (mic capture) and
`NSSpeechRecognitionUsageDescription` (keep it; it's harmless if unused).

## Live Dictation (iOS 27)

iOS 27 adds input providers that own capture **and** format conversion. You no longer write an
engine tap or an `AVAudioConverter`:

```swift
import SwiftUI
import Speech
import AVFoundation

enum DictationError: Error { case localeUnsupported, micDenied, noMicrophone }

@MainActor @Observable
final class Dictation {
    private(set) var finalText = AttributedString()
    private(set) var volatileText = AttributedString()
    private(set) var isRecording = false

    private var analyzer: SpeechAnalyzer?
    private var captureSession: AVCaptureSession?
    private var resultsTask: Task<Void, Never>?

    func start(locale: Locale = .current) async throws {
        guard await AVCaptureDevice.requestAccess(for: .audio) else { throw DictationError.micDenied }
        guard let supported = await SpeechTranscriber.supportedLocale(equivalentTo: locale) else {
            throw DictationError.localeUnsupported
        }
        let transcriber = SpeechTranscriber(locale: supported, preset: .progressiveTranscription)
        // Model download is on-demand and per-locale; no-op if already installed.
        if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
            try await request.downloadAndInstall()
        }
        guard let mic = AVCaptureDevice.default(for: .audio) else { throw DictationError.noMicrophone }

        // Creates and configures an AVCaptureSession (and the app's AVAudioSession on iOS).
        let provider = try await CaptureInputSequenceProvider.providerWithSession(
            from: mic, compatibleWith: [transcriber])
        let session = provider.captureSession
        captureSession = session

        resultsTask = Task { [weak self] in
            do {
                for try await result in transcriber.results {
                    guard let self else { return }
                    if result.isFinal {
                        self.finalText += result.text
                        self.volatileText = AttributedString()
                    } else {
                        self.volatileText = result.text      // show greyed; replaced when final
                    }
                }
            } catch {
                // Surface to UI in a real app
            }
        }

        let analyzer = SpeechAnalyzer(modules: [transcriber])
        self.analyzer = analyzer
        try await analyzer.start(inputSequence: provider.analyzerInputs)
        await Self.run(session)                      // startRunning blocks, so keep it off the main actor
        isRecording = true
    }

    func stop() async {
        if let captureSession { await Self.halt(captureSession) }
        try? await analyzer?.finalizeAndFinishThroughEndOfInput()
        resultsTask?.cancel()
        isRecording = false
    }

    @concurrent private static func run(_ session: sending AVCaptureSession) async { session.startRunning() }
    @concurrent private static func halt(_ session: sending AVCaptureSession) async { session.stopRunning() }
}
```

Display: `Text(dictation.finalText + dictation.volatileText)`, with the volatile part
styled lighter so users see words firm up.

- `providerWithSession` **configures the app's default `AVAudioSession`** on iOS. If you manage the
  audio session yourself (playback while recording, Bluetooth routing), build your own
  `AVCaptureSession` and call `provider(from:in:compatibleWith:)` instead.
- ❌ The iOS 26 pattern (`AVAudioEngine.inputNode.installTap` plus a hand-rolled `AVAudioConverter`).
  `installTap` is deprecated in iOS 27, its throwing replacement has no Swift overlay in Xcode 27.0, and
  mismatched formats fail silently (silence or garbage, not an error).

### Already have an audio graph?

Keep your `AVAudioEngine` (effects, metering, mixing) and let `AnalyzerInputConverter` handle
the format:

```swift
let converter = try await AnalyzerInputConverter.converter(compatibleWith: [transcriber])
// in your buffer callback:
for input in try converter.convert(buffer, at: nil) { continuation.yield(input) }
// on stop:
for input in try converter.flush() { continuation.yield(input) }
```

### Transcribing a file or a video's audio

```swift
func transcribe(_ url: URL, locale: Locale) async throws -> String {
    guard let supported = await SpeechTranscriber.supportedLocale(equivalentTo: locale) else {
        throw DictationError.localeUnsupported
    }
    let transcriber = SpeechTranscriber(locale: supported, preset: .transcription)
    let provider = try await AssetInputSequenceProvider.provider(from: AVURLAsset(url: url), compatibleWith: [transcriber])
    let analyzer = SpeechAnalyzer(modules: [transcriber])
    let collect = Task {
        var text = AttributedString()
        for try await result in transcriber.results where result.isFinal { text += result.text }
        return String(text.characters)
    }
    try await analyzer.start(inputSequence: provider.analyzerInputs)
    try await analyzer.finalizeAndFinishThroughEndOfInput()
    return try await collect.value
}
```

`AssetInputSequenceProvider` reads any `AVAsset`, including a video's audio track
(`provider(from:track:compatibleWith:)`), and converts it for you.

## Translation

### Zero-code: system overlay

```swift
import SwiftUI
import Translation

struct TranslateOverlayDemo: View {
    @State private var showTranslation = false
    let text: String
    var body: some View {
        Text(text)
            .toolbar { Button("Translate") { showTranslation = true } }
            .translationPresentation(isPresented: $showTranslation, text: text)
    }
}
```

### In-app: translate a list

```swift
struct TranslatedList: View {
    let source: [String]
    @State private var translated: [String] = []
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        List(translated.isEmpty ? source : translated, id: \.self) { Text($0) }
            .toolbar {
                Button("Spanish") {
                    configuration = .init(source: nil, target: Locale.Language(identifier: "es"))
                }
            }
            .translationTask(configuration) { session in
                // Batch responses can arrive out of order — key them by clientIdentifier.
                let requests = source.enumerated().map {
                    TranslationSession.Request(sourceText: $1, clientIdentifier: String($0))
                }
                do {
                    var out = source
                    for try await response in session.translate(batch: requests) {
                        if let id = response.clientIdentifier, let i = Int(id) { out[i] = response.targetText }
                    }
                    translated = out
                } catch {
                    // Languages not downloaded + user declined, or unsupported pair
                }
            }
    }
}
```

- Setting `configuration` triggers the task. To re-run with the same languages, call `configuration?.invalidate()`.
- If languages aren't installed, the system shows a download sheet. The session is tied to the view, so never store it.
- ❌ `try await session.translations(from: requests)` under default MainActor isolation → **error**: "sending 'session' risks causing data races". The streaming `translate(batch:)` form compiles clean in both modes and shows results progressively.

### Check before offering

```swift
func pairStatus(from: String, to: String) async -> LanguageAvailability.Status {
    await LanguageAvailability().status(
        from: Locale.Language(identifier: from),
        to: Locale.Language(identifier: to)
    )
}
// .installed → instant · .supported → needs download · .unsupported → hide the option
```

### No UI: installed languages only

```swift
func translateInstalled(_ text: String) async throws -> String {
    let session = TranslationSession(installedSource: Locale.Language(identifier: "en"),
                                     target: Locale.Language(identifier: "fr"))
    return try await session.translate(text).targetText
}
```

Throws if either language isn't installed, so it can't prompt. Use it for background work
after the user has already downloaded the pair once through the UI path.

## Pairing

- Voice note → `SpeechTranscriber` → summary with Foundation Models (`apple-intelligence/on-device-ai-kit`). Transcripts are long, so chunk them to the context window.
- Scanned text (`ios/camera-scanning`) → Translation for a menu/label translator.
- Both run with no network after model download. Test once in Airplane Mode.

## Checklist

- [ ] SpeechTranscriber → DictationTranscriber fallback; feature hidden when neither supports the locale
- [ ] `AssetInventory` download handled with progress/explanation on first use
- [ ] Mic via `CaptureInputSequenceProvider` (or `AnalyzerInputConverter` for an existing engine graph)
- [ ] Capture session stopped off the main actor and analyzer finalized on stop
- [ ] Translation via `translationTask`; batch keyed by `clientIdentifier`
- [ ] `LanguageAvailability` gates the language picker
- [ ] Verified offline (Airplane Mode) after models download

## References

- SpeechAnalyzer: https://developer.apple.com/documentation/speech/speechanalyzer
- Bringing advanced speech-to-text to your app (WWDC25): https://developer.apple.com/videos/play/wwdc2025/277/
- Translation framework: https://developer.apple.com/documentation/translation
- CaptureInputSequenceProvider: https://developer.apple.com/documentation/speech/captureinputsequenceprovider
- AnalyzerInputConverter: https://developer.apple.com/documentation/speech/analyzerinputconverter
- Local SDK truth: `Speech.swiftinterface`, `Translation.swiftinterface`
- Related: `apple-intelligence/on-device-ai-kit`, `ios/camera-scanning`, `apple-intelligence/foundation-models`
