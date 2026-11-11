# تنظيم التطبيق وتقسيمه

## تطبيق الحاوية

- `App/Sources/AppShell/` — نقطة الدخول والواجهة الجذرية وتبديل الأيقونة.
- `App/Sources/Settings/` — الإعدادات وتجهيز الترجمة.
- `App/Sources/Themes/` — الثيمات ومخازن حزمها ولوحة المعاينة.
- `App/Resources/Assets.xcassets/` — الأيقونات والأصول الرسومية.
- `App/Config/` — `Info.plist` وentitlements.

## امتداد لوحة المفاتيح

- `KeyboardExtension/Sources/Lifecycle/` — دورة حياة اللوحة.
- `KeyboardExtension/Sources/Input/` — الإدخال والضغط المطوّل واللغة وتحميل البيانات.
- `KeyboardExtension/Sources/UI/` — الصفوف والأزرار والرسم والألوان.
- `KeyboardExtension/Sources/Features/` — الإيموجي والحافظة والصوت والثيمات والترجمة.
- `KeyboardExtension/Resources/` — `keyboard_layouts.json` و`emoji_catalog.json`، ويُسجل كل منهما صراحةً في `project.yml`.
- `KeyboardExtension/Config/` — `Info.plist` وentitlements.

## المشترك والتحقق

`Shared/Models/SharedKeyboardData.swift` يُضمّن في هدفي التطبيق والامتداد. الاختبارات في `Tests/NaqraTests/`، وسكربتات الإصدار في `scripts/`؛ بعد أي نقل حدّث `project.yml` والمدققات وGitHub Actions.
