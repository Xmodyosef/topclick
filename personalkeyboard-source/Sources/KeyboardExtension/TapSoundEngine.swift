import AVFoundation

final class TapSoundEngine {
    static let shared = TapSoundEngine()
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var isEnabled = true
    private var audioReady = false

    enum Sound { case rowMid, delete, space, emoji, enter }

    private let customFrequencies: [Sound: [Float]] = [
        .rowMid: [800, 850, 900],
        .delete: [400, 350, 300],
        .space: [600, 650, 700],
        .emoji: [1000, 1100, 1200],
        .enter: [500, 550, 450]
    ]

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        audioReady = setupAudio()
    }

    private func setupAudio() -> Bool {
        do {
            try engine.start()
            return true
        } catch {
            return false
        }
    }

    func setEnabled(_ v: Bool) { isEnabled = v }

    func play(_ s: Sound) {
        guard isEnabled, audioReady else { return }
        let freqs = customFrequencies[s] ?? [800]
        let freq = freqs.randomElement() ?? 800
        playTone(freq: freq)
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
