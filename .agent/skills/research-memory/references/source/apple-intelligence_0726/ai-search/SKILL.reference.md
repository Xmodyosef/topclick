---
name: ai-search
description: Natural-language "ask my app" search over the app's own content with SpotlightSearchTool (iOS 27) — index items with Core Spotlight, hand the index to a Foundation Models session as a tool, stream an answer plus matching items, choose on-device vs Private Cloud Compute guides, add custom pipeline stages and a ContactResolver. Use when the user wants semantic or conversational search, "find my notes from last Tuesday", RAG over local data, or an AI search box without a vector database or server.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
last_verified: 2026-10-11
review_by: 2027-06-22
os_version: iOS 27 / macOS 27
---

# AI Search (SpotlightSearchTool)

iOS 27 gives the language model a search tool over **your app's Core Spotlight
index**. The model writes the queries (text, semantic similarity, dates, numbers,
people), reads the hits, and answers in prose. Your UI gets the matching items as a
live stream. That replaces a vector database, an embeddings pipeline, and a RAG
server for most local-first apps.

Everything here compiles against the iOS 27 SDK in Swift 6 and under default
MainActor isolation. A complete, typechecked version is in `templates/AISearch.swift`.

## When This Skill Activates

- "Search my notes/recipes/trips with a question", "AI search box", "ask my data"
- RAG / retrieval over on-device content, semantic search, "find X from last week"
- Already indexing with Core Spotlight and want an LLM on top
- Choosing on-device vs Private Cloud Compute for search

## How It Fits Together

```
your data ──► CSSearchableItem (+ custom attributes) ──► CSSearchableIndex (named)
                                                              │
LanguageModelSession(tools: [SpotlightSearchTool]) ◄──────────┘
   │ model issues queries, filters, re-queries            tool.searchResults ──► your result cards
   └─► streamed prose answer
```

Imports: `import CoreSpotlight` + `import FoundationModels`. The tool lives in the
cross-import overlay, so you get it automatically with both imports. Availability:
iOS / macOS / visionOS 27, not tvOS or watchOS.

## 1. Index Well, or the Model Has Nothing to Read

The model only sees the attributes you index **and** list in `fetchAttributes`.

```swift
nonisolated enum RecipeIndex {
    static let name = "recipes"
    // CSCustomAttributeKey isn't Sendable — build on demand, don't store a static.
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
        attrs.setValue(NSNumber(value: r.minutes), forCustomKey: minutesKey)
        return CSSearchableItem(uniqueIdentifier: r.id, domainIdentifier: "recipe", attributeSet: attrs)
    }
}
```

Index in a batch with client state so relaunches don't redo the work:

```swift
func indexAll(force: Bool = false) async throws {
    let state = withUnsafeBytes(of: Self.schemaVersion) { Data($0) }
    if !force, try await index.fetchLastClientState() == state { return }
    let items = await store.all().map(RecipeIndex.item(for:))
    index.beginBatch()
    try await index.indexSearchableItems(items)
    try await index.endBatch(withClientState: state)
}
```

- ✅ A **named** index (`CSSearchableIndex(name:)`) per content type, with an `indexDelegate`.
- ✅ Upsert and delete on every save. A stale index means confident wrong answers.
- ✅ Implement the delegate's async `searchableItems(forIdentifiers:)`. The tool calls it to
  **hydrate** full items, which enriches the answer.
- ❌ Putting everything in `textContent`. Structured attributes (dates, numbers, keywords) let the
  model filter ("under 30 minutes", "last Tuesday") instead of guessing.

The delegate class is `nonisolated` and `@unchecked Sendable`: `CSSearchableIndex`
is thread-safe but not annotated, and the system calls the delegate off the main thread
(see the template).

## 2. Build the Tool

```swift
static let fetchAttributes: [SearchableItemAttribute] = [
    .title, .contentDescription, .keywords, .contentCreationDate,
    SearchableItemAttribute(rawValue: RecipeIndex.minutesKey.keyName),   // custom attribute
]

private func makeTool() -> SpotlightSearchTool {
    var source = CoreSpotlightSource(searchableIndexDelegate: indexer, fetchAttributes: Self.fetchAttributes)
    source.maximumResultCount = 20
    let guide: SpotlightSearchTool.Guide = useCloud
        ? .complete
        : .init(level: .focused(.documents(.init(keywords: [.keywords], created: [.contentCreationDate]))),
                format: .compact)
    return SpotlightSearchTool(configuration: .init(sources: [.coreSpotlight(source)], guide: guide))
}
```

### Pick the guide by model

| Guide | What the model gets | Use with |
|---|---|---|
| `.complete` (**default**) | Every search technique, full schema | Private Cloud Compute (32K context) |
| `.focused(domain)` | A small, domain-shaped schema | **On-device model** (small context window) |
| `.dynamic(GuidanceProfile)` | Only the techniques you enable (`textMatch`, `similarityMatch`, `numericMatch`, `dates`, `people`, `contentType`, `attributes`) | Turning off a technique that misfires on your data |

Domains: `.items` (title/text/dates; the default), `.documents`, `.communications`,
`.calendar`, `.audio`, `.visualMedia`. Each takes an attribute mapping, for example
`.documents(.init(authors: [.authorNames, SearchableItemAttribute(rawValue: "com_myapp_chef")]))`.

Format: `.structured` (default; precise, token-heavy) or `.compact` (terse lines; pick
this on-device).

- ❌ Leaving the default `.complete` guide on the on-device model. Apple's docs warn that it's tuned
  for PCC. With the small model it overflows the context window (`LanguageModelError.contextSizeExceeded`).
  Always set a guide that fits the model.

