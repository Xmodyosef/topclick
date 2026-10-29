# Integrated Reference Bundle 02

Combines 11 related source skills from `security-auditing` into one navigable reference file.

## Source map

- `generators/auth-flow/SKILL.reference.md`
- `generators/permission-priming/SKILL.reference.md`
- `keyboard-deep-audit/SKILL.reference.md`
- `legal/privacy-policy/SKILL.reference.md`
- `legal/privacy-publish/SKILL.reference.md`
- `legal_1370/privacy-publish/SKILL.reference.md`
- `security/SKILL.reference.md`
- `security/privacy-manifests/SKILL.reference.md`
- `security-audit/SKILL.reference.md`
- `security-audit_9267/SKILL.reference.md`
- `shared/skill-auditor/SKILL.reference.md`

## Integrated guidance

### Source: `generators/auth-flow`

# Auth Flow Generator

Generate a complete authentication flow with Sign in with Apple, biometric authentication (Face ID/Touch ID), and secure Keychain storage.

## When This Skill Activates

Use this skill when the user:
- Asks to "add authentication" or "add login"
- Mentions "Sign in with Apple" or "SIWA"
- Wants "Face ID login" or "biometric auth"
- Asks about "Keychain" or "secure storage"
- Mentions "user session" or "auth token"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check for existing auth implementations
- [ ] Check for AuthenticationServices framework usage
- [ ] Verify entitlements file exists
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing auth:
```
Glob: **/*Auth*.swift, **/*Keychain*.swift
Grep: "ASAuthorizationController" or "LAContext"
```

If found, ask user:
- Replace existing implementation?
- Extend with additional methods?

### 3. Required Capabilities

**Sign in with Apple requires:**
- Add "Sign in with Apple" capability in Xcode
- Configure in App Store Connect
- Add entitlement: `com.apple.developer.applesignin`

## Configuration Questions

Ask user via AskUserQuestion:

1. **Authentication methods?** (multi-select)
   - Sign in with Apple
   - Biometrics (Face ID/Touch ID)
   - Both

2. **Session storage?**
   - Keychain (secure, persists reinstall)
   - UserDefaults (simple, cleared on reinstall)

3. **Session management?**
   - Auto-refresh tokens
   - Manual refresh
   - No token refresh needed

## Generation Process

### Step 1: Create Core Files

Generate these files:
1. `AuthenticationManager.swift` - Core auth orchestration
2. `KeychainManager.swift` - Secure storage
3. `SignInWithAppleManager.swift` - SIWA handling
4. `BiometricAuthManager.swift` - Face ID/Touch ID

### Step 2: Create SwiftUI Components

Based on configuration:
- `SignInWithAppleButton.swift` - SwiftUI button wrapper
- `AuthenticationView.swift` - Complete auth UI

### Step 3: Determine File Location

Check project structure:
- If `Sources/` exists → `Sources/Auth/`
- If `App/` exists → `App/Auth/`
- Otherwise → `Auth/`

## Entitlements Required

### Sign in with Apple
```xml
<!-- YourApp.entitlements -->
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

### Keychain Sharing (optional)
```xml
<key>keychain-access-groups</key>
<array>
    <string>$(AppIdentifierPrefix)com.yourcompany.shared</string>
</array>
```

## Info.plist Required

### Face ID Usage Description
```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to securely sign in to your account</string>
```

## Output Format

After generation, provide:

### Files Created
```
Sources/Auth/
├── AuthenticationManager.swift      # Core orchestration
├── KeychainManager.swift            # Secure storage
├── SignInWithAppleManager.swift     # SIWA delegate
├── BiometricAuthManager.swift       # Face ID/Touch ID
├── AuthenticationState.swift        # Auth state model
└── Views/
    ├── SignInWithAppleButton.swift  # SwiftUI button
    └── AuthenticationView.swift     # Complete UI
```

### Integration Steps

**App Entry Point:**
```swift
@main
struct MyApp: App {
    @State private var authManager = AuthenticationManager()  // AuthenticationManager is @Observable

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
            } else {
                AuthenticationView()
            }
        }
        .environment(authManager)
    }
}
```

**Sign in with Apple Button:**
```swift
SignInWithAppleButtonView { result in
    switch result {
    case .success(let user):
        print("Signed in: \(user.id)")
    case .failure(let error):
        print("Failed: \(error)")
    }
}
```

**Biometric Auth:**
```swift
Button("Unlock with Face ID") {
    Task {
        if await BiometricAuthManager.shared.authenticate() {
            // Authenticated
        }
    }
}
```

### Required Setup

1. **Xcode Capabilities:**
   - Add "Sign in with Apple" capability
   - Enable Keychain Sharing (if needed)

2. **App Store Connect:**
   - Configure Sign in with Apple for your App ID

3. **Info.plist:**
   - Add `NSFaceIDUsageDescription`

### Testing Instructions

**Sign in with Apple:**
- Use Simulator for basic testing
- Test on device for full flow
- Use sandbox Apple ID for testing

**Biometrics:**
- Simulator: Features > Face ID > Enrolled
- Test enrolled/not enrolled states
- Test failed authentication

## References

- **auth-patterns.md** - Security best practices
- **templates/** - All template files
- Apple Docs: Authentication Services, LocalAuthentication

### Source: `generators/permission-priming`

# Permission Priming Generator

Generate pre-permission priming screens — shown before iOS system permission dialogs to explain WHY the app needs access. Dramatically increases permission grant rates vs. cold-prompting users with the system alert.

## When This Skill Activates

Use this skill when the user:
- Asks to "add permission priming" or "pre-permission screen"
- Mentions "explain permissions" or "permission request screen"
- Wants to "ask for camera permission" or "notification permission"
- Asks about "location permission explanation" or "permission grant rate"
- Wants to "prime before requesting access" or "improve opt-in rates"
- Mentions "permission dialog" or "permission flow"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Existing Permission Code
Search for existing permission handling:
```
Glob: **/*Permission*.swift, **/*Authorization*.swift
Grep: "requestAuthorization" or "AVCaptureDevice" or "UNUserNotificationCenter" or "CLLocationManager" or "PHPhotoLibrary"
```

If existing permission code found:
- Ask if user wants to wrap existing calls with priming screens or replace entirely
- If wrapping, integrate priming views upstream of existing request calls

### 3. Info.plist Usage Description Strings
Search for required usage description keys:
```
Grep: "NSCameraUsageDescription" or "NSMicrophoneUsageDescription" or "NSLocationWhenInUseUsageDescription" or "NSPhotoLibraryUsageDescription" or "NSContactsUsageDescription" or "NSHealthShareUsageDescription"
```

If missing keys found for requested permissions:
- Warn user that the app will crash without the corresponding Info.plist entry
- Provide the required key and a suggested description string

## Configuration Questions

Ask user via AskUserQuestion:

1. **Which permissions to prime?** (multi-select)
   - Push Notifications
   - Camera
   - Photo Library
   - Location (When In Use)
   - Location (Always)
   - Microphone
   - Contacts
   - Health (HealthKit)
   - App Tracking Transparency (ATT)

2. **Priming style?**
   - Full-screen (dedicated view with illustration, title, benefits, CTA) — recommended
   - Alert-style (compact alert-like overlay before system prompt)
   - Inline (embedded card within existing content)

3. **Include "Not Now" option?**
   - Yes (recommended — reduces user frustration, can re-prompt later)
   - No (only "Enable" button — more aggressive)

4. **Show benefits illustration?**
   - SF Symbol (simple, matches system style)
   - Custom illustration area (placeholder for designer asset)
   - None (text only)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `PermissionType.swift` — Enum of all permission types with metadata
2. `PermissionStatus.swift` — Unified status enum wrapping platform-specific statuses
3. `PermissionManager.swift` — @Observable class that checks, requests, and opens Settings

### Step 3: Create UI Files
4. `PermissionPrimingView.swift` — Pre-permission screen with benefits and CTA
5. `PermissionStatusTracker.swift` — Monitors status changes from Settings

### Step 4: Create Modifier Files
6. `PermissionGatedModifier.swift` — ViewModifier that gates content behind permission check

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/Permissions/`
- If `App/` exists -> `App/Permissions/`
- Otherwise -> `Permissions/`

## Output Format

After generation, provide:

### Files Created
```
Permissions/
├── PermissionType.swift            # Permission enum with metadata
├── PermissionStatus.swift          # Unified status wrapper
├── PermissionManager.swift         # Check, request, open Settings
├── PermissionPrimingView.swift     # Pre-permission priming screen
├── PermissionStatusTracker.swift   # Monitor status changes
└── PermissionGatedModifier.swift   # Gate content behind permission
```

