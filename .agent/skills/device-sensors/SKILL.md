---
name: device-sensors
description: Core Motion on iPhone — step counting and floors (CMPedometer), walking/running/driving detection (CMMotionActivityManager), altitude (CMAltimeter), and tilt/attitude (CMMotionManager) — with Swift 6-safe async wrappers. Use when the user wants step counts without HealthKit, activity detection, motion-driven interactions, or "use the phone's sensors" in a local-only app.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# Device Sensors (Core Motion)

The M-series motion coprocessor logs steps, floors, and activity type **all the
time**, even when your app isn't running, and keeps 7 days of history. An app
can show "today's steps" on first launch with a single motion permission and no
HealthKit. Code below compiles against the iOS 27 SDK in Swift 6 and
default-MainActor modes.

## When This Skill Activates

- Steps/floors/distance without asking for Health access
- Detect walking / running / cycling / driving / stationary
- Altitude or pressure (hikes, stairs), tilt- or shake-driven UI
- Choosing between Core Motion and HealthKit for activity data

## Core Motion vs HealthKit

| Need | Use |
|---|---|
| Today / last 7 days of steps, one permission, iPhone only | **CMPedometer** |
| Long history, Apple Watch data merged, sleep/heart | **HealthKit** (`ios/healthkit`) |
| "What is the user doing right now?" | **CMMotionActivityManager** |
| Relative climb, absolute altitude | **CMAltimeter** |
| Tilt, rotation, gestures | **CMMotionManager** device motion |

Many apps use both: Core Motion for instant, permission-light numbers, HealthKit
when the user opts into history.

## Setup

```yaml
# project.yml → info.properties
NSMotionUsageDescription: "MyApp counts your steps and detects walks."
```

Permission is prompted on first query. Check before showing UI:

```swift
CMPedometer.authorizationStatus()       // .notDetermined / .authorized / .denied / .restricted
CMPedometer.isStepCountingAvailable()   // false in the Simulator
```

**Simulator has no motion hardware.** Every `is…Available()` returns false there.
Test on a device (`generators/testflight-ship` → `ship.sh device`) and use a fake behind a protocol
for previews and unit tests.

## Async Wrappers (Swift 6-safe)

Core Motion has completion-handler APIs only — **no `async` overloads**
(`try await pedometer.queryPedometerData(from:to:)` does not compile). Also,
`CMPedometerData` and `CMMotionActivity` are not `Sendable`: resuming a continuation
with them is a **hard error** under default MainActor isolation. Copy values out
inside the callback:

```swift
import CoreMotion

enum MotionError: Error { case unavailable }

@MainActor @Observable
final class MotionService {
    private let pedometer = CMPedometer()
    private let activity = CMMotionActivityManager()
    private let altimeter = CMAltimeter()

    private(set) var stepsToday = 0
    private(set) var floorsToday = 0
    private(set) var currentActivity = "unknown"
    private(set) var relativeAltitudeMeters = 0.0

    struct ActivitySegment: Sendable {
        let start: Date
        let kind: String
    }

    func loadToday() async throws {
        let start = Calendar.current.startOfDay(for: .now)
        // CMPedometerData isn't Sendable — copy the numbers out inside the callback.
        let (steps, floors): (Int, Int) = try await withCheckedThrowingContinuation { cont in
            pedometer.queryPedometerData(from: start, to: .now) { data, error in
                if let data {
                    cont.resume(returning: (data.numberOfSteps.intValue, data.floorsAscended?.intValue ?? 0))
                } else {
                    cont.resume(throwing: error ?? MotionError.unavailable)
                }
            }
        }
        stepsToday = steps
        floorsToday = floors
    }

    // Past 7 days of activity segments — no HealthKit needed
    func recentActivity() async throws -> [ActivitySegment] {
        let start = Calendar.current.date(byAdding: .day, value: -7, to: .now)!
        return try await withCheckedThrowingContinuation { cont in
            activity.queryActivityStarting(from: start, to: .now, to: .main) { list, error in
                guard let list else { return cont.resume(throwing: error ?? MotionError.unavailable) }
                cont.resume(returning: list.map { ActivitySegment(start: $0.startDate, kind: Self.label(for: $0)) })
            }
        }
    }

    nonisolated static func label(for a: CMMotionActivity) -> String {
        a.walking ? "walking" : a.running ? "running" : a.cycling ? "cycling"
            : a.automotive ? "driving" : a.stationary ? "still" : "unknown"
    }
}
```

