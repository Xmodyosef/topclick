# Live Activities Integration

Countdown and paused states appear on the Lock Screen and Dynamic Island through a Live Activity that
your **widget extension** draws. Alerts work without one; countdowns don't. Snippets compile against the
iOS 27 SDK.

## Setup

1. Add a Widget Extension target (XcodeGen: `type: app-extension` with
   `NSExtensionPointIdentifier: com.apple.widgetkit-extension`; see `ios/project-bootstrap`).
2. Put your `AlarmMetadata` type in a file that **both** the app and the extension compile.
3. Add an `ActivityConfiguration` for `AlarmAttributes<YourMetadata>`.

## The widget

```swift
import WidgetKit
import SwiftUI
import AlarmKit

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<TimerMetadata>.self) { context in
            TimerLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.metadata?.label ?? "Timer")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    TimerStateView(state: context.state)
                }
            } compactLeading: {
                Image(systemName: context.attributes.metadata?.iconName ?? "timer")
            } compactTrailing: {
                TimerStateView(state: context.state)
            } minimal: {
                Image(systemName: "timer")
            }
        }
    }
}
```

Register it in the extension's `WidgetBundle` (`@main struct MyWidgets: WidgetBundle { … TimerLiveActivity() }`).

❌ `ActivityConfiguration(for: AlarmAttributes.self)` — `AlarmAttributes` is generic; name the metadata type.
❌ Declaring your own `struct AlarmAttributes: ActivityAttributes` — AlarmKit provides it.

## Reading state

`context.attributes` is what you scheduled (presentation, metadata, `tintColor`). `context.state` is an
`AlarmPresentationState` whose `mode` says what to draw right now:

```swift
struct TimerStateView: View {
    let state: AlarmPresentationState

    var body: some View {
        switch state.mode {
        case .countdown(let countdown):
            Text(timerInterval: Date.now...countdown.fireDate, countsDown: true)
                .monospacedDigit()
        case .paused(let paused):
            let remaining = paused.totalCountdownDuration - paused.previouslyElapsedDuration
            Text(Duration.seconds(remaining), format: .time(pattern: .minuteSecond))
        case .alert:
            Text("Done")
        @unknown default:
            EmptyView()
        }
    }
}
```

✅ `Text(timerInterval:countsDown:)` updates every second without your process running.
❌ Computing remaining time in a `Timer` or `TimelineView` inside the widget — the extension isn't running between updates.

## Lock Screen view

```swift
struct TimerLockScreenView: View {
    let context: ActivityViewContext<AlarmAttributes<TimerMetadata>>

    var body: some View {
        HStack {
            Image(systemName: context.attributes.metadata?.iconName ?? "timer")
                .foregroundStyle(context.attributes.tintColor)
            Text(context.attributes.metadata?.label ?? "Timer")
                .font(.headline)
            Spacer()
            TimerStateView(state: context.state)
        }
        .padding()
    }
}
```

`tintColor` is non-optional. ❌ `context.attributes.tintColor ?? .primary` doesn't compile.

Titles you configured live under the presentation: `context.attributes.presentation.alert.title`,
`.countdown?.title`, `.paused?.title` (all `LocalizedStringResource`; `Text` accepts them directly).

## Checklist

- [ ] Widget extension target exists and includes the shared metadata file
- [ ] `ActivityConfiguration(for: AlarmAttributes<YourMetadata>.self)` with the same type the app schedules
- [ ] Registered in the `WidgetBundle`
- [ ] `context.state.mode` handled for countdown, paused, alert
- [ ] Countdown text uses `Text(timerInterval:countsDown:)`
- [ ] Tested on a device (Live Activities and alarms behave differently in the Simulator)
