import AudioToolbox
import UIKit

final class TapSoundEngine {
    static let shared = TapSoundEngine()
    private let accessQueue = DispatchQueue(label: "Naqra.TapSound.queue")
    private var _isEnabled = true
    /// Pack id → system sound created once at load (soft / thocky / creamy).
    private var packSounds: [String: SystemSoundID] = [:]

    var isEnabled: Bool {
        get { accessQueue.sync { _isEnabled } }
        set { accessQueue.sync { _isEnabled = newValue } }
    }

    enum Sound: Int { case rowMid = 0, delete = 1, space = 2, emoji = 3, enter = 4, rowTop = 5, rowBot = 6 }

    private init() {
        loadPackSounds()
    }

    private func loadPackSounds() {
        for name in ["soft", "thocky", "creamy"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "caf") else { continue }
            var soundID: SystemSoundID = 0
            let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
            if status == kAudioServicesNoError {
                packSounds[name] = soundID
            }
        }
    }

    func setEnabled(_ enabled: Bool) { isEnabled = enabled }

    func play(_ sound: Sound, variation: Float = 0) {
        guard isEnabled, ThemeIO.bool("sounds") != false else { return }
        let choice = ThemeIO.string("soundChoice") ?? "system"
        if choice == "none" { return }
        if let id = packSounds[choice] {
            AudioServicesPlaySystemSound(id)
            return
        }
        AudioServicesPlaySystemSound(1104)
    }
}
