# Integrated Reference Bundle 10

Combines 12 related source skills from `ios-swift-platform` into one navigable reference file.

## Source map

- `swiftui_0533/alarmkit/SKILL.reference.md`
- `swiftui_1667/SKILL.reference.md`
- `swiftui_1667/alarmkit/SKILL.reference.md`
- `swiftui_1667/charts-3d/SKILL.reference.md`
- `swiftui_1667/data-flow/SKILL.reference.md`
- `swiftui_1667/text-editing/SKILL.reference.md`
- `swiftui_1667/toolbars/SKILL.reference.md`
- `swiftui_1667/webkit/SKILL.reference.md`
- `swiftui_1667/whats-new-27/SKILL.reference.md`
- `visionos/SKILL.reference.md`
- `visionos/widgets/SKILL.reference.md`
- `watchos/SKILL.reference.md`

## Integrated guidance

### Source: `swiftui_0533/alarmkit`

# AlarmKit

Framework for scheduling alarms and countdown timers with custom UI, Live Activities integration, and focus/silent mode override. Prevents the most common mistakes: using the wrong authorization property name, omitting the Info.plist key, and forgetting the widget extension for countdown presentations.

## When This Skill Activates

Use this skill when the user:
- Asks to add, fix, or review **alarm** or **timer** functionality
- Mentions **AlarmKit**, **AlarmManager**, or **AlarmPresentation**
- Wants to schedule **one-time**, **repeating**, or **countdown** alarms
- Asks about **snooze**, **stop**, or **repeat** buttons on alarm alerts
- Wants alarms to appear on **Dynamic Island** or **Lock Screen** (Live Activities)
- Mentions overriding **Focus** or **silent mode** for alarms
- Asks about **AlarmAttributes** or **AlarmMetadata**

## Decision Tree

Choose the right reference file based on what the user needs:

```
What do you need?
|
+-- Schedule an alarm (one-time, repeating, or timer)
|   --> scheduling.md
|       +-- One-time alarm: Alarm.Schedule.relative + .repeats: .never
|       +-- Repeating alarm: Alarm.Schedule.relative + .repeats: .weekly(weekdays)
|       +-- Countdown timer: CountdownDuration (no schedule)
|       +-- Authorization & Info.plist setup
|       +-- Managing alarms: pause, resume, cancel
|
+-- Customize alarm UI (alert, countdown, paused screens)
|   --> presentation.md
|       +-- AlarmPresentation.Alert: title, stop, snooze/repeat buttons
|       +-- AlarmPresentation.Countdown: title, pause button
|       +-- AlarmPresentation.Paused: title, resume button
|       +-- Custom buttons with AlarmButton
|       +-- Tint color and metadata via AlarmAttributes
|
+-- Show alarm on Dynamic Island / Lock Screen
    --> live-activities.md
        +-- Widget extension with ActivityConfiguration
        +-- AlarmAttributes conformance
        +-- Custom AlarmMetadata protocol
```

## API Availability

| API | Minimum Version | Reference |
|-----|----------------|-----------|
| `AlarmManager` | iOS 26 | scheduling.md |
| `Alarm` / `Alarm.Schedule` | iOS 26 | scheduling.md |
| `AlarmPresentation` (.alert, .countdown, .paused) | iOS 26 | presentation.md |
| `AlarmAttributes` | iOS 26 | live-activities.md |
| `AlarmMetadata` | iOS 26 | live-activities.md |
| `AlarmButton` | iOS 26 | presentation.md |
| `CountdownDuration` | iOS 26 | scheduling.md |
| `alarmUpdates` async sequence | iOS 26 | scheduling.md |
| `authorizationUpdates` async sequence | iOS 26 | scheduling.md |

## Top Mistakes -- Quick Reference

| # | Mistake | Fix | Details |
|---|---------|-----|---------|
| 1 | Using `.authorizationStatus` instead of `.authorizationState` | The property is `AlarmManager.shared.authorizationState` -- there is no `authorizationStatus` | scheduling.md |
| 2 | Forgetting `NSAlarmKitUsageDescription` in Info.plist | Add the key with a user-facing string before calling `requestAuthorization()` | scheduling.md |
| 3 | Creating countdown timer with a schedule | Timers use `CountdownDuration` only -- do not pass a schedule | scheduling.md |
| 4 | Missing widget extension for countdown presentations | Countdown and paused UI requires an `ActivityConfiguration(for: AlarmAttributes.self)` widget | live-activities.md |
| 5 | Not persisting alarm UUIDs | Store the `Alarm.id` (UUID) so you can pause, resume, or cancel later | scheduling.md |
| 6 | Not observing `alarmUpdates` for state sync | Use the `alarmUpdates` async sequence to keep local state in sync with the system | scheduling.md |

## Review Checklist

When reviewing AlarmKit code, verify:

- [ ] **Info.plist** -- `NSAlarmKitUsageDescription` is present with a meaningful description
- [ ] **Authorization** -- `requestAuthorization()` is called before scheduling; denial is handled gracefully
- [ ] **Correct property** -- uses `.authorizationState`, not `.authorizationStatus`
- [ ] **Alarm ID persistence** -- alarm UUIDs are stored (e.g., UserDefaults, SwiftData) for later management
- [ ] **State observation** -- `alarmUpdates` async sequence is used to keep UI in sync
- [ ] **Widget extension** -- exists if countdown or paused presentations are used
- [ ] **Error handling** -- `schedule()`, `pause()`, `resume()`, `cancel()` calls handle errors
- [ ] **System limits** -- code accounts for the system limit on number of active alarms
- [ ] **Real device testing** -- alarms are tested on physical devices, not just Simulator

## Reference Files

| File | Content |
|------|---------|
| [scheduling.md](scheduling.md) | Authorization, one-time/repeating/timer creation, managing alarms, observing updates |
| [presentation.md](presentation.md) | Alert, countdown, paused UI customization, buttons, tint color |
| [live-activities.md](live-activities.md) | Widget extension, AlarmAttributes, AlarmMetadata, Dynamic Island |

### Source: `swiftui_1667`

# SwiftUI Toolkit

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
- Builds for **iOS 27**: reorder or swipe outside `List`, toolbar overflow, alerts from errors, foldable-iPhone prep (whats-new-27)

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
| whats-new-27 | `whats-new-27/SKILL.md` | iOS 27 additions: reorder/swipe in any container, item/error alerts, toolbar priority + overflow, @State macro, 27.1 foldable APIs |

## How to Route

1. Match the request to a row above.
2. Read that SKILL.md (relative to this file) plus any reference files it lists.
3. Apply the guidance to the user's code.

### Source: `swiftui_1667/alarmkit`

# AlarmKit

Framework for scheduling alarms and countdown timers with custom UI, Live Activities integration, and focus/silent mode override. Prevents the most common mistakes: inventing a result-builder scheduling API, convenience buttons that don't exist, the deprecated `stopButton`, the wrong authorization property, and a missing widget extension for countdowns. All code here compiles against the iOS 27 SDK.

## When This Skill Activates

Use this skill when the user:
- Asks to add, fix, or review **alarm** or **timer** functionality
- Mentions **AlarmKit**, **AlarmManager**, or **AlarmPresentation**
- Wants to schedule **one-time**, **repeating**, or **countdown** alarms
- Asks about **snooze**, **stop**, or **repeat** buttons on alarm alerts
- Wants alarms to appear on **Dynamic Island** or **Lock Screen** (Live Activities)
- Mentions overriding **Focus** or **silent mode** for alarms
- Asks about **AlarmAttributes** or **AlarmMetadata**

## Decision Tree

```
What do you need?
|
+-- Schedule an alarm or timer          --> scheduling.md
|   +-- One moment:            .alarm(schedule: .fixed(date), attributes:)
|   +-- Daily/weekly time:     .alarm(schedule: .relative(.init(time:, repeats: .weekly([...]))), attributes:)
|   +-- Countdown timer:       .timer(duration:, attributes:)          (no schedule)
|   +-- Snooze / repeat:       AlarmConfiguration(countdownDuration: .init(preAlert:, postAlert:), ...)
|   +-- Authorization, managing (pause/resume/cancel), observing alarmUpdates
|
+-- Customize what the system shows     --> presentation.md
|   +-- AlarmPresentation(alert:countdown:paused:), AlarmButton(text:textColor:systemImageName:)
|   +-- secondaryButtonBehavior: .countdown (snooze) vs .custom (your intent)
|   +-- AlarmAttributes<Metadata>(presentation:metadata:tintColor:)
|
+-- Lock Screen / Dynamic Island        --> live-activities.md
    +-- ActivityConfiguration(for: AlarmAttributes<YourMetadata>.self)
    +-- Draw context.state.mode (.countdown / .paused / .alert)
```

## The API in one block

```swift
let attributes = AlarmAttributes<TimerMetadata>(            // TimerMetadata: AlarmMetadata (required, even if unused)
    presentation: AlarmPresentation(alert: .init(title: "Time's Up")),
    tintColor: .orange
)
let alarm = try await AlarmManager.shared.schedule(
    id: UUID(),
    configuration: .timer(duration: 10 * 60, attributes: attributes)
)
try AlarmManager.shared.cancel(id: alarm.id)                // management calls are sync + throwing
```

## API Availability

| API | Minimum | Notes |
|---|---|---|
| `AlarmManager`, `Alarm`, `AlarmPresentation`, `AlarmAttributes`, `AlarmButton`, `AlarmMetadata` | iOS 26 | |
| `AlarmPresentation.Alert(title:stopButton:…)` | deprecated iOS 26.1 | `stopButton` ignored; system provides stop |
| `AlarmConfiguration(…, appEntityIdentifier:)`, `.alarm/.timer(…, appEntityIdentifier:)` | iOS 27 | Link an alarm to an App Intents entity |

## Top Mistakes

| # | ❌ Mistake | ✅ Fix |
|---|---|---|
| 1 | `schedule(id:) { … }` result-builder style | `schedule(id:configuration:)` with an `AlarmConfiguration` value |
| 2 | `AlarmButton(label:)`, `.snoozeButton()`, `.repeatButton()` | `AlarmButton(text:textColor:systemImageName:)`; snooze = secondary button + `.countdown` + `postAlert` |
| 3 | `authorizationStatus`; `requestAuthorization()` without `try` | `authorizationState`; `try await requestAuthorization()` |
| 4 | Passing `stopButton:` | Removed in practice (deprecated 26.1); omit it |
| 5 | `AlarmAttributes` used without a metadata type | `AlarmAttributes<YourMetadata>` everywhere, same type in app and widget |
| 6 | Countdown without a widget extension | `ActivityConfiguration(for: AlarmAttributes<YourMetadata>.self)` |
| 7 | `try await pause(id:)` | `try AlarmManager.shared.pause(id:)` (synchronous) |
| 8 | Missing `NSAlarmKitUsageDescription` | Add it to Info.plist before requesting authorization |

