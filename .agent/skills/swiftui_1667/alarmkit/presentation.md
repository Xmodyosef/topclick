# Alarm Presentation

What the system shows for each alarm state, the buttons, tint, and metadata. Snippets compile against
the iOS 27 SDK; `TimerMetadata` is the type defined in scheduling.md.

## Structure

```
AlarmAttributes<Metadata>          → passed to AlarmConfiguration
├── presentation: AlarmPresentation
│   ├── alert:     AlarmPresentation.Alert       (required — the alarm is firing)
│   ├── countdown: AlarmPresentation.Countdown?  (timers / snooze counting down)
│   └── paused:    AlarmPresentation.Paused?     (user paused a countdown)
├── metadata:  Metadata?            (your data for the Live Activity)
└── tintColor: Color                (required, not optional)
```

## Buttons

There are no factory buttons. Every button is an `AlarmButton` with text, color, and an SF Symbol:

```swift
AlarmButton(text: "Snooze", textColor: .white, systemImageName: "zzz")
```

❌ `AlarmButton(label:)`, `.snoozeButton()`, `.repeatButton()`, `.openAppButton()` — none exist.

## Alert

```swift
// Plain alert — the system provides the stop control
AlarmPresentation.Alert(title: "Wake Up")

// With a secondary button
AlarmPresentation.Alert(
    title: "Morning Alarm",
    secondaryButton: AlarmButton(text: "Snooze", textColor: .white, systemImageName: "zzz"),
    secondaryButtonBehavior: .countdown
)
```

`secondaryButtonBehavior`:

| Behavior | What the secondary button does | Needs |
|---|---|---|
| `.countdown` | Starts a countdown, then alerts again (snooze, "repeat timer") | `countdownDuration.postAlert` in the configuration |
| `.custom` | Runs your `secondaryIntent` (e.g. open the app to a screen) | `secondaryIntent:` (a `LiveActivityIntent`) in the configuration |

❌ `stopButton:` — deprecated since iOS 26.1 and ignored. Code that still passes it compiles with a
deprecation warning; remove it.

## Countdown and Paused

```swift
let presentation = AlarmPresentation(
    alert: .init(title: "Time's Up"),
    countdown: .init(
        title: "Cooking",
        pauseButton: AlarmButton(text: "Pause", textColor: .orange, systemImageName: "pause.fill")
    ),
    paused: .init(
        title: "Paused",
        resumeButton: AlarmButton(text: "Resume", textColor: .orange, systemImageName: "play.fill")
    )
)
```

The remaining time is drawn by your widget extension from `context.state` (see live-activities.md),
not configured here. `pauseButton` is optional; `resumeButton` is required on `Paused`.

## Attributes: tint and metadata

```swift
let attributes = AlarmAttributes<TimerMetadata>(
    presentation: presentation,
    metadata: TimerMetadata(label: "Pasta", iconName: "fork.knife"),
    tintColor: .orange
)
```

✅ One `AlarmAttributes` value goes into the configuration (`.timer(duration:attributes:)`,
`.alarm(schedule:attributes:)`, or `AlarmConfiguration(…, attributes:)`).
❌ `AlarmAttributes(tintColor:)` alone — `presentation` and `tintColor` are both required initializer arguments.

## Anti-patterns

- **Countdown presentation without a widget extension.** Countdown and paused states render through a Live
  Activity; without `ActivityConfiguration(for: AlarmAttributes<YourMetadata>.self)` they don't appear on
  the Lock Screen or Dynamic Island. See live-activities.md.
- **`.countdown` secondary behavior with no `postAlert`.** The button has nothing to count down.
- **Mismatched metadata types.** The app schedules `AlarmAttributes<TimerMetadata>`; the widget must
  configure the exact same generic type, or the activity never matches.
