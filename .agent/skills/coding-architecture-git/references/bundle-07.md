# Integrated Reference Bundle 07

Combines 11 related source skills from `coding-architecture-git` into one navigable reference file.

## Source map

- `generators/data-export/SKILL.reference.md`
- `generators/deep-linking/SKILL.reference.md`
- `generators/error-monitoring/SKILL.reference.md`
- `generators/feature-flags/SKILL.reference.md`
- `generators/featuring-nomination/SKILL.reference.md`
- `generators/feedback-form/SKILL.reference.md`
- `generators/force-update/SKILL.reference.md`
- `generators/http-cache/SKILL.reference.md`
- `generators/image-loading/SKILL.reference.md`
- `generators/in-app-events/SKILL.reference.md`
- `generators/lapsed-user/SKILL.reference.md`

## Integrated guidance

### Source: `generators/data-export`

# Data Export Generator

Generate production data export and import infrastructure -- JSON export via Codable, CSV generation with proper escaping, PDF report rendering with UIGraphicsPDFRenderer, GDPR-compliant full data export, file import with UTType-based picker, and share sheet integration. No third-party dependencies.

## When This Skill Activates

Use this skill when the user:
- Asks to "add data export" or "export user data"
- Wants "CSV export" or "JSON export" or "PDF export"
- Mentions "GDPR data portability" or "right to data portability"
- Asks about "exporting all user data" for compliance
- Wants to "import data" from files or competitor apps
- Mentions "share sheet" for exporting data
- Asks about "data backup" or "data download"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Identify data model layer (SwiftData, Core Data, custom structs)
- [ ] Identify source file locations

### 2. Existing Export Detection
Search for existing export code:
```
Glob: **/*Export*.swift, **/*Import*.swift, **/*CSV*.swift, **/*PDF*.swift
Grep: "UIGraphicsPDFRenderer" or "CSVExport" or "UIActivityViewController" or "ShareLink" or "fileExporter"
```

If existing export code found:
- Ask if user wants to replace or add additional formats
- Identify which formats are already supported

### 3. Data Model Detection
Search for data models that need exporting:
```
Grep: "@Model" or "NSManagedObject" or "struct.*Codable" or "class.*Codable"
```

Identify the models to build export conformances for.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Export formats needed?**
   - JSON (structured, machine-readable, best for GDPR)
   - CSV (tabular data, spreadsheet-compatible)
   - PDF (formatted reports with headers, tables, branding)
   - Multiple (select which combination)

2. **What data needs exporting?**
   - All user data -- GDPR compliance (every piece of stored user data)
   - Specific data types (user selects which models to export)
   - Reports/summaries (aggregated data, not raw records)

3. **Do you need import capability?**
   - No -- export only
   - Yes -- from files (JSON, CSV via file picker)
   - Yes -- from competitor apps (custom format parsing)

4. **How should users trigger export?**
   - Share sheet (system share UI with multiple destinations)
   - Settings screen (dedicated export section)
   - Export button (inline in content views)
   - Automatic backup (periodic export to iCloud/local)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `DataExportManager.swift` -- Central export coordinator with format routing
2. `DataExportable.swift` -- Protocol for models that support export

### Step 3: Create Format-Specific Files
Based on configuration:
3. `CSVExporter.swift` -- If CSV format selected
4. `PDFExporter.swift` -- If PDF format selected

### Step 4: Create Import Files
If import capability selected:
5. `DataImporter.swift` -- File picker and format parser

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/DataExport/`
- If `App/` exists -> `App/DataExport/`
- Otherwise -> `DataExport/`

## Output Format

After generation, provide:

### Files Created
```
DataExport/
├── DataExportable.swift   # Protocol for exportable models
├── DataExportManager.swift # Central export coordinator
├── CSVExporter.swift       # CSV generation (optional)
├── PDFExporter.swift       # PDF rendering (optional)
└── DataImporter.swift      # File import (optional)
```

### Integration with Data Models

**Make a model exportable:**
```swift
struct Expense: Codable, DataExportable {
    let id: UUID
    let title: String
    let amount: Double
    let date: Date
    let category: String

    // DataExportable conformance
    static var csvHeaders: [String] {
        ["ID", "Title", "Amount", "Date", "Category"]
    }

    var csvRow: [String] {
        [id.uuidString, title, String(format: "%.2f", amount),
         ISO8601DateFormatter().string(from: date), category]
    }

    var pdfDescription: String {
        "\(title) - $\(String(format: "%.2f", amount)) (\(category))"
    }
}
```

**Export from a view:**
```swift
struct ExpenseListView: View {
    let expenses: [Expense]
    @State private var exportURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        List(expenses) { expense in
            ExpenseRow(expense: expense)
        }
        .toolbar {
            Menu {
                Button("Export as JSON") {
                    Task { await exportAs(.json) }
                }
                Button("Export as CSV") {
                    Task { await exportAs(.csv) }
                }
                Button("Export as PDF") {
                    Task { await exportAs(.pdf) }
                }
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let exportURL {
                ShareSheet(activityItems: [exportURL])
            }
        }
    }

    private func exportAs(_ format: DataExportManager.ExportFormat) async {
        do {
            exportURL = try await DataExportManager.shared.export(
                expenses, format: format, filename: "expenses"
            )
            showShareSheet = true
        } catch {
            // Handle error
        }
    }
}
```

**SwiftUI ShareLink (iOS 16+):**
```swift
if let url = exportURL {
    ShareLink(item: url) {
        Label("Share Export", systemImage: "square.and.arrow.up")
    }
}
```

**Import from file picker:**
```swift
struct ImportView: View {
    @State private var showFilePicker = false
    @State private var importedItems: [Expense] = []

    var body: some View {
        Button("Import Data") { showFilePicker = true }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: DataImporter.supportedTypes
            ) { result in
                Task {
                    let url = try result.get()
                    importedItems = try await DataImporter.importFile(
                        from: url, as: Expense.self
                    )
                }
            }
    }
}
```

### GDPR Data Portability

For full GDPR compliance, export ALL user data:
```swift
func exportAllUserData() async throws -> URL {
    let allData = GDPRExportData(
        profile: try await fetchUserProfile(),
        expenses: try await fetchAllExpenses(),
        settings: try await fetchUserSettings(),
        exportDate: Date(),
        appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(allData)

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("user-data-export.json")
    try data.write(to: url)
    return url
}
```

### Testing

```swift
@Test
func jsonExportRoundTrip() async throws {
    let expenses = [
        Expense(id: UUID(), title: "Coffee", amount: 4.50,
                date: Date(), category: "Food")
    ]

    let url = try await DataExportManager.shared.export(
        expenses, format: .json, filename: "test"
    )
    let data = try Data(contentsOf: url)
    let decoded = try JSONDecoder().decode([Expense].self, from: data)

    #expect(decoded.count == 1)
    #expect(decoded.first?.title == "Coffee")
}

@Test
func csvExportFormatsCorrectly() {
    let expenses = [
        Expense(id: UUID(), title: "Coffee, Large", amount: 4.50,
                date: Date(), category: "Food")
    ]

    let csv = CSVExporter.generate(
        from: expenses,
        headers: Expense.csvHeaders,
        rowMapper: { $0.csvRow }
    )

    #expect(csv.contains("\"Coffee, Large\""))  // Commas escaped with quotes
    #expect(csv.hasPrefix("ID,Title,Amount,Date,Category"))
}

@Test
func importParsesCSV() async throws {
    let csvContent = "ID,Title,Amount\n1,Coffee,4.50\n2,Lunch,12.00"
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("test.csv")
    try csvContent.write(to: url, atomically: true, encoding: .utf8)

    let rows = try CSVExporter.parse(from: url)
    #expect(rows.count == 2)
    #expect(rows.first?["Title"] == "Coffee")
}
```

## Common Patterns

### Export to Temporary File for Sharing
Always export to a temporary directory, then present via share sheet:
```swift
let url = FileManager.default.temporaryDirectory
    .appendingPathComponent("export.\(format.fileExtension)")
try data.write(to: url)
// Present via UIActivityViewController or ShareLink
```

### GDPR Export Should Include Everything
For GDPR Article 20 compliance, export must include:
- All personal data the user provided
- All data generated about the user
- With clear field descriptions

### CSV Must Handle Special Characters
Wrap fields containing commas, quotes, or newlines in double quotes; escape internal quotes by doubling them.

## Gotchas

### Temporary Files Cleanup
Delete large export files after sharing completes rather than relying on the system's periodic cleanup.

### PDF Rendering on Background Thread
`UIGraphicsPDFRenderer` must be used on the main thread if it references UIKit views. For data-only PDF generation (text, lines, rectangles), it is safe to render on a background thread.

### Large Dataset Memory
For exporting thousands of records, stream the output instead of building the entire string/data in memory. Write CSV line-by-line to a file handle. For JSON, use JSONSerialization with streams.

### ShareLink vs UIActivityViewController
Use `ShareLink` for the simple case; use `UIActivityViewController` when you need excluded activities, completion handlers, or custom activities.

### File Import Security Scoped URLs
`.fileImporter` URLs are security-scoped: call `url.startAccessingSecurityScopedResource()` before reading, `url.stopAccessingSecurityScopedResource()` after.

## References

- **templates.md** -- All production Swift templates for data export/import
- [UIGraphicsPDFRenderer](https://developer.apple.com/documentation/uikit/uigraphicspdfrenderer)
- [UIActivityViewController](https://developer.apple.com/documentation/uikit/uiactivityviewcontroller)
- [UniformTypeIdentifiers](https://developer.apple.com/documentation/uniformtypeidentifiers)
- [GDPR Article 20 - Right to Data Portability](https://gdpr-info.eu/art-20-gdpr/)
- Related: `generators/settings-screen` -- Settings screen with export button
- Related: `generators/account-deletion` -- Account deletion includes data export option

### Source: `generators/deep-linking`

# Deep Linking Generator

Generate deep linking infrastructure with URL schemes, Universal Links, and App Intents for Siri/Shortcuts.

## When This Skill Activates

- User wants to handle custom URL schemes (myapp://)
- User mentions Universal Links or Associated Domains
- User wants Siri Shortcuts or App Intents
- User needs to navigate to specific content from external sources

## Pre-Generation Checks

Before generating, verify:

1. **Existing Deep Link Handling**
   ```bash
   # Check for existing URL handling
   grep -r "onOpenURL\|open.*url\|handleOpen" --include="*.swift" | head -5
   ```

2. **URL Scheme in Info.plist**
   ```bash
   # Check for CFBundleURLTypes
   find . -name "Info.plist" -exec grep -l "CFBundleURLSchemes" {} \;
   ```

3. **Associated Domains Entitlement**
   ```bash
   find . -name "*.entitlements" -exec grep -l "associated-domains" {} \;
   ```

## Configuration Questions

### 1. URL Scheme
- What custom URL scheme? (e.g., `myapp`)
- This enables `myapp://path/to/content` links

### 2. Universal Links
- **Yes** - Handle HTTPS links (requires AASA file on server)
- **No** - Custom URL scheme only

### 3. App Intents / Siri Shortcuts
- **Yes** - Enable voice commands and Shortcuts app
- **No** - URL-based deep linking only

### 4. Link Types
- Profile: `/users/{id}`
- Content: `/items/{id}`
- Actions: `/actions/share`, `/actions/create`
- Custom routes based on app needs

## Generated Files

### Core Infrastructure
```
Sources/DeepLinking/
├── DeepLinkRouter.swift       # Central router
├── DeepLink.swift             # Route definitions
└── UniversalLinkHandler.swift # Universal link processing
```

### App Intents (Optional)
```
Sources/AppIntents/
├── OpenContentIntent.swift    # Open specific content
├── AppShortcuts.swift         # Shortcuts provider
└── ContentEntity.swift        # Entities for Spotlight/Siri
```

### Server Files (Universal Links)
```
.well-known/
└── apple-app-site-association  # AASA file template
```

## Key Features

### Route Definitions

```swift
enum DeepLink: Equatable {
    case home
    case profile(userId: String)
    case item(itemId: String)
    case settings
    case action(ActionType)

    enum ActionType {
        case share(itemId: String)
        case create
    }
}
```

### URL Parsing

```swift
extension DeepLink {
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        let pathComponents = components.path.split(separator: "/").map(String.init)

        switch pathComponents {
        case ["users", let userId]:
            self = .profile(userId: userId)
        case ["items", let itemId]:
            self = .item(itemId: itemId)
        case ["settings"]:
            self = .settings
        default:
            self = .home
        }
    }
}
```

### SwiftUI Integration

```swift
@main
struct MyApp: App {
    @State private var router = DeepLinkRouter()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(router)
                .onOpenURL { url in
                    router.handle(url)
                }
        }
    }
}
```

## App Intents Integration

### OpenIntent for Navigation

```swift
struct OpenItemIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Item"

    @Parameter(title: "Item")
    var target: ItemEntity

    func perform() async throws -> some IntentResult {
        await router.navigate(to: .item(itemId: target.id))
        return .result()
    }
}
```

### App Shortcuts

```swift
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenItemIntent(),
            phrases: [
                "Open \(\.$target) in \(.applicationName)",
                "Show \(\.$target)"
            ],
            shortTitle: "Open Item",
            systemImageName: "doc"
        )
    }
}
```

## Required Capabilities

### URL Scheme (Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.myapp</string>
    </dict>
</array>
```

### Universal Links (Entitlements)
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:yourapp.com</string>
    <string>applinks:www.yourapp.com</string>
</array>
```

### Server Configuration (AASA)

Host at `https://yourapp.com/.well-known/apple-app-site-association`:

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.yourcompany.yourapp",
        "paths": [
          "/items/*",
          "/users/*",
          "/share/*"
        ]
      }
    ]
  }
}
```

## Integration Steps

### 1. Basic URL Handling

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
}
```

