---
name: ios-development
description: Comprehensive iOS development guidance including Swift best practices, SwiftUI patterns, UI/UX review against HIG, and app planning. Also covers CLI project scaffolding (XcodeGen), HealthKit, Core Motion sensors, camera scanning/OCR, and native services (WeatherKit, location, MapKit, EventKit, local notifications). Use for iOS code review, best practices, accessibility audits, or planning new iOS apps.
allowed-tools: [Read, Glob, Grep, WebFetch]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27 / macOS 27
---

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
