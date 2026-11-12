---
name: keyboard-extension
description: Use when working on custom iOS keyboards, Arabic/English layouts, key interactions, long-press alternatives, emoji, sound, haptics, App Groups, or keyboard-extension limits.
---

# Keyboard Extensions

حزمة لوحة مفاتيح iOS (عربي/إنجليزي). لا تعتمد على مراجع خارج المنتج: مرجع نسخ HTML لحافظة الماك أُزيل لأنه لا يخص إضافة لوحة المفاتيح.

## طريقة الاستخدام

1. حدّد نطاق المهمة والمخاطر قبل التعديل (ذاكرة الإضافة، App Group، RTL، الضغط المطول، الإيموجي).
2. اقرأ الكود الحالي في `personalkeyboard-source/KeyboardExtension/` قبل أي تغيير.
3. تحقق بـ `python3 skills/ios-keyboard-release-gate/scripts/check_keyboard_release.py personalkeyboard-source` قبل اعتبار الإصدار جاهزاً.
4. لا تنشئ مهارة جديدة إذا كان يمكن تحديث هذه الحزمة بمرجع يخص iOS فقط.

## الحدود

- لا تستخدم أوامر ماك (`osascript`, `pbcopy`) داخل هذه الحزمة.
- لا تفتح Full Access أو الشبكة دون حاجة صريحة من المالك.
- نجاح الفحص الساكن لا يغني عن تجربة IPA على iPhone.
