# Integrated Reference Bundle 09

Combines 11 related source skills from `ios-swift-platform` into one navigable reference file.

## Source map

- `swiftdata/SKILL.reference.md`
- `swiftdata/inheritance/SKILL.reference.md`
- `swiftdata-pro/SKILL.reference.md`
- `swiftui-performance-audit/SKILL.reference.md`
- `swiftui-performance-inspector/SKILL.reference.md`
- `swiftui-pro/SKILL.reference.md`
- `swiftui-ui-patterns/SKILL.reference.md`
- `swiftui-ui-patterns_1895/SKILL.reference.md`
- `swiftui-view-architect/SKILL.reference.md`
- `swiftui-view-refactor/SKILL.reference.md`
- `swiftui_0533/SKILL.reference.md`

## Integrated guidance

### Source: `swiftdata`

# SwiftData Skills

SwiftData modeling patterns beyond the basics.

## When This Skill Activates

Use this skill when the user:
- Designs **hierarchical SwiftData models** (class inheritance)
- Needs **type-based or polymorphic queries**
- Weighs **inheritance vs enum** for model variants

## Available Skills

Paths are relative to THIS file's directory — skills run with cwd set to the
user's project, so resolve each path from this SKILL.md's own location.

| Skill | Read | Covers |
|-------|------|--------|
| inheritance | `inheritance/SKILL.md` | Class inheritance, polymorphic relationships, type-based querying, inheritance-vs-enum |

## How to Route

1. Read `inheritance/SKILL.md` (relative to this file) plus any reference files it lists.
2. Apply the guidance to the user's code. For broader macOS SwiftData architecture, see also `../macos/swiftdata-architecture/SKILL.md`.

### Source: `swiftdata/inheritance`

# SwiftData Class Inheritance

Guide for implementing class inheritance in SwiftData models. Covers when to use inheritance versus enums or protocols, how to annotate subclasses, query across hierarchies, and avoid common pitfalls with schema migrations and relationship modeling.

## When This Skill Activates

- User is designing a SwiftData model hierarchy with shared base properties
- User asks about `@Model` on subclasses or how inheritance works in SwiftData
- User needs to query across a type hierarchy (all trips vs only business trips)
- User is deciding between inheritance, enums, or protocols for model variants
- User has issues with polymorphic relationships or type casting in SwiftData
- User is migrating a Core Data inheritance hierarchy to SwiftData

## Decision Tree

```
Do your model variants share a common identity and most properties?
|
+-- YES: Clear IS-A relationship (BusinessTrip IS-A Trip)
|   |
|   +-- Subclasses add significant unique properties or behavior?
|   |   +-- YES --> Use class inheritance (this skill)
|   |   +-- NO, just 1-2 distinguishing fields --> Use enum property on base model
|   |
|   +-- Need to query "all trips" AND "only business trips"?
|       +-- YES --> Inheritance gives you both for free
|       +-- Only one type at a time --> Enum filter is simpler
|
+-- NO: Models share only a few properties
|   +-- Use protocol conformance (no SwiftData inheritance needed)
|
+-- UNCERTAIN: Could go either way
    +-- Prefer enum on base model (simpler schema, easier migrations)
    +-- Promote to inheritance later if variants diverge significantly
```

### When to Use Inheritance

- There is a meaningful IS-A relationship (a `BusinessTrip` fundamentally IS a `Trip`)
- Subclasses add substantial unique stored properties
- You need deep queries (fetch all `Trip` instances regardless of subtype) and shallow queries (fetch only `BusinessTrip`)
- Polymorphic relationships are required (a `[Trip]` array holding mixed subtypes)

### When to Avoid Inheritance

- Subclasses share only a few properties -- use a protocol instead
- A boolean flag or enum could represent the distinction without separate classes
- You want to minimize schema migration complexity
- The hierarchy would go deeper than two levels

## API Patterns

### Base Model Declaration

Apply `@Model` to the base class. All persistent properties live here.

```swift
@Model
class Trip {
    var name: String
    var startDate: Date
    var endDate: Date

    @Attribute(.preserveValueOnDeletion)
    var identifier: UUID

    @Relationship(deleteRule: .cascade, inverse: \Accommodation.trip)
    var accommodations: [Accommodation] = []

    init(name: String, startDate: Date, endDate: Date) {
        self.identifier = UUID()
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}
```

### Subclass Declaration

Apply `@Model` to each subclass. Call `super.init()` and add subclass-specific stored properties.

```swift
@Model
class BusinessTrip: Trip {
    var company: String
    var expenseReport: String?
    var meetingAgenda: String?

    init(name: String, startDate: Date, endDate: Date, company: String) {
        self.company = company
        super.init(name: name, startDate: startDate, endDate: endDate)
    }
}

@Model
class PersonalTrip: Trip {
    enum Reason: String, Codable {
        case vacation
        case family
        case adventure
    }

    var reason: Reason
    var companions: [String] = []

    init(name: String, startDate: Date, endDate: Date, reason: Reason) {
        self.reason = reason
        super.init(name: name, startDate: startDate, endDate: endDate)
    }
}
```

