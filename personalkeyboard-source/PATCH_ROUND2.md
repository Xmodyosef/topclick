# Patch Round 2 — App-side fixes (KeyboardPrototypeApp.swift)

Apply these three search-and-replace edits. Do NOT rewrite the whole file.

## 1) MiniKeyboardView — remove globe button

Find:
```swift
            HStack(spacing: 4) {
                keyButton("🌐", width: 36)
                keyButton("123", width: 44)
                keyButton("😊", width: 36)
```

Replace with:
```swift
            HStack(spacing: 4) {
                keyButton("123", width: 44)
                keyButton("😊", width: 36)
```

## 2) ThemesTab — sections + live preview + selected highlight

Find the whole `struct ThemesTab` and replace with the version in `ThemesTab_v2.swift` (pushed separately).

## 3) SettingsTab — Full Access button

Inside `var body` of SettingsTab, after `guideCard`, add:
```swift
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "lock.open")
                            Text("تفعيل الوصول الكامل")
                            Spacer()
                            Image(systemName: "chevron.left")
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radius.button))
                        .foregroundStyle(.white)
                    }
```
