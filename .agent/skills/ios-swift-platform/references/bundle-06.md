# Integrated Reference Bundle 06

Combines 12 related source skills from `ios-swift-platform` into one navigable reference file.

## Source map

- `ios/run-simulator/SKILL.reference.md`
- `ios-intents-architect/SKILL.reference.md`
- `ios-memgraph-inspector/SKILL.reference.md`
- `ios-rocketsim-operator/SKILL.reference.md`
- `ios-simulator-browser/SKILL.reference.md`
- `ios-swiftui-architect/SKILL.reference.md`
- `ios_1296/SKILL.reference.md`
- `ios_1296/camera-scanning/SKILL.reference.md`
- `ios_1296/device-sensors/SKILL.reference.md`
- `ios_1296/healthkit/SKILL.reference.md`
- `ios_1296/native-services/SKILL.reference.md`
- `ios_1296/project-bootstrap/SKILL.reference.md`

## Integrated guidance

### Source: `ios/run-simulator`

# Run in Simulator

Launches the **actual app** in the iOS Simulator and drives it far enough to see
what a user would see. Building proves the code compiles; this skill proves it
*runs*. The payoff is a screenshot of the live app that you read back to confirm
the change — a blank or crashed frame is a failure, not a pass.

This skill is generic. Nothing about a specific app is hardcoded — the scheme,
simulator, product path, and bundle id are all discovered at runtime.

## When This Skill Activates

Use this skill when the user:
- Asks to "run", "launch", or "open" the app in the simulator
- Wants to *see* a change working, not just compile it
- Asks for a screenshot of the running app
- Wants to verify a UI fix visually before committing or pushing
- Says "does this actually work?" about a view/flow they just changed

Do **not** use it for unit/UI test runs (`xcodebuild test`) — that's a different
goal. This is about meeting the app as a user would.

## Process

Run the steps in order. Each step's output feeds the next, so don't hardcode
values a previous step can discover.

### 1. Discover the project and scheme

Prefer a workspace over a bare project when both exist (CocoaPods/SPM setups
often require the workspace):

```bash
# Find the container
ls *.xcworkspace 2>/dev/null || ls *.xcodeproj 2>/dev/null

# List schemes (use -workspace X.xcworkspace OR -project X.xcodeproj)
xcodebuild -list -project <App>.xcodeproj 2>/dev/null
```

Pick the app scheme (usually matches the app name). If several schemes look
plausible and none clearly matches, **ask the user** which to run rather than
guessing.

### 2. Pick a simulator destination

**Never hardcode a device name** — the named device may not exist on this Mac
(e.g. assuming "iPhone 16" when only "iPhone 17 Pro" is installed fails with
*"Unable to find a device matching the provided destination specifier"*). List
what's actually available and prefer one already booted:

```bash
# Already-booted sim, if any (fastest — skip the boot wait)
xcrun simctl list devices booted

# Otherwise, available iPhones to choose from
xcrun simctl list devices available | grep -i iphone
```

Choose a booted device if present; otherwise pick a recent iPhone from the
available list and remember its name for the destination string.

### 3. Build for the simulator

```bash
xcodebuild build \
  -project <App>.xcodeproj \
  -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=<SimName>' \
  2>&1 | tail -5
```

- Read the tail for `** BUILD SUCCEEDED **`. Note that `-quiet` *suppresses*
  that success line, so either drop `-quiet` for the confirming run or grep for
  `error:` explicitly.
- On failure, surface the `error:` lines — don't proceed to install a stale or
  nonexistent build.

### 4. Resolve the built `.app` and its bundle id

Don't guess the DerivedData path — ask the build system for it:

```bash
# Product directory + name from the resolved build settings
eval $(xcodebuild -project <App>.xcodeproj -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=<SimName>' \
  -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ TARGET_BUILD_DIR =/{print "DIR=\""$2"\""} / FULL_PRODUCT_NAME =/{print "NAME=\""$2"\""}')
APP="$DIR/$NAME"
echo "APP: $APP"

# Bundle id straight from the built Info.plist
BID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP/Info.plist")
echo "Bundle id: $BID"
```

### 5. Boot, install, launch

```bash
SIM="<SimName>"
xcrun simctl boot "$SIM" 2>/dev/null   # no-op if already booted
open -a Simulator                      # bring the window forward
xcrun simctl bootstatus "$SIM" -b      # block until fully booted

xcrun simctl install "$SIM" "$APP"
xcrun simctl launch "$SIM" "$BID"
```

`simctl launch` prints `<bundleid>: <pid>` on success. A non-zero exit or an
error string here means the app failed to start — investigate before
screenshotting.

### 6. Screenshot and verify (and drive if needed)

```bash
xcrun simctl io "$SIM" screenshot /tmp/sim-shot.png
```