### Relationships Across the Hierarchy

Relationships defined on the base class apply to all subclasses:

```swift
@Model
class Accommodation {
    var name: String

    // Points to Trip -- could be BusinessTrip or PersonalTrip at runtime
    @Relationship(inverse: \Trip.accommodations)
    var trip: Trip?

    init(name: String) { self.name = name }
}
```

### ModelContainer Configuration

Register the base class. SwiftData discovers subclasses automatically.

```swift
// Register Trip -- BusinessTrip and PersonalTrip are included automatically
let container = try ModelContainer(for: Trip.self, Accommodation.self, Itinerary.self)
```

## Querying Hierarchies

### Deep Query (All Subclasses)

Querying the base class returns instances of every subclass.

```swift
// Returns Trip, BusinessTrip, and PersonalTrip instances
@Query(sort: \Trip.startDate)
var allTrips: [Trip]
```

### Type Filtering with Predicate

Narrow results to a specific subclass using `is` or `as?` in a `#Predicate`.

```swift
// Only BusinessTrip instances
let businessOnly = #Predicate<Trip> { trip in
    trip is BusinessTrip
}

@Query(filter: #Predicate<Trip> { $0 is BusinessTrip }, sort: \Trip.startDate)
var businessTrips: [Trip]
```

### Subclass Property Filtering

Access subclass-specific properties with conditional casting inside the predicate.

```swift
let vacationTrips = #Predicate<Trip> { trip in
    if let personal = trip as? PersonalTrip {
        personal.reason == .vacation
    } else {
        false
    }
}
```

### Enum-Based Filter Switching in UI

A common pattern for filter controls that switch between all trips and a specific type.

```swift
enum TripFilter: String, CaseIterable, Identifiable {
    case all, business, personal
    var id: String { rawValue }
}

struct TripListView: View {
    @State private var filter: TripFilter = .all
    @Query(sort: \Trip.startDate) var allTrips: [Trip]

    var filteredTrips: [Trip] {
        switch filter {
        case .all: return allTrips
        case .business: return allTrips.filter { $0 is BusinessTrip }
        case .personal: return allTrips.filter { $0 is PersonalTrip }
        }
    }

    var body: some View {
        List {
            Picker("Filter", selection: $filter) {
                ForEach(TripFilter.allCases) { f in
                    Text(f.rawValue.capitalized).tag(f)
                }
            }
            .pickerStyle(.segmented)

            ForEach(filteredTrips) { trip in
                TripRowView(trip: trip)
            }
        }
    }
}
```

### Type Casting at Runtime

Use standard Swift casting to access subclass-specific properties in views.

```swift
if let business = trip as? BusinessTrip {
    LabeledContent("Company", value: business.company)
}
if let personal = trip as? PersonalTrip {
    LabeledContent("Reason", value: personal.reason.rawValue)
}
```

## Top Mistakes

### 1. Missing @Model on Subclass

The `@Model` macro must appear on both the base class and every subclass.

```swift
// WRONG -- subclass properties not persisted
class BusinessTrip: Trip {
    var company: String  // not saved
    ...
}

// RIGHT
@Model
class BusinessTrip: Trip {
    var company: String  // persisted correctly
    ...
}
```

### 2. Deep Hierarchies

Keep hierarchies to one level of subclassing (base + one tier).

```swift
// WRONG -- three levels deep
@Model class InternationalBusinessTrip: BusinessTrip { ... }  // avoid

// RIGHT -- flat: base + one level
@Model class Trip { ... }
@Model class BusinessTrip: Trip { ... }
@Model class PersonalTrip: Trip { ... }
```

### 3. Using Inheritance When an Enum Would Suffice

If the only difference is a type tag and one or two optional fields, an enum on the base model is simpler.

```swift
// WRONG -- inheritance just for a category label
@Model class DomesticTrip: Trip { }
@Model class InternationalTrip: Trip { var passportRequired: Bool = true }

// RIGHT -- enum property on the base model
@Model class Trip {
    enum Category: String, Codable { case domestic, international }
    var name: String
    var category: Category
    var passportRequired: Bool?
}
```

### 4. Forgetting super.init()

Subclass initializers must call `super.init()` with all required base properties. Missing this causes incomplete or corrupt records.

```swift
// WRONG -- base properties uninitialized
init(company: String) {
    self.company = company
    // Missing super.init(name:startDate:endDate:)
}

// RIGHT -- always call super.init()
init(name: String, startDate: Date, endDate: Date, company: String) {
    self.company = company
    super.init(name: name, startDate: startDate, endDate: endDate)
}
```

### 5. Registering Subclasses Separately in ModelContainer

Register only the base class -- see "ModelContainer Configuration" above.

```swift
// UNNECESSARY
let container = try ModelContainer(for: Trip.self, BusinessTrip.self, PersonalTrip.self)

// RIGHT
let container = try ModelContainer(for: Trip.self)
```

