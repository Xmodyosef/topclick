# Integrated Reference Bundle 04

Combines 11 related source skills from `product-release-growth` into one navigable reference file.

## Source map

- `appstore-release-planner/SKILL.reference.md`
- `appstore-revenuecat-sync/SKILL.reference.md`
- `appstore-review-readiness/SKILL.reference.md`
- `appstore-screenshot-pipeline/SKILL.reference.md`
- `appstore-screenshot-studio/SKILL.reference.md`
- `appstore-screenshot-validator/SKILL.reference.md`
- `appstore-signing-setup/SKILL.reference.md`
- `appstore-subscription-localizer/SKILL.reference.md`
- `appstore-testflight-coordinator/SKILL.reference.md`
- `appstore-wall-publisher/SKILL.reference.md`
- `appstore-workflow-runner/SKILL.reference.md`

## Integrated guidance

### Source: `appstore-release-planner`

# App Store Release Planner

Use this as the decision front door for App Store release readiness. Do not duplicate the execution workflow here; after the decision, read the focused skill that owns the next action.

## Routing

- Use `appstore-release-director` when the user wants an end-to-end release from local repo through upload, TestFlight, review, and evidence.
- Use `appstore-review-readiness` for concrete validation, staging/submission, status monitoring, cancellation, and blocker repair commands.
- Use `appstore-archive-uploader` when the next unresolved step is version/build numbering, archive, export, upload, or processed build selection.
- Use `appstore-metadata-sync`, `appstore-screenshot-validator`, `appstore-signing-setup`, `appstore-pricing-planner`, `appstore-subscription-localizer`, or `appstore-testflight-coordinator` when the blocker is clearly in that narrower surface.

## Answer Order

1. Ready now or not.
2. Blocking issues.
3. Public API fixes vs experimental web-session/manual fixes.
4. Next exact command.

Resolve `APP_ID`, version, `VERSION_ID`, and `BUILD_ID`; ensure `asc auth login` or `ASC_*`; use canonical `./metadata` when staging.

## Decision Path

1. Establish release target: app, platform, version, build, submission state, and whether this is a first submission.
2. Check whether the next missing evidence belongs to metadata, screenshots, signing, pricing/availability, subscriptions/IAP, App Privacy, review details, Game Center, build processing, or review status.
3. If the version looks action-ready or needs command proof, switch to `appstore-review-readiness` and follow its current `asc` command workflow.
4. If the user only needs an executive answer, report ready/not-ready, blockers, public-API fixes versus experimental web-session/manual fixes, and the next focused skill/command owner.

## First-Submission Blockers

- Availability missing: public edit commands may work after initial availability exists; bootstrap can require an experimental web-session or manual ASC action.
- Subscriptions ready but not attached to first review: later reviews can use public subscription review paths; first review attachment can require an experimental web-session or manual ASC action.
- IAP review readiness: public IAP validation/submission paths cover most cases; selecting IAPs with the first app version can require an experimental web-session or manual ASC action.
- Game Center: create app-version records and add component versions through explicit review submission items before submit.
- App Privacy: public API cannot fully prove publish state; use `asc web privacy pull/plan/apply/publish` or manual App Store Connect confirmation.
- Review details: only set demo account fields when review truly needs them.

Call out all `asc web ...` commands as experimental web-session escape hatches.

## Ready Checklist

Ready means validation has no blockers; stage/submit dry-run is correct; build is `VALID` and attached; metadata, screenshots, app info, content rights, encryption, age rating, and review details are complete; availability exists; digital goods and Game Center review items are handled; App Privacy is confirmed/published.

## Guardrails

- Do not use legacy submit-preflight, submit-create, or release-run shortcuts.
- Do not claim ready without concrete validation evidence or a clear manual-confirmation boundary.
- Do not submit, cancel, or mutate review state from this planner; hand off to `appstore-review-readiness`.

### Source: `appstore-revenuecat-sync`

# App Store RevenueCat Sync

Start read-only, build a diff, then create/update only after explicit confirmation. Never delete resources in this workflow.

## Preconditions

- `asc` auth configured.
- RevenueCat MCP configured/authenticated; write-enabled API v2 key for apply.
- Known `APP_ID`, RevenueCat `project_id`, target app type (`app_store` or `mac_app_store`), and bundle ID for create flows.

