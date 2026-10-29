---
name: healthkit
description: HealthKit integration for iPhone apps — entitlement + usage strings, the SwiftUI permission sheet, reading steps/sleep/heart data with async query descriptors, writing samples, live and background updates, iOS 27 limited-read access (earliestAuthorizedSampleDate), Simulator seeding, and App Review rules for health data. Use when the user wants to read or write Apple Health data, build a fitness/wellness/habit app, or asks about HealthKit permissions or background delivery on iOS.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# HealthKit (iPhone)

Apple Health is the best free backend a small health app can have: years of the
user's step, sleep, heart, and workout history already on the device, synced
across their devices by Apple, with zero server work. Every snippet below was
type-checked against the **iOS 27 SDK** in both Swift 6 and default-MainActor modes.

watchOS workouts and complications → `watchos/` (health-fitness.md).

## When This Skill Activates

- Read or write Apple Health data (steps, sleep, heart rate, workouts, water, mindfulness…)
- "Connect to Apple Health", HealthKit permission flow, background delivery
- A tester says "my data isn't showing" (usually authorization or limited access)

## Rules That Shape the Design (read first)

1. **Read denial is invisible.** `requestAuthorization` succeeds whether the user allows reads or not. A denied read type just returns *no samples*. Design empty states that say "No step data — check Health ▸ Sharing", never "Error".
2. **Write status is visible**: `store.authorizationStatus(for:)` reports `sharingAuthorized` / `sharingDenied` for *write* types only.
3. **iOS 27: limited read access.** Users can grant reads only from a chosen date onward. Clamp query start dates with `earliestAuthorizedSampleDate(for:)` (below).
4. **App Review 5.1.3**: no health data in iCloud, no use for ads/marketing/data-mining, no selling it, and the privacy policy must cover it. Health data stays in HealthKit or on-device storage. This shapes `product/local-first-app`'s sync decision.
5. **iPad**: `HKHealthStore.isHealthDataAvailable()` is true on iPadOS 17+, but most data comes from iPhone/Watch. Always check it and hide the feature where false.

## Setup

Entitlement + usage strings (XcodeGen — see `ios/project-bootstrap`):

```yaml
entitlements:
  properties:
    com.apple.developer.healthkit: true
    com.apple.developer.healthkit.access: []        # [health-records] only for clinical records
    # com.apple.developer.healthkit.background-delivery: true
info:
  properties:
    NSHealthShareUsageDescription: "MyApp reads your steps and sleep to show weekly trends."
    NSHealthUpdateUsageDescription: "MyApp saves the water you log to Apple Health."
```

HealthKit works with a **free Personal Team** for on-device testing.

## Service Behind a Protocol

```swift
import HealthKit

protocol HealthStoring: Sendable {
    func dailySteps(days: Int) async throws -> [(date: Date, steps: Double)]
    func latestRestingHeartRate() async throws -> Double?
    func logWater(milliliters: Double, at date: Date) async throws
}

final class HealthKitService: HealthStoring {
    let store = HKHealthStore()

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    static let readTypes: Set<HKObjectType> = [
        HKQuantityType(.stepCount),
        HKQuantityType(.restingHeartRate),
        HKCategoryType(.sleepAnalysis),
        HKObjectType.workoutType(),
    ]
    static let shareTypes: Set<HKSampleType> = [
        HKQuantityType(.dietaryWater),
    ]
}
```

✅ Ask only for the types the current screen needs; add more when a feature first needs them.
❌ Requesting 20 types at onboarding — the Health sheet becomes a wall of toggles and users hit "Don't Allow".

## Permission: the SwiftUI Sheet

```swift
import SwiftUI
import HealthKitUI

struct ConnectHealthButton: View {
    @State private var trigger = false
    @State private var granted = false
    let health: HealthKitService

    var body: some View {
        Button("Connect Apple Health") { trigger.toggle() }
            .disabled(!HealthKitService.isAvailable)
            .healthDataAccessRequest(
                store: health.store,
                shareTypes: HealthKitService.shareTypes,
                readTypes: HealthKitService.readTypes,
                trigger: trigger
            ) { result in
                Task { @MainActor in
                    if case .success = result { granted = true }
                }
            }
    }
}
```

