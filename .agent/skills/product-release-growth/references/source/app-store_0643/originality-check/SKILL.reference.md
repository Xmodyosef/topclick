---
name: originality-check
description: Guideline-4.3 anti-spam / originality gate — score whether an app (and each portfolio addition) is meaningfully distinct in function, content, and metadata before you invest or submit. Use when validating a new app idea, before adding an app to a portfolio, and again before submission. Protects the whole developer account from 4.3 (spam/duplicate) rejections. NOT rejection-handler (that works an existing rejection) and NOT competitive-analysis (that positions in the market).
allowed-tools: [Read, Write, WebSearch, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# Originality Check

Decide, with evidence, whether an app is *distinct enough to exist* — before you build it or submit it.

> At portfolio scale, shipping many similar small apps risks **Guideline 4.3 (spam / duplicate)**
> — this is the go/no-go distinctness gate that keeps that from happening.

## When This Skill Activates

- "Is this app too similar to my other apps?", "will this get rejected for spam?"
- Planning a second, third, or tenth small app in the same niche
- Template- or white-label-based apps, or clones of an existing app with a new theme
- A previous 4.3 rejection and a new submission in the same space

## Where it fits (read the seams)

- **Not `rejection-handler`.** That works a rejection you *already have*. This is upstream — it
  prevents the 4.3 by catching sameness before you ship.
- **Not `competitive-analysis` / `market-research`.** Those size demand and position you in the
  market. This judges *distinctness* (function + content + metadata) vs your own portfolio and vs
  near-identical competitors — a spam risk, not a demand question.
- **Two moments to run it:** at `validate` / `new-app` (don't build a dup) and before `submit`
  (don't trip 4.3). Also periodically across the portfolio (internal cannibalization / template-sameness).

## Prerequisites

- The app idea or a shipped app to evaluate (name, one-line function, target metadata).
- Optional: an existing competitor/market analysis (`product/competitive-analysis`, `product/market-research`). If missing/stale, gather fresh
  via WebSearch or the `product/competitive-analysis` skill.
- Optional App Store Connect access to read the developer's existing portfolio (`GET /v1/apps`, then each app's version localizations; via `_shared/asc-api/asc.py`).

## Flow

1. **Internal check (your own portfolio).** List your apps → for each shipped app read its positioning
   (subtitle, description). Does the candidate overlap one you already ship in **function**, **code
   template**, or **metadata**? Two apps that differ only in theme/reskin = 4.3 risk.
2. **External check (the market).** Read the existing competitor analysis if present; otherwise `WebSearch` for close
   look-alikes. Judge: is the core function a thin reskin of an existing app, or a genuine wedge?
3. **Distinctness scorecard.** Score each dimension *meaningful difference vs cosmetic*, and flag any
   that is only skin-deep:

   | Dimension | Distinct if… |
   |---|---|
   | **Function** | it does something materially different, not a template swap |
   | **Content / data** | unique data or content, not a generic wrapper |
   | **Metadata** | name / keywords / screenshots not near-identical to siblings or competitors |
   | **UX / value** | a real reason a user picks *this* one |

4. **Verdict + remedy.**
   - **Distinct** → proceed.
   - **Borderline** → give concrete ways to differentiate (merge sibling apps into one configurable
     app, add the unique wedge, or drop it); if approved, name the specific wedge that MUST be built
     to clear 4.3.
   - **Duplicate** → recommend not shipping; consolidate any existing thin apps into one strong
     app instead.
5. **Record.** Write the verdict + reasoning to `docs/ORIGINALITY.md` in the project. For a
   borderline-approved app, record the wedge as a build requirement in the spec so the build delivers it.

## Done

- A written verdict (distinct / borderline+wedge / duplicate) with per-dimension reasoning, and —
  if borderline — the specific differentiation that must ship before submission.

## Caveats

- **Cosmetic theming ≠ differentiation** — Apple judges function + metadata similarity, not intent.
- **Protect the account.** When in doubt between "borderline ship" and "consolidate," prefer one
  strong app over several thin ones.
- Guideline numbers/text drift — confirm current 4.3 wording at the
  [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) (verified 2026-10).

## Common Mistakes

✅ One app with five strong modes. ❌ Five apps that are the same app with a different color, name, or topic.
❌ Treating different keywords or screenshots as differentiation — reviewers compare what the app *does*.
✅ When borderline, name the wedge (a capability competitors and your own apps lack) and ship it in v1.

## References

- [App Review Guidelines 4.3 (Spam)](https://developer.apple.com/app-store/review/guidelines/#spam)
- Related: `app-store/rejection-handler`, `product/competitive-analysis`, `product/idea-generator`