## Review Checklist

When reviewing code that uses SwiftData class inheritance, verify each item:

- [ ] `@Model` is applied to the base class AND every subclass
- [ ] Each subclass calls `super.init()` with all required base properties
- [ ] Hierarchy is shallow (base + one level of subclasses, no deeper)
- [ ] The IS-A relationship is meaningful -- not just a type tag that could be an enum
- [ ] `@Attribute(.preserveValueOnDeletion)` is used on fields needed after deletion (sync IDs, audit trails)
- [ ] Relationships use `inverse:` parameters correctly, pointing to the base class property
- [ ] `@Relationship(deleteRule:)` is specified on owning side (`.cascade`, `.nullify`, or `.deny`)
- [ ] Deep queries (base class fetch) and shallow queries (type-filtered) both work as expected
- [ ] Type casting (`as? Subclass`) is used safely with `if let` in views and logic
- [ ] ModelContainer registers the base class (subclasses are auto-discovered)
- [ ] Schema migration plan exists if the hierarchy will evolve (adding/removing subclasses)
- [ ] Enum-based filter pattern is used for UI that switches between type views

## Cross-Reference

- For **SwiftData repository and architecture patterns**, see `macos/swiftdata-architecture/`
- For **SwiftData concurrency with @ModelActor**, see `swift/concurrency-patterns/`
- For **persistence setup generator**, see `generators/persistence-setup/`

## References

