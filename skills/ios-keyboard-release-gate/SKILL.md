---
name: ios-keyboard-release-gate
description: Validate iOS custom keyboard release readiness, App Groups, extension resources, version metadata, system keyboard switching, and built IPA/app bundles. Use before reviewing or releasing a keyboard extension.
---

# بوابة إصدار لوحة مفاتيح iOS

استخدم هذه المهارة قبل مراجعة أو إصدار تطبيق يحتوي على `UIInputViewController` وامتداد لوحة مفاتيح.

## الخطوات

1. من جذر المستودع شغّل `python3 skills/ios-keyboard-release-gate/scripts/check_keyboard_release.py personalkeyboard-source`.
2. أصلح كل إخفاق قبل البناء؛ لا تعتبر نجاح الفحص الساكن دليلًا على نجاح التوقيع أو التثبيت.
3. بعد البناء، أضف `--built-app path/to/PersonalKeyboard.app` لفحص الحزمة المولدة والامتداد وملفات الموارد المضمّنة.
4. أبلغ بوضوح أن الانتقال بين لوحات النظام وVoiceOver والتوقيع وFeather/ESign تحتاج تجربة فعلية على iPhone.

## الحدود

السكربت يتحقق من عقود الملفات والإعدادات فقط؛ لا يحلل Swift ولا يستبدل `xcodebuild` أو اختبارات iPhone. لا تفتح Full Access أو الحافظة أو الشبكة دون حاجة صريحة.
