# Integrated Reference Bundle 02

Combines 13 related source skills from `design-ux-accessibility` into one navigable reference file.

## Source map

- `design/animation-patterns/SKILL.reference.md`
- `design/game-feel/SKILL.reference.md`
- `design/liquid-glass/SKILL.reference.md`
- `design/sf-symbols/SKILL.reference.md`
- `design/typography/SKILL.reference.md`
- `design/ui-prototyping/SKILL.reference.md`
- `design/ux-writing/SKILL.reference.md`
- `generators/accessibility-generator/SKILL.reference.md`
- `generators/quick-win-session/SKILL.reference.md`
- `ios/accessibility-audit/SKILL.reference.md`
- `ios/ui-review/SKILL.reference.md`
- `ios-liquid-glass-designer/SKILL.reference.md`
- `karpathy-guidelines/SKILL.reference.md`

## Integrated guidance

### Source: `design/animation-patterns`

# Animation Patterns

Correct API shapes and patterns for SwiftUI animations. Prevents the most common mistakes: mixed spring parameter generations, wrong PhaseAnimator/KeyframeAnimator closure signatures, and using matchedGeometryEffect where matchedTransitionSource is needed.

## When This Skill Activates

Use this skill when the user:
- Asks to add, fix, or review **animation** code
- Mentions **spring**, **bounce**, or **snappy** animations
- Wants **view transitions** (insertion/removal, hero, zoom)
- Asks about **PhaseAnimator** or **KeyframeAnimator**
- Wants **SF Symbol effects** (bounce, pulse, wiggle, breathe)
- Mentions **matchedGeometryEffect** or **matchedTransitionSource**
- Asks about **reduce motion** / animation accessibility
- Wants to sequence or chain animations
- Mentions **withAnimation**, **animation completions**, or **Transaction**
- Wants **scroll-driven effects** (parallax, carousels, `scrollTransition`, `visualEffect`)
- Mentions **MeshGradient**, **TextRenderer**, or **Metal shader effects** (`colorEffect`, `distortionEffect`, `layerEffect`)

## Decision Tree

Choose the right reference file based on what the user needs:

```
What are you animating?
│
├─ A state change (opacity, position, color)
│  └─ → core-animations.md
│     ├─ withAnimation { } — explicit animation
│     ├─ .animation(_:value:) — implicit animation
│     └─ Spring configuration — .spring, .bouncy, .snappy, .smooth
│
├─ A multi-step / sequenced animation
│  └─ → phase-keyframe-animators.md (PhaseAnimator)
│     └─ Cycles through discrete phases automatically or on trigger
│
├─ A complex multi-property animation (scale + rotation + offset)
│  └─ → phase-keyframe-animators.md (KeyframeAnimator)
│     └─ Timeline-based keyframes with per-property tracks
│
├─ A view appearing / disappearing
│  └─ → transitions.md
│     ├─ .transition() — insertion/removal
│     ├─ .contentTransition() — text/symbol changes
│     └─ .asymmetric() — different in/out
│
├─ A hero / zoom navigation transition
│  └─ → transitions.md (matchedTransitionSource section)
│     ├─ iOS 18+: matchedTransitionSource + .navigationTransition(.zoom)
│     ├─ UIKit: preferredTransition = .zoom (capture stable IDs, never views)
│     └─ iOS 14+: matchedGeometryEffect (NOT for NavigationStack)
│
├─ A UIKit view driven by SwiftUI state or gestures
│  └─ → transitions.md (Bridging UIKit and SwiftUI Animations)
│     └─ UIView.animate(.spring(...)) / context.animate in updateUIView
│
├─ An SF Symbol animation
│  └─ → symbol-effects.md
│     └─ .symbolEffect(.bounce), .pulse, .wiggle, .breathe, .rotate
│
├─ A scroll-driven, geometry-driven, or shader effect
│  └─ → visual-effects.md
│     ├─ .scrollTransition — carousel scale/parallax/caption fades
│     ├─ .visualEffect — position-based effects without GeometryReader
│     ├─ MeshGradient — animatable multi-point gradients
│     ├─ TextRenderer — per-line / per-glyph text animation
│     └─ ShaderLibrary + .colorEffect / .distortionEffect / .layerEffect
│
└─ Spring physics / timing configuration
   └─ → core-animations.md (Spring Configurations section)
```

## API Availability

| API | Minimum Version | Reference |
|-----|----------------|-----------|
| `withAnimation` | iOS 13 | core-animations.md |
| `.animation(_:value:)` | iOS 13 | core-animations.md |
| `.spring(response:dampingFraction:)` | iOS 13 | core-animations.md |
| `.matchedGeometryEffect` | iOS 14 | transitions.md |
| `.transition(.push(from:))` | iOS 16 | transitions.md |
| `.contentTransition(.numericText())` | iOS 16 | transitions.md |
| `PhaseAnimator` | iOS 17 | phase-keyframe-animators.md |
| `KeyframeAnimator` | iOS 17 | phase-keyframe-animators.md |
| `.spring(duration:bounce:)` | iOS 17 | core-animations.md |
| Spring presets (`.bouncy`, `.snappy`, `.smooth`) | iOS 17 | core-animations.md |
| `withAnimation(_:completionCriteria:_:completion:)` | iOS 17 | core-animations.md |
| `.symbolEffect()` | iOS 17 | symbol-effects.md |
| `.transition(.blurReplace)` | iOS 17 | transitions.md |
| `.contentTransition(.symbolEffect(.replace))` | iOS 17 | transitions.md |
| `Transition` protocol / `TransitionPhase` | iOS 17 | transitions.md |
| `TransactionKey`, scoped `.animation` / `.transaction` variants | iOS 17 | core-animations.md |
| `KeyframeTimeline`, `.mapCameraKeyframeAnimator` | iOS 17 | phase-keyframe-animators.md |
| `.scrollTransition`, `.visualEffect` | iOS 17 | visual-effects.md |
| Shaders: `.colorEffect` / `.distortionEffect` / `.layerEffect` | iOS 17 | visual-effects.md |
| `MeshGradient` | iOS 18 | visual-effects.md |
| `TextRenderer` / `TextAttribute` | iOS 18 | visual-effects.md |
| `.matchedTransitionSource` | iOS 18 | transitions.md |
| `.navigationTransition(.zoom)` — push, sheet, fullScreenCover | iOS 18 | transitions.md |
| `UIViewController.preferredTransition = .zoom` | iOS 18 | transitions.md |
| `UIView.animate(_: Animation)` / `context.animate` | iOS 18 | transitions.md |

## Top 5 Mistakes — Quick Reference

| # | Mistake | Fix | Details |
|---|---------|-----|---------|
| 1 | `spring(response:bounce:)` — mixing parameter generations | Use either `spring(response:dampingFraction:)` (iOS 13) or `spring(duration:bounce:)` (iOS 17) | core-animations.md |
| 2 | `.animation(.spring())` without `value:` parameter | Always pass `value:` — the no-value variant is deprecated (iOS 15) | core-animations.md |
| 3 | Wrong PhaseAnimator closure signature | `PhaseAnimator(phases) { content, phase in }` — not `{ phase in }` | phase-keyframe-animators.md |
| 4 | Using `matchedGeometryEffect` for NavigationStack transitions | Use `matchedTransitionSource` + `.navigationTransition(.zoom)` on iOS 18+ | transitions.md |
| 5 | Using `withAnimation` for SF Symbol effects | Use `.symbolEffect()` modifier instead | symbol-effects.md |

## Review Checklist

When reviewing animation code, verify:

- [ ] **Reduce motion** — animations respect `AccessibilityMotionEffect` or `UIAccessibility.isReduceMotionEnabled`; provide non-motion alternatives
- [ ] **Duration limits** — no animation exceeds ~0.5s for UI feedback; longer only for decorative/ambient effects
- [ ] **Spring vs linear** — springs for interactive/physical motion; linear/easeInOut only for opacity fades or progress indicators
- [ ] **No deprecated APIs** — `.animation(.spring())` without `value:` is deprecated; `.animation(nil)` is replaced by `withTransaction`
- [ ] **Correct spring generation** — parameter names match the same API generation (never mix `response` with `bounce`)
- [ ] **Completion handlers** — using `withAnimation(_:completionCriteria:_:completion:)` (iOS 17+), not inventing `.onAnimationCompleted`
- [ ] **Transition scope** — `.transition()` only affects views inside `if`/`switch` controlled by state; not for views that are always present
- [ ] **Per-frame closures stay cheap** — KeyframeAnimator `content` closures, `visualEffect` closures, `TextRenderer.draw`, and `Animatable` view bodies run every frame; no allocation, formatting, or layout math inside

## Reference Files

| File | Content |
|------|---------|
| [core-animations.md](core-animations.md) | withAnimation, springs, completions, transactions + TransactionKey, timing curves, Animatable mechanics, fluid-interface principles (momentum projection, rubber-banding, hysteresis) |
| [phase-keyframe-animators.md](phase-keyframe-animators.md) | PhaseAnimator, KeyframeAnimator, KeyframeTimeline, MapKit camera keyframes, custom animations |
| [transitions.md](transitions.md) | View transitions, custom Transition protocol, matched geometry, navigation/zoom transitions (SwiftUI + UIKit), interruptibility, UIKit↔SwiftUI bridging, gesture-driven springs |
| [symbol-effects.md](symbol-effects.md) | SF Symbol effects, accessibility |
| [visual-effects.md](visual-effects.md) | scrollTransition, visualEffect, MeshGradient, TextRenderer, shader effects (colorEffect/distortionEffect/layerEffect), effect pipelines, semantic alignment guides |

### Source: `design/game-feel`

# Game Feel (Juice)

Makes an app's meaningful moments *land* — through coordinated motion, haptics, and sound. Animation technique lives in `design/animation-patterns`; confetti/badge generation lives in `generators/milestone-celebration`. This skill is the **discipline layer**: which events deserve feedback, on which channels, and how to verify nothing important is silent.

## When This Skill Activates

Use this skill when the user:
- Says the app feels **flat**, **lifeless**, or "lacks juice/polish/delight"
- Wants **celebrations** designed (winners, streaks, reveals, score changes)
- Asks to design or review **haptics** (vocabulary, Core Haptics, `.sensoryFeedback`)
- Asks about **sound effects**, buzzers, countdown ticks, or fanfares
- Wants a **feedback audit** — do the right events fire the right channels?
- Is building a **party/group game** where the phone is shared, passed, or watched at a distance

## Core Principles

### 1. Channels have different reach — match the channel to the audience

| Channel | Who perceives it |
|---------|------------------|
| Haptics | Only the person **holding** the device |
| Screen motion | Whoever is **looking** at the screen |
| Audio | The whole **room** |
| Torch / flash | The whole room, even in noise |

A single-user utility can lean on haptics. A shared-phone or room-facing app (party games, kitchen timers, presentations) **must** put its signature moments on a room-scale channel. The most common juice failure: all feedback is haptic, and the phone is lying on a table.

### 2. Feedback scales with rarity

Tick < action confirmed < success < round complete < **winner**. If the rarest event (winning) fires the same pattern as a routine one (round end), the app has no climax. Reserve the biggest pattern, the confetti burst, and the fanfare for the rarest event.

### 3. Escalation must agree across channels

If the timer's ring turns amber at 10s and red at 5s, the haptic tier and any audio tick must escalate at the *same* thresholds. Cross-channel disagreement reads as broken, not layered.