Then **Read `/tmp/sim-shot.png`** and actually look at it:
- Blank/white frame, a crash dialog, or the launch screen stuck → failure.
- The expected screen → success; describe what confirms the change.

If the change lives behind navigation, drive there before judging. Tap by point
or describe to the user what to navigate to:

```bash
# Tap a point (x y in points) — useful for hitting a known tab/button
xcrun simctl io "$SIM" tap <x> <y>          # (where supported)
# Re-screenshot after each interaction
xcrun simctl io "$SIM" screenshot /tmp/sim-shot-2.png
```

For deep links, `xcrun simctl openurl "$SIM" "<scheme>://<path>"`. If precise
tapping isn't available, take the screenshot at the landing screen and tell the
user the exact taps to reach the target view.

## Output Format

Report, concisely:
1. **What ran** — scheme, simulator name/OS, bundle id.
2. **Build result** — succeeded / failed (with the error tail if failed).
3. **Launch result** — pid on success, or the failure reason.
4. **What the screenshot shows** — the screen reached and whether it confirms
   the change. Embed/Read the screenshot so the user sees it too.
5. **Anything the user must do** — e.g. taps needed to reach a gated screen.

## Reliability Notes (common failure modes)

- **Wrong device name** → "Unable to find a device matching the destination."
  Always list available sims (step 2) instead of assuming a model number.
- **Stale install** → if behavior looks unchanged, `xcrun simctl uninstall
  "$SIM" "$BID"` then reinstall; or `xcrun simctl shutdown "$SIM" && xcrun
  simctl erase "$SIM"` for a clean slate (destroys sim data — confirm first).
- **Workspace vs project** → if the build complains about missing packages/pods,
  re-run with `-workspace <App>.xcworkspace` instead of `-project`.
- **First boot is slow** → `simctl bootstatus -b` blocks correctly; a fixed
  `sleep` does not and races the install.
- **Launch screen "stuck"** → on a cold sim the app may still be initializing;
  re-screenshot after a short wait before declaring failure.

## References

- `xcrun simctl help` — full simulator control surface (boot, install, launch,
  io, openurl, spawn).
- `man xcodebuild` — `build`, `-list`, `-showBuildSettings`, `-destination`.
- Apple: Running your app in Simulator —
  https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device

### Source: `ios-intents-architect`

# iOS Intents Architect

Expose the smallest useful action and entity surface to the system. Start with verbs and objects users need outside the app, then route cleanly back into the app when needed.

## Workflow

1. Choose 1-3 high-value actions. Prefer verbs like compose, open, find, filter, continue, inspect, or start. Do not mirror the app navigation tree.
2. Add only the `AppEntity` types the system must understand. Keep them narrower than persistence models. Add `EntityQuery` when suggestions or disambiguation are useful.
3. Decide execution mode:
   - direct system-surface action for work that can finish inline
   - `openAppWhenRun` or open-style intent when the user should land in an app workflow
   - one predictable handoff route in the scene/root router when the app must react
   - separate inline and open-app intents when one compromise would be unclear
4. Add `AppShortcutsProvider` for the first useful set. Keep titles, phrases, and symbols direct and task-oriented.
5. Reuse the same action/entity surface for widgets and controls when their parameters match.
6. Build and verify that intents compile, open or execute correctly, and route to the expected state.

## Defaults

- Prefer a dedicated intents target or module.
- Keep intent types thin; business logic stays in app services or domain models.
- Use `AppEnum` for fixed choices such as tabs, modes, or visibility before creating entities.
- Treat App Intents as system integration infrastructure, not only a Shortcuts feature.

## Avoid

- one intent per screen or tab without real user value
- mirroring the full model graph as entities
- global side-effect handoff with no clear app entry path
- vague shortcut phrases or generic titles
- broad taxonomy work in the first pass

## Resources

Read only what is needed:

- `references/first-pass-checklist.md`: choose the first intent/entity surface.
- `references/example-patterns.md`: copyable patterns.
- `references/code-templates.md`: generalized code templates.
- `references/system-surfaces.md`: Shortcuts, Siri, Spotlight, widgets, and controls.

Use current Apple Developer docs when APIs or platform behavior may have changed:

- `https://developer.apple.com/documentation/appintents`
- `https://developer.apple.com/documentation/appintents/creating-your-first-app-intent`
- `https://developer.apple.com/documentation/appintents/adopting-app-intents-to-support-system-experiences`

Output the exposed actions, backing entities, invocation mode, app handoff path, and validation result.

### Source: `ios-memgraph-inspector`

# iOS Memgraph Inspector

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Use for leaks from a live simulator process or existing `.memgraph`. Pair with `../ios-simulator-debugger/SKILL.md` when build, launch, UI driving, logs, or screenshots are needed.

## Workflow

