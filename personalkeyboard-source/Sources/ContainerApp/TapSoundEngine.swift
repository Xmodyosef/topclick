import AudioToolbox
import UIKit

final class TapSoundEngine {
    static let shared = TapSoundEngine()

    private var enabled = true

    enum Sound: Int {
        case rowMid = 0, delete = 1, space = 2, emoji = 3, enter = 4, rowTop = 5, rowBot = 6
    }

    var isEnabled: Bool {
        get { enabled }
        set { enabled = newValue }
    }

    func setEnabled(_ enabled: Bool) {
        self.enabled = enabled
    }

    func play(_ sound: Sound, style: String = "system") {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func playKeyTap(for key: String, style: String = "system") {
        play(.rowMid, style: style)
    }
}
