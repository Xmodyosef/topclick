---
name: tester-loop
description: Run the TestFlight feedback loop from the terminal — invite testers, toggle public links, and pull tester screenshot feedback and crash logs into markdown files Claude can triage into fixes. Ships a zero-dependency asc.swift (CryptoKit-signed App Store Connect API). Use after builds are on TestFlight, when the user asks "what are testers saying", "add a tester", "get the crash logs", or wants a weekly beta triage.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# Tester Loop

The cycle that matters in a small beta: **ship → testers use it → feedback lands →
fix → ship**. TestFlight already collects screenshot feedback and crash reports;
the App Store Connect API exposes both. This skill pulls them into the repo as
markdown so Claude can read, cluster, and turn them into tasks — no dashboard
clicking.

Upstream: `generators/testflight-ship` (getting builds up). Strategy (how many
testers, what to ask, go/no-go) → `product/beta-testing`.

## When This Skill Activates

- "Invite <person> to the beta", "make a public TestFlight link"
- "What did testers report?", "pull crash logs", "triage beta feedback"
- Step 5 of `product/local-first-app`

## Setup

```bash
cp <skill>/templates/asc.swift scripts/asc.swift
# Same key as ship.sh — add to .env.ship:
echo 'BUNDLE_ID=com.yourname.MyApp' >> .env.ship
grep -q '^feedback/$' .gitignore || echo 'feedback/' >> .gitignore   # testers' emails live here
```

Run with the env loaded:

```bash
set -a; . ./.env.ship; set +a
swift scripts/asc.swift builds
```

No pip, gems, or Homebrew: the script signs the ES256 JWT with CryptoKit
(`P256.Signing.PrivateKey(pemRepresentation:)` reads the `.p8` directly). Verified to
compile clean under Swift 6 on Xcode 27.0.

## Commands

| Command | API | Notes |
|---|---|---|
| `builds` | `GET /v1/builds?filter[app]=…&sort=-uploadedDate` | Watch `processingState` go `PROCESSING` → `VALID` |
| `groups` | `GET /v1/apps/{id}/betaGroups` | Shows internal/external + public link |
| `invite <email> <group> [first] [last]` | `POST /v1/betaTesters` with `betaGroups` relationship | Tester gets an email with a redeem link |
| `public-link <group> on\|off` | `PATCH /v1/betaGroups/{id}` `publicLinkEnabled` | External groups only; needs a build that passed Beta App Review |
| `feedback [n]` | `GET /v1/apps/{id}/betaFeedbackScreenshotSubmissions?sort=-createdDate` | → `feedback/<date>-screenshots.md` |
| `crashes [n]` | `GET /v1/apps/{id}/betaFeedbackCrashSubmissions` + `GET /v1/betaFeedbackCrashSubmissions/{id}/crashLog` | → `feedback/<date>-crashes.md` with `logText` |

Each feedback item carries `comment`, `email`, `deviceModel`, `osVersion`,
`locale`, `batteryPercentage`, `connectionType`, `appUptimeInMilliseconds`, and
(screenshot submissions) `screenshots[]` of `{url, width, height, expirationDate}`.
Screenshot URLs are signed and **expire** — download any you need to keep.

## Triage Workflow (what Claude does with the files)

1. `swift scripts/asc.swift feedback && swift scripts/asc.swift crashes`
2. Read both markdown files. Cluster by *symptom*, not by tester.
3. For crashes, find the first frame in the app's own module in `logText`; map to file/line.
4. Output a triage table:

```markdown
| # | Symptom | Reports | Devices / iOS | Severity | Next step |
|---|---------|---------|---------------|----------|-----------|
| 1 | Crash opening Health tab | 3 | iPhone 13 · 27.0 | 🔴 Critical | tdd-bug-fix: HealthView nil sample |
| 2 | "AI summary button missing" | 2 | iPhone 14 · 27.0 | 🟡 Medium | Expected (no Apple Intelligence) — add explainer row |
| 3 | Dark mode text unreadable | 1 | iPhone 16 Pro | 🟢 Low | ui-review |
```

5. Fix the top item with `testing/tdd-bug-fix`, ship with `scripts/ship.sh testflight`, and
   reply to the tester (they gave their email in the feedback).

✅ Treat "feature missing" reports on older iPhones as a UX signal — the app should
*explain* AI-gated features, not hide them silently (`apple-intelligence/on-device-ai-kit`).
❌ Committing `feedback/` — it contains tester emails and device details. Keep it git-ignored.

## Getting Better Feedback

- Fill **What to Test** on every build (App Store Connect → TestFlight → build). One or two concrete tasks beat "try everything".
- Tell testers the gesture: **take a screenshot → tap the thumbnail → Share Beta Feedback**. Crash prompts appear automatically after a crash.
- Keep a feedback route for testers who don't screenshot: `generators/feedback-form`.

## Gotchas

- **401 NOT_AUTHORIZED** → wrong issuer/key ID pair, clock skew, or a key revoked in Users and Access. Tokens live 20 minutes max (the script signs a fresh one per run).
- **403 on invite** → the key's role lacks tester management; use App Manager or Admin.
- **No app found** → the App Store Connect app record must exist and `BUNDLE_ID` must match exactly.
- **Internal testers** must be App Store Connect users first (Users and Access); `invite` is for adding people to groups, usually external ones.

## Checklist

- [ ] `.env.ship` has `BUNDLE_ID` plus the ASC key variables
- [ ] `feedback/` git-ignored
- [ ] At least one external group with feedback enabled (`groups` shows it)
- [ ] Triage table produced and top issue routed to a fix
- [ ] Testers who reported the fixed issue told which build has it

## References

- TestFlight API (beta testers, groups): https://developer.apple.com/documentation/appstoreconnectapi/prerelease-versions-and-beta-testers
- Beta feedback screenshot submissions: https://developer.apple.com/documentation/appstoreconnectapi/betafeedbackscreenshotsubmission
- Beta feedback crash log: https://developer.apple.com/documentation/appstoreconnectapi/get-v1-betafeedbackcrashsubmissions-_id_-crashlog
- Generating tokens: https://developer.apple.com/documentation/appstoreconnectapi/generating-tokens-for-api-requests
- Related: `generators/testflight-ship`, `product/beta-testing`, `testing/tdd-bug-fix`, `generators/feedback-form`
