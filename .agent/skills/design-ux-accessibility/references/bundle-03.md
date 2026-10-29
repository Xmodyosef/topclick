# Integrated Reference Bundle 03

Combines 12 related source skills from `design-ux-accessibility` into one navigable reference file.

## Source map

- `layout/SKILL.reference.md`
- `macos/ui-review-tahoe/SKILL.reference.md`
- `macos-liquid-glass-designer/SKILL.reference.md`
- `penpot-uiux-design/SKILL.reference.md`
- `swiftui-liquid-glass/SKILL.reference.md`
- `swiftui-liquid-glass_1885/SKILL.reference.md`
- `swiftui-ux-review/SKILL.reference.md`
- `swiftui_1667/layout/SKILL.reference.md`
- `tuist-generation-doctor/SKILL.reference.md`
- `tuist-migration-planner/SKILL.reference.md`
- `tuist-workspace-navigator/SKILL.reference.md`
- `visionos/spatial-design/SKILL.reference.md`

## Integrated guidance

### Source: `layout`

# Layout Patterns (macOS)

## Window Default Sizing
```swift
WindowGroup {
    ContentView()
}
.defaultSize(width: 900, height: 600)
```

## Window Resizability
```swift
// Allow free resizing with a minimum content size
WindowGroup {
    ContentView()
        .frame(minWidth: 600, minHeight: 400)
}
.windowResizability(.contentMinSize)

// Fixed content size (non-resizable)
Window("Preferences", id: "prefs") {
    PreferencesView()
}
.windowResizability(.contentSize)
```

## Toolbar
```swift
NavigationSplitView {
    SidebarView()
} detail: {
    DetailView()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Document")
                    .font(AppTheme.Fonts.headline)
            }
            ToolbarItemGroup {
                Button("Share", systemImage: "square.and.arrow.up") { share() }
                Button("Settings", systemImage: "gear") { openSettings() }
            }
        }
}
```

## Customizable Toolbar
```swift
.toolbar(id: "editor") {
    ToolbarItem(id: "bold", placement: .automatic) {
        Button("Bold", systemImage: "bold") { toggleBold() }
    }
    ToolbarItem(id: "italic", placement: .automatic) {
        Button("Italic", systemImage: "italic") { toggleItalic() }
    }
}
.toolbarRole(.editor)
```

## Sidebar Column Width
```swift
NavigationSplitView {
    SidebarView()
        .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
} content: {
    ContentList()
        .navigationSplitViewColumnWidth(min: 250, ideal: 300)
} detail: {
    DetailView()
}
```

## Adaptive Sizing
```swift
GeometryReader { geometry in
    let columns = geometry.size.width > 800
        ? [GridItem(.adaptive(minimum: 200))]
        : [GridItem(.adaptive(minimum: 150))]

    LazyVGrid(columns: columns) {
        ForEach(items) { item in
            ItemCard(item: item)
        }
    }
}
```

## Dynamic Type + Accessibility
```swift
@Environment(\.dynamicTypeSize) var dynamicTypeSize

var body: some View {
    VStack(spacing: AppTheme.Spacing.medium) {
        Text(title)
            .font(AppTheme.Fonts.headline)
        Text(subtitle)
            .font(AppTheme.Fonts.body)
    }
    .padding(AppTheme.Spacing.large)
}
```

## Safe Areas
macOS windows have title bar inset and traffic light buttons area:
```swift
VStack {
    content
}
.padding() // Respect default window padding
```

## File Handling (Open/Save Panels)
```swift
.fileImporter(
    isPresented: $showImporter,
    allowedContentTypes: [.json, .plainText]
) { result in
    handleImport(result)
}

.fileExporter(
    isPresented: $showExporter,
    document: myDocument,
    contentType: .json
) { result in
    handleExport(result)
}
```

## NOT Available on macOS
- No device rotation — desktop has resizable windows
- No `.edgesIgnoringSafeArea` patterns for notch/Dynamic Island
- No status bar customization
- No `UIScreen.main.bounds` — use GeometryReader or window sizing

## Rules
1. Use `.defaultSize(width:height:)` for initial window dimensions
2. Use `.windowResizability(.contentMinSize)` for resizable windows with minimums
3. Use `.toolbar {}` with placement for toolbar items
4. Use `.toolbarRole(.editor)` for user-customizable toolbars
5. Use `.navigationSplitViewColumnWidth()` to control sidebar widths
6. Design for resizable windows — never assume fixed dimensions
7. Use AppTheme spacing tokens for consistent layout
8. Use `.fileImporter()` / `.fileExporter()` for open/save panels

### Source: `macos/ui-review-tahoe`

# UI Review for macOS Tahoe

You are a macOS UI/UX expert specializing in the Liquid Glass design system and macOS 26 (Tahoe) Human Interface Guidelines.

## When This Skill Activates

- User asks to review macOS UI or UX
- User wants to check macOS HIG compliance
- User asks about Liquid Glass usage or design consistency
- User wants an accessibility audit of a macOS app
- User is modernizing an AppKit UI with Liquid Glass

## Your Role

Conduct comprehensive UI/UX reviews of macOS applications, focusing on design consistency, accessibility, and adherence to macOS Tahoe design principles.

## Core Focus Areas

1. **Liquid Glass Design System** - Modern design language for macOS 26
2. **macOS Tahoe HIG Compliance** - Platform-specific guidelines
3. **SwiftUI for macOS** - Modern UI patterns and best practices
4. **AppKit Modernization** - AppKit with Liquid Glass design
5. **Accessibility** - VoiceOver, keyboard navigation, Dynamic Type

## How to Conduct Reviews

### Step 1: Understand the Application
- Ask about the app's purpose and target audience
- Identify the UI framework (SwiftUI, AppKit, or hybrid)
- Understand the minimum macOS version supported
- Review the app's design goals and constraints

### Step 2: Systematic UI Audit

Review the interface against each module's guidelines:
- Liquid Glass design implementation (see liquid-glass-design.md)
- macOS Tahoe HIG compliance (see macos-tahoe-hig.md)
- SwiftUI patterns for macOS (see swiftui-macos.md)
- AppKit modernization (see appkit-modern.md)
- Accessibility standards (see accessibility.md)

### Step 3: Provide Structured Feedback

For each UI issue found:
1. **Issue**: Clearly describe the problem
2. **Guideline Violated**: Reference specific HIG or Liquid Glass principle
3. **Impact**: Explain effect on user experience
4. **Fix**: Provide concrete code or design example
5. **Resources**: Link to relevant Apple documentation

### Step 4: Prioritize Recommendations

Categorize feedback:
- 🔴 **Critical**: Breaks platform conventions, accessibility failures
- 🟡 **Important**: Inconsistent with HIG, poor UX
- 🟢 **Nice-to-have**: Polish improvements, advanced features

## Review Checklist

Before completing review, ensure you've checked:

### Visual Design
- [ ] Follows Liquid Glass design principles
- [ ] Transparent menu bar implementation
- [ ] Proper use of depth and hierarchy
- [ ] Consistent spacing and alignment
- [ ] Appropriate color usage (accent colors, semantic colors)
- [ ] Custom folder icons (if applicable)
- [ ] Animation quality and smoothness

### Layout & Navigation
- [ ] Proper window chrome and toolbar design
- [ ] Navigation patterns (NavigationSplitView, tabs)
- [ ] Responsive to window resizing
- [ ] Proper sidebar/main content split
- [ ] Control Center integration (if applicable)
- [ ] Menu bar organization

### Controls & Interactions
- [ ] Platform-appropriate controls
- [ ] Proper button styles and placement
- [ ] Form design and validation
- [ ] Keyboard shortcuts
- [ ] Drag and drop support (where appropriate)
- [ ] Context menus

### Accessibility
- [ ] VoiceOver support
- [ ] Keyboard navigation
- [ ] Focus indicators
- [ ] Dynamic Type support
- [ ] Color contrast (WCAG AA minimum)
- [ ] Accessibility labels and hints

### Performance
- [ ] Smooth animations (60fps)
- [ ] Responsive UI updates
- [ ] No SwiftUI layout bugs (Tahoe-specific issues)
- [ ] Proper NSHostingView usage (if hybrid)

### Platform Integration
- [ ] System appearance (light/dark mode)
- [ ] Accent color support
- [ ] Spotlight integration
- [ ] Share extensions
- [ ] Quick Look (if applicable)

## Module References

Load these modules as needed during review:

1. **Liquid Glass Design**: `skills/ui-review-tahoe/liquid-glass-design.md`
   - Design language principles
   - Visual hierarchy and depth
   - Transparency and materials
   - Animation guidelines

2. **macOS Tahoe HIG**: `skills/ui-review-tahoe/macos-tahoe-hig.md`
   - Human Interface Guidelines
   - Platform conventions
   - Window management
   - Toolbar and menu design

3. **SwiftUI for macOS**: `skills/ui-review-tahoe/swiftui-macos.md`
   - SwiftUI patterns and components
   - macOS-specific modifiers
   - Known Tahoe SwiftUI issues
   - Layout best practices

4. **AppKit Modernization**: `skills/ui-review-tahoe/appkit-modern.md`
   - Modern AppKit patterns
   - Liquid Glass in AppKit
   - NSViewController best practices
   - AppKit + SwiftUI hybrid

5. **Accessibility**: `skills/ui-review-tahoe/accessibility.md`
   - VoiceOver testing
   - Keyboard navigation
   - Dynamic Type
   - Accessibility API usage

## Example Review Format

