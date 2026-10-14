import AVFoundation

final class TapSoundEngine {
    static let shared = TapSoundEngine()
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let accessQueue = DispatchQueue(label: "TapSound.queue")
    private var _isEnabled = true
    private var started = false

    var isEnabled: Bool {
        get { accessQueue.sync { _isEnabled } }
        set { accessQueue.sync { _isEnabled = newValue } }
    }

    enum Sound: Int { case rowMid = 0, delete = 1, space = 2, emoji = 3, enter = 4 }

    private let frequencies: [Double] = [800, 400, 600, 1000, 500]
    private let customFrequencies: [String: [Double]] = [
        "creamy": [523.25, 493.88, 440.00, 392.00, 349.23, 329.63, 293.66],
        "thocky": [261.63, 246.94, 220.00, 196.00, 174.61, 164.81, 146.83],
        "soft": [659.25, 587.33, 523.25, 493.88, 440.00, 392.00, 349.23],
        "typewriter": [880, 740, 620, 500, 440, 380, 320]
    ]

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
    }

    private func setupAudio() -> Bool {
        if started { return true }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true, options: [])
            try engine.start()
            started = true
            return true
        } catch { return false }
    }

    func setEnabled(_ v: Bool) { isEnabled = v }

    func play(_ s: Sound) {
        guard isEnabled else { return }
        guard setupAudio() else {
            UIDevice.current.playInputClick()
            return
        }
        let choice = UserDefaults(suiteName: "group.app.personal.PersonalKeyboard")?.string(forKey: "soundChoice") ?? "system"
        let freqs = (choice == "system" || choice == "none") ? frequencies : (customFrequencies[choice] ?? frequencies)
        let idx = min(max(s.rawValue, 0), freqs.count - 1)
        let frequency = freqs[idx]
        playTone(freq: Float(frequency))
    }

    private func playTone(freq: Float) {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        let sampleRate = format.sampleRate
        let duration: Double = 0.05
        let length = Int(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(length)) else { return }
        buffer.frameLength = AVAudioFrameCount(length)
        let data = buffer.floatChannelData![0]
        for i in 0..<length {
            let t = Double(i) / sampleRate
            data[i] = Float(sin(2.0 * .pi * Double(freq) * t) * exp(-t * 40) * 0.1)
        }
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying { player.play() }
    }
}