Canonical key: ASC `productId` == RevenueCat `store_identifier`. Never use display names as unique IDs.

## Modes

- Audit: read ASC + RevenueCat, find missing resources and conflicts, present plan.
- Apply: after approval, ensure ASC items, RevenueCat app/products, entitlements/attachments, offerings/packages, then verify.

## Read Sources

```bash
asc subscriptions groups list --app "APP_ID" --paginate --output json
asc iap list --app "APP_ID" --paginate --output json
asc subscriptions list --group-id "GROUP_ID" --paginate --output json
```

RevenueCat MCP tools: `mcp_RC_get_project`, `mcp_RC_list_apps`, `mcp_RC_list_products`, `mcp_RC_list_entitlements`, `mcp_RC_list_offerings`, `mcp_RC_list_packages` with pagination.

Type mapping:

- subscription -> `subscription`
- `CONSUMABLE` -> `consumable`
- `NON_CONSUMABLE` -> `non_consumable`
- `NON_RENEWING_SUBSCRIPTION` -> `non_renewing_subscription`

Entitlement defaults: one per subscription group, one per non-consumable, none for consumables unless requested.

## Apply Order

1. Create missing ASC resources, then re-read ASC to get canonical IDs:
   ```bash
   asc subscriptions groups create --app "APP_ID" --reference-name "Premium"
   asc subscriptions create --group-id "GROUP_ID" --reference-name "Monthly" --product-id "com.example.premium.monthly" --subscription-period ONE_MONTH
   asc iap create --app "APP_ID" --type NON_CONSUMABLE --ref-name "Lifetime" --product-id "com.example.lifetime"
   ```
2. Ensure RevenueCat app/products with `mcp_RC_create_app` and `mcp_RC_create_product`; set `store_identifier` to ASC `productId`.
3. Ensure entitlements and product attachments with `mcp_RC_create_entitlement`, `mcp_RC_attach_products_to_entitlement`, and verify with `mcp_RC_get_products_from_entitlement`.
4. Optional offerings/packages: `mcp_RC_create_offering`, `mcp_RC_update_offering`, `mcp_RC_create_package`, `mcp_RC_attach_products_to_package` using `eligibility_criteria: "all"`.

Recommended package keys: weekly `$rc_weekly`, monthly `$rc_monthly`, two-month `$rc_two_month`, three-month `$rc_three_month`, six-month `$rc_six_month`, annual `$rc_annual`, lifetime `$rc_lifetime`, custom `$rc_custom_<name>`.

## Agent Rules

- Always audit first, even when the user asks to apply.
- Ask before create/update operations.
- Match by `store_identifier` first.
- Use full pagination (`--paginate`, `starting_after`).
- Continue after per-item failures and report all together.
- RevenueCat MCP does not create ASC products; use `asc` for ASC resources first.
- Watch for wrong RevenueCat project/app, wrong platform app, consumables attached to entitlements, skipped ASC re-read, and unverified package/offering attachments.

## Output

Summarize ASC created/skipped/failed counts, RevenueCat created/skipped/failed counts, attachment counts, and actionable failures.

References: `examples.md`, `references.md`.

### Source: `appstore-review-readiness`

# App Store Review Readiness

Use `asc validate` and current review commands. Do not use legacy submit-preflight or submit-create shortcuts.

For go/no-go planning, first-submission strategy, or choosing which release skill owns a blocker, use `appstore-release-planner` first. This skill owns command execution once the review-readiness path is selected.

Preconditions: auth configured; app/version/build IDs resolved; build processing complete unless using `--wait`; metadata, app info, screenshots, review details, content rights, encryption, pricing, availability, and App Privacy expected complete.

## Command Plan Helper

For a deterministic dry-run command plan, run the helper from the plugin root:

```bash
python3 "$PLUGIN_ROOT/skills/appstore-review-readiness/scripts/review_readiness_plan.py" \
  --app "APP_ID" --version "1.2.3" --platform IOS --build "BUILD_ID" \
  --version-id "VERSION_ID" --submission-id "SUBMISSION_ID" \
  --metadata-dir "./metadata" --include-submit
```