1. Build, launch, and drive the exact flow that should release objects.
2. Capture with `scripts/capture_sim_memgraph.sh`.
3. Summarize with `scripts/summarize_memgraph_leaks.py`.
4. For app-owned leaked types, inspect ownership with `leaks --traceTree=<address> <file.memgraph>` and grouped leak evidence.
5. Patch the smallest retaining edge, then recapture the same flow/simulator when possible.
6. Report before/after counts, disappeared root types or paths, remaining leaks, memgraph paths, and build/test proof.

Do not claim a fix from a smaller memgraph alone; prove the specific type or ownership path disappeared.

## Capture

`SKILL_DIR` is the loaded skill folder, not the app repo.

```bash
SKILL_DIR="<absolute path to this loaded skill folder>"
SIM="<simulator-udid>"
BUNDLE_ID="<app.bundle.identifier>"
MEMGRAPH_DIR="$(mktemp -d "${TMPDIR:-/tmp}/codex-ios-memgraph.XXXXXX")"

"$SKILL_DIR/scripts/capture_sim_memgraph.sh" \
  --udid "$SIM" \
  --bundle-id "$BUNDLE_ID" \
  --out-dir "$MEMGRAPH_DIR"
```

If the process is missing, verify the bundle id and inspect running labels:

```bash
xcrun simctl spawn "$SIM" launchctl list
```

Summarize:

```bash
"$SKILL_DIR/scripts/summarize_memgraph_leaks.py" \
  /path/to/app.memgraph \
  --trace-limit 5 \
  --out /path/to/leak-summary.md
```

Use `--trace-limit` sparingly. If `traceTree` says `Found 0 roots referencing`, treat it as an unreachable/self-retained candidate and inspect `leaks --groupByType <file.memgraph>` plus source.

## Root-Cause Rules

- Identify the first app-owned leaked type.
- Determine intended lifetime: process, session, account, view, request, or task.
- Lazy allocation is scope reduction, not proof of a fixed leak.
- Prove retain cycles with `traceTree` or an isolated repro.
- Separate framework/runtime noise from app-owned branches.
- Prefer removing the retaining edge over broad cleanup code.

## Report

Include flow, simulator/app build, memgraph and summary paths, leaked app types/counts, ownership path or grouped evidence, applied/proposed fix, and before/after evidence. If only framework noise appears, say so and recommend a narrower capture.

### Source: `ios-rocketsim-operator`

# iOS RocketSim Operator

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Use the installed RocketSim app as the versioned Simulator automation layer. Always resolve the matching app bundle, bundled skill, and CLI before interacting with a simulator.

## Discovery

Prefer a running RocketSim bundle:

```bash
ROCKETSIM_PID="$(pgrep -x RocketSim | head -1)"
APP_PATH=""
if [ -n "$ROCKETSIM_PID" ]; then
  APP_PATH="$(ps -o command= -p "$ROCKETSIM_PID" | sed 's#/Contents/MacOS/RocketSim$##')"
fi
printf '%s\n' "$APP_PATH"
```

If not running, enumerate candidates with:

```bash
mdfind "kMDItemCFBundleIdentifier == 'com.swiftLee.RocketSim'"
```

Also check `/Applications/RocketSim.app`, `/Applications/RocketSim 2.app`, `~/Applications/RocketSim.app`, and `~/Applications/RocketSim 2.app`.

For each candidate, validate both files:

```bash
test -f "$APP_PATH/Contents/Resources/Agent-Skill/SKILL.md" && \
test -x "$APP_PATH/Contents/Helpers/rocketsim"
```

Use the first valid candidate. If RocketSim is running, use the running bundle only if it validates; otherwise rediscover or stop.

If no candidate validates, tell the user to launch or install a current RocketSim build from the Mac App Store:
`https://apps.apple.com/us/app/rocketsim-for-xcode-simulator/id1504940162`

## Required Paths

After discovery, set:

- Bundled skill: `$APP_PATH/Contents/Resources/Agent-Skill/SKILL.md`
- CLI: `$APP_PATH/Contents/Helpers/rocketsim`

Before any CLI call:

```bash
pgrep -x RocketSim >/dev/null && echo "Running" || echo "Not running"
```

If RocketSim is not running, ask the user to launch it. If it is running from a different bundle than `APP_PATH`, restart discovery and prefer the running bundle.

## Handoff

Read the bundled `Agent-Skill/SKILL.md` and follow it. Wherever it refers to `rocketsim`, use the resolved absolute CLI path. Do not use ad hoc simulator automation until discovery, validation, and the running-app check pass.

### Source: `ios-simulator-browser`

# iOS Simulator Browser

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Bundled commands use `$PLUGIN_ROOT` (`$env:PLUGIN_ROOT` in PowerShell; same path suffix) for the plugin root. Set it once: use the host's plugin-root variable when defined (Claude Code: `PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"`), otherwise the absolute path of this plugin's root directory.

