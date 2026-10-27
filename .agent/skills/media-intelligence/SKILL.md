---
name: media-intelligence
description: On-device photo and video AI with the iOS 27 Media Intelligence framework and Vision — group photos by person (FaceGroupAnalyzer), find a video's highlights and best key frame (VideoAnalyzer), and tap-to-select subject cutouts (GenerateIterativeSegmentationRequest), plus getting picker files into URLs and the privacy rules for face data. Use when building a photo organizer, video editor, journaling or memories feature, auto-thumbnails, highlight reels, "people" albums, or object cut-out in a media app.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27 / macOS 27
---

# Media Intelligence

New in iOS 27. These are on-device models for media apps, and they need neither Apple
Intelligence nor a server:

| Feature | API | Framework |
|---|---|---|
| Group photos by person; "who's in this photo?" | `FaceGroupAnalyzer` | MediaIntelligence |
| Most engaging segments plus a 0–9 engagement curve | `HighlightAnalysisRequest` | MediaIntelligence |
| The frame that best represents a clip (poster/thumbnail) | `KeyFrameAnalysisRequest` | MediaIntelligence |
| Tap, box, or scribble to select an object, then refine with more taps | `GenerateIterativeSegmentationRequest` | Vision |

Availability: iOS, macOS, tvOS, and visionOS 27. Everything runs in-process on the
Neural Engine and no data leaves the device. The full typechecked code is in
`templates/MediaAI.swift` (Swift 6 plus default MainActor isolation).

## When This Skill Activates

- "Group photos by person", "people album", "find everyone in this event"
- Auto-thumbnail or poster frame, highlight reel, "skip to the good part", engagement scrubber
- "Tap to cut out", "lift subject", or "remove background" with user-guided selection
- A video editor, journaling, memories, or photo-organizer app

## Inputs Are File URLs

Both analyzers take `.url(URL)` assets only. Copy picker results into a container you own:

```swift
struct PickedMovie: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { SentTransferredFile($0.url) } importing: { received in
            let dest = URL.cachesDirectory.appending(path: UUID().uuidString + "." + received.file.pathExtension)
            try FileManager.default.copyItem(at: received.file, to: dest)   // picker file is temporary
            return PickedMovie(url: dest)
        }
    }
}
```

✅ Run these analyzers on media **your app owns** (imported or captured).
❌ Re-implementing People for the whole system library. Photos already does that, and
exporting every asset needs full-library access plus a lot of disk space.

## People: FaceGroupAnalyzer

The analyzer persists its own database in a working directory. It resumes across
launches, and you never touch the files directly.

```swift
actor PeopleIndex {
    private let analyzer: FaceGroupAnalyzer
    private let directory: URL

    init() throws {
        directory = URL.applicationSupportDirectory.appending(path: "FaceGroups", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        analyzer = try FaceGroupAnalyzer(workingDirectory: directory)
    }

    func add(_ photos: [(id: String, url: URL)]) async throws -> Int {
        let assets = photos.map { MediaIntelligenceImageAsset(id: .init($0.id), kind: .url($0.url)) }
        var faces = 0
        for try await (_, found) in try await analyzer.insertOrUpdateAssets(assets) { faces += found.count }
        return faces
    }

    func regroup(progress: consuming Subprogress? = nil) async throws {
        if await analyzer.state == .stale { try await analyzer.update(subprogress: progress) }
    }

    func people() async throws -> [PersonGroup] {
        var groups: [PersonGroup] = []
        for try await (entity, assetIDs) in analyzer.allAssetIDsByEntityID {
            groups.append(PersonGroup(id: entity, photoIDs: assetIDs))
        }
        return groups.sorted { $0.photoIDs.count > $1.photoIDs.count }
    }
}
```

The workflow has three phases: **insert** (detect; faces have `entityID == nil`), then
**update** (cluster; `state` goes `.stale` → `.updating` → `.ready`), then **query**.

- **Asset IDs must be stable.** Use your model's ID, not a temp file name, because re-inserting the same ID updates in place.
- **`update(subprogress:)` is resumable.** If the app is killed mid-update, the state is `.stale` on next launch and the stored faces are kept. Run it from a `BackgroundTasks` processing task for big libraries.
- **Use `identifyFaces(in:)`** to tag a new photo against known people **without storing it**. It works when `.stale`, but it's more accurate after `update`.
- `fetchFaces(for:)`, `fetchFaces(in:)`, and `fetchAssetIDs(for:)` are synchronous `throws` calls (local store) that return async sequences.
- `Face.bounds` is a `CGRect` in the image. Crop it for avatar circles.
- `Subprogress` is noncopyable: a forwarding parameter must be `consuming Subprogress?`. Without that you get "must specify ownership".

### Face data rules (non-negotiable)

- ✅ Ask before scanning ("Group photos by person?"), and put an off switch in Settings.
- ✅ "Forget faces" calls `FaceGroupAnalyzer.purge(workingDirectory:)`, which permanently deletes everything.
- ✅ Keep the working directory out of iCloud backup if your privacy policy says on-device only (`URLResourceValues.isExcludedFromBackup`).
- ❌ Using face data for advertising, profiling, or sending it to a server. App Review guideline 5.1.2 restricts data from face-mapping tools.
- Names are your data. Store `Entity.ID → name` in your own model; the analyzer only knows clusters.

## Video: Highlights and Key Frame

Pass both requests in **one** call, which decodes the video once:

```swift
func analyzeVideo(_ url: URL) async throws -> VideoInsights {
    let asset = MediaIntelligenceVideoAsset(id: .init(url.lastPathComponent), kind: .url(url))
    let (highlight, key) = try await VideoAnalyzer.shared.analyze(
        asset, for: HighlightAnalysisRequest(), KeyFrameAnalysisRequest())

    var out = VideoInsights()
    if case .success(let h) = highlight {
        out.highlights = h.highlights                                   // [CMTimeRange]
        out.levels = h.levels.map { ($0.timeRange, $0.level) }          // 0 (dull) … 9 (most engaging)
    }
    if case .success(let k) = key { out.keyFrame = k.timestamp }        // CMTime
    return out
}
```

- The return is a **tuple of `Result`s**, one per request in order, so each can fail independently.
- Poster image: `AVAssetImageGenerator(asset:).image(at: keyFrame).image`.
- `VideoAnalyzer.shared` **runs requests serially with no queue limit or timeout.** Cancel stale work (`task.cancel()` when the user scrolls away) instead of enqueueing every clip in a grid.
- Cancellation is cooperative and can take a moment to return while the Neural Engine work stops.

Uses: highlight-reel export (`AVMutableComposition` from `highlights`), an engagement
heat-strip under the scrubber (`levels`), smart default thumbnails (`keyFrame`), and
"jump to best moment".

## Tap-to-Select Cutouts (Vision, iOS 27)

```swift
@MainActor @Observable
final class CutoutSession {
    let image: CGImage
    private var request: GenerateIterativeSegmentationRequest?
    private(set) var mask: CGImage?

    func tap(_ point: NormalizedPoint, include: Bool = true) async throws {
        if let request {
            if include { try request.addIncludedPoint(point) } else { try request.addExcludedPoint(point) }
        } else {
            let r = GenerateIterativeSegmentationRequest(seedPoint: point)
            r.qualityLevel = .balanced                         // .fast while dragging, .accurate for export
            request = r
        }
        guard let request, let observation = try await request.perform(on: image, orientation: nil) else {
            mask = nil; return                                 // nil = nothing to segment there
        }
        mask = try observation.cgImage                         // grayscale mask; the getter throws
    }
}
```

- Seed with `seedPoint:`, `seedBox:` (drag a rectangle), or `seedScribbleBuffer:`, then refine with included and excluded points.
- **Point budget:** 13 points with a point or scribble seed, 11 with a box seed. Past that, `addIncludedPoint` throws. Offer "Start over" (`request = nil`).
- **The model downloads on demand.** It's a `DownloadableAssetsRequest`: check `await request.assetStatus` and call `downloadAssets()` up front (`prepare()` in the template) so the first tap isn't slow.
- **Coordinates:** Vision is normalized with a **lower-left** origin. A SwiftUI tap is top-left in points: `NormalizedPoint(x: x / w, y: 1 - y / h)`, measured against the *displayed image* frame.
- Composite with `CIFilter.blendWithMask()`, after scaling the mask to the source extent.

For a fully automatic "lift the main subject" with no taps, VisionKit's
`ImageAnalysisInteraction` subject lifting already ships in system image views.

## Also Useful (Vision, iOS 18+)

- `CalculateImageAestheticsScoresRequest` gives `overallScore` (−1…1) and `isUtility` (screenshots, receipts). Use it to pick the best shot in a burst or to hide utility images from a memories feature.

## Common Mistakes

| ❌ | ✅ |
|---|---|
| Passing the picker's temp URL to the analyzer | Copy into your container first |
| Unstable asset IDs (file names that change) | Your model's persistent ID |
| Calling `update()` on every insert | Insert in batches, then `update()` once while `state == .stale` |
| Enqueueing analysis for every visible video | One task; cancel on scroll or disappear |
| Separate calls for highlights and key frame | One `analyze(_:for:_:)` call with both requests |
| Mask overlaid with top-left math | Flip Y; Vision is lower-left normalized |
| No "Forget faces" | `purge(workingDirectory:)` behind a Settings button |

## Checklist

- [ ] Media copied to app-owned URLs with stable IDs
- [ ] Face grouping is opt-in, with a Settings toggle and "Forget faces" (`purge`)
- [ ] `update()` batched and resumable (background processing task for large sets)
- [ ] Video analysis is one call per clip, cancellable, never mass-enqueued
- [ ] Segmentation model downloaded before first use; point budget handled
- [ ] Coordinate conversion verified on portrait and landscape images
- [ ] Tested on device (Neural Engine)

## References

- Media Intelligence: https://developer.apple.com/documentation/mediaintelligence
- Detecting and grouping faces in images: https://developer.apple.com/documentation/mediaintelligence/detecting-and-grouping-faces-in-images
- Finding the best moments in a video: https://developer.apple.com/documentation/mediaintelligence/finding-the-best-moments-in-a-video
- GenerateIterativeSegmentationRequest: https://developer.apple.com/documentation/vision/generateiterativesegmentationrequest
- CalculateImageAestheticsScoresRequest: https://developer.apple.com/documentation/vision/calculateimageaestheticsscoresrequest
- App Review Guidelines 5.1.2: https://developer.apple.com/app-store/review/guidelines/#data-use-and-sharing
- Related: `apple-intelligence/document-intelligence`, `ios/camera-scanning`, `core-ml` (Vision basics), `apple-intelligence/in-app-agent` (feed a frame to the model)