### 4. Single-owner rule

Exactly **one** code layer fires feedback for a given event. When an engine *and* a view-store both react to "music stopped", the user gets a double-buzz. Decide the owner (usually the layer closest to the state machine) and make the other layer silent.

### 5. Juice amplifies meaning — it never decorates

Every effect must be attached to an event the user cares about. Ambient/always-on effects (background particles, looping glows) are *texture*, not feedback — keep them static or slow, and never let them compete with event feedback.

### 6. Every channel needs an accessibility story

- Motion → gate large-scale motion on Reduce Motion, with a static equivalent
- Haptics → user-facing toggle (the system provides no global haptics setting for Core Haptics)
- Sound → mute toggle independent of system volume; a deliberate, documented silent-switch policy

## Decision Tree

```
What do you need?
│
├─ Which events should have feedback, and on which channels?
│  └─ → feedback-audit.md (event×channel matrix + three-lens audit)
│
├─ Design or review haptics (vocabulary, service architecture, APIs)
│  └─ → haptic-design.md
│
├─ Add a sound-effect layer (assets, latency, AVAudioSession coexistence)
│  └─ → sound-design.md
│
├─ HOW to animate a celebration/transition you've already decided on
│  └─ → design/animation-patterns (springs, transitions, symbol effects)
│
├─ Generate confetti / badge / milestone UI code
│  └─ → generators/milestone-celebration
│
└─ Animated SF Symbols for feedback moments
   └─ → design/sf-symbols (preset vocabulary)
```

## Review Checklist

When reviewing an app's game feel, verify:

- [ ] **Signature moments hit ≥2 channels** (e.g. winner = motion + haptic + sound)
- [ ] **Room-facing events use a room-scale channel** (audio, display-size motion, torch)
- [ ] **Rarity gradient exists** — the rarest event has visibly/audibly the biggest feedback
- [ ] **No channel disagreement** — escalation thresholds match across visual/haptic/audio
- [ ] **Single owner per event** — no double-fire from two layers
- [ ] **Score/number changes animate** (`.contentTransition(.numericText())`) — values never teleport
- [ ] **State changes transition** — no hard cuts between phases of a flow
- [ ] **Reduce Motion parity** — every gated effect has a static equivalent conveying the same information
- [ ] **User controls exist** — haptics toggle; mute toggle if there's an SFX layer
- [ ] **Loading/waiting states have anticipation** — determinate progress or a live effect, not a bare spinner at a climactic moment

## Reference Files

| File | Content |
|------|---------|
| [feedback-audit.md](feedback-audit.md) | Event×channel matrix method, three-lens audit (runnable subagent prompts), scoring rubric, output format |
| [haptic-design.md](haptic-design.md) | API decision table, semantic-vocabulary service architecture, pattern design rules, lifecycle, pitfalls |
| [sound-design.md](sound-design.md) | Minimal SFX kit, asset formats and latency, AVAudioSession coexistence with music, silent-switch policy, pitfalls |

## Related Skills

- `design/animation-patterns` — the *how* of every motion technique
- `design/sf-symbols` — symbol effect vocabulary for feedback glyphs
- `generators/milestone-celebration` — production confetti/badge/celebration code
- `ios/accessibility-audit` — Reduce Motion and assistive-tech verification

## References

