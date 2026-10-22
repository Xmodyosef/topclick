import SwiftUI
import Translation
import UIKit
import AudioToolbox

// MARK: - Main navigation

struct ContentView: View {
    var body: some View {
        TabView {
            KeyboardPreviewTab()
                .tabItem { Label("معاينة", systemImage: "keyboard") }
            ThemesTab()
                .tabItem { Label("الثيمات", systemImage: "paintpalette.fill") }
            SettingsTab()
                .tabItem { Label("الإعدادات", systemImage: "slider.horizontal.3") }
        }
        .tint(NaqraColors.accent)
        .preferredColorScheme(.dark)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

