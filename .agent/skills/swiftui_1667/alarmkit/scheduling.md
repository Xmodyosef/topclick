# Scheduling Alarms and Timers

Authorization, one-time / repeating alarms, countdown timers, managing the lifecycle, and
observing state. Every snippet compiles against the iOS 27 SDK (Swift 6 and default-MainActor modes).

## The shape of the API

There is one entry point, and it takes a value, not a closure:

```swift
AlarmManager.shared.schedule(id: Alarm.ID, configuration: AlarmManager.AlarmConfiguration<Metadata>) async throws -> Alarm
```

A configuration bundles **what to show** (`AlarmAttributes`: presentation + metadata + tint),
**when** (`Alarm.Schedule`, alarms only), and **how long** (`Alarm.CountdownDuration`, timers and snooze).

❌ `AlarmManager.shared.schedule(id: id) { Alarm.Schedule… AlarmPresentation.Alert… }` — there is no
result-builder form; this doesn't compile.

## Metadata type (required)

`AlarmAttributes` is generic over your `AlarmMetadata` type, and every configuration needs a concrete
one, even if you never set a value. The widget extension uses the same type.

```swift
import AlarmKit

struct TimerMetadata: AlarmMetadata {
    var label: String
    var iconName: String
}
```

## Authorization

Add `NSAlarmKitUsageDescription` to Info.plist, then:

```swift
func requestAlarmAccess() async -> Bool {
    switch AlarmManager.shared.authorizationState {
    case .authorized:
        return true
    case .denied:
        return false
    case .notDetermined:
        do {
            return try await AlarmManager.shared.requestAuthorization() == .authorized
        } catch {
            return false
        }
    @unknown default:
        return false
    }
}
```

✅ `authorizationState` and `requestAuthorization()` (**async throws**).
❌ `authorizationStatus` — doesn't exist. ❌ `await AlarmManager.shared.requestAuthorization()` without `try`.

Observe changes (Settings toggles) with `for await state in AlarmManager.shared.authorizationUpdates { … }`.

## One-time alarm

```swift
func scheduleOneTime(at date: Date) async throws -> Alarm {
    let attributes = AlarmAttributes<TimerMetadata>(
        presentation: AlarmPresentation(alert: .init(title: "Wake Up")),
        tintColor: .orange
    )
    return try await AlarmManager.shared.schedule(
        id: UUID(),
        configuration: .alarm(schedule: .fixed(date), attributes: attributes)
    )
}
```

`Alarm.Schedule` has two cases: `.fixed(Date)` (one moment, time-zone fixed) and
`.relative(Relative)` (a wall-clock time, optionally repeating; follows the user's time zone).

## Repeating alarm with snooze

```swift
func scheduleWeekdays() async throws -> Alarm {
    let schedule = Alarm.Schedule.relative(.init(
        time: .init(hour: 7, minute: 0),
        repeats: .weekly([.monday, .tuesday, .wednesday, .thursday, .friday])
    ))
    let alert = AlarmPresentation.Alert(
        title: "Time for Work",
        secondaryButton: AlarmButton(text: "Snooze", textColor: .white, systemImageName: "zzz"),
        secondaryButtonBehavior: .countdown          // snooze = count down postAlert, then alert again
    )
    let attributes = AlarmAttributes<TimerMetadata>(
        presentation: AlarmPresentation(alert: alert),
        metadata: TimerMetadata(label: "Work", iconName: "briefcase"),
        tintColor: .blue
    )
    let configuration = AlarmManager.AlarmConfiguration(
        countdownDuration: .init(preAlert: nil, postAlert: 9 * 60),   // 9-minute snooze
        schedule: schedule,
        attributes: attributes
    )
    return try await AlarmManager.shared.schedule(id: UUID(), configuration: configuration)
}
```

Snooze is not a built-in button. It is a secondary `AlarmButton` with `secondaryButtonBehavior: .countdown`
plus a `postAlert` duration. Without `postAlert`, the countdown has nothing to count.

## Countdown timer

```swift
func startTimer(minutes: Int) async throws -> Alarm {
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
    let attributes = AlarmAttributes<TimerMetadata>(
        presentation: presentation,
        metadata: TimerMetadata(label: "Pasta", iconName: "fork.knife"),
        tintColor: .orange
    )
    return try await AlarmManager.shared.schedule(
        id: UUID(),
        configuration: .timer(duration: TimeInterval(minutes * 60), attributes: attributes)
    )
}
```

✅ Timers: `.timer(duration:attributes:)`, no schedule.
❌ Passing a `schedule` to a timer. For a timer whose alert offers "Repeat", use the full
`AlarmConfiguration(countdownDuration: .init(preAlert: d, postAlert: d), attributes:)` initializer so the
secondary `.countdown` button has a `postAlert` to run.

## Managing alarms

`pause`, `resume`, `cancel`, `stop`, and `countdown` are **synchronous** and throwing:

```swift
func manage(_ id: Alarm.ID) {
    do {
        try AlarmManager.shared.pause(id: id)
        try AlarmManager.shared.resume(id: id)
        try AlarmManager.shared.cancel(id: id)
    } catch AlarmManager.AlarmError.maximumLimitReached {
        // too many alarms scheduled
    } catch {
        // other failures
    }
}
```

❌ `try await AlarmManager.shared.pause(id:)` — not async (the `await` produces a warning and signals a misunderstanding).

`AlarmManager.shared.alarms` returns the current list. `Alarm.state` is `.scheduled`, `.countdown`, `.paused`, or `.alerting`.

## Observing updates

```swift
@MainActor @Observable
final class AlarmViewModel {
    private(set) var alarms: [Alarm] = []

    func observe() async {
        for await updated in AlarmManager.shared.alarmUpdates {
            alarms = updated
        }
    }

    var running: [Alarm] { alarms.filter { $0.state == .countdown || $0.state == .alerting } }
}
```

Start it from `.task { await viewModel.observe() }` — the task cancels with the view. No `MainActor.run`
needed: the model is already main-actor isolated.

## Persisting IDs

The `Alarm.ID` (a `UUID`) is the only handle for pause/resume/cancel later. Store it with whatever the alarm
belongs to (a SwiftData model, `@AppStorage`), and reconcile against `alarmUpdates` on launch: alarms the system
removed should be dropped from your store.

## iOS 27 notes

- `AlarmPresentation.Alert`'s `stopButton` parameter is **deprecated since iOS 26.1** ("will no longer be used").
  The system supplies the stop control; use `Alert(title:secondaryButton:secondaryButtonBehavior:)`.
- iOS 27 adds `AlarmConfiguration` initializers and `.alarm` / `.timer` factories taking an
  `appEntityIdentifier:` (an App Intents `EntityIdentifier`), linking an alarm to an app entity.
