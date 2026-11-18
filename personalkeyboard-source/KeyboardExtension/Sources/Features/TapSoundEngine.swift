import AudioToolbox
import UIKit

/// Plays short bundled keyboard clicks through AudioServices.
/// Uses cached AudioServices identifiers without creating an audio-session graph.
final class TapSoundEngine {
    static let shared = TapSoundEngine()

    enum Sound: Int {
        case rowMid = 0
        case delete = 1
        case space = 2
        case emoji = 3
        case enter = 4
        case rowTop = 5
        case rowBot = 6
    }

    private let audioQueue = DispatchQueue(label: "Naqra.TapSound.queue", qos: .userInitiated)
    private let pendingLock = NSLock()
    private let maximumPendingPlayRequests = 4

    // Accessed only on audioQueue.
    private var enabled = true
    private var cachedSoundIDs: [String: SystemSoundID] = [:]
    private var unavailableSamples = Set<String>()

    // The repository ships these three CAF files. Typewriter intentionally reuses
    // the existing thocky sample until a dedicated typewriter asset is added.
    private static let sampleAssets: [String: String] = [
        "creamy": "creamy",
        "thocky": "thocky",
        "soft": "soft",
        "typewriter": "typewriter",
        "piano": "piano"
    ]

    // Counts work submitted to the serial queue, not audio currently playing.
    // This prevents rapid typing from creating an unbounded DispatchQueue backlog.
    private var pendingPlayRequests = 0

    private init() {}

    deinit {
        cachedSoundIDs.values.forEach { AudioServicesDisposeSystemSoundID($0) }
    }

    func setEnabled(_ value: Bool) {
        audioQueue.async { [weak self] in
            self?.enabled = value
        }
    }

    func play(_ sound: Sound, variation: Float = 0) {
        // Preserve the existing call surface for keyboard input handlers.
        _ = sound
        _ = variation

        guard reservePlayRequest() else { return }

        audioQueue.async { [weak self] in
            guard let self else { return }
            defer { self.releasePlayRequest() }

            guard self.enabled, ThemeIO.bool("sounds") != false else { return }

            let choice = ThemeIO.string("soundChoice") ?? "system"
            if choice == "none" { return }

            guard choice != "system" else {
                self.playSystemClick()
                return
            }

            guard let soundID = self.soundID(for: choice) else {
                self.playSystemClick()
                return
            }

            AudioServicesPlaySystemSound(soundID)
        }
    }

    private func reservePlayRequest() -> Bool {
        pendingLock.lock()
        defer { pendingLock.unlock() }

        guard pendingPlayRequests < maximumPendingPlayRequests else { return false }
        pendingPlayRequests += 1
        return true
    }

    private func releasePlayRequest() {
        pendingLock.lock()
        pendingPlayRequests = max(0, pendingPlayRequests - 1)
        pendingLock.unlock()
    }

    private func soundID(for choice: String) -> SystemSoundID? {
        guard let assetName = Self.sampleAssets[choice] else { return nil }
        if let cached = cachedSoundIDs[assetName] { return cached }
        guard !unavailableSamples.contains(assetName),
              let url = Bundle.main.url(forResource: assetName, withExtension: "caf") else {
            unavailableSamples.insert(assetName)
            return nil
        }

        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        guard status == kAudioServicesNoError, soundID != 0 else {
            unavailableSamples.insert(assetName)
            return nil
        }

        cachedSoundIDs[assetName] = soundID
        return soundID
    }

    private func playSystemClick() {
        DispatchQueue.main.async {
            UIDevice.current.playInputClick()
        }
    }
}
