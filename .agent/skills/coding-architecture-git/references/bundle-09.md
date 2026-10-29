# Integrated Reference Bundle 09

Combines 11 related source skills from `coding-architecture-git` into one navigable reference file.

## Source map

- `generators/preview-data-generator/SKILL.reference.md`
- `generators/push-notifications/SKILL.reference.md`
- `generators/referral-system/SKILL.reference.md`
- `generators/review-prompt/SKILL.reference.md`
- `generators/screenshot-automation/SKILL.reference.md`
- `generators/settings-screen/SKILL.reference.md`
- `generators/share-card/SKILL.reference.md`
- `generators/spotlight-indexing/SKILL.reference.md`
- `generators/state-restoration/SKILL.reference.md`
- `generators/streak-tracker/SKILL.reference.md`
- `generators/tipkit-generator/SKILL.reference.md`

## Integrated guidance

### Source: `generators/preview-data-generator`

# Preview Data Generator

Generates two tightly-coupled things for a SwiftUI view:

1. **Sample data** tuned for the Xcode canvas — realistic instances *plus* the visual edge cases that break layouts (empty, one item, huge list, long/overflowing strings, missing images, error and loading states).
2. **A `#Preview` matrix** — the variant blocks you'd otherwise hand-write to prototype and QA a view across light/dark, Dynamic Type, locale/RTL, device sizes, and data states.

This is the design-time counterpart to `testing/test-data-factory` (which makes fixtures for the *test suite*). Where a factory already exists, this skill **reuses** `Model.fixture()` instead of inventing parallel data.

## When This Skill Activates

Use this skill when the user:
- Wants sample/mock data for Xcode previews ("what do I put in the preview?")
- Wants to preview a view in multiple states (empty / loading / error / loaded)
- Is prototyping UI and wants light/dark, Dynamic Type, RTL, or device variants
- Says "add previews", "preview matrix", "preview this in dark mode + large text"
- Has a SwiftData `@Model` and needs an in-memory seeded container for previews
- Is on Xcode 16 / iOS 18 and wants shared, cached preview data via `PreviewModifier`

**Just need fixtures for unit tests?** Use `testing/test-data-factory` instead.
**Want screenshot regression tests?** Pair this with `testing/snapshot-test-setup` — the same data + variant matrix feeds snapshot tests.

## Reference Files

Load both before generating:

| File | Purpose |
|------|---------|
| **preview-data-patterns.md** | Sample-data design, the edge-case catalog, SwiftData in-memory seeding, `PreviewModifier` (iOS 18), `@Previewable`, reusing `test-data-factory` |
| **preview-matrix.md** | The variant axes, preview `traits:`, `.environment` overrides, deployment-target fallbacks (`#Preview` vs `PreviewProvider`), data-state previews |

## Pre-Generation Checks

Generators are context-aware. Before writing code, detect:

| Check | How | Why it matters |
|-------|-----|----------------|
| **Deployment target** | Read project/`.xcodeproj` or `Package.swift` | iOS 17+ → `#Preview` macro; iOS 18+ → `PreviewModifier` + `@Previewable`; below 17 → `PreviewProvider` fallback |
| **Target view + its models** | Read the view file; Grep its `init`/properties for model types | Determines which types need sample data |
| **Existing fixtures** | `Grep "static func fixture\|extension .*{ static (let\|var) preview"` | Reuse `Model.fixture()` / existing `.preview` — never duplicate |
| **SwiftData** | `Grep "@Model"` on the model types | Use the in-memory `.modelContainer(inMemory:)` seed pattern, not plain structs |
| **View shape** | Does it take a model, a ViewModel, or fetch its own data? | Drives whether to inject data, a mock VM, or a seeded container |
| **Platform** | iOS / macOS / multiplatform | Device variants and some traits differ |

Ask via AskUserQuestion only what you can't infer — e.g. "Which states matter for this view: empty, loading, error, loaded, or all four?"

## Generation Process

### Step 1: Build the Sample Data

For each model the view needs, generate a `Model.preview` namespace with the realistic case **and the edge cases** (see **preview-data-patterns.md** for the full catalog):

```swift
extension Article {
    /// A typical, realistic instance for the canvas.
    static var preview: Article {
        Article(id: UUID(), title: "Designing for the Smallest Screen",
                author: "Mei Chen", body: String(repeating: "Lorem ipsum. ", count: 40),
                imageURL: URL(string: "https://picsum.photos/seed/1/600/400"),
                readMinutes: 6, isBookmarked: false)
    }

    /// Edge cases that expose layout bugs.
    static var previewLongTitle: Article { .preview.with(title: "An Extraordinarily, Almost Unreasonably Long Headline That Wraps") }
    static var previewNoImage: Article   { .preview.with(imageURL: nil) }
    static var previewList: [Article]    { (1...12).map { .preview.with(id: UUID(), title: "Article \($0)") } }
    static var previewEmpty: [Article]   { [] }
}
```

If `Article.fixture()` already exists (from `test-data-factory`), build `.preview` *on top of it* rather than re-specifying every field.

### Step 2: Build the Preview Matrix

Generate the `#Preview` blocks for the axes that matter (see **preview-matrix.md**). Always include **data states** — that's the UI-prototyping payoff:

```swift
#Preview("Loaded")  { ArticleListView(state: .loaded(Article.previewList)) }
#Preview("Empty")   { ArticleListView(state: .empty) }
#Preview("Loading") { ArticleListView(state: .loading) }
#Preview("Error")   { ArticleListView(state: .error("No connection")) }

#Preview("Dark")        { ArticleListView(state: .loaded(Article.previewList)).preferredColorScheme(.dark) }
#Preview("XXL Text")    { ArticleListView(state: .loaded(Article.previewList)).dynamicTypeSize(.accessibility3) }
#Preview("German / RTL", traits: .sizeThatFitsLayout) {
    ArticleDetailView(article: .previewLongTitle).environment(\.locale, .init(identifier: "de"))
}
```

Scale the matrix to the request — don't emit 20 previews for a label. A reasonable default per view: the relevant **data states** + **dark mode** + **one large Dynamic Type** + (if the view has text that localizes) **one long-language/RTL** check.

### Step 3: Wire Up Infrastructure (when needed)

- **SwiftData view** → generate an in-memory `previewContainer` seeded with sample models, attached via `.modelContainer(previewContainer)`.
- **Xcode 16 / iOS 18** → offer a `PreviewModifier` so the seeded container/data is built **once and cached** across every preview, applied with `#Preview(traits: .modifier(SampleData()))`.
- **View needs `@State`/`@Bindable`** → use `@Previewable` so state lives directly in the `#Preview` body.

### Step 4: Place the Code

