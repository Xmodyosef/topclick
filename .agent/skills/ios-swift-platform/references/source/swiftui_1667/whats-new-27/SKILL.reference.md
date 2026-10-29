---
name: whats-new-27
description: SwiftUI additions in iOS 27 with compile-verified recipes — drag-to-reorder and swipe actions in any container (grids, stacks, custom layouts), alerts driven by an item or an Error, toolbar visibility priority / overflow menu / pinned trailing items / minimization, prominent tabs, cross-fade sheets, AsyncImage caching, the @State macro, ContentBuilder, URL-based documents, plus the iOS 27.1 foldable-iPhone APIs (ArrangementView, hinge, reserved regions). Use when building SwiftUI for iOS 27, replacing List-only reorder/swipe workarounds, tidying toolbars, or preparing for iPhone Duo.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27
---

# SwiftUI: What's New in iOS 27

These are the iOS 27.0 additions that replace common workarounds. Every snippet comes from
`templates/SwiftUI27.swift`, which typechecks against the iOS 27.0 SDK in Swift 6 and under
default MainActor isolation. The 27.1 foldable APIs at the end are **beta**: they're not in the
27.0 SDK, so they're listed without code.

## When This Skill Activates

- Reorder or swipe-to-delete in a `LazyVGrid`, `LazyVStack`, or custom layout (not a `List`)
- Toolbars overflowing on iPhone; deciding what collapses first
- An alert driven by an optional item or an `Error`
- Starting an iOS 27 project, or auditing SwiftUI for 27-era idioms
- Planning for the foldable iPhone (iOS 27.1)

## Reorder Anywhere

```swift
ScrollView {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
        ForEach(board.cards) { card in CardView(card) }
            .reorderable()                                  // marks the content draggable
    }
    .reorderContainer(for: Card.self) { board.apply($0) }   // receives a ReorderDifference
}
```

```swift
func apply(_ diff: ReorderDifference<Card.ID, ReorderableSingleCollectionIdentifier>) {
    let moving = cards.filter { diff.sources.contains($0.id) }      // may be several items
    cards.removeAll { diff.sources.contains($0.id) }
    switch diff.destination.position {
    case .before(let id): cards.insert(contentsOf: moving, at: cards.firstIndex { $0.id == id } ?? cards.endIndex)
    case .end: cards.append(contentsOf: moving)
    }
}
```

- The difference is **ID-based** (`sources`, `.before(id)` / `.end`), not index-based like `onMove`. Apply it by ID, as above.
- Between sections or columns (kanban): use `.reorderable(collectionID:)` plus `.reorderContainer(for:in:)`; `destination.collectionID` says where the items landed.
- `isEnabled:` toggles reordering (for example, only in edit mode).
- ❌ `List` + `onMove` only so you get reordering. ✅ Keep the layout you want.

## Swipe Actions Anywhere

```swift
ForEach(board.cards) { card in
    CardView(card)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", systemImage: "trash", role: .destructive) { pendingDelete = card }
        }
}
// …
.swipeActionsContainer()        // on the ScrollView / container
```

`swipeActions` now works on rows in any container. `List` coordinates rows for you; elsewhere, add
`.swipeActionsContainer()` so that only one row is open at a time, scrolling dismisses it, and tapping
outside closes it. Use the `onPresentationChanged:` overload when you need to react to the reveal,
for example to dim the row.

## Alerts From Data

```swift
.alert("Delete card?", item: $pendingDelete) { card in
    Button("Delete", role: .destructive) { board.delete(card) }
} message: { card in
    Text("\"\(card.title)\" will be removed.")
}

.alert(error: $error) { Button("OK") {} }   // title from LocalizedError.errorDescription
```

- ❌ Keeping `@State var showAlert = false` and `@State var alertItem` in sync. ✅ One optional drives presentation.
- `confirmationDialog(_:item:titleVisibility:actions:)` works the same way.

## Toolbars That Degrade Gracefully

```swift
.toolbar {
    ToolbarItem(placement: .topBarPinnedTrailing) { ShareButton() }        // never moves
    ToolbarItem(placement: .primaryAction) { BoldButton() }.visibilityPriority(.high)
    ToolbarItem(placement: .primaryAction) { RulerButton() }.visibilityPriority(.low)   // collapses first
    ToolbarOverflowMenu {                                                   // always in "•••"
        Button("Archive", systemImage: "archivebox") {}
        Button("Delete", systemImage: "trash", role: .destructive) {}
    }
}
.toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
```