## Routing Priority

Use this as the preferred user-facing Simulator surface whenever the task would benefit from the user seeing or interacting with the app in the Codex browser. Plain simulator debugging remains useful for build/run, logs, bundle IDs, UI trees, and headless automation; once it provides or launches a Simulator UDID, hand off to this browser workflow for visible proof unless the user explicitly asked for a headless or log-only check.

## Browser Workflow

1. Obtain an explicit Simulator UDID from the existing iOS build/run workflow or from `xcrun simctl list devices available`.
2. Start `serve-sim` in a long-running terminal pinned to that simulator. Clean up any tracked stale helper for this simulator before starting, and install a trap so the helper is cleaned up when this terminal exits:

   ```bash
   SIM="<simulator-udid>"
   cleanup_serve_sim() {
     npx --yes serve-sim@latest --kill "$SIM" >/dev/null 2>&1 || true
   }
   trap cleanup_serve_sim EXIT INT TERM HUP
   cleanup_serve_sim
   npx --yes serve-sim@latest "$SIM"
   ```

3. Open the exact local preview URL printed by `serve-sim` in the Codex in-app browser.
4. Verify that a real frame is rendering before reporting success. A loaded page alone is not proof that the simulator stream is healthy.

- Keep the terminal alive while the browser mirror is in use. When finished, stop the terminal and wait for it to exit so the trap runs.
- If the terminal disappeared or did not exit cleanly, run `npx --yes serve-sim@latest --kill "$SIM"` before starting another mirror for that simulator.
- Never run an unscoped `serve-sim --kill`; another thread may own a different simulator mirror.

## SwiftUI Preview Workflow

Use the bundled launcher when the requested previews live in an importable Swift package. Point it at the package manifest and select the target whose previews should be displayed. It generates a disposable host project outside the user's source tree, installs and launches that host in Simulator, and watches the package for edits.

```bash
node "$PLUGIN_ROOT/skills/ios-simulator-browser/scripts/swiftui-preview-browser.mjs" \
  /absolute/path/to/Package.swift \
  --package-target "<target>" \
  --device "<simulator-udid>"
```

- Watch mode is enabled by default. On a Swift package source edit, the launcher rebuilds a generated dylib and hot-swaps it into the running host without relaunching the app.
- The generated host shows every preview variant discovered in the selected Swift Package target with in-simulator page controls. To show a subset instead, pass `--preview-filter <regex[, ...]>`; it matches display names and code identifiers such as `StatusRowView_Previews`.
- Once the launcher prints the selected Simulator UDID, start `serve-sim` for that same UDID and open its printed URL in the in-app browser.

## Support Boundary

- Support Swift Package-backed `PreviewProvider` and `#Preview` declarations through the generated host.
- Do not edit the user's `.xcodeproj`, `.xcworkspace`, `Package.swift`, schemes, or build settings to force preview support.

## Proof

For browser or preview QA, capture a browser screenshot showing the simulator frame. For hot reload QA, also report the launcher's `hot reloaded package preview ... in pid ...` output and show the changed frame after editing.

### Source: `ios-swiftui-architect`

# iOS SwiftUI Architect

Use for iOS SwiftUI UI structure and component choices. Read the nearest local example before introducing a new pattern.

## Start

- Existing project: identify screen model (list/detail/editor/settings/tab), search for nearby examples (`rg "TabView\\("`, etc.), then read `references/components-index.md`.
- New app: start with `references/app-wiring.md` for TabView + NavigationStack + sheets, then expand route/sheet enums as screens appear.
- For scroll-driven reveals, read `references/scroll-reveal.md` before hand-rolling gestures.

## Rules

- Prefer `@State`, `@Binding`, `@Observable`, and `@Environment`; avoid unnecessary view models.
- If iOS 16 or earlier is supported, use `ObservableObject` with `@StateObject` at the owner and `@ObservedObject` for injection.
- Keep views small, composed, and project-formatted.
- Use `.task`/`.task(id:)` with loading/error states; read `references/async-state.md` for cancellation/debouncing.
- Put shared app services in `@Environment`; keep feature-local dependencies as explicit inputs.
- Prefer newest SwiftUI APIs that match deployment target and call out minimum OS.
- Maintain legacy patterns only inside legacy files.
- Sheets: prefer `.sheet(item:)`, avoid `if let` inside sheet bodies, let sheets call `dismiss()` internally.
- Scroll reveals: derive one normalized progress value from scroll offset instead of parallel gesture state machines when possible.

## State Ownership

| Scenario | Pattern |
| --- | --- |
| Local UI state | `@State` |
| Child mutates parent value | `@Binding` |
| Root-owned iOS 17+ reference model | `@State` with `@Observable` |
| Injected iOS 17+ observable | explicit stored property |
| Shared service/config | `@Environment(Type.self)` |
| iOS 16 legacy model | `@StateObject` owner, `@ObservedObject` injected |

