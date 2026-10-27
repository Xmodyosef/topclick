---
name: local-first-app
description: Playbook for building a small iPhone app with no backend — data on device (SwiftData), optional free sync via iCloud, Apple services and on-device AI in place of servers and API keys — from empty folder to testers' phones in days. Sequences the other skills (project-bootstrap → features → testflight-ship → tester-loop) and makes the architecture calls. Use when the user wants to build an app "quickly", "without a backend", "local only", "for a few testers", "on my own phone", or asks where to start.
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# Local-First App Playbook

Small-scale iOS development, start to finish: an app whose data lives on the phone,
whose "backend" is Apple's frameworks, and which reaches a tester's iPhone in one
command. This skill makes the architecture calls and sequences the specialist
skills. It doesn't repeat them.

Full product process (market research, PRD, ASO) → `product/product-agent`. Use this skill
when the goal is **working software in testers' hands fast**.

## When This Skill Activates

- "Build an app quickly", "no backend", "local-only", "offline app"
- "I want to run it on my phone / give it to a few friends"
- "Where do I start?" for a small personal or prototype app
- Choosing between a server and on-device approaches

## Step 0 — Three Questions (ask, don't assume)

1. **Who runs it?** Only you → free Apple ID works (7-day reinstalls). Friends/testers → $99 Apple Developer Program + TestFlight.
2. **Does data need to leave the phone?** No → SwiftData only. Same user's other devices → SwiftData + iCloud sync. Other *people* → this isn't a no-backend app; see "When You Do Need a Server".
3. **Which Apple services?** Health, motion, camera, weather, location, calendar, AI, speech. Each adds a permission and a usage string, so pick only what the core loop needs.

## Architecture (the defaults)

```
┌──────────── SwiftUI views ────────────┐
│  @Observable view models (MainActor)  │
├───────── protocol seams ──────────────┤
│ HealthStoring  StepSource  Summarizer │  ← fakes in tests/previews
│ WeatherFetching  Transcribing  …      │
├──────── Apple frameworks ─────────────┤
│ HealthKit · CoreMotion · WeatherKit   │
│ FoundationModels · Speech · Vision    │
├──────────── storage ──────────────────┤
│ SwiftData (local)  [+ CloudKit sync]  │
└───────────────────────────────────────┘
```

| Concern | Default | Skill |
|---|---|---|
| Project | XcodeGen `project.yml`, iOS 27, iPhone-only | `ios/project-bootstrap` |
| Storage | SwiftData | `generators/persistence-setup` |
| Sync (optional) | SwiftData + CloudKit private DB (no server, no auth screen) | `generators/cloudkit-sync` |
| Identity | None. The device/iCloud account *is* the user | — |
| AI | On-device, gated, with fallbacks | `apple-intelligence/on-device-ai-kit` |
| Settings | `@AppStorage` | `generators/settings-screen` |
| Reminders | Local notifications | `ios/native-services` |
| Distribution | `scripts/ship.sh device` / `testflight` | `generators/testflight-ship` |
| Feedback | TestFlight API → markdown → triage | `product/tester-loop` |
| Concurrency | Default MainActor isolation, Swift 6 | `swift/concurrency-patterns` |

✅ No login screen. A local-first app has no account to create, which is one of its best features.
❌ Adding Firebase "just for auth". It brings a privacy policy burden, an App Privacy label, and an SDK update cycle, for no benefit to a single-user app.

### Sync decision

| Data | Store | Sync |
|---|---|---|
| User's own records (notes, logs, habits) | SwiftData | CloudKit private DB, free, Apple handles conflicts |
| Health data | **HealthKit itself** (read on demand) | Apple syncs Health. **Never copy health data to iCloud** (App Review 5.1.3) |
| Derived health stats you cache | SwiftData with **`cloudKitDatabase: .none`** for that store | none |
| Preferences | `@AppStorage` | `NSUbiquitousKeyValueStore` if needed |
| Large files (scans, audio) | App container files | iCloud Drive documents, if the user wants them |

A health app that also syncs non-health data uses **two SwiftData configurations**:
one CloudKit-backed (non-health), one local-only (health-derived).

## Step-by-Step

| Step | Do | Skill | Done when |
|---|---|---|---|
| 1 | Scaffold project, tests, `.gitignore` | `ios/project-bootstrap` | `xcodebuild test` green on Simulator |
| 2 | Model + persistence | `generators/persistence-setup` | Data survives relaunch |
| 3 | Core loop UI with **fake** services | `generators/preview-data-generator`, `testing/tdd-feature` | Usable in Simulator with fake data |
| 4 | Real Apple services behind the protocols | `ios/healthkit`, `ios/device-sensors`, `ios/native-services`, `ios/camera-scanning` | Works on your phone |
| 5 | On-device AI with gate + fallback | `apple-intelligence/on-device-ai-kit`, `apple-intelligence/speech-translation` | Works on an AI device *and* degrades on a non-AI one |
| 6 | On your phone | `generators/testflight-ship` (`ship.sh device`) | Running on hardware |
| 7 | App icon, usage strings, privacy policy | `generators/app-icon-generator`, `legal/privacy-policy`, `security/privacy-manifests` | Upload won't bounce |
| 8 | TestFlight | `generators/testflight-ship` (`ship.sh testflight`) | Internal testers install it |
| 9 | Feedback loop | `product/tester-loop` | Triage table → fixes → next build |

Fakes first (step 3) is the speed trick. The Simulator has no motion sensors, an empty
Health store, and AI that depends on the host Mac. Building the UI on fakes means hardware
only comes in at step 4.

## Scope Guard (small means small)

For a first TestFlight build:
- One core loop, 3–5 screens
- iPhone only, portrait, light + dark mode
- One or two Apple services, not all of them
- English only (localize later: `generators/localization-setup`)
- No paywall (`generators/paywall-generator` when there's demand)

Write these down in the repo's README as the v0.1 boundary. Anything else goes to a `LATER.md`.

## When You Do Need a Server

The no-backend approach stops working when you need:
- **Data shared between different people** (a shared list with a partner can still use CloudKit *shared* databases; a public feed can't)
- **Remote push** triggered by events outside the device
- **Server-side secrets** (paid third-party APIs, webhooks)
- **Cross-platform** users (Android/web)

Even then, keep the local-first core and add the server for one capability only. See `generators/networking-layer`.

## Checklist

- [ ] Three questions answered and recorded in the README
- [ ] Every Apple service behind a protocol with a fake
- [ ] No auth screen, no third-party SDKs in v0.1
- [ ] Health data never in CloudKit; separate local store if cached
- [ ] AI features gated with fallbacks/explainers
- [ ] Builds on your phone via `ship.sh device`
- [ ] TestFlight build with *What to Test* notes; feedback pulled weekly

## References

- SwiftData: https://developer.apple.com/documentation/swiftdata
- Syncing model data across devices: https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices
- App Review Guidelines (5.1 Privacy): https://developer.apple.com/app-store/review/guidelines/#privacy
- Related: `ios/project-bootstrap`, `generators/testflight-ship`, `product/tester-loop`, `apple-intelligence/on-device-ai-kit`, `ios/healthkit`, `ios/native-services`, `ios/device-sensors`, `ios/camera-scanning`, `apple-intelligence/speech-translation`
