# تنظيم مصادر لوحة نقرة

## خريطة المجلدات

- `App/Sources/AppShell/` — نقطة الدخول والواجهة الجذرية وتبديل الأيقونة.
- `App/Sources/Settings/` — الإعدادات وتجهيز الترجمة.
- `App/Sources/Themes/` — نماذج الثيمات ومخازن الحزم وواجهات الثيمات.
- `App/Resources/Assets.xcassets/` — صور وأيقونات التطبيق.
- `App/Config/` — `Info.plist` وملف entitlements للتطبيق.
- `KeyboardExtension/Sources/Lifecycle/` — دورة حياة لوحة المفاتيح وحالتها الأساسية.
- `KeyboardExtension/Sources/Input/` — إدخال النص والضغط المطوّل واللغة وتحميل البيانات.
- `KeyboardExtension/Sources/UI/` — بناء الصفوف والأزرار والشريط والألوان.
- `KeyboardExtension/Sources/Features/` — الإيموجي والحافظة والصوت والثيمات والترجمة.
- `KeyboardExtension/Resources/` — ملفات JSON التي تُضمّن صراحةً في الامتداد.
- `KeyboardExtension/Config/` — إعدادات وentitlements الامتداد.
- `Shared/Models/` — نماذج مشتركة بين التطبيق والامتداد.

## قواعد النقل

يُعلن كل مسار مصدر أو مورد في `project.yml`، وتُحدّث معه سكربتات التحقق وGitHub Actions والاختبارات. تغيير المجلدات لا يغيّر سلوك Swift أو Bundle IDs أو App Group، ويُتحقق من البناء عبر GitHub Actions.
