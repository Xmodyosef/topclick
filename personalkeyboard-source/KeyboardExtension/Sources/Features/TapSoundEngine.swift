import AudioToolbox
import UIKit

/// Plays short bundled keyboard clicks without reading preferences on every key press.
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
    private let configurationLock = NSLock()
    private let pendingLock = NSLock()
    private let maximumPendingPlayRequests = 4

    // Updated only when settings change; the key-tap path performs no preferences I/O.
    private var soundsEnabled = false
    private var selectedChoice = "system"

    // Accessed only on audioQueue.
    private var cachedSoundIDs: [String: SystemSoundID] = [:]
    private var unavailableSamples = Set<String>()
    private var pendingPlayRequests = 0

    private static let sampleAssets: [String: String] = [
        "creamy": "creamy",
        "thocky": "thocky",
        "soft": "soft",
        "typewriter": "typewriter",
        "piano": "piano"
    ]

    private init() {}

    deinit {
        cachedSoundIDs.values.forEach { AudioServicesDisposeSystemSoundID($0) }
    }

    func configure(enabled: Bool, choice: String) {
        configurationLock.lock()
        selectedChoice = Self.sampleAssets[choice] != nil || choice == "system" || choice == "none"
            ? choice
            : "system"
        soundsEnabled = enabled && selectedChoice != "none"
        configurationLock.unlock()
    }

    func play(_ sound: Sound, variation: Float = 0) {
        _ = sound
        _ = variation

        configurationLock.lock()
        let shouldPlay = soundsEnabled
        let choice = selectedChoice
        configurationLock.unlock()

        guard shouldPlay, choice != "none", reservePlayRequest() else { return }

        audioQueue.async { [weak self] in
            guard let self else { return }
            defer { self.releasePlayRequest() }

            if choice == "system" {
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
            NSLog("[Naqra.Audio] missing sound resource: %@.caf", assetName)
            return nil
        }

        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        guard status == kAudioServicesNoError, soundID != 0 else {
            unavailableSamples.insert(assetName)
            NSLog("[Naqra.Audio] AudioServicesCreateSystemSoundID failed for %@.caf status=%d", assetName, status)
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