## Reference Files

| File | Content |
|------|---------|
| [scheduling.md](scheduling.md) | Authorization, one-time/repeating/timer creation, managing alarms, observing updates |
| [presentation.md](presentation.md) | Alert, countdown, paused UI customization, buttons, tint color |
| [live-activities.md](live-activities.md) | Widget extension, AlarmAttributes, AlarmMetadata, Dynamic Island |

## References

- AlarmKit: https://developer.apple.com/documentation/alarmkit
- Local SDK truth: `AlarmKit.swiftinterface` in the iOS 27 SDK
- Related: `generators/live-activity-generator`, `generators/widget-generator`, `apple-intelligence/app-intents`

### Source: `swiftui_1667/charts-3d`

# 3D Charts with Swift Charts

Create 3D data visualizations using `Chart3D` and `SurfacePlot`. Covers math-driven surfaces, data-driven surfaces, interactive camera pose control, surface styling, and camera projection modes.

## When This Skill Activates

Use this skill when the user:
- Wants to create a 3D chart or 3D data visualization
- Asks about `Chart3D`, `SurfacePlot`, or 3D surface plots
- Needs to visualize a mathematical function as a 3D surface
- Wants interactive drag-to-rotate on a 3D chart
- Asks about 3D chart camera angles, pose, or projection
- Needs to style 3D surfaces with gradients or height-based coloring
- Wants to render multiple surfaces in a single 3D chart
- Asks about data-driven 3D plots from an array of points
- Needs the 2D Swift Charts API layer: marks, axes, series styling, selection, SectorMark pies/donuts, or scrollable charts

## Decision Tree

```
What 3D chart feature do you need?
|
+-- Visualize a math function f(x, y) -> z
|   +-- Use SurfacePlot(x:y:z:function:)
|
+-- Visualize data points as a surface
|   +-- Use Chart3D(data) { point in SurfacePlot(...) }
|
+-- Interactive drag-to-rotate
|   +-- Bind pose: .chart3DPose($pose) with @State var pose: Chart3DPose
|
+-- Fixed viewing angle (no interaction)
|   +-- Read-only pose: .chart3DPose(Chart3DPose.front) or custom
|
+-- Style the surface color
|   +-- Solid color -> .foregroundStyle(Color.blue)
|   +-- Gradient -> .foregroundStyle(LinearGradient(...))
|   +-- Height-based -> .foregroundStyle(.heightBased(gradient, yRange:))
|   +-- Normal-based -> .foregroundStyle(.normalBased)
|
+-- Camera projection
|   +-- Perspective (depth) -> .chart3DCameraProjection(.perspective)
|   +-- Orthographic (flat) -> .chart3DCameraProjection(.orthographic)
|   +-- System default -> .chart3DCameraProjection(.automatic)
|
+-- Multiple surfaces in one chart
    +-- Place multiple SurfacePlot calls inside a single Chart3D { }
```

## API Availability

| API | Minimum Version | Import | Notes |
|-----|----------------|--------|-------|
| `Chart3D` | iOS 26 / macOS 26 | `Charts` | Main 3D chart container |
| `SurfacePlot` | iOS 26 / macOS 26 | `Charts` | 3D surface mark |
| `Chart3DPose` | iOS 26 / macOS 26 | `Charts` | Viewing angle control |
| `Chart3DCameraProjection` | iOS 26 / macOS 26 | `Charts` | `.automatic`, `.perspective`, `.orthographic` |
| `Chart3DSurfaceStyle` | iOS 26 / macOS 26 | `Charts` | `.heightBased`, `.normalBased` |

## Quick Start

### Math-Driven Surface

Render a surface from a function `f(x, y) -> z`:

```swift
import SwiftUI
import Charts

struct WaveSurfaceView: View {
    var body: some View {
        Chart3D {
            SurfacePlot(
                x: "X",
                y: "Height",
                z: "Z",
                function: { x, z in
                    sin(x) * cos(z)
                }
            )
            .foregroundStyle(.blue)
        }
    }
}
```

### Data-Driven Surface

Render a surface from an array of data points:

```swift
import SwiftUI
import Charts

struct DataPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
    let z: Double
}

struct DataSurfaceView: View {
    let points: [DataPoint]

    var body: some View {
        Chart3D(points) { point in
            SurfacePlot(
                x: .value("X", point.x),
                y: .value("Height", point.y),
                z: .value("Z", point.z)
            )
        }
    }
}
```

### Interactive Rotation

Allow the user to drag to rotate the chart:

```swift
import SwiftUI
import Charts

struct InteractiveChartView: View {
    @State private var pose = Chart3DPose.default

    var body: some View {
        Chart3D {
            SurfacePlot(
                x: "X",
                y: "Height",
                z: "Z",
                function: { x, z in
                    sin(x) * cos(z)
                }
            )
            .foregroundStyle(.blue)
        }
        .chart3DPose($pose)
    }
}
```

## Surface Styling Patterns

### Solid Color

```swift
SurfacePlot(x: "X", y: "Y", z: "Z", function: { x, z in x * z })
    .foregroundStyle(.blue)
```

### Linear Gradient

```swift
SurfacePlot(x: "X", y: "Y", z: "Z", function: { x, z in x * z })
    .foregroundStyle(
        LinearGradient(
            colors: [.blue, .green, .yellow],
            startPoint: .bottom,
            endPoint: .top
        )
    )
```

### Height-Based Surface Style

Color the surface based on height values, mapping a gradient across the y-axis range:

```swift
SurfacePlot(x: "X", y: "Y", z: "Z", function: { x, z in sin(x) * cos(z) })
    .foregroundStyle(
        Chart3DSurfaceStyle.heightBased(
            Gradient(colors: [.blue, .cyan, .green, .yellow, .red]),
            yRange: -1...1
        )
    )
```

### Normal-Based Surface Style

Color based on surface normals, giving a lighting-aware appearance:

```swift
SurfacePlot(x: "X", y: "Y", z: "Z", function: { x, z in sin(x) * cos(z) })
    .foregroundStyle(Chart3DSurfaceStyle.normalBased)
```

### Surface Roughness

Control surface shininess (0 = reflective, 1 = matte):

```swift
SurfacePlot(x: "X", y: "Y", z: "Z", function: { x, z in sin(x) * cos(z) })
    .foregroundStyle(.blue)
    .roughness(0.3)
```

## Interactive Pose Control

### Preset Poses

`Chart3DPose` provides built-in presets for common viewing angles:

```swift
.chart3DPose(.default)   // Standard 3/4 angle
.chart3DPose(.front)     // Viewing from front
.chart3DPose(.back)      // Viewing from back
.chart3DPose(.top)       // Top-down view
.chart3DPose(.bottom)    // Bottom-up view
.chart3DPose(.right)     // Right side view
.chart3DPose(.left)      // Left side view
```

### Custom Pose

Specify exact azimuth (horizontal rotation) and inclination (vertical tilt):

```swift
.chart3DPose(
    Chart3DPose(azimuth: .degrees(45), inclination: .degrees(30))
)
```

### Anti-Patterns

```swift
// ❌ Passing a literal where a binding is needed for interactivity
.chart3DPose(.default) // This is read-only; drag gestures will not work

// ✅ Use a @State binding for interactive rotation
@State private var pose = Chart3DPose.default
// ...
.chart3DPose($pose)
```

## Camera Projection

Control how 3D depth is rendered:

```swift
Chart3D {
    SurfacePlot(x: "X", y: "Y", z: "Z", function: { x, z in sin(x) * cos(z) })
        .foregroundStyle(.blue)
}
.chart3DCameraProjection(.perspective)   // Objects farther away appear smaller
// .chart3DCameraProjection(.orthographic)  // No perspective distortion
// .chart3DCameraProjection(.automatic)     // System decides
```

## Multiple Surfaces

Render multiple surfaces in a single chart for comparison:

```swift
import SwiftUI
import Charts

struct ComparisonChartView: View {
    @State private var pose = Chart3DPose.default

    var body: some View {
        Chart3D {
            SurfacePlot(
                x: "X",
                y: "Wave A",
                z: "Z",
                function: { x, z in sin(x) * cos(z) }
            )
            .foregroundStyle(.blue.opacity(0.8))

            SurfacePlot(
                x: "X",
                y: "Wave B",
                z: "Z",
                function: { x, z in cos(x) * sin(z) }
            )
            .foregroundStyle(.red.opacity(0.8))
        }
        .chart3DPose($pose)
        .chart3DCameraProjection(.perspective)
    }
}
```

## Complete Example

A full-featured 3D chart with height-based coloring, interactive rotation, and perspective projection:

```swift
import SwiftUI
import Charts

struct TerrainView: View {
    @State private var pose = Chart3DPose(
        azimuth: .degrees(30),
        inclination: .degrees(25)
    )

    var body: some View {
        VStack {
            Text("Terrain Visualization")
                .font(.headline)

            Chart3D {
                SurfacePlot(
                    x: "Longitude",
                    y: "Elevation",
                    z: "Latitude",
                    function: { x, z in
                        let distance = sqrt(x * x + z * z)
                        return sin(distance) / max(distance, 0.1)
                    }
                )
                .foregroundStyle(
                    Chart3DSurfaceStyle.heightBased(
                        Gradient(colors: [
                            .blue, .cyan, .green, .yellow, .orange, .red
                        ]),
                        yRange: -0.5...1.0
                    )
                )
                .roughness(0.4)
            }
            .chart3DPose($pose)
            .chart3DCameraProjection(.perspective)
        }
        .padding()
    }
}
```

## Chart Design Fundamentals (WWDC22)

These apply to every chart you build — 2D or 3D. The pillars: **focused, approachable, accessible**.

- **Pick marks by goal**: bars for patterns, ranges, and individual values; points for spotting outliers; lines for rates of change.
- **Test with real, noisy data early** — placeholder sine waves hide layout failures. Design the edge cases explicitly (e.g., gaps in a line chart where data is missing).
- **~4 horizontal gridlines** is a good baseline; pick intuitive intervals — multiples of 20 for counts, multiples of 7 for day-based axes.
- **Descriptive takeaway title** ("Total Sales: 1,234 Pancakes"), not a generic label ("Sales") — and give the chart surrounding context.
- **Touch targets stretch to full chart height** — a tap anywhere in a bar's column selects it, not just the drawn pixels.
- Support **touch, keyboard, Voice Control, Switch Control, and VoiceOver equally** — every interaction needs a non-pointer path.
- **Color enhances, never solely conveys** — differentiate series with symbols/shapes first, color second. Verify contrast in Dark, Light, and Increase Contrast, and balance saturation so no series visually outweighs the others.
- **Every visual encoding needs a non-visual representation** — per-mark VoiceOver labels and an Audio Graph descriptor; Swift Charts provides both by default, so don't break them with custom drawing. Custom-drawn charts implement them by hand — see "Audio Graphs: AXChartDescriptor" below.

