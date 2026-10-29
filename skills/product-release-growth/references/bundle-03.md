# Integrated Reference Bundle 03

Combines 10 related source skills from `product-release-growth` into one navigable reference file.

## Source map

- `appstore-connect-cli/SKILL.reference.md`
- `appstore-crash-insights/SKILL.reference.md`
- `appstore-id-resolver/SKILL.reference.md`
- `appstore-metadata-localizer/SKILL.reference.md`
- `appstore-metadata-sync/SKILL.reference.md`
- `appstore-notary-runner/SKILL.reference.md`
- `appstore-pricing-planner/SKILL.reference.md`
- `appstore-record-creator/SKILL.reference.md`
- `appstore-release-director/SKILL.reference.md`
- `appstore-release-notes-writer/SKILL.reference.md`

## Integrated guidance

### Source: `appstore-connect-cli`

# App Store Connect CLI

Use when running or designing generic App Store Connect `asc` commands. Hand
Apple Ads auth, org, campaign, ad-group, creative, keyword, reporting, and Ads
API work to `appstore-ads-operator`.

## Discovery

- Start with `--help`: `asc --help`, `asc builds --help`, `asc builds list --help`.
- Use deterministic command search:
  - `asc search "submit app for review"`
  - `asc search --output table "upload build"`
- Inspect bundled ASC schemas before API-facing commands:
  - `asc schema --pretty "GET /v1/apps"`
  - `asc schema --method POST appStoreVersions`
- Explain workflow coverage:
  - `asc capabilities --area release --output table`
  - `asc capabilities --status not-public-api --output markdown`

## Command Rules

- Prefer current verbs shown by help: `view` for reads, `edit` for update-only availability, and `set` only where the CLI models replacement/configuration.
- Use explicit long flags in automation.
- Destructive operations require `--confirm`.
- Use `--paginate` only when all pages are needed.
- Output defaults are TTY-aware: table interactively, JSON when piped/non-interactive.
- Use `--output table`/`markdown` for humans; `--pretty` only with JSON.

Examples:

```bash
asc apps view --id "APP_ID"
asc versions view --version-id "VERSION_ID"
asc pricing availability edit --app "APP_ID" --territory "USA,GBR" --available true
asc xcode version edit --build-number "42"
```

## Auth

