import SwiftUI
import CoreSpotlight
import FoundationModels

// MARK: - Domain

struct Recipe: Sendable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let cuisine: String
    let minutes: Int
    let created: Date
}

protocol RecipeStore: Sendable {
    func all() async -> [Recipe]
    func recipes(ids: [String]) async -> [Recipe]
}

// MARK: - Indexing

nonisolated enum RecipeIndex {
    static let name = "recipes"
    // CSCustomAttributeKey isn't Sendable, so build it on demand instead of storing a static.
    static var minutesKey: CSCustomAttributeKey {
        CSCustomAttributeKey(keyName: "com_example_recipes_minutes", searchable: true,
                             searchableByDefault: false, unique: false, multiValued: false)!
    }

    static func item(for r: Recipe) -> CSSearchableItem {
        let attrs = CSSearchableItemAttributeSet(contentType: .text)
        attrs.title = r.title
        attrs.contentDescription = r.summary
        attrs.keywords = [r.cuisine]
        attrs.contentCreationDate = r.created
        attrs.duration = NSNumber(value: r.minutes * 60)
        attrs.setValue(NSNumber(value: r.minutes), forCustomKey: minutesKey)
        return CSSearchableItem(uniqueIdentifier: r.id, domainIdentifier: "recipe", attributeSet: attrs)
    }
}

/// Owns the named index and answers the system's reindex / hydration callbacks.
/// `@unchecked`: CSSearchableIndex is thread-safe but not annotated Sendable; every stored property is `let`.
nonisolated final class RecipeIndexer: NSObject, CSSearchableIndexDelegate, @unchecked Sendable {
    let index: CSSearchableIndex
    let store: any RecipeStore

    init(store: any RecipeStore) {
        self.index = CSSearchableIndex(name: RecipeIndex.name)
        self.store = store
        super.init()
        index.indexDelegate = self
    }

    /// Bump when the item shape changes (new attributes) to force a full reindex.
    static let schemaVersion = 1

    /// Batch + client state so a relaunch doesn't reindex everything.
    func indexAll(force: Bool = false) async throws {
        let state = withUnsafeBytes(of: Self.schemaVersion) { Data($0) }
        if !force, try await index.fetchLastClientState() == state { return }
        let items = await store.all().map(RecipeIndex.item(for:))
        index.beginBatch()
        try await index.indexSearchableItems(items)
        try await index.endBatch(withClientState: state)
    }

    func upsert(_ r: Recipe) async throws { try await index.indexSearchableItems([RecipeIndex.item(for: r)]) }
    func remove(id: String) async throws { try await index.deleteSearchableItems(withIdentifiers: [id]) }

    // Index lost → rebuild.
    func searchableIndex(_ searchableIndex: CSSearchableIndex,
                         reindexAllSearchableItemsWithAcknowledgementHandler ack: @escaping () -> Void) {
        Task { try? await indexAll(force: true); ack() }
    }

    func searchableIndex(_ searchableIndex: CSSearchableIndex,
                         reindexSearchableItemsWithIdentifiers ids: [String],
                         acknowledgementHandler ack: @escaping () -> Void) {
        Task {
            let items = await store.recipes(ids: ids).map(RecipeIndex.item(for:))
            try? await index.indexSearchableItems(items)
            ack()
        }
    }

    // Hydration: the search tool asks for full items to enrich the answer.
    func searchableItems(forIdentifiers ids: [String]) async -> [CSSearchableItem] {
        await store.recipes(ids: ids).map(RecipeIndex.item(for:))
    }
}

// MARK: - Ask

@MainActor @Observable
final class AskRecipes {
    private(set) var answer = ""
    private(set) var hits: [CSSearchableItem] = []
    private(set) var error: String?
    private(set) var isSearching = false

    private let indexer: RecipeIndexer
    private let pcc = PrivateCloudComputeLanguageModel()
    var preferCloud = false   // needs the PCC managed entitlement

    init(indexer: RecipeIndexer) { self.indexer = indexer }

