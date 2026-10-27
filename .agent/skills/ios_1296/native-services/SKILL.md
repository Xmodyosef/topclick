---
name: native-services
description: Apple services that replace a backend in small iPhone apps — WeatherKit (forecasts + required attribution), Core Location's async CLLocationUpdate/CLServiceSession, MapKit for SwiftUI and local search, EventKit calendar/reminders with iOS 17+ access levels, and local notifications — each with setup, usage string, and Swift 6-clean code. Use when the user wants weather, location, maps, nearby places, calendar or reminder integration, or reminders/notifications without running a server.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# Native Services (no backend required)

Each service here would otherwise mean an API key, a server, or a paid
third-party SDK. On Apple platforms they're system frameworks. All code
compiles against the iOS 27 SDK in Swift 6 and default-MainActor modes.

Health → `ios/healthkit`. Sensors → `ios/device-sensors`. Siri/Shortcuts → `apple-intelligence/app-intents`.
Widgets → `generators/widget-generator`. Remote push (needs a server) → `generators/push-notifications`.

## When This Skill Activates

- Weather, location, maps, "places near me"
- Add to / read from Calendar or Reminders
- Daily reminders or scheduled nudges without a server
- "What can I add without a backend?"

## Service Menu

| Service | Gives you | Setup | Cost / limits |
|---|---|---|---|
| **WeatherKit** | Current, hourly, daily, alerts | Entitlement **+** enable on App ID | Included with Apple Developer Program: 500K calls/month |
| **Core Location** | Position, region monitoring | Usage string | Free |
| **MapKit** | Maps, markers, local search, directions | none | Free for native apps |
| **EventKit** | Calendar events, reminders | Usage string per access level | Free |
| **UserNotifications (local)** | Scheduled alerts | Runtime permission | 64 pending requests per app |

## Core Location (async, iOS 18+ style)

```yaml
NSLocationWhenInUseUsageDescription: "MyApp uses your location to show local weather."
```

```swift
import CoreLocation

@MainActor @Observable
final class LocationService {
    private(set) var lastLocation: CLLocation?
    private var session: CLServiceSession?
    private var task: Task<Void, Never>?

    func start() {
        session = CLServiceSession(authorization: .whenInUse)   // prompts if needed, holds the grant
        task = Task {
            do {
                for try await update in CLLocationUpdate.liveUpdates() {
                    if update.authorizationDenied { break }
                    if let loc = update.location { lastLocation = loc }
                }
            } catch {}
        }
    }

    func stop() {
        task?.cancel()
        session?.invalidate()
        session = nil
    }

    func oneShot() async -> CLLocation? {
        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                if let loc = update.location { return loc }
                if update.authorizationDenied { return nil }
            }
        } catch {}
        return nil
    }
}
```

✅ `CLLocationUpdate.liveUpdates()` + `CLServiceSession`: no delegate, no manual `requestWhenInUseAuthorization`.
❌ A `CLLocationManagerDelegate` class for a one-shot "where am I". That's three callbacks and a state machine you don't need.
✅ Weather needs city-level precision. Respect approximate location rather than asking for precise.

## WeatherKit

Two switches, both required:
1. Entitlement `com.apple.developer.weatherkit: true` (XcodeGen: `ios/project-bootstrap`).
2. developer.apple.com → Certificates, IDs & Profiles → Identifiers → your App ID → enable **WeatherKit** under *both* Capabilities and App Services. Allow ~30 minutes to propagate. Until then, calls fail with an authentication error, which looks like a code bug and isn't.

```swift
import WeatherKit
import CoreLocation

struct WeatherSnapshot: Sendable {
    let temperature: Measurement<UnitTemperature>
    let condition: String
    let symbolName: String       // SF Symbol name
    let uvIndex: Int
}

func currentWeather(at location: CLLocation) async throws -> WeatherSnapshot {
    let current = try await WeatherService.shared.weather(for: location, including: .current)
    return WeatherSnapshot(
        temperature: current.temperature,
        condition: current.condition.description,
        symbolName: current.symbolName,
        uvIndex: current.uvIndex.value
    )
}
```

Fetch only the datasets you show: `including: .current, .daily`. Each dataset counts toward quota.
Cache for 15–30 minutes. Weather doesn't change per screen visit.

**Attribution is mandatory** (App Review checks it): Apple Weather mark + link to the legal page wherever data appears.

```swift
import SwiftUI
import WeatherKit

struct WeatherAttributionView: View {
    @Environment(\.colorScheme) private var scheme
    @State private var attribution: WeatherAttribution?

    var body: some View {
        Group {
            if let attribution {
                Link(destination: attribution.legalPageURL) {
                    AsyncImage(url: scheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL) { image in
                        image.resizable().scaledToFit()
                    } placeholder: { EmptyView() }
                    .frame(height: 12)
                }
            }
        }
        .task { attribution = try? await WeatherService.shared.attribution }
    }
}
```