```markdown
# UI Review: [App Name]

## Summary
Brief overview of the app and its current UI state.

## Critical Issues 🔴
1. **VoiceOver Cannot Navigate Main List**
   - Guideline: Accessibility - VoiceOver support required
   - Impact: App unusable for blind users
   - Fix: [code example with accessibility labels]

## Important Issues 🟡
1. **Window Toolbar Not Following Tahoe HIG**
   - Guideline: macOS Tahoe HIG - Toolbar design
   - Impact: Feels out of place on macOS 26
   - Fix: [code example with proper toolbar]

## Suggestions 🟢
1. **Consider Adding Liquid Glass Transparency**
   - Guideline: Liquid Glass - Visual hierarchy
   - Benefit: More native macOS 26 appearance
   - Example: [code example]

## Overall Assessment
[Summary and priority recommendations]

## Tahoe-Specific Considerations
[Any macOS 26-specific issues or opportunities]
```

## Response Guidelines

- Be constructive and specific
- Provide visual examples when describing issues
- Reference Apple's HIG and WWDC sessions
- Consider both SwiftUI and AppKit contexts
- Acknowledge good design choices already made
- Balance ideal design with practical constraints
- Highlight Tahoe-specific issues and opportunities

## When to Load Modules

- Load modules on-demand as specific topics arise
- Don't load all modules upfront
- Reference module filenames when providing guidance
- Suggest reading specific modules for deeper understanding

## Screenshot Analysis

If provided with screenshots:
- Analyze visual hierarchy and spacing
- Check color contrast and accessibility
- Verify alignment and consistency
- Identify HIG violations
- Suggest improvements

Begin reviews by asking to see the UI code or screenshots, and understanding the app's context.

### Source: `macos-liquid-glass-designer`

# macOS Liquid Glass Designer

Modernize macOS SwiftUI UI by using standard app structure and system materials first; add custom glass only for app-specific surfaces.

## Workflow

1. Inspect the scene/root view and identify the pattern: split view, tab, sheet, toolbar, inspector, custom floating controls.
2. Remove custom opaque backgrounds, scrims, and toolbar/sheet fills that fight system material unless intentionally required.
3. Update standard SwiftUI structure and controls first.
4. Add `glassEffect` only where standard controls do not cover the design.
5. Validate grouping, transitions, icon treatment, pointer/keyboard usability, and foreground activation. Use `macos-runtime-debugger` for SwiftPM GUI apps.

## Rules

- Prefer `NavigationSplitView`; let sidebars use system Liquid Glass material.
- Use `backgroundExtensionEffect` for hero/media that should extend beyond safe area near floating chrome.
- Keep inspectors visually lighter than or equal to the content they inspect.
- Keep `TabView` for persistent top-level sections; do not force iPhone tab/search patterns onto macOS.
- Remove old `presentationBackground` imitation layers when the system sheet material is enough.
- Put hierarchy-wide search on `NavigationSplitView`; use `searchToolbarBehavior` for compact secondary search.
- Assume toolbar items live on floating glass; use `ToolbarSpacer`, `sharedBackgroundVisibility`, and `badge` instead of custom chrome.
- Tint icons/glass only for semantic meaning.
- Prefer standard controls and system glass/prominent button styles before custom translucent buttons.
- Use `controlSize`, `buttonBorderShape`, slider `step`/ticks/`neutralValue`, and `Label` before custom controls.
- Use concentric rectangle/container corner configuration for custom shapes that must align with sheet/card/window corners.

## Custom Glass

- `glassEffect` defaults to a capsule-like shape and vibrant text; pass an explicit shape when needed.
- Use `.interactive()` for custom controls/containers with interactive elements.
- Put nearby custom glass in one `GlassEffectContainer`; separate containers cannot sample each other correctly.
- Use `glassEffectID` with a local `@Namespace` for collapsed/expanded morphing with stable identity.

## Guardrails

- Do not rebuild sidebars, toolbars, sheets, or controls from scratch when SwiftUI APIs provide the behavior.
- Do not leave opaque backgrounds behind `NavigationSplitView`, toolbars, or sheets by default.
- Do not scatter related glass elements across containers.
- Do not tint for decoration alone.
- Do not review Liquid Glass behavior from a bare SwiftPM executable; launch a foreground `.app` bundle.

Use `macos-swiftui-architect` for scene architecture, `macos-view-architect` for large-view structure, `macos-appkit-bridge` for AppKit-only behavior, and `macos-runtime-debugger` for launch/log verification.

### Source: `penpot-uiux-design`

# Penpot UI/UX Design Guide

Create professional, user-centered designs in Penpot using the `penpot/penpot-mcp` MCP server and proven UI/UX principles.

## Available MCP Tools

| Tool | Purpose |
| ---- | ------- |
| `mcp__penpot__execute_code` | Run JavaScript in Penpot plugin context to create/modify designs |
| `mcp__penpot__export_shape` | Export shapes as PNG/SVG for visual inspection |
| `mcp__penpot__import_image` | Import images (icons, photos, logos) into designs |
| `mcp__penpot__penpot_api_info` | Retrieve Penpot API documentation |

## MCP Server Setup

The Penpot MCP tools require the `penpot/penpot-mcp` server running locally. For detailed installation and troubleshooting, see [setup-troubleshooting.md](references/setup-troubleshooting.md).

### Before Setup: Check If Already Running

**Always check if the MCP server is already available before attempting setup:**

1. **Try calling a tool first**: Attempt `mcp__penpot__penpot_api_info` - if it succeeds, the server is running and connected. No setup needed.

2. **If the tool fails**, ask the user:
   > "The Penpot MCP server doesn't appear to be connected. Is the server already installed and running? If so, I can help troubleshoot. If not, I can guide you through the setup."

3. **Only proceed with setup instructions if the user confirms the server is not installed.**

### Quick Start (Only If Not Installed)

```bash
# Clone and install
git clone https://github.com/penpot/penpot-mcp.git
cd penpot-mcp
npm install

# Build and start servers
npm run bootstrap
```

Then in Penpot:
1. Open a design file
2. Go to **Plugins** → **Load plugin from URL**
3. Enter: `http://localhost:4400/manifest.json`
4. Click **"Connect to MCP server"** in the plugin UI

### VS Code Configuration

Add to `settings.json`:
```json
{
  "mcp": {
    "servers": {
      "penpot": {
        "url": "http://localhost:4401/sse"
      }
    }
  }
}
```

### Troubleshooting (If Server Is Installed But Not Working)

| Issue | Solution |
| ----- | -------- |
| Plugin won't connect | Check servers are running (`npm run start:all` in penpot-mcp dir) |
| Browser blocks localhost | Allow local network access prompt, or disable Brave Shield, or try Firefox |
| Tools not appearing in client | Restart VS Code/Claude completely after config changes |
| Tool execution fails/times out | Ensure Penpot plugin UI is open and shows "Connected" |
| "WebSocket connection failed" | Check firewall allows ports 4400, 4401, 4402 |

## Quick Reference

| Task | Reference File |
| ---- | -------------- |
| MCP server installation & troubleshooting | [setup-troubleshooting.md](references/setup-troubleshooting.md) |
| Component specs (buttons, forms, nav) | [component-patterns.md](references/component-patterns.md) |
| Accessibility (contrast, touch targets) | [accessibility.md](references/accessibility.md) |
| Screen sizes & platform specs | [platform-guidelines.md](references/platform-guidelines.md) |

## Core Design Principles

### The Golden Rules

1. **Clarity over cleverness**: Every element must have a purpose
2. **Consistency builds trust**: Reuse patterns, colors, and components
3. **User goals first**: Design for tasks, not features
4. **Accessibility is not optional**: Design for everyone
5. **Test with real users**: Validate assumptions early

### Visual Hierarchy (Priority Order)

1. **Size**: Larger = more important
2. **Color/Contrast**: High contrast draws attention
3. **Position**: Top-left (LTR) gets seen first
4. **Whitespace**: Isolation emphasizes importance
5. **Typography weight**: Bold stands out

## Design Workflow

1. **Check for design system first**: Ask user if they have existing tokens/specs, or discover from current Penpot file
2. **Understand the page**: Call `mcp__penpot__execute_code` with `penpotUtils.shapeStructure()` to see hierarchy
3. **Find elements**: Use `penpotUtils.findShapes()` to locate elements by type or name
4. **Create/modify**: Use `penpot.createBoard()`, `penpot.createRectangle()`, `penpot.createText()` etc.
5. **Apply layout**: Use `addFlexLayout()` for responsive containers
6. **Validate**: Call `mcp__penpot__export_shape` to visually check your work

## Design System Handling

**Before creating designs, determine if the user has an existing design system:**

1. **Ask the user**: "Do you have a design system or brand guidelines to follow?"
2. **Discover from Penpot**: Check for existing components, colors, and patterns

```javascript
// Discover existing design patterns in current file
const allShapes = penpotUtils.findShapes(() => true, penpot.root);

// Find existing colors in use
const colors = new Set();
allShapes.forEach(s => {
  if (s.fills) s.fills.forEach(f => colors.add(f.fillColor));
});

// Find existing text styles (font sizes, weights)
const textStyles = allShapes
  .filter(s => s.type === 'text')
  .map(s => ({ fontSize: s.fontSize, fontWeight: s.fontWeight }));

// Find existing components
const components = penpot.library.local.components;

return { colors: [...colors], textStyles, componentCount: components.length };
```

**If user HAS a design system:**

- Use their specified colors, spacing, typography
- Match their existing component patterns
- Follow their naming conventions

**If user has NO design system:**

- Use the default tokens below as a starting point
- Offer to help establish consistent patterns
- Reference specs in [component-patterns.md](references/component-patterns.md)

## Key Penpot API Gotchas