    static let fetchAttributes: [SearchableItemAttribute] = [
        .title, .contentDescription, .keywords, .contentCreationDate,
        SearchableItemAttribute(rawValue: RecipeIndex.minutesKey.keyName),
    ]

    private var useCloud: Bool { preferCloud && pcc.isAvailable }

    private func makeTool() -> SpotlightSearchTool {
        var source = CoreSpotlightSource(searchableIndexDelegate: indexer, fetchAttributes: Self.fetchAttributes)
        source.maximumResultCount = 20
        let guide: SpotlightSearchTool.Guide = useCloud
            ? .complete
            : .init(level: .focused(.documents(.init(keywords: [.keywords], created: [.contentCreationDate]))),
                    format: .compact)
        return SpotlightSearchTool(configuration: .init(sources: [.coreSpotlight(source)], guide: guide))
    }

    func ask(_ question: String) async {
        answer = ""; hits = []; error = nil; isSearching = true
        defer { isSearching = false }

        let tool = makeTool()               // fresh tool + session per question
        let listener = Task { await self.collect(from: tool) }
        defer { listener.cancel() }

        let instructions = """
            You answer questions about the user's saved recipes. Always search before answering. \
            Keywords hold the cuisine. Only mention recipes the search returned.
            """
        let session = useCloud
            ? LanguageModelSession(model: pcc, tools: [tool], instructions: instructions)
            : LanguageModelSession(tools: [tool], instructions: instructions)
        do {
            for try await snapshot in session.streamResponse(to: question) {
                answer = snapshot.content
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func collect(from tool: SpotlightSearchTool) async {
        var seen = Set<String>()
        for await reply in tool.searchResults {
            let items: [CSSearchableItem]
            switch reply.content {
            case .items(let r): items = r.map(\.item)
            case .scoredItems(let r): items = r.map(\.item.item)
            case .groupedItems(let g): items = g.values.flatMap { $0 }.map(\.item)
            case .count, .table, .statistic, .text: continue
            @unknown default: continue
            }
            hits += items.filter { seen.insert($0.uniqueIdentifier).inserted }
        }
    }
}

// MARK: - Custom stage

@Generable
struct QuickFilter: CustomStage {
    static var name: String { "quick" }
    static var description: String { "Keeps only recipes that take at most the given number of minutes." }
    static var inputTypes: [SearchPipelineDataType] { [.items] }
    static var outputType: SearchPipelineDataType { .items }

    @Guide(description: "Maximum total minutes")
    var maxMinutes: Int

    func execute(items: [SearchableItem]) async throws -> SearchPipelineData {
        .items(items.filter {
            let v = $0.item.attributeSet.value(forCustomKey: RecipeIndex.minutesKey) as? NSNumber
            return (v?.intValue ?? .max) <= maxMinutes
        })
    }
}

struct Me: ContactResolver {
    func userIdentity() -> ResolvedContact {
        var c = ResolvedContact(displayName: "Sam")
        c.emailAddresses = ["sam@example.com"]
        return c
    }
}

func configured() -> SpotlightSearchTool.Configuration {
    var c = SpotlightSearchTool.Configuration(sources: [.coreSpotlight])
    c.customStages = [QuickFilter(maxMinutes: 30)]
    c.contactResolver = Me()
    c.maximumResponseSize = 4_000
    c.guide = .dynamic(.init(textMatch: true, similarityMatch: true, numericMatch: true, dates: true, people: false))
    return c
}

// MARK: - UI

struct AskView: View {
    @State var model: AskRecipes
    @State private var question = ""

    var body: some View {
        NavigationStack {
            List {
                if !model.answer.isEmpty { Text(model.answer) }
                Section("Matches") {
                    ForEach(model.hits, id: \.uniqueIdentifier) { item in
                        Text(item.attributeSet.title ?? "Untitled")
                    }
                }
            }
            .overlay { if model.isSearching && model.hits.isEmpty { ProgressView() } }
            .searchable(text: $question, prompt: "Ask about your recipes")
            .onSubmit(of: .search) { Task { await model.ask(question) } }
            .navigationTitle("Recipes")
        }
    }
}