### 2. Universal Links (UIKit)

```swift
// In SceneDelegate
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
        return
    }
    handleUniversalLink(url)
}
```

### 3. App Intents Setup

1. Create entities for Spotlight indexing
2. Implement OpenIntent for each content type
3. Define AppShortcuts for Siri phrases
4. Index entities with CSSearchableIndex

## Testing

### URL Schemes
```bash
# Simulator
xcrun simctl openurl booted "myapp://items/123"

# Device
# Open Safari and navigate to myapp://items/123
```

### Universal Links
```bash
# Test AASA file
curl -I "https://yourapp.com/.well-known/apple-app-site-association"
# Should return Content-Type: application/json

# Validate with Apple
# Use Apple's tool or Branch.io validator
```

### App Intents
1. Build and run on device
2. Open Shortcuts app
3. Your app's shortcuts should appear
4. Test with Siri: "Hey Siri, [your phrase]"

## References

- [Supporting Universal Links](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)
- [App Intents Framework](https://developer.apple.com/documentation/appintents)
- [Defining Custom URL Schemes](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)
- [Making App Entities Available in Spotlight](https://developer.apple.com/documentation/appintents/making-app-entities-available-in-spotlight)

### Source: `generators/error-monitoring`

# Error Monitoring Generator

Generates a production-ready error monitoring infrastructure with protocol-based architecture for easy provider swapping.

## When This Skill Activates

- User asks to "add crash reporting" or "error monitoring"
- User mentions "Sentry", "Crashlytics", or "crash analytics"
- User wants to "track errors in production"
- User asks about "debugging production issues"

## Pre-Generation Checks (CRITICAL)

### 1. Project Context Detection

Before generating, ALWAYS check:

```bash
# Check for existing crash reporting
rg -l "Sentry|Crashlytics|CrashReporter" --type swift

# Check Package.swift for existing SDKs
cat Package.swift | grep -i "sentry\|firebase\|crashlytics"

# Check for existing error handling patterns
rg "captureError|recordError|logError" --type swift | head -5
```

### 2. Conflict Detection

If existing crash reporting found:
- Ask: Replace, wrap existing, or create parallel system?

## Configuration Questions

Ask user via AskUserQuestion:

1. **Initial provider?**
   - Sentry (recommended for indie devs)
   - Firebase Crashlytics (if already using Firebase)
   - None (set up infrastructure only)

2. **Include breadcrumbs?**
   - Yes (track navigation, user actions)
   - No (errors only)

3. **Include user context?**
   - Yes (anonymized user ID, app state)
   - No (minimal data collection)

## Generation Process

### Step 1: Create Core Files

**Always generate:**
```
Sources/ErrorMonitoring/
├── ErrorMonitoringService.swift     # Protocol
├── ErrorContext.swift               # Breadcrumbs, user info
└── NoOpErrorMonitoring.swift        # Testing/privacy
```

**Based on provider selection:**
```
Sources/ErrorMonitoring/Providers/
├── SentryErrorMonitoring.swift      # If Sentry selected
└── CrashlyticsErrorMonitoring.swift # If Crashlytics selected
```

### Step 2: Read Templates

Read templates from this skill:
- `templates/ErrorMonitoringService.swift`
- `templates/ErrorContext.swift`
- `templates/NoOpErrorMonitoring.swift`
- `templates/SentryErrorMonitoring.swift` (if selected)
- `templates/CrashlyticsErrorMonitoring.swift` (if selected)

### Step 3: Customize for Project

Adapt templates to match:
- Project naming conventions
- Existing error types
- Bundle identifier for Sentry DSN

### Step 4: Integration

**In App.swift:**
```swift
import SwiftUI

@main
struct MyApp: App {
    init() {
        // Configure error monitoring
        ErrorMonitoring.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.errorMonitoring, ErrorMonitoring.shared.service)
        }
    }
}
```

**Capturing errors:**
```swift
do {
    try await riskyOperation()
} catch {
    ErrorMonitoring.shared.service.captureError(error)
}
```

**Adding breadcrumbs:**
```swift
ErrorMonitoring.shared.service.addBreadcrumb(
    Breadcrumb(category: "navigation", message: "Opened settings")
)
```

## Provider Setup

### Sentry

1. **Create account** at [sentry.io](https://sentry.io)
2. **Create project** for iOS/macOS
3. **Get DSN** from Project Settings > Client Keys
4. **Add to Package.swift:**
```swift
.package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.0.0")
```

### Firebase Crashlytics

1. **Add Firebase** to your project via [console.firebase.google.com](https://console.firebase.google.com)
2. **Download** GoogleService-Info.plist
3. **Add Firebase SDK** via SPM or CocoaPods
4. **Enable Crashlytics** in Firebase console

## Generated Code Patterns

### Protocol (Stable Interface)
```swift
protocol ErrorMonitoringService: Sendable {
    func configure()
    func captureError(_ error: Error, context: ErrorContext?)
    func captureMessage(_ message: String, level: ErrorLevel)
    func addBreadcrumb(_ breadcrumb: Breadcrumb)
    func setUser(_ user: MonitoringUser?)
    func reset()
}
```

### Swapping Providers
```swift
// In ErrorMonitoring.swift
final class ErrorMonitoring {
    static let shared = ErrorMonitoring()

    // Change this ONE line to swap providers:
    let service: ErrorMonitoringService = SentryErrorMonitoring()
    // let service: ErrorMonitoringService = CrashlyticsErrorMonitoring()
    // let service: ErrorMonitoringService = NoOpErrorMonitoring()
}
```

### Breadcrumb Tracking
```swift
// Automatic navigation breadcrumbs
struct ContentView: View {
    @Environment(\.errorMonitoring) var errorMonitoring

    var body: some View {
        Button("Open Details") {
            errorMonitoring.addBreadcrumb(
                Breadcrumb(category: "ui", message: "Tapped details button")
            )
            showDetails = true
        }
    }
}
```

## Verification Checklist

After generation, verify:

- [ ] App compiles without errors
- [ ] Provider SDK added (if applicable)
- [ ] DSN/config set correctly
- [ ] Test error appears in dashboard
- [ ] Breadcrumbs captured correctly
- [ ] User context (if enabled) shows in reports
- [ ] NoOp mode works for debug/testing

## Privacy Considerations

### GDPR Compliance
- Use `NoOpErrorMonitoring` for EU users who opt out
- Don't capture PII in error messages
- Anonymize user IDs

### App Store Guidelines
- Disclose crash reporting in privacy policy
- Use App Tracking Transparency if combining with analytics
- Don't capture unnecessary device identifiers

### Privacy Manifest (iOS 17+)
Add to PrivacyInfo.xcprivacy if using Sentry/Crashlytics:
```xml
<key>NSPrivacyCollectedDataTypes</key>
<array>
    <dict>
        <key>NSPrivacyCollectedDataType</key>
        <string>NSPrivacyCollectedDataTypeCrashData</string>
        <key>NSPrivacyCollectedDataTypeLinked</key>
        <false/>
        <key>NSPrivacyCollectedDataTypeTracking</key>
        <false/>
        <key>NSPrivacyCollectedDataTypePurposes</key>
        <array>
            <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
        </array>
    </dict>
</array>
```

## Common Customizations

### Custom Error Types
```swift
enum AppError: Error {
    case networkFailure(URLError)
    case decodingFailure(DecodingError)
    case authenticationRequired

    var context: ErrorContext {
        ErrorContext(
            tags: ["error_type": String(describing: self)],
            extra: ["recoverable": isRecoverable]
        )
    }
}

// Capture with context
errorMonitoring.captureError(error, context: error.context)
```

### Performance Monitoring
```swift
// Sentry supports performance monitoring
let transaction = SentrySDK.startTransaction(name: "Load Data", operation: "http")
defer { transaction.finish() }

let data = try await fetchData()
```

### Release Tracking
```swift
// Include version info
SentrySDK.start { options in
    options.dsn = "YOUR_DSN"
    options.releaseName = "\(Bundle.main.appVersion)-\(Bundle.main.buildNumber)"
}
```

## Troubleshooting

### Errors Not Appearing in Dashboard

1. **Check DSN** is correct and not expired
2. **Verify** network connectivity
3. **Check** debug mode isn't suppressing uploads
4. **Look** for SDK initialization errors in console

### Symbolication Not Working

1. **Upload dSYMs** to Sentry/Firebase
2. **Enable** "Upload Debug Symbols" build phase
3. **Check** build settings include debug info

### High Volume / Costs

1. **Filter** common/expected errors
2. **Sample** errors (e.g., capture 10%)
3. **Group** similar errors

## Related Skills

- `analytics-setup` - Often combined with error monitoring
- `logging-setup` - Use Logger for debug, error monitoring for production

## References

- [Sentry iOS Documentation](https://docs.sentry.io/platforms/apple/)
- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Apple Privacy Manifest](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files)

### Source: `generators/feature-flags`

# Feature Flags Generator

Generate a complete feature flag infrastructure with typed flag definitions, protocol-based providers (local, remote, composite), SwiftUI environment integration, an `@Observable` manager, and a debug menu for toggling flags at runtime.

## When This Skill Activates

Use this skill when the user:
- Asks to "add feature flags" or "add feature toggles"
- Mentions A/B testing or gradual rollouts
- Asks about Firebase Remote Config or similar remote configuration
- Wants to disable features without shipping an app update
- Mentions "kill switches" or "feature gates"
- Wants to control features remotely for a subset of users
- Asks for a debug menu to toggle features during development

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check for existing feature flag implementations
- [ ] Check for Firebase Remote Config or third-party flag SDKs
- [ ] Identify source file locations (Sources/, App/, or root)
- [ ] Verify minimum deployment target (iOS 17+ / macOS 14+ for @Observable)

### 2. Conflict Detection

Search for existing feature flag code:
```
Glob: **/*FeatureFlag*.swift, **/*FeatureToggle*.swift, **/*RemoteConfig*.swift
Grep: "FeatureFlag" or "FeatureToggle" or "RemoteConfig" or "isFeatureEnabled"
```

If existing feature flag code is found:
- Ask whether to replace or extend the existing implementation
- Check for flag names or enum cases that could conflict

If a third-party SDK (Firebase, LaunchDarkly, etc.) is detected:
- Ask if the user wants a standalone implementation or a wrapper around the SDK

### 3. Required Capabilities

**Feature flags require:**
- iOS 17+ / macOS 14+ deployment target (for @Observable manager)
- Network access entitlement if using remote flags
- No special Info.plist entries needed

## Configuration Questions

Ask user via AskUserQuestion:

1. **What features do you want to flag?** (freeform)
   - Examples: new onboarding, premium paywall, experimental UI, dark mode v2
   - This determines the flag enum cases and their default values

2. **What flag value types do you need?**
   - Boolean only (feature on/off)
   - Boolean + String (on/off plus string configuration)
   - Boolean + String + Integer (full typed support)
   - Boolean + String + Integer + JSON (for complex configurations)

3. **What provider architecture?**
   - **Local only** -- UserDefaults-based with compile-time defaults
   - **Remote only** -- JSON endpoint with local caching
   - **Composite (recommended)** -- Local defaults with remote override; remote wins when available

4. **Include debug menu?**
   - Yes -- SwiftUI view for toggling flags at runtime (DEBUG builds only)
   - No -- Skip the debug view

5. **Include SwiftUI environment integration?**
   - Yes (recommended) -- Inject the flag manager via SwiftUI Environment
   - No -- Use the manager directly

## Generation Process

### Step 1: Determine File Locations

Check project structure:
- If `Sources/` exists --> `Sources/FeatureFlags/`
- If `App/` exists --> `App/FeatureFlags/`
- Otherwise --> `FeatureFlags/`

### Step 2: Create Core Files

Generate these files based on configuration answers:

1. **`FeatureFlag.swift`** -- Flag enum with typed default values
2. **`FeatureFlagService.swift`** -- Protocol defining provider interface
3. **`LocalFeatureFlagProvider.swift`** -- UserDefaults-based provider with debug overrides
4. **`RemoteFeatureFlagProvider.swift`** -- URL-based provider with disk caching (if remote or composite)
5. **`CompositeFeatureFlagProvider.swift`** -- Combines local + remote; remote overrides local (if composite)
6. **`FeatureFlagManager.swift`** -- @Observable manager for SwiftUI
7. **`FeatureFlagEnvironmentKey.swift`** -- SwiftUI Environment integration (if requested)
8. **`FeatureFlagDebugView.swift`** -- Debug toggle view (if requested)

### Step 3: Generate Code from Templates

Use the templates in **templates.md** and customize based on user answers:
- Replace placeholder flag cases with real feature names
- Set appropriate default values per flag
- Include or exclude remote/composite providers based on architecture choice
- Include or exclude typed value methods (string, int, JSON) based on type selection
- Include or exclude environment key and debug view

## Output Format

After generation, provide:

### Files Created

```
Sources/FeatureFlags/
├── FeatureFlag.swift                    # Flag enum with typed defaults
├── FeatureFlagService.swift             # Provider protocol
├── LocalFeatureFlagProvider.swift       # UserDefaults-based provider
├── RemoteFeatureFlagProvider.swift      # URL-based provider (if remote/composite)
├── CompositeFeatureFlagProvider.swift   # Local + remote combiner (if composite)
├── FeatureFlagManager.swift             # @Observable manager for SwiftUI
├── FeatureFlagEnvironmentKey.swift      # SwiftUI Environment key (if requested)
└── FeatureFlagDebugView.swift           # Debug toggle menu (if requested)
```

### Integration Steps

**1. Initialize the manager in your App struct or entry point:**

```swift
import SwiftUI

@main
struct MyApp: App {
    @State private var featureFlagManager: FeatureFlagManager

    init() {
        // Local only
        let provider = LocalFeatureFlagProvider()

        // Or composite (remote overrides local)
        // let provider = CompositeFeatureFlagProvider(
        //     local: LocalFeatureFlagProvider(),
        //     remote: RemoteFeatureFlagProvider(
        //         endpoint: URL(string: "https://api.example.com/flags")!
        //     )
        // )

        _featureFlagManager = State(initialValue: FeatureFlagManager(provider: provider))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(featureFlagManager)
        }
    }
}
```

**2. Use flags in your views:**

```swift
struct ContentView: View {
    @Environment(FeatureFlagManager.self) private var flags

    var body: some View {
        VStack {
            if flags.isEnabled(.newOnboarding) {
                NewOnboardingView()
            } else {
                LegacyOnboardingView()
            }
        }
    }
}
```

**3. Refresh remote flags (if using remote or composite):**

```swift
// Refresh on app launch or periodically
Task {
    try await featureFlagManager.refresh()
}
```

**4. Add debug menu (if generated, DEBUG builds only):**

```swift
#if DEBUG
NavigationLink("Feature Flags") {
    FeatureFlagDebugView()
        .environment(featureFlagManager)
}
#endif
```

### Testing Instructions

1. **Unit test providers independently:** Each provider conforms to `FeatureFlagService` and can be tested in isolation.
2. **Mock provider for previews and tests:**
   ```swift
   final class MockFeatureFlagProvider: FeatureFlagService {
       var overrides: [FeatureFlag: Bool] = [:]

       func isEnabled(_ flag: FeatureFlag) -> Bool {
           overrides[flag] ?? flag.defaultValue
       }
       // ... implement remaining protocol methods
   }
   ```
3. **Debug menu:** Run in DEBUG builds, navigate to the debug menu, and toggle flags to verify behavior.
4. **Remote provider:** Use a local JSON file served via a test server or mock URLProtocol to test remote fetching.

## Common Patterns

### Boolean Flags (Kill Switches)
The most common pattern. Enable or disable a feature entirely.

```swift
if flags.isEnabled(.premiumPaywall) {
    PremiumPaywallView()
}
```

### String Flags (Copy Variants / A/B Testing)
Use string values to serve different text or configuration strings remotely.

```swift
let welcomeMessage = flags.stringValue(.welcomeMessage) ?? "Welcome!"
Text(welcomeMessage)
```

### Integer Flags (Thresholds / Limits)
Control numeric parameters like retry counts, page sizes, or rate limits.

```swift
let maxRetries = flags.intValue(.maxRetries) ?? 3
```

### JSON Flags (Complex Configuration)
For structured configuration that changes server-side.

```swift
struct PaywallConfig: Codable {
    let title: String
    let trialDays: Int
    let showTestimonials: Bool
}

if let config: PaywallConfig = flags.jsonValue(.paywallConfig) {
    PaywallView(config: config)
}
```

### Gradual Rollout
Combine feature flags with user segmentation.

```swift
// Server returns different flag values per user segment
// The flag is simply on/off from the client perspective
if flags.isEnabled(.newCheckoutFlow) {
    NewCheckoutView()
} else {
    LegacyCheckoutView()
}
```

## Gotchas

- **Stale flags:** Always provide sensible local defaults. If the remote fetch fails, the app must still function correctly with local values.
- **Flag cleanup:** After a feature is fully rolled out, remove the flag enum case, delete related conditional code, and clean up remote configuration. Stale flags accumulate technical debt.
- **Thread safety:** The generated `FeatureFlagManager` is `@MainActor`-isolated. Access it on the main thread or via `@Environment` in SwiftUI views. The providers use `Sendable`-conforming storage.
- **Testing both paths:** When a flag controls a UI branch, write tests (or at least manual test plans) for both the enabled and disabled paths. It is easy to forget the disabled path once a flag has been on for weeks.
- **Debug overrides in production:** The debug override mechanism uses `#if DEBUG` guards. Double-check that debug toggles never leak into release builds.
- **Cache invalidation:** The remote provider caches to disk. Set an appropriate `cacheDuration` (default 5 minutes). For time-sensitive flags, call `refresh()` explicitly.
- **UserDefaults key collisions:** All flag keys are prefixed with `ff_` to avoid collisions with other UserDefaults entries in the app.

## References

- **templates.md** -- Production-ready Swift templates for all generated files
- [Feature Toggles (Martin Fowler)](https://martinfowler.com/articles/feature-toggles.html)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config)

### Source: `generators/featuring-nomination`

# Featuring Nomination Generator

Generate a compelling App Store featuring nomination ready for submission, including all required fields, narrative pitch, and strategic timing.

## When This Skill Activates

Use this skill when the user:
- Asks to "get featured" or "submit for App Store featuring"
- Mentions "featuring nomination" or "editorial feature"
- Wants help with "App Store editorial" pitch
- Is preparing a major launch or update and wants visibility
- Asks about "Today tab" or "Apps We Love"

## How App Store Featuring Works

Apple's editorial team hand-picks apps for featuring based on:
- **Quality**: Design, performance, and polish
- **Innovation**: Novel use of Apple technologies
- **Relevance**: Timely content or seasonal alignment
- **Story**: Compelling developer or user narrative

### Featuring Placements
| Placement | Visibility | Requirements |
|-----------|-----------|-------------|
| Today tab story | Highest | Exceptional quality + narrative |
| App of the Day | Very high | Outstanding app + timing |
| Collection feature | High | Fits a themed collection |
| Category feature | Medium | Top quality in category |
| Search result boost | Medium | Relevance + quality |

### Submission Timeline
- Submit **6-8 weeks** before desired featuring date
- Apple reviews and plans editorial calendar in advance
- Seasonal features are planned months ahead
- No guarantee of featuring — but quality nominations increase odds significantly

## Configuration Questions

Ask user via AskUserQuestion:

1. **Reason for nomination?**
   - New app launch
   - Major update with new features
   - Seasonal relevance (holiday, back-to-school, etc.)
   - Apple technology showcase (new API adoption)
   - Milestone (anniversary, user count, award)

2. **Apple technologies used?** (multi-select)
   - SwiftUI
   - WidgetKit / Live Activities
   - App Intents / Shortcuts
   - Apple Intelligence / Foundation Models
   - ARKit / RealityKit
   - HealthKit / ActivityKit
   - SharePlay
   - StoreKit 2
   - Apple Watch complications
   - visionOS support
   - Other (specify)

3. **Target featuring date?**
   - Within 2 weeks (too late for editorial, but can try)
   - 4-6 weeks from now (ideal timing)
   - 8+ weeks from now (best chance for planning)
   - Seasonal window (specify season)

## Generation Process

### Step 1: Gather App Details

Collect comprehensive information:
- App name, description, and category
- What's new in this version (if update)
- Apple technologies used with specific details
- Developer story (indie, team, background)
- User impact stories or metrics
- Visual design highlights
- Accessibility features
- Privacy stance

### Step 2: Identify Featuring Angles

Read `nomination-template.md` for the angle selection framework.

Strong angles by category:
- **Accessibility**: Apps that serve underserved communities
- **Health**: Mental health, physical wellness, therapy tools
- **Education**: Learning innovation, kids' safety
- **Sustainability**: Environmental impact, eco-friendly
- **Creativity**: Novel creative tools or expression
- **Apple Tech**: Deep integration with latest Apple APIs
- **Cultural**: Apps celebrating cultural moments or diversity

### Step 3: Generate Nomination

Produce the complete nomination document.

## Output Format

Read `nomination-template.md` and fill all fields.

```markdown
# App Store Featuring Nomination

## App Information
| Field | Value |
|-------|-------|
| App Name | [Name] |
| Developer | [Developer/Company Name] |
| App Store URL | [URL] |
| Category | [Primary Category] |
| Platforms | [iOS / macOS / watchOS / visionOS] |
| App Store Connect Contact | [Email] |

## Nomination Reason
[One of: New Launch / Major Update / Seasonal / Technology / Milestone]

## Desired Featuring Window
[Date range, aligned with launch or seasonal opportunity]

## App Overview (2-3 sentences)
[Compelling summary of what the app does and why it matters]

## What Makes This App Special (3-5 bullet points)
- [Unique value proposition]
- [Design or UX innovation]
- [Technical excellence]
- [User impact]
- [Cultural or social significance]

## Apple Technology Integration
| Technology | How It's Used |
|-----------|--------------|
| [SwiftUI] | [Specific usage details] |
| [WidgetKit] | [Specific usage details] |
| [etc.] | [etc.] |

## Developer Story (2-3 sentences)
[Personal or team narrative that makes the app relatable]

## User Impact
[Metrics, testimonials, or stories showing real-world impact]

## Design Highlights
[What makes the visual design noteworthy — animations, interactions, aesthetics]

## Accessibility Features
[VoiceOver support, Dynamic Type, color accessibility, etc.]

## Privacy Commitment
[How the app respects user privacy — on-device processing, minimal data collection, etc.]

## Media Kit
[Links to: screenshots, app preview video, press kit, developer photos]

## Social Proof (optional)
[Press mentions, awards, notable reviews, download milestones]
```

## References

- **nomination-template.md** — Detailed nomination form and angle framework
- Related: `app-store/marketing-strategy` — Featuring as part of broader strategy
- Related: `app-store/app-description-writer` — Compelling app copy
- Related: `generators/in-app-events` — Pair featuring with events
- Apple: [Nominate your app for featuring](https://developer.apple.com/app-store/discoverability/)

### Source: `generators/feedback-form`

# Feedback Form Generator

Generate a production in-app feedback form with category selection, sentiment-based rating, optional screenshot attachment, device diagnostics collection, and smart routing that funnels satisfied users to the App Store review prompt and dissatisfied users to a support channel.

## When This Skill Activates

Use this skill when the user:
- Asks to "add a feedback form" or "feedback form"
- Wants "in-app feedback" or "user feedback" collection
- Mentions "bug report form" or "feature request" form
- Asks about "contact support" from within the app
- Wants "feedback collection" with categories or screenshots
- Asks to "route users to App Store review" based on sentiment

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing feedback or support code:
```
Glob: **/*Feedback*.swift, **/*Support*.swift, **/*BugReport*.swift, **/*ContactForm*.swift
Grep: "MFMailComposeViewController" or "FeedbackForm" or "SKStoreReviewController"
```

If third-party feedback SDK found (Instabug, UserVoice, Zendesk):
- Ask if user wants to replace or keep it
- If keeping, don't generate — advise on best practices instead

### 3. Framework Detection
Check for MessageUI availability:
```
Grep: "import MessageUI" or "MFMailCompose"
```
Note: MessageUI is iOS-only. macOS uses `NSSharingService` or direct webhook delivery.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Feedback categories?** (multi-select)
   - Bug Report
   - Feature Request
   - General Feedback
   - Praise
   - Other
   - All of the above — recommended

2. **Delivery method?**
   - Email (via MFMailComposeViewController / NSSharingService)
   - Webhook (POST to a URL endpoint)
   - Both — recommended

3. **Include screenshot capture?**
   - Yes — recommended (capture current screen + annotation overlay)
   - No

4. **Include device diagnostics?**
   - Yes — recommended (device model, OS, app version, disk, memory)
   - No

5. **Sentiment routing?**
   - Yes — recommended (rating >= 4 suggests App Store review, rating <= 2 routes to support)
   - No (all feedback goes through the same channel)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `FeedbackCategory.swift` — Enum with SF Symbol icons and display names
2. `FeedbackEntry.swift` — Data model for a feedback submission
3. `DeviceDiagnostics.swift` — Collects device and app info

### Step 3: Create UI Files
4. `FeedbackFormView.swift` — SwiftUI form with sentiment, category, message, screenshots

### Step 4: Create Delivery Files
5. `FeedbackSubmitter.swift` — Protocol + EmailFeedbackSubmitter + WebhookFeedbackSubmitter

### Step 5: Create Optional Files
Based on configuration:
- `ScreenshotCapture.swift` — If screenshot capture selected

### Step 6: Determine File Location
Check project structure:
- If `Sources/` exists -> `Sources/Feedback/`
- If `App/` exists -> `App/Feedback/`
- Otherwise -> `Feedback/`

## Output Format

After generation, provide:

### Files Created
```
Feedback/
├── FeedbackCategory.swift       # Category enum with icons
├── FeedbackEntry.swift          # Feedback data model
├── DeviceDiagnostics.swift      # Device info collector
├── FeedbackFormView.swift       # SwiftUI form view
├── FeedbackSubmitter.swift      # Email + webhook delivery
└── ScreenshotCapture.swift      # Screen capture (optional)
```

### Integration Steps

**Present the feedback form from any view:**
```swift
@State private var showFeedback = false

Button("Send Feedback") {
    showFeedback = true
}
.sheet(isPresented: $showFeedback) {
    FeedbackFormView()
}
```

**In a settings screen:**
```swift
Form {
    Section("Support") {
        Button {
            showFeedback = true
        } label: {
            Label("Send Feedback", systemImage: "bubble.left.and.text.bubble.right")
        }
    }
}
.sheet(isPresented: $showFeedback) {
    FeedbackFormView()
}
```

**With a pre-selected category (e.g., from a help menu):**
```swift
FeedbackFormView(initialCategory: .bugReport)
```

### Testing

```swift
@Test
func feedbackEntryEncodesCorrectly() throws {
    let entry = FeedbackEntry(
        category: .bugReport,
        message: "App crashes when tapping save",
        rating: 2,
        screenshots: [],
        deviceInfo: DeviceDiagnostics.collect(),
        appVersion: "1.2.3",
        timestamp: Date()
    )

    let data = try JSONEncoder().encode(entry)
    let decoded = try JSONDecoder().decode(FeedbackEntry.self, from: data)
    #expect(decoded.category == .bugReport)
    #expect(decoded.rating == 2)
}

@Test
func webhookSubmitterSendsCorrectPayload() async throws {
    let mockSession = MockURLSession()
    let submitter = WebhookFeedbackSubmitter(
        url: URL(string: "https://example.com/feedback")!,
        session: mockSession
    )

    let entry = FeedbackEntry(
        category: .featureRequest,
        message: "Dark mode support please",
        rating: 4,
        screenshots: [],
        deviceInfo: DeviceDiagnostics.collect(),
        appVersion: "1.0.0",
        timestamp: Date()
    )

    try await submitter.submit(entry)
    #expect(mockSession.lastRequest?.httpMethod == "POST")
    #expect(mockSession.lastRequest?.value(forHTTPHeaderField: "Content-Type") == "application/json")
}

@Test
func sentimentRoutingDirectsHighRatingToReview() {
    let entry = FeedbackEntry(
        category: .praise,
        message: "Love this app!",
        rating: 5,
        screenshots: [],
        deviceInfo: DeviceDiagnostics.collect(),
        appVersion: "1.0.0",
        timestamp: Date()
    )

    #expect(entry.suggestsAppStoreReview) // rating >= 4
}
```

## Common Patterns

### Open feedback form from a menu bar app
```swift
Button {
    showFeedback = true
    NSApp.activate(ignoringOtherApps: true)
} label: {
    Label("Send Feedback", systemImage: "envelope")
}
.sheet(isPresented: $showFeedback) {
    FeedbackFormView()
}
```

### Submit feedback with a screenshot attachment
```swift
let screenshot = try await ScreenshotCapture.captureCurrentWindow()
let entry = FeedbackEntry(
    category: .bugReport,
    message: "Layout is broken on this screen",
    rating: 1,
    screenshots: [screenshot],
    deviceInfo: DeviceDiagnostics.collect(),
    appVersion: Bundle.main.appVersion,
    timestamp: Date()
)
try await submitter.submit(entry)
```

### Route by sentiment after submission
```swift
if entry.suggestsAppStoreReview {
    // Happy user — ask for App Store review
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        SKStoreReviewController.requestReview(in: scene)
    }
} else if entry.suggestsSupportFollowUp {
    // Unhappy user — show support confirmation
    showSupportConfirmation = true
}
```

## Gotchas

- **MFMailComposeViewController requires a mail account**: Check `MFMailComposeViewController.canSendMail()` before presenting. Fall back to webhook or `mailto:` URL if unavailable.
- **Screenshot privacy**: Consider blurring or redacting sensitive data (passwords, financial info) before attaching. Use `UITextField.isSecureTextEntry` areas as a guide.
- **Attachment size limits for email**: Email attachments are typically limited to 10-25 MB. Compress screenshots to JPEG and resize if needed. Webhook delivery is more reliable for large attachments.
- **Offline submission queuing**: If the device is offline when feedback is submitted, queue the entry to disk and retry when connectivity is restored. Use `NWPathMonitor` to detect network changes.
- **App Store review prompt limits**: `SKStoreReviewController.requestReview()` is rate-limited by the system (typically 3 times per 365-day period). Don't rely on it always appearing.
- **macOS has no MFMailComposeViewController**: Use `NSSharingService(named: .composeEmail)` or prefer webhook delivery on macOS.

## References

- **templates.md** — All production Swift templates
- Related: `generators/review-prompt` — App Store review prompt timing and strategy

### Source: `generators/force-update`

# Force Update Generator

Generate a minimum version check system that blocks app usage when a critical update is required, or shows a dismissible prompt for recommended updates. Checks the current app version against a remote configuration endpoint or the App Store lookup API and presents the appropriate UI.

## When This Skill Activates

Use this skill when the user:
- Asks to "add force update" or "force update screen"
- Wants "minimum version check" or "minimum version enforcement"
- Mentions "required update" or "mandatory update"
- Asks about "version check" or "app version check"
- Wants an "app update prompt" or "update dialog"
- Mentions "block old versions" or "deprecate old versions"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing version check code:
```
Glob: **/*ForceUpdate*.swift, **/*VersionCheck*.swift, **/*UpdateManager*.swift, **/*AppVersion*.swift
Grep: "ForceUpdate" or "minimumVersion" or "mandatoryUpdate" or "CFBundleShortVersionString"
```

If an existing update mechanism is found:
- Ask if user wants to replace or extend it
- If extending, integrate with the existing check flow

### 3. Network Layer Detection
Search for existing networking code:
```
Glob: **/*API*.swift, **/*Client*.swift, **/*Network*.swift
Grep: "APIClient" or "URLSession" or "NetworkService"
```

If a networking layer exists, generate the version checker to use it rather than raw URLSession.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Update check source?**
   - Remote JSON endpoint (your own server hosts a JSON config) — recommended
   - App Store lookup API (uses iTunes Search API, no server needed)
   - Firebase Remote Config (requires Firebase SDK)

2. **Update types to support?**
   - Hard block only (always force update)
   - Soft prompt only (always dismissible)
   - Both hard block and soft prompt — recommended

3. **Check frequency?**
   - Every app launch
   - Once per day — recommended
   - Once per week

4. **Include skip option for soft updates?**
   - Yes — user can skip a specific version and won't be prompted again until a newer version is available
   - No — prompt shows every time (respecting check frequency)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `AppVersion.swift` — Semantic version model (major.minor.patch) with Comparable
2. `UpdateRequirement.swift` — Enum: none, softUpdate, hardUpdate with message and store URL
3. `VersionChecker.swift` — Protocol + implementation based on chosen source

### Step 3: Create Manager
4. `UpdateManager.swift` — @Observable manager that coordinates checks, caches timing, exposes state

### Step 4: Create UI Files
5. `ForceUpdateView.swift` — Full-screen blocking view with App Store button
6. `SoftUpdateBannerView.swift` — Dismissible banner with Update and Later buttons

### Step 5: Create Integration
7. `UpdateCheckModifier.swift` — ViewModifier that auto-checks on appear and presents UI

### Step 6: Determine File Location
Check project structure:
- If `Sources/` exists → `Sources/ForceUpdate/`
- If `App/` exists → `App/ForceUpdate/`
- Otherwise → `ForceUpdate/`

## Output Format

After generation, provide:

### Files Created
```
ForceUpdate/
├── AppVersion.swift           # Semantic version model with Comparable
├── UpdateRequirement.swift    # none / softUpdate / hardUpdate enum
├── VersionChecker.swift       # Protocol + remote/App Store implementation
├── UpdateManager.swift        # @Observable coordinator
├── ForceUpdateView.swift      # Full-screen blocking UI
├── SoftUpdateBannerView.swift # Dismissible banner UI
└── UpdateCheckModifier.swift  # ViewModifier for auto-check
```

### Integration Steps

**Add the modifier to your root view:**
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .checkForUpdates()
        }
    }
}
```

**Custom configuration:**
```swift
ContentView()
    .checkForUpdates(
        checker: RemoteJSONVersionChecker(
            url: URL(string: "https://api.example.com/app-config")!
        ),
        frequency: .daily
    )
```

**Manual check from a settings screen:**
```swift
struct SettingsView: View {
    @Environment(UpdateManager.self) private var updateManager

    var body: some View {
        Section("App") {
            if case .softUpdate(_, let message) = updateManager.requirement {
                Button("Update Available") {
                    updateManager.openAppStore()
                }
            }

            Button("Check for Updates") {
                Task { await updateManager.checkNow() }
            }
        }
    }
}
```

### Testing

```swift
@Test
func hardUpdateBlocksWhenBelowMinimum() async throws {
    let checker = MockVersionChecker(
        requirement: .hardUpdate(
            version: AppVersion(major: 2, minor: 0, patch: 0),
            message: "Critical security fix"
        )
    )
    let manager = UpdateManager(
        checker: checker,
        currentVersion: AppVersion(major: 1, minor: 0, patch: 0)
    )

    await manager.checkNow()

    guard case .hardUpdate = manager.requirement else {
        Issue.record("Expected hard update requirement")
        return
    }
}

@Test
func softUpdateAllowsSkip() async throws {
    let checker = MockVersionChecker(
        requirement: .softUpdate(
            version: AppVersion(major: 1, minor: 5, patch: 0),
            message: "New features available"
        )
    )
    let manager = UpdateManager(
        checker: checker,
        currentVersion: AppVersion(major: 1, minor: 0, patch: 0)
    )

    await manager.checkNow()
    manager.skipCurrentUpdate()

    #expect(manager.requirement == .none)
}

@Test
func respectsCheckFrequency() async throws {
    let checker = MockVersionChecker(requirement: .none)
    let manager = UpdateManager(checker: checker, frequency: .daily)

    await manager.checkNow()
    #expect(checker.checkCount == 1)

    // Second check within frequency window should skip
    await manager.checkIfNeeded()
    #expect(checker.checkCount == 1)
}
```

## Common Patterns

### Check on Every Launch
```swift
// In your App's root view
ContentView()
    .checkForUpdates(frequency: .everyLaunch)
```

### Hard Block for Critical Security Updates
The remote JSON should differentiate between hard and soft:
```json
{
    "minimumVersion": "2.0.0",
    "minimumVersionMessage": "This version is no longer supported. Please update for security fixes.",
    "recommendedVersion": "2.1.0",
    "recommendedVersionMessage": "Update for new features and improvements.",
    "storeURL": "https://apps.apple.com/app/id123456789"
}
```

### Soft Prompt with Skip
```swift
SoftUpdateBannerView(
    message: "A new version is available",
    onUpdate: { updateManager.openAppStore() },
    onSkip: { updateManager.skipCurrentUpdate() }
)
```

## Gotchas

### App Store Lookup API Rate Limits
The iTunes Search API (`itunes.apple.com/lookup?bundleId=...`) has undocumented rate limits. For high-volume apps, prefer a remote JSON endpoint you control. Cache the response and avoid calling on every cold launch.

### Version String Comparison
Never compare version strings lexicographically — `"9.0.0" > "10.0.0"` evaluates to `true`. Always parse into semantic version components (major, minor, patch) and compare numerically.

### Don't Block During Onboarding
If the user hasn't completed onboarding, defer the force update check until after. Blocking a first-launch user with an update screen creates confusion.

### Offline Handling
If the version check network request fails, do **not** block the user. Default to `.none` (allow usage). Only block when you have a confirmed response that the version is below minimum.

### TestFlight and Debug Builds
Skip force update checks for TestFlight and debug builds. TestFlight builds always have a higher build number but may have a lower marketing version during development:
```swift
#if DEBUG
// Skip version check
#else
// Check version
#endif
```

### App Review Rejection Risk
Apple may reject apps that show an update prompt during review if the current App Store version is the one under review. Consider disabling the check when the app is running in a sandbox/review environment.

## References

- **templates.md** — All production Swift code templates
- Related: `generators/networking-layer` — Base networking layer for API calls
- Related: `generators/feature-flags` — Feature flags can control update enforcement
- Related: `generators/whats-new` — Show what's new after an update completes

### Source: `generators/http-cache`

# HTTP Cache Generator

Generate a production HTTP caching layer that integrates with your existing networking code. Supports Cache-Control directives, ETag/Last-Modified conditional requests, stale-while-revalidate, and offline fallback.

## When This Skill Activates

Use this skill when the user:
- Asks to "add HTTP caching" or "cache API responses"
- Wants "offline support" or "offline fallback"
- Mentions "reduce API calls" or "cache network responses"
- Asks about "ETag" or "conditional requests" or "304 Not Modified"
- Wants "stale-while-revalidate" behavior

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Search for existing caching implementations
- [ ] Identify source file locations

### 2. Networking Layer Detection
Search for existing networking code:
```
Glob: **/*API*.swift, **/*Client*.swift, **/*Network*.swift
Grep: "APIClient" or "URLSession" or "HTTPURLResponse"
```

If `networking-layer` generator was used, detect the `APIClient` protocol and generate a decorator that wraps it.

### 3. Conflict Detection
Search for existing caching:
```
Glob: **/*Cache*.swift
Grep: "URLCache" or "ResponseCache" or "CachePolicy"
```

If found, ask user whether to replace or extend.

## Configuration Questions

Ask user via AskUserQuestion:

1. **Cache storage sizes?**
   - Small (10 MB memory / 50 MB disk)
   - Medium (25 MB memory / 100 MB disk) — recommended
   - Large (50 MB memory / 250 MB disk)

2. **Caching strategy?**
   - Respect server Cache-Control headers (standard)
   - Cache-first with background revalidation (stale-while-revalidate)
   - Manual per-endpoint policies

3. **Offline support?**
   - Yes — serve stale cache when network unavailable
   - No — only cache while online

4. **Integration style?**
   - Decorator wrapping existing APIClient (recommended if networking-layer exists)
   - Standalone cache you call directly

## Generation Process

### Step 1: Read Templates
Read `http-cache-patterns.md` for architecture guidance.
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `HTTPCacheConfiguration.swift` — Memory/disk sizes, default policy
2. `CachePolicy.swift` — Per-endpoint enum (default, noCache, forceCache, cacheFirst)
3. `CacheControlHeader.swift` — Cache-Control header parser
4. `ConditionalRequestHandler.swift` — ETag/Last-Modified/304 handling
5. `HTTPResponseCache.swift` — Protocol + disk-backed response store

### Step 3: Create Integration Files
Based on configuration:
- `CachingAPIClient.swift` — Decorator wrapping existing APIClient (if decorator style)
- `NetworkReachability.swift` — NWPathMonitor wrapper (if offline support selected)

### Step 4: Determine File Location
Check project structure:
- If `Sources/Networking/` exists → `Sources/Networking/Cache/`
- If `App/Networking/` exists → `App/Networking/Cache/`
- If `Networking/` exists → `Networking/Cache/`
- Otherwise → `Cache/`

## Output Format

After generation, provide:

### Files Created
```
Networking/Cache/
├── HTTPCacheConfiguration.swift    # Memory/disk sizes, default policy
├── CachePolicy.swift               # Per-endpoint caching enum
├── CacheControlHeader.swift        # Cache-Control header parser
├── ConditionalRequestHandler.swift # ETag/Last-Modified/304
├── HTTPResponseCache.swift         # Protocol + disk implementation
├── CachingAPIClient.swift          # Decorator for existing APIClient
└── NetworkReachability.swift       # NWPathMonitor (optional)
```

### Integration Steps

**Wrap your existing client:**
```swift
let baseClient = URLSessionAPIClient(configuration: .production)
let cachingClient = CachingAPIClient(
    wrapping: baseClient,
    cache: DiskHTTPResponseCache(),
    configuration: .default
)

// Use cachingClient everywhere you used baseClient
let users = try await cachingClient.request(UsersEndpoint())
```

**Per-endpoint cache policy:**
```swift
struct UsersEndpoint: APIEndpoint, CacheConfigurable {
    var cachePolicy: CachePolicy { .cacheFirst(maxAge: 300) }
}

struct OrdersEndpoint: APIEndpoint, CacheConfigurable {
    var cachePolicy: CachePolicy { .noCache }
}
```

**With SwiftUI:**
```swift
struct UsersView: View {
    @Environment(\.apiClient) private var apiClient

    var body: some View {
        List(users) { user in
            Text(user.name)
        }
        .task {
            // Automatically uses cache if available
            users = try await apiClient.request(UsersEndpoint())
        }
    }
}
```

### Testing

```swift
@Test
func cachedResponseReturnedOnSecondRequest() async throws {
    let mockClient = MockAPIClient()
    let cache = InMemoryHTTPResponseCache()
    let cachingClient = CachingAPIClient(wrapping: mockClient, cache: cache)

    mockClient.mockResponse(for: UsersEndpoint.self, response: [.mock])

    // First request hits network
    let first = try await cachingClient.request(UsersEndpoint())
    #expect(mockClient.requestCount == 1)

    // Second request comes from cache
    let second = try await cachingClient.request(UsersEndpoint())
    #expect(mockClient.requestCount == 1) // No additional network call
    #expect(first == second)
}
```

## References

- **http-cache-patterns.md** — Cache-Control directives, ETag flow, stale-while-revalidate
- **templates.md** — All production Swift templates
- Related: `generators/networking-layer` — Base networking layer this decorates

### Source: `generators/image-loading`

# Image Loading Generator

Generate a production image loading pipeline with NSCache memory cache, LRU disk cache, request deduplication, image processing, and a drop-in `CachedAsyncImage` SwiftUI view.

## When This Skill Activates

Use this skill when the user:
- Asks to "add image caching" or "cache images"
- Wants to "replace AsyncImage" or fix "AsyncImage has no cache"
- Mentions "image loading pipeline" or "lazy image loading"
- Asks about "image download" or "image prefetching"
- Wants "thumbnail generation" or "image resizing"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 16+ / macOS 13+)
- [ ] Check for @Observable support (iOS 17+ / macOS 14+)
- [ ] Identify source file locations

### 2. Conflict Detection
Search for existing image loading:
```
Glob: **/*ImageCache*.swift, **/*ImageLoader*.swift, **/*ImagePipeline*.swift
Grep: "AsyncImage" or "UIImage" or "NSImage" or "ImageCache"
```

If third-party library found (Kingfisher, SDWebImage, Nuke):
- Ask if user wants to replace or keep it
- If keeping, don't generate — advise on best practices instead

### 3. Platform Detection
Determine if generating for iOS (UIImage) or macOS (NSImage) or both (cross-platform typealias).

## Configuration Questions

Ask user via AskUserQuestion:

1. **Cache sizes?**
   - Small (50 MB memory / 100 MB disk)
   - Medium (100 MB memory / 250 MB disk) — recommended
   - Large (200 MB memory / 500 MB disk)

2. **Image processing?**
   - Resize to fit (downscale large images to save memory)
   - Thumbnail generation (create small thumbnails for lists)
   - None (cache original images only)

3. **Additional features?** (multi-select)
   - Prefetching for collections (preload images for visible rows + buffer)
   - Placeholder and error images
   - Progress indicator during download

4. **Platform?**
   - iOS only
   - macOS only
   - Cross-platform (iOS + macOS)

## Generation Process

### Step 1: Read Templates
Read `image-loading-patterns.md` for architecture guidance.
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `ImageCache.swift` — Protocol for cache interface
2. `MemoryImageCache.swift` — NSCache-based with configurable size
3. `DiskImageCache.swift` — FileManager LRU with expiration
4. `ImageDownloader.swift` — Actor-based with deduplication + cancellation
5. `ImagePipeline.swift` — Orchestrator (cache → download → process → store)

### Step 3: Create UI Files
6. `CachedAsyncImage.swift` — Drop-in SwiftUI view replacement

### Step 4: Create Optional Files
Based on configuration:
- `ImageProcessor.swift` — If resize or thumbnail selected
- `ImagePrefetcher.swift` — If prefetching selected

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists → `Sources/ImageLoading/`
- If `App/` exists → `App/ImageLoading/`
- Otherwise → `ImageLoading/`

## Output Format

After generation, provide:

### Files Created
```
ImageLoading/
├── ImageCache.swift          # Protocol for cache interface
├── MemoryImageCache.swift    # NSCache-based memory cache
├── DiskImageCache.swift      # LRU disk cache with expiration
├── ImageDownloader.swift     # Actor-based downloader
├── ImagePipeline.swift       # Orchestrator
├── ImageProcessor.swift      # Resize, thumbnails (optional)
├── CachedAsyncImage.swift    # SwiftUI view
└── ImagePrefetcher.swift     # Collection prefetching (optional)
```

### Integration Steps

**Drop-in replacement for AsyncImage:**
```swift
// Before (no caching)
AsyncImage(url: user.avatarURL) { image in
    image.resizable().aspectRatio(contentMode: .fill)
} placeholder: {
    ProgressView()
}

// After (with caching)
CachedAsyncImage(url: user.avatarURL) { image in
    image.resizable().aspectRatio(contentMode: .fill)
} placeholder: {
    ProgressView()
}
```

**In a List:**
```swift
List(users) { user in
    HStack {
        CachedAsyncImage(url: user.avatarURL) { image in
            image.resizable().frame(width: 44, height: 44).clipShape(Circle())
        } placeholder: {
            Circle().fill(Color.secondary.opacity(0.2)).frame(width: 44, height: 44)
        }
        Text(user.name)
    }
}
```

**With prefetching:**
```swift
struct UsersListView: View {
    let users: [User]
    @State private var prefetcher = ImagePrefetcher()

    var body: some View {
        List(users) { user in
            UserRow(user: user)
                .onAppear { prefetcher.startPrefetching(urls: nearbyURLs(for: user)) }
                .onDisappear { prefetcher.stopPrefetching(urls: [user.avatarURL]) }
        }
    }
}
```

**With image processing:**
```swift
CachedAsyncImage(
    url: photo.url,
    processing: .resize(targetSize: CGSize(width: 300, height: 300))
) { image in
    image.resizable()
} placeholder: {
    Color.secondary.opacity(0.2)
}
```

### Testing

```swift
@Test
func cachedImageReturnedWithoutDownload() async throws {
    let cache = InMemoryImageCache()
    let downloader = MockImageDownloader()
    let pipeline = ImagePipeline(cache: cache, downloader: downloader)

    let testImage = PlatformImage.testImage
    await cache.store(testImage, for: testURL)

    let result = try await pipeline.image(for: testURL)
    #expect(result != nil)
    #expect(downloader.downloadCount == 0) // Cache hit
}

@Test
func deduplicatesConcurrentRequests() async throws {
    let downloader = MockImageDownloader(delay: .milliseconds(100))
    let pipeline = ImagePipeline(downloader: downloader)

    async let image1 = pipeline.image(for: testURL)
    async let image2 = pipeline.image(for: testURL)

    let results = try await [image1, image2]
    #expect(results.count == 2)
    #expect(downloader.downloadCount == 1) // Only one download
}
```

## References

- **image-loading-patterns.md** — Why not AsyncImage, NSCache config, LRU disk cache, deduplication
- **templates.md** — All production Swift templates
- Related: `generators/http-cache` — General HTTP response caching
- Related: `generators/pagination` — Prefetch images in paginated lists

### Source: `generators/in-app-events`

# In-App Events Generator

Generate complete In-App Event metadata ready for App Store Connect upload, including event cards, descriptions, deep link configuration, and promotional image specifications.

## When This Skill Activates

Use this skill when the user:
- Asks to "create in-app events" or "add App Store events"
- Mentions "event cards" or "App Store event metadata"
- Wants to create seasonal campaigns or challenges on the App Store
- Asks about "event badges" or "event promotion"
- Mentions driving engagement through App Store events

## How In-App Events Work

In-App Events appear on:
- Your product page (up to 5 events visible)
- Search results (when relevant to search term)
- Editorial features and collections
- Personalized recommendations

Events are visible to ALL users — including people who haven't downloaded your app. This makes them a powerful discovery and re-engagement tool. Users who opt in also get an App Store notification when the event starts.

### Rules & Limits (per Apple)

| Rule | Value |
|------|-------|
| Event duration | 15 minutes to 31 days |
| Publish ahead of start | Up to 14 days early — the card shows the start time |
| Concurrent limits | 10 approved / 5 published simultaneously across storefronts — ASC blocks submission beyond either |
| Per-country schedules | Custom start/end per country, within ±48 hours of the default schedule |
| Review time | ~24 hours typical |
| Past-event URL | Stays live for 30 days after the event ends |
| Card media | One image, or a looping video ≤30 seconds |
| Submission conflict | Marketing role can't submit an event while an app version is in submission |
| Analytics | Event analytics appear only after ≥5 downloads from the event |

## Configuration Questions

Ask user via AskUserQuestion:

1. **Event type**
   - Challenge (skill-based competition or goal)
   - Competition (leaderboard or ranked event)
   - Live Event (real-time participation)
   - Special Event (limited-time content or feature)
   - Major Update (significant new version)
   - New Season (seasonal content refresh)
   - Premiere (first-time content debut)

2. **Event purpose**
   - Drive new downloads (acquisition)
   - Re-engage lapsed users (re-engagement)
   - Increase active user engagement (retention)
   - Promote new content/feature (awareness)

3. **Number of events to create**
   - Single event
   - Event series (3-5 related events)
   - Seasonal calendar (12-month plan)

## Generation Process

### Step 1: Gather Event Details

For each event, collect:
- Event concept and theme
- Start and end dates
- Target audience (new users, existing users, lapsed users)
- Related app feature or content

### Step 2: Generate Metadata

For each event, produce:
1. **Event Reference Name** (64 characters max, internal, not shown to users)
2. **Event Badge** (one of the 7 badge types)
3. **Event Name** (30 characters max, shown on event card)
4. **Short Description** (50 characters max, shown on event card)
5. **Long Description** (120 characters max, shown on event detail page)
6. **Event Media Specs** (image/video requirements)
7. **Deep Link** (where users land when they tap the event)

### Step 3: Generate Image Specs

Provide exact image specifications for event cards:
- **Event Card Image**: 1080 x 1920 pixels (portrait) or 1920 x 1080 (landscape)
- **Format**: PNG or JPEG
- **Safe zones**: Keep critical content within center 80%
- **No text or logos in card art** (per Apple) — the card already renders your event name and app name over it; preview the image for cropping across placements

### Step 4: Produce Output Document

Write a markdown document with all metadata ready for copy/paste into App Store Connect.

## Event Badge Reference

| Badge | Use For | Examples |
|-------|---------|---------|
| **Challenge** | Goal-based activities users can complete | "30-Day Fitness Challenge", "Photography Week" |
| **Competition** | Ranked or scored events against other users | "Weekly Leaderboard", "Speed Run Contest" |
| **Live Event** | Real-time events at a specific time | "Live Q&A with Creator", "Launch Party" |
| **Special Event** | Limited-time features, offers, or content | "Holiday Collection", "Anniversary Sale" |
| **Major Update** | Significant new app version | "Version 3.0 — Complete Redesign" |
| **New Season** | Seasonal content refreshes | "Winter Season", "Chapter 3" |
| **Premiere** | First-time content or feature debut | "Introducing Dark Mode", "New Game Mode" |

**The badge-fit rule** (per Apple): if none of the badges fits what you're promoting, it shouldn't be an event. Two badges Apple polices closely — **Live Event** must introduce new features, content, or goods (not just "we're streaming"), and **Major Update** must exceed UI tweaks and bug fixes.

### Announced Badge Types

> Status: announced (WWDC26) — verify availability in App Store Connect before executing.

| Badge | Use For | Examples |
|-------|---------|---------|
| **Now On Sale** | Limited-time price drops on the app or IAPs | "Pro Unlock 50% Off — This Week" |
| **Try Before You Buy** | Free-trial or demo-access promotions | "7-Day Free Trial Event" |

## Metadata Best Practices

### Event Name (30 chars)
- **DO**: Name the event like a title, in Title Case ("Summer Photo Week", "Championship Finals")
- **DO**: Include time urgency ("This Week Only", "24-Hour Event")
- **DON'T**: Use generic names ("Special Event", "Update")
- **DON'T**: Style the name as a call to action ("Watch the Live Stream") or use ALL CAPS — App Review flags both (per Apple's Tech Talk)
- **DON'T**: Repeat the badge type in the name — the badge already says it
- **DON'T**: Include app name (it's already shown)

### Short Description (50 chars)
- **DO**: Explain the core value or action
- **DO**: Create urgency or excitement
- **DON'T**: Repeat the event name
- **DON'T**: Use marketing fluff

### Long Description (120 chars)
- **DO**: Provide specific details about what users will experience
- **DO**: Include clear call to action
- **DON'T**: List features — describe the experience

### App Review Rules (Guidelines 2.3.13 + 2.3.8)

- Metadata must be suitable for a **4+ audience in every region** the event runs
- No unverifiable claims ("best", "#1") and no specific prices — prices vary by region
- Don't repeat the badge type in the name or description
- Declare accurately whether the event **requires an IAP or subscription** — it's shown on the card, and an inaccurate declaration stalls review

### Purpose & Priority

- **Purpose** (Attract New Users / Keep Active Users Informed / Bring Back Lapsed Users) feeds the App Store's on-device personalized recommendations — pick honestly; it determines who sees the card
- **High priority** only reorders YOUR events relative to each other — it has no effect on search rank against other apps

### Deep Link (required)

- Prefer a **universal link** over a custom URL scheme; **no shorteners or redirects** — review rejects them
- Route by state: event live → straight to the event; before start → an anticipation screen; new user → onboarding first, then the event
- Test by pasting the link into Notes and tapping it

## Output Format

### Single Event Template

```markdown
# In-App Event: [Event Concept]

## App Store Connect Metadata

| Field | Value |
|-------|-------|
| Reference Name | [internal-name-kebab-case] |
| Badge | [Badge Type] |
| Event Name | [30 chars max] |
| Short Description | [50 chars max] |
| Long Description | [120 chars max] |
| Start Date | [YYYY-MM-DD HH:MM timezone] |
| End Date | [YYYY-MM-DD HH:MM timezone] |
| Event Purpose | [Attract New Users / Keep Active Users Informed / Bring Back Lapsed Users] |
| Event Priority | [Normal / High] |
| Deep Link | [yourapp://event/event-id] |

## Event Card Image

| Spec | Value |
|------|-------|
| Size | 1080 x 1920 px (portrait) |
| Format | PNG, no transparency |
| Safe Zone | Center 80% for critical content |
| Background | [Color/gradient suggestion] |
| Content | [Visual description] |
| Text/Logos | None — event name renders over the art; preview for cropping |

## Deep Link Configuration

- URL Scheme: `yourapp://event/[event-id]`
- Universal Link: `https://yourapp.com/event/[event-id]`
- Fallback: App Store product page

## Localization Notes

- [Language]: [Localized event name and descriptions]
```

### Event Series Template

```markdown
# Event Series: [Series Name]

## Series Overview
[Brief description of the series theme and cadence]

## Events

### Event 1: [Name]
[Same fields as single event template]

### Event 2: [Name]
[Same fields as single event template]

### Event 3: [Name]
[Same fields as single event template]

## Series Strategy
- **Cadence**: [Weekly / Biweekly / Monthly]
- **Escalation**: [How events build on each other]
- **Retention hook**: [What brings users back for the next event]
```

### Annual Calendar Template

```markdown
# Annual Event Calendar: [App Name]

| Month | Event | Badge | Duration | Goal |
|-------|-------|-------|----------|------|
| Jan | [Event name] | [Badge] | [X days] | [Goal] |
| Feb | [Event name] | [Badge] | [X days] | [Goal] |
| ... | ... | ... | ... | ... |

## Seasonal Themes
- **Q1 (Jan-Mar)**: [Theme — e.g., New Year motivation]
- **Q2 (Apr-Jun)**: [Theme — e.g., Spring refresh, WWDC tie-in]
- **Q3 (Jul-Sep)**: [Theme — e.g., Summer activities, back to school]
- **Q4 (Oct-Dec)**: [Theme — e.g., Halloween, holiday season]
```

## References

- Related: `app-store/marketing-strategy` — Strategic event planning by app type
- Related: `generators/custom-product-pages` — Pair events with targeted product pages
- Related: `app-store/app-description-writer` — Event description writing style
- Apple: App Store Connect Help > In-App Events

### Source: `generators/lapsed-user`

# Lapsed User Re-Engagement Generator

Generate production infrastructure for detecting users who haven't opened the app in X days, showing personalized return screens that highlight what they missed, and optionally presenting win-back incentives to recover churned or lapsing users.

## When This Skill Activates

Use this skill when the user:
- Asks about "lapsed user" detection or re-engagement
- Wants to handle "returning user" or "inactive user" scenarios
- Mentions "re-engagement" screens or flows
- Asks about "win-back" offers for churned users
- Wants to detect when a "user hasn't opened app" in a while
- Asks about "user retention" or "come back" experiences

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Check deployment target (iOS 17+ / macOS 14+ for @Observable)
- [ ] Identify source file locations and project structure

### 2. Existing Engagement Tracking
Search for existing engagement or analytics infrastructure:
```
Glob: **/*Analytics*.swift, **/*Engagement*.swift, **/*Tracker*.swift, **/*Activity*.swift
Grep: "lastActiveDate" or "UserDefaults" or "scenePhase" or "applicationDidBecomeActive"
```

If existing tracking found:
- Ask if user wants to integrate with it or build standalone
- If integrating, adapt templates to use existing storage/events

### 3. Push Notification Setup
Search for existing push notification configuration:
```
Glob: **/*Notification*.swift, **/*Push*.swift
Grep: "UNUserNotificationCenter" or "UNNotification" or "registerForRemoteNotifications"
```

If push notifications are configured, offer push-based re-engagement as an option.

### 4. Conflict Detection
Search for existing lapsed user handling:
```
Glob: **/*LapsedUser*.swift, **/*WinBack*.swift, **/*ReturnExperience*.swift, **/*Reengag*.swift
Grep: "lapsedUser" or "winBack" or "returnExperience" or "daysInactive"
```

If existing implementation found:
- Ask if user wants to replace or extend it
- If extending, generate only the missing pieces

## Configuration Questions

Ask user via AskUserQuestion:

1. **Inactivity threshold?**
   - 7 days (light engagement apps — social, news)
   - 14 days (moderate engagement — productivity, fitness) — recommended
   - 30 days (low-frequency apps — finance, travel)
   - Custom (user specifies days)

2. **Re-engagement strategy?**
   - What-You-Missed (highlight new content, features, or activity since last visit)
   - Special Offer (discount or extended trial for lapsed subscribers)
   - Fresh Start (reset onboarding highlights, re-introduce key features)
   - All of the above (tiered by lapse duration)

3. **Trigger mechanism?**
   - Show on app return (present sheet when user opens app after inactivity)
   - Via push notification (schedule local notification after X days inactive)
   - Both — recommended

4. **Include analytics events?**
   - Yes (track lapse detection, return screen shown, CTA tapped, offer redeemed) — recommended
   - No (skip analytics, just UI)

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `InactivityTracker.swift` — Tracks last active date, calculates days since last use
2. `LapsedUserDetector.swift` — Evaluates inactivity against thresholds, returns lapse category
3. `LapsedUserManager.swift` — Orchestrator combining detection + experience selection + analytics

### Step 3: Create UI Files
4. `ReturnExperienceView.swift` — Personalized "Welcome back" screen with what-you-missed
5. `WinBackOfferView.swift` — Special offer screen for lapsed subscribers

### Step 4: Create Integration File
6. `LapsedUserModifier.swift` — SwiftUI ViewModifier for root view auto-detection and presentation

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists → `Sources/LapsedUser/`
- If `App/` exists → `App/LapsedUser/`
- Otherwise → `LapsedUser/`

## Output Format

After generation, provide:

### Files Created
```
LapsedUser/
├── InactivityTracker.swift       # Tracks last active date in UserDefaults
├── LapsedUserDetector.swift      # Evaluates inactivity thresholds
├── LapsedUserManager.swift       # Orchestrator for detection + experience
├── ReturnExperienceView.swift    # Welcome back screen with highlights
├── WinBackOfferView.swift        # Special offer for lapsed subscribers
└── LapsedUserModifier.swift      # ViewModifier for auto-detection
```

### Integration at App Launch

**Attach to root view:**
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .lapsedUserDetection()
        }
    }
}
```

**Manual detection (if you need control over presentation):**
```swift
struct ContentView: View {
    @State private var manager = LapsedUserManager()

    var body: some View {
        NavigationStack {
            MainView()
        }
        .task {
            await manager.checkOnReturn()
        }
        .sheet(item: $manager.returnExperience) { experience in
            ReturnExperienceView(experience: experience)
        }
        .sheet(item: $manager.winBackOffer) { offer in
            WinBackOfferView(offer: offer)
        }
    }
}
```

**With custom thresholds:**
```swift
let detector = LapsedUserDetector(
    recentThreshold: 7,     // 1-7 days: recently inactive
    moderateThreshold: 21,  // 8-21 days: moderately lapsed
    longTermThreshold: 60   // 22-60 days: long-term lapsed
)
```

**Win-back offer for lapsed subscribers:**
```swift
WinBackOfferView(offer: WinBackOffer(
    headline: "We missed you!",
    discount: .percentage(30),
    originalPrice: "$9.99/mo",
    offerPrice: "$6.99/mo",
    expiresIn: .days(7),
    productID: "com.app.premium.monthly"
))
```

### Testing

```swift
@Test
func detectsRecentlyInactiveUser() async {
    let tracker = InactivityTracker(store: MockUserDefaults())
    tracker.recordActivity()

    // Simulate 5 days of inactivity
    tracker.override(lastActiveDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!)

    let detector = LapsedUserDetector(tracker: tracker)
    let category = detector.evaluate()
    #expect(category == .recentlyInactive)
}

@Test
func longTermLapsedUserGetsWinBackOffer() async {
    let tracker = InactivityTracker(store: MockUserDefaults())
    tracker.override(lastActiveDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!)

    let manager = LapsedUserManager(tracker: tracker, isSubscriber: true)
    await manager.checkOnReturn()

    #expect(manager.winBackOffer != nil)
    #expect(manager.returnExperience != nil)
}

@Test
func activeUserSeesNothing() async {
    let tracker = InactivityTracker(store: MockUserDefaults())
    tracker.recordActivity() // Just opened the app

    let manager = LapsedUserManager(tracker: tracker)
    await manager.checkOnReturn()

    #expect(manager.returnExperience == nil)
    #expect(manager.winBackOffer == nil)
}
```

## Common Patterns

### Detect on App Become Active
```swift
// In your App struct or root view
.onChange(of: scenePhase) { _, newPhase in
    if newPhase == .active {
        inactivityTracker.recordActivity()
    }
}
```

### Show Return Screen
```swift
// LapsedUserManager determines what to show based on:
// 1. How long the user has been away
// 2. Whether they are/were a subscriber
// 3. What changed in the app since their last visit
let experience = manager.buildReturnExperience(
    category: .moderatelyLapsed,
    changelog: appChangelog.since(tracker.lastActiveDate)
)
```

### Trigger Win-Back Offer
```swift
// Only show win-back to users who previously had a subscription
if detector.category.isLapsed && subscriptionStatus == .expired {
    manager.presentWinBackOffer(
        discount: .percentage(30),
        duration: .days(7)
    )
}
```

## Gotchas

### Background App Refresh vs Actual Absence
Background app refresh triggers `applicationDidBecomeActive` without user interaction. Use `scenePhase` changes to `.active` paired with the app being in `.background` (not `.inactive`) to avoid false positives. Track whether the user actually interacted (foreground time > threshold).

### Timezone-Aware Date Math
Always use `Calendar.current` for day calculations, not raw `TimeInterval` division. A user who opened the app at 11pm and returns at 1am the next day has been away for 2 hours, not 1 day.

```swift
// Wrong - raw seconds
let daysAway = Date().timeIntervalSince(lastActive) / 86400

// Right - calendar-aware
let daysAway = Calendar.current.dateComponents([.day], from: lastActive, to: Date()).day ?? 0
```

### Don't Annoy Deliberate Break-Takers
Provide a "Don't show again" option on the return screen. Respect user preferences — if they dismiss the return experience, increase the threshold before showing again. Store dismissal count and back off exponentially.

### Avoid Stacking with Other Modals
If your app has onboarding, what's-new, or review prompts, coordinate with them. Don't show a return screen AND a review prompt AND a what's-new modal on the same launch. Use a presentation queue.

### Testing Date-Dependent Logic
Inject the date source so tests can control "now":
```swift
let tracker = InactivityTracker(
    store: mockDefaults,
    currentDate: { Date(timeIntervalSince1970: 1700000000) }
)
```

## References

- **templates.md** — All production Swift templates
- Related: `generators/subscription-lifecycle` — Subscription state management
- Related: `generators/whats-new` — What's New screen generation
