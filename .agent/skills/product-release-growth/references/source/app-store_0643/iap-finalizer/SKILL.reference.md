---
name: iap-finalizer
description: Take a one-time in-app purchase from MISSING_METADATA to READY_TO_SUBMIT in App Store Connect — set its price schedule and localized display name/description (and optional review screenshot) via the ASC REST API. Use when an in-app purchase shows Missing Metadata or needs a price before submission, once the purchase works in the app and its App Store Connect record exists. NOT for subscriptions, and NOT the same as promoted-iap (which displays IAPs in-app).
allowed-tools: [Read, Bash, AskUserQuestion]
last_verified: 2026-10-03
review_by: 2027-06-22
os_version: iOS 27
---

# IAP Finalizer

Finish a **one-time** in-app purchase on the store side: **price + localization**, the two fields most App Store Connect MCP servers can't set. Moves an IAP from `MISSING_METADATA` → `READY_TO_SUBMIT` so it can ship with the build.

> **This finalizes; it does not define.** The product id, tier, and price *decision* come from `monetization` and `generators/paywall-generator`. The App Store Connect IAP record must already exist (created in App Store Connect or via an MCP server). This skill sets the metadata on that existing record.

## When This Skill Activates

- "My IAP says Missing Metadata", "set the price for my in-app purchase", "localize the IAP name"
- A one-time purchase must be `READY_TO_SUBMIT` to ship with the next build
- Pre-submission checklist shows an IAP without a price schedule or localization

## Where it fits (read the seams)

- **Not the paywall.** `generators/paywall-generator` builds the IAP *into the app* (StoreKit 2) and `monetization` *decides* the price. This skill is the store-side finalization before submission.
- **Price = one source of truth.** Do **not** re-ask the price. **Read it** from wherever the project recorded the monetization decision (a planning doc, the paywall config, or the StoreKit configuration file); only *confirm* it. Re-eliciting risks drift from the paywall/StoreKit price.
- **Not `promoted-iap`.** That generator displays promoted IAPs in-app; this sets ASC price/localization. Different jobs.
- **One-time IAPs only.** Subscriptions are a separate ASC flow (groups/offers) — out of scope here.

## Prerequisites

- `_shared/asc-api/` set up (see its README — key + `~/.appstoreconnect/`).
- Set `ASC="python3 <path to asc.py>"`. `asc.py` lives at `_shared/asc-api/asc.py` under the same `skills/` root as this skill — resolve it **relative to this SKILL.md file's location** (`../../_shared/asc-api/asc.py` from this skill's directory), never relative to the project cwd (skills run with cwd = the user's project). Known install locations:
  - Copied install: `.claude/skills/_shared/asc-api/asc.py` (project) or `~/.claude/skills/_shared/asc-api/asc.py` (global)
  - Plugin install: resolve from this file's location — the `_shared/` tree ships with the plugin.
- The IAP already exists in App Store Connect. Get its id: `$ASC GET "/v1/apps/<APP_ID>/inAppPurchasesV2" --apply` → pick the product.
- Price already decided. Read it from the project and confirm — don't invent it.

## Flow — dry-run → confirm → apply

1. **Confirm state.** `$ASC GET "/v2/inAppPurchases/<IAP_ID>" --apply` → current `state` + `productId`. Read the target price + Display Name (≤30) + Description (≤45) from the project; confirm with the user via `AskUserQuestion` if anything is missing.
2. **Find the price point.**
   ```
   $ASC GET "/v2/inAppPurchases/<IAP_ID>/pricePoints?filter[territory]=USA"
   ```
   Pick the `inAppPurchasePricePoint` id whose `customerPrice` matches the target tier (e.g. 6.99).
3. **Set the price** (one-time IAPs use *price schedules*):
   ```
   $ASC POST /v1/inAppPurchasePriceSchedules @price.json          # dry-run: review the body
   $ASC POST /v1/inAppPurchasePriceSchedules @price.json --apply  # after you confirm
   ```
   Body: `data` relationships `inAppPurchase`→{IAP_ID}, `baseTerritory`→USA, `manualPrices`→[new `inAppPurchasePrices`]; `included` a new `inAppPurchasePrices` referencing the price point with `startDate: null` (="now").
4. **Set the localization:**
   ```
   $ASC POST /v1/inAppPurchaseLocalizations '{"data":{"type":"inAppPurchaseLocalizations","attributes":{"locale":"en-US","name":"<=30","description":"<=45"},"relationships":{"inAppPurchase":{"data":{"type":"inAppPurchases","id":"<IAP_ID>"}}}}}' --apply
   ```
   PATCH the existing localization id instead if one already exists.
5. **Review screenshot (optional):** `POST /v1/inAppPurchaseAppStoreReviewScreenshots` — the 3-step ASC upload (reserve → upload bytes → commit).
6. **Verify:** `$ASC GET "/v2/inAppPurchases/<IAP_ID>" --apply` → `state` no longer `MISSING_METADATA`.

## Done

- IAP priced + localized in ASC; state advanced; ready to submit with the build.

## Caveats

- **Verify each endpoint/field against the current [ASC API reference](https://developer.apple.com/documentation/appstoreconnectapi) before `--apply`** (verified 2026-10).
- Every write is **dry-run first** — show the body, confirm, then `--apply`. Never `--apply` a price the user hasn't seen.
- One-time IAPs only. Subscriptions use subscription groups and offers, a separate flow (`generators/subscription-offers`).

## Common Mistakes

✅ Read the price from the project's monetization decision and confirm it with the user.
❌ Picking a price point "close enough" — the `pricePoints` list is per-territory; match `customerPrice` exactly in the base territory and let App Store Connect equalize the rest.
❌ Submitting the build before the IAP leaves `MISSING_METADATA` — the IAP won't be reviewed with it.

## References

- [In-app purchase API](https://developer.apple.com/documentation/appstoreconnectapi/in-app-purchases)
- [Set a price for an in-app purchase](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/set-a-price-for-an-in-app-purchase)
- Related: `_shared/asc-api`, `generators/paywall-generator`, `monetization`