Choose ownership first; do not introduce a reference model when value state is enough.

## New View Workflow

1. Define state ownership, dependencies, and minimum OS.
2. Sketch hierarchy, routing, and presentation; read navigation/sheet/deeplink refs when complex.
3. Build and verify before widening call-site changes.
4. Add async loading and explicit error/loading UI when needed.
5. Add previews for primary/secondary states and accessibility IDs/labels for interactive UI.
6. Validate build/previews/state propagation/list identity/observation scope. If build fails, fix the exact error before continuing.

## Anti-Patterns

- Giant views mixing layout, business logic, networking, routing, and formatting.
- Multiple booleans for exclusive sheets/alerts/destinations.
- Live service calls from `body`.
- `AnyView` as a composition escape hatch.
- Defaulting every shared dependency to `@EnvironmentObject` or a global router.

## References

- `references/components-index.md`
- `references/navigationstack.md`
- `references/sheets.md`
- `references/deeplinks.md`
- `references/app-wiring.md`
- `references/async-state.md`
- `references/previews.md`
- `references/performance.md`

Use current Apple docs when API availability or platform guidance may have changed.

### Source: `ios_1296`

# iOS Essentials

Comprehensive guidance for iOS app development. This skill aggregates specialized modules for different aspects of iOS development.

## When This Skill Activates

Use this skill when the user:
- Asks about iOS development best practices
- Wants code review for iOS/Swift projects
- Needs UI/UX review against Human Interface Guidelines
- Wants accessibility audit for iOS apps
- Is planning a new iOS app
- Needs help with SwiftUI patterns for iOS
- Wants to scaffold a project from the CLI, or integrate HealthKit, Core Motion, camera scanning, WeatherKit, location, maps, calendar, or local notifications
- Asks about navigation architecture (NavigationStack, NavigationSplitView, TabView)
- Wants to run/launch the app in the Simulator or screenshot it to verify a change

## Available Skills

Read relevant module files based on the user's needs:

### coding-best-practices/
Swift code quality and modern idioms for iOS.
- Modern Swift patterns and idioms
- Architecture patterns (MVVM, Clean Architecture)
- Code quality standards
- Performance optimization

### ui-review/
UI/UX review against Apple HIG.
- Human Interface Guidelines compliance
- Font usage and Dynamic Type support
- Accessibility review (VoiceOver, color contrast)
- SwiftUI best practices for iOS/watchOS

### accessibility-audit/
Structured accessibility audit workflow (advisory).
- Automated XCUITest audits (`performAccessibilityAudit`) + CI patterns
- Accessibility Inspector workflow
- Manual VoiceOver / Voice Control / Dynamic Type passes per common task
- App Store Accessibility Nutrition Label evaluation + declaration

### navigation-patterns/
SwiftUI navigation architecture patterns.
- NavigationStack, NavigationLink, navigationDestination
- NavigationSplitView (two/three column, iPad/macOS)
- TabView (iOS 18 customizable tabs, sidebar mode)
- Programmatic navigation (NavigationPath, pop-to-root, state restoration)
- Navigation transitions (zoom, custom animations)

### app-planner/
iOS app planning and analysis.
- New app concept to architecture
- Existing app audits
- Tech stack evaluation
- Product planning guidance

### run-simulator/
Build, install, launch, and screenshot the app in the Simulator to verify a
change visually (operational — uses Bash, not just guidance).
- Discover scheme + an available simulator (no hardcoded device names)
- Build for the simulator and resolve the `.app` + bundle id
- Boot, install, launch, then screenshot and read it back
- Drive navigation / deep links to reach the changed screen

### run-device/
Run an app on a physical iPhone/iPad from the CLI (no Xcode GUI).
- Build + code-sign for a device with `xcodebuild -allowProvisioningUpdates`
- Install and launch via `devicectl`
- Screenshot on hardware via `libimobiledevice`
- Device prerequisites (Developer Mode, pairing) and signing gotchas

### project-bootstrap/
Create the project from the CLI with XcodeGen (`project.yml` as source of truth).
- Entitlements + Info.plist usage strings per capability
- Signing team setup; simulator builds with no signing
- Adding targets without touching `project.pbxproj`

### healthkit/
Apple Health on iPhone.
- SwiftUI permission sheet, invisible read-denial handling
- Statistics/sample/anchored query descriptors, writing samples, background delivery
- iOS 27 limited read access (`earliestAuthorizedSampleDate`), new types
- Simulator seeding, App Review 5.1.3 rules

### device-sensors/
Core Motion: steps, floors, activity type, altitude, tilt.
- Swift 6-safe async wrappers (no async overloads, non-Sendable results)
- Core Motion vs HealthKit decision

