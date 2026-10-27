---
name: testflight-ship
description: Generates scripts/ship.sh — one command to put a build on a phone. `ship.sh device` installs on your own iPhone (free Apple ID works, 7-day expiry); `ship.sh testflight` archives and uploads to TestFlight with an App Store Connect API key, no Xcode GUI, no fastlane, no CI. Use when the user wants to get the app onto their phone or testers' phones quickly, set up TestFlight uploads from the terminal, or asks "how do I ship a beta".
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27 / Xcode 27
---

# TestFlight Ship (local, one command)

For small teams, a CI pipeline is overhead. Xcode 27's `xcodebuild` can archive,
sign, **and upload** with an App Store Connect API key in two commands. This skill
drops a tested script into the repo that does exactly that.

Bigger setups (GitHub Actions, Xcode Cloud, fastlane lanes) → `generators/ci-cd-setup`.
Tester strategy and recruiting → `product/beta-testing`. Managing testers and
pulling feedback once builds are live → `product/tester-loop`.

## When This Skill Activates

- "Put this on my phone", "send to TestFlight", "ship a beta", "upload a build"
- User has no paid account and wants to try the app on their own iPhone
- Step 4 of `product/local-first-app`

## Pick the Path

| | **Path A — own phone** | **Path B — TestFlight** |
|---|---|---|
| Account | Free Apple ID (Personal Team) or paid | Apple Developer Program ($99/yr) |
| Who can run it | Devices physically plugged into your Mac | Up to 100 internal + 10,000 external testers |
| Expiry | **7 days** (free) / 1 year (paid dev profile) | 90 days per build |
| Review | None | Internal: none. External: one-time Beta App Review per version |
| Command | `scripts/ship.sh device` | `scripts/ship.sh testflight` |
| Testers need | To hand you their phone | The TestFlight app + an invite email or public link |

Free Personal Team limits worth knowing up front: profiles expire after 7 days
(reinstall to refresh), a small cap on apps per week, and some capabilities are
paid-only. HealthKit works on a free account. If Xcode reports *"Personal
development teams … do not support the X capability"*, that capability needs the
paid program — check Apple's capability table (References) before planning around it.

## Process

### 1. Install the script

```bash
mkdir -p scripts && cp <skill>/templates/ship.sh scripts/ship.sh && chmod +x scripts/ship.sh
grep -q '^.env.ship$' .gitignore || echo '.env.ship' >> .gitignore
```

### 2. Configure `.env.ship` (git-ignored)

```bash
SCHEME=MyApp
TEAM_ID=ABCDE12345
# Path B only:
ASC_KEY_ID=XXXXXXXXXX
ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ASC_KEY_PATH=$HOME/.appstoreconnect/private_keys/AuthKey_XXXXXXXXXX.p8
# INTERNAL_ONLY=1   # build can never go to external testers / App Store
```

API key: App Store Connect → Users and Access → Integrations → **Team Keys** → `+`,
role **App Manager**. Download the `.p8` once (Apple won't show it again) into
`~/.appstoreconnect/private_keys/` — never into the repo.

### 3. Path A — your own phone

One-time on the phone: Settings → Privacy & Security → **Developer Mode** → on →
restart. Plug in, unlock, tap **Trust**.

```bash
scripts/ship.sh check     # validates config, touches nothing
scripts/ship.sh device    # xcodegen (if project.yml) → build → install → launch
```

First launch on a free account is blocked until you trust the profile:
Settings → General → VPN & Device Management → your Apple ID → Trust.
The script prints this hint if launch fails.

### 4. Path B — TestFlight

One-time in App Store Connect: **Apps → + → New App** with the same bundle ID
(the API can't create app records). Then:

```bash
scripts/ship.sh testflight
```

What it does — verified against `xcodebuild -help` on Xcode 27.0:

1. `xcodegen generate` if `project.yml` exists
2. `xcodebuild archive` with `CURRENT_PROJECT_VERSION=<UTC yyyymmddHHMM>` — unique, increasing, no commit noise
3. Writes `ExportOptions.plist`: `method=app-store-connect`, `destination=upload`,
   `manageAppVersionAndBuildNumber=false` (we already set it), `testFlightInternalTestingOnly` from `INTERNAL_ONLY`
4. `xcodebuild -exportArchive … -authenticationKeyPath/-ID/-IssuerID` — **exports and uploads in one step**

Processing takes ~5–15 minutes. Internal testers (App Store Connect users added to
an internal group) get it automatically; external groups need the first build of
each version to pass Beta App Review (usually < 24h).

✅ `ITSAppUsesNonExemptEncryption: false` in Info.plist (`ios/project-bootstrap` sets it) — no
export-compliance prompt blocking every build.
❌ `method=app-store` / `ad-hoc` / `development` — deprecated spellings in Xcode 27; use
`app-store-connect` / `release-testing` / `debugging`.
❌ `xcrun altool --upload-app` as the primary path — `-exportArchive` with `destination=upload`
does sign + upload with the same API key and no extra tool.

## Gotchas

- **"No account for team"** → the API key flags must be on *both* `archive` and `-exportArchive` (script does this) so Xcode can mint a distribution certificate without a logged-in Xcode account.
- **"Bundle version must be higher"** → two uploads in the same minute. Wait a minute, rerun.
- **Upload succeeded, build never appears** → check the email for "ITMS-" errors (missing usage string, invalid icon). An app icon is required for TestFlight — `generators/app-icon-generator`.
- **`devicectl` table format changed in Xcode 27** (names with spaces, simulators listed, `Reality` column). The script parses `--json-output` and picks `reality == physical`, `platform == iOS`.
- **Expired free builds** just stop launching. Re-run `ship.sh device`.

## Checklist

- [ ] `.env.ship` git-ignored; `.p8` outside the repo
- [ ] `scripts/ship.sh check` passes
- [ ] App record exists in App Store Connect (Path B)
- [ ] App icon present, usage strings present for every permission requested
- [ ] Internal group created with yourself in it; first build installs from the TestFlight app
- [ ] `What to Test` notes filled in for testers (App Store Connect → TestFlight → build)

## References

- Upload builds: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds
- Creating API keys: https://developer.apple.com/documentation/appstoreconnectapi/creating-api-keys-for-app-store-connect-api
- Supported capabilities by membership: https://developer.apple.com/help/account/reference/supported-capabilities-ios
- TestFlight overview: https://developer.apple.com/testflight/
- `xcodebuild -help` → "Available keys for -exportOptionsPlist"
- Related: `ios/run-device`, `ios/project-bootstrap`, `product/tester-loop`, `product/beta-testing`, `generators/ci-cd-setup`