The helper prints commands only; it does not call ASC, mutate review state, or read credentials. Pass `--json` for machine-readable output. Pass `--confirming-actions` only after manually verifying that generated `--confirm` commands are intended.

## Workflow

1. Generate the helper plan unless the user requested one specific command.
2. Run read-only readiness checks first: processed build state, normal validate, strict validate, and version-id validate when available.
3. Repair blockers in the smallest owning surface: encryption, content rights, metadata, screenshots, IAP/subscriptions, or App Privacy.
4. Submit only after dry-run output is clean and the user has clearly selected the build/version to send.
5. Monitor by app, version ID, or submission ID; cancel only when the active submission is identified and the user intends cancellation.

For macOS App Store review, use the same flow with `--platform MAC_OS`.

## References

- `references/appstore-review-readiness.md` for detailed ASC repair, submit, multi-item submission, monitor, and retry commands.

### Source: `appstore-screenshot-pipeline`

# App Store Screenshot Pipeline

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Build/run the app, capture deterministic screenshots, frame them, review them, then upload through `asc`.

Defaults: settings `.asc/screenshot.settings.json`, plan `.asc/screenshots.json`, raw `./screenshots/raw`, framed `./screenshots/framed`, frame device `iphone-air`, Koubou `0.18.1`.

## Workflow

1. Verify the current CLI surface with `asc screenshots --help`, subcommand help, and `axe --version`. If `axe` is missing, install it with `brew install cameroncooke/axe/axe` or run `./scripts/install-deps.sh --profile screenshots`.
2. Create/update settings with bundle id, project/scheme, UDID, paths, `frame_enabled`, `upload_enabled`, and upload target.
3. Build/install/launch:

   ```bash
   xcrun simctl boot "$UDID" || true
   xcodebuild -project "App.xcodeproj" -scheme "App" -configuration Debug \
     -destination "platform=iOS Simulator,id=$UDID" -derivedDataPath ".build/DerivedData" build
   xcrun simctl install "$UDID" ".build/DerivedData/Build/Products/Debug-iphonesimulator/App.app"
   xcrun simctl launch "$UDID" "com.example.app"
   ```

   Use `xcodebuild -showBuildSettings` if the bundle path differs.

4. Capture with plan:

   ```bash
   asc screenshots run --plan ".asc/screenshots.json" --udid "$UDID" --output json
   ```

   During plan authoring use AXe primitives: `axe describe-ui`, `axe tap`, `axe type`, `axe screenshot`.

5. Frame with pinned Koubou:

   ```bash
   pip install koubou==0.18.1
   kou --version
   asc screenshots list-frame-devices --output json
   asc screenshots frame --input "./screenshots/raw/home.png" --output-dir "./screenshots/framed" --device "iphone-air" --output json
   ```

   If frames are missing, run `kou setup-frames` once with network access.

6. Review:

   ```bash
   asc screenshots review-generate --framed-dir "./screenshots/framed" --output-dir "./screenshots/review"
   asc screenshots review-open --output-dir "./screenshots/review"
   asc screenshots review-approve --all-ready --output-dir "./screenshots/review"
   ```

7. Prefer plan/apply for reviewed batches so existing remote screenshots are considered:

   ```bash
   asc screenshots plan --app "APP_ID" --version "1.2.3" --review-output-dir "./screenshots/review" --output json
   asc screenshots apply --app "APP_ID" --version "1.2.3" --review-output-dir "./screenshots/review" --confirm --output json
   ```

   Direct upload:

   ```bash
   asc screenshots upload --version-localization "LOC_ID" --path "./screenshots/framed" --device-type "IPHONE_69" --output json
   ```

## Locale Capture

Do not rely on `xcrun simctl launch ... -e AppleLanguages`; it does not reliably switch app language. Prefer one simulator UDID per locale, set simulator-wide defaults, then capture:

```bash
set_simulator_locale() {
  UDID="$1"; LOCALE="$2"; LANG="${LOCALE%%-*}"; APPLE_LOCALE="${LOCALE/-/_}"
  xcrun simctl boot "$UDID" || true
  xcrun simctl spawn "$UDID" defaults write NSGlobalDomain AppleLanguages -array "$LANG"
  xcrun simctl spawn "$UDID" defaults write NSGlobalDomain AppleLocale -string "$APPLE_LOCALE"
}

set_simulator_locale "$UDID" "de-DE"
xcrun simctl terminate "$UDID" "com.example.app" || true
asc screenshots capture --bundle-id "com.example.app" --name "home" --udid "$UDID" --output-dir "./screenshots/raw/de-DE" --output json
```