## Swift Charts Construction Reference (2D)

The design fundamentals above apply to every chart; this is the API layer for standard 2D charts (iOS 16+ unless noted; selection, SectorMark, and scrolling are iOS 17+).

### Marks Compose

A `Chart` is a composition of marks — `BarMark`, `LineMark`, `PointMark`, `AreaMark`, `RuleMark`, `RectangleMark`. The `.value("Label", v)` factory arguments do double duty: they bind data AND drive the automatic axes and legend, so label them meaningfully:

```swift
Chart(salesData) { sale in          // Identifiable data — no explicit ForEach needed
    BarMark(
        x: .value("Day", sale.day, unit: .day),   // unit: .day buckets temporal values per day
        y: .value("Sales", sale.count)
    )
}
```

- Transpose a chart by swapping the x/y value pairs — horizontal bars need no other change.
- `unit:` (`.day`, `.month`, `.hour`) controls temporal bucketing; omit it and every timestamp is its own position.

### Series: Style + Symbol, Never Color Alone

`.foregroundStyle(by:)` splits marks into series; pair it with `.symbol(by:)` so series stay distinguishable without color (WWDC22):

```swift
Chart(data) { point in
    LineMark(x: .value("Day", point.day), y: .value("Sales", point.sales))
        .foregroundStyle(by: .value("City", point.city))
        .symbol(by: .value("City", point.city))
}
```

- Remap series colors with `.chartForegroundStyleScale(["Cupertino": .indigo, "San Francisco": .teal])`.
- `.position(by: .value("City", point.city))` converts stacked bars into grouped bars.

### Pin Scales for Stability

Pin scales so a filtered dataset doesn't make the whole chart jump:

```swift
.chartYScale(domain: 0...maxExpectedSales)
.chartXScale(domain: startDate...endDate)
```

### Composing Statistics into a Chart

Marks compose freely, so summary statistics are just more marks:

```swift
Chart {
    ForEach(data) { point in
        AreaMark(                                    // min–max band
            x: .value("Day", point.day),
            yStart: .value("Min", point.min),
            yEnd: .value("Max", point.max)
        )
        .opacity(0.3)

        LineMark(x: .value("Day", point.day), y: .value("Average", point.average))
    }

    RuleMark(y: .value("Overall", overallAverage))   // overall average line
        .foregroundStyle(.secondary)
        .annotation(position: .top, alignment: .leading) {
            Text("Avg: \(overallAverage, format: .number.precision(.fractionLength(0)))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
}
```

### Axes Are Builders

```swift
.chartXAxis {
    AxisMarks(values: .stride(by: .month)) { value in
        AxisGridLine()
        AxisTick()
        AxisValueLabel(format: .dateTime.month(.narrow))
    }
}
.chartYAxis {
    AxisMarks(position: .leading)   // move the value axis to the leading edge
}
```

- Conditional styling belongs *inside* the builder — check `value.as(Date.self)` in the closure to, say, bold only the first month of each quarter.
- `.chartXAxis(.hidden)` removes an axis entirely; `.chartPlotStyle { $0.frame(height: 200).background(.gray.opacity(0.05)).border(.quaternary) }` sizes and styles the plot area itself.

### Interactivity: Selection First

Prefer the built-in selection binding over hand-rolled overlay gestures (iOS 17):

```swift
@State private var selectedDay: Date?

Chart(data) { ... }
    .chartXSelection(value: $selectedDay)
```

Render the selection as marks — a `RuleMark` with `zIndex(-1)` so it draws behind the data, and an annotation that stays inside the plot:

```swift
if let selectedDay {
    RuleMark(x: .value("Selected", selectedDay, unit: .day))
        .foregroundStyle(.gray.opacity(0.3))
        .zIndex(-1)
        .annotation(
            position: .top, spacing: 0,
            overflowResolution: .init(x: .fit(to: .chart), y: .disabled)
        ) {
            SelectionDetailCard(day: selectedDay)
        }
}
```

For fully custom hit-testing, drop to `ChartProxy` inside `.chartOverlay` with a `GeometryReader`: `proxy.value(atX:)` converts gesture locations to data values, `proxy.position(forX:)` converts back.

### SectorMark: Pies and Donuts (iOS 17+)

```swift
Chart(data) { item in
    SectorMark(
        angle: .value("Sales", item.sales),
        innerRadius: .ratio(0.62),     // donut hole
        angularInset: 1.5              // 1.5 per side = 3pt gaps between sectors
    )
    .clipShape(.rect(cornerRadius: 4))
    .foregroundStyle(by: .value("Name", item.name))
}
.chartBackground { proxy in
    GeometryReader { geo in            // headline metric in the donut hole
        if let anchor = proxy.plotFrame {
            let frame = geo[anchor]
            Text("Best: \(topSellerName)")
                .position(x: frame.midX, y: frame.midY)
        }
    }
}
```

### Large Datasets: Scroll a Window

Don't cram a year into one screen — show a window and scroll (WWDC23):

```swift
Chart(yearOfData) { ... }
    .chartScrollableAxes(.horizontal)
    .chartXVisibleDomain(length: 3600 * 24 * 30)   // 30-day window
    .chartScrollPosition(x: $scrollDate)           // read/write the scroll offset
    .chartScrollTargetBehavior(
        .valueAligned(
            matching: DateComponents(hour: 0),                    // land on day boundaries
            majorAlignment: .matching(DateComponents(day: 1))     // snap paging to month starts
        )
    )
```

### Accessibility Per Mark

Auto-generated VoiceOver descriptions read raw values; per-mark labels beat them:

```swift
BarMark(x: .value("Day", sale.day, unit: .day), y: .value("Sales", sale.count))
    .accessibilityLabel(sale.day.formatted(date: .abbreviated, time: .omitted))
    .accessibilityValue("\(sale.count) pancakes sold")
```

With hundreds or thousands of points, bucket into reasonable intervals and expose one
accessibility element per interval rather than per point (WWDC21 10122).

### Audio Graphs: AXChartDescriptor (WWDC21 10122)

Audio Graphs let VoiceOver play a data series as a continuous tone — pitch = Y value,
time = X position — with an explorer view (rotor → "Audio Graph" → Chart Details) that
plays the sonification, scrubs it (double-tap-and-hold; pausing speaks the value at the
current position), and shows automatically computed summary statistics. Swift Charts
generates a default descriptor; custom-drawn charts conform to `AXChart` (UIKit) or use
the `.accessibilityChartDescriptor(_:)` modifier with an `AXChartDescriptorRepresentable`
(SwiftUI, iOS 15+):

```swift
var accessibilityChartDescriptor: AXChartDescriptor? {
    let xAxis = AXNumericDataAxisDescriptor(
        title: "Cups of coffee",
        range: 0...10,
        gridlinePositions: [],                              // gridlines render as haptics during playback
        valueDescriptionProvider: { "\(Int($0)) cups" })    // "5 cups", never a bare "5"

    let yAxis = AXNumericDataAxisDescriptor(
        title: "Lines of code",
        range: 0...100,
        gridlinePositions: [],
        valueDescriptionProvider: { "\(Int($0)) lines of code" })

    let series = AXDataSeriesDescriptor(
        name: "Productivity",
        isContinuous: true,      // line → one continuous tone; false for bars/points → discrete tones
        dataPoints: model.points.map { AXDataPoint(x: $0.x, y: $0.y) })

    return AXChartDescriptor(
        title: model.title,
        summary: model.summary,  // 1–2 sentence alt text; spoken in the explorer view
        xAxis: xAxis,
        yAxis: yAxis,
        additionalAxes: [],
        series: [series])
}
```

- Categorical axes use `AXCategoricalDataAxisDescriptor`; localize and pluralize the
  `valueDescriptionProvider` output in production.
