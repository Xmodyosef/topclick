---
name: store-signals
description: Close the post-launch loop — turn a live app's App Store signals (reviews, analytics, sales, crashes, listing conversion) into a metric-tagged backlog for the next version, and verify whether last cycle's changes moved the metric they promised to move. Read-only on App Store Connect; every proposed change is routed to the skill that makes it. Use when asking what users are saying or what to build next: before planning a version, monthly, or 1–2 weeks after shipping to check whether a change worked.
allowed-tools: [Read, Write, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# Store Signals

Pull what the *shipped* app is telling you, turn it into the next backlog, and check whether
last cycle's bets paid off.

> This is what turns build → ship into a **loop**:
> `ship → MEASURE → DIAGNOSE → plan → build → ship → measure again…`
> The ledger (`docs/SIGNALS.md`) makes it a loop instead of a monthly report.

## When This Skill Activates

- "What are users saying?", "what should v1.3 be?", "did the onboarding change help retention?"
- Monthly review of a live app, or 1–2 weeks after a release
- Choosing which app in a portfolio deserves the next week of work

## Where it fits

- **Not `growth/analytics-interpretation`.** That *interprets* one metric you hand it (is 14% D7 good?).
  This gathers every signal → clusters → diagnoses → writes a metric-tagged backlog → closes last
  cycle's hypotheses. It *uses* analytics-interpretation's benchmarks.
- **Not `growth/store-growth-audit`.** That scores the listing and store setup against a checklist. This
  reads what real users did and said.
- **Read-only on App Store Connect.** Never replies to reviews, never edits metadata or pricing. It
  surfaces, asks for an explicit OK, and routes the change.

## Data sources (read-only)

Read with `_shared/asc-api/asc.py` (`GET … --apply`; GETs change nothing), or an App Store Connect
MCP server's equivalent tools if one is installed. Every endpoint below was checked against Apple's
API reference on 2026-10-03.

| Signal | Endpoint |
|---|---|
| App id | `GET /v1/apps?filter[bundleId]=<id>` |
| Reviews / ratings | `GET /v1/apps/{id}/customerReviews?sort=-createdDate` · `GET /v1/customerReviews/{id}` |
| Analytics (retention, funnel, impressions → downloads) | `GET /v1/apps/{id}/analyticsReportRequests` (none yet → `POST /v1/analyticsReportRequests` with `accessType: ONGOING`) |
| Sales / proceeds | `GET /v1/salesReports?filter[…]` (gzipped TSV; `asc.py` decompresses it) |
| Crashes / hangs | `GET /v1/builds/{id}/diagnosticSignatures` |
| Launch, memory, energy | `GET /v1/apps/{id}/perfPowerMetrics` |
| Beta crashes | `GET /v1/apps/{id}/betaFeedbackCrashSubmissions` (or `product/tester-loop`) |
| Listing copy | `GET /v1/apps/{id}/appStoreVersions` → `GET /v1/appStoreVersions/{id}/appStoreVersionLocalizations` |

## Inputs

- A live (or TestFlight) app and its bundle id.
- The app's positioning: who it's for, the job it does, what it deliberately won't do. Read it from the
  project (`README`, PRD) or ask once with `AskUserQuestion` and write it at the top of `docs/SIGNALS.md`.
- `docs/SIGNALS.md` if present — OPEN hypotheses from prior runs, each with a target metric, recorded
  baseline, and "check-after" date. Formats: **signals-ledger.md**.

## Flow

1. **Load prior hypotheses.** Read `docs/SIGNALS.md` → the OPEN rows to verify in step 5.
2. **Pull the signals**, this period vs trailing period (table above). A freshly requested analytics
   report is empty until Apple's next delivery; note "retention/funnel lands next cycle".
3. **Normalize & cluster.** Dedupe reviews into recurring themes (requests / complaints / praise) with
   frequency; attach magnitude (users / revenue / retention affected). Weight by **frequency ×
   revenue impact**, not by the loudest reviewer.
4. **Diagnose, filter, prioritize.** Map each cluster to the metric it moves (rating · D7 · paid
   conversion · crash-free rate · listing conversion · proceeds); score **impact × confidence ÷ effort**.
   **Strategy filter:** on-positioning → backlog; off-positioning → **"Declined (why)"** (never silently
   drop, never silently build). Small sample (new app): say so, lean on reviews, flag low confidence.
5. **Close the prior loop.** For each OPEN hypothesis that shipped and passed its "check-after" date,
   compare the target metric now vs baseline → **WIN / REGRESSION / NEUTRAL**. WIN → resolve;
   REGRESSION → open a revert/rethink task; NEUTRAL → keep watching or retire.
6. **Write the backlog.** Append a dated, metric-tagged section to the project's backlog (`ROADMAP.md`
   or wherever it keeps one) and update `docs/SIGNALS.md`. Output a ranked digest (top 3–5: what hurts
   most, why, the proposed move), the loop-closure results, and where each move goes:

| Move | Skill |
|---|---|
| Hot crash | `testing/tdd-bug-fix` |
| Listing / keyword fix | `app-store/keyword-optimizer`, `app-store/app-description-writer` |
| Review replies | `app-store/review-response-writer` |
| Feature request worth building | `testing/tdd-feature` |
| Pricing / paywall change | `monetization`, `generators/paywall-generator` |

✅ Every backlog item cites its signal and magnitude ("23 reviews mention sync loss; 1-star share up 4 pts").
❌ "Users want dark mode" from one loud review.

## Portfolio mode

With several apps: run steps 2–4 for each app from `GET /v1/apps`, then rank which app to invest in
next, biggest fixable revenue/retention/rating gap first. One line per app plus the single
highest-ROI move overall.

## Done when

- Ranked, cited digest
- WIN/REGRESSION/NEUTRAL closure for last cycle
- Metric-tagged backlog written, `docs/SIGNALS.md` updated, each move routed to a skill

## Caveats

- **Read-only.** Never auto-apply pricing, metadata, or review replies: surface → confirm → route.
- **Verify last cycle (step 5) before planning the next.** That closure is the point of the skill.
- Apple delivers analytics on its own schedule; a new report request is empty until the next cycle.

## References

- App Store Connect API: https://developer.apple.com/documentation/appstoreconnectapi
- Analytics reports: https://developer.apple.com/documentation/appstoreconnectapi/analytics
- Related: `growth/analytics-interpretation`, `growth/store-growth-audit`, `product/tester-loop`
