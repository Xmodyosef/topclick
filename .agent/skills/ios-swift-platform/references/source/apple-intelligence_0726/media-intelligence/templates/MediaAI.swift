import SwiftUI
import PhotosUI
import CoreMedia
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import MediaIntelligence
import Vision

// MARK: - Getting file URLs out of the picker (Media Intelligence takes URLs only)

struct PickedMovie: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { SentTransferredFile($0.url) } importing: { received in
            // The picker's file is temporary — copy it somewhere you own.
            let dest = URL.cachesDirectory.appending(path: UUID().uuidString + "." + received.file.pathExtension)
            try FileManager.default.copyItem(at: received.file, to: dest)
            return PickedMovie(url: dest)
        }
    }
}

// MARK: - People: FaceGroupAnalyzer

struct PersonGroup: Identifiable, Sendable {
    let id: FaceGroupAnalyzer.Entity.ID
    let photoIDs: [MediaIntelligenceImageAsset.ID]
}

actor PeopleIndex {
    private let analyzer: FaceGroupAnalyzer
    private let directory: URL

    init() throws {
        directory = URL.applicationSupportDirectory.appending(path: "FaceGroups", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        analyzer = try FaceGroupAnalyzer(workingDirectory: directory)   // resumes previous data
    }

    /// Detect faces in new or changed photos. IDs must be stable — use your model's ID, not the file name.
    func add(_ photos: [(id: String, url: URL)]) async throws -> Int {
        let assets = photos.map { MediaIntelligenceImageAsset(id: .init($0.id), kind: .url($0.url)) }
        var faces = 0
        for try await (_, found) in try await analyzer.insertOrUpdateAssets(assets) { faces += found.count }
        return faces
    }

    /// Cluster faces into people. Only needed when state is `.stale`; resumable after a kill.
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

    /// "Who is in this new photo?" without storing it.
    func whoIsIn(_ url: URL) async throws -> [FaceGroupAnalyzer.Entity.ID] {
        let probe = MediaIntelligenceImageAsset(id: .init("probe-\(UUID())"), kind: .url(url))
        var ids: [FaceGroupAnalyzer.Entity.ID] = []
        for try await (_, faces) in try await analyzer.identifyFaces(in: [probe]) {
            ids += faces.compactMap(\.entityID)
        }
        return ids
    }

    func remove(_ photoIDs: [String]) async throws {
        try await analyzer.deleteAssets(photoIDs.map { .init($0) })   // leaves state .stale
    }

    /// Settings → "Forget faces". Deletes everything permanently.
    func forgetAll() async throws {
        try await FaceGroupAnalyzer.purge(workingDirectory: directory)
    }
}

// MARK: - Video: highlights + key frame in one decode

struct VideoInsights: Sendable {
    var highlights: [CMTimeRange] = []
    var levels: [(range: CMTimeRange, level: Float)] = []   // 0 (dull) … 9 (most engaging)
    var keyFrame: CMTime?
}

func analyzeVideo(_ url: URL) async throws -> VideoInsights {
    let asset = MediaIntelligenceVideoAsset(id: .init(url.lastPathComponent), kind: .url(url))
    let (highlight, key) = try await VideoAnalyzer.shared.analyze(
        asset, for: HighlightAnalysisRequest(), KeyFrameAnalysisRequest())

    var out = VideoInsights()
    if case .success(let h) = highlight {
        out.highlights = h.highlights
        out.levels = h.levels.map { ($0.timeRange, $0.level) }
    }
    if case .success(let k) = key { out.keyFrame = k.timestamp }
    return out
}

func thumbnail(of url: URL, at time: CMTime) async throws -> CGImage {
    let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
    generator.appliesPreferredTrackTransform = true
    return try await generator.image(at: time).image
}

@MainActor @Observable
final class VideoInsightsModel {
    private(set) var insights: VideoInsights?
    private(set) var poster: CGImage?
    private(set) var isAnalyzing = false
    private var task: Task<Void, Never>?

    func analyze(_ url: URL) {
        task?.cancel()                         // analyses queue serially — don't pile them up
        task = Task {
            isAnalyzing = true
            defer { isAnalyzing = false }
            do {
                let result = try await analyzeVideo(url)
                insights = result
                if let t = result.keyFrame { poster = try await thumbnail(of: url, at: t) }
            } catch {
                insights = nil
            }
        }
    }

    func cancel() { task?.cancel() }           // cooperative; may take a moment on the Neural Engine
}

// MARK: - Tap-to-select: GenerateIterativeSegmentationRequest

enum CutoutError: Error { case nothingSelected }

/// Keep one request per selection and add points as the user taps.
@MainActor @Observable
final class CutoutSession {
    let image: CGImage
    private var request: GenerateIterativeSegmentationRequest?
    private(set) var mask: CGImage?
    private(set) var modelReady = false

    init(image: CGImage) { self.image = image }

    func prepare() async throws {
        let probe = GenerateIterativeSegmentationRequest(seedPoint: NormalizedPoint(x: 0.5, y: 0.5))
        if await probe.assetStatus != .ready { try await probe.downloadAssets() }   // on-demand model
        modelReady = true
    }

    /// `point` is normalized with a lower-left origin, like all Vision coordinates.
    func tap(_ point: NormalizedPoint, include: Bool = true) async throws {
        if let request {
            if include { try request.addIncludedPoint(point) } else { try request.addExcludedPoint(point) }
        } else {
            let r = GenerateIterativeSegmentationRequest(seedPoint: point)
            r.qualityLevel = .balanced
            request = r
        }
        guard let request, let observation = try await request.perform(on: image, orientation: nil) else {
            mask = nil
            return
        }
        mask = try observation.cgImage
    }

    func reset() { request = nil; mask = nil }

    func cutout() throws -> CIImage {
        guard let mask else { throw CutoutError.nothingSelected }
        let source = CIImage(cgImage: image)
        let scaledMask = CIImage(cgImage: mask).transformed(by: CGAffineTransform(
            scaleX: source.extent.width / CGFloat(mask.width), y: source.extent.height / CGFloat(mask.height)))
        let blend = CIFilter.blendWithMask()
        blend.inputImage = source
        blend.backgroundImage = CIImage.empty()
        blend.maskImage = scaledMask
        return blend.outputImage ?? source
    }
}

/// SwiftUI tap location (top-left origin, view points) → Vision normalized point (lower-left origin).
func normalized(_ location: CGPoint, in size: CGSize) -> NormalizedPoint {
    NormalizedPoint(x: location.x / size.width, y: 1 - location.y / size.height)
}

struct CutoutView: View {
    @State var session: CutoutSession

    var body: some View {
        GeometryReader { geo in
            Image(decorative: session.image, scale: 1)
                .resizable()
                .scaledToFit()
                .overlay {
                    if let mask = session.mask {
                        Image(decorative: mask, scale: 1).resizable().scaledToFit()
                            .blendMode(.screen).opacity(0.5).allowsHitTesting(false)
                    }
                }
                .onTapGesture { location in
                    Task { try? await session.tap(normalized(location, in: geo.size)) }
                }
        }
        .task { try? await session.prepare() }
    }
}
