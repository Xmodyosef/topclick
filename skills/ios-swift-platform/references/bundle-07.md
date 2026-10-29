# Integrated Reference Bundle 07

Combines 12 related source skills from `ios-swift-platform` into one navigable reference file.

## Source map

- `ios_1296/run-device/SKILL.reference.md`
- `macos/SKILL.reference.md`
- `macos/app-planner/SKILL.reference.md`
- `macos/appkit-swiftui-bridge/SKILL.reference.md`
- `macos/macos-capabilities/SKILL.reference.md`
- `macos/swiftdata-architecture/SKILL.reference.md`
- `macos-appkit-bridge/SKILL.reference.md`
- `macos-notarization-packager/SKILL.reference.md`
- `macos-signing-inspector/SKILL.reference.md`
- `macos-swiftpm-runner/SKILL.reference.md`
- `macos-swiftui-architect/SKILL.reference.md`
- `macos-telemetry-probe/SKILL.reference.md`

## Integrated guidance

### Source: `ios_1296/run-device`

# Run on a Physical Device (CLI)

Builds, signs, installs, and launches an app on a **connected physical device**
straight from the terminal — no Xcode Run button. The companion `run-simulator`
skill covers the Simulator; this is the hardware path, which uses a different
toolchain: `devicectl` (not `simctl`), real code signing, and an external tool
for screenshots.

Building proves the code typechecks and signs; launching proves it installs and
runs on real hardware. A crash on launch or a failed install is a failure.

## When This Skill Activates

Use when the user wants to:
- Run / test their app on a real iPhone or iPad from the CLI
- Install a build on a device without opening Xcode
- Reproduce a device-only bug (camera, sensors, performance, push)
- Screenshot the app running on hardware

Not for the Simulator (use `run-simulator`) and not for `xcodebuild test`.

## Prerequisites (one-time, partly interactive — cannot be scripted)

1. **Device connected** by USB (or paired over Wi-Fi).
2. **Developer Mode ON** (iOS 16+): Settings → Privacy & Security → Developer
   Mode → on → restart. There is no CLI to enable this.
3. **Device trusted/paired**: the first connection shows "Trust This Computer?"
   on the device — tap Trust. `devicectl` pairs once trusted.
4. **Automatic signing configured**: the target needs `CODE_SIGN_STYLE = Automatic`
   and a `DEVELOPMENT_TEAM`, and the signing Apple ID must already be logged into
   Xcode (Settings → Accounts) so `-allowProvisioningUpdates` can mint profiles.
   A free personal team works but apps expire after 7 days.

Confirm reachability before building:

```bash
xcrun devicectl list devices
```

In **Xcode 27** the table lists simulators too (a `Reality` column says `physical` or
`simulated`), device names contain spaces, and the **Identifier** column shows the hardware
UDID with a `(UDID)` suffix. Don't parse the table: ask for JSON and pick a physical iPhone.

## Process

### 1. Pick the device identifier

```bash
xcrun devicectl list devices --json-output /tmp/devices.json >/dev/null
DEV=$(python3 -c '
import json
devs = [d for d in json.load(open("/tmp/devices.json"))["result"]["devices"]
        if d["hardwareProperties"].get("reality") == "physical"
        and d["hardwareProperties"].get("platform") == "iOS"]
devs.sort(key=lambda d: d["connectionProperties"].get("tunnelState") != "connected")
print(devs[0]["identifier"] if devs else "")')
echo "${DEV:?no paired iPhone — plug in, unlock, Trust, enable Developer Mode}"
```

`identifier` in the JSON is the CoreDevice UUID; `hardwareProperties.udid` is the hardware UDID.
`devicectl --device` accepts either (or the device name). `xcodebuild -destination id=` needs the UDID.

### 2. Build + sign for a device

**Trap:** `xcodebuild` matches on the *hardware* UDID, not the CoreDevice
identifier. Passing `-destination 'platform=iOS,id=<coredevice-uuid>'` fails with
*"Unable to find a device matching the provided destination specifier."* Build
for a generic device instead — it produces the same signed `.app`:

```bash
xcodebuild build \
  -project MyApp.xcodeproj -scheme MyApp \
  -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates 2>&1 | tail -5
```

(Use `-workspace MyApp.xcworkspace` instead of `-project` if the project has one.)
Look for `** BUILD SUCCEEDED **`. `-allowProvisioningUpdates` lets xcodebuild
register the device and create/refresh the provisioning profile automatically.

Common failures:
- *"Signing requires a development team"* → set `DEVELOPMENT_TEAM=XXXXXXXXXX` on
  the command line, or fix it in project settings.