- [Human Interface Guidelines — Playing haptics](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)
- [Human Interface Guidelines — Playing audio](https://developer.apple.com/design/human-interface-guidelines/playing-audio)
- [Human Interface Guidelines — Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Core Haptics](https://developer.apple.com/documentation/corehaptics)

### Source: `design/liquid-glass`

# Liquid Glass Design

Implement Apple's Liquid Glass design language across all Apple UI frameworks. Covers SwiftUI (`.glassEffect()`), AppKit (`NSGlassEffectView`), UIKit (`UIGlassEffect` + `UIVisualEffectView`), and WidgetKit (rendering modes, accented content, glass elements in widgets).

## When This Skill Activates

- User wants glass/blur effects on views
- User asks about Liquid Glass or modern Apple design
- User needs transparent, interactive UI elements
- User wants morphing transitions between views
- User is implementing glass effects in UIKit with `UIVisualEffectView`
- User needs `UIGlassEffect` or `UIGlassContainerEffect`
- User asks about scroll view edge effects in UIKit
- User wants Liquid Glass in widgets (WidgetKit)
- User needs to support accented rendering mode in widgets
- User asks about widget textures or mounting styles on visionOS

## Design Rules (WWDC25)

Liquid Glass is the material of the **navigation layer** — bars, toolbars, floating controls — never the content layer (tables, lists, rows in a scroll view).

| Rule | Detail |
|------|--------|
| **Never glass on glass** | Don't stack glass. Elements sitting ON glass don't get the material again — style them with fills and vibrancy. |
| **Two variants — never mix them** | **Regular** (default): works at any size, over anything, with adaptive legibility. **Clear**: only when ALL three hold — media-rich content underneath, a dimming layer is acceptable, and bold bright content sits above. Clear has no adaptive behaviors. One variant per interface. |
| **Tint only primary actions** | "When every element is tinted, nothing stands out." |
| **No steady-state intersections** | In resting layouts, content shouldn't sit half-under a glass element — reposition or scale the content instead. |
| **Strip decorated bars** | Remove customized bar backgrounds and borders; build hierarchy through layout and grouping, not decoration. Never group a symbol with a text label in one toolbar group. Action sheets spring from their source element. |

**Scroll edge effects** keep floating elements separated from scrolling content: soft (gradual fade — the iOS default) vs hard (denser, with a dividing line — mostly macOS). One per view edge, and they're not decorative — don't add one where no floating UI elements exist.

**Shape system** — let containers do the math:

| Shape | Radius | Use |
|-------|--------|-----|
| Fixed | Constant | Standalone elements |
| Capsule | Half the element height | Phone-scale controls — add extra margin from the screen edge |
| Concentric | Parent radius minus padding | Nested containers (inner radii auto-calculate); iPad/Mac elements concentric with the window edge |

**Accessibility comes free at the system level**: Reduced Motion decreases lensing and elastic effects; Increased Contrast renders glass elements black/white with a contrasting border. (Lensing is how glass appears — it materializes by modulating how it bends light, and adaptive shadows flip small elements light/dark for legibility over any content.)

## Quick Start (SwiftUI)

### Basic Glass Effect

```swift
import SwiftUI

Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect()  // Capsule shape by default
```

### Custom Shape

```swift
Text("Hello")
    .padding()
    .glassEffect(in: .rect(cornerRadius: 16))

// Available shapes:
// .capsule (default)
// .rect(cornerRadius: CGFloat)
// .rect(corner: .containerConcentric) — radius derived from the container, keeps nested shapes concentric
// .circle
```

### Interactive Glass

```swift
Button("Tap Me") {
    // action
}
.padding()
.glassEffect(.regular.interactive())
```

### Tinted Glass

```swift
Text("Important")
    .padding()
    .glassEffect(.regular.tint(.blue))
```

## Glass Configuration Options

| Option | Description | Example |
|--------|-------------|---------|
| `.regular` | Standard glass effect | `.glassEffect(.regular)` |
| `.tint(Color)` | Add color tint | `.glassEffect(.regular.tint(.orange))` |
| `.interactive()` | Scale, bounce, and shimmer on touch/hover | `.glassEffect(.regular.interactive())` |

## Multiple Glass Effects

### GlassEffectContainer

When using multiple glass elements, wrap them in `GlassEffectContainer` for:
- Better rendering performance
- Proper blending between effects
- Morphing transitions

This is correctness, not just performance: glass can not sample other glass, so nearby glass elements must share ONE container to render and blend correctly.

```swift
GlassEffectContainer(spacing: 40.0) {
    HStack(spacing: 40.0) {
        Image(systemName: "star.fill")
            .frame(width: 80, height: 80)
            .font(.system(size: 36))
            .glassEffect()

        Image(systemName: "heart.fill")
            .frame(width: 80, height: 80)
            .font(.system(size: 36))
            .glassEffect()
    }
}
```

**Spacing Parameter:**
- Controls when effects merge
- Smaller spacing = views must be closer to merge
- Larger spacing = effects merge at greater distances

### Uniting Glass Effects

Combine views into a single glass effect using `glassEffectUnion`:

```swift
@Namespace private var namespace

GlassEffectContainer(spacing: 20.0) {
    HStack(spacing: 20.0) {
        ForEach(items.indices, id: \.self) { index in
            Image(systemName: items[index])
                .frame(width: 60, height: 60)
                .glassEffect()
                .glassEffectUnion(
                    id: index < 2 ? "group1" : "group2",
                    namespace: namespace
                )
        }
    }
}
```

## Morphing Transitions

Create fluid morphing effects when views appear/disappear.

### Setup

1. Create a namespace
2. Assign glass effect IDs
3. Use animations on state changes

```swift
struct MorphingToolbar: View {
    @State private var isExpanded = false
    @Namespace private var namespace

    var body: some View {
        GlassEffectContainer(spacing: 40.0) {
            HStack(spacing: 40.0) {
                // Always visible
                Image(systemName: "pencil")
                    .frame(width: 60, height: 60)
                    .glassEffect()
                    .glassEffectID("pencil", in: namespace)

                // Conditionally visible - will morph in/out
                if isExpanded {
                    Image(systemName: "eraser")
                        .frame(width: 60, height: 60)
                        .glassEffect()
                        .glassEffectID("eraser", in: namespace)

                    Image(systemName: "ruler")
                        .frame(width: 60, height: 60)
                        .glassEffect()
                        .glassEffectID("ruler", in: namespace)
                }
            }
        }

        Button("Toggle") {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }
        .buttonStyle(.glass)
    }
}
```

## Button Styles

### Glass Button

```swift
Button("Standard") {
    // action
}
.buttonStyle(.glass)
```

### Glass Prominent Button

```swift
Button("Primary Action") {
    // action
}
.buttonStyle(.glassProminent)
```

## Advanced Techniques

### Background Extension

Extend a hero image beyond the safe area — the system mirrors and blurs it under bars and sidebars:

```swift
Image("hero")
    .backgroundExtensionEffect()
```

Or stretch content under sidebar or inspector:

```swift
NavigationSplitView {
    SidebarView()
} detail: {
    DetailView()
        .background {
            Image("wallpaper")
                .resizable()
                .ignoresSafeArea()
        }
}
```

### Horizontal Scroll Under Sidebar

```swift
ScrollView(.horizontal) {
    HStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}
.scrollExtensionMode(.underSidebar)
```

### Tab Bar Behaviors

```swift
TabView {
    // tabs
}
.tabBarMinimizeBehavior(.onScrollDown)  // Tab bar recedes while scrolling content
.tabViewBottomAccessory {               // Persistent control docked above the tab bar
    MiniPlayerView()
}
```

### Toolbar Spacers

Split toolbar items into separate glass groups instead of customizing bar backgrounds:

```swift
.toolbar {
    ToolbarItem { editButton }
    ToolbarSpacer(.fixed)      // Visual break — starts a new glass group
    ToolbarItem { shareButton }
    ToolbarSpacer(.flexible)   // Pushes the following group apart
    ToolbarItem { doneButton }
}
```

### Scroll Edge Effect Style

```swift
ScrollView { content }
    .scrollEdgeEffectStyle(.hard, for: .top)  // Hard style for dense UI, mostly macOS
```

### Sheets

Remove custom `presentationBackground` modifiers — they interfere with the sheet's glass material and its morphing behavior.

## AppKit Implementation

### NSGlassEffectView

```swift
import AppKit

// Create glass effect view
let glassView = NSGlassEffectView(frame: NSRect(x: 20, y: 20, width: 200, height: 100))
glassView.cornerRadius = 16.0
glassView.tintColor = NSColor.systemBlue.withAlphaComponent(0.3)

// Create content
let label = NSTextField(labelWithString: "Glass Content")
label.translatesAutoresizingMaskIntoConstraints = false

// Set content view
glassView.contentView = label

// Add constraints
if let contentView = glassView.contentView {
    NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
}
```

### NSGlassEffectContainerView

```swift
// Create container
let container = NSGlassEffectContainerView(frame: bounds)
container.spacing = 40.0

// Create content view
let contentView = NSView(frame: container.bounds)
container.contentView = contentView

// Add glass views to content
let glass1 = NSGlassEffectView(frame: NSRect(x: 20, y: 50, width: 150, height: 100))
let glass2 = NSGlassEffectView(frame: NSRect(x: 190, y: 50, width: 150, height: 100))

contentView.addSubview(glass1)
contentView.addSubview(glass2)
```

### Interactive AppKit Glass

```swift
class InteractiveGlassView: NSGlassEffectView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupTracking()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTracking()
    }

    private func setupTracking() {
        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeInActiveApp
        ]
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: options,
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            animator().tintColor = NSColor.systemBlue.withAlphaComponent(0.2)
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            animator().tintColor = nil
        }
    }
}
```

## Common Patterns

### Floating Action Bar

```swift
struct FloatingActionBar: View {
    @Namespace private var namespace

    var body: some View {
        GlassEffectContainer(spacing: 20) {
            HStack(spacing: 16) {
                ForEach(actions) { action in
                    Button {
                        action.perform()
                    } label: {
                        Image(systemName: action.icon)
                            .font(.title2)
                    }
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.interactive())
                    .glassEffectID(action.id, in: namespace)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}
```

### Card with Glass Effect

For a card floating above content (e.g. overlaid on a map). Cards inside a scrolling list are content-layer — don't use glass there. Note the icon uses a fill, not a second `glassEffect`: elements on glass never get glass again.

```swift
struct GlassCard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .frame(width: 50, height: 50)
                .background(.blue.opacity(0.15), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .glassEffect(in: .rect(cornerRadius: 16))
    }
}
```

### Tab Bar with Morphing

```swift
struct GlassTabBar: View {
    @Binding var selection: Int
    @Namespace private var namespace

    let tabs = [
        ("house", "Home"),
        ("magnifyingglass", "Search"),
        ("person", "Profile")
    ]

    var body: some View {
        GlassEffectContainer(spacing: 30) {
            HStack(spacing: 30) {
                ForEach(tabs.indices, id: \.self) { index in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selection = index
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tabs[index].0)
                                .font(.title2)
                            Text(tabs[index].1)
                                .font(.caption)
                        }
                        .frame(width: 70, height: 60)
                    }
                    .glassEffect(
                        selection == index
                            ? .regular.tint(.blue).interactive()
                            : .regular.interactive()
                    )
                    .glassEffectID("tab\(index)", in: namespace)
                }
            }
        }
    }
}
```

## Migration from Old API

### Before (Old Approach)

```swift
// Old: Using materials directly
VStack {
    Text("Content")
}
.padding()
.background(.ultraThinMaterial)
.cornerRadius(16)
```

### After (New API)

```swift
// New: Using glassEffect modifier
VStack {
    Text("Content")
}
.padding()
.glassEffect(in: .rect(cornerRadius: 16))
```

### Key Differences

| Old Approach | New API |
|--------------|---------|
| `.background(.material)` | `.glassEffect()` |
| Manual corner radius | Shape parameter |
| No interactivity | `.interactive()` modifier |
| Manual tinting | `.tint(Color)` modifier |
| No morphing | `glassEffectID` + `@Namespace` |
| No container grouping | `GlassEffectContainer` |

## UIKit Implementation

### UIGlassEffect

Use `UIVisualEffectView` with a `UIGlassEffect` to create glass surfaces in UIKit:

```swift
import UIKit

let glassEffect = UIGlassEffect()
let visualEffectView = UIVisualEffectView(effect: glassEffect)
visualEffectView.frame = CGRect(x: 50, y: 100, width: 300, height: 200)
visualEffectView.layer.cornerRadius = 20
visualEffectView.clipsToBounds = true

let label = UILabel()
label.text = "Liquid Glass"
label.textAlignment = .center
label.frame = visualEffectView.bounds
visualEffectView.contentView.addSubview(label)
view.addSubview(visualEffectView)
```

#### Customizing the Glass Effect

```swift
glassEffect.tintColor = UIColor.systemBlue.withAlphaComponent(0.3)
glassEffect.isInteractive = true
```

### Interactive Glass in UIKit

Set `isInteractive = true` on a `UIGlassEffect` to make it respond to touch:

```swift
let interactiveGlassEffect = UIGlassEffect()
interactiveGlassEffect.isInteractive = true

let glassButton = UIButton(frame: CGRect(x: 50, y: 300, width: 200, height: 50))
glassButton.setTitle("Glass Button", for: .normal)
glassButton.setTitleColor(.white, for: .normal)

let buttonEffectView = UIVisualEffectView(effect: interactiveGlassEffect)
buttonEffectView.frame = glassButton.bounds
buttonEffectView.layer.cornerRadius = 15
buttonEffectView.clipsToBounds = true

glassButton.insertSubview(buttonEffectView, at: 0)
view.addSubview(glassButton)
```

### UIGlassContainerEffect

Use `UIGlassContainerEffect` when combining multiple glass elements. This is the UIKit equivalent of SwiftUI's `GlassEffectContainer` -- it enables proper blending and morphing between glass views:

```swift
let containerEffect = UIGlassContainerEffect()
containerEffect.spacing = 40.0

let containerView = UIVisualEffectView(effect: containerEffect)
containerView.frame = CGRect(x: 50, y: 400, width: 300, height: 200)

let firstGlassEffect = UIGlassEffect()
let firstGlassView = UIVisualEffectView(effect: firstGlassEffect)
firstGlassView.frame = CGRect(x: 20, y: 20, width: 100, height: 100)
firstGlassView.layer.cornerRadius = 20
firstGlassView.clipsToBounds = true

let secondGlassEffect = UIGlassEffect()
secondGlassEffect.tintColor = UIColor.systemPink.withAlphaComponent(0.3)
let secondGlassView = UIVisualEffectView(effect: secondGlassEffect)
secondGlassView.frame = CGRect(x: 80, y: 60, width: 100, height: 100)
secondGlassView.layer.cornerRadius = 20
secondGlassView.clipsToBounds = true

containerView.contentView.addSubview(firstGlassView)
containerView.contentView.addSubview(secondGlassView)
view.addSubview(containerView)
```

### Scroll View Edge Effects

UIKit scroll views now support configurable edge effects for Liquid Glass integration:

```swift
let scrollView = UIScrollView(frame: view.bounds)
scrollView.topEdgeEffect.style = .automatic
scrollView.bottomEdgeEffect.style = .hard
scrollView.leftEdgeEffect.isHidden = true
scrollView.rightEdgeEffect.isHidden = true
```

**Available Edge Effect Styles:**

| Style | Description |
|-------|-------------|
| `.automatic` | System determines style based on context |
| `.hard` | Hard cutoff with a dividing line |

### UIScrollEdgeElementContainerInteraction

Coordinates glass elements (such as bottom toolbars) with scroll edge behavior:

```swift
let interaction = UIScrollEdgeElementContainerInteraction()
interaction.scrollView = scrollView
interaction.edge = .bottom
buttonContainer.addInteraction(interaction)
```

### Toolbar Integration

UIKit navigation bar items integrate with Liquid Glass automatically; `hidesSharedBackground` opts an item out of the shared glass bar:

```swift
let shareButton = UIBarButtonItem(
    barButtonSystemItem: .action,
    target: self,
    action: #selector(shareAction)
)
let favoriteButton = UIBarButtonItem(
    image: UIImage(systemName: "heart"),
    style: .plain,
    target: self,
    action: #selector(favoriteAction)
)
favoriteButton.hidesSharedBackground = true
navigationItem.rightBarButtonItems = [shareButton, favoriteButton]
```

### UIKit vs SwiftUI Comparison

| SwiftUI | UIKit |
|---------|-------|
| `.glassEffect()` | `UIVisualEffectView(effect: UIGlassEffect())` |
| `.glassEffect(.regular.interactive())` | `UIGlassEffect()` with `isInteractive = true` |
| `.glassEffect(.regular.tint(.blue))` | `UIGlassEffect()` with `tintColor = ...` |
| `GlassEffectContainer(spacing:)` | `UIGlassContainerEffect()` with `spacing` |
| `.buttonStyle(.glass)` | Insert `UIVisualEffectView` as button subview |

## WidgetKit Implementation

### Rendering Modes

Widgets support two rendering modes that affect how Liquid Glass is displayed:

| Mode | Description |
|------|-------------|
| **Full Color** | Default mode. Displays all colors, images, and transparency as designed. |
| **Accented** | Used when tinted or clear appearance is chosen. Primary and accented content tinted white (iOS and macOS). Background replaced with themed glass or tinted color effect. |

### Accented Mode

Detect the rendering mode and adapt layout accordingly. Use `.widgetAccentable()` to mark views that should be tinted in accented mode:

```swift
struct MyWidgetView: View {
    @Environment(\.widgetRenderingMode) var renderingMode

    var body: some View {
        if renderingMode == .accented {
            // Layout optimized for accented mode
            AccentedWidgetLayout()
        } else {
            // Standard full-color layout
            FullColorWidgetLayout()
        }
    }
}
```

#### Grouping Accent Content

```swift
HStack(alignment: .center, spacing: 0) {
    VStack(alignment: .leading) {
        Text("Widget Title")
            .font(.headline)
            .widgetAccentable()
        Text("Widget Subtitle")
    }
    Image(systemName: "star.fill")
        .widgetAccentable()
}
```

#### Image Rendering in Accented Mode

```swift
Image("myImage")
    .widgetAccentedRenderingMode(.monochrome)
```

### Container Backgrounds

Define a container background for your widget content:

```swift
var body: some View {
    VStack {
        // Widget content
    }
    .containerBackground(for: .widget) {
        Color.blue.opacity(0.2)
    }
}
```

### Background Removal

Prevent the system from removing the widget background. Note that marking a background as non-removable excludes the widget from contexts that require removable backgrounds (iPad Lock Screen, StandBy):

```swift
var body: some WidgetConfiguration {
    StaticConfiguration(kind: "MyWidget", provider: Provider()) { entry in
        MyWidgetView(entry: entry)
    }
    .containerBackgroundRemovable(false)
}
```

### visionOS Textures and Mounting Styles

#### Widget Textures

```swift
// Default glass texture
.widgetTexture(.glass)

// Paper-like texture
.widgetTexture(.paper)
```

#### Mounting Styles

```swift
.supportedMountingStyles([.recessed, .elevated])
```

| Style | Description |
|-------|-------------|
| `.recessed` | Widget appears embedded into a vertical surface |
| `.elevated` | Widget appears on top of a surface |

### Custom Glass Elements in Widgets

Apply `.glassEffect()` and `.buttonStyle(.glass)` directly within widget views:

```swift
// Glass text element
Text("Custom Element")
    .padding()
    .glassEffect()

// Glass image element
Image(systemName: "star.fill")
    .frame(width: 60, height: 60)
    .glassEffect(.regular, in: .rect(cornerRadius: 12))

// Glass button in widget
Button("Action") { }
    .buttonStyle(.glass)
```

## Best Practices

1. **Use GlassEffectContainer** for multiple glass views
   - Improves rendering performance
   - Enables morphing transitions

2. **Apply glass effect last** in modifier chain
   - After frame, padding, and content modifiers

3. **Choose appropriate spacing** in containers
   - Controls when effects blend together

4. **Use animations** for state changes
   - Enables smooth morphing transitions

5. **Add interactivity** for touchable elements
   - `.interactive()` for buttons and controls

6. **Tint sparingly** — reserve tint for the primary action
   - See Design Rules: tinting everything makes nothing stand out

7. **Consistent shapes** across your app
   - Establish a shape language (all capsules, or all rounded rects)

## Checklist

### SwiftUI
- [ ] Use `.glassEffect()` instead of `.background(.material)`
- [ ] Wrap multiple glass views in `GlassEffectContainer`
- [ ] Add `@Namespace` for morphing transitions
- [ ] Use `.glassEffectID()` on views that appear/disappear
- [ ] Add `.interactive()` for touchable elements
- [ ] Use `.buttonStyle(.glass)` for glass buttons
- [ ] Test animations for smooth morphing

### UIKit
- [ ] Use `UIVisualEffectView` with `UIGlassEffect` for glass surfaces
- [ ] Set `isInteractive = true` on glass effects for touchable elements
- [ ] Wrap multiple glass views in `UIGlassContainerEffect`
- [ ] Configure scroll view edge effects (`.automatic` or `.hard`)
- [ ] Use `UIScrollEdgeElementContainerInteraction` for scroll-coordinated toolbars
- [ ] Use `hidesSharedBackground` for toolbar items that need independent glass

### WidgetKit
- [ ] Detect `widgetRenderingMode` and adapt layout for accented mode
- [ ] Mark accent content with `.widgetAccentable()`
- [ ] Set `.widgetAccentedRenderingMode()` on images
- [ ] Define `.containerBackground(for: .widget)` for backgrounds
- [ ] Use `.containerBackgroundRemovable(false)` only when necessary
- [ ] Apply `.glassEffect()` and `.buttonStyle(.glass)` in widget views
- [ ] Configure `.widgetTexture()` and `.supportedMountingStyles()` for visionOS

### General
- [ ] Glass only on the navigation layer — never on content (tables, lists)
- [ ] No glass stacked on glass; one variant (Regular or Clear) per interface
- [ ] Only the primary action is tinted
- [ ] Consider performance with many glass effects
- [ ] Support both light and dark appearances

## References

### SwiftUI
- [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)
- [Landmarks: Building an app with Liquid Glass](https://developer.apple.com/documentation/SwiftUI/Landmarks-Building-an-app-with-Liquid-Glass)
- [SwiftUI GlassEffectContainer](https://developer.apple.com/documentation/SwiftUI/GlassEffectContainer)

### AppKit
- [AppKit NSGlassEffectView](https://developer.apple.com/documentation/AppKit/NSGlassEffectView)

### UIKit
- [UIKit UIGlassEffect](https://developer.apple.com/documentation/UIKit/UIGlassEffect)
- [UIKit UIGlassContainerEffect](https://developer.apple.com/documentation/UIKit/UIGlassContainerEffect)
- [UIKit UIVisualEffectView](https://developer.apple.com/documentation/UIKit/UIVisualEffectView)
- [UIScrollEdgeElementContainerInteraction](https://developer.apple.com/documentation/UIKit/UIScrollEdgeElementContainerInteraction)

### WidgetKit
- [WidgetKit Rendering Modes](https://developer.apple.com/documentation/WidgetKit/WidgetRenderingMode)
- [widgetAccentable()](https://developer.apple.com/documentation/SwiftUI/View/widgetAccentable(_:))
- [containerBackground(for:)](https://developer.apple.com/documentation/SwiftUI/View/containerBackground(for:alignment:content:))

### Source: `design/sf-symbols`

# SF Symbols

Over 7,000 system symbols with free platform consistency, Dynamic Type alignment, and
accessibility — the default answer to "we need an icon." This skill covers using them well,
authoring custom ones that behave like system ones, and the animation vocabulary.
(Animation *implementation patterns* live in `design/animation-patterns` → symbol-effects.md;
this skill owns selection, authoring, and rendering.)

## When This Skill Activates

- Choosing icons for tabs, toolbars, buttons, widgets ("should this be an SF Symbol?" — usually yes)
- A needed glyph doesn't exist → authoring a custom symbol
- Rendering a changing value (signal, progress, volume) as a symbol
- Symbol state changes that should animate (mute/unmute, play/pause)

## Using system symbols

- Prefer symbols over custom art for tab/toolbar icons — recognizability across the platform
  for free, and they scale with text styles (`imageScale`, weights match adjacent text).
- Keep platform-conventional symbols conventional: share, trash, search mean one thing each.
- **Rendering modes**: Monochrome · Hierarchical (one color, opacity-derived depth) ·
  Palette (2–3 explicit colors) · Multicolor (intrinsic colors). Pick per context — hierarchical
  shines in toolbars; multicolor in content.
- **Gradients** (SF Symbols 7-era): a smooth linear gradient generated from one source color,
  available in all rendering modes — use where depth helps, keep flat in dense UI.
- **Variable value**: pass `variableValue` (0–1) to render magnitude — signal bars, progress.
  Thresholds distribute evenly; 0% is the only "empty" state (a symbol reads "full" before 100%).
  **Variable Draw** (SF Symbols 7) renders the path at a percentage instead of activating
  layers — an alternative for progress/temperature; a symbol can carry both but renders one.

## Animation vocabulary

Presets: **Bounce · Pulse · Variable Color · Scale · Appear · Disappear · Replace · Draw On/Off**
(SF Symbols 7). Behavior classes: discrete (one-off), indefinite (until removed — always pair
with removal logic), transition, content transition.

- Swap symbol states with `.contentTransition(.symbolEffect(.replace))` — and prefer **Magic
  Replace** (preserves matching enclosures, uses Draw Off/On where supported) for state pairs
  like mute/unmute.
- Draw On/Off playback: By Layer (default) · Whole Symbol · Individually. Symbols define their
  own drawing direction (wind draws left→right; symmetric symbols from center).
- Effects propagate down the view hierarchy — `.symbolEffectsRemoved()` blocks them on subviews.
- Full API patterns (SwiftUI `symbolEffect`, UIKit `addSymbolEffect`) in
  `design/animation-patterns/symbol-effects.md`.

## Authoring custom symbols

The workflow that makes a custom glyph behave like a system one:

1. **Start from the closest system symbol** (prefer an unfilled base) — SF Symbols app →
   Export Template. Never draw from a blank canvas.
2. **Draw three sources**: Ultralight-Small, Regular-Small, Black-Small — the system
   interpolates all **27 variants** (9 weights × 3 scales) from them. Get Regular-Small right
   first, then copy its paths and only *move* points — all sources must keep the **same number
   and order of paths and points** (move, never add/remove).
3. **Outline everything**: convert live strokes to outlined paths once the design settles; no
   open paths (can't fill), no gradients or drop shadows baked in (they break multicolor/
   hierarchical rendering) — flat fills only.
4. **Annotate with unified annotation**: layers in explicit z-order; system colors for
   multicolor (they adapt to dark mode/contrast); primary→tertiary groups drive hierarchical
   and palette modes; `Erase` punches shapes out of layers behind; `Hidden` excludes a layer
   from a mode. For **variable color**, z-order = activation order (first-to-fill at bottom).
5. **Draw guide points** (SF Symbols 7 templates) for Draw On/Off: every path needs a start
   (open circle) and end (closed circle); corners marked with diamonds; annotate the Regular
   weight first (the only weight where guide points can be added/removed) and keep guide-point
   order identical across weights.
6. **Export the current template version** for Xcode. Legacy note: 2.0 templates are
   monochrome-only (needed only for very old deployment targets); 3.0+ carries all rendering
   modes; 4.0+ carries variable color.

❌ Common failures: baking effects into art (breaks rendering modes) · mismatched path counts
across sources (kills interpolation) · re-ordering paths after annotation (forces re-annotation)
· shipping a filled base variant as the only variant.

## Output Format

For icon reviews: `Location | Current | Symbol exists? (name) | Mode/config | Action`.
For custom-symbol requests: the 6-step authoring checklist above with per-step status.

## References

- https://developer.apple.com/sf-symbols/ (the SF Symbols app)
- https://developer.apple.com/videos/play/wwdc2025/337/ (What's new in SF Symbols 7)
- https://developer.apple.com/videos/play/wwdc2021/10250/ (Create custom symbols)
- https://developer.apple.com/videos/play/wwdc2023/10258/ (Animate symbols)
- https://developer.apple.com/videos/play/wwdc2022/10158/ (Variable Color)
- https://developer.apple.com/design/human-interface-guidelines/sf-symbols
- Related skills: `design/animation-patterns` (symbol-effects implementation), `design/typography` (SF font pairing), `generators/app-icon-generator` (app icons are NOT symbols)

### Source: `design/typography`

# Typography

Type is most of your UI. The system does the hard parts — optical sizes, tracking tables,
Dynamic Type — *if* you use its APIs. This skill covers when to trust the system, how to build
hierarchy deliberately, and what custom fonts owe you back.

## When This Skill Activates

- Choosing fonts or building a type hierarchy for a screen or app
- Text truncating, cramping, or breaking under larger Dynamic Type sizes
- Adopting a custom/brand font (and keeping accessibility)
- Display typesetting: hero numbers, stats, editorial headlines

## Rule 1: text styles first

Predefined styles (Large Title → Caption 2) are weight + size + leading combos with Dynamic
Type support built in — and different styles scale *differently* (body grows more than
footnote), which manual font sizes can't replicate.

- Build hierarchy from 2–3 text styles + emphasized variants (bold trait — the actual weight
  varies per style: some go medium→semibold, others bold→heavy) before reaching for new fonts.
- Semantic colors + text styles together give dark mode, contrast, and Dynamic Type for free.
- macOS supports text styles (without Dynamic Type); design Mac type at 100% — no iOS-style
  scaling assumptions.

## Rule 2: let optical sizes and tracking work

- San Francisco blends Text→Display designs **continuously between 17 and 28pt** (below: sturdier
  letterforms, looser tracking for legibility; above: tighter, more refined). System font APIs do
  this automatically — hardcoded single-cut fonts don't.
- **Tracking, not kerning**, for letterspacing — tracking is size-specific and lets the OS
  disable clashing features (ligatures). Override system tracking only in exceptional cases.
- Truncation pressure? Use `allowsTightening` (default-tightening-for-truncation) instead of
  manually squeezing — and prefer wrapping to truncating (line limit 0 on labels that matter).
- Line height moves only via leading traits: tight = −2pt, loose = +2pt (±1pt on watchOS); the
  system adds leading automatically for tall scripts (Arabic, Devanagari).

## The Dynamic Type ladder (WWDC24 10074)

12 sizes: 7 default + 5 accessibility (AX1–AX5). `.body` runs 17pt at default up to 53pt
at AX5 — roughly 3× taller, and layouts must expect that. Escalate in order:

1. **Text styles** — `.font(.title)` / `preferredFont(forTextStyle:)` +
   adjusts-for-content-size, line count 0 so text wraps instead of truncating.
2. **`@ScaledMetric`** for the non-text riding alongside (icon frames, spacing); SF
   Symbols scale via `UIImage.SymbolConfiguration(textStyle:)`. Prioritize scaling
   essential content over decoration.
3. **Switch layout axis at accessibility sizes** — branch on
   `dynamicTypeSize.isAccessibilitySize` with `AnyLayout(HStackLayout())` /
   `AnyLayout(VStackLayout())` (UIKit: flip the stack axis on
   `preferredContentSizeCategory.isAccessibilityCategory`); give text the full line
   width and relax `lineLimit`.
4. **Large Content Viewer** — only for bars that legitimately can't grow: a tab bar takes
   under 10% of screen height, and scaled to accessibility sizes it would eat almost a
   quarter (WWDC24 10074). Scaling is always preferred; the viewer is the fallback, not
   the fix.

Test at all 12 sizes (Xcode Previews → Variants → Dynamic Type Variants), not just the
biggest — mid-range accessibility sizes catch different wrap points.

## The San Francisco family — pick by job

| Face | Job |
|---|---|
| SF Pro | The default; UI text everywhere |
| SF Pro Rounded | Friendlier numerals/labels — widgets, health/fitness data |
| SF Compact | watchOS (space-efficient counterpart) |
| SF Mono | Code, tabular alignment |
| New York | Serif — reading experiences, editorial contrast |
| SF Arabic / SF Arabic Rounded | Arabic script with its own optical sizes |

**The width axis** (Condensed / Regular / Compressed / Expanded):

- Default Regular; every non-Regular choice is a legibility decision — check it.
- Condensed: fit more text comfortably (long headlines wrap one line fewer).
- Compressed: display-only density, not body text.
- Expanded: display typesetting AND small secondary labels (wide + loose tracking).
- Width is a **fourth hierarchy lever** beside weight, size, color; all widths share identical
  vertical proportions, so mixing them never misaligns baselines. 2–3 styles are enough —
  pair one width with contrasting weights, one weight with contrasting widths, or oppose both
  for maximum display contrast.

## Custom fonts: what you owe back

System fonts get Dynamic Type free; a brand font makes *you* the type engine:

- Scale with `UIFontMetrics(forTextStyle:).scaledFont(for:)` + adjusts-for-content-size, or
  SwiftUI `Font.custom(_:size:relativeTo:)`; scale layout constants with `@ScaledMetric`.
- Test at the largest accessibility sizes — wrap to multiple lines rather than truncate.
- Verify script coverage for your locales; have a fallback plan for writing systems the brand
  font doesn't cover (the system stacks: `system-ui`, `ui-rounded`, `ui-serif`, `ui-monospace`
  on the web).
- Budget for the maintenance: tracking tables, optical sizing, and weight ramps are things SF
  does that a licensed font usually doesn't.

❌ Anti-patterns: hardcoded point sizes on user-facing text · kerning APIs for tracking jobs ·
custom font without `relativeTo:` (frozen size) · Compressed body text · truncation where
wrapping was possible.

## Output Format

Type review: `Element | Current (font/size/style) | Issue (hierarchy/scaling/legibility) | Fix`
— check Dynamic Type at XXL + AX sizes before signing off; pairs with the contrast rules in
`generators/accessibility-generator`.

## References

- https://developer.apple.com/videos/play/wwdc2020/10175/ (The details of UI typography)
- https://developer.apple.com/videos/play/wwdc2022/110381/ (The expanded San Francisco family)
- https://developer.apple.com/fonts/ (SF + New York downloads)
- https://developer.apple.com/design/human-interface-guidelines/typography
- Related skills: `design/sf-symbols` (symbols align to text styles), `foundation/attributed-string` (rich text mechanics), `generators/accessibility-generator`

### Source: `design/ui-prototyping`

# UI Prototyping Skill

Task lists and specs commit you to **one** layout before you've seen the alternatives. The cost is quiet but large: you anchor on the first arbitrary structure an agent guessed, then spend the rest of the phase fighting feature creep around it. This skill front-loads *divergent exploration* — many real, named SwiftUI variations you flip between in Xcode's canvas — so the layout you carry into `/apple:plan` is one you **chose**, not one you defaulted into.

> **Agents are collaborators, not designers. You always have final say.** Go wide, remix, repeat.

## Why this exists (the trap it removes)

A vague prompt — *"make a UI for a book club"* — produces one arbitrary layout, silently guesses at features you never asked for (polling? a photo gallery?), and anchors you on a flawed start. By the time you've bent it to the features you *do* want, it looks clunky and inelegant. Three disciplines remove the trap, and this skill enforces all three:

| Discipline | What it means | What it prevents |
|---|---|---|
| **Specificity** | Bake the exact features in; nothing extra | Feature creep, arbitrary navigation elements |
| **Stylistic intent** | Name the mood — warm coffee-shop palette? paper & typography? clean editorial? | Point-of-view-less, generic layouts |
| **Multiplicity** | Ask for *many divergent* options at once | Anchoring on the first guess |

Early is your **only** cheap chance to explore wide. Spend it.

## Input

- `.planning/APP.md` — features, audience, platform. The feature list is exactly what you bake into every variation.
- Optional target screen (arg). If none, prototype the primary screen implied by `<mvp-features>`.
- **If `APP.md` is missing, that's fine** — elicit the essentials first via `AskUserQuestion` (this is the novice front door): the one screen, its 3–5 must-have features, the mood, and 0–2 reference apps. You do not need to know how to write the "good prompt" — the skill assembles it from your answers.

## The method — go wide → remix → make lived-in → tune

### Stage 1 — Go wide (divergent variations)

1. **Assemble the brief** (via `AskUserQuestion` if it isn't already pinned down in `APP.md`): the screen, the 3–5 must-have features (baked in — *this* is what stops feature creep), the mood cue, reference apps.
2. **Generate 6–10 genuinely divergent variations** of that ONE screen. Divergence is measured by *organizing metaphor*, not paint: vary tab vs. grid→detail vs. single-scroll vs. dashboard/standings, the navigation shape, typography (New York / serif vs. SF), density, and color/mood. Two variations that differ only in tint = one wasted slot.
3. **Each variation gets its own `#Preview` with a descriptive, memorable name** — `"Cozy"`, `"Editorial"`, `"Club Hub"`, `"Blueprint Atelier"`. The name is the handle you'll use when you remix. Put each in its own file (or a clearly separated struct) so the named previews render side by side in Xcode's canvas.
   ```swift
   #Preview("Cozy") { CozyHomeView(club: .sample) }
   #Preview("Club Hub") { ClubHubHomeView(club: .sample) }
   ```
4. **Only the requested features appear.** If the app needs no polling or gallery, no variation invents one.
5. **It compiles.** `xcodebuild build` (or the canvas) — you're carrying this forward, not screenshotting a dead mock.

Present the named set; the user flips between them and reacts. **Expect duds** ("…well, it was worth a shot") — range is the goal, not a batting average.

### Stage 2 — Remix + make it lived-in

1. **Remix.** The user names what they liked *by preview name and element* — "the standings board from *Club Hub* + the current-book cover from *Cozy*." Generate new **hybrid** variations from only those elements, each its own new named preview. Go wide → remix → repeat until one direction feels right.
2. **Lived-in content.** Empty scaffolding lies about how a screen feels. Generate **reusable sample models in their own file** (delegate to `generators/preview-data-generator`) so you can edit them, and make the content *plausible for the audience* — a book club's discussions are about books, not lorem ipsum. Plausible also means **messy, not idealized**: prototype with real data ranges, because the layout that flatters a hilly San Francisco route must also survive a pancake-flat New York one (WWDC23). Ideal placeholders hide exactly the cases that break a design.
3. **Edge-case previews.** Think the states through yourself; don't let the agent silently pick the happy path. Cover at minimum:
   - **Empty / blank-slate** — no meeting scheduled yet, zero items. Is there a call-to-action and an account/management entry, or does it just look broken?
   - **Unbounded growth** — many members, long message threads, dozens of past items, long titles. Truncate, or an expand control? (The leaderboard that pushes the discussion off-screen is the classic bug.)
   - **Long input** — does text truncate with `.help()`/detail access, or wrap to multiple lines?

   Delegate the state-matrix generation to the `swiftui-builder` agent (it emits a `#Preview` per state); **you** decide which states matter.

### Stage 3 — Tune key moments (a tuning panel)

Signature interactions — a cover-to-detail transition, a staggered list entrance — are where an app reads as considered or cheap. Don't hand-edit constants scattered across files; have the agent build a **tuning panel**.

1. **Be specific about what you're tuning.** Ease (duration) vs. spring (stiffness / damping / mass)? A single element, or a transition where views enter and leave the hierarchy?
2. **Break the animation into named phases** — "Phase 1: cover transitions to detail. Phase 2: rows stagger in." Phases give you and the agent a shared vocabulary; ask for controls per phase so you can inspect and retune one in isolation.
3. **Lay the panel out side-by-side on a wide window**, not a modal that obstructs the content — toggle a parameter and see the effect without context-switching. Ask for a resize control that moves the panel beside the UI on a larger canvas.
4. **Tuning panels generalize** beyond animation: swap app states, colors, fonts, visual offsets. Use `design/animation-patterns` for the curve knowledge; the panel is its runnable counterpart.
5. **Prototype beyond static layout.** Friction, inertia, device-motion effects (gyroscope parallax), and haptics are all promptable and panel-tunable the same way — and they're *feel*, only judgeable running on a device, not in a screenshot (WWDC26).
6. **Guard it behind DEBUG / a launch arg** so it never ships — same discipline as walkthrough's `-uiTestSeed`.
7. **On device early; review as a demo app.** Don't wait for "done" to leave the canvas — feel parameters (Digital Crown sensitivity, spring values) only tune while running live, so the earlier a prototype is on hardware the cheaper every iteration. And when it's time for a design review, bundle the competing prototypes into one on-device demo app rather than exporting stills: "no slide deck in the world can compare with one spectacular demo" (WWDC23).

## Output: `.planning/PROTOTYPE.md` + real Swift

Record the decisions so the next session — and `/apple:plan` — inherits them:

```markdown
# UI Prototype — [Screen], Phase [N]

## Variations explored (Stage 1)
| Preview name | Organizing idea | Verdict |
|--------------|-----------------|---------|
| Cozy | single-scroll, warm serif, current-book hero | ✅ base direction |
| Club Hub | tab bar + standings board | remix: take the standings board |
| Blueprint Atelier | grid → detail | ✗ too cold |

## Chosen direction & remix (Stage 2)
- Base: *Cozy*; grafted the standings board from *Club Hub*.
- Sample data: `PreviewData/BookClubSamples.swift` (editable, reused across previews).
- Edge cases covered: empty (added CTA + account entry), long member list (rank pinned + expand), long titles (truncate).

## Tuned moments (Stage 3)
- Cover→detail: spring(stiffness: …, damping: …); rows stagger 0.04s. Panel: `Debug/TransitionTuner.swift` (DEBUG only).

## Carry-forward
- Winning layout → `/apple:plan` `<flows>` + `<apple-patterns>`; keep the Swift files.
```

Plus the actual files in the project: the variation views, the sample-data file, and any tuning panel (DEBUG-guarded).

## Honest limits

- **Agents propose; you decide.** Don't delegate "which is best" — that judgment *is* the design work. A pile of variations with no chosen direction is not a result.
- **Divergent ≠ good.** Some variations will flop; that's the method working, not failing.
- **Nothing beats real users.** Lived-in sample content is a head start on the feedback stage, not a substitute for people using your app with their own content.
- **The tuning panel is scaffolding** — DEBUG-only, guarded, and removed or gated before release.

## Cadence & integration

- **Run early, once per signature screen** — after `/apple:new-app`, or at the start of a UI-heavy phase, *before* `/apple:plan` locks a layout. Exploration is cheapest before the "real" screen exists.
- **Feeds forward:** the winning variation is real SwiftUI — hand its structure to `/apple:plan` (`<flows>` / `<apple-patterns>`) and `/apple:build`; don't rebuild it.
- **Bookends with `flow-walkthrough` / `/apple:walkthrough`:** prototype the *screen* (diverge, choose, tune), then walkthrough the *flow* (verify transitions and dead-ends) once it's wired up. Explore → build → verify.
- **Complements `product/ux-spec`:** ux-spec formalizes *one* spec; this skill is how you find the one worth formalizing. Feed the winner in, or skip ux-spec for small apps.
- **Reuses:** `generators/preview-data-generator` (sample content), the `swiftui-builder` agent (edge-case `#Preview` matrix), `design/animation-patterns` (curve reference).

### Source: `design/ux-writing`

# UX Writing

Interface text is interface design. This skill covers writing it: the frameworks Apple's
writers use, the anatomy of the hardest components (alerts, errors, empty states, names), and
the mechanical edits that improve any screen's copy in minutes.

## When This Skill Activates

- Writing or reviewing user-facing copy: labels, buttons, alerts, onboarding, notifications
- Naming a new feature, tier, or setting
- Error messages that frustrate, empty states that dead-end, permission prompts that get denied
- Localization prep (copy that survives translation)

## The PACE framework (Writing for Interfaces)

Run every screen's copy through four questions:

- **Purpose** — what must this screen communicate? Headers and buttons should carry the screen
  alone; know what to leave out. Hierarchy in words mirrors hierarchy in layout.
- **Anticipation** — what will the user ask or do next? Write for that ("What comes next?").
- **Context** — where is the user right now (quiet home vs. busy airport, mid-task vs. idle)?
  That decides how much to say.
- **Empathy** — write for a person having a problem, not for the system reporting one.

## Voice vs. tone

- **Finding voice**: describe the app as a person, cluster the personality adjectives, keep 2–3
  as your voice attributes — constant across the app, while tone flexes per moment (more
  directness for high-stakes info, sparing warmth in celebrations).
- The test that recurs in every Apple session: **read it aloud**. Does it sound like the best
  version of your app talking?
- ❌ Jargon ("it can make people feel left out"); ❌ personality at the cost of usefulness.

## The four small edits (biggest impact per minute)

1. **Cut filler**: "easily," "quickly," "simply," "just" — ✅ "Enter your license plate to pay
   for parking" ❌ "Simply enter your license plate number to quickly pay for parking."
2. **Kill repetition** — merge redundant sentences: ❌ "We're running late. Your driver won't
   make it on time. They'll be there in 10 minutes." ✅ "Delivery delayed 10 minutes."
3. **Lead with the why** — benefit before action: ✅ "To get reservation updates, enter your
   phone number." Notifications too: ✅ "Keep your streak going by solving today's crossword."
4. **Keep a word list** — three columns: approved term · alternatives to avoid · definition
   (e.g. "alias — not handle/username/title — the player's in-game name, shown to others").
   Reuse identical button labels ("Next") everywhere; consistency builds trust.

## Alert anatomy (Writing Great Alerts)

First: should this be an alert at all? Alerts interrupt by design — reserve them for things
the user must know *now*.

- **Title**: the main point, one sentence or less. **Message**: only if needed.
- **The scannability test**: title + buttons alone must convey the situation.
- ❌ Vague hedging ("You may need to…") — name the file, name the fix.

## Naming features (Craft Clear Names, WWDC26)

Judge every candidate on three criteria: it **belongs** (fits the app and its location), it
**sets expectations** (readers predict what they'll get), it **works everywhere** (languages,
markets, platforms).

- Process: **Think / Feel / Do** — what should the audience think, feel, and do? Group the
  answers into themes; name from the themes; test candidates in natural sentences ("just
  search for ___").
- ✅ Industry-standard words in high-stakes domains: "Balance," not "Spending Power."
- ✅ Compounds are fine when the parts self-explain ("AutoMix"); emotional names win where the
  moment is emotional ("Memories").
- ❌ Implementation jargon — describe the outcome, not the mechanism.

## Empty states, permissions, localization

- **Empty states**: never dead-end — say what will appear and how, ideally with example input.
- **Permission prompts**: explain value first, ask at the contextually right moment (mechanics
  in `generators/permission-priming`).
- **Localization**: plain language over idiom/humor; leave layout room and accessibility text
  for every element.

## Output Format

Copy review table:

```
Location | Current | Problem (PACE / filler / vague button / jargon) | Rewrite
```

ordered by frequency-of-exposure (navigation labels before deep-screen prose).

## References

- https://developer.apple.com/videos/play/wwdc2022/10037/ (Writing for interfaces)
- https://developer.apple.com/videos/play/wwdc2024/10140/ (Add personality through UX writing)
- https://developer.apple.com/videos/play/wwdc2025/404/ (Small writing changes)
- https://developer.apple.com/videos/play/wwdc2026/290/ (Craft clear names)
- https://developer.apple.com/videos/play/wwdc2017/813/ (Writing Great Alerts)
- Related skills: `generators/permission-priming`, `generators/push-notifications` (notification copy), `app-store/app-description-writer` (store copy)

### Source: `generators/accessibility-generator`

# Accessibility Generator

Generate accessibility infrastructure for VoiceOver, Dynamic Type, and accessibility features.

## When This Skill Activates

- User wants to improve app accessibility
- User mentions VoiceOver, Dynamic Type, or accessibility
- User needs to add accessibility labels and hints
- User wants to audit accessibility compliance

## Pre-Generation Checks

```bash
# Check existing accessibility usage
grep -r "accessibilityLabel\|accessibilityHint\|AccessibilityFocused" --include="*.swift" | head -5
```

## Key Features

### Accessibility Labels

```swift
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite")
    .accessibilityHint("Double tap to remove from favorites")
```

### Dynamic Type Support

```swift
Text("Title")
    .font(.title)  // Scales automatically
    .dynamicTypeSize(...DynamicTypeSize.accessibility3)  // Limit max size
```

### Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

withAnimation(reduceMotion ? nil : .spring()) {
    // Animation
}
```

### VoiceOver Groups

```swift
VStack {
    Text("Item Name")
    Text("$9.99")
}
.accessibilityElement(children: .combine)
```

## Visual Accessibility: Numbers and APIs (WWDC20)

| Setting | Threshold / API | What to do |
|---------|-----------------|------------|
| Contrast | **4.5:1 minimum** ("generally the lowest acceptable ratio"); ~**7.5:1** for comfort on dark backgrounds | Check text and glyphs against their actual backgrounds |
| Differentiate Without Color | `UIAccessibility.shouldDifferentiateWithoutColor` | Add shapes/symbols wherever color is the only signal (red/green states) |
| Button Shapes | `UIAccessibility.buttonShapesEnabled` + its change notification | Show borders/underlines on plain-text buttons when on |
| Increase Contrast | System colors adapt for free; custom colors need a **"High Contrast" variant in the asset catalog** | Never ship a single hex for both modes |
| Dynamic Type | `preferredContentSizeCategory` | **Never truncate** — set line count to 0 so text wraps; reflow layout at accessibility sizes |
| Bold Text | `UIAccessibility.isBoldTextEnabled` | Free with system text styles; custom fonts must swap weights manually |
| Reduce Motion | `isReduceMotionEnabled`, `prefersCrossFadeTransitions` | Gate animations, parallax, and video autoplay; prefer cross-fades over sliding transitions |
| Smart Invert | `.accessibilityIgnoresInvertColors()` | Apply to photos, videos, and full-color icons so they don't invert |
| Reduce Transparency | `UIAccessibility.isReduceTransparencyEnabled` | Render blur/vibrancy backgrounds as opaque |

SwiftUI mirrors most of these as environment values (`\.accessibilityReduceMotion` above, plus `\.accessibilityDifferentiateWithoutColor`, `\.legibilityWeight`, `\.accessibilityReduceTransparency`).

## Deep Patterns (accessibility-patterns.md)

The full recipes live in [accessibility-patterns.md](accessibility-patterns.md):

- Label-writing rules — context ladder, no control types, succinctness, localize (WWDC19 254)
- Custom actions doctrine — clutter/speed rationale, hide replaced buttons, widget intents (WWDC19 250, WWDC24 10073)
- Custom rotors, UIKit and SwiftUI (WWDC20 10116, WWDC21 10119)
- Data-rich rows via the More Content rotor / `AXCustomContent` (WWDC21 10121)
- Announcements with priorities, `.isToggle`, zoom, direct touch, block-based setters (WWDC23 10036)
- Custom-control technique selection: adjustable vs passthrough vs custom actions vs direct touch (WWDC26 220)
- Switch Control grouping and timeout rules (WWDC20 10019); Full Keyboard Access (WWDC21 10120)
- Reading-app text navigation, page turns, `UITextInput` adoption (WWDC26 219)

## Inclusive Design Principles (WWDC25)

- **About 1 in 7 people has a disability** — accessibility features are mainstream features.
- Provide information through **multiple senses**: captions for audio, audible/haptic paths for visual cues.
- Support **multiple input methods** — touch, keyboard, voice, switch — for every action.
- **Larger Text scales text up to ~3x** — layouts must reflow, not clip or overlap.
- Inclusion is **iterative, not one-time** — re-audit each release, not just before launch.

## Generated Files

```
Sources/Accessibility/
├── AccessibilityModifiers.swift   # Custom view modifiers
├── AccessibilityHelpers.swift     # Label builders
└── AccessibilityStrings.swift     # Localized labels
```

## Audit Checklist

- [ ] All interactive elements have labels
- [ ] Images have descriptions or are hidden decoratively
- [ ] Color is not the only indicator
- [ ] Touch targets are at least 44×44 points
- [ ] Dynamic Type is supported
- [ ] Reduce Motion is respected
- [ ] VoiceOver order is logical
- [ ] Custom controls expose purpose, value, actions, and feedback (WWDC26 220)
- [ ] Automated audit + Nutrition Label evaluation — see `ios/accessibility-audit`

## References

- [Accessibility in SwiftUI](https://developer.apple.com/documentation/swiftui/accessibility)
- [Human Interface Guidelines: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)

### Source: `generators/quick-win-session`

# Quick Win Session Generator

Generate a "quick win" session system that guides users to complete a meaningful action within their first 60 seconds. Reduces time-to-value by surfacing the simplest high-impact task, walking the user through it step by step, and celebrating completion. Critical for onboarding retention — users who achieve a quick win in the first minute are significantly more likely to return.

## When This Skill Activates

Use this skill when the user:
- Asks about "quick win" flows or "first action" experiences
- Wants to reduce "time to value" or "time to first success"
- Mentions "guided first task" or "onboarding action"
- Asks about a "first success moment" or "activation metric"
- Wants to "get users to do something useful immediately"
- Mentions "new user activation" or "onboarding retention"

## Pre-Generation Checks

### 1. Project Context Detection
- [ ] Check deployment target (iOS 17+ / macOS 14+ required for @Observable)
- [ ] Check Swift version (requires Swift 5.9+)
- [ ] Identify source file locations

### 2. Existing Onboarding Detection
Search for existing onboarding code:
```
Glob: **/*Onboarding*.swift, **/*Welcome*.swift, **/*QuickWin*.swift, **/*FirstRun*.swift
Grep: "onboarding" or "firstLaunch" or "hasCompletedSetup" or "isNewUser"
```

If existing onboarding found:
- Ask if quick win should run after the existing onboarding or replace it
- If running after, integrate as the next step in the onboarding flow

### 3. User State Tracking Detection
Search for existing user defaults or state tracking:
```
Grep: "UserDefaults" or "@AppStorage" or "isFirstLaunch"
```

Determine how to persist quick win completion status (UserDefaults, AppStorage, SwiftData, etc.).

## Configuration Questions

Ask user via AskUserQuestion:

1. **Quick win type?**
   - Create first item (e.g., first note, first task, first photo)
   - Complete profile (fill in name, avatar, preferences)
   - Import data (bring in existing content from another source)
   - Explore feature (guided tour of the single most valuable feature)

2. **Guidance style?**
   - Step-by-step overlay (instruction cards at top, progress dots)
   - Spotlight hints (dim screen, cut out spotlight on target element)
   - Coach marks (tooltip arrows pointing at UI elements)

3. **Celebrate on completion?**
   - Yes — animated checkmark, congratulations message, time stat
   - Minimal — brief success banner, auto-dismiss
   - No — silently mark as complete

4. **Track as activation metric?**
   - Yes — log completion time, step-by-step progress, abandonment point
   - No — just persist completed/not completed

## Generation Process

### Step 1: Read Templates
Read `templates.md` for production Swift code.

### Step 2: Create Core Files
Generate these files:
1. `QuickWinTask.swift` — Model for a quick win task and its steps
2. `QuickWinSession.swift` — @Observable session manager: task selection, step tracking, timing, completion

### Step 3: Create UI Files
3. `QuickWinGuideView.swift` — Overlay that shows instructions and progress
4. `SpotlightHintView.swift` — Spotlight cutout overlay with callout arrow
5. `QuickWinCelebrationView.swift` — Completion celebration with stats

### Step 4: Create Integration File
6. `QuickWinModifier.swift` — ViewModifier that triggers the quick win for new users

### Step 5: Determine File Location
Check project structure:
- If `Sources/` exists → `Sources/QuickWin/`
- If `App/` exists → `App/QuickWin/`
- Otherwise → `QuickWin/`

## Output Format

After generation, provide:

### Files Created
```
QuickWin/
├── QuickWinTask.swift           # Task model with steps
├── QuickWinSession.swift        # Session manager (progress, timing)
├── QuickWinGuideView.swift      # Step-by-step overlay UI
├── SpotlightHintView.swift      # Spotlight cutout with callout
├── QuickWinCelebrationView.swift # Completion celebration
└── QuickWinModifier.swift       # ViewModifier for root view
```

### Integration After Onboarding

**Attach to your root view:**
```swift
// In your main ContentView or post-onboarding view
ContentView()
    .quickWinSession(task: .createFirstNote)
```

**Define your app's quick win task:**
```swift
extension QuickWinTask {
    static let createFirstNote = QuickWinTask(
        id: "create-first-note",
        title: "Create Your First Note",
        description: "Let's get started — it only takes a few seconds.",
        estimatedSeconds: 30,
        steps: [
            QuickWinStep(instruction: "Tap the + button to create a new note", actionType: .tap, targetView: "addButton"),
            QuickWinStep(instruction: "Type a title for your note", actionType: .input, targetView: "titleField"),
            QuickWinStep(instruction: "Tap Done to save", actionType: .tap, targetView: "doneButton")
        ],
        completionCriteria: "firstNoteCreated",
        iconName: "note.text.badge.plus"
    )
}
```

**With spotlight hints:**
```swift
// Mark target views for spotlight
TextField("Title", text: $title)
    .quickWinTarget(id: "titleField")

Button("Done") { save() }
    .quickWinTarget(id: "doneButton")
```

**Start session programmatically (after existing onboarding):**
```swift
struct PostOnboardingView: View {
    @State private var session = QuickWinSession()

    var body: some View {
        MainView()
            .onAppear {
                if !session.hasCompletedQuickWin {
                    session.start(task: .createFirstNote)
                }
            }
            .quickWinOverlay(session: session)
    }
}
```

### Testing

```swift
@Test
func quickWinSessionTracksProgress() async {
    let session = QuickWinSession(storage: MockStorage())
    let task = QuickWinTask.testTask(stepCount: 3)

    session.start(task: task)
    #expect(session.currentStepIndex == 0)
    #expect(session.isActive)

    session.completeCurrentStep()
    #expect(session.currentStepIndex == 1)

    session.completeCurrentStep()
    #expect(session.currentStepIndex == 2)

    session.completeCurrentStep()
    #expect(session.isCompleted)
    #expect(session.isActive == false)
}

@Test
func quickWinRecordsCompletionTime() async {
    let session = QuickWinSession(storage: MockStorage())
    let task = QuickWinTask.testTask(stepCount: 1)

    session.start(task: task)
    // Simulate time passing
    try? await Task.sleep(for: .milliseconds(500))
    session.completeCurrentStep()

    #expect(session.completionTimeSeconds > 0)
    #expect(session.completionTimeSeconds < 5)
}

@Test
func quickWinSkipsForReturningUsers() async {
    let storage = MockStorage()
    storage.set(true, forKey: "quickWin_create-first-note_completed")

    let session = QuickWinSession(storage: storage)
    session.start(task: .createFirstNote)

    #expect(session.isActive == false) // Already completed, skip
}

@Test
func quickWinHandlesAbandonment() async {
    let session = QuickWinSession(storage: MockStorage())
    let task = QuickWinTask.testTask(stepCount: 3)

    session.start(task: task)
    session.completeCurrentStep()
    session.abandon()

    #expect(session.isActive == false)
    #expect(session.isCompleted == false)
    #expect(session.abandonedAtStep == 1)
}
```

## Common Patterns

### Start Quick Win Session
```swift
// After onboarding completes
session.start(task: .createFirstNote)
```

### Show Guided Steps
```swift
// Session automatically advances through steps
// Each step shows instruction + highlights target
QuickWinGuideView(session: session)
```

### Celebrate Completion
```swift
// Automatically shown when all steps complete
QuickWinCelebrationView(
    taskTitle: session.completedTask?.title ?? "",
    completionTime: session.completionTimeSeconds
)
```

## Gotchas

- **Don't block experienced users** — Always check completion status before showing. Provide a "Skip" button. Never show again after completion or dismissal.
- **Make it genuinely useful, not just a tutorial** — The quick win should produce a real artifact (a note, a list item, an imported file). Users should feel they accomplished something, not that they watched a demo.
- **Handle interruptions gracefully** — If the user backgrounds the app, navigates away, or receives a notification mid-session, persist progress and resume where they left off.
- **Different quick wins for different user types** — A power user migrating from another app needs a different quick win (import data) than a brand-new user (create first item). Detect context and choose accordingly.
- **Keep it under 60 seconds** — If a quick win takes longer, it's not quick. Trim steps ruthlessly. Three steps is ideal, five is the maximum.
- **Test with real timing** — Run the flow yourself with a stopwatch. If it feels slow, it is slow.

### App Store Guidelines
- **Guideline 5.1.1(v)**: Don't gate the quick win behind account creation — apps may not require sign-in for features that don't functionally need an account. Let users reach their first win before any registration ask.
- **Guideline 2.3.1**: The guided first win must exercise real app functionality — a scripted demo that misrepresents what the app does is a metadata/functionality mismatch.
- **Guideline 4.5.4**: "Finish what you started" re-engagement pushes are promotional — explicit opt-in consent and an in-app opt-out are required.
- **Guideline 4.3 (Spam)**: Onboarding polish doesn't differentiate a thin app. If this is one of several similar apps on your account, run `app-store/originality-check` before submitting.

## References

- **templates.md** — All production Swift templates
- Related: `generators/onboarding-generator` — Full onboarding flow generation
- Related: `generators/milestone-celebration` — Celebration UI for achievements beyond first action

### Source: `ios/accessibility-audit`

# Accessibility Audit

A repeatable audit workflow that takes an app from "we think it's accessible" to evidence: automated audits in CI, an Inspector pass, manual assistive-tech passes, and an Accessibility Nutrition Label evaluation you can defend. Distilled from Apple's WWDC23 "Perform accessibility audits" (10035), WWDC19 "Accessibility Inspector" (257), WWDC25 "Evaluate your app for Accessibility Nutrition Labels" (224), and the 2026 Tech Talk "Prepare your app for Accessibility Nutrition Labels" (111433).

Why it matters: **Accessibility Nutrition Labels** on the App Store make your support (or its absence) visible before download.

## When This Skill Activates

- User asks for an accessibility audit, review, or compliance check
- User is preparing Accessibility Nutrition Label declarations for App Store Connect
- User asks about `performAccessibilityAudit`, Accessibility Inspector, or automated a11y testing
- User mentions EU Accessibility Act / accessibility compliance
- Pre-release checks (pairs with `release-review`)

## The Audit Workflow

### 1. Define common tasks first (WWDC25 224)

List the primary tasks people download the app for, **plus** the fundamentals: first-launch experience, login, purchase, settings. Every subsequent pass evaluates these tasks, on **every device family the app supports**.

### 2. Automated pass — XCUITest audits in CI

`try app.performAccessibilityAudit()` audits the current view exactly as the Inspector does; the test fails automatically on findings. Full API, audit-type table, issue filtering, and CI patterns: **automated-audits.md**. Baseline rules:

- Audits cover only what's on screen — write one audit per distinct screen/state.
- `continueAfterFailure = true` before the audit to surface all issues in one run.
- Filter *accepted* issues via the issue handler — never by skipping whole audit types.

### 3. Inspector pass (WWDC19 257)

Xcode → Open Developer Tool → Accessibility Inspector, target the app:

1. **Run Audit** → each finding highlights the view and offers a Help suggestion.
2. Fix, re-run to zero.
3. **Auto Navigate** through the screen with the speaker button — hear exactly what VoiceOver would say, in order; wrong reading order shows up here.
4. **Point Inspection** for spot checks; **Color Contrast Calculator** (Window menu) for failing pairs.

Classic findings and fixes: filename-as-label (give a real `accessibilityLabel`; move technical IDs to `accessibilityIdentifier`), text drawn via `CATextLayer` invisible to VoiceOver (`isAccessibilityElement = true` + label), contrast below threshold (Inspector flags pairs; fix with darker/lighter variants until it passes).

### 4. Manual assistive-tech passes (per common task)

| Pass | How | Pass criterion |
|---|---|---|
| VoiceOver | Swipe right through every element; double-tap to activate; complete each common task eyes-free | Every element speaks label + trait + value; task completable with gestures only |
| Voice Control | Complete tasks by voice only | Every interactive element has a speakable label (`accessibilityInputLabels` for synonyms) |
| Dynamic Type | Test at 200% and at the largest accessibility size (310%) | Text wraps (never truncates), fields grow, layout adapts |
| Sufficient Contrast | Light + dark appearance, with Increase Contrast on | Legible everywhere |
| Dark Interface | Dark mode + Smart Invert | Photos/video NOT inverted (`accessibilityIgnoresInvertColors`) |
| Reduced Motion | Reduce Motion on | Zoom/slide transitions, autoplay, parallax replaced (modified, not just removed) |
| Keyboard (Mac / iPad FKA) | Complete tasks keyboard-only | Focus reaches everything; no hover-only affordances |

### 5. Nutrition Label evaluation and declaration

Map the evidence from passes 2–4 onto the nine App Store features and declare only what holds for **all** common tasks on **all** supported device families. Per-feature criteria, disqualifier examples, and the declaration flow: **nutrition-labels.md**. The model behavior (Apple's own demo): find bugs at 235%/310% text size → **fix first, claim after**.

## Output Format

Report findings as:

- 🔴 Critical — blocks an assistive-tech user from completing a common task (unlabeled control on the purchase path, VoiceOver trap, text that doesn't scale)
- 🟠 High — feature claim at risk (truncation at accessibility sizes, color-only state, missing captions)
- 🟡 Medium — friction (bad reading order, unclear labels, missing rotors/actions)
- 🟢 Low — polish (verbosity, missing synonyms, hint quality)
- ✅ Strengths — passes worth keeping (cite the pass that proved them)

For each finding: the screen/task, the failing feature category, the fix (API-level), and which audit pass detects the regression.

## Cross-References

- `generators/accessibility-generator` — implementation patterns (labels, Dynamic Type, custom actions, rotors) to fix what the audit finds
- `macos/ui-review-tahoe/accessibility.md` — Mac-specific VoiceOver/keyboard depth
- `ios/assistive-access` — the separate Assistive Access experience (cognitive disabilities)
- `design/typography` — Dynamic Type design rules
- `release-review` — this audit slots into the pre-release gate

## References

- **automated-audits.md** (this skill) — performAccessibilityAudit API, audit types, CI patterns, Inspector workflow
- **nutrition-labels.md** (this skill) — the nine features, per-feature criteria, evaluation + declaration process
- [WWDC23 — Perform accessibility audits for your app](https://developer.apple.com/videos/play/wwdc2023/10035/)
- [WWDC25 — Evaluate your app for Accessibility Nutrition Labels](https://developer.apple.com/videos/play/wwdc2025/224/)
- [Tech Talk — Prepare your app for Accessibility Nutrition Labels](https://developer.apple.com/videos/play/tech-talks/111433/)
- [Accessibility Nutrition Labels evaluation criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels)

### Source: `ios/ui-review`

# UI Review Skill

Performs comprehensive UI/UX review of SwiftUI code against Apple's Human Interface Guidelines, font best practices, and accessibility standards for iOS and watchOS.

## When This Skill Activates

Use this skill when the user:
- Asks to review UI/UX code
- Mentions HIG compliance or Apple guidelines
- Requests accessibility audit
- Wants font usage checked
- Asks about Dynamic Type support
- Requests design review against Apple standards

## Review Process

### 1. Identify Files to Review

- If user specifies files/views, review those
- Otherwise, ask which views to review or scan recent SwiftUI files
- Prioritize user-facing views over components

### 2. Load Reference Materials

Before starting the review, familiarize yourself with the reference materials by reading the following files in `.claude/skills/ui-review/`:

- **hig-checklist.md** - Comprehensive HIG compliance checklist for iOS and watchOS
- **font-guidelines.md** - Font usage, Dynamic Type, and typography best practices
- **accessibility-quick-ref.md** - Quick reference for accessibility implementation

You may also reference the official Apple guidelines using WebFetch when needed:
- **iOS HIG**: https://developer.apple.com/design/human-interface-guidelines/designing-for-ios
- **watchOS HIG**: https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos

### 3. Review Categories

Apply these review categories based on the code type:

**HIG Compliance:**
- Layout & spacing (tap targets, safe areas, padding)
- Navigation patterns (NavigationStack, sheets, alerts)
- Colors & visuals (semantic colors, dark mode, contrast)
- Platform-specific requirements (iOS vs watchOS)
- Loading/empty/error states

**Font Usage:**
- Dynamic Type support
- System text styles vs fixed sizes
- Font hierarchy and semantic usage
- Custom fonts scaling properly
- Text formatting and truncation

**Accessibility:**
- Labels and hints for interactive elements
- Traits and roles
- VoiceOver navigation order
- Custom actions
- Dynamic content announcements
- Testing with assistive technologies

### 4. Common Issues to Flag

**Anti-patterns:**
- Hardcoded colors (`.foregroundColor(.black)`)
- Fixed font sizes (`.font(.system(size: 14))`)
- Missing accessibility labels on icon-only buttons
- Tap targets smaller than 44pt (iOS) or 40pt (watchOS)
- Important info conveyed by color only
- Missing loading/error states
- Direct UIColor usage (use `Color(.systemBackground)`)
- `.frame()` without considering Dynamic Type expansion
- Missing keyboard shortcuts (iPad/Mac)

**Good Patterns:**
- Semantic color usage
- System font styles with Dynamic Type
- Comprehensive accessibility labels
- Clear visual hierarchy
- Consistent spacing
- Proper error handling
- Responsive layouts

### 5. Component Checklists

Apply when the reviewed code contains the component.

**Search UX (WWDC26):**
- [ ] Standard Search Field anatomy intact — leading magnifying-glass icon, placeholder, clear button; on iOS a Cancel button appears while focused. Don't rebuild these from scratch
- [ ] iOS placement: prefer the bottom toolbar — it animates above the keyboard and stays within thumb reach
- [ ] Tab apps: exactly one primary Search tab, not a search field per tab
- [ ] iPad/Mac placement: trailing side of the toolbar, or pinned at the top of the sidebar
- [ ] Recent searches shown on focus, with per-item removal and a clear-all affordance
- [ ] Suggestions correspond to the typed text, visually distinguish the user's input from the predicted part, and are limited in count
- [ ] Scope Bar used for lightweight filtering of where to search (e.g. All / Sender / Subject)
- [ ] Search Tokens supplement — never replace — visible filter UI (tokens are less discoverable)
- [ ] Empty results show a Content Unavailable view (`ContentUnavailableView.search`), not a blank list

**Menus & Pickers (WWDC20):**
- [ ] Menus preferred over action sheets/popovers for NON-destructive actions — the menu opens adjacent to the tap (less eye/finger travel) and doesn't dim the screen
- [ ] Action sheets kept for destructive confirmation — their friction is deliberate
- [ ] Never ALL primary actions hidden in a menu or "more" (ellipsis) button — menus hold secondary actions only
- [ ] Each menu fits one of four uses: disambiguation, navigation, selection (check marks required), or secondary actions
- [ ] Menu anatomy: label on the left, icon on the right, separators to group — and NO Cancel item (tapping outside cancels)
- [ ] Date pickers: inline (calendar) when space allows, compact style when constrained

## Output Format

Provide review in this structure:

### ✅ HIG Compliance
- List items that comply well
- Highlight good practices

### ⚠️ HIG Issues Found
- Specific line references: `filename.swift:lineNumber`
- Description of issue
- Suggested fix with code example

### ✅ Font Usage
- Proper Dynamic Type usage
- Good font hierarchy

### ⚠️ Font Issues Found
- Hardcoded sizes or missing Dynamic Type support
- Suggested fixes

### ✅ Accessibility
- Well-implemented accessibility features
- Good label/hint usage

### ⚠️ Accessibility Issues Found
- Missing labels or hints
- Incorrect traits
- Navigation problems
- Suggested fixes with code examples

### 📋 Testing Recommendations
- Specific tests to run (VoiceOver, Dynamic Type, Dark Mode)
- Accessibility Inspector checks
- Device/simulator testing suggestions

## Example Review Output

```
Reviewing: AddOrUpdateExpenseView.swift

✅ HIG Compliance
- Good use of semantic colors throughout
- Proper NavigationStack implementation
- Safe area handling is correct

⚠️ HIG Issues Found
1. AddOrUpdateExpenseView.swift:145 - Delete button tap target may be small
   Suggested fix: Ensure .frame(minWidth: 44, minHeight: 44)

2. AddOrUpdateExpenseView.swift:203 - Hardcoded color
   Current: .foregroundColor(.red)
   Suggested: .foregroundColor(Color(.systemRed))

✅ Font Usage
- Excellent use of .headline for section headers
- Proper .body for content text

⚠️ Font Issues Found
1. AddOrUpdateExpenseView.swift:178 - Hardcoded font size
   Current: .font(.system(size: 14))
   Suggested: .font(.subheadline)

✅ Accessibility
- Good labels on most form fields
- Proper form structure

⚠️ Accessibility Issues Found
1. AddOrUpdateExpenseView.swift:92 - Icon button missing label
   Current: Button { } label: { Image(systemName: "calendar") }
   Suggested: Add .accessibilityLabel("Select date")

📋 Testing Recommendations
1. Test with VoiceOver enabled
2. Test at largest Dynamic Type size (Accessibility → Display)
3. Verify in Dark Mode
4. Use Accessibility Inspector to check contrast ratios
```

## References

Always reference these when in doubt:
- [iOS HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)
- [watchOS HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [Accessibility on Apple platforms](https://developer.apple.com/accessibility/)

## Notes

- Be constructive and specific
- Provide code examples for fixes
- Reference exact line numbers
- Prioritize user-impacting issues
- Consider context (some exceptions are valid)

### Source: `ios-liquid-glass-designer`

# iOS Liquid Glass Designer

Use native iOS 26+ Liquid Glass APIs first. Keep glass grouped, interactive only when appropriate, performance aware, and backed by non-glass fallback UI.

## Paths

- Review: inspect where glass belongs, modifier order, shape consistency, `GlassEffectContainer`, availability, and fallback.
- Improve: target surfaces/chips/buttons/cards, group multiple glass elements, and make only tappable/focusable elements interactive.
- New feature: design shapes/prominence/grouping first, apply glass after layout/appearance modifiers, and add morphing only for animated hierarchy changes.

## Rules

- Prefer native APIs over custom blurs.
- Use `GlassEffectContainer` for multiple glass views.
- Apply `.glassEffect(...)` after layout and visual modifiers.
- Use `.interactive()` only for interactive elements.
- Keep related shapes, tinting, spacing, and prominence consistent.
- Gate with `#available(iOS 26, *)` and provide a fallback.
- Use `.buttonStyle(.glass)` or `.buttonStyle(.glassProminent)` for actions.
- Use `glassEffectID` with `@Namespace` only for morphing transitions.

## Snippets

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

```swift
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Image(systemName: "scribble.variable")
            .frame(width: 72, height: 72)
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 72, height: 72)
            .glassEffect()
    }
}
```

```swift
Button("Confirm") { }
    .buttonStyle(.glassProminent)
```

## Resources

Read `references/liquid-glass.md` for details. Use current Apple docs when API details may have changed.

### Source: `karpathy-guidelines`

# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
