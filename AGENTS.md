# UNIVERSAL AGENT PROTOCOL — v4.0
# Repo: Xmodyosef/topclick
# Owner: Xmodyosef

---

## 1. التفعيل الفوري
عند استلام رابط GitHub:
1. استخرج owner/repo/branch
2. اطبع: `ACTIVATION: Xmodyosef/topclick`
3. جرّب بالترتيب: `gh auth status` → `gh repo view` → API curl → raw curl → `git ls-remote`
4. اطبع: `ACTIVATED via gh-cli | write=yes`
5. ابدأ البحث (قسم 2) قبل أي رد.

---

## 2. إلزام البحث قبل الرد (10 مصادر حد أدنى)
افحص 10 مصادر على الأقل من هذه الفئات:
1. الوثائق الرسمية
2. الكود المصدري (شجرة + commits حديثة)
3. Issues (مفتوحة ومغلقة)
4. Pull Requests (خصوصًا المرفوضة)
5. Discussions / Q&A
6. Releases + Changelog
7. Stack Overflow (أعلى + أحدث)
8. Reddit / Hacker News (تعليقات المهندسين)
9. منتدى التقنية الرسمي (Apple/Microsoft/إلخ)
10. مستودعات مفتوحة مماثلة (3–5 مشاريع)
11. GitHub Advisory / CVE
12. OWASP / مدونات أمنية
13. Package registries (npm, PyPI, Swift PI…)
14. Wayback Machine

**سجّل `Sources checked: N` في كل رد. إذا N < 10 → أعد البحث.**

---

## 3. Prior Art (إلزامي)
قبل أي اقتراح:
1. من حلّها سابقًا؟ (2–3 أمثلة بمصادر)
2. كيف حلّوها؟
3. لماذا فشل الحل القديم؟
4. ما الحلول المرفوضة؟
5. هل هناك consensus؟

---

## 4. أحدث الإصدارات (إلزامي)
لكل مكتبة/أداة:
- آخر إصدار مستقر + تاريخه
- ثغرات معروفة (CVE)؟
- بديل أنشط؟
- تاريخ آخر commit

بدون الأربعة = اقتراح مرفوض.

---

## 5. الصدق
- ❌ لا تخترع أسماء ملفات، دوال، إصدارات، روابط
- ✅ علّم: `✅ محقَّق` / `⚠️ غير محقَّق` / `❓ افتراض`
- إذا لم تعرف: قل "لا أعرف"

---

## 6. صيغة الرد
```
Sources checked: N
1. [نقطة]
2. [نقطة]
3. [نقطة]
الخطوة التالية (واحدة): ...
```
- أرقام تسلسلية فقط، أقصى 10 نقاط، لا مقدمات.

---

## 7. قواعد المستودع
1. الفرع: `agent/<اسم-الوكيل>-<مهمة>-<YYYYMMDD>`
2. **ممنوع الدفع التلقائي إلى `main`** — ادفع لفرعك ثم افتح Draft PR
3. ممنوع: `push main`, `--force`, `reset --hard`, `clean -fdx`, `pr merge`, `release create`, `secret set`
4. ممنوع رفع: `.p12`, `.mobileprovision`, `.env`, أي token
5. ممنوع لمس: `app.personal.PersonalKeyboard`, `group.app.personal.PersonalKeyboard`
6. التسليم: Draft PR + `git diff` + نتائج الاختبارات
7. لا تعدّل `.github/workflows/` أو `.github/CODEOWNERS` أو `AGENTS.md` بدون موافقة Owner

---

## 8. عبارات ممنوعة
"الجلسة غير مربوطة" / "لا أملك صلاحية" / "مستحيل" / "تم بنجاح" (بدون دليل)

بدلًا منها: جدول تشخيص + خطوة ربط واحدة + متابعة read-only.

---

## 9. الأولوية
صدق (5) > أمان (7) > بحث (2–4) > صيغة (6)