❌ `enum CMError: Error` — CoreMotion already exports a `CMError` type; name yours `MotionError`.

## Live Updates

```swift
extension MotionService {
    func startLive() {
        let start = Calendar.current.startOfDay(for: .now)
        pedometer.startUpdates(from: start) { [weak self] data, _ in
            guard let steps = data?.numberOfSteps.intValue else { return }
            Task { @MainActor in self?.stepsToday = steps }     // handler runs on a background queue
        }
        if CMMotionActivityManager.isActivityAvailable() {
            activity.startActivityUpdates(to: .main) { [weak self] a in
                guard let a else { return }
                let label = Self.label(for: a)
                MainActor.assumeIsolated { self?.currentActivity = label }   // delivered on .main
            }
        }
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
                guard let meters = data?.relativeAltitude.doubleValue else { return }
                MainActor.assumeIsolated { self?.relativeAltitudeMeters = meters }
            }
        }
    }

    func stopLive() {
        pedometer.stopUpdates()
        activity.stopActivityUpdates()
        altimeter.stopRelativeAltitudeUpdates()
    }
}
```

`CMPedometer.startUpdates` has no queue parameter, so hop with `Task { @MainActor in }`.
The activity/altimeter APIs take `to: .main`, so `MainActor.assumeIsolated` is correct there.

✅ Start in `.onAppear`, stop in `.onDisappear` or on `scenePhase != .active`.
❌ Leaving device-motion updates running in the background — battery drain, and testers will notice.

## Tilt / Attitude

```swift
@MainActor @Observable
final class TiltReader {
    private let manager = CMMotionManager()     // one instance per app
    private(set) var pitch = 0.0
    private(set) var roll = 0.0

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30.0     // 30 Hz is plenty for UI
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let attitude = motion?.attitude else { return }
            MainActor.assumeIsolated {
                self?.pitch = attitude.pitch
                self?.roll = attitude.roll
            }
        }
    }
    func stop() { manager.stopDeviceMotionUpdates() }
}
```

iOS 27 adds `CMDeviceMotion.headingAccuracy` (max heading error in degrees; negative =
invalid), useful for compass UIs, and `CMMotionManager.deviceMotionBody` ("a body from which
device motion should be referenced"; a `CMBodyIdentifiable`). The SDK documents the
latter in one line, so prototype it before building on it.

## Testing

```swift
protocol StepSource: Sendable {
    func stepsToday() async throws -> Int
}

struct FixedSteps: StepSource {
    let value: Int
    func stepsToday() async throws -> Int { value }
}
```

Inject `StepSource` into view models. `#Preview` and `@Test` use `FixedSteps(value: 8_421)`.

## Checklist

- [ ] `NSMotionUsageDescription` set
- [ ] Availability checked per sensor; UI degrades on iPad/Simulator
- [ ] Continuations resume with Sendable values only
- [ ] Every `start…Updates` paired with a `stop…Updates`
- [ ] Denied state explains Settings ▸ Privacy & Security ▸ Motion & Fitness
- [ ] Protocol seam for previews/tests

## References

- Core Motion: https://developer.apple.com/documentation/coremotion
- CMPedometer: https://developer.apple.com/documentation/coremotion/cmpedometer
- CMMotionActivityManager: https://developer.apple.com/documentation/coremotion/cmmotionactivitymanager
- Related: `ios/healthkit`, `swift/concurrency-patterns`, `design/game-feel` (motion-driven interactions)