- Visual floor for any chart (WWDC21 10122): foreground/background contrast **≥ 4.5:1**
  (verify with Accessibility Inspector's Color Contrast Calculator); **never pair
  red + green** (the most common color blindness) and avoid **blue + yellow** (the second
  most common); use **symbols in addition to color** so series stay distinguishable with
  no color perception at all.

## Top Mistakes

| # | Mistake | Fix |
|---|---------|-----|
| 1 | Forgetting to `import Charts` | Both `SwiftUI` and `Charts` imports are required |
| 2 | Using `.chart3DPose(.default)` and expecting drag-to-rotate | Use a `@State` binding: `.chart3DPose($pose)` for interactive rotation |
| 3 | Setting `yRange` that does not cover actual function output | Match the `yRange` in `.heightBased()` to the actual min/max of your function output |
| 4 | Applying `.roughness()` without `.foregroundStyle()` | Roughness modifies existing surface appearance; set a foreground style first |
| 5 | Using orthographic projection for presentation/demo contexts | Prefer `.perspective` for visual appeal; use `.orthographic` for precise data reading |

## Review Checklist

### Imports and Setup
- [ ] Both `import SwiftUI` and `import Charts` are present
- [ ] Deployment target is iOS 26 / macOS 26 or later
- [ ] `Chart3D` wraps all `SurfacePlot` content

### Surface Configuration
- [ ] Axis labels (`x:`, `y:`, `z:`) are descriptive and meaningful
- [ ] `foregroundStyle` applied to each `SurfacePlot` for clear visual distinction
- [ ] `yRange` in `.heightBased()` matches the actual output range of the function
- [ ] `roughness` value makes sense for the use case (0 = reflective, 1 = matte)

### Interactivity
- [ ] Pose is a `@State` binding if drag-to-rotate is intended
- [ ] Pose is a constant (non-binding) if rotation should be locked
- [ ] Initial pose angle provides a good default view of the data

### Camera
- [ ] Camera projection set appropriately (`.perspective` for visual, `.orthographic` for precision)
- [ ] If using `.automatic`, verified the system choice looks acceptable

### Multiple Surfaces
- [ ] Each surface has a distinct color or opacity to differentiate
- [ ] Axis labels are unique per surface or shared where appropriate

### Accessibility
- [ ] Contrast ≥ 4.5:1; no red+green or blue+yellow series pairs; symbols supplement color (WWDC21 10122)
- [ ] Custom-drawn charts expose an `AXChartDescriptor` (Audio Graphs) — or keep Swift Charts' default intact
- [ ] Large datasets expose one accessibility element per interval, not per point

## References

- [Swift Charts](https://developer.apple.com/documentation/charts)
- [Swift Charts — Chart3D](https://developer.apple.com/documentation/Charts/Chart3D)
- [Swift Charts — SurfacePlot](https://developer.apple.com/documentation/Charts/SurfacePlot)
- [Swift Charts — Chart3DPose](https://developer.apple.com/documentation/Charts/Chart3DPose)
- [Swift Charts — Chart3DCameraProjection](https://developer.apple.com/documentation/Charts/Chart3DCameraProjection)
- [Swift Charts — Chart3DSurfaceStyle](https://developer.apple.com/documentation/Charts/Chart3DSurfaceStyle)

### Source: `swiftui_1667/data-flow`

# SwiftUI Data Flow

Nearly every confusing SwiftUI bug — state that resets, animations that crossfade instead of
move, lists that flash, bodies that run constantly — traces to identity, lifetime, or
dependencies. This is Apple's own mental model (the Demystify sessions + Data Essentials +
Observation), current through the WWDC26 `@State` macro.

## When This Skill Activates

- "@State resets when…" / state loses its value on a condition change
- Views re-render too often; animations crossfade when they should move
- Lists flashing, rows reordering wrongly, `ForEach` misbehaving
- Choosing between `@State`, `@Binding`, `@Bindable`, `@Environment`, plain property
- Debugging with `Self._printChanges()`; concurrency warnings in view code

## Identity: the root concept

SwiftUI sees three things: **identity, lifetime, dependencies**. Views with the same identity
are "different states of the same conceptual UI element"; distinct identities are distinct views.

- **Structural identity** = type + position in the hierarchy. An `if/else` creates **two
  identities** (`_ConditionalContent`) — flipping the branch destroys/recreates the view: state
  resets, transitions crossfade instead of animating.
- **Explicit identity** = `id:` in ForEach or `.id(_:)` (also the target for
  `ScrollViewReader.scrollTo`). Changing an explicit id is a new identity — new lifetime,
  fresh state. (That's the `.id(item.id)` force-refresh trick — use it knowingly.)
- **The inert-modifier rule** (the most under-used fix): prefer one view whose modifiers vary
  over branching —

  ```swift
  // ❌ two identities; state resets, transition crossfades
  if expired { content.opacity(0.3) } else { content }
  // ✅ one identity; cheap, pruned when inert
  content.opacity(expired ? 0.3 : 1.0)
  ```

  Inert values (opacity 1, padding 0) cost nothing. "By default, try to preserve identity."
- Conditionally include a view *inside* a stack rather than conditionally wrapping the stack.

## Lifetime: state is tied to identity

- View **values** are ephemeral — created for comparison, then destroyed. Never rely on the
  struct instance; identity provides continuity.
- "Whenever the identity changes, the state is replaced" — `@State`/`@StateObject` storage
  tears down and reinitializes. If state "randomly resets," find the identity change.
- WWDC26: `@State` is a macro with **lazy initialization of `@Observable` classes** (backported
  to iOS 17) — the stored object initializes once per lifetime, not on every view-value init.
  Remove default values when also assigning in `init` (source-breaking edge).

## ForEach identifier rules (the flashing-list checklist)

- **Stable** — never `var id = UUID()` computed per access (everything flashes/reanimates).
- **Not indices** — insert-at-front reads as insert-at-end; rows animate wrongly.
- **Unique** — duplicate IDs drop rows.
- Use persistent/database-derived IDs; that's what `Identifiable` is for. Range ForEach
  (`0..<n`) only with a constant range.
- **Constant views per element**: an `if` filter inside ForEach (0-or-1 views) or `AnyView`
  forces List to resolve every row just to count them. Filter in the **data**, and cache the
  filtered collection in the model — an inline `.filter` re-runs linearly on every body.
- List/Table gather all identifiers **eagerly** — cheap IDs = fast loads.

## Dependencies: the graph, not the tree

- Every piece of data read in body is a dependency; only views whose dependency changed
  re-run, and value comparison prunes unchanged subtrees. Stable identity is "the backbone of
  the dependency graph."
- **Scope dependencies tightly**: pass the subview what it renders (the `Image`, not the whole
  model). Extracting subviews is free — "breaking up one view into multiple doesn't hurt
  performance" — and shrinks invalidation scope.
- **Observation** (`@Observable`) tracks **per property, per instance** — a view re-renders only
  when a property it actually *read* changes, including through computed properties, arrays,
  optionals, and nesting.
- Migration from `ObservableObject`: drop conformance + `@Published` → `@Observable`;
  `@ObservedObject` → delete or `@Bindable`; `@EnvironmentObject` → `@Environment`.
  Invalidation narrows from whole-object to read-properties — a free performance win.

## State ownership: the decision rules

Ask Apple's three questions: what data does the view need · how does it manipulate it ·
**where does truth live?**

| Situation | Use |
|---|---|
| Display-only, parent owns it | plain `let` property |
| Transient, view-local UI state | `@State` (group related fields into one struct with mutating methods) |
| Write access to someone else's truth | `@Binding` (bindings compose: `$config.note`) |
| Observable model owned by this view | `@State` (lazy-init since WWDC26 macro) |
| Observable model, needs `$model.field` bindings only | `@Bindable` |
| Observable model, globally available | `@Environment` |
| Observable model, none of the above | plain property |

- ❌ Never allocate a reference-type model inline as an `@ObservedObject` default — every
  re-run reallocates it (heap churn, data loss); use `@StateObject` or `@State` + `@Observable`.
- ❌ Two siblings each holding `@State` for the same value desync — lift state to the container
  and hand children Bindings.
- `@SceneStorage` (restoration state, per window) and `@AppStorage` (settings) are stores
  *next to* your model, not the model. Limit total sources of truth.

## Body discipline

- Body must be a pure function, free of side effects — no allocation, I/O, filtering, or
  string-building; move loading to `.task { await … }`.
- Debug why body ran with `Self._printChanges()` (or `expression Self._printChanges()` at an
  LLDB breakpoint): `@self` = view value changed; a named property = that dependency changed.
  Debug-only — never ship it. Deeper workflow: `performance/swiftui-debugging`.
- ❌ `AnyView` hides structure from SwiftUI (worse diagnostics/performance) — use
  `@ViewBuilder` helpers and `switch` instead.

## Concurrency contract (WWDC25)

- `View` is `@MainActor`: body, `@State`, members, and `Task { }` created in body are all
  main-actor — most view code needs zero annotations (and Swift 6.2's default-isolation mode
  removes the rest).
- SwiftUI runs some of *your* closures off-main — `Shape.path(in:)`, `Layout` methods,
  `visualEffect`, `onGeometryChange` — that's why they're `Sendable`. Don't touch
  `self.someState` there; **copy the value in the capture list** (`[pulse]`) and compute from
  the proxies SwiftUI hands you.
- Every `await` can resume after the frame deadline, so time-sensitive state (gesture/scroll
  reactions, button loading indicators) must mutate synchronously *before* starting async work.
  Bridge UI↔async through a piece of state; keep view `Task`s minimal ("inform the model") so
  async logic stays unit-testable.

## Output Format

Data-flow review: `Symptom | Root cause (identity / lifetime / dependency / ownership) | Fix`
— check identity first; it explains most of the rest.

## Common Mistakes

✅ Inject shared `@Observable` models with `.environment(model)` and read them with `@Environment(Model.self)`.
❌ A custom `EnvironmentKey` (or `@Entry`) whose default value is a `@MainActor` object — under Swift 6 the default is read from a nonisolated context and fails to compile ("main actor-isolated default value in a nonisolated context"). Use the `@Observable` environment pattern instead.

## References

- https://developer.apple.com/videos/play/wwdc2021/10022/ (Demystify SwiftUI — the canon)
- https://developer.apple.com/videos/play/wwdc2020/10040/ (Data Essentials)
- https://developer.apple.com/videos/play/wwdc2023/10149/ (Discover Observation)
- https://developer.apple.com/videos/play/wwdc2023/10160/ (Demystify SwiftUI performance)
- https://developer.apple.com/videos/play/wwdc2025/266/ (Explore concurrency in SwiftUI)
- Related skills: `performance/swiftui-debugging` (Instruments workflow), `swiftui/layout`, `swift/concurrency-patterns`, `ios/coding-best-practices`

### Source: `swiftui_1667/text-editing`

# Styled Text Editing

Patterns for displaying styled text and building rich text editors in SwiftUI. Covers Text styling, AttributedString, TextEditor with selection-based formatting, and custom formatting definitions.

## When This Skill Activates

Use this skill when the user:
- Wants to display styled or formatted text
- Needs rich text editing with bold/italic/underline controls
- Asks about AttributedString or TextEditor
- Wants text formatting toolbars
- Asks about Markdown rendering in Text views
- Needs custom text attributes or formatting constraints
- Wants selection-based text formatting

## Decision Tree

```
What text feature do you need?
|
+- Display styled read-only text
|  +- Simple styling (one style) -> Text Styling section below
|  +- Mixed styles in one string -> AttributedString section below
|  +- Markdown content -> Markdown section below
|
+- Edit plain text
|  +- TextEditor(text: $stringBinding)
|
+- Edit rich/styled text
|  +- Basic rich editor -> Rich Text Editing section below
|  +- With formatting toolbar -> Formatting Controls section below
|  +- With custom constraints -> Custom Formatting section below
```

## API Availability

| API | Minimum Version | Notes |
|-----|----------------|-------|
| `Text` with modifiers | iOS 13 | .font(), .bold(), .italic() |
| `TextEditor(text:)` | iOS 14 | Plain string binding |
| `.foregroundStyle()` | iOS 15 | Preferred over .foregroundColor() |
| `AttributedString` | iOS 15 | Rich text model |
| `.bold(condition)` | iOS 16 | Conditional bold/italic |
| `.underline(pattern:)` | iOS 16 | Dash, dot patterns |
| `TextEditor(text:selection:)` | iOS 26 | AttributedString + selection |
| `AttributedTextSelection` | iOS 26 | Selection-based formatting |
| `text.transformAttributes(in:)` | iOS 26 | Modify attributes in selection |
| `AttributedTextFormattingDefinition` | iOS 26 | Custom formatting constraints |
| `@Environment(\.fontResolutionContext)` | iOS 18 | Resolve font properties |

## Top 5 Mistakes

| # | Mistake | Fix |
|---|---------|-----|
| 1 | Using `.foregroundColor()` on new projects | Use `.foregroundStyle()` — supports gradients and ShapeStyle |
| 2 | `.animation(.spring())` without `value:` on text | Deprecated in iOS 15 — always pass `value:` parameter |
| 3 | Expecting full Markdown in `Text` | Text only supports inline Markdown: **bold**, *italic*, [links]. No lists, tables, code blocks, images |
| 4 | Creating new AttributedString instances on every body evaluation | Cache complex AttributedString objects in @State or computed properties outside body |
| 5 | Using `TextEditor(text: $string)` for rich text | Use `TextEditor(text: $attributedString, selection: $selection)` with AttributedString binding (iOS 26+) |

## Text Styling Quick Reference

```swift
// Font
Text("Hello").font(.headline)
Text("Custom").font(.system(size: 24, design: .rounded))

// Weight
Text("Bold").fontWeight(.bold)

// Color — prefer foregroundStyle over foregroundColor
Text("Styled").foregroundStyle(.red)
Text("Gradient").foregroundStyle(
    .linearGradient(colors: [.yellow, .blue], startPoint: .top, endPoint: .bottom)
)

// Decorations
Text("Bold").bold()
Text("Conditional").bold(someCondition)
Text("Underline").underline(true, pattern: .dash, color: .blue)
Text("Strike").strikethrough(true, pattern: .dot, color: .red)

// Layout
Text("Centered").multilineTextAlignment(.center)
Text("Spaced").lineSpacing(10)
Text("Truncated").lineLimit(2).truncationMode(.tail)
```

## AttributedString

```swift
// Create and style ranges
var text = AttributedString("Red and Blue")
if let redRange = text.range(of: "Red") {
    text[redRange].foregroundColor = .red
    text[redRange].font = .headline
}
if let blueRange = text.range(of: "Blue") {
    text[blueRange].foregroundColor = .blue
    text[blueRange].underlineStyle = .single
}

// Display
Text(text)
```

### Available Attributes

| Attribute | Type | Example |
|-----------|------|---------|
| `.font` | Font | `.headline` |
| `.foregroundColor` | Color | `.red` |
| `.backgroundColor` | Color | `.yellow` |
| `.underlineStyle` | UnderlineStyle | `.single` |
| `.underlineColor` | Color | `.blue` |
| `.strikethroughStyle` | UnderlineStyle | `.single` |
| `.strikethroughColor` | Color | `.red` |
| `.inlinePresentationIntent` | InlinePresentationIntent | `.stronglyEmphasized` (bold), `.emphasized` (italic) |

## Rich Text Editing (iOS 26+)

```swift
struct RichTextEditorView: View {
    @State private var text = AttributedString("Select text to format")
    @State private var selection = AttributedTextSelection()

    @Environment(\.fontResolutionContext) private var fontResolutionContext

    var body: some View {
        VStack {
            TextEditor(text: $text, selection: $selection)
                .frame(height: 200)

            HStack {
                Button(action: toggleBold) {
                    Image(systemName: "bold")
                }
                Button(action: toggleItalic) {
                    Image(systemName: "italic")
                }
                Button(action: toggleUnderline) {
                    Image(systemName: "underline")
                }
            }
        }
    }

    private func toggleBold() {
        text.transformAttributes(in: &selection) {
            let font = $0.font ?? .default
            let resolved = font.resolve(in: fontResolutionContext)
            $0.font = font.bold(!resolved.isBold)
        }
    }

    private func toggleItalic() {
        text.transformAttributes(in: &selection) {
            let font = $0.font ?? .default
            let resolved = font.resolve(in: fontResolutionContext)
            $0.font = font.italic(!resolved.isItalic)
        }
    }

    private func toggleUnderline() {
        text.transformAttributes(in: &selection) {
            if $0.underlineStyle != nil {
                $0.underlineStyle = nil
            } else {
                $0.underlineStyle = .single
            }
        }
    }
}
```

### Reading Selection Attributes

```swift
// Get current attributes at the selection/cursor
let attributes = selection.typingAttributes(in: text)
let currentColor = attributes.foregroundColor ?? .primary
```

## Custom Formatting Definition (iOS 26+)

Constrain which attribute values the editor allows. A definition's `body` lists
`ValueConstraint`s; anything outside the allowed set is replaced with the default:

```swift
/// Only allow the app's brand colors (or none) as text color in the editor.
struct BrandTextFormatting: AttributedTextFormattingDefinition {
    var body: some AttributedTextFormattingDefinition<AttributeScopes.SwiftUIAttributes> {
        ValueConstraint(
            for: \.foregroundColor,
            values: [nil, .blue, .orange],
            default: nil
        )
    }
}

struct NoteEditor: View {
    @State private var text = AttributedString()
    @State private var selection = AttributedTextSelection()

    var body: some View {
        TextEditor(text: $text, selection: $selection)
            .attributedTextFormattingDefinition(BrandTextFormatting())
    }
}
```

❌ `ValueConstraint(\.font, constraint: { … })` and `.textFormattingDefinition(…)` — neither exists. The
initializer is `ValueConstraint(for:values:default:)` and the modifier is `.attributedTextFormattingDefinition(_:)`.

## Markdown in Text

```swift
// Inline markdown support
Text("This is **bold** and *italic* text")
Text("Visit [Apple](https://www.apple.com)")
Text("Code: `inline code`")
```

### Markdown Limitations

Text supports only **inline** Markdown:
- ✅ Bold (`**text**`), italic (`*text*`), links, inline code
- ❌ Line breaks, block formatting, lists, tables, code blocks, images, block quotes

## Review Checklist

### Text Display
- [ ] Using `.foregroundStyle()` instead of deprecated `.foregroundColor()`
- [ ] `.lineLimit()` paired with `.help()` tooltip or `.textSelection(.enabled)` for truncated text
- [ ] Dynamic Type supported — using system font styles, not hardcoded sizes
- [ ] Colors adapt to dark mode — using system colors or semantic styles

### AttributedString
- [ ] Complex AttributedString cached in @State, not recreated in body
- [ ] Range lookups use safe `if let range = text.range(of:)` pattern
- [ ] Appropriate attributes used (`.inlinePresentationIntent` for semantic bold/italic)

### TextEditor
- [ ] Rich text uses `TextEditor(text: $attributedString, selection: $selection)` (iOS 26+)
- [ ] Formatting toolbar uses `text.transformAttributes(in: &selection)` pattern
- [ ] Font resolution uses `@Environment(\.fontResolutionContext)` for toggle logic
- [ ] Accessibility labels provided for formatting buttons

### Localization
- [ ] User-facing strings use `LocalizedStringKey`
- [ ] Markdown in localized strings uses `Text(LocalizedStringKey("**Bold** text"))`

## References

- [SwiftUI Text and Symbol Modifiers](https://developer.apple.com/documentation/SwiftUI/View-Text-and-Symbols)
- [Building Rich SwiftUI Text Experiences](https://developer.apple.com/documentation/SwiftUI/building-rich-swiftui-text-experiences)
- [AttributedString Documentation](https://developer.apple.com/documentation/Foundation/AttributedString)
- [TextEditor Documentation](https://developer.apple.com/documentation/SwiftUI/TextEditor)

### Source: `swiftui_1667/toolbars`

# SwiftUI Toolbars

Modern toolbar patterns for SwiftUI apps. Covers customizable toolbars, enhanced search integration, new placements, transition effects, and platform-specific considerations.

## When This Skill Activates

Use this skill when the user:
- Wants to add or customize toolbars
- Asks about customizable/user-configurable toolbars
- Needs search field in toolbar with specific placement
- Wants toolbar item transitions or animations
- Asks about toolbar placements (bottomBar, largeSubtitle, etc.)
- Needs platform-specific toolbar behavior (iOS vs macOS)
- Wants to reposition system toolbar items (search, sidebar)

## Decision Tree

```
What toolbar feature do you need?
|
+- User-customizable toolbar (add/remove/reorder items)
|  +- Use .toolbar(id:) with ToolbarItem(id:)
|
+- Search field in toolbar
|  +- Minimize to button -> .searchToolbarBehavior(.minimize)
|  +- Reposition search -> DefaultToolbarItem(kind: .search, placement:)
|
+- Toolbar transition/animation
|  +- Zoom transition from toolbar item -> .matchedTransitionSource(id:in:)
|  +- Hide glass background -> .sharedBackgroundVisibility(.hidden)
|
+- Custom subtitle area content
|  +- Use ToolbarItem(placement: .largeSubtitle)
|
+- System toolbar items with custom placement
|  +- DefaultToolbarItem(kind: .search/.sidebarToggle/.title, placement:)
```

## API Availability

| API | Minimum Version | Notes |
|-----|----------------|-------|
| `.toolbar { }` | iOS 14 | Basic toolbar |
| `ToolbarItem(placement:)` | iOS 14 | Standard placements |
| `.toolbar(id:)` | iOS 16 | Customizable toolbars |
| `ToolbarItem(id:)` | iOS 16 | Items in customizable toolbars |
| `ToolbarSpacer` | iOS 16 | Fixed and flexible spacers |
| `.searchable()` | iOS 15 | Search integration |
| `.searchToolbarBehavior(.minimize)` | iOS 17 | Minimized search button |
| `DefaultToolbarItem(kind:placement:)` | iOS 18 | Reposition system items |
| `ToolbarItem(placement: .largeSubtitle)` | iOS 18 | Subtitle area content |
| `.matchedTransitionSource(id:in:)` | iOS 18 | Toolbar transition source |
| `.sharedBackgroundVisibility()` | iOS 18 | Glass background control |

## Customizable Toolbars

Allow users to personalize toolbar items by adding, removing, and rearranging:

```swift
ContentView()
    .toolbar(id: "main-toolbar") {
        ToolbarItem(id: "tag") {
            TagButton()
        }
        ToolbarItem(id: "share") {
            ShareButton()
        }
        ToolbarSpacer(.fixed)
        ToolbarItem(id: "more") {
            MoreButton()
        }
    }
```

### Toolbar Spacers

```swift
ToolbarSpacer(.fixed)      // Fixed-width space
ToolbarSpacer(.flexible)   // Flexible space — pushes items apart
```

### Anti-Patterns

```swift
// ❌ Missing IDs in customizable toolbar — items can't be customized
.toolbar(id: "main") {
    ToolbarItem {           // No id parameter
        ShareButton()
    }
}

// ✅ Every item needs its own ID
.toolbar(id: "main") {
    ToolbarItem(id: "share") {
        ShareButton()
    }
}
```

## Enhanced Search Integration

### Minimized Search

Renders search field as a compact button that expands on tap:

```swift
@State private var searchText = ""

NavigationStack {
    RecipeList()
        .searchable(text: $searchText)
        .searchToolbarBehavior(.minimize)
}
```

### Repositioning Search

Move the default search field to a different toolbar position:

```swift
NavigationSplitView {
    AllCalendarsView()
} detail: {
    SelectedCalendarView()
        .searchable(text: $query)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                CalendarPicker()
            }
            ToolbarItem(placement: .bottomBar) {
                Invites()
            }
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                NewEventButton()
            }
        }
}
```

## System-Defined Toolbar Items

Reposition system items with custom placements:

```swift
.toolbar {
    DefaultToolbarItem(kind: .search, placement: .bottomBar)
    DefaultToolbarItem(kind: .sidebarToggle, placement: .topBarLeading)
}
```

## Large Subtitle Placement

Place custom content in the navigation bar subtitle area:

```swift
NavigationStack {
    DetailView()
        .navigationTitle("Title")
        .navigationSubtitle("Subtitle")
        .toolbar {
            ToolbarItem(placement: .largeSubtitle) {
                CustomLargeNavigationSubtitle()
            }
        }
}
```

## Transition Effects

### Matched Transition from Toolbar

Create zoom transitions originating from a toolbar button:

```swift
struct ContentView: View {
    @State private var isPresented = false
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            DetailView()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Show Sheet", systemImage: "globe") {
                            isPresented = true
                        }
                    }
                    .matchedTransitionSource(id: "world", in: namespace)
                }
                .sheet(isPresented: $isPresented) {
                    SheetView()
                        .navigationTransition(
                            .zoom(sourceID: "world", in: namespace))
                }
        }
    }
}
```

### Glass Background Control

Control the shared glass background on toolbar items:

```swift
ContentView()
    .toolbar(id: "main") {
        ToolbarItem(id: "build-status", placement: .principal) {
            BuildStatus()
        }
        .sharedBackgroundVisibility(.hidden)
    }
```

## Top 5 Mistakes

| # | Mistake | Fix |
|---|---------|-----|
| 1 | Missing `id` on ToolbarItem in customizable toolbar | Every item in `.toolbar(id:)` must have its own `id` parameter |
| 2 | Using `.searchToolbarBehavior(.minimize)` without `.searchable()` | Must pair with `.searchable()` modifier — `.minimize` only affects rendering |
| 3 | Putting `.matchedTransitionSource` on the Button instead of ToolbarItem | Apply `.matchedTransitionSource(id:in:)` on the `ToolbarItem`, not its content |
| 4 | Using `.largeSubtitle` alongside `.navigationSubtitle()` expecting both to show | `.largeSubtitle` takes precedence — the subtitle modifier value is hidden |
| 5 | Forgetting `placement:` on DefaultToolbarItem | Without explicit placement, system items use their default position |

## Platform Considerations

| Platform | Recommendations |
|----------|----------------|
| **iOS** | Bottom bar useful on iPhones. Use `.searchToolbarBehavior(.minimize)` for space efficiency. |
| **iPadOS** | Customizable toolbars valuable in productivity apps. Consider keyboard shortcuts. |
| **macOS** | Users expect toolbar customization. Use spacers for logical groupings. |

## Review Checklist

### Customizable Toolbars
- [ ] `.toolbar(id:)` has a unique, stable string identifier
- [ ] Every `ToolbarItem` within has its own unique `id`
- [ ] Spacers used to create logical groups of related items
- [ ] Toolbar tested with customization panel (long-press on iPadOS, right-click on macOS)

### Search Integration
- [ ] `.searchable()` paired with appropriate `.searchToolbarBehavior()`
- [ ] Search placement makes sense for the platform (bottom bar on iOS, toolbar on macOS)
- [ ] `DefaultToolbarItem(kind: .search)` used when repositioning is needed

### Transitions
- [ ] `.matchedTransitionSource` applied to `ToolbarItem`, not its content view
- [ ] Namespace declared with `@Namespace` at the view level
- [ ] Source ID matches between `.matchedTransitionSource` and `.navigationTransition(.zoom)`

### Platform
- [ ] Toolbar layouts tested on both iOS and macOS (if multiplatform)
- [ ] Bottom bar items appropriate for small screens
- [ ] Customizable toolbars provided for complex macOS apps

## References

- [SwiftUI ToolbarItemPlacement](https://developer.apple.com/documentation/SwiftUI/ToolbarItemPlacement)
- [SwiftUI CustomizableToolbarContent](https://developer.apple.com/documentation/SwiftUI/CustomizableToolbarContent)
- [SwiftUI SearchToolbarBehavior](https://developer.apple.com/documentation/SwiftUI/SearchToolbarBehavior)
- [SwiftUI DefaultToolbarItem](https://developer.apple.com/documentation/SwiftUI/DefaultToolbarItem)
- [SwiftUI ToolbarSpacer](https://developer.apple.com/documentation/SwiftUI/ToolbarSpacer)

### Source: `swiftui_1667/webkit`

# WebKit Integration for SwiftUI

Embed and control web content in SwiftUI apps using the native `WebView` struct and `WebPage` observable class. Covers loading, navigation, JavaScript execution, and view customization.

## When This Skill Activates

- User wants to display web content inside a SwiftUI app
- User needs to load URLs, HTML strings, or data blobs in a web view
- User asks about JavaScript interop from SwiftUI
- User needs navigation control (back, forward, reload) for embedded web content
- User wants to customize web view behavior (gestures, text selection, link previews)
- User needs to capture snapshots or export PDFs from web content
- User asks about intercepting navigation requests or custom URL schemes
- User wants to configure private browsing or custom user agents

## Decision Tree

```
What do you need?
|
+-- Display a URL or HTML content
|   +-- Simple, no interaction needed
|   |   +-- WebView(url:) --> see webview-basics.md
|   +-- Need loading state, reload, custom config
|       +-- WebPage + WebView(page) --> see webview-basics.md
|
+-- Navigate programmatically (back, forward, intercept)
|   +-- Back/forward list, navigation events
|   |   +-- see navigation.md
|   +-- Intercept or cancel navigation requests
|       +-- NavigationDeciding protocol --> see navigation.md
|
+-- Execute JavaScript or communicate with web content
|   +-- callJavaScript, arguments, content worlds
|       +-- see javascript-advanced.md
|
+-- Capture snapshots, export PDF, web archive
|   +-- page.snapshot(), page.pdf(), page.webArchiveData()
|       +-- see javascript-advanced.md
|
+-- Handle custom URL schemes
    +-- URLSchemeHandler protocol --> see javascript-advanced.md
```

## API Availability

| API | Minimum OS | Import |
|-----|-----------|--------|
| `WebView` | iOS 26 / macOS 26 | `SwiftUI` + `WebKit` |
| `WebPage` | iOS 26 / macOS 26 | `WebKit` |
| `WebPage.Configuration` | iOS 26 / macOS 26 | `WebKit` |
| `NavigationDeciding` | iOS 26 / macOS 26 | `WebKit` |
| `WKContentWorld` | iOS 14 / macOS 11 | `WebKit` |
| `WKSnapshotConfiguration` | iOS 11 / macOS 10.13 | `WebKit` |
| `WKPDFConfiguration` | iOS 14 / macOS 11 | `WebKit` |

## Quick Start

### Simplest Usage

```swift
import SwiftUI
import WebKit

struct BrowserView: View {
    var body: some View {
        WebView(url: URL(string: "https://developer.apple.com")!)
    }
}
```

### With WebPage for Full Control

```swift
import SwiftUI
import WebKit

struct ControlledBrowserView: View {
    @State private var page = WebPage()

    var body: some View {
        WebView(page)
            .onAppear {
                page.load(URLRequest(url: URL(string: "https://developer.apple.com")!))
            }
    }
}
```

## Top Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using `WebView(url:)` when you need navigation control | No access to back/forward, reload, or events | Use `WebPage` + `WebView(page)` |
| Forgetting `import WebKit` alongside `import SwiftUI` | `WebView` is in SwiftUI but `WebPage` requires WebKit | Always import both |
| Not observing `currentNavigationEvent` | Missing loading states, errors go unnoticed | Use `onChange(of: page.currentNavigationEvent)` |
| Calling `callJavaScript` before page finishes loading | Script fails because DOM is not ready | Wait for `.finished` navigation event |
| Using persistent data store for private browsing | User data is saved to disk | Use `.nonPersistent()` on `WebsiteDataStore` |
| Not handling `nil` return from `decidePolicyFor(navigationAction:)` | Navigation proceeds when it should be cancelled | Return `nil` to cancel, return `NavigationPreferences` to allow |
| Passing JavaScript without argument binding | Vulnerable to injection, hard to debug | Use `arguments:` parameter for named values |

## Review Checklist

- [ ] Using `WebPage` when any control beyond simple display is needed
- [ ] Both `SwiftUI` and `WebKit` are imported
- [ ] Navigation events observed for loading indicators and error handling
- [ ] JavaScript execution waits for page to finish loading
- [ ] Private browsing uses `.nonPersistent()` data store
- [ ] Navigation interception returns correct values (preferences to allow, nil to cancel)
- [ ] JavaScript arguments passed via `arguments:` parameter, not string interpolation
- [ ] Custom URL scheme handler registered on configuration before page loads
- [ ] Find-in-page enabled with `findNavigator(isPresented:)` if needed
- [ ] Appropriate gesture and interaction modifiers applied (back/forward, magnification, text selection)
- [ ] Content background customized if needed for visual integration

## Reference Files

| File | Contents |
|------|----------|
| `webview-basics.md` | WebView creation, WebPage setup, configuration, find-in-page, customization modifiers |
| `navigation.md` | Loading content, back/forward list, navigation events, NavigationDeciding protocol |
| `javascript-advanced.md` | JavaScript execution, content worlds, snapshots, PDF export, custom URL schemes |

## Cross-References

- For **macOS window management** around web views, see `macos/architecture-patterns/`
- For **navigation architecture** that hosts a web view, see `ios/navigation-patterns/`
- For **Liquid Glass** design around web content, see `design/liquid-glass/`

## References

- [WebView (SwiftUI)](https://developer.apple.com/documentation/webkit/webview-swift.struct)
- [WebPage](https://developer.apple.com/documentation/webkit/webpage)
- [WKContentWorld](https://developer.apple.com/documentation/webkit/wkcontentworld)
- [WKSnapshotConfiguration](https://developer.apple.com/documentation/webkit/wksnapshotconfiguration)

### Source: `swiftui_1667/whats-new-27`

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

### Source: `visionos`

# visionOS Skills

Spatial-computing patterns for visionOS.

## When This Skill Activates

Use this skill when the user:
- Designs, builds, or reviews any **visionOS app, window, volume, or immersive space**
- Asks about **spatial layout, eye/hand input, hover effects, motion comfort, or environments**
- Builds or adapts **widgets for visionOS**
- Asks about **mounting styles**, glass/paper **textures**, or spatial widget families
- Needs **proximity-aware layouts**

## Available Skills

Paths are relative to THIS file's directory — skills run with cwd set to the
user's project, so resolve each path from this SKILL.md's own location.

| Skill | Read | Covers |
|-------|------|--------|
| spatial-design | `spatial-design/SKILL.md` | Layout ergonomics (60pt eye targets, dynamic scale), input, motion comfort, immersion strategy, spatial sound, video formats; `immersive-environments.md` for production budgets |
| widgets | `widgets/SKILL.md` | Mounting styles, glass/paper textures, proximity-aware layouts, spatial families |

## How to Route

1. Read `widgets/SKILL.md` (relative to this file) plus any reference files it lists.
2. Apply the guidance to the user's code.

### Source: `visionos/widgets`

# visionOS Widgets

Patterns for building widgets that live in physical space on visionOS. Covers mounting styles, textures, proximity-aware detail levels, spatial widget families, and rendering modes.

## When This Skill Activates

Use this skill when the user:
- Asks to create or adapt a **widget for visionOS**
- Mentions **mounting styles** (elevated, recessed)
- Wants **glass or paper texture** on a widget
- Asks about **proximity awareness** or **level of detail** in widgets
- Mentions **spatial widget families** or `.systemExtraLargePortrait`
- Wants to control **container backgrounds** or **rendering modes** (full color vs accented)
- Is porting an existing iOS/iPadOS widget to visionOS

## Decision Tree

```
What do you need for your visionOS widget?
|
+- Where should the widget appear?
|  +- On a surface (table, shelf) -> .elevated (default)
|  +- Embedded in a wall -> .recessed
|  +- Both -> .supportedMountingStyles([.elevated, .recessed])
|
+- What visual treatment?
|  +- Transparent, blends with environment -> .glass (default)
|  +- Opaque, poster-like appearance -> .paper
|
+- How should it respond to user distance?
|  +- Full detail when close -> @Environment(\.levelOfDetail) == .default
|  +- Simplified when far -> @Environment(\.levelOfDetail) == .simplified
|
+- What size families?
|  +- Standard -> .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge
|  +- Tall portrait -> .systemExtraLargePortrait (visionOS only)
|
+- How should colors render?
|  +- Full color (default) -> No extra work
|  +- System-tinted monochrome -> Mark backgrounds with .containerBackground(for:)
```

## API Availability

| API | Minimum Version | Notes |
|-----|----------------|-------|
| WidgetKit on visionOS | visionOS 1.0 | Basic widget support |
| `.containerBackground(for: .widget)` | visionOS 1.0 | Removable background marking |
| `@Environment(\.showsWidgetContainerBackground)` | visionOS 1.0 | Background visibility check |
| `.supportedMountingStyles()` | visionOS 2.0 | Elevated and recessed placement |
| `.widgetTexture(.glass / .paper)` | visionOS 2.0 | Widget surface material |
| `@Environment(\.levelOfDetail)` | visionOS 2.0 | Proximity-aware layouts |
| `.systemExtraLargePortrait` | visionOS 2.0 | Tall portrait widget family |

## Complete Widget Example

This example demonstrates mounting styles, textures, families, and proximity awareness together:

```swift
struct MyWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.example.mywidget",
            provider: Provider()
        ) { entry in
            MyWidgetView(entry: entry)
        }
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .systemExtraLarge, .systemExtraLargePortrait
        ])
        .supportedMountingStyles([.elevated, .recessed])
        .widgetTexture(.glass)        // .glass is default, .paper for opaque
    }
}
```

**Mounting styles**: `.elevated` (default) sits on surfaces like tables. `.recessed` embeds into walls like a framed picture. Omit `.supportedMountingStyles()` to use elevated only. Recessed works only on vertical surfaces — placements on horizontal surfaces are always elevated. On horizontal surfaces the system also applies a gentle tilt toward the user; design for that angle rather than fighting it.

**Textures**: `.glass` (default) blends with the environment; `.paper` is opaque, best for rich imagery.

## Spatial Behavior (WWDC25)

Widgets are permanent, physical-surface-only room fixtures — they persist across sessions, room changes, and power cycles, and multiple instances can coexist in a room.

- **User resizing**: a corner affordance lets users scale a widget from **75% to 125%** of its template size — layouts must survive the entire range.
- **Frames**: users pick from **five frame widths** (thin to thick), independent of template size. The recessed style fixes the frame width.
- **Frame tinting**: the widget frame always receives the user's color tint and cannot opt out. Even when the background opts out of tinting, foregrounds must hold up under all **7 light and 7 dark** system palettes.
- **Assets**: widgets render at real-world scale — ship high-resolution assets so imagery stays sharp at close range.

## Proximity Awareness (Level of Detail)

The system transitions automatically, with animation, between `.default` (close) and `.simplified` (far) based on user distance — simplify by cutting density and enlarging key info.

```swift
struct MyWidgetView: View {
    let entry: Provider.Entry
    @Environment(\.levelOfDetail) private var levelOfDetail

    var body: some View {
        switch levelOfDetail {
        case .default:
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.title).font(.headline)
                Text(entry.subtitle).font(.subheadline).foregroundStyle(.secondary)
                DetailChart(data: entry.chartData)
            }
            .padding()
        case .simplified:
            VStack(spacing: 4) {
                Image(systemName: entry.iconName).font(.largeTitle)
                Text(entry.title).font(.headline)
            }
            .padding()
        @unknown default:
            Text(entry.title).padding()
        }
    }
}
```

Always handle `@unknown default` for forward compatibility.

## Widget Families

| Family | Description |
|--------|-------------|
| `.systemSmall` | Compact square -- glanceable info |
| `.systemMedium` | Wide rectangle -- two-column or list preview |
| `.systemLarge` | Large square -- charts, detailed content |
| `.systemExtraLarge` | Extra-large landscape -- dashboards |
| `.systemExtraLargePortrait` | Extra-large portrait -- visionOS only; wall-art "statement" widgets |

Guard the visionOS-only family in multiplatform targets:

```swift
.supportedFamilies({
    var families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
    #if os(visionOS)
    families.append(.systemExtraLargePortrait)
    #endif
    return families
}())
```

## Container Backgrounds and Rendering Modes

In accented rendering mode, the system removes backgrounds and applies a tint color. Mark removable backgrounds so the widget renders correctly in both modes.

```swift
struct MyWidgetView: View {
    let entry: Provider.Entry
    @Environment(\.showsWidgetContainerBackground) var showsBackground

    var body: some View {
        VStack {
            Image(systemName: "star.fill").font(.largeTitle)
            Text(entry.title)
                .font(.headline)
                .foregroundStyle(showsBackground ? .white : .primary)
        }
        .padding()
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
```

- **Full color** (default): All colors render intact.
- **Accented**: Container background is removed; system applies a monochrome tint.

## Previewing visionOS Widgets

```swift
#Preview("Close Up", as: .systemSmall) {
    MyWidget()
} timelineProvider: {
    Provider()
}

#Preview("Extra Large Portrait", as: .systemExtraLargePortrait) {
    MyWidget()
} timelineProvider: {
    Provider()
}
```

## Top 5 Mistakes

| # | Mistake | Fix |
|---|---------|-----|
| 1 | Missing `.containerBackground(for: .widget)` -- accented mode renders blank | Always wrap backgrounds in `.containerBackground(for: .widget) { }` |
| 2 | Ignoring `levelOfDetail` -- detailed views unreadable from across the room | Provide a `.simplified` layout with larger text, fewer elements |
| 3 | Using `.systemExtraLargePortrait` on iOS -- build error or runtime crash | Guard with `#if os(visionOS)` or visionOS-only targets |
| 4 | Hardcoding colors that clash with glass texture | Use `.foregroundStyle(.primary / .secondary)` and system colors |
| 5 | No `@unknown default` in `levelOfDetail` switch | Always include for forward compatibility |

### Anti-Patterns

```swift
// ❌ No container background — accented mode shows nothing
struct BadWidgetView: View {
    var body: some View {
        ZStack {
            Color.blue  // Not marked as removable
            Text("Hello")
        }
    }
}

// ✅ Background marked as removable
struct GoodWidgetView: View {
    var body: some View {
        Text("Hello")
            .containerBackground(for: .widget) { Color.blue }
    }
}
```

```swift
// ❌ Same complex layout at all distances
struct BadProximityView: View {
    var body: some View {
        VStack {
            Text(entry.title).font(.caption2)  // Unreadable far away
            DetailChart(data: entry.data)
        }
    }
}

// ✅ Simplified layout when far away
struct GoodProximityView: View {
    @Environment(\.levelOfDetail) private var levelOfDetail
    var body: some View {
        switch levelOfDetail {
        case .default: DetailedLayout(entry: entry)
        case .simplified: SimplifiedLayout(entry: entry)
        @unknown default: SimplifiedLayout(entry: entry)
        }
    }
}
```

## Review Checklist

### Mounting and Texture
- [ ] Mounting style explicitly set if widget should appear recessed or support both
- [ ] Texture set to `.paper` for widgets with rich imagery
- [ ] Widget tested in both elevated and recessed placements (if both supported)
- [ ] Layout survives user resizing from 75% to 125% of the template size

### Proximity Awareness
- [ ] `@Environment(\.levelOfDetail)` provides simplified layout for distant viewers
- [ ] `.simplified` layout uses larger text, fewer elements, high-contrast visuals
- [ ] `@unknown default` case present in `levelOfDetail` switch

### Families and Layout
- [ ] `.systemExtraLargePortrait` guarded with `#if os(visionOS)` in multiplatform targets
- [ ] Widget content adapts to each supported family size
- [ ] Layout tested in all declared family sizes via Xcode previews

### Backgrounds and Rendering
- [ ] `.containerBackground(for: .widget) { }` used to mark removable backgrounds
- [ ] Widget renders correctly in both full color and accented modes
- [ ] `showsWidgetContainerBackground` checked if foreground colors depend on background
- [ ] System semantic colors used for glass texture compatibility
- [ ] Foreground legible under all 7 light and 7 dark frame-tint palettes

## References

- [Widgets for visionOS (WWDC)](https://developer.apple.com/documentation/widgetkit/widgets-for-visionos)
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [visionOS Human Interface Guidelines - Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)

### Source: `watchos`

# watchOS Development

Comprehensive guidance for watchOS app development with SwiftUI, Watch Connectivity, and complications.

## When This Skill Activates

Use this skill when the user:
- Is building a watchOS app or Watch extension
- Asks about Watch Connectivity (iPhone ↔ Watch sync)
- Needs help with complications or ClockKit
- Wants to implement watch-specific UI patterns
- Asks about **WidgetKit complications** or migrating from ClockKit to WidgetKit
- Wants to build **watch face complications** (accessoryCircular, accessoryRectangular, accessoryCorner, accessoryInline)
- Asks about **HealthKit on watchOS**, workout sessions, heart rate, or fitness tracking
- Needs **Extended Runtime sessions** for background workout tracking
- Wants to build **watchOS widgets** or Smart Stack widgets
- Asks about **widget relevance**, Smart Stack ordering, or widget suggestions
- Needs to share widgets **cross-platform** between iOS and watchOS
- Asks about **watchOS accessibility** — VoiceOver, AssistiveTouch, or Dynamic Type on the Watch

## Key Principles

### 1. Watch-First Design
- Glanceable content - users look for seconds, not minutes
- Quick interactions - 2 seconds or less
- Essential information only - no scrolling walls of text
- Large touch targets - minimum 38pt height

### 2. Independent vs Companion
- Prefer independent Watch apps when possible
- Use Watch Connectivity for data sync, not as dependency
- Cache data locally for offline access
- Handle connectivity failures gracefully

### 3. Performance
- Minimize background work (battery)
- Use complication updates sparingly
- Prefer timeline-based content over live updates
- Keep views lightweight

## watchOS Design Rules (WWDC20/23)

### The Ten-Second Test
Design for roughly ten seconds of attention: "if you had ten seconds of someone's attention, which information would you surface?" Launch directly into that detail view — chosen by location, recency, or frequency — and make it so unmistakable it needs no title.

### Three Foundational Layouts
| Layout | Use For | Notes |
|--------|---------|-------|
| **Dial** | Dense at-a-glance status | Up to 4 corner controls; `.scenePadding(.horizontal)` to align with the bezel |
| **Infographic** | Charts + metrics | One chart with supporting numbers |
| **List** | Scrollable finding | When the user must locate an item |

### Navigation Model
- Prefer **vertical pagination** via the Digital Crown between purposeful, single-screen-height pages — horizontal paging is "more difficult to navigate".
- Prefer the two-level **Source List** pattern with `NavigationSplitView`: always initialize the selection so the app launches straight to detail, and leave the source list untitled.
- Reach for `NavigationStack` only when neither fits — and hierarchical navigation should remember the last destination across launches.
- The Digital Crown anchors navigation, scrolling, and precision input, but ALWAYS back it up with touch.

```swift
// Source List: launch to detail, not the list
NavigationSplitView {
    List(rooms, selection: $selectedRoom) { room in  // source list stays untitled
        Text(room.name)
    }
} detail: {
    RoomView(room: selectedRoom)
}
// Initialize selectedRoom (last used / most relevant) so launch lands on detail
```

### Backgrounds and Materials
- Backgrounds must carry utility — recognition or information (a solar gradient tracking the sun, a state change from black to orange) — never mere flourish.
- Four vibrant full-screen materials (Ultra Thin → Thick) pair with Primary–Quaternary vibrant foreground styles and vibrant semantic colors to keep content legible over any background.

### Toolbars and Action Buttons
- Toolbar placements: `.topBarLeading`, `.topBarTrailing` (moves the time to the center), and `.bottomBar`.
- Bottom-of-detail action buttons are the most discoverable pattern. A red label signals destructive — add a confirmation if the data isn't recoverable.
- The More button (ellipsis in a circular container: white at 85% opacity with a 1pt black outer glow at 50%) holds ONLY secondary actions — never a primary action.
- Toolbar-revealed buttons belong only in scrolling views — scrolling is what makes them discoverable.

## Accessibility on watchOS (WWDC21 10223)

### Dynamic Type on the Watch
- watchOS has 11 text styles; a fixed `.font(.system(size: 24))` never scales — use `.font(.title3)` and friends.
- Let text wrap: `lineLimit(1)` truncates at accessibility sizes — set the real maximum you support (`.lineLimit(3)`) or remove the limit.
- Watch setup defaults text size to the closest match to the paired iPhone's setting — expect real users at accessibility sizes (WWDC21 10223).
- Swap layout when wrapping gets crowded:

```swift
@Environment(\.sizeCategory) var sizeCategory

var body: some View {
    if sizeCategory < .extraExtraLarge {
        PlantViewHorizontal(plant: $plant)   // default layout
    } else {
        PlantViewVertical(plant: $plant)     // stacked layout for large sizes
    }
}
```

### VoiceOver
- `NavigationLink` combines its children's accessibility automatically — don't add extra grouping inside one; the whole row becomes a single element (WWDC21 10223).
- Label icon+text rows so they read as meaning, not parts: `.accessibilityLabel("Watering in five days")` instead of "Drop, image. Five days." Label icon-only buttons too: `.accessibilityLabel("Log \(task.name)")` → "Log watering, button".
- Steppers/counters: collapse [minus, value, plus] into one adjustable element. Put the changing number in the **value** — it is re-spoken on every change; the label is spoken only on navigation:

```swift
CustomCounter(value: value, increment: increment, decrement: decrement)
    .accessibilityElement()               // drops the +/- buttons as separate stops
    .accessibilityAdjustableAction { direction in
        switch direction {
        case .increment: increment()      // swipe up
        case .decrement: decrement()      // swipe down
        default: break
        }
    }
    .accessibilityLabel("\(task.name) frequency")
    .accessibilityValue("\(value) days")
```

- Complications and dynamic notifications need the same treatment — they're extra content paths out of your app. Expand abbreviations ("Wednesday, March 9th", not "Wednesday Mar 9"), and label image complications or VoiceOver speaks the asset name (WWDC21 10223).

### AssistiveTouch
Hand gestures drive the watch with zero screen touches: **clench = tap, double-clench = action menu, pinch = next element, double-pinch = previous** (WWDC21 10223). A cursor focuses only interactive elements — Button, Toggle, NavigationLink, views with tap gestures, accessibility actions, or actionable traits; static text and disabled elements are skipped.

```swift
// ✅ static text whose parent owns the tap gesture — make it a cursor stop
FreeDrinkInfoView()
    .accessibilityRespondsToUserInteraction(true)

// ✅ cursor frame == tappable area; enlarge tiny hit targets
NavigationLink(destination: EditView()) {
    Image(systemName: "ellipsis").symbolVariant(.circle)
}
.contentShape(Circle().scale(1.5))
```

VoiceOver custom actions appear in the AssistiveTouch action menu automatically. Supply a real icon via the `Label` form of `.accessibilityAction { } label: { Label("Edit", systemImage: "ellipsis.circle") }` — otherwise the menu falls back to the first letter of the action name (WWDC21 10223).

## Architecture Patterns

### App Structure

```swift
@main
struct MyWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Navigation

```swift
// Use NavigationStack (watchOS 9+)
NavigationStack {
    List {
        NavigationLink("Item 1", value: Item.one)
        NavigationLink("Item 2", value: Item.two)
    }
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
    }
}

// TabView for main sections
TabView {
    HomeView()
    ActivityView()
    SettingsView()
}
.tabViewStyle(.verticalPage)
```

### List Design

```swift
List {
    ForEach(items) { item in
        ItemRow(item: item)
    }
    .onDelete(perform: delete)
}
.listStyle(.carousel)  // For focused content
.listStyle(.elliptical)  // For browsing
```

## Watch Connectivity

### Session Setup

```swift
import WatchConnectivity

@Observable
final class WatchConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    private(set) var isReachable = false

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Required delegate methods
    func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        isReachable = session.isReachable
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
}
```

### Data Transfer Methods

| Method | Use Case | Delivery |
|--------|----------|----------|
| `updateApplicationContext` | Latest state (settings) | Overwrites previous |
| `sendMessage` | Real-time, both apps active | Immediate |
| `transferUserInfo` | Queued data | Guaranteed, in order |
| `transferFile` | Large data | Background transfer |

```swift
// Application Context (most common)
func updateContext(_ data: [String: Any]) throws {
    try WCSession.default.updateApplicationContext(data)
}

// Real-time messaging
func sendMessage(_ message: [String: Any]) {
    guard WCSession.default.isReachable else { return }
    WCSession.default.sendMessage(message, replyHandler: nil)
}

// Receiving data
func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
    Task { @MainActor in
        // Update UI with received data
    }
}
```

## Complications

### Timeline Provider

```swift
import ClockKit

struct ComplicationController: CLKComplicationDataSource {

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptor = CLKComplicationDescriptor(
            identifier: "myComplication",
            displayName: "My App",
            supportedFamilies: [.circularSmall, .modularSmall, .graphicCircular]
        )
        handler([descriptor])
    }

    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        let template = makeTemplate(for: complication.family)
        let entry = CLKComplicationTimelineEntry(date: .now, complicationTemplate: template)
        handler(entry)
    }
}
```

### WidgetKit Complications (watchOS 9+)

```swift
import WidgetKit
import SwiftUI

struct MyComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MyComplication",
            provider: ComplicationProvider()
        ) { entry in
            ComplicationView(entry: entry)
        }
        .configurationDisplayName("My Complication")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryCorner,
            .accessoryInline
        ])
    }
}
```

## UI Components

### Digital Crown

```swift
@State private var crownValue = 0.0

ScrollView {
    // Content
}
.focusable()
.digitalCrownRotation($crownValue)
```

### Haptic Feedback

```swift
WKInterfaceDevice.current().play(.click)
WKInterfaceDevice.current().play(.success)
WKInterfaceDevice.current().play(.failure)
```

### Now Playing

```swift
import WatchKit

NowPlayingView()  // Built-in now playing controls
```

## Workout Apps

```swift
import HealthKit

@Observable
class WorkoutManager {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    func startWorkout(type: HKWorkoutActivityType) async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = type
        config.locationType = .outdoor

        session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
        builder = session?.associatedWorkoutBuilder()

        session?.startActivity(with: .now)
        try await builder?.beginCollection(at: .now)
    }
}
```

## Best Practices

### Performance
- Use `@Observable` over `ObservableObject` (watchOS 10+)
- Limit background refreshes
- Cache images locally
- Use lazy loading for lists

### Battery
- Minimize location updates
- Use scheduled background tasks
- Prefer complications over frequent refreshes
- Batch network requests

### User Experience
- Always show loading states
- Provide haptic feedback
- Support keyboard input
- Use clear iconography

## Testing

### Simulator
- Test with different watch sizes
- Verify complications in all families
- Test Watch Connectivity with paired iPhone simulator

### On Device
- Test battery impact
- Verify haptics feel appropriate
- Test in different lighting conditions

## Decision Tree

Choose the right reference file based on what the user needs:

```
What are you building?
|
+- iPhone <-> Watch data sync
|  -> watch-connectivity.md
|     +- Session management, application context, real-time messaging
|     +- File transfers, offline caching, complication push updates
|
+- Watch face complications
|  -> complications.md
|     +- ClockKit (legacy) vs WidgetKit (modern) complications
|     +- Migration from ClockKit to WidgetKit
|     +- Complication families (circular, rectangular, corner, inline)
|     +- Timeline providers, reload strategies, gauges
|
+- Health / fitness / workout tracking
|  -> health-fitness.md
|     +- HealthKit authorization and data types
|     +- HKWorkoutSession and HKLiveWorkoutBuilder
|     +- Real-time heart rate, calories, distance
|     +- Extended Runtime sessions, route tracking
|
+- watchOS widgets / Smart Stack
|  -> widgets-for-watch.md
|     +- Smart Stack configuration and relevance
|     +- Cross-platform widget sharing (iOS + watchOS)
|     +- watchOS-specific design (dark background, small screen)
|
+- General watchOS app development
   -> This file (SKILL.md)
      +- Design rules: ten-second test, layouts, navigation model, action buttons
      +- App structure, navigation, lists
      +- Digital Crown, haptics, Now Playing
```

## Reference Files

| File | Content |
|------|---------|
| [watch-connectivity.md](watch-connectivity.md) | iPhone <-> Watch sync, session management, data transfer, offline caching |
| [complications.md](complications.md) | ClockKit to WidgetKit migration, complication families, timeline providers, gauges |
| [health-fitness.md](health-fitness.md) | HealthKit, workout sessions, heart rate, Extended Runtime, route tracking, privacy |
| [widgets-for-watch.md](widgets-for-watch.md) | Smart Stack widgets, relevance, cross-platform sharing, watchOS design |

## External References

- [watchOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/designing-for-watchos)
- [Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity)
- [ClockKit](https://developer.apple.com/documentation/clockkit)
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [HealthKit Workouts](https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings)