### camera-scanning/
On-device scanning and OCR.
- DataScannerViewController (live text/barcodes), document camera
- Swift Vision `RecognizeTextRequest`, permission-free `PhotosPicker`

### native-services/
Apple services that replace a backend.
- WeatherKit (+ attribution), CLLocationUpdate/CLServiceSession, MapKit search
- EventKit access levels, local notifications

### assistive-access/
Assistive Access implementation for cognitive accessibility including simplified scenes, navigation icons, runtime detection, and design principles.

### ipad-patterns/
iPadOS-specific patterns including Stage Manager, multi-window, drag and drop, keyboard shortcuts, pointer interactions, and Apple Pencil support.

### migration-patterns/
Migration guides for CoreData to SwiftData, UIKit to SwiftUI, ObservableObject to @Observable, XCTest to Swift Testing, Objective-C to Swift, and StoreKit 1 to StoreKit 2.

## How to Use

1. Identify user's need from their question
2. Read relevant module files from subdirectories
3. Apply the guidance to their specific context
4. Reference Apple HIG documentation when needed

## Example Workflow

**User asks for UI review:**
1. Read `ui-review/SKILL.md` for the full review process
2. Check their SwiftUI code against HIG
3. Verify accessibility compliance
4. Report findings with specific recommendations

### Source: `ios_1296/camera-scanning`

# Camera & Scanning

Apple ships three production-grade scanners and an OCR engine. All of them run on
device, cost nothing, and replace what used to be a cloud OCR subscription.
Every snippet below compiles against the iOS 27 SDK (Swift 6 and default-MainActor modes).

Image *classification* / custom models → `core-ml`. Feeding an image to the
on-device LLM → `apple-intelligence/foundation-models` (models-and-agents.md, vision input).

## When This Skill Activates

- Scan receipts, nutrition labels, business cards, serial numbers, QR/barcodes
- "Scan a document", multi-page capture with auto-crop
- Extract text from photos the user already has
- Choosing between the live scanner, document camera, and OCR-after-capture

## Pick the Tool

| Need | Tool | Permission |
|---|---|---|
| Point camera, tap text/barcode live | `DataScannerViewController` (VisionKit) | Camera |
| Flatbed-style pages, auto edge-detect, multi-page | `VNDocumentCameraViewController` (VisionKit) | Camera |
| Text from an existing photo/scan | `RecognizeTextRequest` (Vision) | none |
| Pick photos from the library | `PhotosPicker` (PhotosUI) | **none**, out-of-process picker |

✅ Start with `PhotosPicker` + OCR when the use case allows it: no permission prompt, works in the Simulator.
❌ Requesting full photo-library access to import one image. The picker already returns only what the user chose.

Setup: `NSCameraUsageDescription` ("MyApp scans food labels to log meals.") for the two camera tools.

## Live Scanner (text + barcodes)

```swift
import SwiftUI
import VisionKit

struct LiveScanner: UIViewControllerRepresentable {
    var onFound: (String) -> Void

    static var isUsable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [.text(), .barcode(symbologies: [.qr, .ean13])],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {
        if !vc.isScanning { try? vc.startScanning() }
    }

    static func dismantleUIViewController(_ vc: DataScannerViewController, coordinator: Coordinator) {
        vc.stopScanning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(onFound: onFound) }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onFound: (String) -> Void
        init(onFound: @escaping (String) -> Void) { self.onFound = onFound }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text): onFound(text.transcript)
            case .barcode(let code): onFound(code.payloadStringValue ?? "")
            @unknown default: break
            }
        }
    }
}
```

- `isSupported`: device has the Neural Engine (A12+). `isAvailable`: camera permission granted and not restricted. Check both, and fall back to `PhotosPicker` + OCR.
- `.text(textContentType: .URL)` (also `.telephoneNumber`, `.emailAddress`, `.dateTimeDuration`…) narrows recognition.
- **Simulator: not supported.** Test on device.

## Document Camera

```swift
import SwiftUI
import VisionKit

struct DocumentScanner: UIViewControllerRepresentable {
    var onScan: ([UIImage]) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ vc: VNDocumentCameraViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    @MainActor final class Coordinator: NSObject, @MainActor VNDocumentCameraViewControllerDelegate {
        let parent: DocumentScanner
        init(parent: DocumentScanner) { self.parent = parent }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.onScan((0..<scan.pageCount).map { scan.imageOfPage(at: $0) })
            parent.dismiss()
        }
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }
    }
}
```

Present it with `.fullScreenCover`. Note the **isolated conformance**
(`@MainActor VNDocumentCameraViewControllerDelegate`, Swift 6.2+) on a `@MainActor` class:

❌ Plain `final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate` → Swift 6 warnings touching `dismiss`/`onScan`.
❌ `@MainActor final class … VNDocumentCameraViewControllerDelegate` without the isolated conformance → **error**: "conformance crosses into main actor-isolated code".

