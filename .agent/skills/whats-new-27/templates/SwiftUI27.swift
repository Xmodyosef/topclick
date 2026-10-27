import SwiftUI

struct Card: Identifiable, Hashable, Sendable {
    let id: UUID
    var title: String
}

// MARK: - Reorder + swipe in ANY container (not just List)

@MainActor @Observable
final class Board {
    var cards: [Card] = (1...12).map { Card(id: UUID(), title: "Card \($0)") }

    func apply(_ diff: ReorderDifference<Card.ID, ReorderableSingleCollectionIdentifier>) {
        let moving = cards.filter { diff.sources.contains($0.id) }
        cards.removeAll { diff.sources.contains($0.id) }
        switch diff.destination.position {
        case .before(let id):
            let index = cards.firstIndex { $0.id == id } ?? cards.endIndex
            cards.insert(contentsOf: moving, at: index)
        case .end:
            cards.append(contentsOf: moving)
        }
    }

    func delete(_ card: Card) { cards.removeAll { $0.id == card.id } }
}

struct BoardView: View {
    @State private var board = Board()
    @State private var pendingDelete: Card?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                ForEach(board.cards) { card in
                    Text(card.title)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(.thinMaterial, in: .rect(cornerRadius: 12))
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button("Delete", systemImage: "trash", role: .destructive) { pendingDelete = card }
                        }
                }
                .reorderable()
            }
            .padding()
            .reorderContainer(for: Card.self) { board.apply($0) }
            .swipeActionsContainer()
        }
        // Alert driven by an optional item — the item flows into actions and message.
        .alert("Delete card?", item: $pendingDelete) { card in
            Button("Delete", role: .destructive) { board.delete(card) }
        } message: { card in
            Text("\"\(card.title)\" will be removed.")
        }
    }
}

// MARK: - Errors straight into an alert

enum SyncError: LocalizedError {
    case offline
    var errorDescription: String? { "You're offline" }
    var recoverySuggestion: String? { "Changes will sync when you reconnect." }
}

struct SyncButton: View {
    @State private var error: SyncError?
    var body: some View {
        Button("Sync") { error = .offline }
            .alert(error: $error) {
                Button("OK") {}
            }
    }
}

// MARK: - Toolbars that degrade gracefully

struct EditorToolbar: View {
    var body: some View {
        NavigationStack {
            Text("Document")
                .toolbar {
                    ToolbarItem(placement: .topBarPinnedTrailing) {        // never moves to overflow
                        Button("Share", systemImage: "square.and.arrow.up") {}
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Bold", systemImage: "bold") {}
                    }
                    .visibilityPriority(.high)                              // last to collapse
                    ToolbarItem(placement: .primaryAction) {
                        Button("Ruler", systemImage: "ruler") {}
                    }
                    .visibilityPriority(.low)                               // first to collapse
                    ToolbarOverflowMenu {                                   // always in "•••"
                        Button("Archive", systemImage: "archivebox") {}
                        Button("Delete", systemImage: "trash", role: .destructive) {}
                    }
                }
                .toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
        }
    }
}

// MARK: - Tabs, sheets, images

struct RootTabs: View {
    @State private var composing = false
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") { Text("Home") }
            Tab("Library", systemImage: "books.vertical") { Text("Library") }
            Tab("New", systemImage: "plus", role: .prominent) {     // separate, trailing position
                Button("Compose") { composing = true }
            }
        }
        .sheet(isPresented: $composing) {
            Text("Composer")
                .navigationTransition(.crossFade)                     // fades in over content
        }
    }
}

struct Avatar: View {
    let url: URL
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 20_000_000, diskCapacity: 200_000_000)
        return URLSession(configuration: config)
    }()

    var body: some View {
        AsyncImage(request: URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)) { phase in
            if let image = phase.image { image.resizable().scaledToFill() } else { Color.secondary.opacity(0.2) }
        }
        .frame(width: 44, height: 44)
        .clipShape(.circle)
        .asyncImageURLSession(Self.session)
    }
}
