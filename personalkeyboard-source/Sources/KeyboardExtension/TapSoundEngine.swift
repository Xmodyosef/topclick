import AVFoundation
import AudioToolbox
import UIKit

final class TapSoundEngine {
    static let shared = TapSoundEngine()
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let accessQueue = DispatchQueue(label: "Naqra.TapSound.queue")
    private var _isEnabled = true
    private var started = false

    var isEnabled: Bool {
        get { accessQueue.sync { _isEnabled } }
        set { accessQueue.sync { _isEnabled = newValue } }
    }

    enum Sound: Int { case rowMid = 0, delete = 1, space = 2, emoji = 3, enter = 4, rowTop = 5, rowBot = 6 }

    private let systemFrequencies: [Double] = [880, 440, 660, 1100, 550, 980, 720]
    private let customFrequencies: [String: [Double]] = [
        "creamy": [523.25, 493.88, 440.00, 392.00, 349.23, 587.33, 466.16],
        "thocky": [261.63, 246.94, 220.00, 196.00, 174.61, 293.66, 233.08],
        "soft": [659.25, 587.33, 523.25, 493.88, 440.00, 698.46, 554.37],
        "typewriter": [880, 740, 620, 500, 440, 920, 680]
    ]

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
    }

    private func setupAudio() -> Bool {
        if started { return true }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            try engine.start()
            started = true
            return true
        } catch {
            return false
        }
    }

    func setEnabled(_ enabled: Bool) { isEnabled = enabled }

    func play(_ sound: Sound, variation: Float = 0) {
        guard isEnabled else { return }
        let choice = ThemeIO.string("soundChoice") ?? "system"
        // Legacy "none" and unavailable custom modes fall back to the reliable system click.
        if choice == "none" { AudioServicesPlaySystemSound(1104); return }
        if choice == "system" {
            DispatchQueue.main.async { AudioServicesPlaySystemSound(1104) }
            return
        }
        guard setupAudio() else {
            DispatchQueue.main.async { AudioServicesPlaySystemSound(1104) }
            return
        }

        let frequencies = customFrequencies[choice] ?? systemFrequencies
        let index = min(max(sound.rawValue, 0), frequencies.count - 1)
        var frequency = Float(frequencies[index])
        if variation != 0 { frequency *= 1.0 + variation * 0.08 }
        playTone(frequency: frequency, duration: sound == .delete ? 0.06 : 0.045)
    }

    private func playTone(frequency: Float, duration: Double) {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate
        let length = Int(sampleRate * duration)
        guard length > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(length)),
              let channelData = buffer.floatChannelData else { return }
        buffer.frameLength = AVAudioFrameCount(length)
        let samples = channelData[0]
        for index in 0..<length {
            let time = Double(index) / sampleRate
            samples[index] = Float(sin(2.0 * .pi * Double(frequency) * time) * exp(-time * 45) * 0.12)
        }
        DispatchQueue.main.async {
            self.player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !self.player.isPlaying { self.player.play() }
        }
    }
}
