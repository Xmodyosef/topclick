# Integrated Reference Bundle 08

Combines 11 related source skills from `coding-architecture-git` into one navigable reference file.

## Source map

- `generators/live-activity-generator/SKILL.reference.md`
- `generators/localization-setup/SKILL.reference.md`
- `generators/logging-setup/SKILL.reference.md`
- `generators/milestone-celebration/SKILL.reference.md`
- `generators/networking-layer/SKILL.reference.md`
- `generators/offer-codes-setup/SKILL.reference.md`
- `generators/offline-queue/SKILL.reference.md`
- `generators/pagination/SKILL.reference.md`
- `generators/paywall-generator/SKILL.reference.md`
- `generators/persistence-setup/SKILL.reference.md`
- `generators/pre-orders/SKILL.reference.md`

## Integrated guidance

### Source: `generators/live-activity-generator`

# Live Activity Generator

Generate a complete ActivityKit Live Activity implementation with Dynamic Island layouts, Lock Screen presentation, activity lifecycle management, and push-to-update support.

## When This Skill Activates

Use this skill when the user:
- Asks to "add Live Activities" or "add a Live Activity"
- Mentions "Dynamic Island" layouts
- Wants real-time status updates on the Lock Screen
- Asks about "ActivityKit" or "ActivityAttributes"
- Mentions "push-to-update" for live activities
- Wants to show ongoing progress (delivery tracking, sports scores, timers, workouts)

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check for existing ActivityKit implementations
- [ ] Check for an existing widget extension target
- [ ] Verify deployment target is iOS 16.1+
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing Live Activity code:
```
Glob: **/*Activity*.swift, **/*LiveActivity*.swift
Grep: "ActivityKit" or "ActivityAttributes" or "ActivityConfiguration"
```

If an existing widget extension is found:
- Ask if the Live Activity should be added to the existing widget bundle
- Check for existing `WidgetBundle` to extend

If Live Activity code already exists:
- Ask user whether to replace or extend

### 3. Required Capabilities

**Live Activities require:**
- iOS 16.1+ deployment target
- `NSSupportsLiveActivities` set to `YES` in Info.plist
- A widget extension target (can share with existing WidgetKit widgets)
- For push updates: `NSSupportsLiveActivitiesFrequentUpdates` (optional, iOS 16.2+)

## Configuration Questions

Ask user via AskUserQuestion:

1. **What is the Live Activity for?** (freeform)
   - Examples: delivery tracking, sports score, workout timer, ride-sharing, food order
   - This determines the attribute fields and content state

2. **What data should appear on the Lock Screen?** (freeform)
   - Static data (set at start, does not change): e.g., restaurant name, order number
   - Dynamic data (updated over time): e.g., ETA, driver location, score

3. **Dynamic Island layout needs?**
   - Compact (leading + trailing) only
   - Expanded (leading, trailing, center, bottom) only
   - Both compact and expanded (recommended)

4. **Push-to-update support?**
   - Yes -- server can update the activity remotely via APNs
   - No -- updates only from the app process

5. **Alert configuration when ending?**
   - Yes -- show a final alert on the Lock Screen when the activity ends
   - No -- dismiss silently

## Generation Process

### Step 1: Determine File Locations

Check project structure:
- If a widget extension target exists, add files there
- Otherwise, instruct user to create a Widget Extension target first

For the activity manager (lives in the main app target):
- If `Sources/` exists --> `Sources/LiveActivity/`
- If `App/` exists --> `App/LiveActivity/`
- Otherwise --> `LiveActivity/`

For the widget extension views:
- Place inside the existing widget extension directory (e.g., `MyAppWidgets/`)

### Step 2: Create Core Files

Generate these files based on configuration answers:

1. **`{Name}ActivityAttributes.swift`** -- Shared between app and widget extension
   - `ActivityAttributes` struct with static properties
   - Nested `ContentState` with dynamic properties
2. **`{Name}LiveActivityView.swift`** -- Widget extension file
   - `ActivityConfiguration` with Lock Screen, Dynamic Island layouts
3. **`{Name}ActivityManager.swift`** -- Main app target file
   - Protocol-based manager for start, update, end, and push token handling

### Step 3: Generate Code from Templates

Use the templates in **templates.md** and customize based on user answers:
- Replace placeholder attribute names with real fields
- Configure Dynamic Island regions based on layout choice
- Include or exclude push-to-update code
- Include or exclude alert configuration

## Info.plist Required

### Main App Target
```xml
<key>NSSupportsLiveActivities</key>
<true/>

<!-- Optional: for frequent push updates (iOS 16.2+) -->
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

## Output Format

After generation, provide:

### Files Created

```
Sources/LiveActivity/
├── {Name}ActivityAttributes.swift     # Shared: attributes + content state
└── {Name}ActivityManager.swift        # Main app: lifecycle management

MyAppWidgets/
├── {Name}LiveActivityView.swift       # Widget ext: all Live Activity UI
└── (update WidgetBundle if needed)
```

### Integration Steps

**1. Add the widget extension target (if not present):**
- File > New > Target > Widget Extension
- Ensure "Include Live Activity" is checked

**2. Share the attributes file between targets:**
The `{Name}ActivityAttributes.swift` file must be included in both the main app target and the widget extension target. Select the file in Xcode, open the File Inspector, and check both targets under "Target Membership".

**3. Add Info.plist entries in the main app target:**
```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

**4. Register the Live Activity configuration in the widget bundle:**
```swift
@main
struct MyAppWidgets: WidgetBundle {
    var body: some Widget {
        // Existing widgets...
        MyAppLiveActivity()
    }
}
```

**5. Start a Live Activity from your app:**
```swift
let attributes = DeliveryActivityAttributes(
    orderNumber: "1234",
    restaurantName: "Pizza Place"
)

let initialState = DeliveryActivityAttributes.ContentState(
    status: .preparing,
    estimatedDelivery: Date().addingTimeInterval(30 * 60),
    driverName: nil
)

let manager = LiveActivityManager()
try await manager.startActivity(attributes: attributes, state: initialState)
```

**6. Update the activity when state changes:**
```swift
let updatedState = DeliveryActivityAttributes.ContentState(
    status: .enRoute,
    estimatedDelivery: Date().addingTimeInterval(15 * 60),
    driverName: "Alex"
)

await manager.updateActivity(state: updatedState)
```

**7. End the activity when complete:**
```swift
let finalState = DeliveryActivityAttributes.ContentState(
    status: .delivered,
    estimatedDelivery: Date(),
    driverName: "Alex"
)

await manager.endActivity(state: finalState, dismissalPolicy: .default)
```

### Push-to-Update Setup (if enabled)

**1. Observe push tokens:**
The generated `{Name}ActivityManager` automatically observes push token updates. Send the token to your server when it changes.

**2. Server-side APNs request:**
```bash
curl -v \
  --header "authorization: bearer $JWT_TOKEN" \
  --header "apns-topic: com.yourcompany.yourapp.push-type.liveactivity" \
  --header "apns-push-type: liveactivity" \
  --http2 \
  --data '{"aps":{"timestamp":1234567890,"event":"update","content-state":{"status":"enRoute","estimatedDelivery":1234568000,"driverName":"Alex"}}}' \
  https://api.push.apple.com/3/device/$PUSH_TOKEN
```

Note: The `apns-topic` must be your app bundle ID with `.push-type.liveactivity` appended.

**3. Ending via push:**
```json
{
  "aps": {
    "timestamp": 1234567890,
    "event": "end",
    "dismissal-date": 1234568000,
    "content-state": {
      "status": "delivered",
      "estimatedDelivery": 1234567890,
      "driverName": "Alex"
    }
  }
}
```

### Testing Instructions

1. **Verify on a physical device:** Live Activities run in the Simulator in current Xcode releases, but Lock Screen, StandBy, and Dynamic Island presentation is only authoritative on hardware. Test on a device with iOS 16.1+ before shipping.
2. **Dynamic Island:** Requires iPhone 14 Pro or later (devices with the Dynamic Island hardware).
3. **Push-to-update testing:** Use a tool like `apnspush` or `curl` with an APNs auth key (.p8 file) to send test payloads.
4. **Debug tips:**
   - Use `Activity<Attributes>.activities` to list all running activities
   - Check Console.app for ActivityKit logs filtered by your app bundle ID
   - Activities are limited to a maximum of 5 concurrent per app

## Design Rules

Apply when generating the Lock Screen and Dynamic Island views.

**Lock Screen presentation (WWDC23):**
- **14pt margins on all edges** — matches the notification layout the activity sits among.
- Keep height compact, and **change it dynamically between moments** — collapse sections that are no longer relevant (e.g., drop the "preparing" row once the driver is en route).
- Transitions: **numeric content transition** for counting values (scores, timers), **content-replace** when swapping graphics, and when reordering a list animate **only the row that moves**.
- Provide explicit **background and foreground colors** — the system derives the dismiss button's appearance from them.
- **Remove the activity shortly after it ends** — don't let a finished state linger; use a tight dismissal policy rather than the 4-hour default window.
- **StandBy scales the presentation to 200% and won't draw under the sensor region** — verify the layout survives both.

**Dynamic Island presentation:**
- Shapes **concentric with the island's corner radius**, with even margins all around.
- **Compact view: as narrow as possible**, content snug against the sensor housing on both sides.
- **Expanded view preserves the compact view's relative element placement** — leading stays leading, trailing stays trailing, so the transition reads as growth, not rearrangement.
- Avoid a **"forehead"** — an empty band above the sensor. Wrap content around the sensor region instead.
- **Never draw UI that points at or interacts with the island** (arrows toward the cutout, faux hardware jokes).