- [Preserving your app's model data across launches](https://developer.apple.com/documentation/swiftdata/preserving-your-apps-model-data-across-launches)
- [SwiftData documentation](https://developer.apple.com/documentation/swiftdata)
- Local captured doc (optional): `~/Downloads/docs/SwiftData-Class-Inheritance.md` — read if present; skip silently if absent.

### Source: `swiftdata-pro`

Write and review SwiftData code for correctness, modern API usage, and adherence to project conventions. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Check for core SwiftData issues using `references/core-rules.md`.
1. Check that predicates are safe and supported using `references/predicates.md`.
1. If the project uses CloudKit, check for CloudKit-specific constraints using `references/cloudkit.md`.
1. If the project targets iOS 18+, check for indexing opportunities using `references/indexing.md`.
1. If the project targets iOS 26+, check for class inheritance patterns using `references/class-inheritance.md`.

If doing partial work, load only the relevant reference files.


## Core Instructions

- Target Swift 6.2 or later, using modern Swift concurrency.
- The user strongly prefers to use SwiftData across the board. Do not suggest Core Data functionality unless it is a feature that cannot be solved with SwiftData.
- Do not introduce third-party frameworks without asking first.
- Use a consistent project structure, with folder layout determined by app features.


## Output Format

If the user asks for a review, organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary of the most impactful changes to make first.

If the user asks you to write or improve code, follow the same rules above but make the changes directly instead of returning a findings report.

Example output:

### Destination.swift

**Line 8: Add an explicit delete rule for relationships.**

```swift
// Before
var sights: [Sight]

// After
@Relationship(deleteRule: .cascade, inverse: \Sight.destination) var sights: [Sight]
```

**Line 22: Do not use `isEmpty == false` in predicates – it crashes at runtime. Use `!` instead.**

```swift
// Before
#Predicate<Destination> { $0.sights.isEmpty == false }

// After
#Predicate<Destination> { !$0.sights.isEmpty }
```

### DestinationListView.swift

**Line 5: `@Query` must only be used inside SwiftUI views.**

```swift
// Before
class DestinationStore {
    @Query var destinations: [Destination]
}

// After
class DestinationStore {
    var modelContext: ModelContext

    func fetchDestinations() throws -> [Destination] {
        try modelContext.fetch(FetchDescriptor<Destination>())
    }
}
```

### Summary

1. **Data loss (high):** Missing delete rule on line 8 of Destination.swift means sights will be orphaned when a destination is deleted.
2. **Crash (high):** `isEmpty == false` on line 22 will crash at runtime – use `!isEmpty` instead.
3. **Incorrect behavior (high):** `@Query` on line 5 of DestinationListView.swift only works inside SwiftUI views.

End of example.


## References

- `references/core-rules.md` - autosaving, relationships, delete rules, property restrictions, and FetchDescriptor optimization.
- `references/predicates.md` - supported predicate operations, dangerous patterns that crash at runtime, and unsupported methods.
- `references/cloudkit.md` - CloudKit-specific constraints including uniqueness, optionality, and eventual consistency.
- `references/indexing.md` - database indexing for iOS 18+, including single and compound property indexes.
- `references/class-inheritance.md` - model subclassing for iOS 26+, including @available requirements, schema setup, and predicate filtering.

### Source: `swiftui-performance-audit`

# SwiftUI Performance Audit

## Overview

Audit SwiftUI view performance from instrumentation and baselining to root-cause analysis and concrete remediation steps.

## Workflow Decision Tree

1. **If user provides code**: Start with Code-First Review
2. **If user only describes symptoms**: Ask for minimal code/context, then Code-First Review
3. **If code review is inconclusive**: Guide user to profile with Instruments

## 1. Code-First Review

### Collect
- Target view/feature code
- Data flow: state, environment, observable models
- Symptoms and reproduction steps

### Focus On
- View invalidation storms from broad state changes
- Unstable identity in lists (`id` churn, `UUID()` per render)
- Heavy work in `body` (formatting, sorting, image decoding)
- Layout thrash (deep stacks, `GeometryReader`, preference chains)
- Large images without downsampling
- Over-animated hierarchies (implicit animations on large trees)

### Provide
- Likely root causes with code references
- Suggested fixes and refactors
- Minimal repro or instrumentation suggestion if needed

## 2. Guide User to Profile

If code review is inconclusive, explain how to collect data:

1. Use SwiftUI template in Instruments (Release build)
2. Reproduce the exact interaction (scroll, navigation, animation)
3. Capture SwiftUI timeline and Time Profiler
4. Export or screenshot relevant lanes and call tree

Ask for:
- Trace export or screenshots
- Device/OS/build configuration

## 3. Common Code Smells (and Fixes)

### Expensive formatters in `body`

**Bad:**
```swift
var body: some View {
    let formatter = NumberFormatter()  // Slow allocation every render
    Text(formatter.string(from: value))
}
```

**Good:**
```swift
final class Formatters {
    static let number = NumberFormatter()
}

var body: some View {
    Text(Formatters.number.string(from: value))
}
```

### Computed properties with heavy work

**Bad:**
```swift
var filtered: [Item] {
    items.filter { $0.isEnabled }  // Runs every body eval
}
```

**Good:**
```swift
@State private var filtered: [Item] = []

.onChange(of: items) {
    filtered = items.filter { $0.isEnabled }
}
```

### Sorting/filtering in ForEach

**Bad:**
```swift
ForEach(items.sorted(by: sortRule)) { item in
    Row(item)
}
```

**Good:**
```swift
let sortedItems = items.sorted(by: sortRule)  // Compute once
ForEach(sortedItems) { item in
    Row(item)
}
```

### Unstable identity

**Bad:**
```swift
ForEach(items, id: \.self) { item in  // \.self may not be stable
    Row(item)
}
```

**Good:**
```swift
ForEach(items, id: \.stableID) { item in
    Row(item)
}
```

### Image decoding on main thread

**Bad:**
```swift
Image(uiImage: UIImage(data: data)!)
```

**Good:**
```swift
// Decode/downsample off main thread, cache the result
@State private var image: UIImage?

.task {
    image = await ImageLoader.load(data: data, targetSize: size)
}
```

### Broad dependencies in observable models

**Bad:**
```swift
@Observable class Model {
    var items: [Item] = []
}

var body: some View {
    Row(isFavorite: model.items.contains(item))  // Entire array dependency
}
```

**Good:**
```swift
// Granular view models or per-item state to reduce update fan-out
```

## 4. Remediation Strategies

| Issue | Fix |
|-------|-----|
| Broad state changes | Narrow scope with `@State`/`@Observable` closer to leaves |
| Unstable identities | Use stable, unique IDs for `ForEach` |
| Heavy work in body | Precompute, cache, move to `@State` |
| Expensive subtrees | Use `equatable()` or value wrappers |
| Large images | Downsample before rendering |
| Layout complexity | Reduce nesting, use fixed sizing where possible |

## 5. Verify

Ask user to re-run same capture and compare with baseline:
- CPU usage
- Frame drops
- Memory peak

## Output Format

Provide:
1. Metrics table (before/after if available)
2. Top issues (ordered by impact)
3. Proposed fixes with estimated effort

## Profiling Commands

```bash
# Build for profiling
xcodebuild -scheme MyApp -configuration Release -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Open in Instruments
open -a Instruments
```

## Instruments Checklist

- [ ] Use Release build (not Debug)
- [ ] Select SwiftUI template
- [ ] Reproduce exact problematic interaction
- [ ] Look at SwiftUI timeline for body evaluations
- [ ] Check Time Profiler for hot spots
- [ ] Note frame rate drops in Animation timeline

### Source: `swiftui-performance-inspector`

# SwiftUI Performance Inspector

Diagnose from code first, then request profiling evidence when code review cannot explain the symptom.

## Workflow

1. Classify the symptom: slow rendering, scrolling jank, high CPU, memory growth, hangs, broad updates, or layout thrash.
2. If code is available, review with `references/code-smells.md`.
3. If code is missing, ask for the smallest useful slice: target view, data flow, reproduction steps, device/simulator, build config, and deployment target.
4. If runtime evidence is needed, use `references/profiling-intake.md` for the exact Instruments checklist.
5. Report likely causes, evidence, fixes, and validation steps using `references/report-template.md` when useful.

## Code Review Focus

- invalidation storms from broad observation or environment reads
- unstable identity in `List`/`ForEach`
- heavy derived work in `body` or view builders
- layout thrash from complex hierarchy, `GeometryReader`, or preferences
- main-thread image decode/resize or other expensive work
- animation and transition work applied too broadly

## Profiling Evidence

Ask for SwiftUI timeline or Time Profiler export/screenshots, device/OS/build configuration, exact profiled interaction, and before/after metrics when comparing changes.

Map evidence to invalidation, identity churn, layout, main-thread work, image cost, animation cost, or hangs. Distinguish trace-backed findings from code-level suspicion and state what evidence would reduce uncertainty.

## Fix Defaults

- narrow state scope and observation fan-out
- stabilize list identities
- move heavy work out of `body` into model/service precomputation, memoized helpers, background preprocessing, or input-driven derived state
- use `@State` only for view-owned state, not arbitrary caches
- use `equatable()` only when equality is cheaper than recomputing and inputs are value-semantic
- downsample images before rendering
- reduce layout complexity or add stable sizing where appropriate

## Output

Provide a short metrics table when available, top issues ordered by impact, proposed fixes with effort, and verification steps.

## References

- `references/profiling-intake.md`
- `references/code-smells.md`
- `references/report-template.md`
- `references/optimizing-swiftui-performance-instruments.md`
- `references/understanding-improving-swiftui-performance.md`
- `references/understanding-hangs-in-your-app.md`
- `references/demystify-swiftui-performance-wwdc23.md`

Use current Apple Developer docs when Instruments or SwiftUI performance guidance may have changed.

### Source: `swiftui-pro`

Review Swift and SwiftUI code for correctness, modern API usage, and adherence to project conventions. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Check for deprecated API using `references/api.md`.
1. Check that views, modifiers, and animations have been written optimally using `references/views.md`.
1. Validate that data flow is configured correctly using `references/data.md`.
1. Ensure navigation is updated and performant using `references/navigation.md`.
1. Ensure the code uses designs that are accessible and compliant with Apple’s Human Interface Guidelines using `references/design.md`.
1. Validate accessibility compliance including Dynamic Type, VoiceOver, and Reduce Motion using `references/accessibility.md`.
1. Ensure the code is able to run efficiently using `references/performance.md`.
1. Quick validation of Swift code using `references/swift.md`.
1. Final code hygiene check using `references/hygiene.md`.

If doing a partial review, load only the relevant reference files.


## Core Instructions

- iOS 26 exists, and is the default deployment target for new apps.
- Target Swift 6.2 or later, using modern Swift concurrency.
- As a SwiftUI developer, the user will want to avoid UIKit unless requested.
- Do not introduce third-party frameworks without asking first.
- Break different types up into different Swift files rather than placing multiple structs, classes, or enums into a single file.
- Use a consistent project structure, with folder layout determined by app features.


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated (e.g., "Use `foregroundStyle()` instead of `foregroundColor()`").
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary of the most impactful changes to make first.

Example output:

### ContentView.swift

**Line 12: Use `foregroundStyle()` instead of `foregroundColor()`.**

```swift
// Before
Text("Hello").foregroundColor(.red)

// After
Text("Hello").foregroundStyle(.red)
```

**Line 24: Icon-only button is bad for VoiceOver - add a text label.**

```swift
// Before
Button(action: addUser) {
    Image(systemName: "plus")
}

// After
Button("Add User", systemImage: "plus", action: addUser)
```

**Line 31: Avoid `Binding(get:set:)` in view body - use `@State` with `onChange()` instead.**

```swift
// Before
TextField("Username", text: Binding(
    get: { model.username },
    set: { model.username = $0; model.save() }
))

// After
TextField("Username", text: $model.username)
    .onChange(of: model.username) {
        model.save()
    }
```

### Summary

1. **Accessibility (high):** The add button on line 24 is invisible to VoiceOver.
2. **Deprecated API (medium):** `foregroundColor()` on line 12 should be `foregroundStyle()`.
3. **Data flow (medium):** The manual binding on line 31 is fragile and harder to maintain.

End of example.


## References

- `references/accessibility.md` - Dynamic Type, VoiceOver, Reduce Motion, and other accessibility requirements.
- `references/api.md` - updating code for modern API, and the deprecated code it replaces.
- `references/design.md` - guidance for building accessible apps that meet Apple’s Human Interface Guidelines.
- `references/hygiene.md` - making code compile cleanly and be maintainable in the long term.
- `references/navigation.md` - navigation using `NavigationStack`/`NavigationSplitView`, plus alerts, confirmation dialogs, and sheets.
- `references/performance.md` - optimizing SwiftUI code for maximum performance.
- `references/data.md` - data flow, shared state, and property wrappers.
- `references/swift.md` - tips on writing modern Swift code, including using Swift Concurrency effectively.
- `references/views.md` - view structure, composition, and animation.

### Source: `swiftui-ui-patterns`

# SwiftUI UI Patterns

## Quick Start

### Existing Project
1. Identify the feature and primary interaction model (list, detail, editor, settings, tabbed)
2. Find nearby examples in the repo with `rg "TabView\("` or similar
3. Apply local conventions: prefer SwiftUI-native state, keep state local
4. Build with small, focused subviews and SwiftUI-native data flow

### New Project Scaffolding
1. Wire TabView + NavigationStack + sheets
2. Add minimal `AppTab` enum and `RouterPath`
3. Expand route and sheet enums as new screens are added

## General Rules

- Use modern SwiftUI state (`@State`, `@Binding`, `@Observable`, `@Environment`)
- Avoid unnecessary view models - prefer MV (Model-View) over MVVM
- Prefer composition; keep views small and focused
- Use async/await with `.task` and explicit loading/error states
- Follow the project's formatter and style guide

### Sheets Best Practices
- Prefer `.sheet(item:)` over `.sheet(isPresented:)` when state represents a selected model
- Avoid `if let` inside a sheet body
- Sheets should own their actions and call `dismiss()` internally

## Workflow for a New SwiftUI View

1. Define the view's state and its ownership location
2. Identify dependencies to inject via `@Environment`
3. Sketch the view hierarchy and extract repeated parts into subviews
4. Implement async loading with `.task` and explicit state enum if needed
5. Add accessibility labels or identifiers for interactive UI
6. Validate with a build and update usage callsites if needed

## MV Pattern (Preferred over MVVM)

SwiftUI views should be lightweight state expressions. Avoid ViewModels unless truly necessary.

```swift
struct FeedView: View {
    @Environment(APIClient.self) private var client

    enum ViewState {
        case loading
        case error(String)
        case loaded([Post])
    }

    @State private var viewState: ViewState = .loading

    var body: some View {
        NavigationStack {
            List {
                switch viewState {
                case .loading:
                    ProgressView("Loading...")
                case .error(let message):
                    ErrorView(message: message, retry: { await loadFeed() })
                case .loaded(let posts):
                    ForEach(posts) { post in
                        PostRow(post: post)
                    }
                }
            }
            .task { await loadFeed() }
        }
    }

    private func loadFeed() async {
        do {
            let posts = try await client.getFeed()
            viewState = .loaded(posts)
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}
```

## Sheet Patterns

### Item-driven sheet (preferred)
```swift
@State private var selectedItem: Item?

.sheet(item: $selectedItem) { item in
    EditItemSheet(item: item)
}
```

### Sheet owns its actions
```swift
struct EditItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    let item: Item
    @State private var isSaving = false

    var body: some View {
        VStack {
            Button(isSaving ? "Saving..." : "Save") {
                Task { await save() }
            }
        }
    }

    private func save() async {
        isSaving = true
        await store.save(item)
        dismiss()
    }
}
```

## App-Level Environment Setup

```swift
@main
struct MyApp: App {
    @State var client: APIClient = .init()
    @State var router: AppRouter = .init()

    var body: some Scene {
        WindowGroup {
            TabView(selection: $router.selectedTab) {
                ForEach(AppTab.allCases) { tab in
                    tab.rootView
                        .tag(tab)
                }
            }
            .environment(client)
            .environment(router)
        }
    }
}
```

## State Management Guidelines

| Wrapper | Use Case |
|---------|----------|
| `@State` | Local, ephemeral view state |
| `@Binding` | Two-way data flow from parent |
| `@Observable` | Shared state across views (iOS 17+) |
| `@Environment` | Dependency injection, app-wide concerns |
| `@Query` | SwiftData queries directly in views |

## Task and onChange Patterns

```swift
// React to state changes
.task(id: searchText) {
    guard !searchText.isEmpty else { return }
    await search(query: searchText)
}

// Respond to state transitions
.onChange(of: isActive, initial: false) {
    guard isActive else { return }
    Task { await refresh() }
}
```

## Why Not MVVM?

SwiftUI was designed without ViewModels in mind:
- Views are structs, lightweight and disposable
- `@State`, `@Environment`, `@Observable` handle all data flow needs
- ViewModels add complexity, indirection, and cognitive overhead
- SwiftData's `@Query` works directly in views

**Instead:**
- Keep views as pure expressions of state
- Put business logic in services/models injected via `@Environment`
- Test services and models, not views
- Use SwiftUI Previews for visual regression testing

### Source: `swiftui-ui-patterns_1895`

# SwiftUI UI Patterns

## Quick start

Choose a track based on your goal:

### Existing project

- Identify the feature or screen and the primary interaction model (list, detail, editor, settings, tabbed).
- Find a nearby example in the repo with `rg "TabView\("` or similar, then read the closest SwiftUI view.
- Apply local conventions: prefer SwiftUI-native state, keep state local when possible, and use environment injection for shared dependencies.
- Choose the relevant component reference from `references/components-index.md` and follow its guidance.
- Build the view with small, focused subviews and SwiftUI-native data flow.

### New project scaffolding

- Start with `references/app-scaffolding-wiring.md` to wire TabView + NavigationStack + sheets.
- Add a minimal `AppTab` and `RouterPath` based on the provided skeletons.
- Choose the next component reference based on the UI you need first (TabView, NavigationStack, Sheets).
- Expand the route and sheet enums as new screens are added.

## General rules to follow

- Use modern SwiftUI state (`@State`, `@Binding`, `@Observable`, `@Environment`) and avoid unnecessary view models.
- Prefer composition; keep views small and focused.
- Use async/await with `.task` and explicit loading/error states.
- Maintain existing legacy patterns only when editing legacy files.
- Follow the project's formatter and style guide.
- **Sheets**: Prefer `.sheet(item:)` over `.sheet(isPresented:)` when state represents a selected model. Avoid `if let` inside a sheet body. Sheets should own their actions and call `dismiss()` internally instead of forwarding `onCancel`/`onConfirm` closures.

## Workflow for a new SwiftUI view

1. Define the view's state and its ownership location.
2. Identify dependencies to inject via `@Environment`.
3. Sketch the view hierarchy and extract repeated parts into subviews.
4. Implement async loading with `.task` and explicit state enum if needed.
5. Add accessibility labels or identifiers when the UI is interactive.
6. Validate with a build and update usage callsites if needed.

## Component references

Use `references/components-index.md` as the entry point. Each component reference should include:
- Intent and best-fit scenarios.
- Minimal usage pattern with local conventions.
- Pitfalls and performance notes.
- Paths to existing examples in the current repo.

## Sheet patterns

### Item-driven sheet (preferred)

```swift
@State private var selectedItem: Item?

.sheet(item: $selectedItem) { item in
    EditItemSheet(item: item)
}
```

### Sheet owns its actions

```swift
struct EditItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Store.self) private var store

    let item: Item
    @State private var isSaving = false

    var body: some View {
        VStack {
            Button(isSaving ? "Saving…" : "Save") {
                Task { await save() }
            }
        }
    }

    private func save() async {
        isSaving = true
        await store.save(item)
        dismiss()
    }
}
```

## Adding a new component reference

- Create `references/<component>.md`.
- Keep it short and actionable; link to concrete files in the current repo.
- Update `references/components-index.md` with the new entry.

### Source: `swiftui-view-architect`

# SwiftUI View Architect

Default to vanilla SwiftUI: local state in views, shared dependencies in environment/services, business logic outside view bodies, and view models only when requested or already present.

## Ordering

Preserve stronger local conventions; otherwise order stored members top-to-bottom:

1. environment
2. `let` inputs
3. `@State`/other stored properties
4. non-view computed vars
5. `init`
6. `body`
7. view builders/helpers
8. actions/async helpers

## Rules

- Prefer MV over MVVM. Do not introduce a view model just to mirror local state or wrap environment dependencies.
- Split long bodies into dedicated `View` types with explicit inputs/bindings/callbacks. Keep computed `some View` helpers small and rare.
- Extract non-trivial button actions and side effects from `body`; call private methods, and move real domain logic into services/models.
- Keep a stable root view tree. Avoid top-level `if/else` swapping entire root branches; localize conditions in sections/modifiers/overlays/toolbars.
- If a view model exists, prefer non-optional state initialized in `init`:
  ```swift
  @State private var viewModel: SomeViewModel
  init(dependency: Dependency) {
    _viewModel = State(initialValue: SomeViewModel(dependency: dependency))
  }
  ```
- For `@Observable` owners on iOS 17+, store as `@State` and pass explicitly. For iOS 16 or earlier, use `@StateObject` owner and `@ObservedObject` injection.
- Keep behavior/layout intact unless the user asked for a product change.

## Workflow

1. Reorder the view.
2. Move inline actions/effects out of `body`.
3. Extract meaningful sections into dedicated subviews; move reusable/independent subviews to files.
4. Stabilize root structure.
5. Normalize view model and Observation usage.
6. Build/test the touched surface.

## Large Views

For ~300+ line files, split aggressively into section views and small private helpers. `// MARK:` extensions can organize actions/helpers but are not a substitute for extracting real subviews.

Reference: `references/mv-patterns.md`. Use current Apple docs when SwiftUI/Observation behavior may have changed.

### Source: `swiftui-view-refactor`

# SwiftUI View Refactor

## Overview

Apply consistent structure and dependency patterns to SwiftUI views, focusing on ordering, MV patterns, careful view model handling, and correct Observation usage.

## View Ordering (top to bottom)

1. Environment properties
2. `private`/`public` `let` constants
3. `@State` / other stored properties
4. Computed `var` (non-view)
5. `init`
6. `body`
7. Computed view builders / view helpers
8. Helper / async functions

## Core Guidelines

### 1) Prefer MV (Model-View) Patterns

- Default to MV: views are lightweight state expressions; models/services own business logic
- Favor `@State`, `@Environment`, `@Query`, `task`, and `onChange` for orchestration
- Inject services and shared models via `@Environment`
- Split large views into smaller views instead of introducing a view model

### 2) Split Large Bodies

If `body` grows beyond a screen or has multiple logical sections, split it:

```swift
var body: some View {
    VStack(alignment: .leading, spacing: 16) {
        HeaderSection(title: title, isPinned: isPinned)
        DetailsSection(details: details)
        ActionsSection(onSave: onSave, onCancel: onCancel)
    }
}
```

Or use computed view properties in the same file:

```swift
var body: some View {
    List {
        header
        filters
        results
        footer
    }
}

private var header: some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title).font(.title2)
        Text(subtitle).font(.subheadline)
    }
}

private var filters: some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            ForEach(filterOptions, id: \.self) { option in
                FilterChip(option: option, isSelected: option == selectedFilter)
                    .onTapGesture { selectedFilter = option }
            }
        }
    }
}
```

### 3) View Model Handling (only if already present)

- Do not introduce a view model unless the request or existing code clearly calls for one
- If a view model exists, make it non-optional when possible
- Pass dependencies to the view via `init`, then into the view model

```swift
@State private var viewModel: SomeViewModel

init(dependency: Dependency) {
    _viewModel = State(initialValue: SomeViewModel(dependency: dependency))
}
```

### 4) Observation Usage

- For `@Observable` reference types, store them as `@State` in the root view
- Pass observables down explicitly as needed
- Avoid optional state unless required

## Refactor Workflow

1. Reorder the view to match the ordering rules
2. Favor MV: move orchestration into the view using `@State`, `@Environment`, `task`, `onChange`
3. If a view model exists, replace optional with non-optional `@State` initialized in `init`
4. Confirm Observation usage: `@State` for root `@Observable`, no redundant wrappers
5. Keep behavior intact: do not change layout or business logic unless requested

## Large-View Handling

When a SwiftUI view file exceeds ~300 lines:

1. Split using extensions to group related helpers
2. Move async functions into dedicated `private` extensions
3. Use `// MARK: -` comments (e.g., `// MARK: - Actions`, `// MARK: - Subviews`)
4. Keep main `struct` focused on stored properties, init, and `body`

```swift
struct LargeView: View {
    @Environment(Store.self) private var store
    @State private var items: [Item] = []

    var body: some View {
        List {
            content
        }
        .task { await loadItems() }
    }
}

// MARK: - Subviews
private extension LargeView {
    var content: some View {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}

// MARK: - Actions
private extension LargeView {
    func loadItems() async {
        items = await store.fetchItems()
    }
}
```

## Checklist

- [ ] Properties ordered correctly (Environment → let → @State → computed → init → body)
- [ ] Large body split into subviews or computed view properties
- [ ] No unnecessary ViewModels introduced
- [ ] Existing ViewModels are non-optional where possible
- [ ] `@Observable` types stored as `@State` in root view
- [ ] Dependencies injected via `@Environment`
- [ ] File organized with MARK comments if >300 lines
- [ ] Behavior unchanged unless explicitly requested

### Source: `swiftui_0533`

# SwiftUI Skills

Focused SwiftUI framework skills — each sub-skill covers one API area in depth.

## When This Skill Activates

Use this skill when the user:
- Has **state/rendering bugs**: state resets, over-rendering, flashing lists, animation crossfades (data-flow)
- Is choosing **@State vs @Bindable vs @Environment** or migrating to Observation (data-flow)
- Builds **custom layouts or containers**, or fights **lazy-stack/scroll performance** (layout)
- Wants alarms or timers with **AlarmKit** (custom UI, Live Activities, snooze)
- Is creating **3D data visualizations** with Swift Charts (Chart3D, SurfacePlot)
- Needs **styled text or rich text editing** (Text, AttributedString, TextEditor)
- Is implementing or customizing **toolbars** (customizable toolbars, search integration)
- Wants to **embed web content** (WebView, WebPage, JavaScript interop)

## Available Skills

Paths are relative to THIS file's directory — skills run with cwd set to the
user's project, so resolve each path from this SKILL.md's own location.

| Skill | Read | Covers |
|-------|------|--------|
| data-flow | `data-flow/SKILL.md` | View identity/lifetime/dependencies, Observation, state ownership, body discipline, main-actor contract |
| layout | `layout/SKILL.md` | Layout protocol, Grid decisions, custom containers, lazy-stack + scrolling performance rules |
| alarmkit | `alarmkit/SKILL.md` | Alarms and timers with custom UI, Live Activities, snooze (iOS 18+) |
| charts-3d | `charts-3d/SKILL.md` | Chart3D, SurfacePlot, interactive pose control, surface styling |
| text-editing | `text-editing/SKILL.md` | Text, AttributedString, TextEditor with formatting controls |
| toolbars | `toolbars/SKILL.md` | Customizable toolbars, search integration, transition effects, platform behavior |
| webkit | `webkit/SKILL.md` | WebView and WebPage embedding, navigation, JavaScript interop |

## How to Route

1. Match the request to a row above.
2. Read that SKILL.md (relative to this file) plus any reference files it lists.
3. Apply the guidance to the user's code.