Prefer `asc auth login`. Env fallback: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY_PATH`, `ASC_PRIVATE_KEY`, `ASC_PRIVATE_KEY_B64`. `ASC_APP_ID` can provide the default app. For unclear key permissions, inspect `asc web auth capabilities` or `--key-id`.

## Ownership Boundary

Keep generic CLI discovery, App Store Connect auth, schema inspection, record
operations, pagination, output formatting, raw ASC API requests, and timeout
handling here. Do not plan or execute Apple Ads campaign operations from this
skill; select `appstore-ads-operator`, which owns the separate Ads credentials,
organization context, safety gates, and campaign lifecycle.

## Timeouts

`ASC_TIMEOUT` / `ASC_TIMEOUT_SECONDS` control request timeouts. `ASC_UPLOAD_TIMEOUT` / `ASC_UPLOAD_TIMEOUT_SECONDS` control uploads.

### Source: `appstore-crash-insights`

# App Store Crash Insights

Fetch, analyze, and summarize TestFlight crash reports, beta feedback, and performance diagnostics.

## Workflow

1. Resolve app ID with `asc apps list` if missing.
2. Resolve build ID when diagnostics need one.
3. Fetch JSON with the narrowest useful command.
4. Group by severity/frequency and summarize in human terms.

## Commands

Crashes:

```bash
asc testflight crashes list --app "APP_ID" --sort -createdDate --limit 10
asc testflight crashes list --app "APP_ID" --build "BUILD_ID" --sort -createdDate --limit 10
asc testflight crashes list --app "APP_ID" --device-model "iPhone16,2" --os-version "18.0"
asc testflight crashes list --app "APP_ID" --paginate
```

Feedback:

```bash
asc testflight feedback list --app "APP_ID" --sort -createdDate --limit 10
asc testflight feedback list --app "APP_ID" --sort -createdDate --limit 10 --include-screenshots
asc testflight feedback list --app "APP_ID" --build "BUILD_ID" --sort -createdDate
asc testflight feedback list --app "APP_ID" --paginate
```

Performance diagnostics:

```bash
asc builds info --app "APP_ID" --latest --platform IOS
asc builds list --app "APP_ID" --sort -uploadedDate --limit 5
asc performance diagnostics list --build "BUILD_ID"
asc performance diagnostics list --build "BUILD_ID" --diagnostic-type "HANGS"
asc performance diagnostics view --id "SIGNATURE_ID"
asc performance download --build "BUILD_ID" --output ./metrics.json
```

Diagnostic types: `HANGS`, `DISK_WRITES`, `LAUNCHES`.

Resolve IDs with `asc apps list --name "AppName"`, `asc apps list --bundle-id "com.example.app"`, or `export ASC_APP_ID="APP_ID"`.

## Summary

Report total count, top crash signatures, affected builds, device/OS breakdown,
timeline/spikes, and highest-weight performance signatures. Output defaults are
TTY-aware: interactive terminals use tables, while pipes, files, and CI use
JSON. Pass `--output json` explicitly for automation, use table/markdown for
quick human review, `--paginate` for full analysis, and `--pretty` for JSON
debugging. ASC crash data can lag 24-48h.

### Source: `appstore-id-resolver`

# App Store ID Resolver

Use this skill to map names to IDs needed by other commands.

## App ID
- By bundle ID or name:
  - `asc apps list --bundle-id "com.example.app"`
  - `asc apps list --name "My App"`
- Fetch everything:
  - `asc apps --paginate`
- Set default:
  - `ASC_APP_ID=...`

## Build ID
- Latest build:
  - `asc builds info --app "APP_ID" --latest --version "1.2.3" --platform IOS`
- Recent builds:
  - `asc builds list --app "APP_ID" --sort -uploadedDate --limit 5`

## Version ID
- `asc versions list --app "APP_ID" --paginate`

## TestFlight IDs
- Groups:
  - `asc testflight groups list --app "APP_ID" --paginate`
- Testers:
  - `asc testflight testers list --app "APP_ID" --paginate`

## Pre-release version IDs
- `asc testflight pre-release list --app "APP_ID" --platform IOS --paginate`

## Review submission IDs
- `asc review submissions-list --app "APP_ID" --paginate`

## Output tips
- Output defaults are TTY-aware: interactive terminals use tables, while pipes,
  files, and CI use JSON.
- For automation, always pass `--output json`; use `--pretty` only when a human
  needs formatted JSON. For human viewing, use `--output table` or
  `--output markdown`.

## Guardrails
- Prefer `--paginate` on list commands to avoid missing IDs.
- Use `--sort` where available to make results deterministic.

### Source: `appstore-metadata-localizer`

# App Store Metadata Localizer

Pull source metadata, translate/adapt it, validate limits, get approval, then upload version or app-info localizations.

Use `appstore-metadata-sync` for canonical JSON field edits that are not translation-first. Use `appstore-release-notes-writer` when the requested artifact is only What's New or promotional text. Use `appstore-subscription-localizer` for subscription, group, or IAP display names.

## Local Lint Helper

After writing or editing localized `.strings` or metadata JSON, run the bundled limit checker:

```bash
python3 "$PLUGIN_ROOT/skills/appstore-metadata-localizer/scripts/metadata_localization_lint.py" \
  "./localizations" "./app-info-localizations" --recursive
```

The helper checks App Store field limits for `name`, `subtitle`, `keywords`, `description`, `whatsNew`, and `promotionalText`. It does not translate, rewrite files, upload, or call ASC. Pass `--json` for machine-readable output.

## Workflow

1. Confirm current `asc localizations` flags, then resolve app, version, and app-info IDs deterministically.
2. Download source and existing localizations; if download is unavailable, inspect with `asc localizations list`.
3. Translate one target locale at a time from the source locale. Preserve formatting and meaning; do not translate from memory.
4. Adapt keywords for native App Store search behavior instead of literal translation.
5. Run `metadata_localization_lint.py`, then show a field-by-locale summary table and wait for approval.
6. Upload only after approval, then verify with the matching `asc localizations list` command.

## Translation Rules

Use formal, professional App Store register. Keep the app name unchanged unless the user explicitly asks to translate it. For updates, download current localization, show a diff, get approval, then upload.

## References

- `references/appstore-metadata-localizer.md` for supported locales, detailed ASC commands, field scope, `.strings` format, and translation rules.

### Source: `appstore-metadata-sync`

# App Store Metadata Sync

Prefer canonical `asc metadata` JSON for app-info and version fields. Use `.strings` or fastlane flows only when specifically needed.

Use `appstore-metadata-localizer` when the main work is translation/adaptation across locales. Use `appstore-release-notes-writer` for What's New copy. Use `appstore-subscription-localizer` for subscription, group, or IAP display-name localizations.

## Command Plan Helper

For a deterministic dry-run command plan, run the helper from the plugin root:

```bash
python3 "$PLUGIN_ROOT/skills/appstore-metadata-sync/scripts/metadata_sync_plan.py" \
  --app "APP_ID" --version "1.2.3" --platform IOS --dir "./metadata" \
  --app-info "APP_INFO_ID" --version-id "VERSION_ID" \
  --include-keywords --keywords-csv "./keywords.csv"