For manual launches: `xcrun simctl launch "$UDID" "com.example.app" -AppleLanguages "(de)" -AppleLocale "de_DE"`. Parallelize locales with distinct UDIDs and frame/review after `wait`.

## Rules

Use explicit long flags and JSON for machine steps. Ensure files exist before upload. Treat local screenshot automation as experimental in user-facing notes. Use plan/apply for append-limit guardrails. If framing checks fail, reinstall `koubou==0.18.1`. Validate with `asc screenshots sizes --output table` and `asc screenshots list --version-localization "LOC_ID" --output table`.

### Source: `appstore-screenshot-studio`

# App Store Screenshot Studio

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Build App Store screenshots from product reality: inspect the app, choose install promises, write concise panel copy, assemble visuals, crop panels, and prepare App Store Connect assets.

Pair simulator capture/upload work with `appstore-screenshot-pipeline`, `appstore-screenshot-validator`, and `appstore-review-readiness`.

## Workflow

1. Resolve context: repo, README, onboarding, paywall, root screens, existing screenshots/listings, and brand rules. If given an App Store URL, run `scripts/scrape.mjs` and save JSON under `.appstore-screenshots/scraped/`. Ask only for missing facts that change direction: app name, devices, locales, panel count.
2. Initialize:

   ```bash
   node <skill-dir>/scripts/scaffold.mjs --output-dir .appstore-screenshots
   ```

   Work from `.appstore-screenshots/config.json`; keep composites in `.appstore-screenshots/composites/` and final panels in `.appstore-screenshots/panels/`.

3. Plan 3-5 install-focused benefits. Put the clearest value in panel 1. Keep captions readable in search results, concrete, truthful, localizable, and useful as standalone panels.
4. Generate or assemble visuals. Use real app screenshots when accuracy matters; use image generation only for marketing composites. Keep important text/device edges crop-safe. Do not fake store badges, download buttons, nonexistent features, or misleading UI.
5. Crop:

   ```bash
   node <skill-dir>/scripts/crop.mjs \
     --input .appstore-screenshots/composites/iphone-en.png \
     --device iphone \
     --output-dir .appstore-screenshots/panels/iphone/en
   ```

6. Validate dimensions, file count, and small thumbnails. For ASC upload, use `appstore-screenshot-pipeline` or `asc screenshots validate/upload` after IDs/localizations are known.

## Workspace

- `.appstore-screenshots/config.json`: app, App Store URL, devices, locales, panel count, colors, benefits.
- `.appstore-screenshots/manifest.json`: generated/cropped inventory.
- `.appstore-screenshots/scraped/`: optional public App Store metadata.
- `.appstore-screenshots/composites/`: source composites.
- `.appstore-screenshots/panels/`: upload-ready panels.

## Presets

| Device | Composite | Panel | Key |
| --- | --- | --- | --- |
| iPhone | `3456x2400` | `1290x2796` | `iphone` |
| iPad | `6144x2732` | `2048x2732` | `ipad` |

The crop helper treats a composite as three horizontal panels. For other layouts, crop manually with `sharp`, `sips`, or the app's asset pipeline.

## Quality Bar

Use real product language, high-contrast short headlines, truthful UI, meaning-based localization, and repeated crop/size validation. Do not upload until the user approves final panels or explicitly asks for automated upload.

### Source: `appstore-screenshot-validator`

# App Store Screenshot Validator

Before invoking Apple-only binaries, confirm the execution context is macOS. From Windows or Linux, run those steps in a Mac SSH project or through an already configured remote transport; do not retry missing Apple binaries locally.

Prepare screenshots for App Store Connect. Do not hard-code Apple size tables here; `asc screenshots sizes` is the source of truth.

## Source Of Truth

```bash
asc screenshots sizes --output table
asc screenshots sizes --all --output table
```

