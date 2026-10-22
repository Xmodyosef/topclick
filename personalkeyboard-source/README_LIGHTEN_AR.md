# تخفيف وتقسيم — جولة 2

## A) تطبيق الحاوية
`KeyboardPrototypeApp.swift` أصبح نقطة الدخول فقط. باقي الشاشات في ملفات مستقلة:
NaqraDesign, ThemeModels, AppIconSwitcher, ContentView, KeyboardPreviewTab, ThemesTab, SettingsTab, TranslationPrepCard.

## B) بيانات الامتداد خارج السورس
`Sources/KeyboardExtension/Resources/`:
- keyboard_layouts.json
- arabic_lexicon.json
- emoji_catalog.json

التحميل عبر `KeyboardDataLoader` (كسول + كاش).

## ملاحظات
- `UserDefaults.synchronize` أزيل حيث وُجد.
- الهوية (Bundle / App Group) لم تُغيَّر.