## OCR on Any Image (Swift Vision API)

```swift
import Vision

func recognizeText(in imageData: Data) async throws -> [String] {
    var request = RecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    let observations = try await request.perform(on: imageData)
    return observations.compactMap { $0.topCandidates(1).first?.string }
}
```

`perform(on:)` also accepts `CGImage`, `CIImage`, `CVPixelBuffer`, and a file `URL`.
Set `request.recognitionLanguages` for non-English text. `.fast` suits live preview; `.accurate` suits a captured page.

✅ Use the struct-based Swift Vision API (`RecognizeTextRequest`, iOS 18+).
❌ New code on `VNRecognizeTextRequest` + `VNImageRequestHandler`. That's the older callback API, wordier and not concurrency-native.

## Photo Import (no permission)

```swift
import SwiftUI
import PhotosUI

struct PhotoImport: View {
    @State private var selection: PhotosPickerItem?
    @State private var lines: [String] = []

    var body: some View {
        PhotosPicker("Import receipt", selection: $selection, matching: .images)
            .onChange(of: selection) { _, item in
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
                    lines = (try? await recognizeText(in: data)) ?? []
                }
            }
    }
}
```

## Turning Text Into Data

OCR gives you lines; the app usually wants fields (merchant, total, date). Options,
cheapest first:

1. `NSDataDetector` / regex for dates, amounts, phone numbers. Works on every device.
2. **Foundation Models** `@Generable` extraction, gated on availability (`apple-intelligence/on-device-ai-kit`):

```swift
// @Generable struct Receipt { var merchant: String; var total: Double; var date: String }
// let receipt = try await session.respond(to: lines.joined(separator: "\n"), generating: Receipt.self).content
```

Fall back to option 1 on devices without Apple Intelligence. Never block the core flow on the LLM.

## Checklist

- [ ] `NSCameraUsageDescription` if a camera tool is used
- [ ] `DataScannerViewController.isSupported && .isAvailable` checked, with fallback
- [ ] PhotosPicker path exists (Simulator, older devices, denied camera)
- [ ] Document camera coordinator uses `@MainActor` class + `@MainActor` conformance
- [ ] OCR on Swift Vision API; recognition languages set when non-English
- [ ] Scanned images stored locally; never uploaded without consent

## References

- VisionKit DataScannerViewController: https://developer.apple.com/documentation/visionkit/datascannerviewcontroller
- VNDocumentCameraViewController: https://developer.apple.com/documentation/visionkit/vndocumentcameraviewcontroller
- RecognizeTextRequest: https://developer.apple.com/documentation/vision/recognizetextrequest
- PhotosPicker: https://developer.apple.com/documentation/photosui/photospicker
- Related: `core-ml`, `apple-intelligence/on-device-ai-kit`, `apple-intelligence/visual-intelligence`

### Source: `ios_1296/device-sensors`

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

### Source: `ios_1296/healthkit`

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

### Source: `ios_1296/native-services`

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

### Source: `ios_1296/project-bootstrap`

# Project Bootstrap (CLI, XcodeGen)

Xcode has no `xcodebuild new`. An agent that hand-writes `project.pbxproj` breaks
it within three edits. **XcodeGen** turns a 40-line `project.yml` into a real
`.xcodeproj`, so capabilities, Info.plist keys, and targets become reviewable
YAML diffs instead of opaque UUID soup.

Verified 2026-10-03: XcodeGen 2.46 + Xcode 27.0 generates, builds, and runs a
Swift Testing target on an iOS 27 simulator using `templates/project.yml`.

## When This Skill Activates

- "Start a new app", "scaffold the project", "set up Xcode from the terminal"
- Adding a capability (HealthKit, WeatherKit, iCloud) or a target (widget, tests)
- `project.pbxproj` merge conflicts or an agent that corrupted the project file
- Entry point from `product/local-first-app` step 1

Not for: existing projects the user wants to keep hand-managed in Xcode (adopting
XcodeGen is a one-way door for that team — ask first).

## Process

### 1. Install + scaffold

```bash
brew install xcodegen                       # one-time
mkdir -p MyApp/{Sources/App,Tests,scripts} && cd MyApp
cp <skill>/templates/project.yml .          # then rename MyApp → real name throughout
git init
printf 'build/\n*.xcodeproj/\n.env.ship\nfeedback/\nDerivedData/\n' > .gitignore
```

Ignoring `*.xcodeproj/` is deliberate: the generated project is a build
artifact. Commit `project.yml`. Every teammate (and CI) runs `xcodegen generate`.

### 2. Minimum sources

```swift
// Sources/App/MyAppApp.swift
import SwiftUI

@main
struct MyAppApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

```swift
// Tests/MyAppTests.swift
import Testing
@testable import MyApp