For apps that run on each device family, the current required anchors are the
iPhone 6.9-inch slot (`IPHONE_69`) and iPad 13-inch slot
(`IPAD_PRO_3GEN_129`). Apple accepts the iPhone 6.5-inch slot when 6.9-inch
screenshots are not provided. Use `--all` for every accepted iPhone size, Apple
TV, Mac, Vision Pro, iMessage, or Watch slot.

## Local Audit Helper

After choosing target dimensions from ASC, inspect local screenshots with the bundled helper:

```bash
python3 "$PLUGIN_ROOT/skills/appstore-screenshot-validator/scripts/screenshot_audit.py" \
  "./screenshots/iphone" --recursive --allow-size 1290x2796 --allow-rotated --fail-on-alpha
```

The helper reads PNG/JPEG headers only. It does not resize, rewrite, strip alpha, upload, or call ASC. Pass `--json` for machine-readable output.

## Workflow

1. Query current screenshot size requirements with `asc screenshots sizes --all`.
2. Run `screenshot_audit.py` against candidate PNG/JPEG files; fail on alpha and hidden Unicode filename spaces before upload.
3. Preserve originals. Write sanitized, alpha-stripped, resized, or color-converted images to a separate directory.
4. Use `sips` for macOS image rewrites only after selecting an ASC target size; `sips -z` takes height then width.
5. Run `asc screenshots validate` on the final directory, then `asc screenshots upload --dry-run`, then upload only after the dry-run is clean.

## Guardrails

Preserve originals by writing to a separate directory. Do not stretch across incompatible aspect ratios unless the user accepts the visual tradeoff. Prefer `asc screenshots validate` over visual inspection before upload.

## References

- `references/appstore-screenshot-validator.md` for detailed `asc`, `sips`, filename cleanup, validate, and upload commands.

### Source: `appstore-signing-setup`

# App Store Signing Setup

Use for new signing assets, rotation, or team sharing.

## Preconditions

Auth is configured (`asc auth login` or `ASC_*` env vars), bundle id/platform are known, and certificate creation has a CSR or will use `--generate-csr`.

## Workflow

1. Bundle ID:
   - `asc bundle-ids list --paginate`
   - `asc bundle-ids create --identifier "com.example.app" --name "Example" --platform IOS`
2. Capabilities:
   - `asc bundle-ids capabilities list --bundle "BUNDLE_ID"`
   - `asc bundle-ids capabilities add --bundle "BUNDLE_ID" --capability ICLOUD`
   - use `--settings '[{"key":"ICLOUD_VERSION","options":[{"key":"XCODE_13","enabled":true}]}]'` when required
3. Certificate:
   - `asc certificates list --certificate-type IOS_DISTRIBUTION`
   - `asc certificates create --certificate-type IOS_DISTRIBUTION --csr "./cert.csr"`
   - `asc certificates create --certificate-type IOS_DISTRIBUTION --generate-csr --key-out "./signing/dist.key" --csr-out "./signing/dist.csr"`
4. Profile:
   - `asc profiles create --name "AppStore Profile" --profile-type IOS_APP_STORE --bundle "BUNDLE_ID" --certificate "CERT_ID"`
   - development/ad-hoc also pass `--device "DEVICE_ID"`
5. Download, inspect, install:
   - `asc profiles download --id "PROFILE_ID" --output "./profiles/AppStore.mobileprovision"`
   - `asc profiles inspect --path "./profiles/AppStore.mobileprovision" --output table`
   - `asc profiles inspect --path "./profiles/AppStore.mobileprovision" --entitlements --output markdown`
   - `asc profiles local install --path "./profiles/AppStore.mobileprovision"`
   - `asc profiles local list --output table`

## Rotation

- `asc certificates revoke --id "CERT_ID" --confirm`
- `asc profiles delete --id "PROFILE_ID" --confirm`
- `asc profiles local clean --expired --dry-run`
- `asc profiles local clean --expired --confirm`

## Encrypted Sync

Use `asc signing sync` as a lightweight match-style encrypted git store.

```bash
asc signing sync push \
  --bundle-id "com.example.app" \
  --profile-type IOS_APP_STORE \
  --repo "git@github.com:team/certs.git" \
  --password "$MATCH_PASSWORD"

asc signing sync pull \
  --repo "git@github.com:team/certs.git" \
  --password "$MATCH_PASSWORD" \
  --output-dir "./signing"
```

