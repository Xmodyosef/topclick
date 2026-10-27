---
name: alarmkit
description: AlarmKit integration for scheduling alarms and timers with custom UI, Live Activities, and snooze support. Use when implementing alarm or timer features in iOS 26+ apps.
allowed-tools: [Read, Write, Edit, Glob, Grep]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# AlarmKit

Framework for scheduling alarms and countdown timers with custom UI, Live Activities integration, and focus/silent mode override. Prevents the most common mistakes: inventing a result-builder scheduling API, convenience buttons that don't exist, the deprecated `stopButton`, the wrong authorization property, and a missing widget extension for countdowns. All code here compiles against the iOS 27 SDK.

## When This Skill Activates

Use this skill when the user:
- Asks to add, fix, or review **alarm** or **timer** functionality
- Mentions **AlarmKit**, **AlarmManager**, or **AlarmPresentation**
- Wants to schedule **one-time**, **repeating**, or **countdown** alarms
- Asks about **snooze**, **stop**, or **repeat** buttons on alarm alerts
- Wants alarms to appear on **Dynamic Island** or **Lock Screen** (Live Activities)
- Mentions overriding **Focus** or **silent mode** for alarms
- Asks about **AlarmAttributes** or **AlarmMetadata**

## Decision Tree

```
What do you need?
|
+-- Schedule an alarm or timer          --> scheduling.md
|   +-- One moment:            .alarm(schedule: .fixed(date), attributes:)
|   +-- Daily/weekly time:     .alarm(schedule: .relative(.init(time:, repeats: .weekly([...]))), attributes:)
|   +-- Countdown timer:       .timer(duration:, attributes:)          (no schedule)
|   +-- Snooze / repeat:       AlarmConfiguration(countdownDuration: .init(preAlert:, postAlert:), ...)
|   +-- Authorization, managing (pause/resume/cancel), observing alarmUpdates
|
+-- Customize what the system shows     --> presentation.md
|   +-- AlarmPresentation(alert:countdown:paused:), AlarmButton(text:textColor:systemImageName:)
|   +-- secondaryButtonBehavior: .countdown (snooze) vs .custom (your intent)
|   +-- AlarmAttributes<Metadata>(presentation:metadata:tintColor:)
|
+-- Lock Screen / Dynamic Island        --> live-activities.md
    +-- ActivityConfiguration(for: AlarmAttributes<YourMetadata>.self)
    +-- Draw context.state.mode (.countdown / .paused / .alert)
```

## The API in one block

```swift
let attributes = AlarmAttributes<TimerMetadata>(            // TimerMetadata: AlarmMetadata (required, even if unused)
    presentation: AlarmPresentation(alert: .init(title: "Time's Up")),
    tintColor: .orange
)
let alarm = try await AlarmManager.shared.schedule(
    id: UUID(),
    configuration: .timer(duration: 10 * 60, attributes: attributes)
)
try AlarmManager.shared.cancel(id: alarm.id)                // management calls are sync + throwing
```

## API Availability

| API | Minimum | Notes |
|---|---|---|
| `AlarmManager`, `Alarm`, `AlarmPresentation`, `AlarmAttributes`, `AlarmButton`, `AlarmMetadata` | iOS 26 | |
| `AlarmPresentation.Alert(title:stopButton:…)` | deprecated iOS 26.1 | `stopButton` ignored; system provides stop |
| `AlarmConfiguration(…, appEntityIdentifier:)`, `.alarm/.timer(…, appEntityIdentifier:)` | iOS 27 | Link an alarm to an App Intents entity |

## Top Mistakes

| # | ❌ Mistake | ✅ Fix |
|---|---|---|
| 1 | `schedule(id:) { … }` result-builder style | `schedule(id:configuration:)` with an `AlarmConfiguration` value |
| 2 | `AlarmButton(label:)`, `.snoozeButton()`, `.repeatButton()` | `AlarmButton(text:textColor:systemImageName:)`; snooze = secondary button + `.countdown` + `postAlert` |
| 3 | `authorizationStatus`; `requestAuthorization()` without `try` | `authorizationState`; `try await requestAuthorization()` |
| 4 | Passing `stopButton:` | Removed in practice (deprecated 26.1); omit it |
| 5 | `AlarmAttributes` used without a metadata type | `AlarmAttributes<YourMetadata>` everywhere, same type in app and widget |
| 6 | Countdown without a widget extension | `ActivityConfiguration(for: AlarmAttributes<YourMetadata>.self)` |
| 7 | `try await pause(id:)` | `try AlarmManager.shared.pause(id:)` (synchronous) |
| 8 | Missing `NSAlarmKitUsageDescription` | Add it to Info.plist before requesting authorization |

## Reference Files

| File | Content |
|------|---------|
| [scheduling.md](scheduling.md) | Authorization, one-time/repeating/timer creation, managing alarms, observing updates |
| [presentation.md](presentation.md) | Alert, countdown, paused UI customization, buttons, tint color |
| [live-activities.md](live-activities.md) | Widget extension, AlarmAttributes, AlarmMetadata, Dynamic Island |

## References

- AlarmKit: https://developer.apple.com/documentation/alarmkit
- Local SDK truth: `AlarmKit.swiftinterface` in the iOS 27 SDK
- Related: `generators/live-activity-generator`, `generators/widget-generator`, `apple-intelligence/app-intents`
