import SwiftUI
import Translation
import UIKit
import AudioToolbox

enum AppIconSwitcher {
    static let eveningIconName = "AppIconEvening"
    static let morningStartHour = 6
    static let morningEndHour = 18

    static var isMorningNow: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= morningStartHour && hour < morningEndHour
    }

    static func applyAutomaticIfNeeded() {
        guard (ThemeStore.string("iconMode") ?? "auto") == "auto" else { return }
        setIcon(isMorningNow ? nil : eveningIconName)
    }

    static func apply(mode: String) {
        ThemeStore.write("iconMode", value: mode)
        switch mode {
        case "morning": setIcon(nil)
        case "evening": setIcon(eveningIconName)
        default: applyAutomaticIfNeeded()
        }
    }

    private static func setIcon(_ name: String?) {
        guard UIApplication.shared.supportsAlternateIcons,
              UIApplication.shared.alternateIconName != name else { return }
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error { print("Naqra icon change failed: \(error.localizedDescription)") }
        }
    }
}