- Sample data → `Article+Preview.swift` (one file per model, in the model's group).
- Preview blocks → either appended to the view file (Apple's convention) or a sibling `ArticleListView+Previews.swift` for large matrices. Ask if unsure.
- Wrap preview-only data in `#if DEBUG` so it never ships in release builds.

## Output Format

After generating, always provide:

- **Files created** — full paths (`Article+Preview.swift`, `PreviewSupport.swift`, etc.)
- **Integration steps** — where the `#Preview` blocks went, how to open the canvas
- **Deployment-target notes** — which API was used and why (`#Preview` / `PreviewModifier` / `PreviewProvider`)
- **Testing instructions** — open the canvas, cycle the variants; if pairing with snapshots, how the data feeds `snapshot-test-setup`

## Example Output Summary

```
✅ Generated previews for ArticleListView (iOS 18 target)

Files created:
  • Article+Preview.swift        — .preview, .previewLongTitle, .previewNoImage, .previewList, .previewEmpty
  • PreviewSupport.swift         — SampleData: PreviewModifier (cached in-memory container)
  • ArticleListView+Previews.swift — 7 #Preview blocks (4 states, dark, XXL text, German)

Integration:
  • Reused Article.fixture() from test-data-factory for base fields
  • Open ArticleListView+Previews.swift → canvas shows all 7 variants

API used: #Preview + PreviewModifier (.modifier) — shared container built once, cached.
```

## When NOT to Use This Skill

- **Fixtures for the test suite** → `testing/test-data-factory`
- **Snapshot/regression image tests** → `testing/snapshot-test-setup` (feed it this data)
- **A trivial view with no data** → Xcode's autogenerated `#Preview {}` is enough
- **Locale-only preview helpers** → `generators/localization-setup` already covers locale preview helpers; reuse them

## Cross-Skill Integration

```
generators/persistence-setup   → defines @Model types
        ↓
testing/test-data-factory      → Model.fixture() for tests
        ↓
generators/preview-data-generator (THIS SKILL)
   • reuses .fixture() for canvas data
   • builds the #Preview state/appearance matrix
        ↓
testing/snapshot-test-setup    → renders the same matrix for regression
```

## Deliverables

- [ ] Sample data per model: realistic instance + edge cases (empty, long, missing, list)
- [ ] Existing `.fixture()`/`.preview` reused, not duplicated
- [ ] `#Preview` matrix covering the view's data states + relevant appearance axes
- [ ] Correct API for the deployment target (`#Preview` / `PreviewModifier` / `PreviewProvider`)
- [ ] SwiftData views get a seeded in-memory container
- [ ] Preview-only code guarded with `#if DEBUG`
- [ ] Output summary with files, integration, and testing steps

---

**Generate the data and the variants together.** A preview is only as useful as the data in it — and a view is only proven when you've seen it empty, overflowing, in the dark, and at AX5.

### Source: `generators/push-notifications`

# Push Notifications Generator

Generate push notification infrastructure with APNs registration, handling, and rich notifications.

## When This Skill Activates

- User wants to add push notifications to their app
- User mentions APNs (Apple Push Notification service)
- User asks about notification categories or actions
- User wants rich notifications with images or custom UI

## Pre-Generation Checks

Before generating, verify:

1. **Existing Notification Code**
   ```bash
   # Check for existing notification handling
   grep -r "UNUserNotificationCenter\|registerForRemoteNotifications" --include="*.swift" | head -5
   ```

2. **Entitlements**
   ```bash
   # Check for push notification entitlement
   find . -name "*.entitlements" -exec grep -l "aps-environment" {} \;
   ```

3. **App Delegate or SwiftUI App**
   ```bash
   # Determine app structure
   grep -r "@main\|UIApplicationDelegate" --include="*.swift" | head -5
   ```

## Configuration Questions

### 1. Notification Types
- **Basic** - Simple alerts with title/body
- **Rich** - Include images, custom UI (requires Notification Service Extension)
- **Both** - Full notification support

### 2. Notification Actions
- **None** - Just display notifications
- **Simple Actions** - Quick action buttons
- **Custom Categories** - Multiple action categories

### 3. Silent Notifications
- **Yes** - Background data updates
- **No** - User-visible only

## Generated Files

### Core Infrastructure
```
Sources/Notifications/
├── NotificationManager.swift      # Central notification management
├── NotificationDelegate.swift     # UNUserNotificationCenterDelegate
├── NotificationCategories.swift   # Action categories definition
└── NotificationPayload.swift      # Type-safe payload parsing
```

### Rich Notifications (Optional)
```
NotificationServiceExtension/
├── NotificationService.swift      # Modify notifications before display
└── Info.plist                     # Extension configuration
```

### Content Extension (Optional)
```
NotificationContentExtension/
├── NotificationViewController.swift  # Custom notification UI
├── MainInterface.storyboard
└── Info.plist
```

## Key Features

### Registration Flow

```swift
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        return try await center.requestAuthorization(options: options)
    }

    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
}
```

### Handling Notifications

```swift
// Foreground notification
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification
) async -> UNNotificationPresentationOptions {
    return [.banner, .sound, .badge]
}

// Notification tap/action
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse
) async {
    let userInfo = response.notification.request.content.userInfo
    await handleNotificationAction(response.actionIdentifier, userInfo: userInfo)
}
```

### Action Categories

```swift
enum NotificationCategory: String {
    case message = "MESSAGE_CATEGORY"
    case reminder = "REMINDER_CATEGORY"

    var actions: [UNNotificationAction] {
        switch self {
        case .message:
            return [
                UNNotificationAction(identifier: "REPLY", title: "Reply", options: []),
                UNNotificationAction(identifier: "MARK_READ", title: "Mark as Read", options: [])
            ]
        case .reminder:
            return [
                UNNotificationAction(identifier: "COMPLETE", title: "Complete", options: []),
                UNNotificationAction(identifier: "SNOOZE", title: "Snooze", options: [])
            ]
        }
    }
}
```

## Notification Design (WWDC18)

"Interrupting people is a real privilege… a trust relationship." Design the strategy before the infrastructure:

| Decision | Rule |
|----------|------|
| Authorization | Use **provisional authorization** (add `.provisional` to the options — delivered quietly to Notification Center, no prompt) for passive content like likes and comments; reserve the explicit prompt for **time-critical** content |
| When to prompt | **Never at first launch.** Explain the value first, then ask at a contextually meaningful moment — right after the order is placed, not before the user has ordered |
| Content bar | Every notification carries a **specific message or a completable task** — never an empty "open the app" nudge |
| Timing | Deliver at relevant times; use time- and location-based delivery where it fits |
| Settings | Offer **granular per-topic toggles in-app**, and add `.providesAppNotificationSettings` so "Manage" in system settings deep-links to your page |
| Grouping | App-level grouping is the default; set `threadIdentifier` **only for meaningfully different streams** (conversations, distinct sources) — over-threading recreates the clutter grouping was meant to fix |
| Rich content | A rich notification is a **self-contained package**: image/video plus actions that complete the task without launching the app |
| Fatigue | **Pause notification types a user repeatedly ignores** (the Duolingo pattern) — silence beats an uninstall |

## Required Capabilities

### In Xcode
1. Select project target
2. Signing & Capabilities tab
3. Add "Push Notifications" capability
4. Add "Background Modes" > "Remote notifications" (for silent notifications)

### Entitlements
```xml
<key>aps-environment</key>
<string>development</string>  <!-- or "production" -->
```

## Integration Steps

### 1. SwiftUI App

```swift
@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationCategories.registerAll()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
        // Send token to your server
    }
}
```

### 2. Request Permission (at appropriate time)

```swift
Button("Enable Notifications") {
    Task {
        let granted = try await NotificationManager.shared.requestAuthorization()
        if granted {
            await MainActor.run {
                NotificationManager.shared.registerForRemoteNotifications()
            }
        }
    }
}
```

### 3. Server-Side Setup

Configure your server to send APNs requests:
- Use APNs HTTP/2 API
- Include team ID, key ID, and .p8 key
- Target: `api.push.apple.com` (production) or `api.sandbox.push.apple.com` (development)

## Testing

### Local Notifications (Simulator)
```swift
func scheduleTestNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Test"
    content.body = "This is a test notification"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request)
}
```

### Remote Notifications (Physical Device)
1. Build to physical device
2. Copy device token from console
3. Use APNs testing tool or `curl`:

```bash
curl -v \
  --header "authorization: bearer $JWT_TOKEN" \
  --header "apns-topic: com.yourcompany.yourapp" \
  --header "apns-push-type: alert" \
  --http2 \
  --data '{"aps":{"alert":{"title":"Test","body":"Hello"}}}' \
  https://api.sandbox.push.apple.com/3/device/$DEVICE_TOKEN
```

## References

- [User Notifications Framework](https://developer.apple.com/documentation/usernotifications)
- [Registering for APNs](https://developer.apple.com/documentation/usernotifications/registering-your-app-with-apns)
- [Notification Service Extension](https://developer.apple.com/documentation/usernotifications/modifying-content-in-newly-delivered-notifications)

### Source: `generators/referral-system`

# Referral System Generator

Generate a production referral/invite system with unique code generation, deep link sharing, reward tracking, fraud prevention, and SwiftUI views for inviting friends and monitoring referral performance.

## When This Skill Activates

Use this skill when the user:
- Asks to "add a referral system" or "referral codes"
- Wants to "invite friends" or "refer a friend" flow
- Mentions "viral growth" or "invitation system"
- Asks about "referral rewards" or "referral tracking"
- Wants "invite codes" or "shareable invite links"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 17+ / macOS 14+ for @Observable and SwiftData)
- [ ] Identify source file locations
- [ ] Check for existing entitlements (Associated Domains for deep links)

### 2. Conflict Detection
Search for existing referral/invite code:
```
Glob: **/*Referral*.swift, **/*Invite*.swift, **/*InviteCode*.swift
Grep: "referralCode" or "inviteCode" or "ReferralManager"
```

If existing referral system found:
- Ask if user wants to replace or extend it
- If extending, identify integration points

### 3. Deep Link Setup Detection
Search for existing deep link handling:
```
Glob: **/*DeepLink*.swift, **/*UniversalLink*.swift
Grep: "onOpenURL" or "userActivity" or "NSUserActivity"
```

If deep link handling exists, integrate with it rather than generating a standalone handler.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Reward type?**
   - Both-get (referrer and invitee both earn a reward) -- recommended
   - Referrer-only (only the person who shares gets rewarded)
   - Points-based (both parties earn points toward rewards)

2. **Code format?**
   - Short alphanumeric (e.g., `A7K2M9`) -- recommended
   - Custom prefix (e.g., `MYAPP-A7K2M9`)
   - Username-based (e.g., `john-A7K2`)

3. **Sharing method?**
   - Deep link (universal link with embedded code) -- recommended
   - Clipboard copy (copy code to pasteboard)
   - Share sheet (system share with link and message)
   - All of the above

4. **Storage?**
   - SwiftData (local persistence, recommended for most apps)
   - UserDefaults (lightweight, for simple single-code scenarios)
   - CloudKit (sync across devices)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `ReferralCode.swift` -- Model with unique code generation, expiration, usage tracking
2. `ReferralManager.swift` -- @Observable manager for code lifecycle and redemption
3. `ReferralReward.swift` -- Reward configuration, conditions, and fulfillment tracking

### Step 3: Create UI Files
4. `InviteView.swift` -- SwiftUI invite screen with code display and sharing
5. `ReferralDashboardView.swift` -- Stats view for referral performance

### Step 4: Create Integration Files
6. `ReferralDeepLinkHandler.swift` -- Deep link parsing and redemption triggering

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/Referral/`
- If `App/` exists -> `App/Referral/`
- Otherwise -> `Referral/`

## Output Format

After generation, provide:

### Files Created
```
Referral/
├── ReferralCode.swift            # Code model with generation and validation
├── ReferralManager.swift         # @Observable manager for code lifecycle
├── ReferralReward.swift          # Reward config and fulfillment tracking
├── InviteView.swift              # Invite screen with share actions
├── ReferralDashboardView.swift   # Referral stats dashboard
└── ReferralDeepLinkHandler.swift # Deep link parsing and redemption
```

### Integration Steps

**Add deep link handling in your App struct:**
```swift
@main
struct MyApp: App {
    @State private var referralManager = ReferralManager()
    private let deepLinkHandler = ReferralDeepLinkHandler()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(referralManager)
                .onOpenURL { url in
                    if let code = deepLinkHandler.extractCode(from: url) {
                        Task {
                            await referralManager.redeemCode(code)
                        }
                    }
                }
        }
    }
}
```

**Present the invite screen:**
```swift
struct ProfileView: View {
    @State private var showInvite = false

    var body: some View {
        Button("Invite Friends") { showInvite = true }
            .sheet(isPresented: $showInvite) {
                InviteView()
            }
    }
}
```

**Show referral dashboard:**
```swift
NavigationLink("My Referrals") {
    ReferralDashboardView()
}
```

### Testing

```swift
@Test
func generatedCodeIsUnique() async throws {
    let manager = ReferralManager(store: InMemoryReferralStore())

    let code1 = await manager.generateCode(for: "user-1")
    let code2 = await manager.generateCode(for: "user-2")

    #expect(code1.value != code2.value)
}

@Test
func redemptionGrantsReward() async throws {
    let manager = ReferralManager(store: InMemoryReferralStore())
    let code = await manager.generateCode(for: "referrer-1")

    let result = await manager.redeemCode(code.value, redeemedBy: "invitee-1")

    #expect(result == .success)
    #expect(manager.rewards(for: "referrer-1").count == 1)
    #expect(manager.rewards(for: "invitee-1").count == 1)
}

@Test
func selfReferralIsRejected() async throws {
    let manager = ReferralManager(store: InMemoryReferralStore())
    let code = await manager.generateCode(for: "user-1")

    let result = await manager.redeemCode(code.value, redeemedBy: "user-1")

    #expect(result == .fraudDetected(.selfReferral))
}

@Test
func expiredCodeIsRejected() async throws {
    let manager = ReferralManager(store: InMemoryReferralStore())
    let code = ReferralCode(
        value: "EXPIRED1",
        ownerID: "user-1",
        expiresAt: Date.distantPast
    )

    let result = await manager.redeemCode(code.value, redeemedBy: "user-2")

    #expect(result == .expired)
}
```

## Common Patterns

### Generate and Share a Referral Code

```swift
// Generate code for current user
let code = await referralManager.generateCode(for: currentUserID)

// Share via system share sheet
let shareURL = deepLinkHandler.buildShareURL(for: code)
let message = "Join me on MyApp! Use my code \(code.value) for a bonus."
let activityItems: [Any] = [message, shareURL]
```

### Redeem a Referral Code

```swift
// On app launch or deep link open
let result = await referralManager.redeemCode(codeString, redeemedBy: currentUserID)

switch result {
case .success:
    showRewardAnimation()
case .alreadyRedeemed:
    showAlert("You've already used a referral code.")
case .expired:
    showAlert("This referral code has expired.")
case .fraudDetected(let reason):
    logger.warning("Fraud detected: \(reason)")
case .invalid:
    showAlert("Invalid referral code.")
}
```

### Track Rewards

```swift
// Check pending rewards
let pending = referralManager.pendingRewards(for: currentUserID)
for reward in pending {
    await fulfillReward(reward)
    await referralManager.markFulfilled(reward)
}
```

## Gotchas

### Fraud Prevention
- **Self-referral**: Always verify referrer ID != redeemer ID. Users will try creating alt accounts.
- **Device fingerprinting**: Consider storing device identifiers to detect multi-account abuse.
- **Rate limiting**: Cap the number of referrals per user per time period (e.g., 50 per month).
- **Code reuse**: Each invitee should only be able to redeem one referral code ever.

### App Store Guidelines
- **Guideline 3.1.1**: Do not offer real-money rewards or gift cards for referrals without proper IAP integration.
- **Guideline 3.2.2(vii)**: Referral systems must not manipulate App Store ratings or reviews.
- **Incentivized installs**: Apple may reject apps that reward users purely for downloading. Tie rewards to meaningful in-app actions (e.g., completing a first task, making a purchase).

### Deep Link Expiration
- Universal links require an `apple-app-site-association` file on your server.
- Referral deep links should have a TTL (default 30 days) to prevent stale code accumulation.
- Handle the case where a user taps a referral link but the app is not installed (redirect to App Store, then capture code on first launch).

### Data Privacy
- Referral codes should not expose user PII (no emails or phone numbers in codes).
- Provide opt-out: let users disable their referral code at any time.
- Comply with GDPR/CCPA if tracking referral relationships across users.

## References

- **templates.md** -- All production Swift templates
- Related: `generators/deep-linking` -- Universal link and deep link infrastructure
- Related: `generators/share-card` -- Visual share cards for social sharing
- Related: `generators/analytics-setup` -- Track referral funnel events

### Source: `generators/review-prompt`

# Review Prompt Generator

Generate smart App Store review prompting with configurable trigger conditions, platform detection, and proper timing logic.

## When This Skill Activates

Use this skill when the user:
- Asks to "add review prompt" or "request reviews"
- Mentions "App Store rating" or "app reviews"
- Wants to "prompt for ratings" or "ask for reviews"
- Asks about "StoreKit review" or "SKStoreReviewController"

## Platform Detection (CRITICAL)

**This skill only applies to App Store distributed apps.**

### iOS Apps
- Always applicable (iOS apps require App Store)

### macOS Apps
Detection steps:
1. Check for `com.apple.application-identifier` entitlement
2. Look for Mac App Store related code
3. If unclear, **ASK THE USER**:
   - "Is this app distributed via Mac App Store or direct download?"

### If NOT App Store:
- Explain that StoreKit reviews only work for App Store apps
- Offer alternative: In-app feedback form
- Skip generation or generate feedback form instead

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Determine platform (iOS/macOS)
- [ ] Check distribution method (App Store vs direct)
- [ ] Search for existing review prompt code
- [ ] Identify App entry point

### 2. Conflict Detection
Search for existing implementations:
```
Grep: "requestReview" or "SKStoreReviewController" or "StoreKit"
Glob: **/*Review*.swift
```

If found, ask user:
- Replace existing implementation?
- Enhance with better timing logic?

## Configuration Questions

Ask user via AskUserQuestion:

1. **Trigger conditions?** (multi-select)
   - Session count (e.g., after 5 sessions)
   - Days since install (e.g., after 3 days)
   - Positive actions (e.g., after completing a task)
   - Feature usage (e.g., after using key feature 3 times)

2. **Minimum thresholds?**
   - Sessions before first prompt: 3-5 (default: 3)
   - Days before first prompt: 2-7 (default: 3)

3. **Cool-down period?**
   - Days between prompts: 30-90 (default: 60)
   - Apple limits to 3 prompts/year anyway

4. **Debug mode?**
   - Include debug override for testing?

## Generation Process

### Step 1: Create Core Files

Generate these files:
1. `ReviewPromptManager.swift` - Core logic and timing
2. `ReviewPromptCondition.swift` - Configurable conditions
3. `ReviewPromptStorage.swift` - Persistence for tracking

### Step 2: Determine File Location

Check project structure:
- If `Sources/` exists → `Sources/Reviews/`
- If `App/` exists → `App/Reviews/`
- Otherwise → `Reviews/`

### Step 3: Add Platform Guards

For macOS, include:
```swift
#if os(macOS)
// Check if running from App Store
guard Bundle.main.appStoreReceiptURL?.lastPathComponent != "sandboxReceipt" else {
    // Running in sandbox but not App Store - skip
    return
}
#endif
```

## Output Format

After generation, provide:

### Files Created
```
Sources/Reviews/
├── ReviewPromptManager.swift      # Core logic
├── ReviewPromptCondition.swift    # Conditions enum
└── ReviewPromptStorage.swift      # UserDefaults persistence
```

### Integration Steps

**Option 1: Automatic (Recommended)**
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    ReviewPromptManager.shared.incrementSession()
                }
        }
    }
}

// In relevant places (after positive actions):
ReviewPromptManager.shared.recordPositiveAction()
ReviewPromptManager.shared.requestReviewIfAppropriate()
```

**Option 2: Manual Trigger Points**
```swift
// After user completes a significant action
func completeTask() {
    // ... task completion logic ...

    ReviewPromptManager.shared.recordPositiveAction()
    ReviewPromptManager.shared.requestReviewIfAppropriate()
}
```

### Apple's Guidelines
- System limits to 3 prompts per 365-day period
- Prompt appears at system's discretion (not guaranteed)
- Never prompt after negative experience
- Don't prompt on first launch
- Don't interrupt user's workflow

### Testing Instructions

1. **Debug Mode**: Set `ReviewPromptManager.debugAlwaysShow = true`
2. **Reset State**: Call `ReviewPromptStorage.reset()`
3. **Simulate**: Increment sessions/actions in debug builds
4. **Note**: Actual prompt may not show in Simulator

### App Store Review URL (Alternative)
For custom UI or macOS direct distribution:
```swift
// Deep link to App Store review page
let appID = "YOUR_APP_ID"
let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review")!
NSWorkspace.shared.open(url)  // macOS
UIApplication.shared.open(url)  // iOS
```

## References

- **storekit-patterns.md** - Best practices and timing strategies
- **templates/** - All template files

### Source: `generators/screenshot-automation`

# Screenshot Automation Generator

Generate an automated App Store screenshot pipeline that captures screenshots via UI tests, adds localized marketing captions, applies device frames, and exports all required sizes for App Store Connect. Saves hours of manual screenshot creation every release.

## When This Skill Activates

Use this skill when the user:
- Asks about "screenshot automation" or "automate screenshots"
- Wants to generate "App Store screenshots" or "store screenshots"
- Mentions "automated screenshots" or "screenshot pipeline"
- Asks to "generate screenshots" or "batch screenshots"
- Wants "screenshot testing" or "UI test screenshots"
- Mentions "fastlane snapshot" or wants a replacement for it

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Identify existing UI test target (look for `*UITests` target)
- [ ] Check for existing UI test files
- [ ] Check for fastlane presence (`Fastfile`, `Snapfile`)

### 2. Conflict Detection
Search for existing screenshot infrastructure:
```
Glob: **/*Screenshot*.swift, **/*Snapshot*.swift, **/Snapfile, **/Fastfile
Grep: "XCTAttachment" or "screenshot" or "snapshot" in UI test files
```

If fastlane snapshot already configured:
- Ask if user wants to replace or augment it
- If keeping fastlane, generate only the post-processing pipeline

### 3. Localization Detection
Check for existing localization setup:
```
Glob: **/*.lproj/*.strings, **/*Localizable*, **/*.xcstrings
```
Determine which locales are already configured in the project.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Screenshot capture method?**
   - XCUITest only (pure Apple, no dependencies)
   - fastlane snapshot (uses fastlane tooling)
   - Both (XCUITest capture + fastlane orchestration)

2. **Target devices?** (multi-select)
   - iPhone 6.7" (iPhone 15 Pro Max / 16 Pro Max) -- required for App Store
   - iPhone 6.5" (iPhone 11 Pro Max / XS Max) -- required for older slot
   - iPhone 5.5" (iPhone 8 Plus) -- optional legacy
   - iPad 12.9" (iPad Pro 6th gen) -- required if universal app
   - iPad 11" (iPad Air) -- optional

3. **Locales?**
   - en-US only
   - en-US + (list additional locales, e.g., de-DE, ja-JP, fr-FR, es-ES, zh-Hans)
   - Match existing project localizations

4. **Include device frames?**
   - Yes (wrap screenshots in device bezels for marketing)
   - No (raw screenshots only)

5. **Caption overlay style?**
   - Top (marketing text above the screenshot)
   - Bottom (marketing text below the screenshot)
   - None (no text overlay, raw screenshot or framed only)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code and scripts.

### Step 2: Create App-Side Screenshot Mode
Generate:
1. `ScreenshotModeController.swift` -- **Add to the app target (not tests)**. Detects `--screenshot-mode` launch argument and configures the app: suppresses onboarding, disables analytics/IAP, loads sample data, sizes windows (macOS). Also provides `@Environment(\.isScreenshotMode)` for views to hide promotional UI during capture.

Tell the user to:
- Call `ScreenshotModeController.shared.configureIfNeeded()` in their App's `init()`
- Call `ScreenshotModeController.shared.configureWindow()` in their root view's `onAppear`
- Override `loadSampleData()` to populate their data store with attractive content

### Step 3: Create Configuration
Generate:
2. `ScreenshotPlan.swift` -- Defines screens to capture, devices, locales, and output paths

### Step 4: Create UI Test Files
Generate:
3. `ScreenshotUITests.swift` -- XCUITest class that navigates and captures each screen
4. `ScreenshotTestHelper.swift` -- Helper utilities for locale setup, data seeding, alert dismissal, plus `tapUnhittable()` extension for custom controls

### Step 5: Create Post-Processing Files
Generate:
5. `ScreenshotProcessor.swift` -- Loads captured images, routes through framing and captioning
6. `CaptionOverlay.swift` -- Renders localized marketing text onto screenshot images

For macOS-only or lightweight needs, offer `sips-screenshot-process.sh` as an alternative to the Swift processor. Uses macOS's built-in `sips` command — zero dependencies.

### Step 6: Create Export Script
Generate:
7. `ScreenshotExportScript.swift` -- End-to-end pipeline script: build, test, process, organize

For macOS apps, also generate:
8. `macos-screenshot-env.sh` -- Desktop preparation script (hides dock, desktop icons, simplifies clock) with `trap`-based cleanup

### Step 7: Create Sample Content Generator
If the user needs realistic sample data for screenshots:
9. `SampleContentGenerator.swift` -- Provides text content, chart data, placeholder images, and PDF generation (macOS). Category-specific sample titles for productivity, fitness, finance, and notes apps.

### Step 8: Create Xcode Test Plan
Generate:
10. `ScreenshotTests.xctestplan` -- Dedicated test plan that isolates screenshot tests from development tests. Prevents screenshot tests from running during `Cmd+U`.

Tell the user to:
- Save to project root
- Add to their scheme via Product → Scheme → Edit Scheme → Test → add plan
- Run with: `xcodebuild test -testPlan "ScreenshotTests" ...`

### Step 9: Determine File Locations
Check project structure:
- `ScreenshotModeController.swift` goes into the **app target** source directory
- `SampleContentGenerator.swift` goes into the **app target** source directory
- UI test files go into the existing `*UITests/` target directory
- Processing files go into a `ScreenshotAutomation/` group or `Scripts/` directory
- Shell scripts go into `Scripts/` directory
- Test plan goes into the project root
- If `Sources/` exists -> `Sources/ScreenshotAutomation/`
- Otherwise -> `ScreenshotAutomation/`

## Output Format

After generation, provide:

### Files Created
```
App Target (source directory):
├── ScreenshotModeController.swift  # App-side screenshot mode detection & config
└── SampleContentGenerator.swift    # Realistic sample data for screenshots

UITests Target:
├── ScreenshotUITests.swift         # XCUITest capture class
└── ScreenshotTestHelper.swift      # Helper: locale, seeding, alerts, tapUnhittable()

ScreenshotAutomation/:
├── ScreenshotPlan.swift            # Configuration: screens, devices, locales
├── ScreenshotProcessor.swift       # Post-processing orchestrator
├── CaptionOverlay.swift            # Localized text overlay renderer
└── ScreenshotExportScript.swift    # Full pipeline script

Scripts/ (shell scripts):
├── sips-screenshot-process.sh      # Lightweight sips-based image processing
└── macos-screenshot-env.sh         # macOS desktop prep with trap cleanup

Project Root:
└── ScreenshotTests.xctestplan      # Dedicated test plan for screenshots
```

### Integration with CI

**Xcode Cloud:**
```yaml
# ci_scripts/ci_post_xcodebuild.sh
if [ "$CI_WORKFLOW" = "Screenshots" ]; then
    swift ScreenshotAutomation/ScreenshotExportScript.swift
fi
```

**GitHub Actions:**
```yaml
- name: Generate Screenshots
  run: |
    xcodebuild test \
      -scheme "YourAppUITests" \
      -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
      -testPlan ScreenshotPlan \
      -resultBundlePath screenshots.xcresult
    swift ScreenshotAutomation/ScreenshotExportScript.swift
```

**fastlane (if selected):**
```ruby
lane :screenshots do
  capture_screenshots(scheme: "YourAppUITests")
  # Post-processing handled by ScreenshotProcessor
end
```

### Testing and Running

**Run screenshot tests from Xcode:**
```bash
xcodebuild test \
  -project YourApp.xcodeproj \
  -scheme "YourAppUITests" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro Max" \
  -only-testing "YourAppUITests/ScreenshotUITests"
```

**Run the full pipeline:**
```bash
swift ScreenshotAutomation/ScreenshotExportScript.swift
```

**Verify output directory:**
```
screenshots/
├── en-US/
│   ├── iPhone_6.7/
│   │   ├── 01_HomeScreen.png
│   │   ├── 02_DetailView.png
│   │   └── 03_Settings.png
│   └── iPad_12.9/
│       ├── 01_HomeScreen.png
│       └── ...
├── de-DE/
│   └── ...
└── ja-JP/
    └── ...
```

### Integration Steps

**Add to existing UI test target:**
```swift
// In your UITest scheme, add ScreenshotUITests.swift
// The test class auto-discovers screens from ScreenshotPlan
```

**Localized captions file (Localizable.strings):**
```
// en-US
"screenshot.home" = "Track your goals effortlessly";
"screenshot.detail" = "Deep insights at a glance";
"screenshot.settings" = "Customize everything";

// de-DE
"screenshot.home" = "Verfolgen Sie Ihre Ziele muhelos";
"screenshot.detail" = "Tiefe Einblicke auf einen Blick";
"screenshot.settings" = "Alles anpassen";
```

### Testing

```swift
@Test
func screenshotPlanLoadsAllScreens() throws {
    let plan = ScreenshotPlan.default
    #expect(!plan.screens.isEmpty)
    #expect(plan.screens.allSatisfy { !$0.name.isEmpty })
}

@Test
func captionOverlayRendersText() throws {
    let overlay = CaptionOverlay(
        text: "Track your goals",
        style: .top,
        font: .systemFont(ofSize: 48, weight: .bold),
        textColor: .white
    )
    let sourceImage = PlatformImage.testScreenshot(size: CGSize(width: 1290, height: 2796))
    let result = try overlay.apply(to: sourceImage)
    #expect(result.size.height > sourceImage.size.height)
}

@Test
func processorOrganizesOutputByLocaleAndDevice() async throws {
    let processor = ScreenshotProcessor(outputDirectory: tempDir)
    let screenshot = CapturedScreenshot(
        name: "01_HomeScreen",
        image: .testScreenshot(),
        locale: "en-US",
        device: .iPhone6_7
    )
    try await processor.process([screenshot])

    let outputPath = tempDir
        .appendingPathComponent("en-US")
        .appendingPathComponent("iPhone_6.7")
        .appendingPathComponent("01_HomeScreen.png")
    #expect(FileManager.default.fileExists(atPath: outputPath.path))
}
```

## Common Patterns

### Capture Key Screens
Identify 6-10 screens that showcase the app's value proposition. Order them for maximum impact -- the first screenshot is the most important in App Store search results.

### Add Captions
Marketing text should be short (3-6 words), benefit-focused, and localized. Use the app's brand fonts when possible.

### Frame and Export
Device frames add professionalism. Export at exact App Store Connect required resolutions to avoid rejection.

### Batch All Locales
Run the full pipeline once to generate screenshots for every locale simultaneously. Each locale uses its own localized strings and sample data.

## Gotchas

### Simulator vs Device Differences
- Simulators render slightly different font weights and colors than real devices
- Status bar content varies (carrier name, time) -- use `XCUIDevice.shared.appearance` to set a consistent state
- Always set a fixed time in the status bar: override with `simctl status_bar`

### Dark Mode Screenshots
- Capture both light and dark mode variants by toggling `UITraitCollection.current` or using launch arguments
- Name files distinctly: `01_HomeScreen_light.png`, `01_HomeScreen_dark.png`
- App Store Connect allows separate dark mode screenshot sets (iOS 18+)

### Dynamic Type Screenshots
- Consider capturing at default text size for consistency
- If accessibility is a selling point, include one screenshot at larger Dynamic Type

### Screenshot Naming Convention for App Store Connect
- Files must be PNG format
- Exact pixel dimensions must match device slot requirements:
  - iPhone 6.7": 1290 x 2796 (portrait) or 2796 x 1290 (landscape)
  - iPhone 6.5": 1242 x 2688 (portrait) or 2688 x 1242 (landscape)
  - iPhone 5.5": 1242 x 2208 (portrait) or 2208 x 1242 (landscape)
  - iPad 12.9": 2048 x 2732 (portrait) or 2732 x 2048 (landscape)
  - iPad 11": 1668 x 2388 (portrait) or 2388 x 1668 (landscape)
  - Mac Retina: 2880 x 1800 (landscape)
- Alphabetical file ordering determines screenshot order in App Store Connect

### Landscape Screenshots
- Some apps benefit from landscape screenshots (games, productivity)
- UI tests must explicitly rotate: `XCUIDevice.shared.orientation = .landscapeLeft`
- Remember to rotate back after capture

### macOS: Asymmetric Window Borders
- macOS windows have different border thickness at the top (title bar) vs bottom
- The bottom ~3px typically gets cropped during resize-to-fit
- `ScreenshotModeController` accounts for this by adding `bottomBorderPadding` when sizing windows
- If cropping manually with `sips`, crop from the bottom edge, not centered

### macOS: Desktop Environment
- Unlike iOS simulators, macOS screenshots capture the real desktop behind your app
- Use `macos-screenshot-env.sh` to hide dock, desktop icons, and simplify the clock
- The script uses `trap` handlers to restore settings even on Ctrl+C or failure
- Run the desktop prep script before launching tests, not from within the test

### macOS: Window Sizing for App Store
- Mac App Store requires 2880×1800 (Retina) or minimum 1280×800
- `ScreenshotModeController.configureWindow()` sizes the window to fill the required dimensions
- For non-full-screen apps, account for the title bar (28pt) and menu bar in your layout

### Custom Controls and tapUnhittable()
- Custom tab bars, overlapping views, and controls behind transparent overlays often don't report as hittable in XCUITest
- Use the `tapUnhittable()` extension from `ScreenshotTestHelper.swift` to tap by coordinate
- Assign unique accessibility identifiers to all custom controls used in screenshot navigation (e.g., `"pageStrip.page.1"`)

### Isolating Screenshot Tests
- Screenshot tests are slow and should NOT run during normal `Cmd+U` test cycles
- Generate `ScreenshotTests.xctestplan` and add it as a separate test plan in your scheme
- Run screenshots explicitly: `xcodebuild test -testPlan "ScreenshotTests" ...`
- This also prevents accidental test failures from blocking development

## References

- **templates.md** -- All production Swift/XCTest templates for screenshot automation:
  - `ScreenshotModeController.swift` -- App-side screenshot mode detection
  - `ScreenshotPlan.swift` -- Screen/device/locale configuration
  - `ScreenshotUITests.swift` -- XCUITest capture class
  - `ScreenshotTestHelper.swift` -- Helpers + `tapUnhittable()` extension
  - `ScreenshotProcessor.swift` -- Post-processing orchestrator
  - `CaptionOverlay.swift` -- Localized text overlay renderer
  - `ScreenshotExportScript.swift` -- Full pipeline script
  - `sips-screenshot-process.sh` -- Lightweight macOS image processing
  - `macos-screenshot-env.sh` -- Desktop preparation with trap cleanup
  - `SampleContentGenerator.swift` -- Realistic sample data patterns
  - `ScreenshotTests.xctestplan` -- Dedicated Xcode test plan
- Related: `generators/localization-setup` -- Setting up localization infrastructure
- Related: `app-store/screenshot-planner` -- Planning screenshot content and marketing messaging

### Source: `generators/settings-screen`

# Settings Screen Generator

Generates a production-ready settings screen with modular sections for iOS and macOS apps.

## When This Skill Activates

- User asks to "add settings" or "create settings screen"
- User mentions "preferences", "app settings", or "configuration UI"
- User wants to add dark mode toggle, notifications settings, or about screen

## Pre-Generation Checks (CRITICAL)

### 1. Project Context Detection

Before generating, ALWAYS check:

```
# Find existing settings implementations
rg -l "SettingsView|PreferencesView|SettingsScreen" --type swift

# Check deployment target
cat Package.swift | grep -i "platform"
# Or check project.pbxproj for deployment target

# Detect architecture pattern
rg -l "Observable|ObservableObject|@EnvironmentObject" --type swift | head -5

# Check platform (iOS vs macOS)
rg "UIKit|UIApplication" --type swift | head -1  # iOS
rg "AppKit|NSApplication" --type swift | head -1  # macOS
```

### 2. Conflict Detection

If existing settings implementation found:
- Ask user: Extend existing, replace, or create separate?
- Check for naming conflicts with existing files

## Configuration Questions

Ask user via AskUserQuestion:

1. **Which sections do you need?**
   - Account (sign out, delete account)
   - Appearance (dark mode, app icon)
   - Notifications (push settings)
   - About (version, developer info)
   - Legal (terms, privacy)

2. **Platform?**
   - iOS (NavigationStack)
   - macOS (Settings scene / NavigationSplitView)
   - Both (adaptive)

3. **Additional features?**
   - App icon selector
   - Language selector
   - Data export
   - Cache clearing

## Generation Process

### Step 1: Create Core Files

Generate these files (customize based on answers):

```
Sources/Settings/
├── SettingsView.swift              # Main container
├── AppSettings.swift               # @AppStorage wrapper
├── Components/
│   └── SettingsRow.swift           # Reusable row component
└── Sections/
    ├── AppearanceSettingsView.swift
    ├── AccountSettingsView.swift
    ├── NotificationsSettingsView.swift
    ├── AboutSettingsView.swift
    └── LegalSettingsView.swift
```

### Step 2: Read Templates

Read templates from this skill:
- `templates/SettingsView.swift`
- `templates/AppSettings.swift`
- `templates/SettingsRow.swift`
- `templates/AppearanceSettingsView.swift`
- `templates/AccountSettingsView.swift`
- `templates/NotificationsSettingsView.swift`
- `templates/AboutSettingsView.swift`
- `templates/LegalSettingsView.swift`

### Step 3: Customize for Project

Adapt templates to match:
- Project naming conventions
- Existing architecture patterns
- Selected sections only
- Platform-specific code

### Step 4: Integration

**iOS Integration:**
```swift
// In any view
NavigationLink("Settings") {
    SettingsView()
}

// Or as sheet
.sheet(isPresented: $showSettings) {
    NavigationStack {
        SettingsView()
    }
}
```

**macOS Integration:**
```swift
// In App.swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        Settings {
            SettingsView()
        }
    }
}
```

## Platform-Specific Considerations

### iOS
- Use `NavigationStack` with `List`
- Use `Form` for grouped appearance
- Link to Settings app for notifications: `UIApplication.openSettingsURLString`

### macOS
- Use `Settings` scene for standard preferences window
- Consider `TabView` for multiple sections
- Use `Form` with appropriate styling
- Support keyboard shortcut (⌘,)

### Cross-Platform
- Use conditional compilation for platform-specific features
- Abstract platform differences in AppSettings

## Generated Code Patterns

### AppStorage Wrapper
```swift
@Observable
final class AppSettings {
    static let shared = AppSettings()

    @AppStorage("appearance") var appearance: Appearance = .system
    @AppStorage("notificationsEnabled") var notificationsEnabled = true

    enum Appearance: String, CaseIterable {
        case system, light, dark
    }
}
```

### Settings Row Component
```swift
struct SettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: () -> Content

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 28)
            Text(title)
            Spacer()
            content()
        }
    }
}
```

## Verification Checklist

After generation, verify:

- [ ] Settings accessible from main UI
- [ ] All selected sections present
- [ ] AppStorage persists between launches
- [ ] Dark mode toggle works correctly
- [ ] Links to external URLs work (privacy, terms)
- [ ] Platform-appropriate navigation
- [ ] Accessibility labels present
- [ ] VoiceOver navigation works

## Common Customizations

### Adding Custom Sections
```swift
// In SettingsView
Section("Custom") {
    NavigationLink("My Feature") {
        MyFeatureSettingsView()
    }
}
```

### Conditional Features
```swift
#if DEBUG
Section("Debug") {
    DebugSettingsView()
}
#endif
```

### Subscription Integration
```swift
if !subscriptionStatus.hasAccess {
    Section {
        Button("Upgrade to Pro") {
            showPaywall = true
        }
    }
}
```

## Related Skills

- `paywall-generator` - For subscription upgrade prompts in settings
- `auth-flow` - For account management integration
- `review-prompt` - Trigger review from settings (sparingly)

## References

- [Apple HIG: Settings](https://developer.apple.com/design/human-interface-guidelines/settings)
- [SwiftUI Settings Scene](https://developer.apple.com/documentation/swiftui/settings)
- [AppStorage Documentation](https://developer.apple.com/documentation/swiftui/appstorage)

### Source: `generators/share-card`

# Share Card Generator

Generate a production share card system that renders app content (achievements, statistics, quotes, milestones) as shareable images with SwiftUI `ImageRenderer`, customizable styles, optional QR code overlays, and native `ShareLink` integration.

## When This Skill Activates

Use this skill when the user:
- Asks to "generate share cards" or "create shareable images"
- Wants to "share achievements as images" or "share stats to social media"
- Mentions "social media cards" or "shareable content cards"
- Asks about "exporting content as images" or "screenshot sharing"
- Wants "branded share images" or "share card templates"
- Asks to "add ShareLink with image" or "share rendered SwiftUI view"
- Wants "QR code on share image" or "deep link in share card"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+ minimum for `ImageRenderer`)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing share/export code:
```
Glob: **/*ShareCard*.swift, **/*ShareImage*.swift, **/*SocialCard*.swift
Grep: "ImageRenderer" or "ShareLink" or "UIGraphicsImageRenderer" or "share.*image"
```

If existing share infrastructure found:
- Ask if user wants to replace or extend it
- If extending, integrate with existing models and styles

### 3. Platform Detection
Determine if generating for iOS (`UIImage`) or macOS (`NSImage`) or both (cross-platform `PlatformImage` typealias).

## Configuration Questions

Ask user via AskUserQuestion:

1. **Card style?**
   - Minimal (clean, text-focused, light/dark adaptive)
   - Branded (app logo, brand colors, custom typography)
   - Statistics (data-heavy with charts/numbers emphasis)

2. **Share destinations?**
   - Social media (Instagram, Twitter/X — optimized aspect ratios)
   - Messages / General sharing (flexible sizing)
   - Both — recommended

3. **Card size preset?**
   - Square (1080x1080 — Instagram, general purpose)
   - Story (1080x1920 — Instagram Stories, TikTok)
   - Wide (1200x630 — Twitter/X, Open Graph)
   - Custom (user-specified dimensions)

4. **Include QR code?**
   - Yes (deep link or App Store URL embedded in card corner)
   - No (cleaner card, no link)

5. **Content types?** (multi-select)
   - Achievements / Milestones
   - Statistics / Progress
   - Quotes / Text content
   - Custom (user defines their own content model)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `ShareCardContent.swift` — Protocol and concrete content types (achievement, statistics, quote)
2. `ShareCardStyle.swift` — Enum with predefined styles, colors, fonts, layout configuration
3. `ShareCardRenderer.swift` — `@MainActor` renderer using `ImageRenderer` to convert SwiftUI views to images
4. `ShareCardView.swift` — The SwiftUI view that composes the card layout (background, content, branding)

### Step 3: Create UI Files
5. `ShareCardSheet.swift` — Complete sharing sheet with style picker, live preview, and `ShareLink`

### Step 4: Create Optional Files
Based on configuration:
- `QRCodeOverlay.swift` — If QR code selected (CoreImage-based QR generator)
- `ShareCardPreview.swift` — SwiftUI Preview helpers for design iteration

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/ShareCard/`
- If `App/` exists -> `App/ShareCard/`
- Otherwise -> `ShareCard/`

## Output Format

After generation, provide:

### Files Created
```
ShareCard/
├── ShareCardContent.swift    # Protocol + concrete content types
├── ShareCardStyle.swift      # Style enum with colors, fonts, layout
├── ShareCardRenderer.swift   # ImageRenderer-based rendering
├── ShareCardView.swift       # Card layout SwiftUI view
├── ShareCardSheet.swift      # Share sheet with preview + ShareLink
├── QRCodeOverlay.swift       # CoreImage QR code (optional)
└── ShareCardPreview.swift    # Preview helpers (optional)
```

### Integration Steps

**Share an achievement:**
```swift
struct AchievementDetailView: View {
    let achievement: Achievement
    @State private var showShareCard = false

    var body: some View {
        VStack {
            // ... achievement detail content ...

            Button("Share Achievement") {
                showShareCard = true
            }
        }
        .sheet(isPresented: $showShareCard) {
            ShareCardSheet(
                content: AchievementCardContent(
                    title: achievement.title,
                    subtitle: achievement.description,
                    metric: "\(achievement.points) pts",
                    iconName: achievement.iconName,
                    brandName: "MyApp"
                )
            )
        }
    }
}
```

**Share statistics:**
```swift
ShareCardSheet(
    content: StatisticsCardContent(
        title: "Weekly Progress",
        stats: [
            StatItem(label: "Steps", value: "52,340"),
            StatItem(label: "Calories", value: "3,200"),
            StatItem(label: "Distance", value: "28.5 km"),
        ],
        brandName: "FitTracker"
    )
)
```

**Share a quote:**
```swift
ShareCardSheet(
    content: QuoteCardContent(
        quote: "The only way to do great work is to love what you do.",
        attribution: "Steve Jobs",
        brandName: "DailyQuotes"
    )
)
```

**Inline ShareLink (without sheet):**
```swift
struct QuickShareButton: View {
    let content: any ShareCardContent
    @State private var renderedImage: PlatformImage?

    var body: some View {
        Group {
            if let image = renderedImage {
                ShareLink(
                    item: Image(platformImage: image),
                    preview: SharePreview(content.title, image: Image(platformImage: image))
                )
            } else {
                ProgressView()
            }
        }
        .task {
            let renderer = ShareCardRenderer()
            renderedImage = await renderer.render(content: content, style: .branded)
        }
    }
}
```

### Testing

```swift
@Test
func rendersAchievementCard() async throws {
    let content = AchievementCardContent(
        title: "First Run",
        subtitle: "Completed your first 5K run",
        metric: "500 pts",
        iconName: "figure.run",
        brandName: "FitApp"
    )

    let renderer = ShareCardRenderer()
    let image = await renderer.render(content: content, style: .branded)
    #expect(image != nil)
    #expect(image!.size.width > 0)
    #expect(image!.size.height > 0)
}

@Test
func allStylesRenderSuccessfully() async throws {
    let content = QuoteCardContent(
        quote: "Test quote",
        attribution: "Author",
        brandName: "App"
    )

    let renderer = ShareCardRenderer()
    for style in ShareCardStyle.allCases {
        let image = await renderer.render(content: content, style: style)
        #expect(image != nil, "Style \(style) failed to render")
    }
}

@Test
func qrCodeGeneratesValidImage() throws {
    let image = QRCodeGenerator.generate(
        from: "https://example.com/share/123",
        size: CGSize(width: 100, height: 100)
    )
    #expect(image != nil)
}
```

## Common Patterns

### Achievement Card
Best for: gamification, milestones, unlockables.
- Large icon or badge at top
- Achievement title prominently displayed
- Metric or point value highlighted
- App branding at bottom

### Statistics Card
Best for: fitness, finance, productivity apps.
- Grid or list of stat items with labels and values
- Optional trend indicators (up/down arrows)
- Date range context
- App branding at bottom

### Quote Card
Best for: reading, journaling, social apps.
- Large quotation marks or decorative element
- Quote text centered with elegant typography
- Attribution below quote
- Minimal branding

## Gotchas

### Image Quality for Different Platforms
- Instagram: JPEG works, but use high quality (0.9+) to avoid artifacts on text
- Twitter/X: PNG preserves text sharpness but larger file size
- Use `@2x` scale factor in `ImageRenderer` for Retina-quality output
- Always render at the display scale: `renderer.scale = UIScreen.main.scale` (iOS) or `NSScreen.main?.backingScaleFactor` (macOS)

### Memory for Large Renders
- A 1080x1920 card at `@3x` scale = 3240x5760 pixels = ~75 MB in memory
- Render at `@2x` maximum for share cards — social platforms compress anyway
- Release the rendered image after sharing completes
- Use `autoreleasepool` if generating multiple cards in sequence

### ImageRenderer Limitations
- `ImageRenderer` is `@MainActor` — must be called from the main thread
- Minimum iOS 16 / macOS 13
- Does not render `Map`, `Camera`, or `WebView` content
- Animations are not captured — renders a single frame
- `ScrollView` content beyond visible bounds is not rendered

### Cross-Platform Rendering
- On macOS, `ImageRenderer` produces `NSImage` via `nsImage` property
- On iOS, use `uiImage` property
- Use the `PlatformImage` typealias pattern for shared code
- `UIGraphicsImageRenderer` is UIKit-only — prefer `ImageRenderer` for SwiftUI cross-platform code

### ShareLink Gotchas
- `ShareLink` requires the shared item to conform to `Transferable`
- `Image` conforms to `Transferable` on iOS 16+ / macOS 13+
- For custom share items, implement `Transferable` with `DataRepresentation`
- `ShareLink` renders as a button — style it to match your UI

## References

- **templates.md** — All production Swift templates
- Related: `generators/image-loading` — Cache rendered share card images
- Related: `ios/deep-linking` — Generate deep links for QR codes

### Source: `generators/spotlight-indexing`

# Spotlight Indexing Generator

Generate production Core Spotlight indexing infrastructure — makes app content searchable via Spotlight (and Siri suggestions). Indexes items with rich attributes, handles search continuation into your app, and manages index lifecycle.

## When This Skill Activates

Use this skill when the user:
- Asks to "add spotlight search" or "spotlight indexing"
- Mentions "core spotlight" or "CSSearchableItem"
- Wants to make "searchable content" or "index content" for system search
- Asks about "system search" integration or "Siri suggestions"
- Wants content to appear in Spotlight results
- Mentions "NSUserActivity" for search or handoff

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Existing CoreSpotlight Detection
Search for existing Spotlight code:
```
Glob: **/*Spotlight*.swift, **/*Searchable*.swift, **/*CSSearchable*.swift
Grep: "CoreSpotlight" or "CSSearchableIndex" or "CSSearchableItem"
```

If existing Spotlight code found:
- Ask if user wants to replace or augment it
- If augmenting, identify what's missing and generate only those pieces

### 3. Deep Linking Detection
Search for existing deep link or navigation setup:
```
Grep: "NavigationPath" or "onOpenURL" or "NSUserActivity" or "DeepLink"
```

If deep linking exists:
- Integrate SpotlightSearchHandler with existing router
- If not, generate standalone handler with guidance on wiring it up

### 4. Entitlements Check
Verify CoreSpotlight doesn't require special entitlements (it doesn't — it's a standard framework), but check if the app uses App Groups for shared index across extensions.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Content types to index?**
   - Articles / blog posts (titles, body text, authors)
   - Products (name, description, price, images)
   - Contacts / people (name, phone, email)
   - Tasks / reminders (title, due date, priority)
   - Custom (user describes their model)

2. **Include thumbnails?**
   - Yes — index thumbnail images alongside text attributes
   - No — text-only attributes (smaller index, faster)

3. **Indexing strategy?**
   - Batch indexing (index all content at once, e.g., on first launch or sync)
   - Incremental indexing (index items as they're created/updated/deleted)
   - Both (batch for initial load, incremental for changes)

4. **Include Siri suggestions / shortcuts?**
   - Yes — make content eligible for Siri suggestions and predictions
   - No — Spotlight search only

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.
Read `patterns.md` for architecture guidance and best practices.

### Step 2: Create Core Files
Generate these files:
1. `SpotlightIndexable.swift` — Protocol any model can conform to
2. `SpotlightIndexManager.swift` — Actor wrapping CSSearchableIndex with batching
3. `SpotlightAttributeBuilder.swift` — Fluent builder for CSSearchableItemAttributeSet

### Step 3: Create Integration Files
4. `SpotlightSearchHandler.swift` — Handles NSUserActivity continuation from Spotlight taps

### Step 4: Create Optional Files
Based on configuration:
- `SpotlightSyncModifier.swift` — If incremental indexing selected (ViewModifier for auto index/deindex)
- Add NSUserActivity + eligibleForSearch if Siri suggestions selected

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/SpotlightIndexing/`
- If `App/` exists -> `App/SpotlightIndexing/`
- Otherwise -> `SpotlightIndexing/`

## Output Format

After generation, provide:

### Files Created
```
SpotlightIndexing/
├── SpotlightIndexable.swift        # Protocol for indexable models
├── SpotlightIndexManager.swift     # Actor-based index management
├── SpotlightAttributeBuilder.swift # Fluent attribute builder
├── SpotlightSearchHandler.swift    # Handle Spotlight tap continuation
└── SpotlightSyncModifier.swift     # Auto index/deindex ViewModifier (optional)
```

### Integration with Content Creation/Update

**Make a model searchable:**
```swift
// Conform your model to SpotlightIndexable
struct Article: SpotlightIndexable {
    let id: UUID
    let title: String
    let body: String
    let author: String
    let tags: [String]

    var spotlightID: String { id.uuidString }
    var spotlightTitle: String { title }
    var spotlightDescription: String { String(body.prefix(300)) }
    var spotlightKeywords: [String] { tags + [author] }
    var spotlightThumbnailData: Data? { nil }
    var spotlightDomainIdentifier: String { "com.myapp.articles" }
}
```

**Index on create, remove on delete:**
```swift
func createArticle(_ article: Article) async throws {
    try await repository.save(article)
    await SpotlightIndexManager.shared.index(items: [article])
}

func deleteArticle(_ article: Article) async throws {
    try await repository.delete(article)
    await SpotlightIndexManager.shared.remove(identifiers: [article.spotlightID])
}
```

**Batch reindex (e.g., on first launch):**
```swift
func reindexAllContent() async {
    let articles = await repository.fetchAll()
    await SpotlightIndexManager.shared.reindexAll(items: articles, domain: "com.myapp.articles")
}
```

**Handle Spotlight tap (App or Scene delegate):**
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(CSSearchableItemActionType) { activity in
                    SpotlightSearchHandler.shared.handle(activity)
                }
        }
    }
}
```

**Auto index/deindex with ViewModifier:**
```swift
struct ArticleDetailView: View {
    let article: Article

    var body: some View {
        ScrollView {
            Text(article.body)
        }
        .spotlightIndexed(article)  // Indexes on appear, deindexes on disappear
    }
}
```

### Testing

```swift
@Test
func indexAndRetrieveItem() async throws {
    let manager = SpotlightIndexManager(index: MockSearchableIndex())
    let article = Article(id: UUID(), title: "Test", body: "Body", author: "Author", tags: ["swift"])

    await manager.index(items: [article])
    #expect(manager.indexedCount == 1)
}

@Test
func batchIndexChunksCorrectly() async throws {
    let mockIndex = MockSearchableIndex()
    let manager = SpotlightIndexManager(index: mockIndex, batchSize: 10)
    let items = (0..<25).map { makeArticle(index: $0) }

    await manager.index(items: items)
    #expect(mockIndex.indexCallCount == 3)  // 10 + 10 + 5
}

@Test
func handleSpotlightContinuation() async throws {
    let handler = SpotlightSearchHandler()
    let activity = NSUserActivity(activityType: CSSearchableItemActionType)
    activity.userInfo = [CSSearchableItemActivityIdentifier: "article-123"]

    let itemID = handler.extractItemID(from: activity)
    #expect(itemID == "article-123")
}
```

## Common Patterns

### Index Item on Create
Every time a model is created or updated, index it immediately:
```swift
await SpotlightIndexManager.shared.index(items: [newItem])
```

### Remove on Delete
When content is deleted, remove it from the index:
```swift
await SpotlightIndexManager.shared.remove(identifiers: [item.spotlightID])
```

### Batch Reindex
After app update or data migration, reindex all content:
```swift
await SpotlightIndexManager.shared.reindexAll(items: allItems, domain: "com.myapp.articles")
```

### Handle Search Continuation
When user taps a Spotlight result, the app receives an NSUserActivity. Extract the item ID and navigate:
```swift
.onContinueUserActivity(CSSearchableItemActionType) { activity in
    if let id = activity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
        navigationPath.append(Route.detail(id: id))
    }
}
```

## Gotchas

### Index Size Limits
- CSSearchableIndex has no hard documented limit, but Apple recommends keeping index under ~10,000 items for best performance
- For very large datasets, index only the most relevant/recent items
- Use `expirationDate` on CSSearchableItem to auto-expire stale entries

### Thumbnail Size for Performance
- Keep thumbnails small: 300x300 pixels max, JPEG compressed
- Large thumbnails slow down indexing and increase on-disk index size
- Use `Data` (JPEG/PNG) not full PlatformImage objects

### CSSearchableIndex.default() Thread Safety
- `CSSearchableIndex.default()` returns a singleton but its methods are NOT actor-isolated
- Wrap all calls in an actor (SpotlightIndexManager) to prevent data races
- Never call `indexSearchableItems` from multiple threads simultaneously

### Handling App Launch from Spotlight Tap
- The app may be cold-launched — ensure navigation state is ready before handling the activity
- Use `.onContinueUserActivity` in SwiftUI, not `application(_:continue:)` alone
- The activity type is `CSSearchableItemActionType` (a constant from CoreSpotlight)

### Index Maintenance on App Update
- After a data model change, old indexed items may have stale attributes
- Call `removeAll(domain:)` then re-index on first launch after update
- Store indexed schema version in UserDefaults to detect when reindex is needed

### Domain Identifiers
- Always set `domainIdentifier` on items — it allows bulk removal by domain
- Use reverse-DNS style: `"com.myapp.articles"`, `"com.myapp.products"`
- Without domains, you can only remove by individual identifier or remove everything

## References

- **templates.md** — All production Swift templates for Spotlight indexing
- **patterns.md** — CSSearchableItemAttributeSet content types, batch strategies, Siri suggestions, testing
- Related: `generators/deep-linking` — Deep link routing from Spotlight taps

### Source: `generators/state-restoration`

# State Restoration Generator

Generate production state restoration infrastructure that saves and restores app state (selected tab, scroll position, navigation path, form data) across launches and background termination. Uses Codable state models, @SceneStorage, @AppStorage, and custom file-based persistence.

## When This Skill Activates

Use this skill when the user:
- Asks to "add state restoration" or "restore state"
- Wants to "save app state" or "persist UI state"
- Mentions "preserve navigation" or "remember navigation path"
- Asks to "remember scroll position" or "restore scroll position"
- Wants the app to "resume where left off" or "remember where I was"
- Asks about "saving form drafts" or "preserve form data"
- Mentions "tab selection persistence" or "remember selected tab"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 17+ / macOS 14+ for @Observable)
- [ ] Check for existing state saving code
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing state restoration:
```
Glob: **/*StateRestoration*.swift, **/*AppState*.swift, **/*SceneStorage*.swift
Grep: "SceneStorage" or "NavigationPath" or "selectedTab" or "scrollPosition"
```

If existing state management found:
- Ask if user wants to replace or extend it
- If extending, integrate with the existing approach

### 3. Navigation Pattern Detection
Determine which navigation pattern the app uses:
```
Grep: "NavigationStack" or "NavigationSplitView" or "TabView" or "NavigationLink"
```

This affects which restoration components to generate.

## Configuration Questions

Ask user via AskUserQuestion:

1. **What state to restore?** (multi-select)
   - Navigation path (back stack, detail selection)
   - Selected tab (TabView selection)
   - Scroll position (list/scroll view offset)
   - Form data (unsaved drafts and input fields)
   - All of the above — recommended

2. **Storage method?**
   - @SceneStorage / @AppStorage (simple, per-scene, limited to basic types)
   - UserDefaults (shared across scenes, limited size)
   - File-based (Codable to JSON file in Application Support — recommended for complex state)

3. **Restore behavior?**
   - Always restore (seamless resume on every launch)
   - Time-limited (restore only if last session was within N minutes) — recommended
   - Ask user (show "Resume where you left off?" prompt)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `AppState.swift` — Codable struct capturing all restorable state
2. `StateRestorationManager.swift` — @Observable manager with auto-save and restore

### Step 3: Create Feature Files
Based on configuration:
3. `NavigationStateModifier.swift` — If navigation path selected
4. `ScrollRestorationModifier.swift` — If scroll position selected
5. `TabRestorationModifier.swift` — If tab selection selected
6. `FormDraftManager.swift` — If form data selected

### Step 4: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/StateRestoration/`
- If `App/` exists -> `App/StateRestoration/`
- Otherwise -> `StateRestoration/`

## Output Format

After generation, provide:

### Files Created
```
StateRestoration/
├── AppState.swift                  # Codable state model
├── StateRestorationManager.swift   # Auto-save/restore orchestrator
├── NavigationStateModifier.swift   # Navigation path persistence (optional)
├── ScrollRestorationModifier.swift # Scroll position persistence (optional)
├── TabRestorationModifier.swift    # Tab selection persistence (optional)
└── FormDraftManager.swift          # Form draft auto-save (optional)
```

### Integration Steps

**Basic setup in App struct:**
```swift
@main
struct MyApp: App {
    @State private var stateManager = StateRestorationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stateManager)
        }
    }
}
```

**Restore navigation path:**
```swift
struct ContentView: View {
    @Environment(StateRestorationManager.self) private var stateManager

    var body: some View {
        @Bindable var sm = stateManager
        NavigationStack(path: $sm.navigationPath) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    RouteView(route: route)
                }
        }
        .modifier(NavigationStateModifier(stateManager: stateManager))
    }
}
```

**Restore tab selection:**
```swift
struct MainTabView: View {
    @Environment(StateRestorationManager.self) private var stateManager

    var body: some View {
        @Bindable var sm = stateManager
        TabView(selection: $sm.selectedTab) {
            HomeTab().tag(0)
            SearchTab().tag(1)
            ProfileTab().tag(2)
        }
        .modifier(TabRestorationModifier(stateManager: stateManager))
    }
}
```

**Restore scroll position:**
```swift
struct ItemListView: View {
    let items: [Item]

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(items) { item in
                    ItemRow(item: item)
                }
            }
        }
        .modifier(ScrollRestorationModifier(scrollViewID: "item-list"))
    }
}
```

**Auto-save form drafts:**
```swift
struct ComposeView: View {
    @State private var draftManager = FormDraftManager(formID: "compose")
    @State private var title = ""
    @State private var body = ""

    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextEditor(text: $body)
        }
        .onAppear { draftManager.restore(into: &title, &body, keys: "title", "body") }
        .onChange(of: title) { draftManager.save(key: "title", value: title) }
        .onChange(of: body) { draftManager.save(key: "body", value: body) }
        .onSubmit { draftManager.clearDraft() }
    }
}
```

### Testing

```swift
@Test
func stateRestoredFromDisk() async throws {
    let manager = StateRestorationManager(storage: .file(directory: tempDir))
    manager.selectedTab = 2
    manager.saveState()

    let restored = StateRestorationManager(storage: .file(directory: tempDir))
    restored.restoreState()
    #expect(restored.selectedTab == 2)
}

@Test
func timeLimitedRestoreExpires() async throws {
    let manager = StateRestorationManager(
        storage: .file(directory: tempDir),
        restoreBehavior: .timeLimited(minutes: 30)
    )
    // Simulate state saved 60 minutes ago
    manager.appState.lastSavedDate = Date().addingTimeInterval(-3600)
    manager.saveState()

    let restored = StateRestorationManager(
        storage: .file(directory: tempDir),
        restoreBehavior: .timeLimited(minutes: 30)
    )
    restored.restoreState()
    #expect(restored.selectedTab == 0) // Default, not restored
}

@Test
func formDraftClearedOnSubmit() async throws {
    let draft = FormDraftManager(formID: "test", storage: .file(directory: tempDir))
    draft.save(key: "title", value: "My Draft")
    #expect(draft.value(for: "title") == "My Draft")

    draft.clearDraft()
    #expect(draft.value(for: "title") == nil)
}
```

## Common Patterns

### Save Navigation Path with Codable Routes
```swift
enum Route: Codable, Hashable {
    case detail(id: UUID)
    case settings
    case profile(userID: String)
}

// NavigationPath supports Codable serialization
let representation = navigationPath.codable
let data = try JSONEncoder().encode(representation)
```

### Restore Tab Selection with String Tags
```swift
// Use String tags instead of Int for readability and stability
TabView(selection: $stateManager.selectedTab) {
    HomeView().tag("home")
    SearchView().tag("search")
    ProfileView().tag("profile")
}
```

### Preserve Form Draft with Debounced Save
```swift
// Save draft only after user pauses typing (1 second)
.onChange(of: textContent) {
    draftManager.save(key: "content", value: textContent)
    // Internally debounced — won't write to disk on every keystroke
}
```

## Gotchas

- **@SceneStorage only works with simple types** — String, Int, Double, Bool, URL, Data. For complex state like NavigationPath, use `NavigationPath.CodableRepresentation` converted to Data.
- **NavigationPath Codable limitations** — All types in the path must conform to both Codable and Hashable. If any route type changes between versions, decoding fails silently. Always wrap in try/catch and fall back to empty path.
- **Background termination vs force quit** — State is saved when the app enters background (via `scenePhase`). Force quit from the app switcher does NOT trigger `scenePhase` change on iOS. Save state on every significant change, not just on backgrounding.
- **State migration between versions** — When adding new fields to AppState, provide default values so old JSON files decode without error. Consider a `stateVersion` field for breaking changes.
- **@SceneStorage is per-scene** — On iPad with multiple windows, each scene has its own @SceneStorage. This is usually correct (each window has its own state) but be aware when sharing state across scenes.
- **Avoid saving sensitive data** — Never persist passwords, tokens, or PII in state restoration files. Use Keychain for sensitive data.

## References

- **templates.md** — All production Swift templates
- Related: `generators/persistence-setup` — Core Data / SwiftData persistence layer
- Related: `generators/deep-linking` — URL-based navigation restoration

### Source: `generators/streak-tracker`

# Streak Tracker Generator

Generate a production streak tracking system that records consecutive days of user activity, calculates current and longest streaks, handles timezone-aware day boundaries, supports streak freeze/protection passes, and schedules streak-at-risk local notifications.

## When This Skill Activates

Use this skill when the user:
- Asks to "add streaks" or "daily streak" tracking
- Wants "streak tracking" or "consecutive days" counting
- Mentions "engagement streaks" or "habit tracking"
- Asks about "streak freeze" or "streak protection"
- Wants "streak-at-risk" notifications or reminders
- Mentions "login streak" or "activity streak"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 17+ / macOS 14+ for @Observable and SwiftData)
- [ ] Check for SwiftData availability and existing model container setup
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing streak or habit tracking:
```
Glob: **/*Streak*.swift, **/*Habit*.swift, **/*DailyTrack*.swift
Grep: "streak" or "consecutiveDays" or "habitTrack" or "dailyStreak"
```

If existing streak/habit system found:
- Ask if user wants to replace or extend it
- If extending, generate only the missing components

### 3. Platform Detection
Determine if generating for iOS (UNUserNotificationCenter) or macOS (UNUserNotificationCenter available on macOS 11+) or both.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Streak type?**
   - Daily (consecutive calendar days) -- recommended
   - Weekly (at least one activity per calendar week)
   - Custom interval (every N hours/days)

2. **Storage backend?**
   - SwiftData (recommended for iOS 17+ / macOS 14+)
   - UserDefaults (lightweight, no model container needed)

3. **Include streak freeze/protection?**
   - Yes — users get limited freeze passes to preserve streaks on missed days
   - No — strict consecutive tracking only

4. **Streak-at-risk notifications?**
   - Yes — schedule a local notification (e.g., 8 PM) if no activity recorded today
   - No — no notifications

5. **Additional features?** (multi-select)
   - Calendar heat map view (visual grid of activity days)
   - Streak badge view (compact count with animation)
   - Milestone celebrations (7-day, 30-day, 100-day, etc.)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `StreakRecord.swift` — SwiftData @Model for activity records
2. `StreakManager.swift` — @Observable class: record activity, calculate streaks, manage freezes
3. `StreakError.swift` — Error types for streak operations

### Step 3: Create UI Files
4. `StreakCalendarView.swift` — Grid showing days with/without activity
5. `StreakBadgeView.swift` — Compact badge with streak count and animation

### Step 4: Create Optional Files
Based on configuration:
- `StreakFreeze.swift` — If streak freeze selected
- `StreakNotificationScheduler.swift` — If notifications selected

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/StreakTracking/`
- If `App/` exists -> `App/StreakTracking/`
- Otherwise -> `StreakTracking/`

## Output Format

After generation, provide:

### Files Created
```
StreakTracking/
├── StreakRecord.swift               # SwiftData model for activity records
├── StreakManager.swift              # Core streak calculation engine
├── StreakError.swift                # Error types
├── StreakCalendarView.swift         # Calendar heat map view
├── StreakBadgeView.swift            # Compact animated badge
├── StreakFreeze.swift               # Freeze/protection passes (optional)
└── StreakNotificationScheduler.swift # Streak-at-risk reminders (optional)
```

### Integration Steps

**Set up the model container (SwiftData):**
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [StreakRecord.self, StreakFreeze.self])
    }
}
```

**Record activity on user action:**
```swift
struct LessonCompleteView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var streakManager: StreakManager?

    var body: some View {
        Button("Complete Lesson") {
            Task {
                try await streakManager?.recordActivity(type: "lesson")
            }
        }
        .onAppear {
            streakManager = StreakManager(modelContext: modelContext)
        }
    }
}
```

**Display the current streak:**
```swift
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var streakManager: StreakManager?

    var body: some View {
        VStack {
            if let manager = streakManager {
                StreakBadgeView(streak: manager.currentStreak)
                Text("Longest: \(manager.longestStreak) days")
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            streakManager = StreakManager(modelContext: modelContext)
            Task { await streakManager?.refresh() }
        }
    }
}
```

**Show the calendar heat map:**
```swift
struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var streakManager: StreakManager?

    var body: some View {
        if let manager = streakManager {
            StreakCalendarView(manager: manager)
        }
    }
}
```

**Use a streak freeze:**
```swift
Button("Use Streak Freeze") {
    if streakManager.useStreakFreeze() {
        // Freeze applied — streak preserved
    } else {
        // No freezes available
    }
}
```

### Testing

```swift
import Testing
import SwiftData

@Test
func recordingActivityIncrementsStreak() async throws {
    let container = try ModelContainer(
        for: StreakRecord.self, StreakFreeze.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let manager = StreakManager(modelContext: context)

    // Record activity for today
    try await manager.recordActivity(type: "workout")
    await manager.refresh()

    #expect(manager.currentStreak == 1)
}

@Test
func consecutiveDaysBuildStreak() async throws {
    let container = try ModelContainer(
        for: StreakRecord.self, StreakFreeze.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let manager = StreakManager(modelContext: context)

    // Simulate 3 consecutive days
    let calendar = Calendar.current
    for daysAgo in (0...2).reversed() {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: .now)!
        try await manager.recordActivity(type: "workout", date: date)
    }
    await manager.refresh()

    #expect(manager.currentStreak == 3)
    #expect(manager.longestStreak == 3)
}

@Test
func missedDayBreaksStreak() async throws {
    let container = try ModelContainer(
        for: StreakRecord.self, StreakFreeze.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let manager = StreakManager(modelContext: context)

    let calendar = Calendar.current
    // Day 3 ago and Day 2 ago (streak of 2), then skip Day 1, record today
    let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: .now)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: .now)!
    try await manager.recordActivity(type: "workout", date: threeDaysAgo)
    try await manager.recordActivity(type: "workout", date: twoDaysAgo)
    try await manager.recordActivity(type: "workout", date: .now)
    await manager.refresh()

    #expect(manager.currentStreak == 1) // Gap broke the streak
    #expect(manager.longestStreak == 2) // Previous streak preserved
}

@Test
func streakFreezePreservesStreak() async throws {
    let container = try ModelContainer(
        for: StreakRecord.self, StreakFreeze.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = ModelContext(container)
    let manager = StreakManager(modelContext: context)

    let calendar = Calendar.current
    // Record 2 days ago and today — gap of 1 day
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: .now)!
    try await manager.recordActivity(type: "workout", date: twoDaysAgo)
    manager.addStreakFreeze(count: 1)
    let used = manager.useStreakFreeze()
    try await manager.recordActivity(type: "workout", date: .now)
    await manager.refresh()

    #expect(used == true)
    #expect(manager.currentStreak == 3) // 2 days ago + freeze + today
}
```

## Common Patterns

### Check In for Today
```swift
// Record a single check-in per day (idempotent)
try await streakManager.recordActivity(type: "daily-check-in")
// StreakManager deduplicates — calling twice on the same day is safe
```

### Query Streak State
```swift
let current = streakManager.currentStreak    // Consecutive days up to today
let longest = streakManager.longestStreak    // All-time best
let atRisk = streakManager.isStreakAtRisk    // No activity today yet
let hasActivity = streakManager.hasActivityToday
```

### Streak Freeze
```swift
// Grant freeze passes (e.g., as a reward or purchase)
streakManager.addStreakFreeze(count: 2)

// Use a freeze to cover a missed day
let success = streakManager.useStreakFreeze()
// Returns false if no freezes remaining or no gap to fill
```

## Gotchas & Edge Cases

### Timezone and Day Boundary Handling
Always use `Calendar.current.startOfDay(for:)` to normalize dates. Never compare raw `Date` values for "same day" checks — a user active at 11:59 PM and 12:01 AM has activity on two different calendar days but should not get a gap. The `StreakManager` uses the user's local calendar for all day boundary calculations.

### Midnight Edge Cases
If a user completes an activity exactly at midnight, `startOfDay(for:)` may place it on the new day. The templates handle this by recording the timestamp as well as the normalized date, so the raw data is preserved for debugging.

### Device Clock Manipulation
Users can change their device clock to fake streak activity. Mitigations:
- Store `createdAt` timestamps alongside `activityDate` and flag anomalies (e.g., `createdAt` is before a previously recorded `createdAt`)
- For server-synced apps, validate streaks server-side
- For local-only apps, accept that determined users can game it — focus on honest users

### Calendar vs Gregorian Day Changes
Different calendars (Islamic, Hebrew, Japanese) have different day boundaries and week structures. The templates use `Calendar.current` which respects the user's locale. If your app requires a fixed calendar (e.g., Gregorian for global leaderboards), pass an explicit `Calendar(identifier: .gregorian)` to `StreakManager`.

### Duplicate Activity on Same Day
`StreakManager.recordActivity` is idempotent per calendar day per activity type. Calling it multiple times on the same day creates only one `StreakRecord`. This prevents accidental double-counting.

### App Reinstall / Data Loss
SwiftData stores persist across app updates but are lost on reinstall. For critical streak data, consider syncing to CloudKit or a backend. The templates include a `lastSyncDate` hook in `StreakManager` for this purpose.

### App Store Guidelines
- **Guideline 4.5.4**: Streak-reminder pushes ("don't lose your 12-day streak!") are marketing notifications — they require explicit opt-in consent in your UI plus an in-app opt-out, not just the system permission prompt.
- **Guideline 3.1.1**: If streak freezes or repairs are sold, they are digital content and must go through IAP — never an external purchase link. The one sanctioned exception is the US storefront with the StoreKit External Purchase Link entitlement (see `monetization/external-purchases`); everywhere else the rule stands.
- **Guideline 4.3 (Spam)**: A streak mechanic doesn't differentiate a thin app. If this is one of several similar apps on your account, run `app-store/originality-check` before submitting.

## References

- **templates.md** — All production Swift templates for streak tracking
- Related: `generators/push-notifications` — Push notification setup for streak reminders
- Related: `generators/milestone-celebration` — Celebrate streak milestones with animations

### Source: `generators/tipkit-generator`

# TipKit Generator

Generate a complete TipKit setup for contextual tips and feature discovery, including tip definitions, rules, display frequency, inline and popover presentation, and testing utilities.

## When This Skill Activates

Use this skill when the user:
- Asks to "add tips" or "add TipKit"
- Mentions "contextual tips" or "feature discovery"
- Wants "popover tips" or "inline tips"
- Asks about "coach marks" or "user education"
- Mentions "onboarding hints" or "tip prompts"
- Wants to "highlight new features" or "guide users"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (TipKit requires iOS 17+ / macOS 14+)
- [ ] Identify if SwiftUI or UIKit project
- [ ] Find App entry point location for Tips.configure()
- [ ] Check for existing TipKit implementations

### 2. Conflict Detection
Search for existing TipKit usage:
```
Glob: **/*Tip*.swift
Grep: "import TipKit" or "Tips.configure"
```

If found, ask user:
- Extend existing tip infrastructure?
- Replace existing tips?

## Configuration Questions

Ask user via AskUserQuestion:

1. **What features need tips?**
   - List the features or UI elements that should have tips
   - Example: "search bar, filter button, swipe-to-delete gesture"

2. **Tip presentation style?** (per tip or general preference)
   - Inline (TipView embedded in layout)
   - Popover (attached to a control)
   - Both

3. **Rule types needed?**
   - Parameter-based (show after user meets condition, e.g., has viewed a screen 3 times)
   - Event-based (show after user performs an action N times)
   - Both

4. **Display frequency?**
   - Immediate (tips show as soon as eligible)
   - Hourly
   - Daily
   - Weekly
   - Monthly

5. **Tip ordering?**
   - Independent (tips show whenever eligible)
   - Ordered (use TipGroup to show tips in sequence)

## Generation Process

### Step 1: Read Templates

Read the templates file for code patterns:
```
Read("skills/generators/tipkit-generator/templates.md")
```

### Step 2: Create Core Files

Generate these files based on configuration:
1. `Tips/` directory with one file per tip (e.g., `SearchTip.swift`, `FilterTip.swift`)
2. `Tips/TipEvents.swift` - Centralized event definitions
3. `Tips/TipsConfiguration.swift` - Tips.configure() setup and testing utilities

### Step 3: Determine File Location

Check project structure:
- If `Sources/` exists -> `Sources/Tips/`
- If `App/` exists -> `App/Tips/`
- Otherwise -> `Tips/`

### Step 4: Integrate Tips

- Add `Tips.configure()` call in App entry point
- Add `TipView` or `.popoverTip()` at the appropriate view locations
- Wire up event donation at action sites
- Wire up tip invalidation where appropriate

## Output Format

After generation, provide:

### Files Created
```
Sources/Tips/
├── SearchTip.swift            # Tip with rules and options
├── FilterTip.swift            # Another tip definition
├── TipEvents.swift            # Centralized event definitions
└── TipsConfiguration.swift    # Tips.configure() + testing helpers
```

### Integration Steps

**App Entry Point (Required):**
```swift
import TipKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? Tips.configure([
                        .displayFrequency(.daily),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
    }
}
```

**Inline Tip:**
```swift
import TipKit

struct SearchView: View {
    let searchTip = SearchTip()

    var body: some View {
        VStack {
            TipView(searchTip)
            SearchBar()
        }
    }
}
```

**Popover Tip:**
```swift
import TipKit

struct ToolbarView: View {
    let filterTip = FilterTip()

    var body: some View {
        Button("Filter", systemImage: "line.3.horizontal.decrease.circle") {
            // action
        }
        .popoverTip(filterTip)
    }
}
```

**Event Donation (at action site):**
```swift
Button("Search") {
    performSearch()
    SearchTip.searchPerformed.donate()
}
```

**Tip Invalidation (when tip is no longer relevant):**
```swift
func onFeatureUsed() {
    // User discovered the feature, invalidate the tip
    searchTip.invalidate(reason: .actionPerformed)
}
```

### Testing Instructions

1. **Reset DataStore between runs:**
   ```swift
   // Add to a debug menu or call in preview
   try? Tips.resetDatastore()
   ```

2. **Show all tips for testing:**
   ```swift
   // Ignores rules and frequency -- shows everything
   Tips.showAllTipsForTesting()
   ```

3. **Show specific tips for testing:**
   ```swift
   Tips.showTipsForTesting([SearchTip.self])
   ```

4. **Test scenarios:**
   - Launch app fresh -- eligible tips should appear per display frequency
   - Perform actions that donate events -- event-based tips should appear when thresholds met
   - Tap tip close button -- tip should not reappear
   - Invalidate tip programmatically -- tip should dismiss and not reappear

## Common Gotchas

1. **Forgetting Tips.configure()** -- Tips will never appear if you do not call `Tips.configure()` before any tip is displayed. This must happen early, typically in the App `body` or `.task`.

2. **Rules not evaluating** -- Parameter-based rules require you to set the parameter value explicitly. If you define `@Parameter static var hasSeenFeature = false` but never set it to `true`, the rule never passes.

3. **DataStore conflicts in tests** -- If you run unit tests and the app simultaneously, they may share the same DataStore. Use `.datastoreLocation(.url(...))` to isolate them.

4. **Display frequency blocking tips** -- If you set `.displayFrequency(.daily)` and a tip was already shown today, no new tips will appear until tomorrow. Use `.immediate` during development.

5. **Tips not dismissing after invalidation** -- You must hold a reference to the tip instance and call `.invalidate(reason:)` on that instance. Creating a new instance and invalidating it does nothing to the displayed tip.

6. **TipGroup ordering ignored** -- Tips in a TipGroup only show in order if their rules are all satisfied. If Tip B's rules pass but Tip A's do not, neither will show (Tip A blocks Tip B).

## Tip Content Rules (WWDC23)

Good tips are **actionable, instructional, and easy to remember**:
- **Title** = a direct action phrase naming the feature ("Swipe to Save a Recipe"), not a greeting
- **Message** = the benefit, or short instructions that stand alone without needing more context

Never use tips for:
- ❌ Promotion (upsells, sales, "try Pro")
- ❌ Error messages or system status
- ❌ Purely informational content with no action to take
- ❌ Features too complex to explain in one short tip

### Eligibility and cadence specifics

- **Event rules accept date modifiers**: `$0.donations.donatedWithin(.days(5)).count >= 3` — "3 times in the past 5 days", not just a lifetime count
- **Associated types on event donations** scope a rule to a specific entity: donate the item's ID with the event and require N donations *for that ID*, so the tip fires on the exact item the user keeps revisiting
- The **`IgnoresDisplayFrequency(true)` tip option** exempts an urgent tip from the global `.displayFrequency` cadence
- The **`MaxDisplayCount(n)` tip option** auto-stops a tip after N impressions, even if it is never dismissed or invalidated

## Patterns

### Good Patterns

- One tip struct per file for clarity
- Centralize event definitions in a single file
- Use `.actionPerformed` invalidation reason when the user completes the action the tip describes
- Use `TipGroup` when tips should appear in a logical sequence
- Provide a debug/testing menu that calls `Tips.resetDatastore()`
- Use meaningful tip IDs that describe the feature

### Bad Patterns

- Defining all tips in a single massive file
- Forgetting to call `Tips.configure()` in the App entry point
- Using `.immediate` display frequency in production (overwhelming users)
- Hardcoding tip text instead of using localized strings for shipped apps
- Creating a new tip instance to invalidate instead of using the displayed instance
- Placing `TipView` inside a `ScrollView` without considering layout impact

## References

- **templates.md** - Code templates for tips, rules, configuration, and TipGroup