## MapKit (SwiftUI)

```swift
import SwiftUI
import MapKit

struct PlacesMap: View {
    let places: [(name: String, coordinate: CLLocationCoordinate2D)]
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(places.indices, id: \.self) { i in
                Marker(places[i].name, systemImage: "mappin", coordinate: places[i].coordinate)
            }
        }
        .mapControls { MapUserLocationButton() }
    }
}

func searchNearby(_ query: String, around center: CLLocationCoordinate2D) async throws -> [MKMapItem] {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query                      // "coffee", "pharmacy", "trailhead"
    request.region = MKCoordinateRegion(center: center, latitudinalMeters: 2_000, longitudinalMeters: 2_000)
    return try await MKLocalSearch(request: request).start().mapItems
}
```

`MKLocalSearch` replaces a Places API key for most "near me" features. Advanced MapKit
(GeoToolbox, place descriptors) → `mapkit/geotoolbox`.

## EventKit: ask for the least access

iOS 17+ access levels. **Write-only** shows a lighter prompt and suits "Add to Calendar":

| Need | Call | Usage key |
|---|---|---|
| Add events only | `requestWriteOnlyAccessToEvents()` | `NSCalendarsWriteOnlyAccessUsageDescription` |
| Read events | `requestFullAccessToEvents()` | `NSCalendarsFullAccessUsageDescription` |
| Reminders | `requestFullAccessToReminders()` | `NSRemindersFullAccessUsageDescription` |

```swift
import EventKit

final class CalendarService {
    let store = EKEventStore()

    func addEvent(title: String, start: Date, minutes: Int) async throws {
        guard try await store.requestWriteOnlyAccessToEvents() else { return }
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = start
        event.endDate = start.addingTimeInterval(TimeInterval(minutes * 60))
        event.calendar = store.defaultCalendarForNewEvents
        try store.save(event, span: .thisEvent)
    }

    func upcoming(days: Int) async throws -> [EKEvent] {
        guard try await store.requestFullAccessToEvents() else { return [] }
        let predicate = store.predicateForEvents(withStart: .now,
                                                 end: .now.addingTimeInterval(TimeInterval(days * 86_400)),
                                                 calendars: nil)
        return store.events(matching: predicate)
    }

    func addReminder(_ title: String, due: DateComponents) async throws {
        guard try await store.requestFullAccessToReminders() else { return }
        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.dueDateComponents = due
        reminder.calendar = store.defaultCalendarForNewReminders()
        try store.save(reminder, commit: true)
    }
}
```

No permission at all: `EKEventEditViewController` (EventKitUI) lets the user add one
event through system UI with no prompt.

## Local Notifications

No server, no push entitlement, no APNs certificate:

```swift
import UserNotifications

enum Reminders {
    static func requestPermission() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func scheduleDaily(id: String, title: String, hour: Int, minute: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute), repeats: true
        )
        try await UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        )
    }

    static func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
```

✅ Stable identifiers (`"daily-checkin"`): re-adding replaces instead of duplicating.
✅ Ask for notification permission after the user sets a reminder time, not at launch (`generators/permission-priming`).
❌ Scheduling 30 days of one-off notifications. Use `repeats: true`; the 64-pending cap silently drops extras.

Content that changes daily (e.g. "You walked 8,421 steps yesterday") → refresh in a
`BGAppRefreshTask` (`generators/background-processing`) and reschedule.

## Checklist

- [ ] Each service has its usage string and nothing extra
- [ ] Location via `CLLocationUpdate` + `CLServiceSession`; approximate location handled
- [ ] WeatherKit enabled on the App ID (Capabilities **and** App Services); attribution shown
- [ ] Weather responses cached; only needed datasets requested
- [ ] EventKit uses write-only access where possible
- [ ] Notifications use stable IDs and repeating triggers; permission asked in context

## References

- WeatherKit: https://developer.apple.com/weatherkit/
- CLLocationUpdate: https://developer.apple.com/documentation/corelocation/cllocationupdate
- Core Location (CLServiceSession, approximate location): https://developer.apple.com/documentation/corelocation
- MapKit for SwiftUI: https://developer.apple.com/documentation/mapkit/mapkit-for-swiftui
- EventKit access levels: https://developer.apple.com/documentation/eventkit/accessing-the-event-store
- Scheduling local notifications: https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app
- Related: `ios/healthkit`, `generators/permission-priming`, `generators/background-processing`, `mapkit/geotoolbox`