`--password` falls back to `ASC_MATCH_PASSWORD`. Pull writes files only; keychain import/profile install is separate.

## Notes

Check `--help` for enum values. Use `--paginate` for large accounts. `--certificate` accepts comma-separated IDs. Device management uses `asc devices` with UDID. Local profile commands operate on disk, not ASC API resources.

### Source: `appstore-subscription-localizer`

# App Store Subscription Localizer

Use for subscription/IAP display names and descriptions, not general App Store metadata (`appstore-metadata-localizer` owns that).

Use `appstore-pricing-planner` for price points, availability, or schedules. Use `appstore-revenuecat-sync` when the work also maps ASC products to RevenueCat offerings or entitlements.

## Preconditions

- `asc auth login` or `ASC_*` env vars.
- `APP_ID`, group/subscription/IAP IDs resolved.
- Products already exist.

## Command Plan Helper

For a deterministic command plan, run the helper from the plugin root:

```bash
python3 "$PLUGIN_ROOT/skills/appstore-subscription-localizer/scripts/subscription_localization_plan.py" \
  --app "APP_ID" --group-id "GROUP_ID" --subscription-id "SUB_ID" --iap-id "IAP_ID" \
  --locale "en-US,fr-FR" --name "Display Name"
```

The helper prints commands only; it does not call ASC or change localizations. Create/update commands require `--confirming-actions`. Pass `--json` for machine-readable output.

## Workflow

1. Resolve `APP_ID`, group IDs, subscription IDs, IAP IDs, and existing localization IDs before mutation.
2. List existing localizations before creating anything; duplicate locale creates fail.
3. Skip locales that already exist unless the user asked to update.
4. If the user gives one display name, use it for all locales; if they provide per-locale names, honor them.
5. Pass `--description` only when supplied, usually for IAP localizations.
6. Process many products sequentially by group for readable output, record per-locale failures, and verify with the matching list command after the batch.

## References

- `references/appstore-subscription-localizer.md` for supported locales and detailed resolve, list, create, update, and batch rules.

### Source: `appstore-testflight-coordinator`

# App Store TestFlight Coordinator

Use this skill when managing TestFlight testers, groups, and build distribution.

## Export current config
- `asc testflight config export --app "APP_ID" --output "./testflight.yaml"`
- Include builds/testers:
  - `asc testflight config export --app "APP_ID" --output "./testflight.yaml" --include-builds --include-testers`

## Manage groups and testers
- Groups:
  - `asc testflight groups list --app "APP_ID" --paginate`
  - `asc testflight groups create --app "APP_ID" --name "Beta Testers"`
- Testers:
  - `asc testflight testers list --app "APP_ID" --paginate`
  - `asc testflight testers add --app "APP_ID" --email "tester@example.com" --group "Beta Testers"`
  - `asc testflight testers invite --app "APP_ID" --email "tester@example.com"`

## Distribute builds
- `asc builds add-groups --build-id "BUILD_ID" --group "GROUP_ID"`
- Remove from group:
  - `asc builds remove-groups --build-id "BUILD_ID" --group "GROUP_ID" --confirm`

## What to Test notes
- `asc builds test-notes create --build-id "BUILD_ID" --locale "en-US" --whats-new "Test instructions"`
- `asc builds test-notes update --localization-id "LOCALIZATION_ID" --whats-new "Updated notes"`

## Notes
- Use `--paginate` on large groups/tester lists.
- Prefer IDs for deterministic operations; use the ID resolver skill when needed.

### Source: `appstore-wall-publisher`

# App Store Wall Publisher

Use this skill to add or update a Wall of Apps entry with the built-in CLI flow.

## When to use

- User wants to submit an app to the Wall of Apps
- User wants to update an existing Wall of Apps entry
- User asks for the exact Wall submission flow

## Required inputs

Use one of these input paths:

- Standard App Store flow: `app` ID
- Manual/pre-release flow: `link` plus `name`

## Submission workflow

1. Run commands from the `App-Store-Connect-CLI` repository root.
2. Preview first:
   - `asc apps wall submit --app "1234567890" --dry-run`
   - or `asc apps wall submit --link "https://testflight.apple.com/join/ABCDEFG" --name "My Beta App" --dry-run`