- `width`/`height` are READ-ONLY → use `shape.resize(w, h)`
- `parentX`/`parentY` are READ-ONLY → use `penpotUtils.setParentXY(shape, x, y)`
- Use `insertChild(index, shape)` for z-ordering (not `appendChild`)
- Flex children array order is REVERSED for `dir="column"` or `dir="row"`
- After `text.resize()`, reset `growType` to `"auto-width"` or `"auto-height"`

## Positioning New Boards

**Always check existing boards before creating new ones** to avoid overlap:

```javascript
// Find all existing boards and calculate next position
const boards = penpotUtils.findShapes(s => s.type === 'board', penpot.root);
let nextX = 0;
const gap = 100; // Space between boards

if (boards.length > 0) {
  // Find rightmost board edge
  boards.forEach(b => {
    const rightEdge = b.x + b.width;
    if (rightEdge + gap > nextX) {
      nextX = rightEdge + gap;
    }
  });
}

// Create new board at calculated position
const newBoard = penpot.createBoard();
newBoard.x = nextX;
newBoard.y = 0;
newBoard.resize(375, 812);
```

**Board spacing guidelines:**

- Use 100px gap between related screens (same flow)
- Use 200px+ gap between different sections/flows
- Align boards vertically (same y) for visual organization
- Group related screens horizontally in user flow order

## Default Design Tokens

**Use these defaults only when user has no design system. Always prefer user's tokens if available.**

### Spacing Scale (8px base)

| Token | Value | Usage |
| ----- | ----- | ----- |
| `spacing-xs` | 4px | Tight inline elements |
| `spacing-sm` | 8px | Related elements |
| `spacing-md` | 16px | Default padding |
| `spacing-lg` | 24px | Section spacing |
| `spacing-xl` | 32px | Major sections |
| `spacing-2xl` | 48px | Page-level spacing |

### Typography Scale

| Level | Size | Weight | Usage |
| ----- | ---- | ------ | ----- |
| Display | 48-64px | Bold | Hero headlines |
| H1 | 32-40px | Bold | Page titles |
| H2 | 24-28px | Semibold | Section headers |
| H3 | 20-22px | Semibold | Subsections |
| Body | 16px | Regular | Main content |
| Small | 14px | Regular | Secondary text |
| Caption | 12px | Regular | Labels, hints |

### Color Usage

| Purpose | Recommendation |
| ------- | -------------- |
| Primary | Main brand color, CTAs |
| Secondary | Supporting actions |
| Success | #22C55E range (confirmations) |
| Warning | #F59E0B range (caution) |
| Error | #EF4444 range (errors) |
| Neutral | Gray scale for text/borders |

## Common Layouts

### Mobile Screen (375×812)

```text
┌─────────────────────────────┐
│ Status Bar (44px)           │
├─────────────────────────────┤
│ Header/Nav (56px)           │
├─────────────────────────────┤
│                             │
│ Content Area                │
│ (Scrollable)                │
│ Padding: 16px horizontal    │
│                             │
├─────────────────────────────┤
│ Bottom Nav/CTA (84px)       │
└─────────────────────────────┘

```

### Desktop Dashboard (1440×900)

```text
┌──────┬──────────────────────────────────┐
│      │ Header (64px)                    │
│ Side │──────────────────────────────────│
│ bar  │ Page Title + Actions             │
│      │──────────────────────────────────│
│ 240  │ Content Grid                     │
│ px   │ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ │
│      │ │Card │ │Card │ │Card │ │Card │ │
│      │ └─────┘ └─────┘ └─────┘ └─────┘ │
│      │                                  │
└──────┴──────────────────────────────────┘

```

## Component Checklist

### Buttons

- [ ] Clear, action-oriented label (2-3 words)
- [ ] Minimum touch target: 44×44px
- [ ] Visual states: default, hover, active, disabled, loading
- [ ] Sufficient contrast (3:1 against background)
- [ ] Consistent border radius across app

### Forms

- [ ] Labels above inputs (not just placeholders)
- [ ] Required field indicators
- [ ] Error messages adjacent to fields
- [ ] Logical tab order
- [ ] Input types match content (email, tel, etc.)

### Navigation

- [ ] Current location clearly indicated
- [ ] Consistent position across screens
- [ ] Maximum 7±2 top-level items
- [ ] Touch-friendly on mobile (48px targets)

## Accessibility Quick Checks

1. **Color contrast**: Text 4.5:1, Large text 3:1
2. **Touch targets**: Minimum 44×44px
3. **Focus states**: Visible keyboard focus indicators
4. **Alt text**: Meaningful descriptions for images
5. **Hierarchy**: Proper heading levels (H1→H2→H3)
6. **Color independence**: Never rely solely on color

## Design Review Checklist

Before finalizing any design:

- [ ] Visual hierarchy is clear
- [ ] Consistent spacing and alignment
- [ ] Typography is readable (16px+ body text)
- [ ] Color contrast meets WCAG AA
- [ ] Interactive elements are obvious
- [ ] Mobile-friendly touch targets
- [ ] Loading/empty/error states considered
- [ ] Consistent with design system

## Validating Designs

Use these validation approaches with `mcp__penpot__execute_code`:

| Check | Method |
| ----- | ------ |
| Elements outside bounds | `penpotUtils.analyzeDescendants()` with `isContainedIn()` |
| Text too small (<12px) | `penpotUtils.findShapes()` filtering by `fontSize` |
| Missing contrast | Call `mcp__penpot__export_shape` and visually inspect |
| Hierarchy structure | `penpotUtils.shapeStructure()` to review nesting |

### Export CSS

Use `penpot.generateStyle(selection, { type: 'css', includeChildren: true })` via `mcp__penpot__execute_code` to extract CSS from designs.

## Tips for Great Designs

1. **Start with content**: Real content reveals layout needs
2. **Design mobile-first**: Constraints breed creativity
3. **Use a grid**: 8px base grid keeps things aligned
4. **Limit colors**: 1 primary + 1 secondary + neutrals
5. **Limit fonts**: 1-2 typefaces maximum
6. **Embrace whitespace**: Breathing room improves comprehension
7. **Be consistent**: Same action = same appearance everywhere
8. **Provide feedback**: Every action needs a response

### Source: `swiftui-liquid-glass`

# SwiftUI Liquid Glass

## Overview

Liquid Glass is a dynamic material in iOS 26+ that combines optical glass properties with fluidity. It blurs content, reflects surrounding color and light, and reacts to touch interactions in real time.

## Workflow Decision Tree

### 1) Review an existing feature
- Inspect where Liquid Glass should/shouldn't be used
- Verify correct modifier order, shape usage, container placement
- Check for iOS 26+ availability handling and fallbacks

### 2) Improve a feature using Liquid Glass
- Identify target components (surfaces, chips, buttons, cards)
- Refactor to use `GlassEffectContainer` for multiple glass elements
- Add interactive glass only for tappable/focusable elements

### 3) Implement a new feature using Liquid Glass
- Design glass surfaces and interactions first (shape, prominence, grouping)
- Add glass modifiers after layout/appearance modifiers
- Add morphing transitions only when view hierarchy changes with animation

## Core Guidelines

- Prefer native Liquid Glass APIs over custom blurs
- Use `GlassEffectContainer` when multiple glass elements coexist
- Apply `.glassEffect(...)` after layout and visual modifiers
- Use `.interactive()` for elements that respond to touch/pointer
- Keep shapes consistent across related elements
- Gate with `#available(iOS 26, *)` and provide non-glass fallback

## Review Checklist

- [ ] **Availability**: `#available(iOS 26, *)` present with fallback UI
- [ ] **Composition**: Multiple glass views wrapped in `GlassEffectContainer`
- [ ] **Modifier order**: `glassEffect` applied after layout/appearance modifiers
- [ ] **Interactivity**: `interactive()` only where user interaction exists
- [ ] **Transitions**: `glassEffectID` used with `@Namespace` for morphing
- [ ] **Consistency**: Shapes, tinting, and spacing align across feature

## Implementation Checklist

- [ ] Define target elements and desired glass prominence
- [ ] Wrap grouped glass elements in `GlassEffectContainer` with spacing
- [ ] Use `.glassEffect(.regular.tint(...).interactive(), in: .rect(cornerRadius: ...))` as needed
- [ ] Use `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)` for actions
- [ ] Add morphing transitions with `glassEffectID` when hierarchy changes
- [ ] Provide fallback materials for earlier iOS versions

## Quick Snippets

### Basic Glass Effect with Fallback
```swift
if #available(iOS 26, *) {
    Text("Hello")
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    Text("Hello")
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```

### Multiple Glass Elements
```swift
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Image(systemName: "scribble.variable")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
    }
}
```

### Glass Buttons
```swift
Button("Confirm") { }
    .buttonStyle(.glassProminent)

Button("Cancel") { }
    .buttonStyle(.glass)
```

### Morphing Transitions
```swift
@State private var isExpanded = false
@Namespace private var namespace

GlassEffectContainer(spacing: 40) {
    HStack(spacing: 40) {
        Image(systemName: "pencil")
            .frame(width: 80, height: 80)
            .glassEffect()
            .glassEffectID("pencil", in: namespace)

        if isExpanded {
            Image(systemName: "eraser")
                .frame(width: 80, height: 80)
                .glassEffect()
                .glassEffectID("eraser", in: namespace)
        }
    }
}

Button("Toggle") {
    withAnimation {
        isExpanded.toggle()
    }
}
.buttonStyle(.glass)
```

### Customizing Glass
```swift
Text("Tinted Glass")
    .padding()
    .glassEffect(.regular.tint(.orange).interactive(), in: .capsule)
```

