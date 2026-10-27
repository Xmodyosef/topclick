# SwiftUI Patterns

Quick reference for SwiftUI best practices and common patterns.

## State Management

Models use the Observation framework (`@Observable`, iOS 17+). The pre-iOS 17 wrappers
(`ObservableObject`, `@Published`, `@StateObject`, `@ObservedObject`, `@EnvironmentObject`) are for
legacy code only; migrating: `ios/migration-patterns` (observable-migration.md).

### Anti-patterns

```swift
// ❌ Creating a view-owned model without @State — recreated on every parent re-render
var viewModel = MyViewModel()

// ❌ Legacy wrappers in new code
@StateObject private var viewModel = MyViewModel()        // MyViewModel: ObservableObject

// ❌ Two sources of truth for the same value
@State private var name = ""
var expense: Expense          // and also editing expense.name
```

### Good patterns

```swift
@Observable
final class MyViewModel {
    var items: [Item] = []
}

// ✅ View owns the model
@State private var viewModel = MyViewModel()

// ✅ Passed in, read-only — a plain property; Observation tracks what body reads
let viewModel: MyViewModel

// ✅ Passed in and you need bindings ($viewModel.title)
@Bindable var viewModel: MyViewModel

// ✅ Shared across the hierarchy
@Environment(MyViewModel.self) private var viewModel       // injected with .environment(model)

// ✅ Two-way connection to a parent's value
@Binding var isPresented: Bool
```

### When to use each

| Wrapper | Use case | Owner |
|---|---|---|
| `@State` | Value-type state **and** `@Observable` models the view creates | This view |
| *(none)* / `let` | `@Observable` model passed in, read only | Parent |
| `@Bindable` | `@Observable` model passed in, needs `$` bindings | Parent |
| `@Environment(Type.self)` | `@Observable` model shared down the tree | App / scene |
| `@Binding` | Two-way access to a parent's value | Parent |

### Checklist
- [ ] Models are `@Observable` (no `ObservableObject` / `@Published` in new code)
- [ ] View-created models are held in `@State`
- [ ] Passed-in models are plain properties, or `@Bindable` when bindings are needed
- [ ] Shared models use `.environment(model)` + `@Environment(Model.self)`
- [ ] One source of truth per value

## View Composition

### Anti-patterns

```swift
// ❌ Massive view body
var body: some View {
    VStack {
        // 200 lines of code
    }
}

// ❌ Complex logic in view
var body: some View {
    let filtered = items.filter { $0.isActive }
    let sorted = filtered.sorted { $0.date > $1.date }
    let grouped = Dictionary(grouping: sorted) { $0.category }
    // ...
}
```

### Good patterns

```swift
// ✅ Extracted subviews
var body: some View {
    VStack {
        headerView
        contentView
        footerView
    }
}

private var headerView: some View { /* ... */ }

// ✅ Separate view components
struct ExpenseRow: View {
    let expense: Expense
    var body: some View { /* ... */ }
}

// ✅ Logic in ViewModel or computed property
var sortedExpenses: [Expense] {
    viewModel.getSortedExpenses()
}
```

### Checklist
- [ ] Break large views into smaller components
- [ ] Use `@ViewBuilder` for conditional views
- [ ] Avoid heavy computation in `body`
- [ ] Extract subviews for reusability
- [ ] Keep view structs focused (Single Responsibility)

## Performance

### Anti-patterns

```swift
// ❌ Creating objects in body
var body: some View {
    let formatter = DateFormatter() // Created every render!
    Text(formatter.string(from: date))
}

// ❌ Heavy computation without caching
var body: some View {
    let total = expenses.reduce(0) { $0 + $1.amount }
    Text("Total: \(total)")
}
```

### Good patterns

```swift
// ✅ Static/cached formatters
static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

// ✅ Computed in ViewModel
var totalAmount: Double {
    viewModel.totalAmount
}

// ✅ Use @State for computed values
@State private var totalAmount: Double = 0

var body: some View {
    Text("Total: \(totalAmount)")
        .onAppear {
            totalAmount = viewModel.calculateTotal()
        }
}
```

### Checklist
- [ ] Use `Equatable` for complex view data
- [ ] Avoid creating ViewModels in `body`
- [ ] Use `id()` modifier carefully
- [ ] Minimize `@State` changes
- [ ] Avoid unnecessary view updates
- [ ] Cache expensive formatters and computations

## Common SwiftUI Patterns

### Conditional Views

```swift
// ✅ Using @ViewBuilder
@ViewBuilder
var content: some View {
    if isLoading {
        ProgressView()
    } else if hasError {
        ErrorView()
    } else {
        ContentView()
    }
}
```

### List Performance

```swift
// ✅ Provide stable IDs
List(expenses, id: \.id) { expense in
    ExpenseRow(expense: expense)
}

// ✅ For dynamic lists
List {
    ForEach(expenses) { expense in
        ExpenseRow(expense: expense)
    }
    .onDelete(perform: deleteExpenses)
}
```

### Form Handling

```swift
// ✅ Clean form structure
Form {
    Section("Details") {
        TextField("Name", text: $name)
        TextField("Amount", value: $amount, format: .currency(code: "USD"))
    }

    Section("Options") {
        Toggle("Is Paid", isOn: $isPaid)
        Picker("Category", selection: $category) {
            ForEach(ExpenseCategory.allCases) { category in
                Text(category.rawValue).tag(category)
            }
        }
    }
}
```

### Navigation

```swift
// ✅ NavigationStack (iOS 16+)
NavigationStack {
    List(items) { item in
        NavigationLink(value: item) {
            ItemRow(item: item)
        }
    }
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
    }
}

// ✅ Sheet presentation
.sheet(isPresented: $showingSheet) {
    AddItemView()
}

// ✅ Alert presentation
.alert("Delete Item?", isPresented: $showingAlert) {
    Button("Delete", role: .destructive) {
        deleteItem()
    }
    Button("Cancel", role: .cancel) { }
}
```

## Memory Management in SwiftUI

### Closures in ViewModels

```swift
// ✅ Weak self in escaping closures
func loadData() {
    dataService.fetch { [weak self] data in
        guard let self = self else { return }
        self.process(data)
    }
}
```

### Task Cancellation

```swift
// ✅ Proper task lifecycle
.task {
    await viewModel.loadData()
}
// Automatically cancelled when view disappears

// ✅ Manual task management
@State private var dataTask: Task<Void, Never>?

var body: some View {
    ContentView()
        .onAppear {
            dataTask = Task {
                await loadData()
            }
        }
        .onDisappear {
            dataTask?.cancel()
        }
}
```

## References

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui)
- [Thinking in SwiftUI](https://www.objc.io/books/thinking-in-swiftui/)