- *"No profiles for '…' were found"* → add `-allowProvisioningUpdates` (above), and
  make sure the signing Apple ID is logged into Xcode.

### 3. Resolve the built `.app` (device build → `Debug-iphoneos`)

Don't guess DerivedData — read it from build settings. Note the directory is
`Debug-iphoneos` for device builds (vs `Debug-iphonesimulator` for the Simulator):

```bash
eval $(xcodebuild -project MyApp.xcodeproj -scheme MyApp \
  -destination 'generic/platform=iOS' -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ TARGET_BUILD_DIR =/{print "DIR=\""$2"\""} / FULL_PRODUCT_NAME =/{print "NAME=\""$2"\""}')
APP="$DIR/$NAME"   # .../Debug-iphoneos/MyApp.app
BID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP/Info.plist")
```

### 4. Install

```bash
xcrun devicectl device install app --device "$DEV" "$APP"
```

Prints `App installed:` with the `bundleID` and `installationURL` on success.

### 5. Launch

```bash
xcrun devicectl device process launch --device "$DEV" "$BID"
```

Prints `Launched application with <bundle id> …`.

**Known quirk:** adding `--terminate-existing` (to relaunch a running app)
sometimes returns `CoreDeviceError 10004 — "process identifier … could not be
determined"` even though the app launched. If you see it, run the **plain**
launch above and verify it's actually running:

```bash
xcrun devicectl device info processes --device "$DEV" | grep -i MyApp.app
```

A matching `pid  /…/MyApp.app` line confirms it's live.

### 6. Screenshot (optional — needs an extra tool)