```

The helper prints commands only; it does not call ASC, mutate metadata, or read credentials. Pass `--json` for machine-readable output. Pass `--confirming-actions` only after manually verifying generated `--confirm` commands.

## Workflow

1. Pull canonical metadata JSON into `./metadata` before editing unless the user already provided a fresh metadata tree.
2. Resolve `APP_INFO_ID` when multiple app-info records exist.
3. Edit the owning JSON fields: app-info fields for name/subtitle/privacy text and version fields for description, keywords, marketing URL, promotional text, support URL, and What's New.
4. Validate locally, then run `push --dry-run`; apply/push without dry-run only after the diff and target app/version are confirmed.
5. Use alternate `.strings` or fastlane migration flows only for legacy repos or explicit user requests.

Limits: name/subtitle 30, keywords 100, description/What's New 4000, promotional text 170. Use table output for human verification and JSON for automation.

## References

- `references/appstore-metadata-sync.md` for detailed canonical JSON, keyword, quick-edit, `.strings`, and fastlane commands.

### Source: `appstore-notary-runner`

# App Store Notary Runner

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Use for macOS apps distributed outside the App Store with Developer ID signing and Apple notarization.

Use `macos-notarization-packager` first when the artifact is not clearly distribution-ready. Use `macos-signing-inspector` for local code-signing, entitlement, Gatekeeper, or trust-policy diagnosis.

## Preconditions

- Xcode/CLT configured.
- `asc auth login` or `ASC_*`.
- Developer ID Application certificate in keychain.
- App builds for macOS.

## Command Plan Helper

For a deterministic command plan, run the helper from the plugin root:

```bash
python3 "$PLUGIN_ROOT/skills/appstore-notary-runner/scripts/notary_plan.py" \
  --app-name "YourApp" --scheme "YourMacScheme" \
  --archive-path "/tmp/YourApp.xcarchive" \
  --export-path "/tmp/YourAppExport" \
  --app-path "/tmp/YourAppExport/YourApp.app" \
  --zip-path "/tmp/YourAppExport/YourApp.zip" \
  --file "/tmp/YourAppExport/YourApp.zip" \
  --include-archive --include-export --include-zip --include-submit \
  --wait --confirming-actions
```

The helper prints commands only; it does not build, export, upload, staple, or change trust settings. Commands that write local files or submit to Apple require `--confirming-actions`. Pass `--json` for machine-readable output.

## Workflow

1. Run read-only preflight first: signing identities, trust settings, recent notarization submissions, and existing submission status/log when an ID is known.
2. If the artifact is not clearly Developer ID ready, route to `macos-notarization-packager` before exporting or submitting.
3. Archive, export with Developer ID options, verify code-signing authority/timestamp, package as zip/DMG/PKG, then submit.
4. Fetch status/log output and repair signed nested binaries, hardened runtime, timestamp, or trust issues before retrying.
5. Staple only after Apple accepts the notarization submission.

## References

- `references/appstore-notary-runner.md` for detailed preflight, archive, export, submit, status, stapling, DMG, PKG, and troubleshooting commands.

### Source: `appstore-pricing-planner`

# App Store Pricing Planner

Use current `asc` pricing families to inspect, dry-run, apply, and verify regional subscription/IAP prices.

## Preconditions

- `asc auth login` or `ASC_*`.
- App/product IDs resolved; pass `--app` or use `ASC_APP_ID`.
- Base territory chosen, usually `USA`.
- Run `asc pricing territories list --paginate` if territory IDs are unknown.

## Command Plan Helper

For a deterministic command plan, run the helper from the plugin root:

```bash
python3 "$PLUGIN_ROOT/skills/appstore-pricing-planner/scripts/pricing_plan.py" \
  --subscription-id "SUB_ID" --territory "USA" \
  --include-subscription-import --prices-csv "./ppp-prices.csv"