@Test func launchesWithEmptyStore() async throws {
    #expect(true) // replace with first real behavior test (see testing/tdd-feature)
}
```

### 3. Generate, build, test

```bash
xcodegen generate
SIM=$(xcrun simctl list devices available | grep -m1 -oE 'iPhone [^(]+\(([0-9A-F-]{36})\)' | grep -oE '[0-9A-F-]{36}')
xcodebuild test -project MyApp.xcodeproj -scheme MyApp -destination "id=$SIM" CODE_SIGNING_ALLOWED=NO | tail -3
```

`CODE_SIGNING_ALLOWED=NO` keeps simulator work free of signing setup entirely.
Signing only matters for a real device or TestFlight (`generators/testflight-ship`).

### 4. Add a capability = edit YAML, regenerate

| Service | `entitlements.properties` | `info.properties` usage key(s) |
|---|---|---|
| HealthKit | `com.apple.developer.healthkit: true`, `com.apple.developer.healthkit.access: []` | `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription` |
| HealthKit background delivery | `com.apple.developer.healthkit.background-delivery: true` | — |
| WeatherKit | `com.apple.developer.weatherkit: true` | — (also enable WeatherKit on the App ID — see `ios/native-services`) |
| iCloud / CloudKit | `com.apple.developer.icloud-services: [CloudKit]`, `com.apple.developer.icloud-container-identifiers: [iCloud.com.you.MyApp]` | — |
| Location | — | `NSLocationWhenInUseUsageDescription` |
| Motion | — | `NSMotionUsageDescription` |
| Microphone + speech | — | `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription` |
| Camera | — | `NSCameraUsageDescription` |
| Calendar (add only) | — | `NSCalendarsWriteOnlyAccessUsageDescription` |
| Calendar (read) | — | `NSCalendarsFullAccessUsageDescription` |
| Reminders | — | `NSRemindersFullAccessUsageDescription` |
| Foundation Models / Writing Tools / Image Playground | none | none |

✅ Usage strings say *what the user gets*: "MyApp reads your steps to show daily trends."
❌ "This app needs access to Health data." — App Review rejects vague purpose strings (5.1.1).

❌ Leaving template usage strings for services the app never calls — reviewers
ask why, and testers see permission prompts that make no sense. Delete unused rows.

### 5. Signing (once per machine)

Automatic signing needs a team ID, nothing else:

```bash
# Paid account: developer.apple.com/account → Membership → Team ID
# Free account: Xcode ▸ Settings ▸ Accounts ▸ add Apple ID; Team ID is shown for "(Personal Team)"
echo 'TEAM_ID=ABCDE12345' >> .env.ship
```

`ship.sh` passes `DEVELOPMENT_TEAM` and `-allowProvisioningUpdates`, so Xcode
mints the App ID, enables entitlements, and creates profiles on first build.
Keep `DEVELOPMENT_TEAM: ""` in `project.yml` so the repo is not tied to one person.

### 6. Adding targets later

```yaml
  MyAppWidget:
    type: app-extension
    platform: iOS
    sources: [Widget]
    info:
      path: Widget/Info.plist
      properties:
        NSExtension:
          NSExtensionPointIdentifier: com.apple.widgetkit-extension
  # and under MyApp:
  #   dependencies:
  #     - target: MyAppWidget
```

Then `xcodegen generate`. For widget code itself see `generators/widget-generator`.

## Gotchas

- **Bundle ID collisions**: `com.example.*` is rejected on device builds. Use a reverse-DNS you control.
- **New Swift file not compiling?** XcodeGen globs `sources:` at generate time — rerun `xcodegen generate` after adding files (ship.sh does this automatically).
- **Default MainActor isolation is on** (matches new Xcode 26+ projects). Snippets in the sibling skills were compiled under both this mode and plain Swift 6 mode.
- **Don't mix**: once on XcodeGen, capability toggles made in Xcode's Signing & Capabilities tab are overwritten on next generate. Make them in YAML.

## Checklist

- [ ] `project.yml` committed; `*.xcodeproj/` and `.env.ship` git-ignored
- [ ] Bundle ID is unique and under a domain you own
- [ ] Deployment target iOS 27.0
- [ ] Only the usage strings / entitlements for services actually used
- [ ] `ITSAppUsesNonExemptEncryption: false` (unless you ship custom crypto)
- [ ] `xcodebuild test` passes on a simulator with `CODE_SIGNING_ALLOWED=NO`

## References

- XcodeGen project spec: https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md
- Entitlements: https://developer.apple.com/documentation/bundleresources/entitlements
- Info.plist privacy keys: https://developer.apple.com/documentation/bundleresources/information-property-list
- Related: `ios/run-simulator`, `ios/run-device`, `generators/testflight-ship`, `product/local-first-app`
