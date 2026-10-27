# Naqra Keyboard

نقرة (Naqra) لوحة مفاتيح عربية/إنجليزية مخصصة لـ iPhone وiPad، مبنية باستخدام Swift وUIKit وSwiftUI. يركز المشروع على تخطيط قريب من لوحة Apple، الثبات، التخصيص، الثيمات، الصوت، والإيموجي، مع دعم البناء غير الموقّع للتجربة عبر أدوات sideloading مثل ESign وFeather.

يستخدم المستودع نظام **AI Skill** متقدمًا داخل `.agent/skills/` لمساعدة الوكلاء على تنفيذ مراجعات وتعديلات أكثر اتساقًا، مع بروتوكول تشغيل موثق في `AGENTS.md` وفهرس مهارات في `SKILLS.md`.

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