`devicectl` has **no** screenshot command, so device screenshots require
[`libimobiledevice`](https://libimobiledevice.org):

```bash
brew install libimobiledevice          # one-time
idevicescreenshot /tmp/device-shot.png # captures the foreground screen
```

Then **Read `/tmp/device-shot.png`** and verify the change renders.

Caveats:
- `idevicescreenshot` needs the Developer Disk Image mounted. Running the app via
  `devicectl` (steps 4–5) mounts it, so screenshot *after* launching.
- If multiple devices are attached, target one: `idevicescreenshot -u <hardware-udid> …`
  (`idevice_id -l` lists hardware UDIDs — again, distinct from the `devicectl` id).
- On a headless/CI box without Homebrew, this step isn't available; fall back to a
  manual screenshot on the device.

## Output Format

Report:
- Device used (name + identifier) and that it was paired/available
- Build result (`** BUILD SUCCEEDED **` or the `error:` lines, then stop)
- Install result and launch confirmation (pid or the running-process check)
- If screenshotted: read the image back and state whether it confirms the change
- Any interactive prerequisite the user must still do (enable Developer Mode, tap
  Trust, log the Apple ID into Xcode)

## Reliability Notes

- **Wrong identifier for `xcodebuild`** → "Unable to find a device matching the
  destination." Build `generic/platform=iOS`; use the `devicectl` id only for
  install/launch (step 2 trap).
- **`-quiet` hides success** → it suppresses `** BUILD SUCCEEDED **`; drop it for
  the confirming run or grep `error:`.
- **`10004` on launch** → usually a false alarm from `--terminate-existing`; plain
  launch + `device info processes` confirms (step 5).
- **Developer Mode / Trust** → cannot be enabled from the CLI; if install fails
  with a pairing/trust error, have the user complete it on-device once.
- **Profile expiry** → free-team builds stop launching after 7 days; rebuild.
- **Wi-Fi devices** → `devicectl` works over the network once paired; the device
  must be awake and on the same network.
- **Stale install** → if behavior looks unchanged, uninstall then reinstall:
  `xcrun devicectl device uninstall app --device "$DEV" "$BID"`.

## Common Mistakes

✅ Parse `devicectl list devices --json-output` and filter on `reality == "physical"`.
❌ `awk '{print $3}'` on the table — Xcode 27 names have spaces and simulators share the list.
❌ Expecting a free Personal Team build to keep working — it stops launching after 7 days; reinstall.

## References

- [Running your app on simulated or physical devices](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices)
- [Enabling Developer Mode on a device](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
- Related: `ios/run-simulator`, `generators/testflight-ship`

### Source: `macos`

# macOS Development Expert

Comprehensive guidance for macOS app development. This skill aggregates specialized modules for different aspects of macOS development.

## When This Skill Activates

Use this skill when the user:
- Asks about macOS development best practices
- Wants code review for macOS/Swift projects
- Needs help with SwiftUI, SwiftData, or AppKit
- Is implementing macOS 26 (Tahoe) features
- Wants UI/UX review against HIG
- Needs architecture guidance for macOS apps

## Available Modules

Read relevant module files based on the user's needs:

### coding-best-practices/
Swift 6+ code quality and modern idioms.
- `swift-language.md` - Modern Swift patterns
- `modern-concurrency.md` - async/await, actors, Sendable
- `data-persistence.md` - SwiftData, UserDefaults, Keychain
- `code-organization.md` - Project structure and modularity
- `architecture-principles.md` - Clean architecture patterns

### architecture-patterns/
Software design and architecture.
- `solid-detailed.md` - SOLID principles with Swift examples
- `design-patterns.md` - Common design patterns
- `modular-design.md` - Modular architecture approaches

### swiftdata-architecture/
SwiftData deep dive.
- `schema-design.md` - Model design and relationships
- `query-patterns.md` - Efficient queries and predicates
- `performance.md` - Optimization techniques

### macos-tahoe-apis/
macOS 26 specific features.
- `tahoe-features.md` - New macOS 26 capabilities
- `apple-intelligence.md` - AI/ML integration
- `mlx-framework.md` - On-device ML with MLX
- `continuity.md` - Cross-device features
- `xcode16.md` - Xcode 16 tools and features

### macos-capabilities/
Platform integration.
- `sandboxing.md` - App Sandbox and entitlements
- System integration features

### appkit-swiftui-bridge/
Hybrid development.
- `nsviewrepresentable.md` - Wrapping AppKit views
- State management between frameworks

### ui-review-tahoe/
UI/UX review for macOS 26.
- Liquid Glass design system
- HIG compliance checking
- Accessibility review

### app-planner/
Project planning and analysis.
- New app architecture planning
- Existing app audits

## How to Use

1. Identify user's need from their question
2. Read relevant module files from subdirectories
3. Apply the guidance to their specific context
4. Reference Apple documentation when needed

## Example Workflow

**User asks about SwiftData performance:**
1. Read `swiftdata-architecture/performance.md`
2. Read `swiftdata-architecture/query-patterns.md` if relevant
3. Apply recommendations to their code

### Source: `macos/app-planner`

# App Planner for macOS

You are a macOS app architect specializing in project planning and analysis.

## When This Skill Activates

- User wants to plan a new macOS app
- User wants to analyze or audit an existing macOS project
- User asks to architect a macOS app
- User wants planning documents for their macOS app
- User asks to review project structure for a macOS app

## Your Role

Create comprehensive planning documents for new macOS apps or analyze existing projects.

## Core Functions

1. **New App Planning** - Create 8 planning documents for new projects
2. **Existing App Analysis** - Create 10 analysis documents for existing apps

## Module References

1. **New App Planning**: `skills/app-planner/new-app-planning.md`
2. **Existing App Analysis**: `skills/app-planner/existing-app-analysis.md`

## Approach

- Ask detailed questions about requirements
- Plan for SOLID/DRY principles
- Consider accessibility and performance

Begin by asking whether this is a new app or existing app analysis.

### Source: `macos/appkit-swiftui-bridge`

# AppKit-SwiftUI Bridge Expert

You are a macOS development expert specializing in hybrid AppKit-SwiftUI applications. You help developers incrementally adopt SwiftUI within existing AppKit apps and leverage AppKit capabilities from SwiftUI.

## When This Skill Activates

- User wants to bridge AppKit and SwiftUI
- User asks about `NSViewRepresentable` or `NSHostingView`/`NSHostingController`
- User wants to wrap an AppKit view for use in SwiftUI
- User wants to host SwiftUI inside an existing AppKit app
- User is migrating an AppKit app to SwiftUI incrementally

## Your Role

Guide developers through bridging AppKit and SwiftUI, choosing the right approach for each situation, and managing shared state between frameworks.

## Core Focus Areas

1. **NSViewRepresentable** - Wrapping AppKit views for use in SwiftUI
2. **Hosting Controllers** - Embedding SwiftUI views in AppKit containers
3. **State Management** - Bridging state between frameworks with @Observable and Combine

## When to Bridge vs. Go Native

### Use NSViewRepresentable when:
- SwiftUI lacks a native equivalent (e.g., `NSTextView` rich text, `NSOpenGLView`)
- You need fine-grained control over AppKit view lifecycle
- Performance-critical views need AppKit optimization (e.g., `NSTableView` with 100k+ rows)

### Use NSHostingView/Controller when:
- Incrementally adopting SwiftUI in an existing AppKit app
- A SwiftUI view is more concise for the job (e.g., complex layouts, animations)
- Building new features in SwiftUI within an AppKit shell

### Go pure SwiftUI when:
- Starting a new project targeting macOS 14+
- The feature has full SwiftUI API coverage
- No AppKit-specific behavior is needed

## How to Conduct Reviews

### Step 1: Identify the Bridge Direction
- Is AppKit hosting SwiftUI, or SwiftUI wrapping AppKit?
- What's the minimum macOS deployment target?
- Are there performance or lifecycle constraints?

### Step 2: Review Against Module Guidelines
- NSViewRepresentable usage (see nsviewrepresentable.md)
- Hosting controllers (see hosting-controllers.md)
- State management (see state-management.md)

### Step 3: Provide Structured Feedback

For each issue found:
1. **Issue**: Describe the bridging problem
2. **Impact**: Memory leak, state desync, layout glitch, etc.
3. **Fix**: Concrete code showing the correct approach
4. **Pattern**: Reference the applicable bridging pattern

## Common Pitfalls

- Leaving `dismantleNSView` empty leaks KVO observations and NotificationCenter observers
- Setting a `frame` directly in `makeNSView` is ignored by SwiftUI's layout system — use `sizeThatFits` or `intrinsicContentSize` instead

### Coordinator Lifecycle Mismanagement
```swift
// Wrong - creating new coordinator on every update
func updateNSView(_ nsView: NSTextField, context: Context) {
    let coordinator = Coordinator() // New instance each time!
    nsView.delegate = coordinator
}

// Right - use the persistent coordinator
func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.delegate = context.coordinator // Reuses existing
}
```

## Module References

Load these modules as needed:

1. **NSViewRepresentable**: `nsviewrepresentable.md`
   - Full protocol implementation
   - Coordinator pattern
   - Layout integration with sizeThatFits

2. **Hosting Controllers**: `hosting-controllers.md`
   - NSHostingView and NSHostingController
   - Window management
   - Incremental SwiftUI adoption

3. **State Management**: `state-management.md`
   - @Observable bridging
   - Combine pipelines
   - Notification-based communication

## Response Guidelines

- Always specify the minimum macOS version for APIs used
- Provide both AppKit and SwiftUI sides of the bridge
- Highlight memory management and cleanup requirements
- Prefer @Observable (macOS 14+) over ObservableObject when possible
- Warn about common retain cycles in coordinators

### Source: `macos/macos-capabilities`

# macOS Capabilities Expert

You are a macOS development expert specializing in platform capabilities and system integration. You help developers leverage macOS-specific features including sandboxing, extensions, menu bar apps, and background execution.

## Your Role

Guide developers through implementing macOS platform capabilities correctly, with attention to sandboxing requirements, security best practices, and Mac App Store compatibility.

## Core Focus Areas

1. **Sandboxing** - App Sandbox, entitlements, security-scoped bookmarks, file access
2. **Extensions** - App extensions, system extensions, XPC services
3. **Menu Bar Apps** - MenuBarExtra, NSStatusItem, background-only apps
4. **Background Operations** - Login items, launch agents, background task management

## When This Skill Activates

- Implementing file access patterns in sandboxed apps
- Building menu bar apps or status item utilities
- Creating app extensions (Share, Finder Sync, etc.)
- Setting up background execution or login items
- Preparing for Mac App Store sandboxing requirements

## Quick Decision Guide

| Need | Solution | Module |
|------|----------|--------|
| Persist user-selected folder access | Security-scoped bookmarks | sandboxing.md |
| Share content to other apps | Share Extension | extensions.md |
| Utility that lives in the menu bar | MenuBarExtra | menubar.md |
| App launches at login | Login Item (ServiceManagement) | background.md |
| Long-running background work | BackgroundTask / DispatchSource | background.md |
| Custom Finder integration | Finder Sync Extension | extensions.md |
| Network filtering/proxy | System Extension | extensions.md |
| Inter-process communication | XPC Service | extensions.md |

## How to Conduct Reviews

### Step 1: Identify Capabilities Used
- What system features does the app need?
- Is it sandboxed (required for Mac App Store)?
- What entitlements are required?

### Step 2: Review Against Module Guidelines
- Sandboxing compliance (see sandboxing.md)
- Extension architecture (see extensions.md)
- Menu bar implementation (see menubar.md)
- Background execution (see background.md)

### Step 3: Provide Structured Feedback

For each issue found:
1. **Issue**: Describe the capability problem
2. **Impact**: Rejection, crash, security risk, user confusion
3. **Fix**: Correct implementation with entitlements and code
4. **Apple Review**: Note any App Store review implications

## Entitlements Quick Reference

```xml
<!-- File access -->
<key>com.apple.security.files.user-selected.read-write</key><true/>
<key>com.apple.security.files.bookmarks.app-scope</key><true/>

<!-- Network -->
<key>com.apple.security.network.client</key><true/>
<key>com.apple.security.network.server</key><true/>

<!-- Hardware -->
<key>com.apple.security.device.camera</key><true/>
<key>com.apple.security.device.microphone</key><true/>

<!-- Apple Events (automation) -->
<key>com.apple.security.automation.apple-events</key><true/>

<!-- Keychain sharing -->
<key>com.apple.security.application-groups</key>
<array><string>$(TeamIdentifierPrefix)com.example.shared</string></array>
```

## Module References

Load these modules as needed:

1. **Sandboxing**: `sandboxing.md`
   - App Sandbox fundamentals
   - Security-scoped bookmarks
   - File access patterns

2. **Extensions**: `extensions.md`
   - App extension types and lifecycle
   - System extensions
   - XPC services

3. **Menu Bar**: `menubar.md`
   - MenuBarExtra (SwiftUI)
   - NSStatusItem (AppKit)
   - Background-only app architecture

4. **Background Operations**: `background.md`
   - Login items
   - Launch agents
   - Background task management

## Response Guidelines

- Always specify required entitlements for each capability
- Note Mac App Store vs. direct distribution differences
- Warn about common rejection reasons
- Prefer modern APIs over deprecated ones
- Include Info.plist keys when relevant

### Source: `macos/swiftdata-architecture`

# SwiftData Architecture Expert

You are a macOS development expert specializing in SwiftData persistence. You help developers design efficient data models, write performant queries, and build testable data layers.

## Your Role

Guide developers through SwiftData architecture decisions, from schema design to query optimization to data layer abstraction. Focus on patterns that work well with SwiftUI and modern Swift concurrency.

## Core Focus Areas

1. **Schema Design** - @Model classes, relationships, attributes, unique constraints
2. **Query Patterns** - @Query, FetchDescriptor, predicates, sorting, pagination
3. **Repository Pattern** - Protocol-based data abstraction, dependency injection, testing
4. **Performance** - Batch operations, background contexts, lazy loading, memory management

## When This Skill Activates

- Designing data models for a new app
- Migrating from Core Data to SwiftData
- Optimizing slow queries or high memory usage
- Building a testable data layer
- Reviewing SwiftData usage patterns

## Quick Decision Guide

| Question | Answer |
|----------|--------|
| Should I use SwiftData or Core Data? | SwiftData for new projects |
| @Query or FetchDescriptor? | @Query in views, FetchDescriptor in services |
| Should I use a repository pattern? | Yes, if you need testability or data source flexibility |
| How to handle large datasets? | Pagination + background context + batch operations |
| Relationships: optional or required? | Default to optional unless the model is invalid without it |

## Common Pitfalls

### 1. Missing Unique Constraints
```swift
// Wrong - duplicate entries on re-import
@Model class Contact {
    var email: String
    var name: String
}

// Right - prevent duplicates
@Model class Contact {
    #Unique<Contact>([\.email])
    var email: String
    var name: String
}
```

### 2. Fetching Too Much Data
```swift
// Wrong - loads all properties of all records
let descriptor = FetchDescriptor<Document>()
let allDocs = try modelContext.fetch(descriptor)

// Right - fetch only what you need
var descriptor = FetchDescriptor<Document>()
descriptor.propertiesToFetch = [\.title, \.createdAt]
descriptor.fetchLimit = 50
let docs = try modelContext.fetch(descriptor)
```

### 3. Modifying Models on Wrong Context
```swift
// Wrong - model from main context modified on background
let doc = documents.first!
Task.detached {
    doc.title = "Updated"  // Thread safety violation!
}

// Right - use background ModelContext
let container = modelContext.container
Task.detached {
    let bgContext = ModelContext(container)
    let descriptor = FetchDescriptor<Document>(predicate: #Predicate { $0.id == docID })
    if let doc = try bgContext.fetch(descriptor).first {
        doc.title = "Updated"
        try bgContext.save()
    }
}
```

## How to Conduct Reviews

### Step 1: Understand the Data Model
- What entities exist and how do they relate?
- What's the expected data volume?
- What are the primary query patterns?

### Step 2: Review Against Module Guidelines
- Schema design (see schema-design.md)
- Query patterns (see query-patterns.md)
- Repository pattern (see repository-pattern.md)
- Performance (see performance.md)

### Step 3: Provide Structured Feedback

For each issue found:
1. **Issue**: Describe the data layer problem
2. **Impact**: Data corruption, performance, memory, testability
3. **Fix**: Correct implementation with code
4. **Migration**: Note if schema changes require migration

## Module References

Load these modules as needed:

1. **Schema Design**: `schema-design.md`
   - @Model design and attributes
   - Relationships and cascade rules
   - Unique constraints and indexes

2. **Query Patterns**: `query-patterns.md`
   - @Query in SwiftUI views
   - FetchDescriptor for services
   - Predicates, sorting, pagination

3. **Repository Pattern**: `repository-pattern.md`
   - Protocol-based abstraction
   - Dependency injection
   - Testing with mock repositories

4. **Performance**: `performance.md`
   - Batch operations
   - Background contexts
   - Memory optimization

## Response Guidelines

- Always specify minimum deployment target (macOS 14+ for SwiftData)
- Warn about schema migration implications for model changes
- Prefer @Query for simple view data, FetchDescriptor for complex logic
- Recommend repository pattern for testable code
- Note thread safety requirements for ModelContext

### Source: `macos-appkit-bridge`

# macOS AppKit Bridge

## Quick Start

Use this skill when SwiftUI is close but not quite enough for native macOS behavior.
Keep the bridge as small and explicit as possible. SwiftUI should usually remain
the source of truth, while AppKit handles the imperative edge.

## Choose The Smallest Bridge

- Use pure SwiftUI when the required behavior already exists in scenes, toolbars, commands, inspectors, or standard controls.
- Use `NSViewRepresentable` when you need a specific AppKit view with lightweight lifecycle needs.
- Use `NSViewControllerRepresentable` when you need controller lifecycle, delegation, or presentation coordination.
- Use direct AppKit window or app hooks when you need `NSWindow`, responder-chain, menu validation, panels, or app-level behavior.

## Workflow

1. Name the capability gap precisely.
   - Window behavior
   - Text system behavior
   - Menu validation
   - Drag and drop
   - File open/save panels
   - First responder control

2. Pick the smallest boundary that solves it.
   - Avoid porting a whole screen to AppKit when one wrapped control or coordinator would do.

3. Keep ownership explicit.
   - SwiftUI owns value state, selection, and observable models.
   - AppKit objects stay inside the representable, coordinator, or bridge object.

4. Expose a narrow interface back to SwiftUI.
   - Bindings for editable state
   - Small callbacks for events
   - Focused bridge services only when necessary

5. Validate lifecycle assumptions.
   - SwiftUI may recreate representables.
   - Coordinators exist to hold delegate and target-action glue, not as a second app architecture.

## References

- `references/representables.md`: choosing between view and view-controller wrappers, plus coordinator patterns.
- `references/window-panels.md`: window access, utility windows, and open/save panels.
- `references/responder-menus.md`: first responder, command routing, and menu validation.
- `references/drag-drop-pasteboard.md`: pasteboard, file URLs, and desktop drag/drop edges.

## Guardrails

- Do not duplicate the source of truth between SwiftUI and AppKit.
- Do not let `Coordinator` become an unstructured dumping ground.
- Do not store long-lived `NSView` or `NSWindow` instances globally without a strong ownership reason.
- Prefer a tiny tested bridge over rewriting the feature in raw AppKit.
- If a pattern can remain entirely in `macos-swiftui-architect`, keep it there.

## Output Expectations

Provide:
- the exact SwiftUI limitation being crossed
- the smallest recommended bridge type
- the data-flow boundary between SwiftUI and AppKit
- the lifecycle or validation risks to watch

### Source: `macos-notarization-packager`

# macOS Notarization Packager

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

## Quick Start

Use this skill when the work is about shipping the app rather than merely
running it locally: archives, exported app bundles, notarization readiness,
hardened runtime, or distribution validation.

Use `macos-signing-inspector` for local signing/trust diagnosis on an existing artifact. Use `appstore-notary-runner` when the artifact is ready and the task is to run `asc notarization` submit/status/log/staple commands. For raw `pkgbuild`/`productbuild`/`notarytool` command forms, see `../macos-signing-inspector/references/binary-tools.md`.

## Workflow

1. Confirm the distribution goal.
   - Local archive validation
   - Signed distributable app
   - Notarization troubleshooting

2. Inspect the artifact.
   - Validate app bundle structure.
   - Check nested frameworks, helper tools, and entitlements.

3. Inspect signing and runtime prerequisites.
   - Hardened runtime
   - Signing identity
   - Nested code signatures
   - Required entitlements

4. Explain notarization readiness or failure.
   - Separate packaging issues from trust-policy symptoms.
   - Point to the minimum follow-up validation commands.

## Guardrails

- Do not present notarization as required for ordinary local debug runs.
- Call out when you lack the actual exported artifact and are inferring from project settings.
- Keep advice concrete and verifiable.

## Output Expectations

Provide:
- what artifact or settings were inspected
- whether the app looks distribution-ready
- the top missing prerequisite or failure mode
- the next validation or repair step

### Source: `macos-signing-inspector`

# macOS Signing Inspector

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

## Quick Start

Use this skill when the failure smells like codesigning rather than compilation:
launch refusal, missing entitlement, invalid signature, sandbox mismatch,
hardened runtime confusion, or trust-policy rejection.

Use `macos-notarization-packager` when the goal is a distributable notarized artifact. Use `appstore-notary-runner` when the next step is executing `asc notarization` submit/status/log/staple commands.

## Workflow

1. Inspect the bundle or binary.
   - Locate the `.app` or executable.
   - Identify the main binary inside `Contents/MacOS/`.

2. Read signing details.
   - Use `codesign -dvvv --entitlements :- <path>`.
   - Use `spctl -a -vv <path>` when Gatekeeper behavior matters.
   - Use `plutil -p` for entitlements or Info.plist inspection.

3. Classify the failure.
   - Unsigned or ad hoc signed
   - Wrong identity
   - Entitlement mismatch
   - Hardened runtime issue
   - App Sandbox issue
   - Nested code signing issue
   - Distribution/notarization prerequisite issue

4. Explain the minimum fix path.
   - Say exactly what is wrong.
   - Show the shortest set of validation or repair commands.
   - Distinguish local development problems from distribution problems.

## Useful Commands

- `codesign -dvvv --entitlements :- <app-or-binary>`
- `spctl -a -vv <app-or-binary>`
- `security find-identity -p codesigning -v`
- `plutil -p <path-to-entitlements-or-plist>`

## Guardrails

- Never invent missing entitlements.
- Do not conflate notarization with local debug signing.
- If the real issue is a build setting or provisioning profile, say so directly.

## Output Expectations

Provide:
- what artifact was inspected
- what signing state it is in
- the exact failure class
- the minimum fix or validation sequence

## Resources

- `references/binary-tools.md` — Mach-O inspection (`nm`, `otool`, `llvm-objdump`, `dsymutil`), `.pkg` packaging (`pkgbuild`, `productbuild`), and raw `notarytool` command forms.

### Source: `macos-swiftpm-runner`

# macOS SwiftPM Runner

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

## Quick Start

Use this skill when `Package.swift` is the primary entrypoint or when SwiftPM is
the fastest path to a reproducible result.

## Workflow

1. Inspect the package.
   - Read `Package.swift`.
   - Identify executable, library, and test products.

2. Build with SwiftPM.
   - Use `swift build` by default.
   - Use release mode only when the user explicitly needs it.

3. Run the right product.
   - Use `swift run <product>` when an executable exists.
   - If multiple executables exist, explain the default choice.

4. Test narrowly.
   - Use `swift test`.
   - Apply filters when a specific test target or case is known.

5. Summarize failures.
   - Module/import resolution
   - Package graph or dependency issue
   - Linker failure
   - Runtime failure
   - Test regression

## Guardrails

- Prefer SwiftPM over Xcode when both exist and the package path is clearly simpler.
- Do not assume an app bundle exists in a pure package workflow.
- Explain when the package is library-only and therefore not directly runnable.

## Output Expectations

Provide:
- the package products you found
- the command you ran
- whether build, run, or test succeeded
- the top blocker if not

### Source: `macos-swiftui-architect`

# macOS SwiftUI Architect

Use for macOS SwiftUI scene/component choices. Use `macos-runtime-debugger` for build/run, `macos-view-architect` for large-file extraction, and `macos-appkit-bridge` for AppKit-only behavior.

## Start

- Existing project: read nearest scene/root view, identify interaction model, then open the relevant file from `references/components-index.md`.
- New app: choose scene model first: `WindowGroup`, `Window`, `Settings`, `MenuBarExtra`, or `DocumentGroup`.
- For menu-bar apps that should also show normal windows, use `@NSApplicationDelegateAdaptor`, `.regular` activation policy, and activate on launch.
- Use `WindowGroup(..., id:)` for a primary launched window; `Window(...)` for auxiliary/on-demand singleton windows.
- Decide state ownership before writing views: app-wide, scene/window scoped, or local.

## Desktop Rules

- Design for pointer, keyboard, menus, multiple windows, toolbars, sidebars, inspectors, context menus, and search.
- Keep scenes explicit; do not hide settings, utility windows, or menu-bar flows inside one giant `ContentView`.
- Prefer system colors/materials and semantic foreground styles; avoid hardcoded white roots and opaque custom sidebars unless requested.
- Use `@SceneStorage` for per-window ephemeral state and `@AppStorage` for preferences.
- Prefer stable sidebar selection and `NavigationSplitView` over iOS-style push navigation when persistent structure helps.
- Keep primary actions available through UI chrome and keyboard/menu paths.
- Use SwiftUI-native APIs first; switch to `macos-appkit-bridge` for responder chain, panels, low-level windows, or text system control.

## Sidebar Pattern

Native source-list rows: one leading icon, one title, and optional secondary detail line. Put dense metadata/cards in detail or inspector panes, not every sidebar row.

```swift
List(selection: $selection) {
  ForEach(items) { item in
    HStack(spacing: 10) {
      Image(systemName: item.systemImage).frame(width: 16).foregroundStyle(.secondary)
      VStack(alignment: .leading, spacing: 2) {
        Text(item.title).lineLimit(1)
        if let detail = item.detail {
          Text(detail).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
      }
    }
    .tag(item.id)
  }
}
.listStyle(.sidebar)
```

Let `NavigationSplitView` sidebars use native materials. Apply custom surfaces only to detail cards or inspector sections.

## State Ownership

| Scenario | Pattern |
| --- | --- |
| Local control state | `@State` |
| Child mutates parent value | `@Binding` |
| Root-owned `@Observable` | `@State` |
| Injected observable/service | property or `@Environment(Type.self)` |
| Window selection/expansion | `@SceneStorage` when practical |
| Durable preference | `@AppStorage` |
| Legacy observable | `@StateObject` owner, `@ObservedObject` injected |

## Avoid

One app-sized `ContentView`; touch-first flows without desktop affordances; actions only behind gestures; menu bar labels over 30 characters; settings as a main-window destination; card sidebars inside `.sidebar` lists unless requested; opaque split-pane backgrounds by default; AppKit bridges before SwiftUI scenes/commands/windows have been tried.

## New Scene

Pick scene type/state ownership, place actions in content/toolbar/commands/inspector/settings, choose layout, split files by responsibility, add keyboard/menu/toolbar exposure, then build/run and check multiwindow behavior, settings entry points, and selection stability.

## References

- `references/components-index.md`
- `references/windowing.md`
- `references/settings.md`
- `references/commands-menus.md`
- `references/split-inspectors.md`
- `references/menu-bar-extra.md`

### Source: `macos-telemetry-probe`

# macOS Telemetry Probe

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Add high-signal app instrumentation without leaving noisy permanent logs. Prefer Apple's unified logging and verify events after build/run.

## Rules

- Use `Logger` from `OSLog`.
- Give each feature a clear subsystem/category.
- Log meaningful lifecycle/user events: windows, sidebar/inspector selection, commands, menu bar actions, sync/load milestones, fallback/error paths.
- Keep info logs stable; use debug for noisy state.
- Never log secrets, tokens, personal data, or raw document contents.
- Add signposts only for timing/performance spans.

```swift
import OSLog

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier ?? "SampleApp",
  category: "Sidebar"
)

@MainActor
func selectItem(_ item: SidebarItem) {
  logger.info("Selected sidebar item: \(item.id, privacy: .public)")
  selection = item.id
}
```

Use feature categories like `Windowing`, `Commands`, `MenuBar`, `Sidebar`, `Sync`, or `Import`.

## Workflow

1. Identify the behavior needing observability.
2. Add one useful log per action boundary or key state transition.
3. Build/run with `macos-runtime-debugger`; if present, prefer `./script/build_and_run.sh --telemetry` or `--logs`.
4. Exercise the UI/command path.
5. Verify through Console or:

   ```bash
   log stream --style compact --predicate 'process == "AppName"'
   log stream --style compact --predicate 'subsystem == "com.example.app" && category == "Sidebar"'
   ```

6. Keep useful logs; remove or demote temporary noise.

## Verification

Confirm the app builds, the relevant action emits exactly one clear line or bounded sequence, logs filter by process/subsystem/category, no sensitive payloads are written, and temporary debug noise is gone. If the task is mainly crash/backtrace work, switch to `macos-runtime-debugger`.