**Apple Watch (Smart Stack):**
- iPhone Live Activities automatically appear at the top of the watch Smart Stack, auto-generated by re-compositing the Dynamic Island compact-state assets. Adopting the Apple Watch size class — `.supplementalActivityFamilies([.small])` plus a switch on `@Environment(\.activityFamily)` — makes "a significant difference in quality".
- Show only the most critical information: "just the information you need, and nothing more."
- Surface only significant states: progress (time until landing), action required (car arriving), high care (score change).
- Stick to **exactly one control**.
- While the user is actively using the watch, updates appear as a **compact view at the bottom of the display**; pulling it up expands the full widget — design both states.
- The Smart Stack stays visible on wrist-down, so the Activity must stay legible alongside the time.
- Prefer the existing Smart Stack layouts; custom layouts must use standard margins and text styles.

## Common Patterns

### Delivery Tracking
Static: order number, restaurant name
Dynamic: status enum, ETA, driver name

### Sports Score
Static: home team, away team, sport type
Dynamic: home score, away score, period/quarter, game clock

### Workout / Timer
Static: workout type, goal
Dynamic: elapsed time, calories, heart rate, distance

### Ride-Sharing
Static: pickup location, destination
Dynamic: driver name, ETA, vehicle info, status

## Gotchas and Limits

- **Size limit:** `ActivityAttributes` + `ContentState` combined must be under 4KB
- **Concurrent limit:** Maximum 5 active Live Activities per app
- **Duration:** Activities automatically end after 8 hours (can remain on Lock Screen for up to 4 more hours in ended state)
- **Push token changes:** The push token can change during the lifetime of an activity; always observe `pushTokenUpdates`
- **Stale state:** Always set `staleDate` on content to let the system show stale indicators
- **Background updates:** The app can update activities from the background, but not start new ones

## References

