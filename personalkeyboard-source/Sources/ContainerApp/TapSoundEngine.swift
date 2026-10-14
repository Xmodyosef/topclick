import AVFoundation
import AudioToolbox

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

    private func setupAudio() {
        guard !started else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true, options: [])
            try engine.start()
            started = true
        } catch { print("[TapSoundEngine] \(error)") }
    }

    func play(_ sound: Sound = .rowMid) {
        guard isEnabled else { return }
        let choice = ThemeStore.string("soundChoice") ?? "system"
        if choice == "none" { return }
        if choice == "system" {
            AudioServicesPlaySystemSound(0x450)
            return
        }
        setupAudio()
        let sampleRate = format.sampleRate
        let duration: Double = sound == .delete ? 0.08 : 0.12
        let length = Int(sampleRate * duration)
        let idx = min(max(sound.rawValue, 0), frequencies.count - 1)
        let frequency = frequencies[idx]
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(length)) else { return }
        buffer.frameLength = AVAudioFrameCount(length)
        let channelData = buffer.floatChannelData![0]
        for i in 0..<length {
            let t = Double(i) / sampleRate
            let envelope = exp(-t * 25)
            let sample = sin(2.0 * .pi * frequency * t) * envelope * 0.15
            channelData[i] = Float(sample)
        }
        DispatchQueue.main.async {
            self.playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
            if !self.playerNode.isPlaying { self.playerNode.play() }
        }
    }
}
