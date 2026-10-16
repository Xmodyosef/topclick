import SwiftUI

struct ThemesTab: View {
    @State private var themeID = ThemeStore.string("themeId") ?? TimeTheme.preferredThemeId()
    @State private var section = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Live keyboard preview — changes with selected theme
                    MiniKeyboardView()
                        .frame(height: 210)
                        .padding(.horizontal)
                        .id(themeID) // force refresh on theme change

                    Picker("", selection: $section) {
                        Text("أساسية").tag(0)
                        Text("صباح").tag(1)
                        Text("مساء").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    let items = section == 0 ? ThemeCatalog.core : section == 1 ? ThemeCatalog.morning : ThemeCatalog.evening

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 12) {
                        ForEach(items) { swatch in
                            Button {
                                themeID = swatch.id
                                ThemeStore.write("themeId", value: swatch.id)
                            } label: {
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(swatch.key)
                                        .frame(height: 56)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(themeID == swatch.id ? NaqraColors.accent : Color.clear, lineWidth: 2.5)
                                        )
                                        .overlay(Text(swatch.title.prefix(1)).font(.title3.bold()).foregroundStyle(swatch.ink))
                                    Text(swatch.title).font(.caption2).foregroundStyle(.white).lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(LinearGradient(colors: [Color.black, Color(red: 0.07, green: 0.07, blue: 0.11)], startPoint: .top, endPoint: .bottom))
            .navigationTitle("الثيمات")
        }
    }
}
