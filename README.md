# نقرة — Naqra

لوحة مفاتيح عربية/إنجليزية لـ iPhone وiPad، بتصميم هادئ وتخصيص سريع.

## الحالة

- البناء الحالي: `main`
- الإصدار: `0.2`
- الحد الأدنى: iOS 17
- التوقيع: IPA غير موقّع لـ ESign وFeather
- الخصوصية: لا شهادات أو مفاتيح داخل المستودع

## ما يميزها

- ثيمات إضافية مع تمرير أفقي
- تخصيص ألوان ومظهر المفاتيح
- أصوات نقر واهتزاز قابلة للتحكم
- اقتراحات عربية وإنجليزية
- تصحيح إنجليزي محافظ
- إيموجي وحافظة اختيارية
- ترجمة iOS 18 عند توفرها
- ارتفاع متكيف عند تغيير الاتجاه
- زر إعدادات للوصول الكامل
- بدون زر كرة ظاهر داخل اللوحة

## البناء

1. افتح **Actions**.
2. شغّل **Build PersonalKeyboard IPA**.
3. نزّل artifact باسم `PersonalKeyboard-unsigned-ipa`.
4. وقّعه عبر ESign أو Feather.

> لا يمكن تشغيل النسخ والترجمة وبعض الأصوات قبل تفعيل **Full Access** من إعدادات iOS.

## الهوية الثابتة

```text
App:       app.personal.PersonalKeyboard
Extension: app.personal.PersonalKeyboard.KeyboardExtension
Group:     group.app.personal.PersonalKeyboard
```

## التطوير

التعديلات تتم على `main` فقط. قبل أي تسليم، شغّل:

```bash
python3 .github/scripts/validate_naqra.py personalkeyboard-source
```

الإلهام مأخوذ من أنماط عامة في لوحات المفاتيح المفتوحة والتجارية، دون نسخ كود أو أصول مملوكة.