3. Apply with confirmation:
   - `asc apps wall submit --app "1234567890" --confirm`
   - or `asc apps wall submit --link "https://testflight.apple.com/join/ABCDEFG" --name "My Beta App" --confirm`
4. Review the generated PR plan and resulting change to `docs/wall-of-apps.json`.

## Guardrails

- Do not modify unrelated entries in `docs/wall-of-apps.json`.
- If submission fails due to invalid input, fix the inputs and rerun the CLI command.
- Keep submission path PR-based unless maintainers define an issue-based intake flow.

## Examples

Add new app:

`asc apps wall submit --app "1234567890" --confirm`

Submit a non-App-Store/TestFlight entry:

`asc apps wall submit --link "https://testflight.apple.com/join/ABCDEFG" --name "My Beta App" --confirm`

### Source: `appstore-workflow-runner`

# App Store Workflow Runner

Use `asc workflow` for lane-style repo-local automation. Workflows run trusted shell commands, stream step output to stderr, and keep stdout machine-readable JSON.

## Commands

Verify flags first:

```bash
asc workflow --help
asc workflow validate --help
asc workflow list --help
asc workflow run --help
```

Run flow:

```bash
asc workflow validate
asc workflow list
asc workflow list --all
asc workflow run --dry-run beta BUILD_ID:123 GROUP_ID:abc
asc workflow run beta BUILD_ID:123 GROUP_ID:abc
asc workflow run release --resume "release-20260312T120000Z-deadbeef"
```

Do not pass new `KEY:VALUE` params with `--resume`; saved workflow, params, and outputs are reused.

## File Contract

- Default: `.asc/workflow.json`; override with `--file`.
- JSONC comments supported.
- Top-level hooks: `before_all`, `after_all`, `error`.
- Workflow keys: `description`, `private`, `env`, `steps`.
- Step forms: string shorthand, `run`, `workflow`, `name`, `if`, `with`, `outputs`.
- Runtime params accept `KEY:VALUE` and `KEY=VALUE`; repeated keys are last-write-wins.
- Env precedence: `definition.env < workflow.env < CLI params`; for sub-workflows: `sub env < caller env/params < step with`.
- Conditional truthy values: `1`, `true`, `yes`, `y`, `on`.

Outputs:

- `run` steps that declare `outputs` must emit JSON stdout, have unique reference-safe `name`, and should call `asc ... --output json`.
- Reference as `${steps.step_name.OUTPUT_NAME}`.
- Do not map secrets into persisted outputs.

## Minimal Example

```json
{
  "env": { "APP_ID": "123", "VERSION": "1.0.0", "GROUP_ID": "" },
  "before_all": "asc auth status",
  "workflows": {
    "beta": {
      "description": "Resolve latest build and distribute to TestFlight",
      "steps": [
        {
          "name": "resolve_build",
          "run": "asc builds info --app $APP_ID --latest --platform IOS --output json",
          "outputs": { "BUILD_ID": "$.data.id" }
        },
        { "name": "groups", "run": "asc testflight groups list --app $APP_ID --limit 20 --output json" },
        { "name": "add", "if": "GROUP_ID", "run": "asc builds add-groups --build-id ${steps.resolve_build.BUILD_ID} --group $GROUP_ID" }
      ]
    },
    "release": {
      "steps": [
        { "name": "validate", "run": "asc validate --app $APP_ID --version $VERSION --platform IOS --output json" },
        { "name": "stage", "run": "asc release stage --app $APP_ID --version $VERSION --build $BUILD_ID --metadata-dir ./metadata/version/$VERSION --confirm --output json" },
        { "name": "submit", "if": "SUBMIT_FOR_REVIEW", "run": "asc review submit --app $APP_ID --version $VERSION --build $BUILD_ID --confirm --output json" }
      ]
    }
  }
}
```

## Agent Rules

- Keep workflows repo-local and reviewed; do not put secrets in workflow JSON or outputs.
- Prefer dry-run before mutating release/TestFlight flows.
- Use `private: true` for helper workflows not meant for direct listing.
- After failures, preserve run ID and resume only when the command indicates recovery is safe.