## 3. Ask and Stream

```swift
func ask(_ question: String) async {
    answer = ""; hits = []; error = nil
    let tool = makeTool()                                   // fresh tool + session per question
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
        for try await snapshot in session.streamResponse(to: question) { answer = snapshot.content }
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
        case .count, .table, .statistic, .text: continue      // aggregate answers ("how many…")
        @unknown default: continue
        }
        hits += items.filter { seen.insert($0.uniqueIdentifier).inserted }   // model re-queries → dedupe
    }
}
```

- Result cards appear **before** the prose finishes, so show them as they arrive.
- `SearchableItem` wraps `CSSearchableItem` (`.item`). Unwrap at this boundary and keep the rest of
  the UI on your own types.
- `.count`, `.statistic`, and `.table` replies answer "how many…" and "average…" questions. Render
  them if your app has such questions.
- ✅ Tell the model what your attributes *mean* in the instructions ("Keywords hold the cuisine").
- ✅ Gate on `SystemLanguageModel.default.availability` (see `apple-intelligence/on-device-ai-kit`).
  When it's unavailable, fall back to plain `CSUserQuery` keyword search over the same index.

## 4. On-Device vs Private Cloud Compute

```swift
private let pcc = PrivateCloudComputeLanguageModel()
private var useCloud: Bool { preferCloud && pcc.isAvailable }
```

- PCC needs the **managed entitlement** `com.apple.developer.private-cloud-compute`. Request it
  from Apple before you build for it; without it, stay on-device.
- PCC is online-only and has a **daily per-user quota**. Show `pcc.quotaUsage` status inline,
  offer `quotaUsage.limitIncreaseSuggestion?.show()`, and retry on-device when the network fails.
- Swap the guide with the model (`.complete` ↔ `.focused`). Everything else stays the same.
- Details: `apple-intelligence/foundation-models` → `models-and-agents.md`.

## 5. Extend the Pipeline

**Custom stage.** This is app logic the model can insert into a query plan. Example: a
filter, re-ranker, or scorer.

```swift
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
```

**"Me" resolution.** Social and messaging apps need this so "messages I sent Sam" works:

```swift
struct Me: ContactResolver {
    func userIdentity() -> ResolvedContact {
        var c = ResolvedContact(displayName: "Sam")
        c.emailAddresses = ["sam@example.com"]
        return c
    }
}

var config = SpotlightSearchTool.Configuration(sources: [.coreSpotlight])
config.customStages = [QuickFilter(maxMinutes: 30)]
config.contactResolver = Me()
config.maximumResponseSize = 4_000                    // cap what goes back into context
```

**Files.** Use `.files(FileSource)` with `scopes: [URL]` to search the metadata of files your
app created. Those files must already be indexed (custom types go through a `CSImportExtension`).

## Testing

- **The Simulator** follows the host Mac's Apple Intelligence state. Test the real path on device.
- **Unit-test your own code**: `RecipeIndex.item(for:)` attribute mapping and `CustomStage.execute`.
  Both are pure functions.
- **Answer quality** needs evals: a fixed index fixture plus 20–50 questions with expected item IDs,
  re-run on every OS update. The model changes with the OS. See `foundation-models`.
- Use the Foundation Models instrument to see every query the model issued and how many tokens each used.

## Common Mistakes

| ❌ | ✅ |
|---|---|
| Default `.complete` guide on-device | `.focused(domain)` + `.compact` on-device; `.complete` on PCC |
| Attribute indexed but missing from `fetchAttributes` | The model only reads fetched attributes, so list every one it should reason over |
| Reusing one session across unrelated questions | Fresh tool and session per question (Apple's sample does this) |
| Showing duplicate cards | Dedupe by `uniqueIdentifier`, since the model re-queries |
| Index never updated after edits | Upsert and delete in the same code path as saving |
| Storing `CSCustomAttributeKey` in a `static let` | It isn't Sendable (Swift 6 error), so build it in a computed property |
| No fallback | `CSUserQuery` keyword search when Apple Intelligence is unavailable |

## Checklist

- [ ] Named `CSSearchableIndex` with a delegate (reindex-all, reindex-ids, hydration)
- [ ] Batch indexing with client state; schema version bump forces a reindex
- [ ] Structured attributes (dates, numbers, keywords) plus custom keys, all in `fetchAttributes`
- [ ] Guide matches the model: `.focused` + `.compact` on-device, `.complete` on PCC
- [ ] `searchResults` drives result cards, deduped, before the prose finishes
- [ ] Availability gate plus a keyword-search fallback
- [ ] PCC only with the entitlement; quota UI; on-device retry when offline
- [ ] Eval set of questions → expected items

## References

- Searching indexed content with natural language (sample): https://developer.apple.com/documentation/corespotlight/searching-indexed-content-with-natural-language
- SpotlightSearchTool: https://developer.apple.com/documentation/corespotlight/spotlightsearchtool
- CustomStage: https://developer.apple.com/documentation/corespotlight/customstage
- Adding server-side intelligence with Private Cloud Compute: https://developer.apple.com/documentation/foundationmodels/adding-server-side-intelligence-with-private-cloud-compute
- Core Spotlight: https://developer.apple.com/documentation/corespotlight
- Related: `apple-intelligence/foundation-models`, `apple-intelligence/on-device-ai-kit`, `apple-intelligence/app-intents` (`IndexedEntityQuery`), `apple-intelligence/in-app-agent`