- **templates.md** -- Code templates for attributes, widget views, and manager
- [ActivityKit Documentation](https://developer.apple.com/documentation/activitykit)
- [Displaying live data with Live Activities](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [Updating and ending your Live Activity with ActivityKit push notifications](https://developer.apple.com/documentation/activitykit/updating-and-ending-your-live-activity-with-activitykit-push-notifications)

### Source: `generators/localization-setup`

# Localization Setup Generator

Generate internationalization (i18n) infrastructure for multi-language support in iOS/macOS apps.

## When This Skill Activates

- User wants to localize their app for multiple languages
- User mentions i18n, internationalization, or localization
- User asks about String Catalogs or .strings files
- User wants to support RTL (right-to-left) languages

## Pre-Generation Checks

Before generating, verify:

1. **Existing Localization**
   ```bash
   # Check for existing localization files
   find . -name "*.xcstrings" -o -name "Localizable.strings" 2>/dev/null | head -5
   find . -name "*.lproj" -type d 2>/dev/null | head -5
   ```

2. **Deployment Target**
   ```bash
   # String Catalogs require iOS 16+ / macOS 13+
   grep -r "IPHONEOS_DEPLOYMENT_TARGET\|MACOSX_DEPLOYMENT_TARGET" *.xcodeproj 2>/dev/null
   ```

3. **Project Structure**
   ```bash
   # Find project for adding localization
   find . -name "*.xcodeproj" | head -1
   ```

## Configuration Questions

### 1. Localization Approach
- **String Catalogs** (Recommended, iOS 16+) - Modern, visual editor in Xcode
- **Legacy .strings** - Traditional approach, all iOS versions

### 2. Initial Languages
- English (en) - default
- Which additional languages? (e.g., es, de, fr, ja, zh-Hans)

### 3. Features
- **Pluralization** - Handle "1 item" vs "2 items"
- **Device-specific** - Different strings for iPhone/iPad/Mac
- **SwiftUI Preview** - Preview in different locales

## Generated Files

### String Catalogs (Recommended)
```
Resources/
└── Localizable.xcstrings    # String catalog with all translations
```

### Supporting Code
```
Sources/Localization/
├── LocalizedStrings.swift   # Type-safe string access
├── LocalizationManager.swift # Runtime language switching
└── LocalizedPreview.swift   # SwiftUI preview helpers
```

## Key Features

### Type-Safe String Access

```swift
// Generated enum for type-safe access
enum L10n {
    static let appName = String(localized: "app_name")
    static let welcomeMessage = String(localized: "welcome_message")

    enum Settings {
        static let title = String(localized: "settings_title")
        static let language = String(localized: "settings_language")
    }
}

// Usage
Text(L10n.appName)
Text(L10n.Settings.title)
```

### Pluralization

```swift
// In String Catalog, define plural rules
// key: "items_count"
// variations:
//   - zero: "No items"
//   - one: "1 item"
//   - other: "%lld items"

Text(String(localized: "items_count \(count)",
            defaultValue: "\(count) items"))
```

### String Interpolation

```swift
// In String Catalog:
// key: "greeting"
// value: "Hello, %@!"

let name = "Alice"
Text(String(localized: "greeting \(name)"))
```

### Runtime Language Switching

```swift
// Preview in different locale
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.locale, Locale(identifier: "es"))
    }
}
```

## Integration Steps

### 1. Add String Catalog

1. In Xcode: File > New > File
2. Choose "String Catalog"
3. Name it "Localizable.xcstrings"
4. Add to your app target

### 2. Add Supported Languages

1. Select project in navigator
2. Info tab > Localizations
3. Click + to add languages

### 3. Migrate Existing Strings

If migrating from .strings files:
1. Right-click .strings file
2. "Migrate to String Catalog..."

### 4. Use in SwiftUI

```swift
// Automatic localization
Text("Hello, World!")  // Uses String Catalog automatically

// Explicit localized string
Text(String(localized: "custom_key"))

// With type-safe enum (generated)
Text(L10n.welcomeMessage)
```

### 5. Use in UIKit

```swift
label.text = String(localized: "hello_world")
// or
label.text = NSLocalizedString("hello_world", comment: "Greeting")
```

## Best Practices

### Key Naming Conventions
```
// Good: Descriptive, hierarchical
"settings.appearance.theme"
"onboarding.step1.title"
"error.network.connection_failed"

// Avoid: Vague or hardcoded text as key
"button1"
"Hello, World!"
```

### Comments for Translators
```swift
String(localized: "delete_confirmation",
       comment: "Alert message asking user to confirm deletion")
```

### Formatting
```swift
// Numbers - Use FormatStyle
Text(price, format: .currency(code: "USD"))

// Dates - Use FormatStyle
Text(date, format: .dateTime.month().day())

// Lists - Use ListFormatStyle
Text(items, format: .list(type: .and))
```

### RTL Support
```swift
// Automatic with SwiftUI
// For manual layout adjustments:
.environment(\.layoutDirection, .rightToLeft)
```

## Testing Localization

### In Xcode
1. Edit Scheme > Run > Options
2. Set "App Language" to test language
3. Set "App Region" for number/date formatting

### In SwiftUI Previews
```swift
#Preview {
    ContentView()
        .environment(\.locale, Locale(identifier: "ja"))
}
```

### Export for Translation
1. Product > Export Localizations...
2. Share .xliff files with translators
3. Import translated .xliff files

## References

- [String Catalogs](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog)
- [Localization Guide](https://developer.apple.com/localization/)
- [Formatting Numbers and Dates](https://developer.apple.com/documentation/foundation/formatstyle)

### Source: `generators/logging-setup`

# Logging Setup Generator

Replace print() statements with Apple's structured logging system (os.log/Logger) for better debugging, privacy controls, and Console.app integration.

## When This Skill Activates

Use this skill when the user:
- Asks to "add logging" or "set up logging"
- Wants to "replace print statements"
- Mentions "os.log", "Logger", or "structured logging"
- Asks about "debug logging" or "production logging"
- Wants to audit print() usage in their codebase

## Why Logger Over print()

| print() | Logger |
|---------|--------|
| Always executes | Debug logs compiled out in Release |
| No filtering | Filter by subsystem/category in Console.app |
| No privacy | .private, .public, .sensitive annotations |
| String interpolation always runs | Deferred evaluation (performance) |
| Not in Console.app | Full system integration |

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (Logger requires iOS 14+ / macOS 11+)
- [ ] Search for existing Logger/os.log usage
- [ ] Identify source file locations (Sources/, App/, etc.)

### 2. Conflict Detection
Search for existing logging:
```
Glob: **/*Logger*.swift
Grep: "import OSLog" or "os_log"
```

If found, ask user:
- Extend existing logging?
- Replace with new implementation?
- Create separate logger?

## Modes of Operation

### Mode 1: Audit
Find all print() statements and report:
```
Grep: print\s*\(
```

Report format:
- File:line - print statement
- Severity: Info/Warning/Error (based on context)
- Suggested Logger level

### Mode 2: Generate
Create logging infrastructure from scratch.

### Mode 3: Migrate
Convert existing print() to Logger with suggestions.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Categories needed?**
   - Network, Auth, UI, Data (defaults)
   - Custom categories?

2. **Include migration helpers?**
   - Extension on String for quick migration
   - Temporary print-to-log bridge

## Generation Process

### Step 1: Create AppLogger.swift

Read template from `templates/AppLogger.swift` and customize:
- Set subsystem from Bundle.main.bundleIdentifier
- Add user-specified categories
- Include usage examples in comments

### Step 2: Determine File Location

Check project structure:
- If `Sources/` exists → `Sources/Logging/AppLogger.swift`
- If `App/` exists → `App/Logging/AppLogger.swift`
- Otherwise → `Logging/AppLogger.swift`

### Step 3: Provide Migration Guidance

Show examples of converting common print patterns:
```swift
// Before
print("User logged in: \(email)")

// After
AppLogger.auth.info("User logged in: \(email, privacy: .private)")
```

## Output Format

After generation, provide:

### Files Created
- `[Path]/Logging/AppLogger.swift`

### Integration Steps
1. Import in files: `import OSLog` (not needed if using AppLogger)
2. Replace print() calls with AppLogger.[category].[level]()
3. Add privacy annotations for sensitive data

### Privacy Annotations Guide
- `.public` - Safe to log (IDs, counts, non-sensitive)
- `.private` - Redacted in release (emails, names)
- `.sensitive` - Always redacted (passwords, tokens)

### Console.app Usage
1. Open Console.app
2. Filter by subsystem: `com.yourapp`
3. Filter by category: `Network`, `Auth`, etc.

### Testing Instructions
1. Add a test log: `AppLogger.general.debug("Test log")`
2. Run app, check Xcode console
3. Open Console.app, filter by your app's subsystem

## References

- **logger-patterns.md** - Best practices and privacy levels
- **migration-guide.md** - Converting print() to Logger
- **templates/AppLogger.swift** - Template file

### Source: `generators/milestone-celebration`

# Milestone Celebration Generator

Generate a production milestone celebration system with confetti particle animations via `CAEmitterLayer`, achievement badge views with locked/unlocked states, a celebration overlay with spring animations, haptic feedback, and optional shareable achievement cards — all triggered automatically when users hit key thresholds.

## When This Skill Activates

Use this skill when the user:
- Asks to "add celebrations" or "celebrate achievements"
- Wants "confetti animation" or "particle effects for milestones"
- Mentions "achievement badges" or "badge unlock animation"
- Asks about "milestone rewards" or "progress milestones"
- Wants to "celebrate achievement" or "trigger celebration on threshold"
- Asks about "level-up animation" or "gamification celebrations"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 17+ / macOS 14+ for `@Observable`, spring animations, `sensoryFeedback`)
- [ ] Check for `UIKit` availability (iOS — `CAEmitterLayer` for confetti, haptics)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing celebration/animation code:
```
Glob: **/*Confetti*.swift, **/*Celebration*.swift, **/*Achievement*.swift, **/*Milestone*.swift, **/*Badge*.swift
Grep: "CAEmitterLayer" or "CAEmitterCell" or "UINotificationFeedbackGenerator" or "confetti" or "celebration"
```

If existing celebration or gamification library found (e.g., custom confetti, third-party particle libraries):
- Ask if user wants to replace or integrate with it
- If keeping, advise on best practices instead of generating

### 3. Platform Detection
Determine if generating for iOS (UIKit-based confetti + haptics) or macOS (Core Animation confetti, no haptics) or both (cross-platform with feature gates).

## Configuration Questions

Ask user via AskUserQuestion:

1. **Celebration type?** (multi-select)
   - Confetti burst (full-screen particle animation)
   - Badge unlock (icon reveal with glow animation)
   - Level-up (progress ring fill + title transition)
   - Custom (user defines their own celebration style)

2. **Haptic feedback?**
   - Yes — success haptic on celebration trigger (recommended)
   - No — silent celebrations only

3. **Shareable achievement card?**
   - Yes — render achievement as image for social sharing via `ShareLink`
   - No — in-app celebration only

4. **Sound effects?**
   - Yes — play system sound or bundled audio on celebration
   - No — visual only

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `Milestone.swift` — Model with id, title, description, threshold, icon, unlock state. `Codable` + `Sendable`.
2. `MilestoneTracker.swift` — `@Observable` class tracking progress toward milestones, checking thresholds, triggering celebrations. Persists unlock state via `UserDefaults` or file storage.
3. `ConfettiView.swift` — `UIViewRepresentable` wrapping `CAEmitterLayer` for confetti particle animation. Configurable colors, duration, density. Respects Reduce Motion.

### Step 3: Create UI Files
4. `CelebrationOverlay.swift` — Full-screen overlay combining confetti + badge reveal + congratulations message. Auto-dismisses after configurable duration. Uses `withAnimation(.spring)`.
5. `MilestoneBadgeView.swift` — Individual badge view with locked/unlocked states, SF Symbol icon, progress ring for partial progress.
6. `MilestoneCollectionView.swift` — Grid layout of all milestones showing locked/unlocked state with progress indicators.

### Step 4: Create Optional Files
Based on configuration:
- `HapticManager.swift` — If haptic feedback selected (thin wrapper around `UINotificationFeedbackGenerator` / `UIImpactFeedbackGenerator`)
- `ShareableMilestoneCard.swift` — If shareable selected (renders milestone as image via `ImageRenderer` + `ShareLink`)

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/MilestoneCelebration/`
- If `App/` exists -> `App/MilestoneCelebration/`
- Otherwise -> `MilestoneCelebration/`

## Output Format

After generation, provide:

### Files Created
```
MilestoneCelebration/
├── Milestone.swift              # Model with threshold, icon, unlock state
├── MilestoneTracker.swift       # @Observable tracker with persistence
├── ConfettiView.swift           # CAEmitterLayer confetti animation
├── CelebrationOverlay.swift     # Full-screen celebration overlay
├── MilestoneBadgeView.swift     # Badge with locked/unlocked + progress ring
├── MilestoneCollectionView.swift # Grid of all milestones
├── HapticManager.swift          # Celebration haptics (optional)
└── ShareableMilestoneCard.swift # Achievement share card (optional)
```

### Integration Steps

**Trigger celebration on threshold:**
```swift
struct WorkoutCompleteView: View {
    @State private var tracker = MilestoneTracker()
    @State private var celebratingMilestone: Milestone?

    var body: some View {
        VStack {
            // ... workout summary content ...

            Button("Save Workout") {
                saveWorkout()
                let newCount = totalWorkouts + 1
                if let milestone = tracker.checkThreshold(value: newCount, category: .workouts) {
                    celebratingMilestone = milestone
                }
            }
        }
        .overlay {
            if let milestone = celebratingMilestone {
                CelebrationOverlay(milestone: milestone) {
                    celebratingMilestone = nil
                }
            }
        }
    }
}
```

**Badge collection screen:**
```swift
struct ProfileView: View {
    @State private var tracker = MilestoneTracker()

    var body: some View {
        NavigationStack {
            ScrollView {
                MilestoneCollectionView(
                    milestones: tracker.allMilestones,
                    columns: 3
                )
            }
            .navigationTitle("Achievements")
        }
    }
}
```

**Share an achievement:**
```swift
struct MilestoneDetailView: View {
    let milestone: Milestone
    @State private var showShareCard = false

    var body: some View {
        VStack {
            MilestoneBadgeView(milestone: milestone, size: .large)
            Text(milestone.title).font(.title2.bold())
            Text(milestone.milestoneDescription).foregroundStyle(.secondary)

            if milestone.isUnlocked {
                Button("Share Achievement") {
                    showShareCard = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showShareCard) {
            ShareableMilestoneCard(milestone: milestone, brandName: "FitApp")
        }
    }
}
```

### Testing

```swift
@Test
func milestoneUnlocksAtThreshold() {
    let tracker = MilestoneTracker(store: InMemoryMilestoneStore())
    let milestone = Milestone(
        id: "first-10",
        title: "First 10",
        milestoneDescription: "Complete 10 workouts",
        threshold: 10,
        iconName: "flame.fill"
    )
    tracker.register(milestone)

    let result = tracker.checkThreshold(value: 10, for: milestone.id)
    #expect(result != nil)
    #expect(result?.isUnlocked == true)
    #expect(result?.unlockedDate != nil)
}

@Test
func milestoneDoesNotUnlockBelowThreshold() {
    let tracker = MilestoneTracker(store: InMemoryMilestoneStore())
    let milestone = Milestone(
        id: "first-10",
        title: "First 10",
        milestoneDescription: "Complete 10 workouts",
        threshold: 10,
        iconName: "flame.fill"
    )
    tracker.register(milestone)

    let result = tracker.checkThreshold(value: 9, for: milestone.id)
    #expect(result == nil)
}

@Test
func confettiRespectsReduceMotion() {
    // When Reduce Motion is enabled, ConfettiView should not emit particles
    let config = ConfettiConfiguration(reduceMotionOverride: true)
    #expect(config.shouldAnimate == false)
}

@Test
func celebrationOverlayAutoDismisses() async throws {
    // Verify overlay dismisses after the configured duration
    let expectation = XCTestExpectation(description: "Dismissed")
    let duration: TimeInterval = 0.5
    // Test that the onDismiss callback fires after duration
}
```

## Common Patterns

### Trigger Celebration on Threshold
Best for: fitness, learning, productivity apps.
- Define milestones with numeric thresholds (10 workouts, 100 pages read, 7-day streak)
- `MilestoneTracker` checks values against registered milestones
- Celebration fires only on the first crossing — subsequent calls are no-ops
- Persist unlock state so celebrations do not repeat

### Badge Collection View
Best for: gamification, loyalty, progression systems.
- Grid of all milestones: locked ones are dimmed/grayscale, unlocked ones are vibrant
- Progress ring shows how close user is to unlocking each badge
- Tapping a badge shows detail view with full description and share option
- Counter showing "12 of 20 unlocked" at the top

### Share Achievement
Best for: social apps, fitness, competitions.
- Render the unlocked badge + title + metric as a shareable image
- Use `ImageRenderer` at `@2x` scale for Retina quality
- Include app branding and optional QR code for deep linking
- Integrate with `ShareLink` for native share sheet

## Gotchas

### CAEmitterLayer Performance on Older Devices
- Confetti with many particles (200+) can drop frames on A11 and older chips
- Cap `birthRate` at 50-80 for smooth 60fps on most devices
- Use `emitterCells` with only 3-5 distinct shapes to reduce GPU draw calls
- Stop emission after burst duration — do not leave the emitter running indefinitely
- Profile with Instruments (Core Animation template) if users report frame drops

### Reduce Motion Accessibility
- Always check `UIAccessibility.isReduceMotionEnabled` before starting particle animations
- When Reduce Motion is on: skip confetti, show a static badge reveal or a simple fade-in instead
- Use `@Environment(\.accessibilityReduceMotion)` in SwiftUI for reactive updates
- Provide an equally rewarding experience without animation — the badge reveal and message still appear

### Haptic Feedback on Non-Supporting Devices
- `UINotificationFeedbackGenerator` is a no-op on devices without a Taptic Engine (e.g., iPod touch, iPad)
- Always guard with `CHHapticEngine.capabilitiesForHardware().supportsHaptics` before preparing generators
- On macOS, haptics are not available — gate with `#if canImport(UIKit)` and `#if os(iOS)`
- Use `.sensoryFeedback(.success, trigger:)` modifier on iOS 17+ for a simpler SwiftUI-native approach

### Sound Effect Considerations
- Use `AudioServicesPlaySystemSound` for lightweight celebration sounds (no audio session needed)
- Respect the device silent/mute switch — `AudioServicesPlaySystemSound` honors it automatically
- For custom sounds, keep files under 30 seconds and use CAF or WAV format
- Do not play sounds when Reduce Motion is enabled (some users enable it for sensory reasons)

### Persistence Edge Cases
- If the app is terminated between unlocking a milestone and persisting it, the user may see the celebration again
- Use `UserDefaults` for simple unlock flags or a lightweight JSON file for full milestone state
- For `SwiftData` or `CoreData` apps, consider storing unlock state alongside the user's data model
- Sync unlock state via CloudKit if the app supports multiple devices

### App Store Guidelines
- **Guideline 4.5.4**: Milestone-announcement pushes ("you're 1 away from a badge!") are promotional — explicit opt-in consent and an in-app opt-out are required.
- **Guideline 2.3.1**: Screenshots showing badges and achievements must reflect what the app actually awards — aspirational metadata is a rejection risk.
- **Guideline 4.3 (Spam)**: Celebrations don't differentiate a thin app. If this is one of several similar apps on your account, run `app-store/originality-check` before submitting.

## References

- **templates.md** — All production Swift templates
- Related: `generators/streak-tracker` — Streak tracking pairs naturally with milestone celebrations
- Related: `generators/share-card` — Shareable achievement card rendering and social sharing
- Related: `generators/variable-rewards` — Variable reward schedules for deeper engagement

### Source: `generators/networking-layer`

# Networking Layer Generator

Generate a modern, protocol-based networking layer using Swift's async/await concurrency, with proper error handling and easy testability.

## When This Skill Activates

Use this skill when the user:
- Asks to "add networking" or "create API client"
- Mentions "HTTP layer" or "REST API"
- Wants to "fetch data from API"
- Asks about "URLSession wrapper" or "network requests"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (async/await requires Swift 5.5+)
- [ ] Check deployment target (async/await requires iOS 15+ / macOS 12+)
- [ ] Search for existing networking implementations
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing networking:
```
Glob: **/*API*.swift, **/*Network*.swift, **/*Client*.swift
Grep: "URLSession" or "HTTPURLResponse"
```

If found, ask user:
- Replace existing implementation?
- Extend with new endpoints?

## Configuration Questions

Ask user via AskUserQuestion:

1. **Authentication type?**
   - Bearer token
   - API key (header or query param)
   - None
   - Custom

2. **Base URL configuration?**
   - Single environment
   - Multiple environments (dev/staging/prod)

3. **Additional features?**
   - Retry logic with exponential backoff
   - Request/response logging
   - Caching

## Generation Process

### Step 1: Create Core Files

Generate these files:
1. `APIClient.swift` - Protocol and implementation
2. `APIEndpoint.swift` - Endpoint definition protocol
3. `NetworkError.swift` - Typed errors
4. `APIConfiguration.swift` - Base URL and auth config

### Step 2: Optional Files

Based on configuration:
- `RetryPolicy.swift` - If retry logic selected
- `NetworkLogger.swift` - If logging selected

### Step 3: Determine File Location

Check project structure:
- If `Sources/` exists → `Sources/Networking/`
- If `App/` exists → `App/Networking/`
- Otherwise → `Networking/`

## Swift 6.2 Concurrency Notes

Reference: Apple's Swift Concurrency Updates

### @concurrent for Background Work
Use `@concurrent` to offload heavy processing:
```swift
@concurrent
static func parseResponse<T: Decodable>(_ data: Data) async throws -> T {
    try JSONDecoder().decode(T.self, from: data)
}
```

### MainActor for UI Updates
Keep UI-related code on MainActor:
```swift
@Observable
@MainActor
final class NetworkViewModel {
    var items: [Item] = []

    func fetch() async {
        items = try await apiClient.fetch(ItemsEndpoint())
    }
}
```

## Output Format

After generation, provide:

### Files Created
```
Sources/Networking/
├── APIClient.swift           # Protocol + URLSession implementation
├── APIEndpoint.swift         # Endpoint protocol
├── NetworkError.swift        # Error types
├── APIConfiguration.swift    # Config (base URL, auth)
└── Endpoints/                # Example endpoints
    └── ExampleEndpoint.swift
```

### Integration Steps

**Define an Endpoint:**
```swift
struct UsersEndpoint: APIEndpoint {
    typealias Response = [User]

    var path: String { "/users" }
    var method: HTTPMethod { .get }
}
```

**Make a Request:**
```swift
let client = URLSessionAPIClient(configuration: .production)
let users = try await client.request(UsersEndpoint())
```

**With SwiftUI:**
```swift
struct UsersView: View {
    @State private var users: [User] = []
    @Environment(\.apiClient) private var apiClient

    var body: some View {
        List(users) { user in
            Text(user.name)
        }
        .task {
            users = try await apiClient.request(UsersEndpoint())
        }
    }
}
```

### Testing

Use `MockAPIClient` for tests:
```swift
let mockClient = MockAPIClient()
mockClient.mockResponse(for: UsersEndpoint.self, response: [User.mock])

let viewModel = UsersViewModel(apiClient: mockClient)
await viewModel.fetch()

XCTAssertEqual(viewModel.users.count, 1)
```

## References

- **networking-patterns.md** - Architecture patterns and best practices
- **templates/** - All template files
- Apple Docs: Swift Concurrency Updates (Swift 6.2)

### Source: `generators/offer-codes-setup`

# Offer Codes Setup Generator

Generate offer code distribution strategies, configuration guides, and campaign templates for promoting subscriptions and IAPs through redeemable codes.

## When This Skill Activates

Use this skill when the user:
- Asks about "offer codes" or "promo codes" for subscriptions
- Wants to distribute free/discounted subscriptions to partners or influencers
- Mentions "redemption codes" or "App Store codes"
- Asks about re-engaging users via email with promotional codes
- Wants to set up influencer or reviewer programs

## How Offer Codes Work

- Create in **App Store Connect** under Subscriptions > Offer Codes
- Up to **10 active offers per subscription** SKU
- Two types: **one-time use codes** (generated in batches of 500–25,000) and **custom codes** (reusable, up to 64 characters, no special characters, redemption limit up to 25,000 per code)
- One redemption per customer per offer
- Quarterly ceiling: **1,000,000 codes per app per quarter** — raised from the old 150,000, and now spanning subscriptions + one-time IAP combined (per WWDC25). Sandbox: 10,000 codes/app/quarter, with unlimited redemptions per sandbox account
- Beyond subscriptions, codes now cover **consumables, non-consumables, and non-renewing subscriptions**, with campaign eligibility criteria (never purchased / purchased but not in the last 30 days / purchased in the last 30 days) and auto-install of the app on redemption if it's absent (WWDC25)
- Offer applies the configured discount (free period, discounted rate, etc.)
- Expiry is configurable from 1 day to 6 months — one-time codes auto-expire at 6 months. Print the expiry date in every marketing asset

### Code Types
| Type | Description | Best For |
|------|-------------|----------|
| One-time use | Unique codes, each used once | Email campaigns, individual distribution |
| Custom codes | Reusable keyword codes (e.g., "LAUNCH2025"), ≤64 chars | Social media, events, partnerships |

### Redemption Methods
1. **In your app** via `AppStore.presentOfferCodeRedeemSheet()` — preferred: your app stays in the foreground, so put a "Redeem Code" button on the paywall
2. **Direct URL**: `https://apps.apple.com/redeem?ctx=offercodes&id=APPID&code=CODE` — ideal for QR codes and email; state the minimum iOS version in marketing materials
3. **App Store > Account > Redeem Gift Card or Code**

## Configuration Questions

Ask user via AskUserQuestion:

1. **Distribution purpose?**
   - Influencer/reviewer program (free access for promotion)
   - Partner distribution (B2B or affiliate)
   - Email re-engagement (win-back lapsed users)
   - Event/conference distribution (in-person)
   - Social media promotion (public campaign)

2. **Offer type?**
   - Free subscription period (1 week, 1 month, 3 months)
   - Discounted first period
   - Extended free trial

3. **Scale?**
   - Small (< 100 codes, targeted distribution)
   - Medium (100-1,000 codes, campaign-based)
   - Large (1,000+ codes, broad distribution)

## Generation Process

### Step 1: Design Campaign Strategy

Based on the distribution purpose, design:
- Target audience and outreach plan
- Code type (one-time vs. custom)
- Offer duration and terms
- Distribution channel and messaging
- Tracking and measurement plan

### Step 2: Generate Campaign Document

## Output Format

```markdown
# Offer Code Campaign: [Campaign Name]

## Campaign Overview
| Field | Value |
|-------|-------|
| Purpose | [Distribution purpose] |
| Target Audience | [Who receives codes] |
| Code Type | [One-time / Custom] |
| Offer | [Free X months / Y% off first period] |
| Total Codes | [Number] |
| Distribution Period | [Date range] |
| Code Expiration | [Date] |

## App Store Connect Setup

1. Go to App Store Connect > Subscriptions > [Group] > [Subscription]
2. Navigate to "Offer Codes" tab
3. Create new offer:
   - Offer type: [Free / Pay as you go / Pay up front]
   - Duration: [X weeks/months]
   - Pricing: [If discounted, specify tier]
4. Generate codes:
   - Type: [One-time use / Custom code]
   - Quantity: [Number]
   - Custom code name: [If custom, e.g., "LAUNCH2025"]
   - Expiration: [Date]
5. Download codes CSV (for one-time codes)

## Distribution Plan

### Channel: [Channel Name]
- **Recipients**: [Who gets codes and how many]
- **Delivery method**: [Email / DM / QR code / Link]
- **Message template**: [See below]
- **Tracking**: [How to measure redemption]

### Message Template

#### For Influencers/Reviewers
Subject: [App Name] — Complimentary Pro Access

> Hi [Name],
>
> I'd love to offer you complimentary Pro access to [App Name] — [one-line description].
>
> Your personal code: **[CODE]**
>
> Redeem: Open the App Store → Account → Redeem Gift Card or Code → Enter code
> Or direct link: [redemption URL]
>
> This gives you [offer details — e.g., 3 months free Pro].
>
> If you enjoy the app, we'd love an honest review or mention. No obligation at all.
>
> Best,
> [Your name]

#### For Email Re-engagement
Subject: We've missed you — here's [X] free on us

> Hi [Name],
>
> It's been a while since you've used [App Name], and we've been busy making it better.
>
> Here's what's new:
> - [Feature 1]
> - [Feature 2]
> - [Feature 3]
>
> We'd love for you to come back and try it. Here's a code for [offer details]:
>
> **[CODE]**
>
> [Redemption instructions or direct link]
>
> This code expires [date].
>
> Welcome back,
> [Your name / App name]

#### For Social Media (Custom Code)
> [Emoji] Special offer! Use code **[CUSTOMCODE]** in the App Store to get
> [offer details] of [App Name] completely free.
>
> Redeem: [Link]
>
> Limited time — expires [date]. [Emoji]

## In-App Redemption

### Add Code Entry to Your App

```swift
import StoreKit

struct SettingsView: View {
    var body: some View {
        Button("Redeem Offer Code") {
            Task {
                try? await AppStore.presentOfferCodeRedeemSheet()
            }
        }
    }
}
```

## Measurement

| Metric | How to Track |
|--------|-------------|
| Codes distributed | Your distribution records |
| Codes redeemed | App Store Connect > Offer Codes (redemptions report) |
| Per-campaign attribution | `offer_code_reference_name` in transactions + `OFFER_REDEEMED` server notification |
| Redemption rate | Redeemed / Distributed |
| Post-offer retention | Retained after offer period ends |
| Conversion to paid | Continued subscription after offer |

## Campaign Calendar

| Month | Campaign | Codes | Channel |
|-------|----------|-------|---------|
| [Month] | [Campaign name] | [Count] | [Channel] |
```

## Distribution Strategies by Purpose

### Influencer Program
- **Scale**: 10-50 codes per quarter
- **Code type**: One-time use (track individual redemption)
- **Offer**: 3-6 months free (generous for genuine feedback)
- **Follow-up**: Request honest review 2 weeks after redemption
- **Tracking**: Spreadsheet mapping code → influencer → outcome

### Partner/Affiliate
- **Scale**: 100-1,000 codes per partner
- **Code type**: Custom code per partner ("PARTNER2025")
- **Offer**: 1-3 months free
- **Terms**: Clear agreement on promotion expectations
- **Tracking**: Unique custom code per partner for attribution

### Email Re-Engagement
- **Scale**: Match churned user count
- **Code type**: One-time use (unique per user)
- **Offer**: 1 month free (low barrier to return)
- **Timing**: 30-60 days after churn
- **Tracking**: Email open → Redemption → Retention

### Event/Conference
- **Scale**: Match expected attendees
- **Code type**: Custom code ("WWDC2025")
- **Offer**: 1-3 months free
- **Distribution**: QR code on slides/booth, printed cards
- **Tracking**: Post-event redemption monitoring

## Gotchas

- **Intro-offer stacking order is locked at creation** — whether a code redeems before or after the introductory offer can NEVER be changed later
- **Treat any code that leaves your systems as spent** — unredeemed codes can't be recovered or reissued
- **Never let a code land an active subscriber on a lower tier** — exclude current subscribers from campaigns priced below their plan
- **Listen on `Transaction.updates` from launch** — redemptions happen outside your app (App Store, URL), so entitlements arrive asynchronously

## References

- Related: `generators/subscription-offers` — StoreKit 2 offer implementation
- Related: `generators/win-back-offers` — Win-back campaign strategy
- Related: `app-store/marketing-strategy` — Overall promotional strategy

### Source: `generators/offline-queue`

# Offline Queue Generator

Generate a production offline operation queue that persists API requests/mutations when offline, stores them to disk, and retries with exponential backoff when connectivity returns. Essential for apps that need offline-first behavior.

## When This Skill Activates

Use this skill when the user:
- Asks to "add offline queue" or "offline support"
- Wants to "queue requests" when there is no network
- Mentions "offline first" architecture or design
- Asks about "retry when online" or "retry on reconnect"
- Wants "pending operations" that sync later
- Mentions "offline mutations" or "queue API calls"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing networking/offline code:
```
Glob: **/*OfflineQueue*.swift, **/*OfflineOperation*.swift, **/*NetworkMonitor*.swift, **/*RetryPolicy*.swift
Grep: "NWPathMonitor" or "OfflineQueue" or "pendingOperations" or "offlineQueue"
```

If existing offline handling found:
- Ask if user wants to replace or extend it
- If extending, adapt generated code to existing patterns

### 3. Framework Availability
Check for Network framework availability (required for NWPathMonitor). Available on iOS 12+ / macOS 10.14+, so effectively always available for our iOS 16+ / macOS 13+ targets.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Operation types?**
   - API calls only (JSON requests/responses)
   - File uploads only (multipart data)
   - Both API calls and file uploads

2. **Persistence strategy?**
   - SwiftData (iOS 17+ / macOS 14+) — structured queries, migration support
   - File-based (JSON files in app support) — simpler, wider compatibility — recommended

3. **Retry strategy?**
   - Exponential backoff with jitter — recommended (prevents thundering herd)
   - Linear backoff (fixed interval between retries)
   - Immediate (retry as soon as connectivity returns, no delay)

4. **Conflict resolution?**
   - Server wins (discard client changes on conflict)
   - Client wins (overwrite server data on conflict)
   - Manual merge (surface conflicts to the user for resolution)

## Generation Process

### Step 1: Read Templates
Read `patterns.md` for architecture guidance and conflict resolution strategies.
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `OfflineOperation.swift` — Codable model for queued operations
2. `OfflineQueueManager.swift` — Actor managing enqueue, dequeue, process, retry
3. `QueuePersistence.swift` — Protocol + file-based implementation for saving operations
4. `NetworkMonitor.swift` — @Observable wrapper around NWPathMonitor

### Step 3: Create Policy Files
5. `RetryPolicy.swift` — Configurable backoff strategy with jitter

### Step 4: Create UI Files
6. `OfflineQueueDashboardView.swift` — Debug view showing queue state and manual controls
7. `OfflineQueueModifier.swift` — ViewModifier showing "Offline" banner when disconnected

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists → `Sources/OfflineQueue/`
- If `App/` exists → `App/OfflineQueue/`
- Otherwise → `OfflineQueue/`

## Output Format

After generation, provide:

### Files Created
```
OfflineQueue/
├── OfflineOperation.swift          # Codable operation model
├── OfflineQueueManager.swift       # Actor-based queue manager
├── QueuePersistence.swift          # Protocol + file-based persistence
├── NetworkMonitor.swift            # NWPathMonitor wrapper
├── RetryPolicy.swift               # Exponential backoff with jitter
├── OfflineQueueDashboardView.swift # Debug dashboard view
└── OfflineQueueModifier.swift      # Offline banner modifier
```

### Integration with Networking Layer

**Enqueue an operation when offline:**
```swift
// In your networking layer or repository
func createPost(_ post: Post) async throws {
    guard networkMonitor.isConnected else {
        let operation = OfflineOperation(
            endpoint: "/api/posts",
            httpMethod: .post,
            body: try JSONEncoder().encode(post),
            headers: ["Content-Type": "application/json"]
        )
        await queueManager.enqueue(operation)
        return
    }
    // Normal online request
    try await apiClient.post("/api/posts", body: post)
}
```

**Transparent offline support with a wrapper:**
```swift
func performOrQueue<T: Codable>(
    endpoint: String,
    method: HTTPMethod,
    body: T
) async throws {
    let data = try JSONEncoder().encode(body)

    if networkMonitor.isConnected {
        try await apiClient.request(endpoint: endpoint, method: method, body: data)
    } else {
        let operation = OfflineOperation(
            endpoint: endpoint,
            httpMethod: method,
            body: data
        )
        await queueManager.enqueue(operation)
    }
}
```

**Show offline banner in your app:**
```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            FeedView()
        }
        .offlineQueueBanner()  // Shows "Offline — changes will sync" when disconnected
    }
}
```

**Add dashboard for debugging:**
```swift
#if DEBUG
NavigationLink("Offline Queue") {
    OfflineQueueDashboardView()
}
#endif
```

### Testing

```swift
@Test
func operationEnqueuedWhenOffline() async throws {
    let persistence = MockQueuePersistence()
    let monitor = MockNetworkMonitor(isConnected: false)
    let manager = OfflineQueueManager(persistence: persistence, monitor: monitor)

    let operation = OfflineOperation(
        endpoint: "/api/posts",
        httpMethod: .post,
        body: Data("{\"title\":\"Hello\"}".utf8)
    )
    await manager.enqueue(operation)

    let pending = await persistence.loadAll()
    #expect(pending.count == 1)
    #expect(pending.first?.endpoint == "/api/posts")
}

@Test
func operationsProcessedOnReconnect() async throws {
    let persistence = MockQueuePersistence()
    let monitor = MockNetworkMonitor(isConnected: false)
    let executor = MockOperationExecutor()
    let manager = OfflineQueueManager(
        persistence: persistence,
        monitor: monitor,
        executor: executor
    )

    let operation = OfflineOperation(
        endpoint: "/api/posts",
        httpMethod: .post,
        body: Data("{\"title\":\"Hello\"}".utf8)
    )
    await manager.enqueue(operation)

    // Simulate coming back online
    monitor.simulateConnectivityChange(isConnected: true)

    // Wait for processing
    try await Task.sleep(for: .milliseconds(200))

    #expect(executor.executedOperations.count == 1)
    let remaining = await persistence.loadAll()
    #expect(remaining.isEmpty)
}

@Test
func exponentialBackoffCalculation() {
    let policy = RetryPolicy(
        maxRetries: 5,
        baseDelay: 1.0,
        maxDelay: 60.0,
        multiplier: 2.0
    )

    #expect(policy.delay(forAttempt: 0) >= 1.0)
    #expect(policy.delay(forAttempt: 1) >= 2.0)
    #expect(policy.delay(forAttempt: 2) >= 4.0)
    #expect(policy.delay(forAttempt: 5) <= 60.0)  // Capped at maxDelay
}
```

## Common Patterns

### Enqueue Operation
```swift
let operation = OfflineOperation(
    endpoint: "/api/comments",
    httpMethod: .post,
    body: try JSONEncoder().encode(comment),
    headers: ["Authorization": "Bearer \(token)"]
)
await queueManager.enqueue(operation)
```

### Process Queue on Connectivity
```swift
// Automatic — OfflineQueueManager observes NetworkMonitor
// and calls processQueue() when connectivity returns.
// No manual intervention needed.
```

### Handle Conflict Resolution
```swift
// Server returns 409 Conflict
switch conflictStrategy {
case .serverWins:
    // Discard local operation, fetch server state
    await queueManager.markCompleted(operation)
case .clientWins:
    // Retry with force flag
    operation.headers["X-Force-Overwrite"] = "true"
    await queueManager.retry(operation)
case .manualMerge:
    // Surface to user
    await queueManager.markConflict(operation, serverData: responseData)
}
```

## Gotchas

### Operation Ordering and Dependencies
Operations may have dependencies (e.g., "create parent" must succeed before "create child"). The queue processes in FIFO order by default. For explicit dependencies, use the `dependsOn` field to chain operations, and the queue manager will skip dependent operations until their prerequisites complete.

### Idempotency Keys
Every queued operation gets a UUID-based idempotency key. The server must check this key to avoid duplicate processing if the client retries an operation that actually succeeded but the response was lost. Without idempotency keys, a retry could create duplicate records.

### Stale Data After Long Offline Periods
If the device is offline for hours or days, queued operations may reference data that has changed server-side. Consider adding a TTL to operations (e.g., 24 hours) and discarding expired operations with a user notification rather than blindly replaying stale mutations.

### Background URLSession for Large Uploads
For file uploads, use a background `URLSession` configuration so uploads continue even when the app is suspended. The standard queue manager handles JSON API calls; for large uploads, delegate to a background transfer service.

### Queue Size Limits
Set a maximum queue size (e.g., 500 operations or 50 MB) to prevent unbounded growth. When the limit is reached, notify the user that offline storage is full and suggest connecting to sync pending changes.

## References

- **templates.md** — All production Swift templates
- **patterns.md** — Offline-first architecture, conflict resolution, idempotency
- Related: `generators/networking-layer` — Base networking layer to wrap with offline support
- Related: `generators/http-cache` — Cache GET responses for offline reading

### Source: `generators/pagination`

# Pagination Generator

Generate production pagination infrastructure supporting offset-based and cursor-based APIs, with infinite scroll SwiftUI views, state machine management, and optional search integration.

## When This Skill Activates

Use this skill when the user:
- Asks to "add pagination" or "paginate a list"
- Wants "infinite scroll" or "load more" functionality
- Mentions "cursor-based pagination" or "offset pagination"
- Asks about "paginated API" or "loading pages of data"
- Wants "search with pagination"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 17+ / macOS 14+ for @Observable)
- [ ] Search for existing pagination implementations
- [ ] Identify source file locations

### 2. Networking Layer Detection
Search for existing networking code:
```
Glob: **/*API*.swift, **/*Client*.swift, **/*Endpoint*.swift
Grep: "APIClient" or "APIEndpoint"
```

If `networking-layer` generator was used, detect the `APIEndpoint` protocol and generate data sources that conform to it.

### 3. Conflict Detection
Search for existing pagination:
```
Glob: **/*Pagina*.swift, **/*LoadMore*.swift
Grep: "PaginationState" or "loadNextPage" or "hasMorePages"
```

If found, ask user whether to replace or extend.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Pagination style?**
   - Offset-based (page number + page size) — most common for REST APIs
   - Cursor-based (opaque cursor token) — better for real-time data, social feeds

2. **Loading trigger?**
   - Infinite scroll (auto-load when near bottom) — recommended
   - Manual "Load More" button
   - Both (infinite scroll with manual fallback on error)

3. **Additional features?** (multi-select)
   - Search with pagination (debounced, resets on query change)
   - Pull-to-refresh
   - Empty/error/loading state views

4. **Data source pattern?**
   - Generic (works with any Codable model)
   - Protocol-based (define per-endpoint data sources)

## Generation Process

### Step 1: Read Templates
Read `pagination-patterns.md` for architecture guidance.
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `PaginatedResponse.swift` — Generic response models for offset and cursor
2. `PaginationState.swift` — State machine (idle, loading, loaded, error, exhausted)
3. `PaginatedDataSource.swift` — Protocol endpoints conform to
4. `PaginationManager.swift` — @Observable manager with state transitions

### Step 3: Create Optional Files
Based on configuration:
- `SearchablePaginationManager.swift` — If search selected
- `Views/PaginatedList.swift` — Infinite scroll SwiftUI wrapper
- `Views/LoadMoreButton.swift` — Manual load-more button
- `Views/PaginationStateView.swift` — Empty/loading/error state views

### Step 4: Determine File Location
Check project structure:
- If `Sources/` exists → `Sources/Pagination/`
- If `App/` exists → `App/Pagination/`
- Otherwise → `Pagination/`

## Output Format

After generation, provide:

### Files Created
```
Pagination/
├── PaginatedResponse.swift           # Generic response models
├── PaginationState.swift             # State machine enum
├── PaginatedDataSource.swift         # Data source protocol
├── PaginationManager.swift           # @Observable manager
├── SearchablePaginationManager.swift # Optional: search + pagination
└── Views/
    ├── PaginatedList.swift           # Infinite scroll wrapper
    ├── LoadMoreButton.swift          # Manual load-more
    └── PaginationStateView.swift     # Empty/loading/error states
```

### Integration Steps

**Define a data source:**
```swift
struct UsersDataSource: PaginatedDataSource {
    typealias Item = User

    let apiClient: APIClient

    func fetch(page: PageRequest) async throws -> PaginatedResponse<User> {
        try await apiClient.request(UsersEndpoint(page: page.page, size: page.size))
    }
}
```

**Use PaginationManager in a view model:**
```swift
@Observable
final class UsersViewModel {
    let pagination: PaginationManager<UsersDataSource>

    init(apiClient: APIClient) {
        pagination = PaginationManager(
            dataSource: UsersDataSource(apiClient: apiClient)
        )
    }
}
```

**With SwiftUI (infinite scroll):**
```swift
struct UsersListView: View {
    @State private var viewModel = UsersViewModel()

    var body: some View {
        PaginatedList(manager: viewModel.pagination) { user in
            UserRow(user: user)
        }
        .task {
            await viewModel.pagination.loadFirstPage()
        }
    }
}
```

**With search:**
```swift
struct SearchableUsersView: View {
    @State private var searchManager = SearchablePaginationManager(
        dataSource: UsersDataSource()
    )

    var body: some View {
        PaginatedList(manager: searchManager.pagination) { user in
            UserRow(user: user)
        }
        .searchable(text: $searchManager.query)
    }
}
```

### Testing

```swift
@Test
func loadFirstPagePopulatesItems() async throws {
    let mockSource = MockDataSource(items: User.mockList(count: 20))
    let manager = PaginationManager(dataSource: mockSource, pageSize: 10)

    await manager.loadFirstPage()

    #expect(manager.items.count == 10)
    #expect(manager.state == .loaded)
    #expect(manager.hasMore == true)
}

@Test
func loadAllPagesReachesExhausted() async throws {
    let mockSource = MockDataSource(items: User.mockList(count: 15))
    let manager = PaginationManager(dataSource: mockSource, pageSize: 10)

    await manager.loadFirstPage()
    await manager.loadNextPage()

    #expect(manager.items.count == 15)
    #expect(manager.state == .exhausted)
}
```

## References

- **pagination-patterns.md** — Offset vs cursor comparison, state machine, threshold prefetching
- **templates.md** — All production Swift templates
- Related: `generators/networking-layer` — Base networking layer for data sources
- Related: `generators/http-cache` — Cache paginated responses

### Source: `generators/paywall-generator`

# Paywall Generator

Generate a complete StoreKit 2 subscription paywall with modern SwiftUI views, subscription status tracking, and proper purchase handling.

## When This Skill Activates

Use this skill when the user:
- Asks to "add subscriptions" or "add paywall"
- Mentions "in-app purchases" or "IAP"
- Wants "StoreKit 2" implementation
- Asks about "subscription management"
- Mentions "premium features" or "pro version"

## Paywall Design Principles (Apple's Data)

- **Keep sign-up to 3-4 taps.** Per Apple's Tech Talk: 61% conversion at 3 taps, 48% at 4 — collapsing to 7% at 9 taps.
- **Make the paywall glanceable** — value proposition, price, and renewal/trial terms in one view, no scrolling to find the price.
- **Show clear renewal and trial terms everywhere you pitch** the subscription, not just on the paywall.
- **Persistent entry point over pop-ups** — a tasteful, always-available subscribe button (plus subscribe/manage in Settings). Pop-ups train users to dismiss.
- **Trigger the offer at moments of interest** — when the user taps locked content, not on a timer.
- **Offer 3-4 duration tiers** so users self-select their commitment level.
- **Let users experience value first** — free trial (works best for known brands), freemium, or content sampling (e.g., N free articles per month).

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check for existing StoreKit implementations
- [ ] Check deployment target (StoreKit 2 requires iOS 15+)
- [ ] Look for existing product IDs in codebase
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing StoreKit:
```
Glob: **/*Store*.swift, **/*Purchase*.swift, **/*Subscription*.swift
Grep: "import StoreKit" or "Product.products"
```

If found, ask user:
- Replace existing implementation?
- Extend with additional features?

## Apple Docs Reference

**StoreKit subscription APIs (iOS 18.4+):**
- `SubscriptionOfferView` - New SwiftUI view for merchandising subscriptions
- `subscriptionStatusTask` modifier for tracking subscription state
- `Transaction.currentEntitlements(for:)` - per-product entitlement check (iOS 18.4+)
- `RenewalInfo` enhancements for expiration reasons

## Configuration Questions

Ask user via AskUserQuestion:

1. **Subscription tiers?** (multi-select)
   - Monthly
   - Yearly (with discount)
   - Lifetime
   - Weekly

2. **Features needed?**
   - Free trial
   - Family sharing
   - Promotional offers

3. **UI style?**
   - Full paywall screen
   - Inline subscription view
   - Both

## Generation Process

### Step 1: Create Core Files

Generate these files:
1. `StoreKitManager.swift` - Product loading and purchasing
2. `SubscriptionStatus.swift` - Status tracking
3. `PaywallView.swift` - Full paywall UI
4. `SubscriptionButton.swift` - Individual plan button

### Step 2: Create Configuration

- `Products.swift` - Product ID constants

### Step 3: Determine File Location

Check project structure:
- If `Sources/` exists → `Sources/Store/`
- If `App/` exists → `App/Store/`
- Otherwise → `Store/`

## Product ID Setup

### App Store Connect

1. Go to App Store Connect > Your App > Subscriptions
2. Create subscription group
3. Add subscription products with IDs like:
   - `com.yourapp.subscription.monthly`
   - `com.yourapp.subscription.yearly`
   - `com.yourapp.subscription.lifetime`

### StoreKit Configuration (Testing)

Create `Products.storekit` for local testing:
1. File > New > File > StoreKit Configuration
2. Add products matching your IDs
3. Edit scheme > Options > StoreKit Configuration

## Output Format

After generation, provide:

### Files Created
```
Sources/Store/
├── StoreKitManager.swift        # Product loading & purchasing
├── SubscriptionStatus.swift     # Status enum & tracking
├── Products.swift               # Product ID constants
└── Views/
    ├── PaywallView.swift        # Full paywall screen
    ├── SubscriptionButton.swift # Plan selection button
    └── SubscriptionOfferCard.swift # iOS 18.4+ view
```

### Integration Steps

**App Entry Point:**
```swift
@main
struct MyApp: App {
    @State private var subscriptionStatus: SubscriptionStatus = .unknown

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.subscriptionStatus, subscriptionStatus)
                .subscriptionStatusTask(for: "your.group.id") { statuses in
                    subscriptionStatus = SubscriptionStatus.from(statuses)
                }
        }
    }
}
```

**Show Paywall:**
```swift
struct ContentView: View {
    @State private var showPaywall = false
    @Environment(\.subscriptionStatus) var status

    var body: some View {
        VStack {
            if status != .subscribed {
                Button("Upgrade to Pro") {
                    showPaywall = true
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
```

**SubscriptionOfferView (iOS 18.4+):**
```swift
// Simple merchandising view
SubscriptionOfferView(productID: "com.app.subscription.monthly")
    .prefersPromotionalIcon(true)
    .subscriptionOfferViewDetailAction {
        showPaywall = true
    }
```

### Testing Instructions

1. **Create StoreKit Configuration:**
   - File > New > StoreKit Configuration
   - Add your products

2. **Edit Scheme:**
   - Product > Scheme > Edit Scheme
   - Options > StoreKit Configuration > Select your file

3. **Test Purchases:**
   - Run in Simulator
   - Use Transaction Manager (Debug > StoreKit > Transaction Manager)

4. **Test Scenarios:**
   - Purchase flow
   - Restore purchases
   - Subscription expiration
   - Renewal

## References

- **storekit-patterns.md** - Best practices and patterns
- **templates/** - All template files
- Apple Docs: StoreKit Updates (iOS 18.4+)

### Source: `generators/persistence-setup`

# Persistence Setup Generator

Generates a production-ready persistence layer using SwiftData (iOS 17+) or CoreData with optional iCloud (CloudKit) sync.

## When This Skill Activates

- User asks to "add persistence" or "set up data storage"
- User mentions "SwiftData", "CoreData", or "local storage"
- User wants to "sync data to iCloud" or "enable cloud sync"
- User asks about "offline storage" or "data models"

## Pre-Generation Checks (CRITICAL)

### 1. Project Context Detection

Before generating, ALWAYS check:

```bash
# Check deployment target
cat Package.swift | grep -i "platform"
# Or check project.pbxproj

# Find existing persistence implementations
rg -l "ModelContainer|NSPersistentContainer|@Model|@Entity" --type swift

# Check for existing SwiftData models
rg "@Model" --type swift | head -5

# Check for CoreData stack
rg "NSManagedObjectContext|NSPersistentStore" --type swift | head -5

# Check existing entitlements for iCloud
cat *.entitlements 2>/dev/null | grep -i "icloud"
```

### 2. Framework Selection

**Use SwiftData if:**
- Deployment target is iOS 17+ / macOS 14+
- User explicitly requests SwiftData
- No existing CoreData implementation

**Use CoreData if:**
- Deployment target < iOS 17
- Existing CoreData stack present
- User explicitly requests CoreData

### 3. Conflict Detection

If existing persistence found:
- Ask: Extend existing, migrate to SwiftData, or create separate?

## Configuration Questions

Ask user via AskUserQuestion:

1. **Framework choice?**
   - SwiftData (iOS 17+, recommended)
   - CoreData (older targets)

2. **Enable iCloud sync?**
   - Yes (requires CloudKit entitlement)
   - No (local only)

3. **Generate example model?**
   - Yes (with sample Item model)
   - No (just infrastructure)

## Generation Process

### Step 1: Create Core Files

**Always generate:**
```
Sources/Persistence/
├── PersistenceController.swift    # Container setup
├── Repository.swift               # Repository protocol
└── SwiftDataRepository.swift      # Concrete implementation
```

**If example model requested:**
```
Sources/Persistence/Models/
└── Item.swift                     # Sample @Model
```

**If iCloud enabled:**
```
Sources/Persistence/CloudSync/
├── CloudKitConfiguration.swift    # Container identifier
└── SyncStatus.swift               # Sync monitoring
```

### Step 2: Read Templates

Read templates from this skill:
- `templates/PersistenceController.swift`
- `templates/Repository.swift`
- `templates/SwiftDataRepository.swift`
- `templates/ExampleModel.swift`
- `templates/CloudKitConfiguration.swift` (if iCloud)
- `templates/SyncStatus.swift` (if iCloud)

### Step 3: Customize for Project

Adapt templates to match:
- Project naming conventions
- Existing model patterns
- Bundle identifier for CloudKit container

### Step 4: Integration

**Basic Integration:**
```swift
@main
struct MyApp: App {
    let container = PersistenceController.shared.container

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
        }
    }
}
```

**With iCloud sync:**
```swift
@main
struct MyApp: App {
    let container = PersistenceController.shared.container

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environment(\.syncStatus, SyncStatus.shared)
        }
    }
}
```

## iCloud Sync Setup

### Required Capabilities (Xcode)

1. **iCloud** capability:
   - Check "CloudKit"
   - Add container: `iCloud.com.yourcompany.yourapp`

2. **Background Modes** (optional, for background sync):
   - Check "Remote notifications"

### Required Entitlements

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.yourcompany.yourapp</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

### CloudKit Dashboard Setup

1. Go to [CloudKit Dashboard](https://icloud.developer.apple.com/)
2. Select your container
3. Schema is auto-created from @Model classes
4. Deploy schema to production before release

## Generated Code Patterns

### Repository Protocol
```swift
protocol Repository<T>: Sendable {
    associatedtype T: PersistentModel

    func fetch(predicate: Predicate<T>?, sortBy: [SortDescriptor<T>]) async throws -> [T]
    func insert(_ item: T) async throws
    func delete(_ item: T) async throws
    func save() async throws
}
```

### SwiftData Model
```swift
@Model
final class Item {
    var title: String
    var timestamp: Date
    var isCompleted: Bool

    init(title: String, timestamp: Date = .now, isCompleted: Bool = false) {
        self.title = title
        self.timestamp = timestamp
        self.isCompleted = isCompleted
    }
}
```

### Container with CloudKit
```swift
let container = try ModelContainer(
    for: Item.self,
    configurations: ModelConfiguration(
        cloudKitDatabase: .private("iCloud.com.yourcompany.yourapp")
    )
)
```

## Verification Checklist

After generation, verify:

- [ ] App launches without crashes
- [ ] Data persists between app launches
- [ ] Models compile without errors
- [ ] (If iCloud) CloudKit container exists in dashboard
- [ ] (If iCloud) Data syncs between devices
- [ ] Repository pattern allows easy testing

## Common Customizations

### Adding New Models
```swift
@Model
final class Project {
    var name: String
    @Relationship(deleteRule: .cascade) var items: [Item]

    init(name: String, items: [Item] = []) {
        self.name = name
        self.items = items
    }
}

// Update container
let container = try ModelContainer(for: Item.self, Project.self)
```

### Custom Fetch Descriptors
```swift
let descriptor = FetchDescriptor<Item>(
    predicate: #Predicate { $0.isCompleted == false },
    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
)
let items = try modelContext.fetch(descriptor)
```

### Migration (SwiftData)
```swift
// SwiftData handles lightweight migrations automatically
// For complex migrations, use VersionedSchema

enum ItemSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [Item.self] }
}
```

## Troubleshooting

### iCloud Sync Not Working

1. **Check entitlements** match CloudKit container
2. **Verify** CloudKit Dashboard shows your container
3. **Check** device is signed into iCloud
4. **Deploy schema** to production if testing on release build

### Data Not Persisting

1. **Verify** `modelContainer` modifier is on root view
2. **Check** `save()` is called after modifications
3. **Look for errors** in Console.app

### CloudKit Quota Exceeded

- Default quota is generous (free tier: 100MB asset storage)
- Consider pruning old data
- Use `cloudKitDatabase: .automatic` for shared containers

## Related Skills

- `networking-layer` - For remote API data alongside local cache
- `settings-screen` - Often uses @AppStorage (simpler persistence)

## References

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Syncing Model Data Across Devices](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices)

### Source: `generators/pre-orders`

# Pre-Orders Generator

Generate pre-order configuration guides, launch timeline templates, and marketing coordination plans for App Store pre-orders.

## When This Skill Activates

Use this skill when the user:
- Asks about "pre-orders" or "App Store pre-order"
- Wants to "build anticipation" before a launch
- Mentions "pre-launch strategy" or "launch countdown"
- Asks about making their app available before release date
- Wants to collect day-one downloads

## How Pre-Orders Work

- Unreleased app: release date can be set up to **180 days** out
- Users can order your app before it's available
- On release day customers are notified and the app **auto-downloads within ~24 hours** — the queue converts itself
- Pre-orders count toward your launch day download numbers
- Your app appears in search and browse during pre-order period
- Price can be set to "Free" or any paid tier during pre-order
- Three edit options stay open anytime: change the date, release immediately, or pull a region; changes propagate within 24 hours

### Key Benefits
1. **Accumulate downloads**: Pre-orders count toward day-one velocity
2. **Search visibility**: App is searchable before release
3. **Featuring eligibility**: Apple can feature pre-order apps
4. **Marketing anchor**: Give audiences a concrete action ("Pre-order now")
5. **A working ASO period**: Custom Product Pages and PPO tests both run during pre-order — launch day should land on an already-tested page

### Not Just for Launches: Regional Pre-Orders

An **existing app** entering new storefronts can run a pre-order in just those territories — with a longer runway: the release date can be up to **365 days** out (vs. 180 for an unreleased app), and any date change is capped at 365 days from when the pre-order first published. Accumulated pre-orders convert on day one in the new market — the same velocity spike a launch gets, aimed at the new market's chart entry.

⚠️ **One-shot per territory**: once released in a region, you can never run a pre-order there again.

### Limitations
- Cannot change app name or primary category after pre-order starts
- Price increases require 7-day notice to pre-order customers
- App must be ready for review before pre-order goes live
- Release date can be moved earlier but not more than 180 days out (365 for a published app's regional pre-order, measured from first publication)
- Once released in a region, a pre-order can never be re-run there

## Configuration Questions

Ask user via AskUserQuestion:

1. **Pre-order reason?**
   - Brand new app launch
   - Major version update (new app listing)
   - Seasonal launch timing (holiday, back to school)
   - WWDC/new OS tie-in

2. **Pre-order duration?**
   - Short (1-2 weeks) — urgency-driven
   - Medium (4-6 weeks) — time to build awareness
   - Long (2-6 months) — major marketing campaign

3. **Pricing strategy?**
   - Free app (maximize pre-orders)
   - Paid at final price
   - Paid with launch discount (raise price after launch week)

## Output Format

```markdown
# Pre-Order Plan: [App Name]

## Configuration

| Setting | Value |
|---------|-------|
| Pre-Order Start | [Date] |
| Release Date | [Date] |
| Pre-Order Duration | [X weeks] |
| Price During Pre-Order | [Free / $X.99] |
| Post-Launch Price | [$X.99] |

## App Store Connect Setup

1. Go to App Store Connect > Your App
2. Under "Pricing and Availability":
   - Set the release date to your planned launch date
   - Enable "Pre-Order" availability
3. Under "App Information":
   - App name, category, and description must be final
   - Screenshots should show the final app (or close to final)
4. Submit app for review:
   - App must pass review before pre-order goes live
   - Prepare a TestFlight-ready build for review

## Launch Timeline

### [X] Weeks Before Launch: Pre-Order Goes Live
- [ ] Submit app for App Store review
- [ ] Prepare pre-order announcement
- [ ] Schedule social media posts
- [ ] Send press kit to media contacts
- [ ] Configure In-App Event for launch day

### [X-2] Weeks Before: Build Anticipation
- [ ] Share development updates/behind-the-scenes
- [ ] Release app preview video on social channels
- [ ] Follow up with press contacts
- [ ] Share pre-order link in email newsletter

### 1 Week Before: Final Push
- [ ] Countdown posts on social media
- [ ] Featuring nomination follow-up
- [ ] Prepare launch day communications
- [ ] Verify build is ready for release

### Launch Day
- [ ] Release the app (automatic for pre-orders)
- [ ] Publish launch In-App Event
- [ ] Send launch announcement to email list
- [ ] Post across all social channels
- [ ] Monitor reviews and respond quickly
- [ ] Track download velocity

### Launch Week
- [ ] Start Product Page Optimization test
- [ ] Monitor conversion rates
- [ ] Adjust marketing based on initial data
- [ ] Submit second featuring nomination if not featured

## Pre-Order Marketing Assets

### Landing Page
- Apple's official **localized pre-order badge** (per-storefront artwork — don't hand-roll the button)
- App preview screenshots
- Feature highlights
- Release date and countdown

### Social Media
- Announcement post with pre-order link
- 3-5 countdown posts leading to launch
- Feature highlight posts (one feature per post)
- Behind-the-scenes development content

### Email
- Pre-order announcement to existing audience
- 1-week reminder before launch
- Launch day celebration email

## Measurement

| Metric | Target | Track In |
|--------|--------|----------|
| Pre-order count | [Goal] | App Store Connect |
| Day 1 downloads | [Goal] | App Store Connect |
| First week downloads | [Goal] | App Store Connect |
| Conversion rate | [X%] | App Store Connect Analytics |
```

## Pre-Order Best Practices

### Timing
| Scenario | Recommended Duration | Reason |
|----------|---------------------|--------|
| Indie app, small audience | 2-4 weeks | Short attention span, limited reach |
| Established brand, new app | 4-8 weeks | Time for press and marketing |
| Seasonal launch | Align with season start | Holiday: early Nov, Back to school: mid-Aug |
| WWDC tie-in | Start at WWDC, launch with OS | Ride the hype wave |

### Pricing Strategy
| Model | During Pre-Order | After Launch | Best For |
|-------|-----------------|-------------|----------|
| Free launch | Free | Free | Freemium apps, maximum pre-orders |
| Introductory price | $0.99-2.99 | $4.99-9.99 | Create urgency, reward early adopters |
| Full price | $X.99 | $X.99 | Premium apps with strong demand |
| Free then paid | Free | $X.99 | Controversial — may frustrate expectations |

## References

- Related: `generators/in-app-events` — Launch event for release day
- Related: `generators/featuring-nomination` — Featuring during pre-order
- Related: `generators/app-store-assets` — Asset specs for pre-order page
- Related: `app-store/marketing-strategy` — Pre-launch as part of overall strategy