```

The helper prints commands only; it does not call ASC, import CSV data, or change prices. Commands that create products, apply imports, set prices, edit availability, or create schedules require `--confirming-actions`. Pass `--json` for machine-readable output.

## Workflow

1. Resolve app, subscription, IAP, territory, and price point IDs before planning mutations.
2. Inspect summaries and price lists first, especially the base territory and high-revenue localized territories.
3. For PPP or regional bulk changes, prepare CSV with required `territory` and `price`; optional fields include `currency_code`, `start_date`, `preserved`, `preserve_current_price`, and `price_point_id`.
4. Dry-run broad subscription CSV imports before applying.
5. Verify summaries after applying important price, schedule, or availability changes.
6. Expect propagation delay in App Store Connect/storefronts. Older `asc subscriptions prices ...` paths may exist, but the `pricing` family is canonical.

## References

- `references/appstore-pricing-planner.md` for detailed subscription setup, IAP setup, CSV import, manual override, availability, and schedule commands.

### Source: `appstore-record-creator`

# App Store Record Creator

Opt-in local browser automation for App Store Connect app creation. The user must be signed in; the bundle ID must already exist.

## Preconditions

- Playwright, Cursor browser MCP, or equivalent visible browser automation.
- User can complete login and 2FA.
- Inputs: app name (<=30 chars), registered unused bundle ID, SKU, platform(s), primary language, user access.

## Guardrails

- Never export/store cookies.
- Use a visible session only.
- Pause before final Create click in standalone scripts.
- Do not retry Create automatically.

## Workflow

1. Preflight:
   ```bash
   asc bundle-ids create --identifier "com.example.app" --name "My App" --platform IOS
   asc apps list --bundle-id "com.example.app" --output json
   ```
2. Open `https://appstoreconnect.apple.com/apps` and confirm login.
3. Click the blue `+` New App button, then the `New App` menu item. It is a dropdown first, not a direct dialog.
4. Fill fields:
   - Platform checkboxes: iOS, macOS, tvOS, visionOS; multiple allowed.
   - `Name`, max 30 chars.
   - `Primary Language` combobox/select.
   - `Bundle ID` select: wait until async loading finishes after platform selection; choose label like `My App - com.example.app`.
   - `SKU`.
   - `User Access`: required radio, `Limited Access` or `Full Access`.
5. User Access radios may have span overlays; scroll the radio input into view and click the radio ref directly if accessibility click is intercepted.
6. If Ember validation does not notice filled fields, clear/retype one text value slowly.
7. Confirm, click Create, wait for `/apps/<APP_ID>/...`.
8. Verify:
   ```bash
   asc apps view --id "APP_ID" --output json --pretty
   asc apps list --bundle-id "com.example.app" --output json
   ```
9. Hand off:
   ```bash
   asc app-setup info set --app "APP_ID" --primary-locale "en-US"
   asc app-setup categories set --app "APP_ID" --primary GAMES
   asc web apps availability create --app "APP_ID" --territory "USA,GBR" --available-in-new-territories true
   ```
   Use the web availability flow only for first bootstrap; later use `asc pricing availability edit`.

## Failure Handling

If a field/button cannot be located, stop, capture a screenshot, report the last step, and ask the user to inspect validation errors. Selectors can change; prefer role/label/text selectors over CSS.

### Source: `appstore-release-director`

# App Store Release Director

Broad release orchestration. For focused `asc` work, delegate to `appstore-connect-cli`, `appstore-id-resolver`, `appstore-archive-uploader`, `appstore-release-planner`, `appstore-review-readiness`, `appstore-metadata-sync`, `appstore-metadata-localizer`, `appstore-screenshot-pipeline`, and `appstore-signing-setup`.

## Workflow

1. Discover release truth:
   - git root, workspace/project, scheme, bundle ID, version/build, deployment target, entitlements, generator ownership;
   - existing handoff/docs: `apple-publishing-handoff.md`, manifest JSON, `release`, `appstore`, `testflight`, `fastlane`, `ExportOptions.plist`.
2. Verify Apple account/signing:
   - team, Team ID, API key, identities, Bundle ID resource/capabilities, distribution cert, provisioning profile;
   - keep `.p8`, `.p12`, profiles, passwords, and decoded plists out of git; prefer `.codex-private/apple/` or a secret store.
