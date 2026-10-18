import AVFoundation
import AudioToolbox
import UIKit

final class TapSoundEngine {
    static let shared = TapSoundEngine()
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var format: AVAudioFormat!
    private var isEnabled = true
    private var started = false

    enum Sound: Int { case rowHigh = 0, rowMid, rowLow, delete, space, emoji, enter }

    private let frequencies: [Double] = [880, 740, 620, 220, 520, 980, 660]
    private let customFrequencies: [String: [Double]] = [
        "creamy": [523.25, 493.88, 440.00, 392.00],
        "thocky": [261.63, 246.94, 220.00, 196.00],
        "soft": [659.25, 587.33, 523.25, 493.88],
        "typewriter": [880, 740, 620, 500]
    ]

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
    }

    func setEnabled(_ enabled: Bool) { isEnabled = enabled }

    private func setupAudio() -> Bool {
        guard !started else { return true }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            try engine.start()
            started = true
            return true
        } catch {
            return false
        }
    }

    func play(_ sound: Sound = .rowMid) {
        guard isEnabled, ThemeStore.bool("sounds") ?? true else { return }
        let choice = ThemeStore.string("soundChoice") ?? "system"
        // Legacy "none" and unavailable custom modes fall back to the reliable system click.
        if choice == "none" { AudioServicesPlaySystemSound(1104); return }
        if choice == "system" {
            AudioServicesPlaySystemSound(0x450)
            return
        }
        guard setupAudio() else { AudioServicesPlaySystemSound(1104); return }

        let samples = customFrequencies[choice] ?? frequencies
        let index = min(max(sound.rawValue, 0), samples.count - 1)
        let frequency = samples[index]
        let duration: Double = sound == .delete ? 0.06 : 0.08
        let length = Int(format.sampleRate * duration)
        guard length > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(length)),
              let channelData = buffer.floatChannelData else { return }
        buffer.frameLength = AVAudioFrameCount(length)
        let samplesBuffer = channelData[0]
        for index in 0..<length {
            let time = Double(index) / format.sampleRate
            samplesBuffer[index] = Float(sin(2.0 * .pi * frequency * time) * exp(-time * 30) * 0.12)
        }
        DispatchQueue.main.async {
            self.playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !self.playerNode.isPlaying { self.playerNode.play() }
        }
    }
}