| API | Use |
|---|---|
| `.visibilityPriority(.high / .low / .automatic)` | Order in which items move to overflow as width shrinks |
| `ToolbarOverflowMenu { }` | Secondary actions that always live in overflow |
| `.topBarPinnedTrailing` | The one action that must never move |
| `.toolbarMinimizationBehavior(_:for:)` | `.onScrollDown` / `.onScrollUp` / `.automatic` |

Deeper toolbar work (customization, search placement) is in `swiftui/toolbars`.

## Small Wins

```swift
Tab("New", systemImage: "plus", role: .prominent) { Composer() }   // separate trailing tab slot
.sheet(isPresented: $composing) { Composer().navigationTransition(.crossFade) }   // fade-in sheet
AsyncImage(request: URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)) { phase in … }
    .asyncImageURLSession(Self.session)                             // your URLCache, auth headers
```

- `AsyncImage` now takes a `URLRequest` and honors HTTP caching. Set a session with a sized `URLCache` for avatar-heavy lists.
- **`@State` is a macro when building with Xcode 27.** A class instance in `@State private var model = Model()` is created **once**, instead of on every view initialization with the extras thrown away. Expensive `init`s in `@State` defaults stop being a performance bug. With Xcode 26 or earlier it's still the property wrapper.
- **`@ContentBuilder`** is the unified result builder that replaces type-specific ones (`ToolbarContentBuilder`, `CommandsBuilder`). Existing `@ViewBuilder` code keeps compiling, and new APIs take `@ContentBuilder` closures.

## URL-Based Documents

`ReadableDocument` / `WritableDocument` are class-based (`Observable`) documents that read
**directly from the file URL**. Use them for large files, streaming, or frameworks that want a URL
(AVFoundation, PDFKit). You supply a `DocumentReader` / `DocumentWriter`; the simple case
uses `FileWrapperDocumentReader` / `FileWrapperDocumentWriter`.
`DocumentGroup(editor:makeDocument:)` and `fileExporter(isPresented:document:…)` accept
them. Keep `FileDocument` for small value-type documents.

## iOS 27.1 (Beta): Foldable iPhone

Not in the 27.0 SDK. These ship with Xcode 27.1 for the iPhone Duo. Plan the layout now and
adopt them when you move to the 27.1 SDK:

| API | Purpose |
|---|---|
| `ArrangementView` + `.arrangementViewStyle(.split / .overlay)` | Primary/secondary content that adapts between side-by-side and stacked |
| `splitArrangementLayoutRatio(_:)`, `splitArrangementLayoutSize(…)` | Size the panes |
| `ReservedRegion`, `reservedRegions(kind:options:layoutDirectionBehavior:)` | Avoid the camera cutout (`.occlusion`) and the hinge (`.division`) |
| `onHingeChange(isEnabled:_:)`, `DeviceHinge` | Hinge angle and state: `.closed`, `.partiallyOpen`, `.fullyOpen` |
| `CameraCaptureAccessory` | Content on the outer display during capture |
| `toolbarVerticalEdge`, `toolbarVerticalBehavior(_:)`, `axisBehavior(_:)` | Toolbars on the vertical axis |

✅ Today: build adaptive layouts from size classes and `ViewThatFits`, and keep content out of fixed
coordinates, so the 27.1 adoption is a style change, not a rewrite.

## Checklist

- [ ] Reorder and swipe in grids and stacks use `reorderable()` / `swipeActions` + their containers
- [ ] Reorder applied by ID from `ReorderDifference`
- [ ] Alerts driven by `item:` or `error:` bindings
- [ ] Toolbar: one pinned action, priorities set, secondary actions in `ToolbarOverflowMenu`
- [ ] `AsyncImage` lists use a cached session
- [ ] No expensive work assumed to rerun in `@State` class defaults (Xcode 27 macro)
- [ ] Foldable layout plan noted for 27.1

## References

- What's new in SwiftUI (WWDC26): https://developer.apple.com/videos/play/wwdc2026/269/
- SwiftUI updates: https://developer.apple.com/documentation/updates/swiftui
- reorderable(): https://developer.apple.com/documentation/swiftui/dynamicviewcontent/reorderable()
- ToolbarOverflowMenu: https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu
- State() macro: https://developer.apple.com/documentation/swiftui/state()
- ArrangementView (27.1 beta): https://developer.apple.com/documentation/swiftui/arrangementview
- Related: `swiftui/toolbars`, `swiftui/layout`, `swiftui/data-flow`, `design/liquid-glass`