### Uniting Glass Effects
```swift
@Namespace private var namespace

GlassEffectContainer(spacing: 20) {
    HStack(spacing: 20) {
        ForEach(items.indices, id: \.self) { index in
            ItemView(item: items[index])
                .glassEffect()
                .glassEffectUnion(id: index < 2 ? "group1" : "group2", namespace: namespace)
        }
    }
}
```

## Shape Options

- `.capsule` (default)
- `.rect(cornerRadius: CGFloat)`
- `.circle`

## Best Practices

1. **Container Usage**: Always use `GlassEffectContainer` for multiple glass views
2. **Modifier Order**: Apply `.glassEffect()` after appearance modifiers
3. **Spacing**: Choose spacing values carefully to control effect merging
4. **Animation**: Use animations when changing view hierarchies for smooth morphing
5. **Interactivity**: Add `.interactive()` only to touchable elements
6. **Consistency**: Maintain consistent shapes and styles across your app

### Source: `swiftui-liquid-glass_1885`

# SwiftUI Liquid Glass

## Overview
Use this skill to build or review SwiftUI features that fully align with the iOS 26+ Liquid Glass API. Prioritize native APIs (`glassEffect`, `GlassEffectContainer`, glass button styles) and Apple design guidance. Keep usage consistent, interactive where needed, and performance aware.

## Glass API Reference

### Core Modifier
```swift
func glassEffect<S: Shape>(
    _ glass: Glass = .regular,
    in shape: S = DefaultGlassEffectShape,  // capsule
    isEnabled: Bool = true
) -> some View
```

### Glass Variants (IMPORTANT: Only 3 exist)

| Variant | Use Case |
|---------|----------|
| `.regular` | Standard navigation elements, toolbars, tabs |
| `.clear` | Subtle floating controls over media-rich backgrounds |
| `.identity` | No effect — used for conditional toggling (e.g., accessibility) |

**WARNING:** There is NO `.prominent` variant. For prominent styling, use `.buttonStyle(.glassProminent)` on buttons only.

### Shapes
- `.capsule` (default)
- `.circle`
- `.ellipse`
- `.rect(cornerRadius:)` — supports `.containerConcentric` for auto-matching parent corners
- Any custom `Shape` conforming type

### Tinting
```swift
.glassEffect(.regular.tint(.blue))
.glassEffect(.regular.tint(.purple.opacity(0.6)))
```

### Interactivity (iOS only)
```swift
.glassEffect(.regular.interactive())
```
Enables: scaling, bouncing, shimmering, touch-point illumination, gesture response.

## Workflow Decision Tree
Choose the path that matches the request:

### 1) Review an existing feature
- Inspect where Liquid Glass should be used and where it should not.
- Verify correct modifier order, shape usage, and container placement.
- Check for iOS 26+ availability handling and sensible fallbacks.
- Verify NO `.prominent` variant used (only `.regular`, `.clear`, `.identity`).

### 2) Improve a feature using Liquid Glass
- Identify target components for glass treatment (surfaces, chips, buttons, cards).
- Refactor to use `GlassEffectContainer` where multiple glass elements appear.
- Introduce interactive glass only for tappable or focusable elements.
- Use `glassEffectUnion` to visually merge related controls (like Apple Maps zoom controls).

### 3) Implement a new feature using Liquid Glass
- Design the glass surfaces and interactions first (shape, variant, grouping).
- Add glass modifiers after layout/appearance modifiers.
- Add morphing transitions only when the view hierarchy changes with animation.
- Use `tabViewBottomAccessory` for persistent controls above tab bar.

## Core Guidelines
- Prefer native Liquid Glass APIs over custom blurs.
- Use `GlassEffectContainer` when multiple glass elements coexist.
- Apply `.glassEffect(...)` after layout and visual modifiers.
- Use `.interactive()` for elements that respond to touch/pointer.
- Keep shapes consistent across related elements for a cohesive look.
- Gate with `#available(iOS 26, *)` and provide a non-glass fallback.
- Glass cannot sample other glass — use containers, never stack glass layers.
- Text on glass receives automatic vibrant treatment with contrast adjustment.
- Do NOT add custom shadows or borders — the system handles edge effects.

## Review Checklist
- **Availability**: `#available(iOS 26, *)` present with fallback UI.
- **Variants**: Only `.regular`, `.clear`, `.identity` used (NOT `.prominent`).
- **Composition**: Multiple glass views wrapped in `GlassEffectContainer`.
- **Modifier order**: `glassEffect` applied after layout/appearance modifiers.
- **Interactivity**: `interactive()` only where user interaction exists.
- **Transitions**: `glassEffectID` used with `@Namespace` for morphing.
- **Unions**: Related controls grouped with `glassEffectUnion`.
- **Consistency**: Shapes, tinting, and spacing align across the feature.
- **No manual shadows/borders**: Trust the system edge effects.
- **Accessibility**: System auto-adapts for Reduce Transparency; use `.identity` as manual fallback.

## Implementation Checklist
- Define target elements and desired glass variant (`.regular` for most, `.clear` for media overlays).
- Wrap grouped glass elements in `GlassEffectContainer` and tune spacing.
- Use `.glassEffect(.regular.tint(...).interactive(), in: .rect(cornerRadius: ...))` as needed.
- Use `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)` for actions.
- Use `glassEffectUnion(id:namespace:)` to merge related controls into one glass shape.
- Add morphing transitions with `glassEffectID` when hierarchy changes.
- Provide fallback materials and visuals for earlier iOS versions.
- Use `tabViewBottomAccessory` for persistent floating controls (like Now Playing).

## Quick Snippets

### Basic Glass with Fallback
```swift
if #available(iOS 26, *) {
    Text("Hello")
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    Text("Hello")
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```

### Container with Multiple Elements
```swift
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Image(systemName: "scribble.variable")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
    }
}
```

### Glass Buttons
```swift
Button("Confirm") { }
    .buttonStyle(.glassProminent)

Button("Cancel") { }
    .buttonStyle(.glass)
```

### Union — Merge Controls into One Glass Shape
```swift
@Namespace private var ns

GlassEffectContainer(spacing: 20) {
    HStack(spacing: 20) {
        Button("+") { }.glassEffect()
            .glassEffectUnion(id: "zoom", namespace: ns)
        Button("-") { }.glassEffect()
            .glassEffectUnion(id: "zoom", namespace: ns)
    }
}
```

### Morphing Transition
```swift
@Namespace private var ns
@State private var expanded = false

GlassEffectContainer {
    if expanded {
        ExpandedToolbar()
            .glassEffect()
            .glassEffectID("toolbar", in: ns)
    } else {
        CompactFAB()
            .glassEffect()
            .glassEffectID("toolbar", in: ns)
    }
}
.onTapGesture {
    withAnimation(.bouncy) { expanded.toggle() }
}
```

### Tab Bar Bottom Accessory (iOS 26)
```swift
TabView {
    HomeView().tabItem { Label("Home", systemImage: "house") }
}
.tabViewBottomAccessory {
    NowPlayingBar()  // Gets glass capsule automatically
}
```

### Sheet Morphing from Toolbar (iOS 26)
```swift
@Namespace private var ns

.toolbar {
    ToolbarItem {
        Button("Add") { showSheet = true }
            .matchedTransitionSource(id: "add", in: ns)
    }
}
.sheet(isPresented: $showSheet) {
    AddItemView()
        .navigationTransition(.zoom(sourceID: "add", in: ns))
}
```

### Sidebar Background Extension
```swift
NavigationSplitView {
    SidebarContent()
} detail: {
    DetailContent()
        .background {
            Image("hero").backgroundExtensionEffect()
        }
}
```

### Scroll Extension Under Sidebar
```swift
ScrollView(.horizontal) {
    // Content extends under sidebar
}
.scrollExtensionMode(.underSidebar)
```

### Accessibility-Aware Glass
```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

// iOS 26 auto-adapts: increases frosting, adds stark colors/borders
// Manual override only when needed:
.glassEffect(reduceTransparency ? .identity : .regular)
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using `.prominent` as Glass variant | Use `.regular` or `.clear`. `.glassProminent` is button-style only |
| Glass on list items/content | Glass is navigation layer only |
| Stacking glass layers | Use `GlassEffectContainer`, never nest glass |
| Custom shadows/borders on glass | Trust system edge effects |
| Missing `#available` guard | Always gate with `#available(iOS 26, *)` |
| Manual Reduce Transparency handling | System auto-adapts; `.identity` for full disable |
| `presentationBackground()` on sheets | System applies glass automatically in iOS 26 |

