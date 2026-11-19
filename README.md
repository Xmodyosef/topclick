# Naqra Keyboard

نقرة (Naqra) لوحة مفاتيح عربية/إنجليزية مخصصة لـ iPhone وiPad، مبنية باستخدام Swift وUIKit وSwiftUI. يركز المشروع على تخطيط قريب من لوحة Apple، الثبات، التخصيص، الثيمات، الصوت، والإيموجي، مع دعم البناء غير الموقّع للتجربة عبر أدوات sideloading مثل ESign وFeather.

يستخدم المستودع **7 حزم مهارات** داخل `skills/`، تشمل بوابة إصدار لوحة المفاتيح، ومدقق توجيه المهارات، ومراجعة VoiceOver. يعرض `SKILLS.md` الفهرس، وتُفحص عقود المصدر على GitHub Actions قبل بناء IPA.

## For AI Agents

**Read `AGENTS.md` and `SKILLS.md` before making any changes.**

## البناء والتحقق

```bash
python3 .github/scripts/validate_naqra.py personalkeyboard-source
cd personalkeyboard-source
xcodegen generate
xcodebuild -project PersonalKeyboard.xcodeproj -scheme PersonalKeyboard \
  -configuration Release -sdk iphoneos -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
```

التوقيع غير مضمّن في هذا المستودع؛ يجب توقيع IPA الناتج بأداة sideloading مناسبة قبل تثبيته على الجهاز.

يفحص GitHub Actions موارد الامتداد قبل بناء IPA؛ لا يُستخدم Workflow مستقل لنقل ملفات JSON إلى مسار مختلف.

يستخدم مسار نقرات لوحة المفاتيح `AudioToolbox` (`AudioServicesCreateSystemSoundID` و`AudioServicesPlaySystemSound`) لتشغيل عينات CAF المخزنة مؤقتًا، من دون `AVAudioEngine` أو `AVAudioPlayerNode` أو جدولة PCM buffers داخل امتداد لوحة المفاتيح.

## هيكل ملفات التطبيق

تُقسم مصادر iOS حسب الهدف والوظيفة: `personalkeyboard-source/App/Sources/` للتطبيق، و`KeyboardExtension/Sources/` للوحة، و`Shared/Models/` للكود المشترك. توجد ملفات الإعداد في مجلدي `Config/`، وموارد الامتداد في `KeyboardExtension/Resources/`، والاختبارات في `Tests/NaqraTests/`. خريطة تفصيلية في [`SPLIT_MAP.txt`](personalkeyboard-source/SPLIT_MAP.txt).

## الإصدار الموحد

- **Version:** `0.2.11` — مصدر الحقيقة في `personalkeyboard-source/VERSION`.
- **Build:** `33` — رقم بناء مستقل ومتزايد، موحّد للتطبيق وامتداد لوحة المفاتيح.
- **IPA name:** `PersonalKeyboard-0.2.11.ipa`.
- **Release tag المعتمد للإصدار القادم:** `v0.2.11` بعد نجاح CI ومراجعة الحزمة.

### ملاحظات التثبيت
1. نزّل IPA الناتج من GitHub Actions بعد نشره.
2. وقّع عبر ESign أو Feather مع **App Group** `group.Mark1`.
3. فعّل لوحة نقرة من إعدادات iOS.