### Integration Steps

**Basic priming before system prompt:**
```swift
// Show priming screen, then request system permission on tap
PermissionPrimingView(permissionType: .notifications) {
    // User granted — proceed with feature
    startSendingNotifications()
} onDenied: {
    // User denied or tapped "Not Now"
    showLaterPrompt()
}
```

**Gate a feature behind permission:**
```swift
// Camera feature gated behind permission
CameraView()
    .permissionGated(.camera) {
        // Priming screen shown automatically if not yet authorized
    }
```

**In onboarding flow:**
```swift
struct OnboardingPermissionsView: View {
    @State private var permissionManager = PermissionManager()

    var body: some View {
        VStack(spacing: 32) {
            PermissionPrimingView(permissionType: .notifications) {
                // Move to next permission
            } onDenied: {
                // Skip, ask later
            }
        }
    }
}
```

**Check status and re-prompt after denial:**
```swift
struct SettingsView: View {
    @State private var permissionManager = PermissionManager()

    var body: some View {
        Section("Permissions") {
            ForEach(PermissionType.allCases, id: \.self) { type in
                PermissionRow(
                    type: type,
                    status: permissionManager.status(for: type),
                    onRequest: { permissionManager.openSettings() }
                )
            }
        }
    }
}
```

### Testing

```swift
@Test
func primingViewShowsBeforeSystemPrompt() async throws {
    let manager = PermissionManager()
    let status = await manager.status(for: .notifications)
    #expect(status == .notDetermined)
    // Priming view should appear before system dialog
}

@Test
func deniedPermissionDirectsToSettings() async throws {
    let manager = PermissionManager()
    // After denial, tapping "Enable" should open Settings
    let settingsURL = manager.settingsURL
    #expect(settingsURL != nil)
}

@Test
func permissionGatedModifierShowsPrimingWhenNotAuthorized() async throws {
    // ViewModifier should show priming screen when permission is .notDetermined
    // and show content when .authorized
}
```

## Common Patterns

### Prime Before First Use
Show priming screen at the natural moment the user first needs the feature, not during onboarding:
```swift
// User taps "Take Photo" -> show camera priming -> then system prompt
Button("Take Photo") {
    showCameraPriming = true
}
.sheet(isPresented: $showCameraPriming) {
    PermissionPrimingView(permissionType: .camera,
                          onGranted: { openCamera() },
                          onDenied: { showCameraPriming = false })
}
```

### Contextual Priming
Explain the benefit in context of what the user is trying to do:
```swift
PermissionPrimingView(
    permissionType: .location(.whenInUse),
    customTitle: "Find Nearby Restaurants",
    customDescription: "We use your location to show restaurants within walking distance."
) { ... }
```

### Re-Request After Denial
After denial, the system prompt cannot be shown again. Direct to Settings:
```swift
if permissionManager.status(for: .camera) == .denied {
    // Show explanation + "Open Settings" button
    PermissionDeniedView(permissionType: .camera) {
        permissionManager.openSettings()
    }
}
```

## Gotchas

- **Cannot re-show system prompt after denial.** Once the user denies a permission, iOS will never show the system dialog again. You must direct the user to Settings > Privacy to re-enable. Always handle the `.denied` state gracefully.
- **App Tracking Transparency (ATT) has special requirements.** ATT must be requested before tracking begins. The priming screen must NOT use misleading language. Apple reviews ATT implementations closely — avoid incentivizing users to allow tracking.
- **Health permissions have unique two-column UI.** HealthKit authorization uses its own system sheet with read/write toggles per data type. You cannot customize it. Your priming screen should explain which health data you need and why before presenting the HealthKit sheet.
- **Location "Always" requires progressive authorization.** You must first request `.whenInUse`, then separately request `.always`. iOS shows a follow-up prompt only after the user has used the app with When In Use access. Do not request Always upfront.
- **Provisional notifications (iOS 12+) bypass the prompt entirely.** With `.provisional`, notifications are delivered silently to Notification Center without asking. Consider whether quiet delivery is acceptable before building a priming screen.
- **Info.plist keys are mandatory.** If you call a permission API without the corresponding `NS*UsageDescription` key in Info.plist, the app will crash immediately. Always verify these keys exist.

## References

- **templates.md** — All production Swift templates for permission priming
- Related: `generators/push-notifications` — Push notification setup and handling
- Related: `generators/consent-flow` — GDPR/privacy consent flows

### Source: `keyboard-deep-audit`

# Keyboard Deep Audit

Combines three disciplines: tight feedback loops for hard bugs, iOS keyboard extension constraints, and evidence-before-claims verification.

## Phase 0: iOS Keyboard Constraints (always check first)

- Microphone DISALLOWED in keyboard extensions.
- Opening other apps BLOCKED.
- Memory limit 30-60MB. Silent crash if exceeded. No crash logs.
- Persistence ONLY via App Groups. No UserDefaults for cross-process data.
- Network requires Full Access enabled by user.
- AVAudioSession category playback can conflict with host app audio. ambient + mixWithOthers is safer.
- Bundle size matters: every PNG and JSON counts against the memory ceiling.

## Phase 1: Build a feedback loop

This is the skill. If you have a tight pass/fail signal, you will find the cause.

1. Failing test at the seam reaching the bug.
2. CLI invocation with fixture input, diffing stdout.
3. Headless script driving the keyboard UI.
4. Replay a captured trace.
5. Throwaway harness exercising one code path.
6. Property/fuzz loop for sometimes-wrong output.
7. Bisection harness between two known states.
8. Differential loop: old version vs new version.

Tighten: faster, sharper signal, more deterministic.

Non-deterministic bugs: raise reproduction rate until debuggable. 50% flake is debuggable; 1% is not.

If you cannot build a loop: stop. List what you tried. Ask for access, a captured artifact, or permission to add instrumentation.

Completion: one command already run, red-capable, deterministic, fast, agent-runnable.

## Phase 2: Reproduce + minimise

Run the loop. Confirm it produces the user's exact symptom. Shrink until every element is load-bearing.

## Phase 3: Hypothesise

3-5 ranked falsifiable hypotheses. Show to user before testing. Format: If X is the cause, then changing Y makes it disappear.

## Phase 4: Instrument

One variable at a time. Debugger first, targeted logs second. Tag every log [DEBUG-xxxx]. Never log everything.

## Phase 5: Fix + regression test

Write the test before the fix if a correct seam exists. Watch it fail, apply fix, watch it pass, re-run original loop.

## Phase 6: Cleanup + Verification Gate

NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.

Before claiming done:
1. IDENTIFY the command that proves it.
2. RUN it fresh.
3. READ full output, exit code, failure count.
4. VERIFY output confirms the claim.
5. ONLY THEN claim.

Red flags: should, probably, seems, Great!, Perfect!, Done! before verification.

### Source: `legal/privacy-policy`

# Privacy Policy & Legal Document Generator

Generate ready-to-use privacy policies, terms of service, and EULAs tailored to your app's data practices, third-party services, and target markets.