Prime before the system sheet (why + what you'll show) — `generators/permission-priming`.
Non-SwiftUI path: `try await store.requestAuthorization(toShare:read:)`.

## Reading

Daily totals — `HKStatisticsCollectionQueryDescriptor` does the bucketing and
de-duplicates iPhone + Watch steps (summing raw samples double-counts):

```swift
extension HealthKitService {
    func dailySteps(days: Int) async throws -> [(date: Date, steps: Double)] {
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: .now).addingTimeInterval(86_400)
        let start = calendar.date(byAdding: .day, value: -days, to: end)!
        let predicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.stepCount),
            predicate: HKQuery.predicateForSamples(withStart: start, end: end)
        )
        let query = HKStatisticsCollectionQueryDescriptor(
            predicate: predicate,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: .now),
            intervalComponents: DateComponents(day: 1)
        )
        let collection = try await query.result(for: store)
        var out: [(date: Date, steps: Double)] = []
        collection.enumerateStatistics(from: start, to: end) { stats, _ in
            out.append((stats.startDate, stats.sumQuantity()?.doubleValue(for: .count()) ?? 0))
        }
        return out
    }
}
```

Latest single value:

```swift
extension HealthKitService {
    func latestRestingHeartRate() async throws -> Double? {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: HKQuantityType(.restingHeartRate))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )
        let bpm = HKUnit.count().unitDivided(by: .minute())
        return try await descriptor.result(for: store).first?.quantity.doubleValue(for: bpm)
    }
}
```

Options: `.cumulativeSum` for steps/energy/water; `.discreteAverage` / `.discreteMin` / `.discreteMax` for heart rate, weight, HRV.
❌ `.cumulativeSum` on heart rate — options must match the type's aggregation style (`HKQuantityType.aggregationStyle`); a mismatch fails the query.

### iOS 27: limited read access

```swift
extension HealthKitService {
    func readableStart(for type: HKObjectType, wanted: Date) async throws -> Date {
        let limits = try await store.earliestAuthorizedSampleDate(for: [type])
        guard let earliest = limits[type] else { return wanted }   // absent = no date limit
        return max(wanted, earliest)
    }
}
```

Call it before building a long-range predicate ("last 365 days"). If it clamps, label
the chart "Showing data since <date> (your Health sharing setting)".

New iOS 27 types: `.heartRateVariabilityRMSSD` (quantity, ms — `.secondUnit(with: .milli)`),
`.menopausalState`, `.bleedingAfterMenopause` (category). Gate them with
`if #available(iOS 27, *)` only if you support older OSes; at an iOS 27 minimum, use directly.

## Writing

```swift
extension HealthKitService {
    func logWater(milliliters: Double, at date: Date) async throws {
        let sample = HKQuantitySample(
            type: HKQuantityType(.dietaryWater),
            quantity: HKQuantity(unit: .literUnit(with: .milli), doubleValue: milliliters),
            start: date, end: date
        )
        try await store.save(sample)
    }
}
```

Your app can delete only the samples it wrote. Keep the sample UUID if users can undo.

## Live + Background Updates

Foreground live updates — anchored query as an `AsyncSequence`:

```swift
extension HealthKitService {
    func stepUpdates() -> some AsyncSequence {
        HKAnchoredObjectQueryDescriptor(
            predicates: [.quantitySample(type: HKQuantityType(.stepCount))],
            anchor: nil
        ).results(for: store)
    }
    // for try await batch in stepUpdates() { batch.addedSamples / batch.deletedObjects / batch.newAnchor }
}
```

Background wake (needs the `healthkit.background-delivery` entitlement). Register at
**every launch**, in `App.init` or the app delegate — registrations don't persist:

```swift
extension HealthKitService {
    func enableBackgroundSteps(onChange: @escaping @Sendable () -> Void) async throws {
        let type = HKQuantityType(.stepCount)
        let query = HKObserverQuery(sampleType: type, predicate: nil) { _, completion, _ in
            onChange()
            completion()          // always call, or HealthKit backs off delivery
        }
        store.execute(query)
        try await store.enableBackgroundDelivery(for: type, frequency: .hourly)
    }
}
```

`.immediate` is honored only for some types; steps arrive at most hourly regardless.

## Simulator & Tests

The Simulator has a Health store but it starts **empty**. Seed it in DEBUG builds
(pair with `generators/debug-menu`):

```swift
#if DEBUG
extension HealthKitService {
    func seedSimulatorSteps(days: Int = 14) async throws {
        try await store.requestAuthorization(toShare: [HKQuantityType(.stepCount)], read: [])
        let samples: [HKQuantitySample] = (0..<days).map { i in
            let day = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            return HKQuantitySample(
                type: HKQuantityType(.stepCount),
                quantity: HKQuantity(unit: .count(), doubleValue: .random(in: 3_000...11_000)),
                start: day.addingTimeInterval(-3600), end: day
            )
        }
        try await store.save(samples)
    }
}
#endif
```

Unit tests and previews use a fake through the protocol — never `HKHealthStore` in tests:

```swift
struct FakeHealthStore: HealthStoring {
    func dailySteps(days: Int) async throws -> [(date: Date, steps: Double)] {
        (0..<days).map { (Calendar.current.date(byAdding: .day, value: -$0, to: .now)!, 8_000) }
    }
    func latestRestingHeartRate() async throws -> Double? { 58 }
    func logWater(milliliters: Double, at date: Date) async throws {}
}
```

## Pairing With On-Device AI

Health data plus Foundation Models makes a private weekly summary that never leaves
the phone. Pass **aggregates** (daily totals, averages), not raw samples, because the
on-device context window is small. Gate on availability (`apple-intelligence/on-device-ai-kit`).
Never send health data to a third-party model API without explicit, separate consent.

## Checklist

- [ ] Entitlement + both usage strings (share string only if you write)
- [ ] `isHealthDataAvailable()` checked; feature hidden where false
- [ ] Empty states handle invisible read denial
- [ ] Long-range queries clamped with `earliestAuthorizedSampleDate` (iOS 27)
- [ ] Statistics queries (not raw sums) for cumulative types
- [ ] Background delivery registered on every launch, `completion()` always called
- [ ] No health data in iCloud/CloudKit, analytics, or ads SDKs (5.1.3)
- [ ] Privacy policy mentions Health data (`legal/privacy-policy`)
- [ ] DEBUG seeding for Simulator; fake store for tests

## References

- HealthKit: https://developer.apple.com/documentation/healthkit
- Authorizing access: https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data
- Running queries with Swift concurrency: https://developer.apple.com/documentation/healthkit/running-queries-with-swift-concurrency
- App Review Guidelines 5.1.3 (Health): https://developer.apple.com/app-store/review/guidelines/#health-and-health-research
- Local SDK truth: `HKHealthStore.h` / `HKTypeIdentifiers.h` in the iOS 27 SDK (`ios(27.0)` markers)
- Related: `generators/permission-priming`, `watchos/`, `apple-intelligence/on-device-ai-kit`, `legal/privacy-policy`
