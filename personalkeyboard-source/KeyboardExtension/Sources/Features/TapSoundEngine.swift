import AVFoundation
import UIKit

/// Plays cached, bundled click samples. Audio work is isolated from the keyboard's
/// main thread so a slow audio session can never delay text insertion.
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

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let audioQueue = DispatchQueue(label: "Naqra.TapSound.queue", qos: .userInitiated)
    private let maximumPendingSamples = 4

    // Accessed only on audioQueue.
    private var enabled = true
    private var pendingSamples = 0
    private var cachedSamples: [String: AVAudioPCMBuffer] = [:]
    private var unavailableSamples = Set<String>()

    /// The repository currently ships three CAF packs. Typewriter remains a
    /// first-class selectable profile and uses the percussive thocky sample;
    /// it must never fall through to the system click because its CAF is absent.
    private static let sampleAssets: [String: String] = [
        "creamy": "creamy",
        "thocky": "thocky",
        "soft": "soft",
        "typewriter": "thocky",
        "piano": "piano"
    ]

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
    }

    func setEnabled(_ value: Bool) {
        audioQueue.async { [weak self] in
            self?.enabled = value
        }
    }

    func play(_ sound: Sound, variation: Float = 0) {
        // Keep the existing call signature for keyboard callers. CAF playback
        // uses the recorded transient rather than synthesizing a new tone.
        _ = sound
        _ = variation

        audioQueue.async { [weak self] in
            guard let self, self.enabled, ThemeIO.bool("sounds") != false else { return }

            let choice = ThemeIO.string("soundChoice") ?? "system"
            if choice == "none" { return }

            guard let assetName = Self.sampleAssets[choice] else {
                self.playSystemClick()
                return
            }

            guard let sample = self.loadSample(named: assetName) else {
                self.playSystemClick()
                return
            }

            // Never let a fast typist build an unbounded audio backlog. Dropping
            // an excess click is preferable to delaying or affecting text input.
            guard self.pendingSamples < self.maximumPendingSamples else { return }
            guard self.startAudioIfNeeded() else {
                self.playSystemClick()
                return
            }

            self.pendingSamples += 1
            self.player.scheduleBuffer(sample, at: nil, options: []) { [weak self] in
                guard let self else { return }
                self.audioQueue.async {
                    self.pendingSamples = max(0, self.pendingSamples - 1)
                }
            }
            if !self.player.isPlaying {
                self.player.play()
            }
        }
    }

    private func loadSample(named assetName: String) -> AVAudioPCMBuffer? {
        if let cached = cachedSamples[assetName] { return cached }
        guard !unavailableSamples.contains(assetName) else { return nil }

        guard let url = Bundle.main.url(forResource: assetName, withExtension: "caf"),
              let file = try? AVAudioFile(forReading: url),
              file.length > 0,
              file.length <= Int64(UInt32.max) else {
            unavailableSamples.insert(assetName)
            return nil
        }

        let capacity = AVAudioFrameCount(file.length)
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: file.processingFormat,
            frameCapacity: capacity
        ),
        (try? file.read(into: buffer)) != nil,
        buffer.frameLength > 0 else {
            unavailableSamples.insert(assetName)
            return nil
        }

        cachedSamples[assetName] = buffer
        return buffer
    }

    private func startAudioIfNeeded() -> Bool {
        if engine.isRunning {
            if !player.isPlaying { player.play() }
            return true
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            try engine.start()
            player.play()
            return true
        } catch {
            engine.stop()
            return false
        }
    }

    private func playSystemClick() {
        DispatchQueue.main.async {
            UIDevice.current.playInputClick()
        }
    }
}