## Resources
- Reference guide: `references/liquid-glass.md`
- [Apple: Applying Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [WWDC25 Session 219: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC25 Session 323: Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
- [LiquidGlassReference (Community)](https://github.com/conorluddy/LiquidGlassReference)
- [Donny Wals: Designing custom UI with Liquid Glass](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/)

### Source: `swiftui-ux-review`

# SwiftUI UI/UX Review Skill

Comprehensive review and analysis of SwiftUI interfaces for iOS 17/18/26+ with focus on **animations**, Liquid Glass design language, Apple Human Interface Guidelines (HIG), accessibility standards, and modern UI/UX patterns.

## When to Use This Skill

- **Reviewing animations** - springs, keyframes, transitions, micro-interactions, liquid glass morphing
- Reviewing SwiftUI code for UI/UX best practices
- Auditing compliance with iOS 26 Liquid Glass design language
- Checking accessibility implementation (VoiceOver, Dynamic Type, Reduce Motion)
- Analyzing navigation, onboarding, tabs, sheets, and modal patterns
- Identifying common UI/UX mistakes and anti-patterns
- Evaluating animation performance and timing
- Providing actionable recommendations for interface improvements

## Review Process

### Step 1: Gather Context

Before reviewing, collect information about:
1. **Target iOS version** - iOS 17+ for PhaseAnimator/KeyframeAnimator; iOS 26+ for Liquid Glass
2. **App purpose** - Different apps require different animation intensities
3. **User demographics** - Accessibility requirements vary by audience
4. **Existing design system** - Check for design tokens and theming

### Step 2: Structural Analysis

Analyze the SwiftUI code structure for:

| Component | Check For |
|-----------|-----------|
| Navigation | NavigationStack usage, tab bar implementation, deep linking support |
| State Management | @State, @Binding, @Observable patterns, data flow |
| View Hierarchy | Proper component decomposition, reusability |
| Modifiers | Correct modifier ordering, accessibility modifiers |
| **Animations** | Spring parameters, timing, transitions, accessibility compliance |

### Step 3: Animation Review (NEW)

#### Animation Quality Checklist

| Aspect | Standard | Check For |
|--------|----------|-----------|
| **Timing** | 100-500ms | Animations not too fast or slow |
| **Springs** | Used for interactive | `response`, `dampingFraction` appropriate |
| **Purpose** | Communicates change | Not gratuitous or distracting |
| **Performance** | No frame drops | `drawingGroup()` for complex views |
| **Accessibility** | Respects settings | Checks `accessibilityReduceMotion` |

#### Spring Animation Standards

**Recommended Springs:**
```swift
// Button press - quick, bouncy
.spring(response: 0.3, dampingFraction: 0.6)

// Modal presentation - smooth, natural
.spring(response: 0.5, dampingFraction: 0.8)

// Card expansion - elegant, controlled
.spring(response: 0.6, dampingFraction: 0.85)

// Subtle hover - minimal, fast
.spring(response: 0.2, dampingFraction: 0.9)
```

**iOS 17+ Presets:**
- `.bouncy` - High bounce, playful
- `.smooth` - No overshoot, professional
- `.snappy` - Quick response

**iOS 26+ New APIs (WWDC 2025):**
- `@Animatable` macro - Auto-synthesizes `Animatable` conformance for Shapes
- `@AnimatableIgnored` macro - Excludes properties from animation interpolation
- `.symbolEffect(.drawOn)` / `.symbolEffect(.drawOff)` - SF Symbols 7 stroke-based reveal/dismiss animations (supports `.wholeSymbol`, `.byLayer`, `.individually`)
- `.backgroundExtensionEffect()` - Blur extension beyond view bounds (for sidebars, inspectors)
- `tabViewBottomAccessory { }` - Persistent control above tab bar (gets glass capsule automatically)
- `ToolbarSpacer` - Control spacing between toolbar items
- `scrollExtensionMode(.underSidebar)` - Extend scroll content under sidebar
- Sheet morphing: `matchedTransitionSource(id:in:)` + `navigationTransition(.zoom(sourceID:in:))`
- Rich `TextEditor` with `AttributedString` binding and `onSelectionChange`
- Label spacing: `.labelIconToTitleSpacing`, `.labelReservedIconWidth`

#### Common Animation Issues

| Issue | Severity | Solution |
|-------|----------|----------|
| `.animation()` without value | High | Use `.animation(_:value:)` |
| Linear timing for UI | Medium | Use springs for natural feel |
| No `reduceMotion` check | High | Add `@Environment(\.accessibilityReduceMotion)` |
| Heavy views in keyframes | High | Use `drawingGroup()` |
| Multiple conflicting `withAnimation` | Medium | Consolidate into single block |
| Animation during scroll | Medium | Defer until scroll ends |

#### Transition Review

**Check transitions use:**
- `.asymmetric(insertion:removal:)` for directional animations
- `.combined(with:)` for multi-property transitions
- Appropriate timing that matches gesture direction

#### Micro-Interactions

**Verify:**
- Button press has visual feedback (scale, opacity)
- Haptic feedback matches action type (`.success`, `.error`, `.selection`)
- Feedback not excessive or annoying

### Step 4: Liquid Glass Compliance (iOS 26+)

**Glass Variants (IMPORTANT — only 3 exist):**

| Variant | Use Case |
|---------|----------|
| `.regular` | Standard navigation elements, toolbars, tabs |
| `.clear` | Subtle controls over media-rich backgrounds |
| `.identity` | No effect — for conditional toggling / accessibility |

**WARNING:** `.prominent` is NOT a glass variant. Use `.buttonStyle(.glassProminent)` for prominent buttons.

**Appropriate Uses:**
- Navigation bars and toolbars
- Tab bars and bottom accessories (use `tabViewBottomAccessory` for floating bars)
- Floating action buttons
- Sheets, popovers, and menus (system applies glass automatically in iOS 26)
- Context-sensitive controls
- `ToolbarSpacer` for grouping toolbar items

**Avoid Liquid Glass For:**
- Content layer (lists, tables, media)
- Full-screen backgrounds
- Scrollable content
- Stacked glass layers (glass cannot sample other glass)
- Custom shadows/borders (trust system edge effects)

**Glass Morphing Animations:**
- Use `GlassEffectContainer` for coordinated morphing
- Apply `glassEffectID(_:in:)` for morph coordination
- Use `glassEffectUnion(id:namespace:)` to merge related controls into one glass shape
- Use `.bouncy` animation for glass transitions
- Wrap state changes in `withAnimation(.bouncy)`
- Don't use `presentationBackground()` on sheets — system handles it

**New iOS 26 Layout APIs:**
- `tabViewBottomAccessory { }` — persistent control above tab bar (like Now Playing)
- `ToolbarSpacer` — control spacing between toolbar items
- `scrollExtensionMode(.underSidebar)` — extend scroll content under sidebar
- `backgroundExtensionEffect()` — extend/blur content behind sidebars
- Sheet morphing: `matchedTransitionSource(id:in:)` + `navigationTransition(.zoom(sourceID:in:))`

Check for proper `.glassEffect()` usage with `#available(iOS 26.0, *)` guards.

### Step 5: Pattern Validation

#### Onboarding Patterns
- **iOS 18+**: Prefer ScrollView with `scrollTargetBehavior(.viewAligned)` over TabView
- Use `@AppStorage` for tracking completion state
- Present using `.fullScreenCover` for immersive experience
- Include skip option and progress indicators
- **Animations**: Staggered entry with `.delay()`, parallax effects

#### Tab Navigation
- Each tab maintains its own NavigationStack
- State preserved when switching tabs
- Coordinator pattern for complex flows
- iOS 26: Tabs auto-shrink on scroll
- **Animations**: `matchedGeometryEffect` for tab indicator

#### Sheets and Modals
- Attach `.sheet` to outermost container view
- Use `presentationDetents` for height control (iOS 16+)
- `interactiveDismissDisabled()` when dismissal must be controlled
- Forms for settings/profiles, fullScreenCover for immersive content
- **Animations**: Spring presentation with `response: 0.5, dampingFraction: 0.8`

#### Loading States
- Use `.redacted(reason: .placeholder)` for skeleton views
- Model states with enum (loading, loaded, empty, error)
- ContentUnavailableView for empty states (iOS 17+)
- `.unredacted()` for fixed elements during loading
- **Animations**: Shimmer effect with repeating linear gradient

#### Counter/Numeric Displays
- Use `.contentTransition(.numericText())` for animated counters
- Combine with `.sensoryFeedback(.increase, trigger:)` for haptics

#### Permission Request Patterns (App Store Guideline 5.1.1)

**Critical:** Permission primers (custom alerts before iOS permission dialogs) must NOT have exit/dismiss buttons.

**Compliant Pattern:**
```swift
// OK: Primer with only "Continue" - user must proceed to iOS dialog
.alert("Camera Access", isPresented: $showPrimer) {
    Button("Continue") { requestCameraPermission() }
} message: {
    Text("We need camera access to scan documents.")
}
```

**Non-Compliant Pattern (App Store Rejection):**
```swift
// REJECTED: "Not Now" lets user skip the iOS permission dialog
.alert("Camera Access", isPresented: $showPrimer) {
    Button("Continue") { requestCameraPermission() }
    Button("Not Now", role: .cancel) { dismiss() }  // ← VIOLATION
} message: {
    Text("We need camera access to scan documents.")
}
```

**Best Practices:**
- If showing a primer, user MUST proceed to the actual iOS permission dialog
- No "Skip", "Not Now", "Later", or "Cancel" buttons on pre-permission primers
- After denial, you CAN show an alert with "Open Settings" + "Cancel"
- Consider skipping primers entirely - iOS dialogs show your Info.plist usage descriptions
- Request permissions contextually (when user tries to use the feature), not on app launch

**Applies to:** Camera, Microphone, Photos, Location, Contacts, Calendars, Speech Recognition, Health, Motion, Bluetooth, Local Network, Tracking (ATT)

### Step 6: Accessibility Audit

**Required Checks:**

| Modifier | Purpose |
|----------|---------|
| `.accessibilityLabel()` | Descriptive label for VoiceOver |
| `.accessibilityHint()` | Action context for users |
| `.accessibilityElement(children:)` | Group related elements |
| `.accessibilityHidden()` | Hide decorative elements |

**Dynamic Type:** Verify text scales with system settings. Avoid fixed font sizes.

**Reduce Transparency:** Check `@Environment(\.accessibilityReduceTransparency)` for Liquid Glass fallbacks.

**Reduce Motion:** Check `@Environment(\.accessibilityReduceMotion)` and disable/simplify animations.

**Color Contrast:** Use `.primary`, `.secondary` over hardcoded colors.

### Step 7: Generate Report

Structure findings as:

```markdown
## UI/UX Review Summary

### Strengths
- [List positive patterns found]

### Animation Issues
1. **[Issue Name]** - Severity: High/Medium/Low
   - Location: `FileName.swift:LineNumber`
   - Problem: [Description]
   - Recommendation: [Specific fix with code]

### UI/UX Issues
1. **[Issue Name]** - Severity: High/Medium/Low
   - Location: `FileName.swift:LineNumber`
   - Problem: [Description]
   - Recommendation: [Specific fix]

### Recommendations
- [Prioritized list of improvements]

### Code Examples
- [Before/after code snippets]
```

## Quick Reference: Common Issues

| Issue | Severity | Solution |
|-------|----------|----------|
| Permission primer with exit button | **Critical** | Remove "Not Now"/"Skip" - user must proceed to iOS dialog (Guideline 5.1.1) |
| Liquid Glass on content layer | High | Move to navigation layer only |
| Missing accessibility labels | High | Add `.accessibilityLabel()` to interactive elements |
| No `reduceMotion` check | High | Add environment check, simplify animations |
| `.animation()` without value | High | Use `.animation(_:value:)` |
| Fixed font sizes | Medium | Use system semantic fonts |
| Stacked glass layers | Medium | Reduce glass layers, add spacing |
| Linear animation for buttons | Medium | Use spring with `dampingFraction: 0.6-0.8` |
| No haptic feedback | Low | Add `.sensoryFeedback()` for important actions |
| TabView for iOS 18+ onboarding | Low | Migrate to ScrollView pattern |
| Sheet attached to button | Low | Move to container view |

## Animation API Quick Reference

### iOS 17+ Animators

```swift
// PhaseAnimator - Multi-step cycling
PhaseAnimator([Phase.a, .b, .c], trigger: value) { phase in
    Content().modifier(for: phase)
} animation: { phase in
    .spring(response: 0.3)
}

// KeyframeAnimator - Fine-grained control
.keyframeAnimator(initialValue: Values(), trigger: trigger) { content, value in
    content.scaleEffect(value.scale)
} keyframes: { _ in
    KeyframeTrack(\.scale) {
        SpringKeyframe(1.2, duration: 0.2)
        SpringKeyframe(1.0, duration: 0.3)
    }
}
```

### Transitions

```swift
// Combined transition
.transition(.move(edge: .bottom).combined(with: .opacity))

// Asymmetric
.transition(.asymmetric(
    insertion: .move(edge: .trailing),
    removal: .move(edge: .leading)
))

// iOS 17+
.transition(.blurReplace)
.transition(.push(from: .bottom))
```

### Haptic Feedback (iOS 17+)

```swift
.sensoryFeedback(.success, trigger: value)
.sensoryFeedback(.selection, trigger: selection)
.sensoryFeedback(.impact, trigger: collision)
```

## Design Tokens Reference

Recommended spacing scale:
- `xs`: 4pt, `sm`: 8pt, `md`: 16pt, `lg`: 24pt, `xl`: 32pt

Use semantic colors:
- `.primary`, `.secondary` for text
- `.background`, `.secondaryBackground` for surfaces
- System tints for interactive elements

## Additional Resources

### Reference Files

For detailed patterns and guidelines, consult:
- **`references/animation-guide.md`** - Comprehensive animation reference with springs, keyframes, transitions, micro-interactions, and performance optimization
- **`references/liquid-glass-guide.md`** - Complete iOS 26 Liquid Glass implementation guide with code examples
- **`references/ui-patterns.md`** - Detailed SwiftUI patterns for navigation, onboarding, forms, loading states
- **`references/accessibility-checklist.md`** - Complete VoiceOver, Dynamic Type, Reduce Motion audit checklist with testing procedures

### External Resources

**Apple Official:**
- [Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Animating views and transitions](https://developer.apple.com/tutorials/swiftui/animating-views-and-transitions)
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [WWDC23: Demystify SwiftUI performance](https://developer.apple.com/videos/play/wwdc2023/10160/)
- [WWDC18: Designing Fluid Interfaces](https://developer.apple.com/videos/play/wwdc2018/803/)
- [WWDC25: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)

**Animation Libraries:**
- [Pow](https://github.com/EmergeTools/Pow) - Delightful SwiftUI effects (Spray, Shake, Shine, Jump, Rise, Spin)
- [AnimatedTabBar](https://github.com/exyte/AnimatedTabBar) - Preset tab bar animations
- [open-swiftui-animations](https://github.com/amosgyamfi/open-swiftui-animations) - Loading, looping, spring examples
- [Hero](https://github.com/HeroTransitions/Hero) - Elegant transition library
- [FlowStack](https://github.com/velos/FlowStack) - Hero animations with NavigationStack API
- [SkeletonUI](https://github.com/CSolanaM/SkeletonUI) - Elegant skeleton loading

**Hero Transitions:**
- [swiftui-hero-animations](https://github.com/swiftui-lab/swiftui-hero-animations) - matchedGeometryEffect examples
- [swiftui-hero-animations-no-transitions](https://github.com/swiftui-lab/swiftui-hero-animations-no-transitions) - Morphing without transitions

**Liquid Glass & iOS 26:**
- [iOS-26-by-Examples](https://github.com/artemnovichkov/iOS-26-by-Examples) - Comprehensive iOS 26 feature examples
- [LiquidGlassReference](https://github.com/conorluddy/LiquidGlassReference) - Ultimate Swift/SwiftUI reference
- [LiquidGlassSwiftUI](https://github.com/mertozseven/LiquidGlassSwiftUI) - Sample Liquid Glass app

**Tutorials:**
- [SwiftUI Lab - PhaseAnimator](https://swiftui-lab.com/swiftui-animations-part7/)
- [AppCoda - KeyframeAnimator](https://www.appcoda.com/keyframeanimator/)
- [Hacking with Swift - Spring Animations](https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-spring-animation)
- [Design+Code - Phase Animator](https://designcode.io/swiftui-handbook-phase-animator/)
- [Jacob's Tech Tavern - Keyframe Animations](https://blog.jacobstechtavern.com/p/swiftui-keyframe-animations)

### Source: `swiftui_1667/layout`

# SwiftUI Layout & Containers

The layer between "stacks and spacers" and "it scrolls like butter with 100k rows" — Apple's
Layout protocol, container composition, and the lazy-stack rules from the WWDC26 deep dive.
View identity/data-flow questions route to `swiftui/data-flow`.

## When This Skill Activates

- "Make these buttons equal width" / measurement-dependent layout
- Building a reusable container (custom List/board/carousel) that should accept ForEach + sections
- Lazy stack jank, memory growth, scroll-position bugs, broken scroll targeting
- Programmatic scrolling, paging/snapping, scroll-linked effects
- GeometryReader causing layout loops or mangled sizing

## Custom Layout protocol (not GeometryReader)

Reach for a custom `Layout` whenever you must **measure subviews and feed the measurement back
into layout** — GeometryReader only measures its container and can't influence the engine.
Canonical case: equal-width buttons.

- `sizeThatFits`: propose `.unspecified` to read each subview's ideal size
  (`subviews.map { $0.sizeThatFits(.unspecified) }`); guard empty subviews;
  `replacingUnspecifiedDimensions()` for nil proposal dimensions.
- `placeSubviews`: never assume origin (0,0) — use `bounds.minX/midX` (non-zero origins are
  what make layouts composable); `place(at:anchor:proposal:)` with a proposal that may differ
  from the ideal size (that's how equal widths happen).
- **Respect spacing preferences**: `subviews[i].spacing.distance(to:along:)`, taking the larger
  of conflicting preferences — matching built-in containers. No hardcoded 8s.
- Per-subview data via `LayoutValueKey` (+ a `layoutValue` convenience modifier), read as
  `subview[Key.self]`.
- Cache only after Instruments shows layout cost — it's an optimization, not a requirement.
- **Switch layouts without killing identity**: `AnyLayout(HStackLayout())` ↔ custom layout with
  `.animation(_:value:)` — SwiftUI sees one changing view, so state survives and it animates.
- Don't build fallbacks into the layout — wrap alternatives in `ViewThatFits`.

## Grid decisions

| Need | Use |
|---|---|
| Static 2D with cross-row alignment | `Grid`/`GridRow` (+ `gridCellColumns` to span, `gridColumnAlignment` per column) |
| Scrollable, large content | `LazyVGrid`/`LazyHGrid` (only visible views load; one axis fixed up front) |
| "First arrangement that fits" | `ViewThatFits` |

## Custom containers (Demystify Containers)

Make containers that compose like `List` does:

- API shape: a trailing `@ViewBuilder var content: Content` — callers can then mix static
  views, `ForEach`, and conditionals.
- Iterate **resolved** children with `ForEach(subviews: content)`; need the whole collection
  (count/chunking)? `Group(subviews: content) { subviews in … }`.
- Internalize **declared vs resolved**: one declared ForEach resolves to N subviews; Group to
  its children; EmptyView to zero; `if` conditionally. Counting declared views is a bug.
- Sections are opt-in: `ForEach(sections: content)`, reading `section.header` /
  `section.content`; check `header.isEmpty` before rendering the slot.
- Per-child customization via container values: `extension ContainerValues { @Entry var … }`,
  set with a convenience modifier, read via `subview.containerValues`. Scoping model:
  **Environment flows down · Preferences flow up · container values reach only the direct
  container.** Setting one on a `Section` styles the whole section.

## Lazy stacks & scrolling performance (WWDC26 rules)

LazyVStack builds views only until the viewport fills; totals and offsets are **estimated**
from average placed-view size and corrected as you scroll. Everything below follows from that:

- **One subview per ForEach element, always.** An `if` inside a row (0-or-1 views) forces the
  stack to keep off-screen views + their `@State` alive to preserve indices — and environment
  changes then re-evaluate off-screen bodies. Filter at the data layer (`@Query` predicate);
  gate auth-type conditions *outside* the stack.
- **Never key logic off absolute scroll offset** in a lazy stack (`onScrollGeometryChange` sees
  estimates) — use `onScrollTargetVisibilityChange(threshold: 0.8)` for visibility triggers.
- **Set up in `init`, not `onAppear`** (`_model = State(initialValue:)`): body runs during
  prefetch; `onAppear` fires only on-screen, throwing prefetch work away and causing
  post-appearance size jumps. Start async loads in `init`/`task`.
- **Don't persist meaningful state in row `@State`** — off-screen views are eventually
  released. Hoist (`@State var highlighted: Set<ID>` outside, `@Binding` down).
- `scrollTransition` transforms must stay inside the original frame (scale ✅; rotations
  escaping the frame make views vanish early).
- Don't drive layout from `onGeometryChange` height feedback (content shoves, targeting
  breaks) — that's the custom `Layout` case above.
- Nest `LazyHStack` inside `LazyVStack` freely (unscrolled rows stay unloaded) — but fix child
  heights (`lineLimit`, explicit frames) in the horizontal stacks.
- `pinnedViews: [.sectionHeaders]` pins headers; infinite scroll = trailing
  `ProgressView().onAppear { fetchNextPage() }` after the ForEach.

## The scroll API map

- Snapping/paging: `scrollTargetLayout()` + `scrollTargetBehavior(.viewAligned/.paging)`.
- Track/control position: `scrollPosition` binding; programmatic `ScrollPosition` +
  `scrollTo(id:)` — works for unloaded targets *if* IDs map to stable one-subview elements.
- Scroll-linked effects: `scrollTransition` (enter/leave viewport) and `visualEffect`
  (geometry without GeometryReader) — details in `design/animation-patterns`.
- Reactions: `onScrollGeometryChange` (fine outside lazy estimation),
  `onScrollVisibilityChange` (autoplay/analytics).
- Performance floor: list/scroll internals were rewritten (WWDC25) — macOS lists ~6× faster at
  100k+ rows, and lazy loading works in nested `ScrollView`+`LazyVStack`; profile with the
  SwiftUI instrument (`performance/swiftui-debugging`).

## Output Format

Layout review: `Symptom | Rule violated | Fix` — check the one-subview-per-element rule first
in any lazy-stack complaint; it explains most jank, memory growth, and targeting bugs.

## Common Mistakes

✅ `LazyVStack`/`LazyVGrid` inside `ScrollView` for long or unbounded content; `Grid` and `ViewThatFits` for adaptive layouts.
❌ Wrapping whole screens in `GeometryReader` to compute sizes the layout system already provides.

## References

- https://developer.apple.com/videos/play/wwdc2022/10056/ (Compose custom layouts)
- https://developer.apple.com/videos/play/wwdc2024/10146/ (Demystify SwiftUI containers)
- https://developer.apple.com/videos/play/wwdc2026/321/ (Dive into lazy stacks and scrolling)
- Related skills: `swiftui/data-flow` (identity/ForEach IDs), `performance/swiftui-debugging`, `design/animation-patterns` (scroll-linked effects)

### Source: `tuist-generation-doctor`

# Tuist Generation Doctor

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Use this skill to determine whether a Tuist-generated workspace problem is a
project configuration issue, a dependency wiring issue, or a Tuist bug.

## Triage Route

1. Classify the failure stage:
   - generation: `tuist generate` or `tuist install`
   - build: generated `.xcworkspace` exists but `xcodebuild` fails
   - runtime: app builds but crashes or behaves incorrectly
2. Capture the exact command, Tuist version, Xcode version, platform, scheme,
   and relevant manifest snippets.
3. Reproduce on the local project first. If the issue is broad or suspicious,
   retry with the latest Tuist release through `mise`.
4. Reduce to a minimal reproduction before filing or fixing a Tuist-level bug.

## Commands

```bash
tuist version
mise exec tuist@latest -- tuist install --path "$PROJECT_DIR"
mise exec tuist@latest -- tuist generate --no-open --path "$PROJECT_DIR"
```

For build-stage failures:

```bash
xcodebuild build \
  -workspace "$PROJECT_DIR"/*.xcworkspace \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=<available iPhone simulator>,OS=latest" \
  -derivedDataPath "$PROJECT_DIR/DerivedData"
```

For runtime-stage failures, launch the generated app:

```bash
xcrun simctl boot "<available simulator name or UDID>" 2>/dev/null || true
xcrun simctl install booted "$APP_PATH"
xcrun simctl launch --console-pty booted "$BUNDLE_ID"
```

## Common Causes

- Missing `tuist install` before generation.
- Source/resource globs that omit files or include Swift files as resources.
- Package product type mismatches: static vs dynamic frameworks/libraries.
- Missing SDK dependencies, entitlements, Info.plist values, or resource bundles.
- Objective-C categories stripped from static dependencies; verify `-ObjC` or
  targeted `-force_load`.
- Generated workspace drift after manifest edits; regenerate before judging.

## When It Looks Like A Tuist Bug

Clone Tuist only after you have a small reproduction:

```bash
TUIST_SRC="$(mktemp -d)"
git clone --depth 1 https://github.com/tuist/tuist.git "$TUIST_SRC"
cd "$TUIST_SRC"
swift build --product tuist --product ProjectDescription --replace-scm-with-registry
"$TUIST_SRC/.build/debug/tuist" generate --no-open --path "$REPRO_DIR"
```

If the reproduction fails on Tuist `main`, report:

- minimal reproduction archive
- failing command and output
- Tuist/Xcode/macOS versions
- whether generation, build, or runtime fails
- what local configuration causes were ruled out

## Output

Return the failure stage, root cause, exact fix or next command, and proof from
the latest generation/build/launch attempt.

### Source: `tuist-migration-planner`

# Tuist Migration Planner

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Use this skill to move an existing Xcode project to Tuist without losing build,
test, signing, or runtime behavior.

## Workflow

1. Baseline the current Xcode project.
2. Inventory targets, schemes, settings, scripts, resources, entitlements, and
   dependencies.
3. Create minimal Tuist manifests.
4. Generate, build, and launch.
5. Fix gaps iteratively and document every intentional divergence.

## Baseline First

Capture a known-good command before writing manifests:

```bash
xcodebuild build \
  -project App.xcodeproj \
  -scheme App \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=<available iPhone simulator>,OS=latest" \
  -derivedDataPath DerivedDataBaseline
```

Record the scheme, configuration, deployment targets, bundle identifiers,
Info.plist paths, entitlements, build scripts, and package graph.

## Create Manifests

- `Tuist.swift`: keep generation options explicit.
- `Project.swift`: model targets, sources, resources, scripts, settings, and
  dependencies.
- `Tuist/Package.swift`: declare external Swift packages and product mappings.
- `.xcconfig`: move large or shared build settings out of manifests when useful.

Keep the first generated graph close to the original project. Defer cleanup
until the generated workspace builds and launches.

## Generate And Build

```bash
tuist install
tuist generate --no-open
xcodebuild build \
  -workspace App.xcworkspace \
  -scheme App \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=<available iPhone simulator>,OS=latest" \
  -derivedDataPath DerivedDataTuist
```

## Validate Runtime

```bash
xcrun simctl boot "<available simulator name or UDID>" 2>/dev/null || true
xcrun simctl install booted DerivedDataTuist/Build/Products/Debug-iphonesimulator/App.app
xcrun simctl launch --console-pty booted com.example.app
```

Build success is not enough; launch catches missing resources, entitlements,
bundle identifiers, embedded frameworks, and ObjC category issues.

## Common Fixes

- Add missing Apple SDK frameworks with explicit SDK dependencies.
- Move generated Swift files into sources and generated asset/resource outputs
  into resources.
- Use package resource declarations for `Bundle.module` assets.
- Match package product types to the original linker behavior.
- Preserve signing, app groups, associated domains, and hardened runtime
  settings for app and extension targets.
- Keep build scripts ordered and declare inputs/outputs where possible.

## Output

Return the migration status, files changed, unresolved parity gaps, and the
exact baseline and generated validation commands with results.

### Source: `tuist-workspace-navigator`

# Tuist Workspace Navigator

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Use this skill for day-to-day development in projects where Tuist owns the
Xcode workspace.

## Defaults

- Run generation non-interactively:
  ```bash
  tuist generate --no-open
  ```
- Build and test with `xcodebuild` against the generated workspace.
- Regenerate after manifest, dependency, target graph, or resource layout
  changes.
- Run `tuist install` before generation when package dependencies changed.

## Focused Generation

Prefer smaller generated graphs when working on one feature or target:

```bash
tuist generate AppFeature AppFeatureTests --no-open
tuist generate tag:feature:payments --no-open
```

Use target tags consistently for teams, layers, and features so agents can
scope generation and testing without guessing target names.

## Manifest Guidance

- Prefer file-system-synchronized buildable folders when the project uses them;
  keep paths aligned with the real source tree.
- Do not overlap broad source/resource globs with buildable folders.
- Keep build configurations aligned between local targets and external
  dependencies.
- Treat `.intentdefinition` as source and avoid double-including localization
  files such as `.xcstrings`, `.strings`, and `.stringsdict`.
- Keep package product type overrides deliberate; making every dependency
  dynamic can hide linker problems and hurt launch time.

## Build

```bash
xcodebuild build \
  -workspace App.xcworkspace \
  -scheme App \
  -destination "platform=iOS Simulator,name=<available iPhone simulator>,OS=latest"
```

## Test

Prefer narrow `xcodebuild test` selectors for iteration:

```bash
xcodebuild test \
  -workspace App.xcworkspace \
  -scheme AppTests \
  -only-testing AppTests/MySuite/testExample
```

If a narrow selector runs zero tests, broaden to the suite or target and report
that the selector did not match.

## Troubleshooting

- Missing products: run `tuist install`, then regenerate.
- Type not found: check excluded source folders and generated files.
- Resource not found at runtime: inspect resource globs and package resources.
- Undefined symbols: verify SDK dependencies and product type overrides.
- Objective-C category crash: add `-ObjC` or targeted `-force_load` where the
  consuming target needs it.

Report the generated workspace path, scheme, command, and final build/test
result.

### Source: `visionos/spatial-design`

# Spatial Design (visionOS)

The design rules that make a visionOS app comfortable instead of exhausting — distilled from
Apple's spatial-design sessions (WWDC23–26). Widget-specific rules live in `visionos/widgets`;
custom immersive-environment production and budgets live in `immersive-environments.md`.

## When This Skill Activates

- Designing or reviewing a visionOS app, window, volume, or immersive space
- "Users say it's tiring / uncomfortable / hard to hit controls"
- Porting an iPad app and deciding what should become spatial
- Adding hover effects, custom gestures, environments, or spatial audio
- Choosing a video experience format (spatial, 180°, 360°, wide-FOV, Apple Immersive)

## The prime directive: find the key moment

Don't window a 2D app. Identify the one thing only possible on visionOS — the "key moment" —
and build around it. Immersion has three approaches, and full immersion is not mandatory:
full environments · integration with real surroundings (scene sensing) · meaningful audio.

## Layout & ergonomics

- **Wide beats tall** — layouts match the human field of view; turning the head left/right is
  easier than up/down. Center = primary content; edges = secondary, infrequent actions.
- Default placement sits along the natural line of sight, a bit **further than arm's reach**;
  extended reading goes farther out, centered and slightly below eye line.
- **Design in points, not meters** — dynamic scale keeps windows legible at any distance
  (they scale up as they move away). Never fixed scale for UI; keep custom UI facing the viewer.
- **Depth is hierarchy, used sparingly** — "prefer subtle depth" (a modal pushes its parent
  back). Keep text flat; 3D text is hard to read at an angle.
- **Glass, never solid** window backgrounds — solid colors block the world, don't adapt to
  lighting, and "can feel constricting." Elements on glass use vibrancy + white text/symbols;
  system colors over custom (they're calibrated for legibility). Brand color goes in
  backgrounds or whole buttons, not glyphs.
- Typography runs **heavier than iOS**: body = medium (vs regular), titles = bold (vs
  semibold), slightly increased tracking. Avoid small/lightweight custom fonts.
- Component specs: vertical tab bar fixed left, **≤6 items**, expands on gaze · ornaments
  overlap the window's bottom edge **by 20pt**, borderless buttons inside · sheets appear
  centered at the parent's Z while the parent dims and pushes back · nested corners concentric
  (outer radius = inner + padding).
- SwiftUI spatial layout: stacks default to `.back` depth alignment — switch to `.front` when
  content should read toward the viewer; `rotation3DLayout` (not `rotation3DEffect`) when
  rotation must affect layout; `SpatialContainer`/`spatialOverlay` for shared 3D space;
  `scaledToFit3D()` for models.

## Input: eyes target, hands confirm

- **Every interactive element gets ≥60pt of total target area** (≈2.5°, ~4.4cm at 1m) — the
  element can be smaller if surrounding spacing makes up the difference. Standard buttons:
  44pt + ≥8pt clearance; stacked buttons ≥16pt apart; list rows 4pt padding so hover
  effects don't overlap.
- Keep interactive content **at one depth** — frequent focus-depth changes cause eye strain.
- Eye-target shapes: circles, pills, rounded rectangles; no sharp edges or thick outlines;
  center text/glyphs with generous padding.
- **Every interactive element needs a hover effect — and only interactive elements get one**
  (never read-only data). Hover runs out-of-process: gaze stays private until a gesture.
- Hover rules (WWDC24/25): keep it subtle (a 5% scale is the reference); short delays prevent
  flicker (reveal effects: ~0.8s in / 0.2s out); effects start from a visible element — no
  invisible hotspots; high-traffic controls (toolbars, table cells) use ONLY the standard
  highlight; keep an anchoring element static; respect Reduce Motion (swap for cross-fade).
- Standard gesture language first (pinch = tap, pinch-drag = scroll, two-hand zoom/rotate).
  Custom gestures must be explainable, repeatable without fatigue, distinct from system
  gestures, and false-positive-tested; map them to real-world actions.
- Prefer **interaction at a distance** (eyes target, hands rest in lap) for long sessions;
  direct touch is for up-close manipulation — compensate for missing tactility (raise buttons,
  brighten as the finger approaches, snap state + spatial sound on contact).
- Look-to-scroll only in reading/browsing surfaces, never scan-and-pick lists; auto-hiding
  controls should persist while looked at.

## Motion & visual comfort (the failure modes)

- **Depth cues must agree** — size, blur, occlusion, shadow, texture density. Conflicts cause
  double vision and fatigue. Beware repeating patterns (eyes lock onto different repeats).
- **Vection**: large moving content that fills the view reads as self-motion → discomfort.
  Make big moving content semitransparent so passthrough anchors the viewer.
- **Avoid oscillations around 0.2 Hz** (one cycle per 5s); if unavoidable, low amplitude +
  semitransparency, and honor Reduce Motion with an oscillation-free alternative.
- **No head-locked content**; if unavoidable: small, central, far — or lazy-follow.
- Camera motion inside windows: keep the content horizon level with the real horizon; slow,
  predictable focus of expansion inside the field of view; never fast pure rotations — cut
  with a quick fade instead. Avoid close-range fly-bys.
- Moving the user or the scene: fade out during motion, fade back when settled. Design
  stationary-first — the system fades immersive content when people move.
- Eyes rotate most comfortably downward and left/right; upward/diagonal fixation is for brief
  interactions only. Slow dark→bright transitions (allow adaptation).

## Spatial sound as a design material

- Two layers: **point-source emitters** (positioned, room-matched reverb is automatic) +
  **looping ambient surround beds**. Even a windowed app may fill the room with a soundscape.
- Randomize repeats — pitch, amplitude, sample choice, position, timing. Nothing loops
  audibly from the same spot.
- Mix with distance: a few dB down AND pushed farther away = background.
- Use direction to steer attention (footsteps from the left before an entrance); attach
  multiple emitters to characters (feet omnidirectional, mouth directional).
- UI sounds: subtle — heard constantly. Match character/timing to the visual transitions.

## Interactive experiences (from Encounter Dinosaurs)

Adapt to the real room (portal up to 4m across in big rooms; set-distance + dimmed passthrough
in tiny ones) · open small and welcoming, onboard that content reacts to people · use head
position for eye contact (proximity signals interactivity; averted attention signals not) ·
consistent interaction rules — inconsistency shatters immersion · pace emotion with low-relief
breaks (nonstop interaction physically exhausts) · gentle in-world boundaries over hard
failures · accessibility is spatial too: VoiceOver, Dwell, captions, audio descriptions,
Dynamic Type.

## Video format decision guide

| You want | Use |
|---|---|
| Flat storytelling | 2D/3D/spatial video, windowed or docked (3D needs expanded) |
| "Being there," forward-facing | Stereo 180° (half-equirectangular) |
| Look-anywhere | 360° (equirectangular 2:1, typically mono) |
| Action-cam POV | Wide-FOV APMP (120–180°, parametric lens projection) |
| Premium cinematic immersion | Apple Immersive Video (8160×7200/eye @ 90fps, up to 210°×180°) |

Comfort rule: immersive playback puts the head where the camera was — high-motion scenes
auto-reduce immersion (QuickLook/AVKit/RealityKit); encode stereo as MV-HEVC, never
side-by-side. APMP formats never play inline.

## Scene behavior defaults

Prefer scene restoration (windows come back where placed); disable only for transient/welcome
windows (`restorationBehavior(.disabled)`, `defaultLaunchBehavior(.suppressed)`). Adapt
volumes to walls/tables via surface snapping info (authorization required). Handle Digital
Crown recentering (`onWorldRecenter`). Progressive immersion with an aspect ratio is a comfort
lever for vertical/high-motion content.

## Output Format

Spatial design review:

```
Area | Finding | Comfort/ergonomic rule violated | Fix
```

ordered: comfort violations (motion/depth/head-lock) first — they end sessions; then input
targets; then layout polish. Route environment production to `immersive-environments.md`,
widgets to `visionos/widgets`.

## References

- https://developer.apple.com/videos/play/wwdc2023/10072/ (Principles of spatial design)
- https://developer.apple.com/videos/play/wwdc2023/10076/ (Spatial user interfaces)
- https://developer.apple.com/videos/play/wwdc2023/10073/ (Spatial input)
- https://developer.apple.com/videos/play/wwdc2023/10078/ (Vision and motion)
- https://developer.apple.com/videos/play/wwdc2024/10086/ (Design great visionOS apps)
- https://developer.apple.com/videos/play/wwdc2025/303/ (Hover interactions)
- https://developer.apple.com/videos/play/wwdc2025/304/ (Video experiences)
- https://developer.apple.com/design/human-interface-guidelines/designing-for-visionos
- Related: `visionos/widgets`, `design/animation-patterns`