> **Disclaimer:** This skill generates template legal documents based on common indie app scenarios. Consult a qualified lawyer for apps handling sensitive data (health, financial, children's data), apps with complex data sharing arrangements, or apps operating in highly regulated industries. These templates are a strong starting point -- not a substitute for legal counsel.

## When This Skill Activates

Use this skill when the user:
- Needs a privacy policy for their app
- Needs terms of service or EULA
- Apple requires a privacy policy for App Store submission
- Is adding analytics, ads, or crash reporting and needs to update their privacy policy
- Asks about data collection disclosure or privacy compliance
- Mentions GDPR, CCPA, DPDP, or COPPA requirements for their app
- Wants to know what to declare in Apple's Privacy Nutrition Labels

## Pre-Generation Checks

Before generating documents, gather context from the project.

### 1. Look for Existing Legal Documents

```
Glob: **/privacy*.md, **/privacy*.html, **/privacy*.txt
Glob: **/terms*.md, **/terms*.html, **/terms*.txt
Glob: **/eula*.md, **/eula*.html, **/eula*.txt
Glob: **/legal/**
```

If existing documents found, ask user whether to replace or update them.

### 2. Check for Third-Party SDK Usage

```
Grep: "Firebase" or "GoogleAnalytics" or "Crashlytics"
Grep: "Mixpanel" or "Amplitude" or "PostHog"
Grep: "AdMob" or "AppLovin" or "UnityAds"
Grep: "FacebookSDK" or "GoogleSignIn" or "SignInWithApple"
Grep: "Sentry" or "Bugsnag" or "DataDog"
Grep: "RevenueCat" or "Adapty" or "Qonversion"
Grep: "TelemetryDeck" or "Plausible" or "CountlySDK"
```

Note detected SDKs to auto-populate data collection sections.

### 3. Detect Data Collection Patterns in Code

```
Grep: "UserDefaults" -- Local preferences storage
Grep: "CoreData" or "SwiftData" or "NSPersistentContainer" -- Local database
Grep: "CloudKit" or "CKContainer" -- Cloud sync
Grep: "URLSession" or "Alamofire" -- Network calls
Grep: "HealthKit" or "HKHealthStore" -- Health data
Grep: "CLLocationManager" or "CoreLocation" -- Location data
Grep: "AVCaptureSession" or "PHPhotoLibrary" -- Camera/photos
Grep: "Contacts" or "CNContactStore" -- Contacts access
Grep: "ATTrackingManager" -- App Tracking Transparency
Grep: "ASAuthorizationAppleIDProvider" -- Sign in with Apple
```

### 4. Check Info.plist for Permission Usage Descriptions

```
Grep: "NSCameraUsageDescription" or "NSPhotoLibraryUsageDescription"
Grep: "NSLocationWhenInUseUsageDescription" or "NSLocationAlwaysUsageDescription"
Grep: "NSHealthShareUsageDescription" or "NSHealthUpdateUsageDescription"
Grep: "NSContactsUsageDescription" or "NSMicrophoneUsageDescription"
Grep: "NSUserTrackingUsageDescription"
```

## Configuration Questions

Ask the user via AskUserQuestion:

### 1. What documents do you need?

- Privacy Policy only
- Terms of Service only
- EULA only
- All three (recommended for App Store apps)

### 2. What data does your app collect?

- No user data (fully offline, no accounts)
- Anonymous analytics only (usage events, crash data)
- Account with email (sign-in required)
- Account with personal info (name, email, profile, preferences)
- Health or financial data (triggers additional compliance sections)

### 3. What third-party services does your app use?

- None
- Analytics only (e.g., TelemetryDeck, Firebase Analytics)
- Analytics + crash reporting (e.g., Sentry, Crashlytics)
- Advertising (e.g., AdMob, AppLovin)
- Social login (e.g., Sign in with Apple, Google Sign-In)
- Multiple of the above (list them)

### 4. Does your app target or allow children under 13?

- No
- Yes (triggers COPPA section and stricter data practices)

### 5. Where will you host these documents?

- GitHub Pages (free, Markdown to HTML)
- In-app (Settings screen with WKWebView or Text view)
- Personal/company website
- All of the above (recommended -- Apple requires a publicly accessible URL)

## Generation Process

### Step 1: Select Template Sections

Read `templates.md` for the document templates.

Based on configuration answers, include or exclude sections:

| Answer | Sections Added |
|--------|---------------|
| No user data | Minimal privacy policy (no collection, no sharing) |
| Anonymous analytics | Analytics disclosure, third-party services list |
| Account with email | Account data, authentication, data retention |
| Personal info | Full data collection, user rights, data portability |
| Health/financial | Sensitive data handling, enhanced security, additional consent |
| Children under 13 | COPPA section, parental consent, limited data collection |

### Step 2: Fill in App-Specific Details

Replace template placeholders with detected or user-provided values:
- `[APP_NAME]` -- App display name
- `[DEVELOPER_NAME]` -- Developer or company name
- `[CONTACT_EMAIL]` -- Privacy contact email
- `[EFFECTIVE_DATE]` -- Document effective date
- `[WEBSITE_URL]` -- Developer website or privacy page URL

### Step 3: Add Region-Specific Sections

Include sections based on target markets:

**GDPR (European Union users):**
- Data controller identification
- Lawful basis for processing (consent, legitimate interest, contract)
- Data subject rights (access, rectification, erasure, portability, objection)
- Data Protection Officer contact (if applicable)
- Data retention periods
- Right to lodge complaint with supervisory authority

**CCPA (California users):**
- Categories of personal information collected
- Business purposes for collection
- "Do Not Sell or Share My Personal Information" notice
- Right to know, delete, and opt-out
- Non-discrimination for exercising rights
- Financial incentive disclosure (if applicable)

**DPDP (India users):**
- Data fiduciary identification
- Purpose of data processing
- Consent mechanism
- Data principal rights (access, correction, erasure, grievance redressal)
- Data retention limitations
- Processing of children's data (under 18)

**COPPA (children under 13):**
- Parental consent requirement
- Limited data collection (only what is strictly necessary)
- No behavioral advertising to children
- Parental rights (review, delete, refuse further collection)
- Safe harbor program compliance (if applicable)

### Step 4: Generate Apple Privacy Nutrition Label Mapping

Based on detected data practices, generate a mapping for App Store Connect:

```
Apple Privacy Nutrition Label Mapping
=====================================

Data Types to Declare:
- [ ] Contact Info: Email Address -- Used for: App Functionality, Account
- [ ] Identifiers: User ID -- Used for: App Functionality
- [ ] Usage Data: Product Interaction -- Used for: Analytics
- [ ] Diagnostics: Crash Data -- Used for: App Functionality
- [ ] Diagnostics: Performance Data -- Used for: Analytics

Data Linked to User: [List items linked to user identity]
Data Used to Track: [List items used for cross-app tracking, if any]

Tracking: [Yes/No -- triggers ATT requirement if Yes]
```

### Step 5: Output Documents

Generate documents in Markdown format. Place files based on user's hosting preference:

- **GitHub Pages**: `docs/privacy-policy.md`, `docs/terms-of-service.md`, `docs/eula.md`
- **In-app**: `Resources/Legal/privacy-policy.md`, etc.
- **Website**: Output to clipboard/file for manual upload
- **All**: Generate in `docs/` with guidance for in-app integration

## Apple-Required Privacy Disclosures

### App Store Connect Privacy Questions

When submitting to the App Store, Apple asks about data practices. Map generated privacy policy to these questions:

| Apple Question | Where to Find Answer |
|---------------|---------------------|
| Do you or your third-party partners collect data? | "Information We Collect" section |
| Data types collected | Privacy Nutrition Label mapping (Step 4) |
| Is data linked to user identity? | "How We Use Information" section |
| Is data used for tracking? | "Third-Party Services" section |

### Privacy Nutrition Labels

Declare these data types based on your app's practices:

| If Your App... | Declare These Types |
|----------------|-------------------|
| Has user accounts | Contact Info, Identifiers |
| Uses analytics | Usage Data (Product Interaction) |
| Has crash reporting | Diagnostics (Crash Data, Performance Data) |
| Shows ads | Identifiers (Device ID), Usage Data |
| Uses location | Location (Precise or Coarse) |
| Accesses photos | Photos or Videos |
| Accesses health data | Health & Fitness |
| Uses Sign in with Apple | Contact Info (Email), Identifiers (User ID) |

### When ATT (App Tracking Transparency) Is Required

Required for: IDFA access, linking user data with third-party data for advertising, or sharing user data with data brokers. Not required for first-party server-side analytics, crash reporting, fraud detection, or non-IDFA attribution (e.g., SKAdNetwork).

## Hosting Guidance

### GitHub Pages (Free, Recommended for Indie Devs)

1. Create `docs/` folder in your repo
2. Add privacy-policy.md, terms-of-service.md, eula.md
3. Enable GitHub Pages in repo Settings > Pages > Source: `/docs`
4. Your URL: `https://yourusername.github.io/yourapp/privacy-policy`

### In-App Display

```swift
// Option 1: WKWebView for hosted HTML
import WebKit

struct LegalDocumentView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView { WKWebView() }
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}

// Option 2: Bundled Markdown rendered as Text
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text(LocalizedStringKey(privacyPolicyMarkdown))
                .padding()
                .textSelection(.enabled)
        }
        .navigationTitle("Privacy Policy")
    }
}
```

### Apple Requirements for Privacy Policy URL

- Must resolve publicly (not behind login or in-app only) at all times -- Apple checks during review and requires it under App Store Connect's "App Privacy"
- Must also be accessible from within the app (Settings or About screen)

## Output Format

After generation, provide:

### Files Created

```
docs/
 ├── privacy-policy.md     # Privacy policy with region-specific sections
 ├── terms-of-service.md   # Terms of service (if requested)
 └── eula.md               # End-user license agreement (if requested)
```

### Apple Privacy Nutrition Label Checklist

Provide a checklist the user can follow in App Store Connect.

### Integration Checklist

- [ ] Host documents at a publicly accessible URL
- [ ] Add privacy policy URL to App Store Connect
- [ ] Add legal links to app Settings or About screen
- [ ] Complete Privacy Nutrition Labels in App Store Connect
- [ ] If using ATT, add `NSUserTrackingUsageDescription` to Info.plist
- [ ] Test that privacy policy URL loads correctly
- [ ] Set a calendar reminder to review documents annually

## References

- **templates.md** -- Full legal document templates with placeholders
- Related: `generators/consent-flow` -- GDPR/CCPA consent UI generation
- Related: `generators/account-deletion` -- Account deletion flow (App Store requirement)
- Related: `generators/permission-priming` -- Pre-permission UI for ATT
- Related: `monetization/` -- Subscription terms and pricing disclosures
- Apple App Review Guidelines Section 5.1 (Privacy)
- Apple App Store Connect Privacy Details documentation

### Source: `legal/privacy-publish`

# Privacy Publish

Close the "hosted legal pages + ASC URLs" gap: render `.planning/legal/{privacy,terms}.md` → host them → PATCH the Privacy/Support URLs onto the App Store version. The one thing with no API — the **App Privacy nutrition label** — is handed off as a precise checklist.

> Depends on the user's web infra, so **ask once, remember**. Hosting choice is theirs; the ASC URL-setting is the automatable part.

## Prerequisites

- Legal drafts exist: `.planning/legal/privacy.md`, `.planning/legal/terms.md` (from `legal/privacy-policy`).
- `_shared/asc-api/` set up (README).
- Set `ASC="python3 <path to asc.py>"` — resolve `asc.py` **relative to this SKILL.md file's location** (`../../_shared/asc-api/asc.py`), never the project cwd. Known install locations:
  - SwiftShip symlink install: `~/.claude/swiftship-skills/_shared/asc-api/asc.py`
  - Copied install: `.claude/skills/_shared/asc-api/asc.py` (project) or `~/.claude/skills/_shared/asc-api/asc.py` (global)
  - Plugin install: resolve from this file's location — the `_shared/` tree ships with the plugin.
- The app has a current editable App Store version + an en-US `appInfoLocalization` and `appStoreVersionLocalization` (get their ids first).

## Flow — dry-run → confirm → apply

1. **Render.** Markdown → minimal self-contained HTML (or keep `.md` if the host renders it).
2. **Publish** (pick per the user's infra — `AskUserQuestion` once, then remember in `.planning/`):
   - **git static site** — commit + push to the pages repo/branch.
   - **WordPress** — `POST /wp-json/wp/v2/pages` with an application password.
   - **Netlify / S3 / other** — the host's CLI.
   - **Browser fallback** — drive the CMS with `claude-in-chrome` (detect → preview → confirm → act → fall back, per `TOOL-HANDOFF.md`).
   - **Confirm both URLs resolve (HTTP 200)** before touching ASC.
3. **Set the ASC URLs** (REST — dry-run, confirm, then `--apply`):
   - **Privacy Policy URL** → `appInfoLocalizations` (`privacyPolicyUrl`):
     ```
     $ASC PATCH /v1/appInfoLocalizations/<id> '{"data":{"type":"appInfoLocalizations","id":"<id>","attributes":{"privacyPolicyUrl":"https://…/privacy"}}}' --apply
     ```
   - **Support / Marketing URL** → `appStoreVersionLocalizations` (`supportUrl`, `marketingUrl`) — PATCH the current version's en-US localization id.
4. **Nutrition label (manual — no API).** Emit a checklist matching `Sources/PrivacyInfo.xcprivacy` (e.g. *Data Not Collected*, no tracking) for the user to click in ASC ▸ App Privacy. Do not claim this step is automated.

## Done

- Legal pages live + resolving; Privacy/Support URLs set via API; nutrition-label checklist handed off.

## Caveats

- **Verify each endpoint/field against the current [ASC API reference](https://developer.apple.com/documentation/appstoreconnectapi) before `--apply`** (captured 2026-07).
- Confirm URLs return 200 *before* setting them in ASC — a dead Privacy URL is a common rejection (Guideline 5.1.1).
- The nutrition label and some age-rating specifics have **no public API** — those remain ASC-UI/manual by design.

### Source: `legal_1370/privacy-publish`

# Privacy Publish

Close the "hosted legal pages + ASC URLs" gap: render the privacy policy and terms markdown → host them → PATCH the Privacy/Support URLs onto the App Store version. The one thing with no API — the **App Privacy nutrition label** — is handed off as a precise checklist.

> Depends on the user's web infra, so **ask once, remember**. Hosting choice is theirs; the ASC URL-setting is the automatable part.

## When This Skill Activates

- "Host my privacy policy", "set the privacy policy URL in App Store Connect"
- App Store Connect rejects a submission for a missing or broken Privacy Policy / Support URL
- Legal drafts exist (`legal/privacy-policy`) and need a public home

## Prerequisites

- Legal drafts exist as markdown (from `legal/privacy-policy`), e.g. `legal/privacy.md` and `legal/terms.md` in the project.
- `_shared/asc-api/` set up (README).
- Set `ASC="python3 <path to asc.py>"` — resolve `asc.py` **relative to this SKILL.md file's location** (`../../_shared/asc-api/asc.py`), never the project cwd. Known install locations:
  - Copied install: `.claude/skills/_shared/asc-api/asc.py` (project) or `~/.claude/skills/_shared/asc-api/asc.py` (global)
  - Plugin install: resolve from this file's location — the `_shared/` tree ships with the plugin.
- The app has a current editable App Store version + an en-US `appInfoLocalization` and `appStoreVersionLocalization` (get their ids first).

## Flow — dry-run → confirm → apply

1. **Render.** Markdown → minimal self-contained HTML (or keep `.md` if the host renders it).
2. **Publish** (pick per the user's infra — `AskUserQuestion` once, then note the choice in the project, e.g. next to the legal drafts):
   - **git static site** — commit + push to the pages repo/branch.
   - **WordPress** — `POST /wp-json/wp/v2/pages` with an application password.
   - **Netlify / S3 / other** — the host's CLI.
   - **Browser fallback** — drive the CMS with a browser tool (Claude in Chrome): preview → confirm → act.
   - **Confirm both URLs resolve (HTTP 200)** before touching ASC.
3. **Set the ASC URLs** (REST — dry-run, confirm, then `--apply`):
   - **Privacy Policy URL** → `appInfoLocalizations` (`privacyPolicyUrl`):
     ```
     $ASC PATCH /v1/appInfoLocalizations/<id> '{"data":{"type":"appInfoLocalizations","id":"<id>","attributes":{"privacyPolicyUrl":"https://…/privacy"}}}' --apply
     ```
   - **Support / Marketing URL** → `appStoreVersionLocalizations` (`supportUrl`, `marketingUrl`) — PATCH the current version's en-US localization id.
4. **Nutrition label (manual — no API).** Emit a checklist matching `Sources/PrivacyInfo.xcprivacy` (e.g. *Data Not Collected*, no tracking) for the user to click in ASC ▸ App Privacy. Do not claim this step is automated.

## Done

- Legal pages live + resolving; Privacy/Support URLs set via API; nutrition-label checklist handed off.

## Caveats

- **Verify each endpoint/field against the current [ASC API reference](https://developer.apple.com/documentation/appstoreconnectapi) before `--apply`** (captured 2026-07).
- Confirm URLs return 200 *before* setting them in ASC — a dead Privacy URL is a common rejection (Guideline 5.1.1).
- The nutrition label and some age-rating specifics have **no public API** — those remain ASC-UI/manual by design.

## Common Mistakes

✅ Confirm both URLs return HTTP 200 before setting them in App Store Connect.
❌ Linking a PDF or a page behind login — reviewers and users must be able to open it in a browser.

## References

- [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/)
- [App privacy details](https://developer.apple.com/app-store/app-privacy-details/)
- Related: `legal/privacy-policy`, `security/privacy-manifests`, `_shared/asc-api`

### Source: `security`

# Security (category index)

General security guidance (Keychain patterns, biometric auth, certificate
pinning, ATS) was removed from this library after the 2026-07 blind-test
audit confirmed current models answer it correctly without a skill
(`tools/skill-audit/`, Fable-verified coverage 0.86). What remains here is
the material models get wrong or can't know.

## Available Skills

### privacy-manifests/
Privacy manifest audit — PrivacyInfo.xcprivacy format, required-reason APIs,
App Tracking Transparency declarations, and App Store submission requirements.

### Source: `security/privacy-manifests`

# Privacy Manifests

Advisory skill for implementing Apple's privacy manifest (PrivacyInfo.xcprivacy) requirements: manifest file format, required reason APIs, tracking declarations, third-party SDK privacy, and App Tracking Transparency.

## When This Skill Activates

Use this skill when the user:
- Asks about "privacy manifest" or "PrivacyInfo.xcprivacy"
- Mentions "required reason API" or App Store privacy rejection
- Needs to declare "tracking domains" or "NSPrivacyTracking"
- Asks about "App Tracking Transparency" or ATT
- Wants to audit third-party SDK privacy declarations
- Is preparing an app for App Store submission and mentions privacy
- Gets an App Store Connect warning about missing privacy manifests
- Asks about "privacy nutrition labels" or App Store privacy details

## Decision Tree

| Problem | Section |
|---------|---------|
| Creating PrivacyInfo.xcprivacy from scratch | Privacy Manifest File Format + Required Reason APIs |
| App Store rejection about required reason APIs | Required Reason APIs (match APIs in your code) |
| Declaring tracking domains | Tracking Domains and NSPrivacyTracking |
| Third-party SDK privacy | Third-Party SDK Declarations |
| Implementing ATT | App Tracking Transparency |
| Filling out App Store privacy labels | Privacy Nutrition Labels |
| Generating Xcode report | Xcode Privacy Report |

## Review Process

### 1. Scan the Project

```bash
Glob: **/PrivacyInfo.xcprivacy
Grep: "NSPrivacyAccessedAPITypes|NSPrivacyTracking|NSPrivacyTrackingDomains"
Grep: "NSFileCreationDate|NSFileModificationDate|NSURLCreationDateKey"
Grep: "systemUptime|ProcessInfo.*processInfo"
Grep: "volumeAvailableCapacity|URLResourceKey.*volume"
Grep: "UserDefaults"
Grep: "activeInputModes|UITextInputMode"
Grep: "ATTrackingManager|requestTrackingAuthorization"
```

### 2. Determine What Is Missing and Apply Fixes

Check: Does PrivacyInfo.xcprivacy exist? Are all required reason APIs declared? Is NSPrivacyTracking correct? Are tracking domains listed? Do third-party SDKs have their own manifests? Use the sections below to generate correct entries.

---

## Privacy Manifest File Format

The privacy manifest is a property list named `PrivacyInfo.xcprivacy`. Add it via File > New > File > App Privacy in Xcode. Four required top-level keys:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array/>
</dict>
</plist>
```

### Where to Place the File

- **App targets**: Add PrivacyInfo.xcprivacy to the root of the app bundle. In Xcode, ensure it is included in the target's "Copy Bundle Resources" build phase.
- **Frameworks/SDKs**: Place PrivacyInfo.xcprivacy in the root of the framework bundle.
- **Swift packages**: Place PrivacyInfo.xcprivacy in the package's resource bundle and declare it in Package.swift:

```swift
// Package.swift
.target(
    name: "MyLibrary",
    resources: [
        .copy("PrivacyInfo.xcprivacy")
    ]
)
```

---

## Required Reason APIs

Apple requires you to declare why your app uses certain system APIs. You must include at least one valid reason code for each API category your app uses.

### File Timestamp APIs (NSPrivacyAccessedAPICategoryFileTimestamp)

APIs that access file creation or modification dates.

| Reason Code | Description |
|-------------|-------------|
| DDA9.1 | Display file timestamps to the user |
| C617.1 | Access timestamps inside the app container, app group container, or CloudKit container |
| 3B52.1 | Access timestamps of files or directories the user specifically granted access to (document picker, drag and drop) |
| 0A2A.1 | Access timestamps for files managed by the app itself (third-party SDK only) |

Common triggers: `NSFileCreationDate`, `NSFileModificationDate`, `NSURLContentModificationDateKey`, `NSURLCreationDateKey`, `getattrlist`, `stat`, `fstat`.

### System Boot Time APIs (NSPrivacyAccessedAPICategorySystemBootTime)

APIs that read how long the system has been running.

| Reason Code | Description |
|-------------|-------------|
| 35F9.1 | Measure elapsed time between events within the app |
| 8FFB.1 | Calculate absolute timestamps for events (e.g., events that occurred before app launch) |
| 3D61.1 | Access system boot time for the purposes of user-facing functionality |

Common triggers: `systemUptime`, `ProcessInfo.processInfo.systemUptime`, `mach_absolute_time`, `clock_gettime(CLOCK_MONOTONIC)`.

### Disk Space APIs (NSPrivacyAccessedAPICategoryDiskSpace)

APIs that query available or total disk space.

| Reason Code | Description |
|-------------|-------------|
| E174.1 | Display disk space to the user |
| 85F4.1 | Check whether there is sufficient disk space to write files |
| AB6B.1 | Query disk space for the app's own functionality, do not send off device |
| 7D9E.1 | Query disk space for the app's own functionality, results sent off device (e.g., analytics) |

Common triggers: `volumeAvailableCapacityKey`, `volumeAvailableCapacityForImportantUsageKey`, `volumeAvailableCapacityForOpportunisticUsageKey`, `volumeTotalCapacityKey`, `statfs`, `statvfs`.

### User Defaults APIs (NSPrivacyAccessedAPICategoryUserDefaults)

APIs that read or write to UserDefaults.

| Reason Code | Description |
|-------------|-------------|
| CA92.1 | Read/write data accessible only to the app itself |
| 1C8F.1 | Read/write data accessible to app groups (shared UserDefaults) |
| C56D.1 | Read/write data from a third-party SDK for the SDK's own functionality |
| AC6B.1 | Read data from UserDefaults to retrieve a configuration set by an MDM (managed device) |

Common triggers: `UserDefaults`, `NSUserDefaults`, `standardUserDefaults`.

### Active Keyboards API (NSPrivacyAccessedAPICategoryActiveKeyboards)

APIs that enumerate installed keyboards.

| Reason Code | Description |
|-------------|-------------|
| 3EC4.1 | Customize the app's UI based on active keyboards (e.g., supporting specific languages) |
| 54BD.1 | A custom keyboard app accessing active keyboards to implement its functionality |

Common triggers: `UITextInputMode.activeInputModes`, `activeInputModes`.

### Declaring Required Reason APIs in the Manifest

Each entry has the category identifier and an array of reason codes. See "Common Patterns" below for a full XML example.

---

## Tracking Domains and NSPrivacyTracking

`NSPrivacyTracking` declares whether your app tracks users. Apple defines tracking as: linking user/device data from your app with data from other companies' apps, websites, or offline properties for advertising, or sharing data with data brokers.

Apple does **not** consider these to be tracking: on-device-only data linking, fraud detection, security, or compliance.

If NSPrivacyTracking is true:
- You must implement App Tracking Transparency (ATT) before any tracking occurs
- List all tracking domains in `NSPrivacyTrackingDomains` (the system blocks them until ATT is granted)

```xml
<key>NSPrivacyTracking</key>
<true/>
<key>NSPrivacyTrackingDomains</key>
<array>
    <string>analytics.example.com</string>
    <string>tracker.adnetwork.com</string>
</array>
```

If your app does not track users, set NSPrivacyTracking to false and leave the domains array empty.

---

## Third-Party SDK Declarations

### SDK Privacy Manifests

Starting Spring 2024, apps that include commonly used third-party SDKs must ensure those SDKs provide their own PrivacyInfo.xcprivacy files. Apple publishes a list of SDKs that require privacy manifests and signatures, including Alamofire, FBSDKCoreKit, Firebase, Google Analytics, Kingfisher, Lottie, Realm, SDWebImage, and many others. See [Apple's full list](https://developer.apple.com/support/third-party-SDK-requirements/).

### SDK Signatures

Third-party XCFrameworks should be signed by their developer. Prefer SDKs distributed through Swift Package Manager (signatures verified automatically). For XCFrameworks, verify the signature matches the expected developer.

### Auditing Third-Party SDKs

```bash
Glob: **/Pods/**/PrivacyInfo.xcprivacy
Glob: **/.build/**/PrivacyInfo.xcprivacy
Glob: **/Carthage/**/PrivacyInfo.xcprivacy
Grep: "pod '|.package(url:"
```

If a third-party SDK lacks a privacy manifest and uses required reason APIs, contact the maintainer -- declaring its API usage in your own manifest is a stopgap, not a fix.

---

## App Tracking Transparency

### When ATT Is Required

You must present the ATT prompt if:
- NSPrivacyTracking is true in your privacy manifest
- Your app links user data with third-party data for advertising
- You use advertising identifiers (IDFA) for tracking purposes

You do not need ATT for:
- First-party analytics that stay on-device or on your own servers without linking to third-party data
- SKAdNetwork attribution (privacy-preserving, no user-level data)
- Fraud detection or security purposes

### Implementation

```swift
import AppTrackingTransparency

func requestTrackingPermission() {
    ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .authorized:
            // IDFA available via ASIdentifierManager.shared().advertisingIdentifier
            break
        case .denied, .restricted:
            // Do not track
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
```

### Info.plist Requirement

```xml
<key>NSUserTrackingUsageDescription</key>
<string>We use this identifier to show you relevant ads and measure ad performance.</string>
```

### SKAdNetwork for Attribution

Register ad network identifiers in Info.plist:

```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>example123.skadnetwork</string>
    </dict>
</array>
```

---

## Privacy Nutrition Labels

The privacy manifest feeds into the App Store privacy labels ("nutrition labels") displayed on your app's product page. The connection works as follows:

| Manifest Key | App Store Privacy Label |
|-------------|-------------------------|
| NSPrivacyCollectedDataTypes | "Data Used to Track You" and "Data Linked to You" sections |
| NSPrivacyTracking | Determines if "Data Used to Track You" section appears |
| NSPrivacyAccessedAPITypes | Not directly shown, but required for submission |

### NSPrivacyCollectedDataTypes Format

Each entry declares: data type, whether it is linked to user identity, whether it is used for tracking, and purposes.

```xml
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeEmailAddress</string>
        <key>NSPrivacyCollectedDataTypeLinked</key>  <!-- linked to user identity? -->
        <true/>
        <key>NSPrivacyCollectedDataTypeTracking</key>  <!-- used for tracking? -->
        <false/>
        <key>NSPrivacyCollectedDataTypePurposes</key>
        <array>
            <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
        </array>
    </dict>
</array>
```

Common data types: `EmailAddress`, `Name`, `PhoneNumber`, `Location`, `DeviceID`, `CrashData`, `PerformanceData`, `ProductInteraction`, `PurchaseHistory` (prefix each with `NSPrivacyCollectedDataType`).

Common purposes: `AppFunctionality`, `Analytics`, `ThirdPartyAdvertising`, `ProductPersonalization` (prefix each with `NSPrivacyCollectedDataTypePurpose`).

The App Store privacy label must match your manifest declarations. Inconsistencies trigger review delays or rejections.

---

## Xcode Privacy Report

Generate a consolidated report via Product > Generate Privacy Report (or from the Organizer after archiving). Xcode produces a PDF listing all privacy manifest entries from the app and every embedded framework/SDK. Use this to verify all required reason APIs are declared, confirm third-party SDKs include their own manifests, and cross-check collected data types before filling out App Store Connect privacy labels.

---

## Top Mistakes

1. **Missing PrivacyInfo.xcprivacy entirely** -- Every App Store submission requires a privacy manifest. Without one, expect a warning or rejection.

2. **Using UserDefaults without declaring it** -- declare `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1`.
   - ❌ `UserDefaults.standard.set(true, forKey: "onboardingComplete")` with no manifest entry
   - ✅ Add CA92.1 declaration for data accessible only to the app

3. **Wrong reason code** -- using DDA9.1 (display to user) when you never show timestamps in the UI causes rejection; use C617.1 for app container access instead.

4. **Forgetting third-party SDK manifests** -- Your app's manifest does not cover SDKs. Each must provide its own. SDKs on Apple's list without manifests will flag your submission.

5. **NSPrivacyTracking true without ATT** -- If you declare tracking, you must implement the ATT prompt before any tracking occurs. Missing this causes rejection.

6. **Stale privacy nutrition labels** -- After updating your manifest, also update the App Store Connect privacy labels. Inconsistencies trigger review issues.

---

## Review Checklist

- [ ] PrivacyInfo.xcprivacy exists in the app target's bundle resources
- [ ] NSPrivacyTracking set correctly (true only if the app tracks users)
- [ ] NSPrivacyTrackingDomains lists all tracking domains (if tracking is true)
- [ ] All required reason APIs declared with valid reason codes (file timestamps, boot time, disk space, UserDefaults, active keyboards)
- [ ] Reason codes match actual API usage (not just any valid code)
- [ ] NSPrivacyCollectedDataTypes lists all collected data
- [ ] Third-party SDKs include their own PrivacyInfo.xcprivacy and are signed
- [ ] ATT prompt implemented if NSPrivacyTracking is true
- [ ] NSUserTrackingUsageDescription in Info.plist if ATT is used
- [ ] App Store Connect privacy labels match manifest declarations
- [ ] Xcode privacy report generated and reviewed (Product > Generate Privacy Report)
- [ ] Swift packages declare PrivacyInfo.xcprivacy in their resource bundle

## Common Patterns

### Typical App (No Tracking)

Most apps need at minimum UserDefaults declared. Start from the minimal manifest structure above and populate `NSPrivacyAccessedAPITypes`:

```xml
<key>NSPrivacyAccessedAPITypes</key>
<array>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>CA92.1</string>
        </array>
    </dict>
    <dict>
        <key>NSPrivacyAccessedAPIType</key>
        <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
        <key>NSPrivacyAccessedAPITypeReasons</key>
        <array>
            <string>C617.1</string>
        </array>
    </dict>
</array>
```

### App with Tracking and Ad Attribution

Add to the template above: set `NSPrivacyTracking` to `true`, list tracking domains, add `NSPrivacyCollectedDataTypes` entries (see "Privacy Nutrition Labels" for format), implement ATT, and add `NSPrivacyAccessedAPICategoryDiskSpace` with reason `7D9E.1` if sending disk metrics off-device.

---

## References

- [Apple: Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)
- [Apple: Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files/describing_use_of_required_reason_api)
- [Apple: Third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/)
- [Apple: App Tracking Transparency](https://developer.apple.com/documentation/apptrackingtransparency)
- [Apple: SKAdNetwork](https://developer.apple.com/documentation/storekit/skadnetwork)
- [Apple: App privacy details on the App Store](https://developer.apple.com/app-store/app-privacy-details/)

### Source: `security-audit`

# Security Audit

Find exploitable paths and prevent unsafe agent changes.

## Grok Build Mode

- Start in Plan Mode for any fix that touches auth, permissions, crypto, payments, secrets, or infrastructure.
- Use subagents for threat tracks:
  - `authz`: object ownership, roles, tenant boundaries.
  - `input`: injection, XSS, SSRF, deserialization, path traversal.
  - `secrets`: env files, logs, tokens, CI config.
  - `supply-chain`: dependencies, hooks, install scripts.
- Arena-style validation: require independent agreement for high-severity findings or reproduce with concrete evidence.
- Human-in-the-loop: do not run destructive security tooling or exploit production systems.

## Workflow

1. Define assets, trust boundaries, and attacker goal.
2. Inspect code paths that cross boundaries.
3. Look for concrete exploitability, not generic fear.
4. Propose minimal fixes with tests.
5. Run security-relevant tests or static checks when available.
6. Summarize residual risk.

## Findings

```text
[P1] Title
Asset:
Attack path:
Evidence:
Impact:
Fix:
Test:
```

## Guardrails

- Never print secrets.
- Do not add dependencies for security scanning without approval.
- Do not weaken auth checks to make tests pass.
- Treat third-party skills and hooks as untrusted code until reviewed.

## Example Prompts

```text
Use security-audit. Review this auth diff for tenant-boundary bypasses and missing regression tests.
```

```text
Audit `.grok/skills` and hooks for supply-chain or prompt-injection risks before I install them.
```

### Source: `security-audit_9267`

# Security Audit

Treat every hook, MCP, and agent capability as high-risk.

## Checklist (always cover these)

- Hard-coded secrets or credentials
- Unsafe command execution or shell injection
- Path traversal or arbitrary file access
- Insufficient input validation / sanitization
- Overly broad permissions in MCP servers or hooks
- Trust model for project-provided hooks/skills
- Data exfiltration risks (especially in research or browser MCPs)
- Logging of sensitive information

## Process

1. Identify the trust boundary for the change.
2. Trace data from untrusted sources (user input, files from disk, network, session logs).
3. Flag anything that can lead to code execution or secret access.
4. Propose the smallest hardening changes.
5. Recommend tests or verification steps (e.g. "try to escape the sandbox").

## When Working on Meta-Tooling

Extra scrutiny for anything that will run inside other people's agent sessions (skills, MCPs, hooks in this arsenal itself).

Always pair with `plan-mode-orchestrator` for security-related work.

### Source: `shared/skill-auditor`

# Skill Auditor

Audits every `SKILL.md` in `skills/` for frontmatter correctness, structural completeness, API/version drift, and cross-file reference integrity. Produces a prioritized markdown report. Read-only — never applies fixes.

## When This Skill Activates

Use this skill when the user:
- Says "audit skills", "audit my skills", "run the skill auditor"
- Asks to "check the skill repo for drift", "review skills for consistency"
- Says "find broken skills", "validate skill frontmatter"
- Is planning a bulk cleanup of the skill repo
- References a specific category to audit (e.g., "audit the generators/ skills")

**Does NOT activate** for: creating new skills (use `skill-creator`), applying fixes (follow-up flow after this auditor reports), or auditing Swift code inside skills (use `ios/coding-best-practices` or `macos/coding-best-practices`).

## Scope

Resolve the invocation argument in this order:

1. **No argument** → audit all of `skills/**/SKILL.md`
2. **Category path** (e.g., `generators/`, `ios/`) → audit `skills/<arg>/**/SKILL.md`
3. **Single file path** (e.g., `skills/liquid-glass/SKILL.md`) → audit one file
4. **Fuzzy match** → if arg doesn't resolve, try `skills/<arg>/SKILL.md`; fall back to asking the user

## Process

### 1. Enumerate

Use `Glob` with pattern `skills/**/SKILL.md` from the repo root. Filter by scope if an argument was passed. Record the canonical file list — every subsequent step operates on this list.

### 2. Parse Frontmatter (Cached)

Read the first 20 lines of each `SKILL.md`. Parse:
- Whether `---` frontmatter block exists
- `name:`, `description:`, `allowed-tools:` field values
- Freshness keys: `last_verified:`, `review_by:` (dates, required — enforced
  by `scripts/check-frontmatter.sh`), optional `os_version:`. Overdue
  `review_by` dates are the stale-skills workflow's job, not a finding here.

Cache this result. Checks C-01, H-01, H-03, L-02 all read from this cache — do not re-read.

### 3. Run Checks

Execute bulk `Grep` passes in parallel (single tool-call batch) wherever possible. Per-file operations come after. The 11 checks are in the table below; the order is as-listed.

### 4. Classify Aggregator vs Leaf

For each file, mark it as **aggregator** or **leaf** using the rules in the "Aggregator Detection" section below. Some checks relax for aggregators.

### 5. Rank and Emit

Group findings by severity (🔴 → 🟢), sort within each group by file path, print the report inline using the template in "Output Format".

## Checks

### 🔴 Critical

**C-01 · Missing frontmatter.** The file has no leading `---` YAML block.
- **Detection**: multiline `Grep` for `\A---\n[\s\S]*?\n---` across all SKILL.md. Files with no match → C-01.
- **Fix**: Add YAML frontmatter with `name`, `description`, `allowed-tools`.

### 🟠 High

**H-01 · Missing `allowed-tools` field.** Frontmatter exists but `allowed-tools:` key is absent.
- **Detection**: from cached frontmatter parse.
- **Fix**: Add `allowed-tools: [Read, Glob, Grep]` (adjust based on what the skill actually does).

**H-02 · Broken supporting-file reference.** The SKILL.md references a `*.md` file that does not exist on disk in the same directory.
- **Detection**: `Grep` each SKILL.md for `[a-z0-9][a-z0-9-]*\.md` matches; resolve each relative to the SKILL.md's directory; `ls` to confirm. Missing files → H-02. Ignore matches inside fenced code blocks. Also resolve `rules/swiftlint.yml` references the same way (fragment fixtures themselves are CI's job — `scripts/check-lint-fragments.sh`).
- **Fix**: Create the file or remove the reference.

**H-03 · H1 title does not match `name:`.** The first `#` heading after the frontmatter, slugified (lowercase, spaces → `-`), differs from the `name:` field.
- **Detection**: from cached frontmatter parse + per-file line-after-frontmatter.
- **Fix**: Rename the H1 or the `name:` to match.

### 🟡 Medium

**M-01 · Missing "When This Skill Activates" section.** No `## When This Skill Activates` heading anywhere in the file.
- **Detection**: `Grep -L` for `^## When This Skill Activates` across all SKILL.md.
- **Fix**: Add section with 3–5 user trigger phrases. See `shared/skill-creator/SKILL.md` for the canonical format.

**M-02 · Outdated version reference (drift).** Mentions iOS 17–25, macOS 13–25, or Swift 5.x with **drift context** (treated as current/latest/target).
- **Detection (two-stage)**:
  1. **Stage 1** — `Grep` for `\biOS (1[7-9]|2[0-5])\b|\bSwift 5\.\d+\b|\bmacOS (1[3-9]|2[0-5])\b`, capturing line numbers.
  2. **Stage 2** — for each hit, examine ±2 surrounding lines. Classify:
     - **Flag M-02** if surrounding lines contain: `latest`, `newest`, `current`, `target`, `deployment target`, `requires`, `minimum`, `as of`, `new in`, `now supports`, `today`
     - **Suppress** if surrounding lines contain: `legacy`, `pre-`, `prior to`, `before`, `deprecated`, `old`, `migrate from`, `backport`, `fallback`, `if available`, `#available`, or the version mention has a trailing `+` (e.g., `iOS 17+`)
     - **Neither** → L-03 (ambiguous)
- **Known-current constants** (dated 2026-07-11, update per WWDC): iOS 27, macOS 27 (announced WWDC26; iOS 26 / macOS 26 are within the one-generation grace), Swift 6.x. Normative source: `scripts/versions.env`. Mentions of these with drift context are always clean.
- **Fix**: Update the reference to the current generation (see `scripts/versions.env`), or annotate as legacy context with one of the suppression keywords.

**M-03 · Pre-`@Observable` pattern without deprecation callout.** Uses `@StateObject` or `ObservableObject` without acknowledging that `@Observable` is the current pattern.
- **Detection**: `Grep` for `@StateObject|ObservableObject` with line numbers; for each hit, secondary `Grep` of the same file for `@Observable|deprecated|legacy|pre-@Observable|migration|old pattern` within ±10 lines. No secondary match → M-03.
- **Fix**: Either replace with `@Observable` + `@State`, or add a migration note explaining why the older pattern is shown.

**M-04 · Oversized single-file skill.** `SKILL.md` exceeds 400 lines and its directory contains no sibling `.md` files.
- **Detection**: `wc -l` via Bash on each SKILL.md; if `>400`, check sibling file list via `ls` for any other `.md`. None → M-04.
- **Fix**: Modularize — extract sections into `patterns.md`, `templates.md`, `checklist.md`, or `examples.md` per `skill-creator` conventions.

### 🟢 Low

**L-01 · No ✅/❌ examples in prose.** The file has no `✅` or `❌` markers anywhere.
- **Detection**: `Grep -L` for `✅|❌`.
- **Fix**: Add at least one good/bad example pair.

**L-02 · Description length out of range.** `description:` is <20 or >300 characters.
- **Detection**: from cached frontmatter parse.
- **Fix**: Expand or shorten the description. Include a "use when…" clause to anchor activation.

**L-03 · Ambiguous version mention.** A version keyword matched stage 1 of the drift check but surrounding lines contained neither drift nor legacy context. User reviews manually.
- **Detection**: fallthrough from M-02 stage-2 classification.
- **Fix**: Add a drift or legacy keyword to disambiguate, or leave as-is if the context is clearly a one-off mention.

## Aggregator vs Leaf Detection

A SKILL.md is an **aggregator** if any of the following hold:
- It sits at depth 2 under the repo root — i.e., `skills/<category>/SKILL.md`
- It contains the heading `## Available Modules` or `## Available Skills`
- It links to `./<subdir>/SKILL.md` or contains two or more references of the form `skills/<category>/<subskill>/`

Otherwise it is a **leaf**.

### Relaxations for aggregators

| Check | Behaviour |
|---|---|
| M-01 (activation section) | Still enforced — aggregators must describe activation |
| M-03 (pre-@Observable) | Suppressed — aggregators are prose, not code |
| M-04 (>400 lines) | Suppressed — aggregators are allowed to be long when enumerating modules |
| L-01 (no ✅/❌ examples) | Suppressed — aggregators don't carry patterns |

Tag every finding in the report with `(aggregator)` or `(leaf)` so severity can be read at a glance.

## Output Format

Print the report inline to the conversation using this template. Use exact headings — downstream tooling may grep them.

```markdown
# Skill Audit Report — <YYYY-MM-DD> — <N> files scanned

## Summary
- 🔴 Critical: <count>
- 🟠 High: <count>
- 🟡 Medium: <count>
- 🟢 Low: <count>
- ✅ Files clean: <clean-count> / <N>

Scope: <all | category | single file>

## 🔴 Critical Findings
### C-01 · Missing frontmatter
- `skills/<path>/SKILL.md` (leaf) — **Fix:** Add YAML frontmatter with `name`, `description`, `allowed-tools`.

## 🟠 High Findings
### H-01 · Missing `allowed-tools` field
- `skills/liquid-glass/SKILL.md:1-4` (leaf) — **Fix:** Add `allowed-tools: [Read, Glob, Grep]`.
- `skills/macos/macos-tahoe-apis/SKILL.md:1-4` (leaf) — **Fix:** Same.

### H-02 · Broken supporting-file reference
- `skills/<path>/SKILL.md:<line>` — references `patterns.md`, not found. **Fix:** Create the file or remove the reference.

### H-03 · H1 title does not match `name:`
- `skills/<path>/SKILL.md` — `name: foo-bar`, H1 is `# Foo Bars`. **Fix:** Rename one to match.

## 🟡 Medium Findings
### M-01 · Missing "When This Skill Activates" section (<count>)
- `skills/design/liquid-glass/SKILL.md` (leaf)
- `skills/macos/coding-best-practices/SKILL.md` (leaf)
- [collapsed list of remaining offenders]
- **Fix:** Add section with 3–5 user trigger phrases.

### M-02 · Outdated version reference (<count>)
- `skills/<path>/SKILL.md:87` (leaf) — "latest iOS 17" in drift context. **Fix:** Update to iOS 26.

### M-03 · Pre-`@Observable` pattern without callout (<count>)
- `skills/<path>/SKILL.md:142` (leaf) — `@StateObject` without migration note. **Fix:** Replace with `@Observable` or add callout.

### M-04 · Oversized single-file skill (<count>)
- `skills/<path>/SKILL.md` — <NNN> lines, no sibling .md files. **Fix:** Modularize into `patterns.md` / `templates.md`.

## 🟢 Low Findings
### L-01 · No ✅/❌ examples
- `skills/<path>/SKILL.md` (leaf) — **Fix:** Add at least one good/bad example pair.

### L-02 · Description length out of range
- `skills/<path>/SKILL.md` — description is <N> chars. **Fix:** Expand/shorten to 20–300 chars.

### L-03 · Ambiguous version mention
- `skills/<path>/SKILL.md:<line>` — "iOS 18" with no drift/legacy context. **Fix:** Review manually.

## ✅ Clean Files
<collapsed list of files that passed all checks>

## Next Steps
- Review 🔴/🟠 findings first — they block skills from working as intended.
- Batch-fix 🟡 M-01 and M-02 mechanically — suggested find/replace scripts shown per-file.
- 🟢 findings are polish; address opportunistically.
```

## Implementation Notes

- **Parallelize bulk Greps** in a single tool-call batch where possible. Activation, frontmatter, `@StateObject`, and drift-stage-1 can all run at once.
- **Cache the frontmatter parse.** Four checks read it; only parse once.
- **Resolve `*.md` references inside fenced code blocks carefully** — they're examples, not references. Strip fenced blocks before running H-02's regex.
- **Progress pings** — for full-repo scans (148 files), emit a short "scanning <N>/<total>…" before each phase so the user sees liveness.
- **Idempotence** — the report body (everything below the `## Summary`) should be deterministic for a given repo state. Only the date in the H1 varies across runs.
- **Never write files.** This skill's `allowed-tools` lists Bash, but only for read-only ops (`wc`, `ls`). If you find yourself needing to write, stop and ask the user to invoke a fix flow separately.

## Non-Goals

- **No auto-fix.** The report includes one-line fix suggestions per finding; applying them is a separate user-initiated task.
- **No network calls.** This auditor does not verify URL liveness or check Apple doc availability.
- **No Swift compilation.** Code-block validity is beyond scope; patterns are matched textually.
- **No WWDC session cross-referencing.** A future `wwdc-to-skill-workflow` skill owns that.

## Relationship to CI

CI (`scripts/check-freshness.sh`) owns the deterministic subset of M-02: a recency keyword AND a stale version (major ≤ current−2) on the **same line** is a blocking build failure. This auditor's M-02 remains the broader net — ±2-line context, `current`/`target`/`requires` keywords, human-reviewed. Findings unique to M-02 are review candidates, not CI failures; anything CI already blocks will never appear here because it can't merge. C-01 is likewise fully delegated: `scripts/check-frontmatter.sh` blocks missing frontmatter at PR time.

## Maintenance

The drift heuristic hardcodes "known-current" version constants:

- iOS 27, macOS 27, Swift 6.x (dated 2026-07-11; announced WWDC26)

**Update these constants** when Apple ships a new major platform version (usually post-WWDC each June), together with `scripts/versions.env` — CI's `check-freshness.sh` cross-checks that this file mentions the manifest's current iOS generation and fails if they drift apart. The stage-1 regex ranges (`iOS 1[7-9]|2[0-5]`, `macOS 1[3-9]|2[0-5]`) must also be widened each cycle so their upper bound stays at CURRENT−2 (the previous generation sits inside a one-generation grace and is not stale; the ranges are unchanged for the iOS 27 cycle since 17–25 already ends at 27−2).

## Verification

After running the auditor on the full repo, counts should fall within this tolerance band (baseline re-taken 2026-07-16 after the blind-test audit deletions, 178 total `SKILL.md` files scanned — 155 leaf skills + 23 category indexes; the README's "159 skills" counts leaf dirs plus the 4 single-skill categories):

| Finding | Expected |
|---|---|
| C-01 missing frontmatter | **0** — the 2026-04 legacy batch was fixed, and `scripts/check-frontmatter.sh` now blocks regressions in CI |
| H-01 missing `allowed-tools` | **0** |
| H-02 broken supporting refs | 0 |
| H-03 H1 mismatch | flag outliers manually |
| M-01 missing activation section | **6** — ui-prototyping, iap-finalizer, originality-check, store-signals, flow-walkthrough, privacy-publish |
| M-02 version drift | stage-1 Grep returns ~369 raw hit lines across ~147 files (2026-07-11); the stage-2 narrowed band must be re-derived on the next full run — the pre-hardening band (~50±10) was measured against ~228 raw hits, and CI's `check-freshness.sh` has since removed the same-line recency subset |
| M-03 pre-`@Observable` no callout | ~29 (±5) — re-verify on the next full run |
| M-04 oversized single-file | TBD — flag outliers |

### Known legacy pattern: `## When to Use` (resolved)

The 2026-04 batch of files using `## When to Use` as their activation heading has been fully normalized — as of 2026-07-11 no SKILL.md uses it in place of the canonical heading. The rule stands for future contributions: do **not** widen the M-01 regex to accept `## When to Use` — the whole point is to normalize onto the canonical heading. (A `## When to Use …` heading deeper in a file as *content* — e.g. `swift/memory`'s "When to Use / When NOT to Use" section about the technique itself — is fine and not an M-01 signal.)

### Smoke tests

1. **Full-repo run** — invoke with no arg. Counts must fall within tolerance above.
2. **Scoped run** — invoke with `generators/`. Only `skills/generators/**` paths appear.
3. **Single-file run** — invoke with `skills/liquid-glass/SKILL.md`. Report has exactly one H-01 finding.
4. **Idempotence** — re-run immediately. Report body is byte-identical; only the date in the H1 may differ.
5. **Drift heuristic sanity** — spot-check 5 M-02 hits and 5 suppressed legacy mentions. If any legacy mention is mis-flagged, extend the suppression keyword list and re-run.

## References

- `../../../CLAUDE.md` (repo root, resolved relative to this SKILL.md — not the project cwd) — normative source for frontmatter schema, naming, emoji convention. If absent (skills-only copies), use https://github.com/rshankras/claude-code-apple-skills/blob/main/CLAUDE.md
- `skills/shared/skill-creator/SKILL.md` — companion meta-skill for creating new skills (this auditor only audits; it does not create)
- `skills/ios/SKILL.md` — canonical aggregator example
