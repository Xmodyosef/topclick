---
name: project-bootstrap
description: Create a new iOS app project entirely from the command line with XcodeGen — project.yml as source of truth, entitlements, Info.plist usage strings, signing team, test target — so Claude can scaffold, build, and test without opening Xcode. Use when starting a new app, when an agent needs to add targets/capabilities without hand-editing project.pbxproj, or when the user says "new project", "scaffold", or "set up Xcode project".
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27 / Xcode 27
---

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
