import SwiftUI

@main
struct KeyboardPrototypeApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.layoutDirection, .leftToRight)
                .onAppear { AppIconSwitcher.applyAutomaticIfNeeded() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { AppIconSwitcher.applyAutomaticIfNeeded() }
        }
    }
}