3. Prepare App Store Connect:
   - app record, platform, bundle, app info, categories, pricing/availability, age rating, privacy/support URLs, screenshots, App Privacy, review details, release option;
   - for subscriptions, verify products and Terms/EULA link. Standard EULA: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`.
4. Compliance preflight:
   - production runtime config, legal URLs return 2xx/3xx, encryption/export compliance, privacy/tracking claims match code/SDKs.
5. Build/test/archive/export/upload:
   - choose unique build number from live ASC state;
   - run required tests/smoke checks;
   - archive for `generic/platform=iOS`, export App Store IPA, validate, upload, wait for processing.
6. Link build and submit/readiness:
   - attach processed build, resolve metadata-only issues before new binaries, cancel/complete old submissions if blocking.
7. Finish evidence:
   - handoff/manifest: version/build, archive/IPA paths, SHA-256, delivery UUID, ASC build state, review submission ID, legal URLs, screenshots, remaining risks.

## References

Load only the current stage:

- `references/end-to-end-workflow.md`
- `references/signing-and-provisioning.md`
- `references/app-store-connect-api.md`
- `references/metadata-compliance.md`
- `references/build-upload-submit.md`
- `references/troubleshooting.md`

Helpers:

- `scripts/make_export_options.py`
- `scripts/appstore_preflight.py`

Run helper scripts with `python3` and inspect `--help`.

## Rules

- Operate from live repo/ASC/App Review state, not memory.
- Never commit Apple secrets/profiles unless explicitly requested and the repo is intended for them.
- Do not overwrite user changes or release docs without reading them.
- Apple requirements change; verify current screenshots, privacy, subscriptions, and review behavior.
- For legal text, draft only practical copy and state which business/legal facts need owner confirmation.
- If blocked by Apple web-only UI, permissions, legal answers, or 2FA, stop with evidence and the smallest required user action.

## Final Report

Report build/version, validation/upload status and delivery UUID, ASC build/review status, legal/privacy/screenshot/subscription/encryption state, files/artifacts changed, tests run, and anything not verified.

### Source: `appstore-release-notes-writer`

# App Store Release Notes Writer

Write human-focused release notes, optionally localized to every existing metadata locale.

Use `appstore-metadata-sync` for general listing metadata edits, `appstore-metadata-localizer` for full listing translation, and `appstore-subscription-localizer` for subscription/IAP display-name localization.

## Preconditions

- Canonical metadata from `asc metadata pull --app "APP_ID" --version "1.2.3" --dir "./metadata"` or user-provided keywords.
- Auth configured for upload.
- Primary locale is `en-US` unless specified.
- Read `references/release_notes_guidelines.md`.
- Use highest semver under `metadata/version/`; locales are the JSON files there.

## Workflow

1. Gather input:
   - Git log: `git describe --tags --abbrev=0` then `git log <tag>..HEAD --oneline --no-merges`; remove merges/deps/CI/format noise.
   - User bullets or free text.
   - If absent, ask what changed.
2. Classify user-visible changes into `New`, `Improved`, `Fixed`; omit empty sections.
3. Draft primary locale notes:
   - lead with the clearest user-facing hook in the first ~170 chars;
   - describe user impact, not implementation;
   - use concrete action verbs;
   - naturally echo relevant local keywords from `metadata/version/<version>/<locale>.json` when present;
   - target 500-1500 chars, hard limit 4000.
4. If requested, draft `promotionalText` <= 170 chars.
5. Show draft with character count and wait for approval before localizing.
6. Localize approved notes:
   - formal/professional register and formal "you" where applicable;
   - adapt idioms and tone to local market;
   - echo locale-specific keywords naturally;
   - validate What's New <= 4000 and promo <= 170; shorten, never truncate mid-sentence.
7. Present a locale table with first 80 chars, counts, promo text/counts; wait for upload approval.
8. Upload:
   ```bash
   asc apps info edit --app "APP_ID" --version-id "VERSION_ID" --locale "en-US" --whats-new "..."
   asc metadata push --app "APP_ID" --version "1.2.3" --dir "./metadata" --dry-run
   asc metadata push --app "APP_ID" --version "1.2.3" --dir "./metadata"
   ```
   Include promo via `--promotional-text` or write `promotionalText` into canonical JSON before push.

## Paths

- Keywords/current notes: `metadata/version/{latest-version}/{locale}.json`
- Fields: `keywords`, `whatsNew`, optional `promotionalText`
- Canonical tree is shared with `asc metadata pull/push/keywords`.

## Rules

- What's New is not App Store search-indexed; write for conversion and clarity.
- Promotional text can update without a new submission.
- The visible 170-char preview matters most.
- On partial upload failure, report successes/failures and retry failed locales only.
- Use `appstore-metadata-localizer` for full listing translation and `appstore-aso-auditor` for keyword research.
