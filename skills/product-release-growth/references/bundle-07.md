# Integrated Reference Bundle 07

Combines 11 related source skills from `product-release-growth` into one navigable reference file.

## Source map

- `monetization/bundles-and-licensing/SKILL.reference.md`
- `monetization/external-purchases/SKILL.reference.md`
- `product/SKILL.reference.md`
- `product/app-namer/SKILL.reference.md`
- `product/architecture-spec/SKILL.reference.md`
- `product/competitive-analysis/SKILL.reference.md`
- `product/idea-generator/SKILL.reference.md`
- `product/implementation-guide/SKILL.reference.md`
- `product/implementation-spec/SKILL.reference.md`
- `product/localization-strategy/SKILL.reference.md`
- `product/prd-generator/SKILL.reference.md`

## Integrated guidance

### Source: `monetization/bundles-and-licensing`

# Bundles & Licensing

Four ways one piece of software earns more than one price tag.

## When This Skill Activates

- A portfolio developer asks how apps can sell each other ("bundle my apps?")
- Deciding whether to enable Family Sharing on a subscription or purchase
- Exploring partnerships with complementary indie apps
- Schools, clinics, or businesses keep asking "how do we buy 30 seats?"
- The store-growth audit flags P8.5, P8.6, or P8.7

## 1. Own-app bundles (available now)

App bundles group up to 10 of your own paid apps — or apps sharing a subscription — at a bundle
price, with **Complete My Bundle** crediting what a user already paid.

- ✅ Portfolio play: your catalog cross-sells itself on every member app's product page — a
  discovery surface, not just a discount (pairs with the checkbox-storefront and portfolio
  tactics in `app-store/marketing-strategy`).
- ✅ Price the bundle at "second app ~half off, third+ nearly free" — the goal is basket size
  and page presence, not margin per unit.
- ❌ Bundling apps with no shared audience; the bundle card confuses both product pages.
- Mechanics: paid apps only (or one subscription spanning the bundle); free apps can't bundle.

## 2. Family Sharing (available now — chronically under-enabled)

A checkbox per IAP/subscription in ASC, plus StoreKit handling for shared entitlements. One
purchase covers up to 5 additional family members — 6 entitlements, "6 for the price of 1".

- ✅ Enable for subscriptions whose *job* is shareable (utilities, education, health, home) —
  "the whole family for one price" beats a 6× cheaper feel at maybe 1.5× usage cost, and it's a
  paywall differentiator against non-sharing competitors.
- ✅ Drive paywall copy off `isFamilyShareable` rather than hardcoding "share with your family".
- ✅ Distinguish `ownershipType` — `PURCHASED` vs `FAMILY_PURCHASED` — to tailor onboarding;
  the family member never saw your paywall or purchase flow.
- ✅ Family entitlements arrive *outside* any purchase flow, and after a deliberate delay (the
  purchaser gets a window to disable sharing first) — listen on `Transaction.updates`, and
  check entitlement before merchandising (a family member may already be covered).
- ✅ Handle `revocationDate` + the REVOKE server notification by re-deriving entitlements from
  the full transaction history; test the revoked-from-family path.
- ❌ Enabling it on a per-seat B2B-ish product where sharing cannibalizes real seats — that's
  what volume licensing (below) is for.
- One-way door: enabling takes effect **within hours for new and existing customers** and is
  irreversible — turning it off only affects new purchases.

## 3. Cross-developer bundles & suites

Combined subscriptions spanning apps from *different* developers — the "indie suite" model
(several complementary tools, one subscription).

- The unlock: each partner's install base becomes the others' warm audience — distribution
  cheaper than any paid channel.
- ✅ Partner selection: same buyer, adjacent jobs, no feature overlap (writing tool + reference
  manager + focus timer, not three writing tools). Draft revenue-share on *attribution of the
  acquiring app*, not equal splits.
- ✅ Verify current ASC mechanics before promising a ship date — cross-developer suites are a
  recent capability and terms/tooling are still settling; the fallback is coordinated own-app
  pricing + mutual offer codes (`generators/offer-codes-setup`).
- ❌ Partnering with an app whose rating or privacy posture you wouldn't put your name on — a
  suite shares reputational blast radius (run `app-store/originality-check` thinking on partners).

## 4. Group Purchases & Volume Purchasing — institutional sales

Live for all auto-renewable subscriptions using StoreKit 2 (StoreKit 2 required). ON by default
for most new and existing StoreKit 2 subscriptions — but Family Sharing-enabled subscriptions
are opted OUT by default. Configure per subscription in ASC.

Two sale paths, same seat pool:
- **In-app group purchases** — a customer buys N seats, shares an invite link, and accepters are
  auto-assigned to seats.
- **Volume purchasing** through **Apple Business Manager / Apple School Manager** — the
  institutional channel for schools, clinics, and businesses.

Mechanics:
- **Volume pricing = up to 5 price bands**, with full control of seat thresholds and each band's
  price. The default is every seat at the current price — no discount exists until you configure
  bands (e.g., $19.99 → $13.99 at 21–40 seats → $10.99 at 41+; a 50-seat purchase then averages
  ~20% off).
- ✅ Prefer the built-in seat management (invites, acceptance tracking, seat lifecycle) unless
  you already run member management — then use the App Store Server API group endpoints instead.
- ✅ Merchandise the group value in-app — buyers won't discover multi-seat pricing on their own.
- ✅ Education/health apps: this often outearns consumer conversion optimization by an order of
  magnitude — one district buys more seats than a year of paywall A/B tests adds.
- ❌ Building custom seat management UI before validating a single institutional buyer exists —
  the built-in flow covers the first sale.
- Custom Apps via Apple Business Manager remain the path for bespoke B2B distribution; Group
  Purchases brings multi-seat to the mainstream store — different tools, same buyer.
- Reference: the WWDC26 session on group purchases and volume purchasing.

## Decision sketch

| You have | Reach for |
|---|---|
| 2+ paid apps, shared audience | Own-app bundle |
| A shareable-job subscription | Family Sharing on |
| A complementary indie peer with real traffic | Cross-developer suite (or mutual offer codes today) |
| Institutions asking to buy seats | Group Purchases / volume price bands (live — configure in ASC) |

## Output Format

```
Portfolio: bundle-eligible apps? bundle live? Complete-My-Bundle pricing sane?
Family Sharing: enabled where the job is shareable? entitlement handling tested?
Partnerships: candidate named? terms sketched?
Institutional: demand evidence? seats model drafted? volume price bands configured?
```

Each gap routed to the numbered section above; StoreKit implementation to
`generators/subscription-lifecycle`, offer distribution to `generators/offer-codes-setup`.

## References

- https://developer.apple.com/help/app-store-connect/create-an-app-bundle/
- https://developer.apple.com/documentation/storekit/supporting-family-sharing-in-your-app
- https://support.apple.com/guide/apple-business-manager/welcome/web
- Related skills: `monetization` (pricing/tiers), `generators/subscription-lifecycle`, `generators/offer-codes-setup`, `growth/store-growth-audit`

### Source: `monetization/external-purchases`

# External Purchases (US Web Checkout)

On the **US storefront**, apps may link out to a web checkout for digital goods using the
StoreKit External Purchase Link entitlement — and as of mid-2026, court orders have Apple's
commission on those purchases at **0%**, with the fee case still moving through district court.
This is the largest indie revenue unlock of the era, and it is *reversible by a ruling* — so the
engineering rule is: **ship it now, architect it so a commission can be flipped on later.**

> Verify current state before relying on this: the entitlement terms, the commission rate, and
> the litigation status have each changed more than once. Treat every number here as
> "true as of 2026-07, re-check."

## When This Skill Activates

- "Add a web checkout / Stripe / external purchase link" for digital goods
- Deciding IAP vs web checkout for a US-heavy revenue base
- The store-growth audit flags P8.4
- Reviewing an app whose external links might be non-compliant (wrong storefront, no entitlement)

## The rules of the road

- **US storefront only** — elsewhere Guideline 3.1.1 still applies (EU/JP/KR have separate
  entitlements/terms; don't extrapolate from the US).
- **Entitlement required**: `com.apple.developer.storekit.external-purchase-link` + matching
  `Info.plist` declaration — a bare `Link("Buy", …)` without it is still a rejection (see
  `app-store/rejection-handler` §3.1.1).
- Present the link per the entitlement's UI terms (StoreKit's `ExternalPurchaseLink` /
  disclosure sheet where required). Don't dark-pattern the IAP option away if you keep both.
- Purchases made on the web are **your** customer relationship — payment processor, refunds,
  taxes; Apple's merchant-of-record role no longer applies.

## Architecture: the commission flip

Design so that a future "Apple takes N% of external purchases initiated in-app" ruling changes a
config value, not your codebase:

- ✅ Route every in-app-initiated web checkout through **one** link-out service that stamps the
  session (`source=app`, timestamp, storefront) — web-organic checkouts stay unstamped. If a
  commission returns, it applies to a knowable, logged subset.
- ✅ Keep a single `CommissionPolicy` (remote-configurable): `rate`, `applies_to`,
  `effective_date`. Report/accrue against it from day one — at 0% it's just a counter.
- ✅ Log day-one analytics: link taps → checkout starts → completions, vs the IAP funnel. The
  conversion drop through a web checkout (Apple's sheet, Safari hop, payment form) is real;
  whether 0% beats IAP's frictionless 85–70% is an *empirical* per-app question.
- ❌ Scattering `openURL("https://…/buy")` calls through features — un-auditable, un-flippable.
- ❌ Ripping out StoreKit. Keep IAP as a fallback path (non-US storefronts still need it, and
  some US users convert better in-sheet).

## Decision sketch

| Situation | Lean |
|---|---|
| Subscriptions, US-heavy, ARPU high enough to absorb processor fees + your own support | Web checkout for new subs; keep IAP for the rest of world |
| Impulse-priced consumables/unlocks | IAP — checkout friction eats more than 15–30% commission |
| Existing subscriber base on IAP | Don't force-migrate; offer web at renewal decision points |
| B2B/prosumer, invoicing needs | Web checkout regardless of commission math |

## Output Format

```
Status: entitlement present? · storefront scope correct (US-only gating)? ·
link-out service centralized? · CommissionPolicy flippable? · funnel analytics live?
Verdict + the one next step.
```

## References

- https://developer.apple.com/documentation/storekit/externalpurchaselink
- https://developer.apple.com/support/storekit-external-entitlement-us/
- https://developer.apple.com/app-store/review/guidelines/#in-app-purchase
- Related skills: `app-store/rejection-handler` (the non-entitled rejection pattern), `generators/subscription-lifecycle`, `monetization` (pricing), `growth/store-growth-audit`

### Source: `product`

# Product Development Expert

Comprehensive product development guidance for iOS/macOS apps. This skill orchestrates the entire product lifecycle from idea validation to App Store release.

## When This Skill Activates

Use this skill when the user:
- Has an app idea and wants to validate it
- Needs market research or competitive analysis
- Wants to generate product specifications
- Needs architecture or UX design documents
- Is preparing for App Store submission
- Wants to plan beta testing or TestFlight strategy
- Needs localization strategy or market expansion planning
- Wants end-to-end product planning

## Available Modules

Read relevant module files based on the user's needs:

### Phase 0: Idea Discovery

**idea-generator/**
Brainstorm and rank app ideas via 5 lenses.
- Developer profile elicitation (skills, interests, constraints)
- Five brainstorming lenses (skills, problem-first, technology-first, market gap, trend-based)
- Feasibility filtering and scoring
- Ranked shortlist of 3-5 ideas with `next_step` commands

**app-namer/**
Turn a chosen idea into validated, App-Store-ready name candidates.
- Branded vs. descriptive vs. hybrid archetypes, paired with a subtitle
- App Store display rules (30-char limit, Home-Screen truncation, name/subtitle interplay)
- Validation gauntlet: App Store Connect name, trademark knockout, domain/.app, social handle, linguistic safety
- Ranked shortlist with scores and a "reserve now" action; feeds `app-store/keyword-optimizer`

### Discovery & Validation

**product-agent/**
AI-powered product discovery and validation.
- Idea validation and assessment
- MVP scoping
- Market opportunity analysis

**market-research/**
Deep market analysis.
- Market sizing (TAM/SAM/SOM)
- Growth trends and maturity
- Entry barriers and distribution channels
- Revenue potential

**competitive-analysis/**
Competitor deep dive.
- Feature comparison matrices
- Pricing analysis
- Strengths/weaknesses
- Differentiation opportunities

### Specification Generation

**prd-generator/**
Product Requirements Document.
- Features and user stories
- Acceptance criteria
- Success metrics

**architecture-spec/**
Technical architecture.
- Architecture pattern selection
- Tech stack decisions
- Data models
- App structure

**ux-spec/**
UI/UX specifications.
- Wireframes and user flows
- Design system definition
- Interaction patterns

**implementation-guide/**
Development roadmap.
- Step-by-step instructions
- Pseudo-code examples
- Implementation priorities

**test-spec/**
QA and testing strategy.
- Unit test coverage
- UI testing plan
- Accessibility testing
- Beta testing strategy

**release-spec/**
App Store preparation.
- Submission guide
- Asset requirements
- Privacy compliance
- Marketing strategy

### Pre-Launch

**beta-testing/**
TestFlight beta program strategy and feedback collection.
- Internal vs. external testing cohort management
- Beta tester recruitment and incentive strategies
- Feedback collection methodology (in-app, surveys, interviews)
- Signal vs. noise framework for interpreting feedback
- Go/no-go launch decision framework

**localization-strategy/**
Market prioritization and localization planning.
- Language tier recommendations by app category
- Minimum viable localization levels (metadata-only to full)
- Translation workflow with Xcode String Catalogs
- Cultural adaptation beyond translation
- Localized ASO strategy

### Orchestration

**implementation-spec/**
Master orchestrator.
- Generates complete specification package
- Coordinates all role-based agents
- End-to-end spec generation

**WORKFLOW.md**
Product development workflow guide.

## How to Use

1. Identify where user is in product lifecycle
2. Read relevant module SKILL.md for detailed process
3. Generate requested specifications
4. Save outputs to appropriate files

## Example Workflows

**User doesn't have an idea yet:**
1. Use `idea-generator/` to brainstorm and rank ideas
2. Pick top idea from shortlist
3. Run `product-agent/` to validate the idea
4. Run `app-namer/` to name it and reserve the App Store name
5. Continue with market research and specs

**User has new app idea:**
1. Use `product-agent/` for initial validation
2. Run `market-research/` for market sizing
3. Run `competitive-analysis/` for competitor insights
4. Generate PRD with `prd-generator/`

**User wants full spec package:**
1. Use `implementation-spec/` orchestrator
2. It coordinates all spec generators
3. Produces complete documentation set

### Source: `product/app-namer`

# App Namer Skill

Takes an app idea or one-liner and produces a ranked shortlist of 5-8 **validated** name candidates — not random brainstorming. Each candidate is generated from a naming archetype, paired with a subtitle, checked against App Store display rules, and run through an availability gauntlet (App Store Connect name, trademark, domain, handle) before it's recommended.

The output is a name you can reserve in App Store Connect today, with the keyword work already aligned to feed the `app-store/keyword-optimizer` skill.

## When This Skill Activates

Use this skill when the user:
- Has an app idea but no name ("what should I call it?")
- Wants name ideas or a naming brainstorm for a specific app
- Needs to know if a name is available / safe to use
- Is about to create the app record in App Store Connect and needs to reserve a name
- Wants to rename an existing app and needs ownable, ASO-smart options
- Picked an idea from `idea-generator` and needs the name before writing the PRD

**No app idea yet?** Run `product/idea-generator` first, then come back with the chosen idea.

**Already have a locked name and just want ASO?** Skip this skill — go to `app-store/keyword-optimizer`.

## Reference Files

Before generating names, load both reference files:

| File | Purpose |
|------|---------|
| **naming-strategies.md** | The 3 archetypes, naming techniques, App Store display mechanics (30-char limit, home-screen truncation, name/subtitle interplay), good/bad examples |
| **validation-checklist.md** | The knockout gauntlet — App Store Connect name availability, trademark sanity check, domain/.app, social handles, linguistic safety |

## What This Skill Does

```
Idea/positioning
   ↓  elicit
Naming brief (what it does, who it's for, personality, scope ceiling)
   ↓  generate across archetypes
20-40 raw candidates (branded / descriptive / hybrid)
   ↓  filter (pronounce, spell, truncate, confusability)
8-12 survivors
   ↓  pair with subtitle + score
Ranked candidates with name + subtitle + display preview
   ↓  validate (ASC name / trademark / domain / handle)
5-8 validated candidates
   ↓
Recommendation + "reserve now" action
```

## The Naming Process

### Step 1: Build the Naming Brief

If the user hasn't given enough context, gather it with AskUserQuestion. You need:

| Field | Why it matters |
|-------|----------------|
| **One-liner** | What the app does in one sentence — drives descriptive/hybrid candidates |
| **Target user** | Tone calibration (pro tool vs. playful consumer app) |
| **Personality** | Serious, playful, minimal, premium, technical? Sets the archetype mix |
| **Category** | App Store category — affects trademark class and competitor naming norms |
| **Scope ceiling** | Will it stay single-purpose or grow? A too-descriptive name boxes you in |
| **Existing brand** | Company/developer name, existing app family to stay consistent with |

If the user gives a one-liner and nothing else, infer sensible defaults, **state your assumptions**, and proceed — don't block on a full questionnaire.

### Step 2: Generate Across Archetypes

Generate 20-40 raw candidates spread across the three archetypes (see **naming-strategies.md** for each technique and examples):

1. **Branded / invented** — coined, ownable, zero literal meaning (Spotify, Halide, Bevel, Bear)
2. **Descriptive** — says what it does, carries a keyword (Sleep Cycle, PDF Expert, Pocket Casts)
3. **Hybrid / suggestive** — a real or twisted word that evokes the benefit (Streaks, Overcast, Carrot Weather, Drafts)

Aim for roughly **40% hybrid, 30% branded, 30% descriptive** for a typical indie app — hybrid names tend to win because they're ownable *and* memorable, with the descriptive keyword pushed into the subtitle.

Use the techniques in **naming-strategies.md**: real words, compounds, portmanteaus, prefix/suffix, dropped vowels, foreign words, metaphors.

### Step 3: Filter Hard and Fast

Kill any candidate that fails a basic filter before spending effort scoring it:

- ❌ Can't be pronounced correctly on first read
- ❌ Can't be spelled correctly after hearing it once (the "radio test")
- ❌ (iOS) Doesn't read cleanly when truncated to ~12 characters on the Home Screen — relaxes for Mac apps (see naming-strategies.md)
- ❌ Confusable with a major existing app (Notes, Notion, Things, etc.)
- ❌ Purely generic/descriptive with no distinctiveness (un-trademarkable)
- ❌ Produces an ugly bundle ID or has awkward casing

Target 8-12 survivors going into scoring.

### Step 4: Pair With a Subtitle

For each survivor, write the `Name — Subtitle` pairing the way it appears on the App Store. This is where the ASO strategy lives:

```
[Brand Name] — [Descriptive keyword phrase]

Halide — Pro Camera
Streaks — Habit Tracker
Bear — Markdown Notes
```

The **name** carries the brand; the **subtitle** carries the searchable keywords. This means a branded/hybrid name doesn't need to be descriptive — the subtitle does that job. Both are 30-char fields and both are indexed. (See `app-store/keyword-optimizer` for full keyword allocation.)

### Step 5: Score Each Candidate

Score each candidate 1-10 on six dimensions:

| Dimension | WEAK (1-3) | STRONG (4-7) | EXCELLENT (8-10) |
|-----------|------------|--------------|------------------|
| **Memorability** | Forgettable, generic | Distinctive | Sticky, instantly recalled |
| **Clarity/Fit** | Misleading or opaque | Evokes the benefit (with subtitle) | Name+subtitle = instant understanding |
| **Availability** | Name & domain taken, TM conflict | Domain workaround, name free | Name + .com/.app + clean TM headroom |
| **ASO Value** | Dead keyword-wise | Subtitle carries keywords | Brandable + subtitle owns a keyword |
| **Pronounce/Spell** | Fails radio test | Minor ambiguity | Say it once, spell it right, Siri-safe |
| **Scalability** | Boxed into v1 scope | Some room | Grows with the product |

**Overall = weighted average**, with **Availability and Memorability weighted 1.5×** (an unavailable name scores zero regardless of how clever it is).

### Step 6: Validate the Top Candidates

Run the top 5-8 through the gauntlet in **validation-checklist.md**. For each, record status as `available` / `taken` / `conflict` / `unchecked`:

1. **App Store name** — exact-name search on the App Store; reserve in App Store Connect if clear
2. **Trademark knockout** — USPTO/EUIPO + web search in the software class (not legal clearance)
3. **Domain** — `.com`, then `.app`, then `get-/try-/use-` prefixes
4. **Social handle** — consistent handle across X / Instagram (nice-to-have)
5. **Linguistic safety** — no bad meanings in top ASO markets, Siri-pronounceable

Use WebSearch/WebFetch to check what's checkable (existing App Store apps, trademark databases, domain registrars). For anything you can't verify, mark it `unchecked` and tell the user exactly how to check — **never report a name as available if you didn't verify it.**

### Step 7: Recommend and Reserve

Present the ranked shortlist, then make a single clear recommendation. End with the action: **reserve the winning name in App Store Connect now** — App Store names are unique and first-come, so a name that's available today can be gone tomorrow.

## Output Structure

```json
{
  "naming_brief": {
    "one_liner": "On-device app that turns leftover ingredients into recipe suggestions",
    "target_user": "Home cooks who want to reduce food waste",
    "personality": "warm, simple, a little playful",
    "category": "Food & Drink",
    "scope_ceiling": "could expand to meal planning and grocery lists",
    "assumptions": ["No existing brand to match", "iOS-first, US market primary"]
  },
  "shortlist": [
    {
      "rank": 1,
      "name": "Larder",
      "archetype": "hybrid",
      "name_subtitle": "Larder — Recipes From Leftovers",
      "char_counts": { "name": 6, "subtitle": 30 },
      "home_screen_preview": "Larder",
      "rationale": "Evokes the source (what's in your larder) without being literal about recipes; warm, short, and far more ownable than the generic 'Pantry'; subtitle carries the 'recipes' + 'leftovers' keywords.",
      "scores": {
        "memorability": 8,
        "clarity_fit": 8,
        "availability": 9,
        "aso_value": 8,
        "pronounce_spell": 9,
        "scalability": 9
      },
      "overall_score": 8.4,
      "validation": {
        "app_store_name": "no live 'Larder' recipe app found — verify in ASC New App and reserve",
        "trademark": "unchecked — run USPTO TESS for 'Larder' in Class 9/42 before committing",
        "domain": "larder.com taken; larder.app available — recommended buy",
        "handle": "@larder taken; @larderapp available",
        "linguistic": "clean in EN/ES/DE/JA; Siri-safe"
      },
      "risks": "Slightly less self-explanatory than 'Pantry' on its own — the subtitle does the clarifying. Confirm the trademark knockout before reserving."
    }
  ],
  "filtered_out": [
    { "name": "Pantry", "reason": "Too generic to own — App Store name and pantry.com almost certainly taken, un-trademarkable" },
    { "name": "LeftoverChef", "reason": "Two-word compound truncates badly on Home Screen; 'Chef' is crowded and trademark-risky" },
    { "name": "Fridgify", "reason": "Cute but fails the radio test — users will spell it 'Fridgefy'/'Fridgi'" }
  ],
  "recommendation": "Lead with Rank 1 if a clean App Store variant clears reservation; otherwise Rank 2. Reserve the winner in App Store Connect immediately, then run app-store/keyword-optimizer to lock the subtitle and keyword field.",
  "next_step": "Reserve the name in App Store Connect → run keyword-optimizer for subtitle + 100-char keywords → feed the name into prd-generator"
}
```

## End-to-End Example

**Brief:** "A minimalist iOS app that tracks daily water intake with a single tap. For health-conscious people who find existing trackers cluttered. Personality: clean, calm, premium. Stays single-purpose."

**Generate (sample of ~30):**
- *Branded:* Drift, Sip, Wello, Aqo, Nim
- *Descriptive:* Water Daily, Hydrate, Daily Water, Intake
- *Hybrid:* Gulp, Tide, Droplet, Wave, Brim, Flow

**Filter:** Drop "Intake" (generic, taken), "Hydrate" (crowded, hard to own), "Aqo" (fails spell test).

**Pair + score top survivors:**

| Name | Pairing | Memorable | Avail. | ASO | Overall |
|------|---------|-----------|--------|-----|---------|
| Brim | Brim — Water Tracker | 8 | 7 | 7 | 7.6 |
| Sip | Sip — Daily Water | 9 | 5 | 7 | 7.2 |
| Droplet | Droplet — Hydration | 7 | 6 | 8 | 7.0 |

**Validate (top 3):** "Sip" — App Store name almost certainly taken (very common), sip.com taken. "Brim" — exact App Store name worth checking, brim.app likely available, no obvious TM conflict in Class 9. "Droplet" — used by DigitalOcean (TM risk in software).

**Recommendation:** "Go with **Brim — Water Tracker**. It's short (stands alone on the Home Screen), calm and ownable, almost certainly clears the App Store name, and `brim.app` is available. Avoid Droplet (DigitalOcean trademark in software). Reserve 'Brim' in App Store Connect now, then run keyword-optimizer to fill the subtitle and keyword field around 'water, hydration, drink, reminder.'"

## Integration With Other Skills

```
product/idea-generator        → pick an idea
        ↓
product/app-namer (THIS SKILL) → name it + reserve it
        ↓
app-store/keyword-optimizer    → lock subtitle + 100-char keywords around the name
        ↓
product/prd-generator          → [App Name] is now filled in
        ↓
generators/app-icon-generator  → icon that matches the name's personality
```

The name you pick here is the highest-weighted ASO field and a permanent brand decision — it flows into the keyword strategy, the PRD, the icon, and the bundle ID. Get it right before you build.

## When NOT to Use This Skill

- **No idea yet** — run `idea-generator` first
- **Name is already locked** — go to `keyword-optimizer` for ASO
- **You need the legal clearance** — this skill does a *knockout* search, not trademark clearance; consult an attorney before filing
- **Renaming a high-traffic live app** — renaming resets branded search equity; see `keyword-optimizer/existing-app-strategy.md` before changing a name that's working

## Deliverables

At the end of this skill you should have:

- [ ] Naming brief captured (one-liner, user, personality, category, scope, assumptions)
- [ ] Candidates generated across all three archetypes
- [ ] Filtered down with reasons (pronounce/spell/truncate/confusability)
- [ ] Each finalist paired as `Name — Subtitle` with char counts ≤ 30
- [ ] Home-screen truncation preview for each
- [ ] Scored on all six dimensions, ranked by weighted overall
- [ ] Top candidates run through the validation gauntlet with status flags
- [ ] One clear recommendation + the "reserve in App Store Connect now" action
- [ ] `next_step` pointing to keyword-optimizer and prd-generator

## Output File Location

Save results to `app-name-shortlist.json` (project root), using the Output Structure above.

---

**Generate wide, filter hard, validate before you fall in love.** The best app name is short, ownable, spellable, available today, and lets the subtitle do the keyword work.

### Source: `product/architecture-spec`

# Architecture Spec Skill

Generate technical architecture specification for iOS/macOS app.

## Metadata
- **Name**: architecture-spec
- **Version**: 1.0.0
- **Role**: iOS/macOS Architect
- **Author**: ProductAgent Team

## When This Skill Activates

This skill activates when the user says:
- "generate architecture"
- "create technical spec"
- "write architecture document"
- "generate architecture spec"
- "design technical architecture"
- "create ARCHITECTURE.md"

## Description

You are an iOS/macOS Architect AI agent specializing in Apple platform app architecture. Your job is to design a comprehensive technical architecture based on the Product Requirements Document (PRD) and make opinionated technology stack decisions following Apple best practices.

## Prerequisites

Before activating this skill, ensure:
1. PRD exists at `docs/PRD.md`
2. User has reviewed and approved the PRD
3. MVP scope is clear (from product-agent output or PRD)

## Input Sources

Read and extract information from:
1. **docs/PRD.md**
   - Core features and their complexity
   - Non-functional requirements
   - Data model hints
   - Platform requirements
   - Technical considerations

2. **Product development plan** (if available)
   - MVP scope with technical requirements
   - Third-party dependencies mentioned
   - Platform and timeline constraints

3. **User preferences** (ask if needed):
   - SwiftUI vs UIKit preference
   - Third-party library preferences
   - Architecture pattern preference (if strong opinion)
   - Backend API availability (determines data strategy)

## Output

Generate `docs/ARCHITECTURE.md` with the following structure:

```markdown
# Technical Architecture: [App Name]

**Version**: 1.0.0
**Last Updated**: [Date]
**Status**: Draft / In Review / Approved
**Owner**: Technical Architect
**Platform**: iOS [version]+ / macOS [version]+

---

## 1. Architecture Overview

### 1.1 Architecture Pattern

**Selected Pattern**: MVVM (Model-View-ViewModel) with SwiftUI
*or* Clean Architecture *or* TCA (The Composable Architecture)

**Reasoning**:
[Explain why this pattern was chosen based on app complexity]

**Characteristics**:
- **Layers**: [Describe the architectural layers]
- **Data Flow**: [Unidirectional / Bidirectional]
- **State Management**: [@Observable, Combine, TCA Store, etc.]
- **Testability**: [How architecture supports testing]

### 1.2 High-Level Component Diagram

```
┌─────────────────────────────────────────────────┐
│                 Presentation Layer              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │  Views   │  │ViewModels│  │  Models  │     │
│  │ (SwiftUI)│←→│(@Observ.)│←→│  (Data)  │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────┐
│                Business Logic Layer             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Services │  │  Use     │  │Repository│     │
│  │          │  │  Cases   │  │ Pattern  │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────┐
│                  Data Layer                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │SwiftData │  │ Network  │  │ Keychain │     │
│  │ / Core   │  │ Client   │  │ Storage  │     │
│  │   Data   │  │ (URLSess)│  │          │     │
│  └──────────┘  └──────────┘  └──────────┘     │
└─────────────────────────────────────────────────┘
```

### 1.3 Key Architectural Decisions

| Decision | Choice | Alternative Considered | Rationale |
|----------|--------|----------------------|-----------|
| UI Framework | SwiftUI | UIKit | Modern, declarative, iOS 17+ target allows it |
| Data Persistence | SwiftData | Core Data | Simpler API, better SwiftUI integration |
| Architecture Pattern | MVVM | VIPER, TCA | Balanced complexity vs maintainability |
| Networking | URLSession | Alamofire | No third-party dependency needed |
| State Management | @Observable | Combine, TCA | iOS 17+ Observation framework |
| Navigation | NavigationStack | Coordinator | SwiftUI native, simpler for MVP |

---

## 2. Technology Stack

### 2.1 Apple Frameworks

**UI & Presentation**:
- **SwiftUI** (primary) - Declarative UI framework
  - Minimum iOS 17.0 for @Observable, ContentUnavailableView, etc.
  - Navigation: NavigationStack, NavigationPath
  - Data binding: @State, @Binding, @Environment

**Data Persistence**:
- **SwiftData** (iOS 17+) - Data modeling and persistence
  - @Model macro for model classes
  - ModelContainer for database configuration
  - ModelContext for CRUD operations
  - @Query property wrapper for automatic observation

**Networking & Concurrency**:
- **URLSession** - HTTP networking
- **async/await** - Concurrency
- **Actors** - Thread-safe state management
- **Codable** - JSON serialization/deserialization

**Security**:
- **Keychain Services** - Secure credential storage
- **CryptoKit** - Encryption (if needed)
- **LocalAuthentication** - Biometric authentication (if needed)

**Other**:
- [List any other frameworks based on features]
  - MapKit (if maps needed)
  - Vision (if image recognition)
  - CoreML (if ML features)
  - StoreKit (if IAP)
  - CloudKit (if iCloud sync)

### 2.2 Third-Party Dependencies

**Via Swift Package Manager**:

1. **[Package Name]** (if needed)
   - **Repository**: https://github.com/[org]/[repo]
   - **Version**: ~> X.X.X
   - **Purpose**: [Why this is needed]
   - **Alternative Considered**: [Why not chosen]
   - **License**: [MIT, Apache, etc.]

*Note*: Keep dependencies minimal. Only add if:
- Provides significant value not available in Apple frameworks
- Well-maintained and trusted
- No suitable alternative

**Decision**: Start with zero third-party dependencies for MVP. Add only if needed.

### 2.3 Development Tools

- **Xcode**: [Latest stable version]
- **iOS Deployment Target**: iOS 26.0 (adjust lower for broader reach — iOS 17+ retains `@Observable` and SwiftData support)
- **Swift Version**: Swift 6+
- **Package Manager**: Swift Package Manager (SPM)
- **CI/CD**: Xcode Cloud / GitHub Actions (to be determined)

---

## 3. App Structure

### 3.1 Module Breakdown

```
[AppName]/
├── App/
│   ├── [AppName]App.swift          # App entry point (@main)
│   ├── ContentView.swift            # Root view
│   └── AppState.swift               # Global app state (if needed)
│
├── Features/                        # Feature-based modules
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   ├── HomeCardView.swift
│   │   │   └── HomeEmptyStateView.swift
│   │   ├── ViewModels/
│   │   │   └── HomeViewModel.swift
│   │   └── Models/
│   │       └── HomeItem.swift (if feature-specific)
│   │
│   ├── [Feature2]/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   │
│   └── [Feature3]/
│       └── ...
│
├── Core/                            # Shared core functionality
│   ├── Networking/
│   │   ├── APIClient.swift          # HTTP client
│   │   ├── APIEndpoint.swift        # Endpoint definitions
│   │   ├── APIError.swift           # Error types
│   │   └── RequestModels/           # API request DTOs
│   │       └── ...
│   │
│   ├── Storage/
│   │   ├── DataManager.swift        # SwiftData container wrapper
│   │   └── KeychainManager.swift    # Keychain operations
│   │
│   ├── Extensions/
│   │   ├── View+Extensions.swift    # SwiftUI View extensions
│   │   ├── Color+Extensions.swift   # Color palette
│   │   ├── Font+Extensions.swift    # Typography
│   │   └── Date+Extensions.swift    # Date utilities
│   │
│   └── Utilities/
│       ├── Logger.swift              # Logging utility
│       ├── Validator.swift           # Input validation
│       └── Constants.swift           # App constants
│
├── Models/                          # Domain models (shared)
│   ├── User.swift                   # @Model classes
│   ├── [Entity2].swift
│   └── ResponseModels/              # API response DTOs
│       └── ...
│
├── Services/                        # Business logic services
│   ├── AuthenticationService.swift
│   ├── [Feature]Service.swift
│   └── SyncService.swift (if background sync)
│
├── Resources/
│   ├── Assets.xcassets              # Images, colors
│   ├── Localizable.xcstrings        # Translations
│   └── PrivacyInfo.xcprivacy        # Privacy manifest
│
└── Tests/
    ├── UnitTests/
    │   ├── ViewModelTests/
    │   ├── ServiceTests/
    │   └── ModelTests/
    └── UITests/
        └── ...
```

**Organizational Principles**:
- **Feature-based organization**: Each major feature in its own folder
- **Vertical slicing**: Feature folder contains Views, ViewModels, and feature-specific Models
- **Core for shared**: Reusable components go in Core/
- **Models for domain**: Shared domain models (SwiftData @Model classes)
- **Services for business logic**: Business logic that spans features

### 3.2 Data Models

Based on PRD requirements, core entities are:

#### [Entity 1]: User

```swift
import Foundation
import SwiftData

@Model
final class User {
    // Identity
    @Attribute(.unique) var id: UUID
    var email: String
    var name: String
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    @Relationship(deleteRule: .cascade)
    var [relatedEntities]: [RelatedEntity]

    // Computed Properties
    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? email
            : name
    }

    // Validation
    var isValid: Bool {
        !email.isEmpty && email.contains("@") && !name.isEmpty
    }

    init(email: String, name: String) {
        self.id = UUID()
        self.email = email
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
```

#### [Entity 2]: [Name]

```swift
@Model
final class [Entity2] {
    @Attribute(.unique) var id: UUID
    var [property1]: String
    var [property2]: Date

    // Relationships
    @Relationship(inverse: \User.[relatedEntities])
    var owner: User?

    init(...) {
        // Initialization
    }
}
```

**Entity Relationships**:
- User has many [Entity2] (one-to-many)
- [Entity2] belongs to User (many-to-one)
- [Add other relationships as per PRD]

**SwiftData Considerations**:
- Use @Attribute(.unique) for identifiers
- Define deleteRule for relationships (cascade, nullify, deny, noAction)
- Keep models simple - complex logic goes in ViewModels/Services
- Use @Transient for computed properties that shouldn't persist
- Consider privacy: Mark sensitive fields appropriately

### 3.3 Navigation Architecture

**Pattern**: NavigationStack (SwiftUI native)

**Primary Navigation**:
- **TabView** for main app sections (if 3-5 top-level sections)
- **NavigationStack** for drill-down navigation within tabs

**Navigation State**:
```swift
// In each feature's root view
@State private var navigationPath = NavigationPath()

NavigationStack(path: $navigationPath) {
    ListView()
        .navigationDestination(for: Item.self) { item in
            DetailView(item: item)
        }
        .navigationDestination(for: EditMode.self) { _ in
            EditView()
        }
}
```

**Deep Linking**:
- Handle URL schemes: `[appname]://[route]/[id]`
- Use `.onOpenURL` modifier at app root
- Parse URL and manipulate NavigationPath

**Modal Presentation**:
- Use `.sheet` for full-screen modal forms
- Use `.alert` for simple confirmations
- Use `.confirmationDialog` for action sheets

---

## 4. Data Flow

### 4.1 State Management

**Pattern**: @Observable (iOS 17+ Observation framework)

**State Layers**:

1. **View State** (@State)
   - Local to view
   - Examples: isLoading, showError, selectedItem
   - Transient, not persisted

2. **ViewModel State** (@Observable)
   - Shared across view hierarchy
   - Examples: Business logic, API state, validation
   - Passed as @Environment or direct reference

3. **Persistent State** (SwiftData @Query)
   - Automatically observed by SwiftUI
   - Database-backed
   - Examples: User data, items list

**Example ViewModel**:
```swift
import Foundation
import Observation

@Observable
final class HomeViewModel {
    // Published state
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?
    var showError = false

    // Dependencies (injected)
    private let apiClient: APIClient
    private let dataManager: DataManager

    init(apiClient: APIClient = .shared,
         dataManager: DataManager = .shared) {
        self.apiClient = apiClient
        self.dataManager = dataManager
    }

    // Actions
    @MainActor
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedItems = try await apiClient.fetchItems()
            items = fetchedItems
            // Persist to SwiftData
            try dataManager.saveItems(fetchedItems)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
```

**Data Flow Diagram**:
```
User Action (Tap Button)
    ↓
View calls ViewModel method
    ↓
ViewModel calls Service/APIClient
    ↓
Service makes API call
    ↓
Response updates ViewModel @Observable properties
    ↓
SwiftUI automatically updates View
    ↓
(Optional) Persist to SwiftData
```

### 4.2 Data Persistence

**Strategy**: Local-first with optional sync

**Local Storage**:
- **SwiftData** for structured data (models)
- **UserDefaults** for simple preferences
- **Keychain** for sensitive data (tokens, passwords)
- **FileManager** for large files (images, documents)

**SwiftData Setup**:
```swift
// In App struct
@main
struct [AppName]App: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([User.self, Item.self, ...])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            container = try ModelContainer(
                for: schema,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
```

**Data Migration**:
- SwiftData handles migrations automatically for simple changes
- For complex migrations, use VersionedSchema and MigrationPlan
- Test migrations thoroughly before releases

**Backup & Sync** (if needed):
- **iCloud CloudKit**: For user data sync across devices
- **File-based**: For documents (UIDocument + iCloud Drive)
- Implementation: Phase 2 (post-MVP unless critical)

### 4.3 Networking Layer

**Architecture**: Protocol-oriented with async/await

**APIClient Design**:
```swift
actor APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://api.example.com/v1")!
    private let session: URLSession
    private var authToken: String?

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    // Generic request method
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if available
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body for POST/PUT
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Perform request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        // Decode
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }
}

// Endpoint definition
struct APIEndpoint {
    let path: String
    let method: HTTPMethod
    let body: (any Encodable)?

    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }
}

// Error handling
enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code, _):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to parse response"
        case .networkError:
            return "Network connection failed"
        }
    }
}
```

**Request/Response Models**:
- Separate DTOs (Data Transfer Objects) from domain models
- Keep in `Core/Networking/RequestModels/` and `ResponseModels/`
- Map from DTO to domain model in service layer

**Error Handling Strategy**:
- Use typed errors (APIError enum)
- Provide user-friendly messages
- Log technical details for debugging
- Implement retry with exponential backoff for transient failures
- Cache responses when appropriate

**Caching**:
- Use URLCache for HTTP caching (images, static content)
- Implement custom cache for API responses (if needed)
- Cache strategy: Cache-Control headers + custom logic

---

## 5. Security & Privacy

### 5.1 Data Security

**Sensitive Data Storage**:
```swift
// KeychainManager for secure storage
final class KeychainManager {
    static let shared = KeychainManager()

    func save(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func retrieve(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.retrieveFailed(status)
        }

        return data
    }
}
```

**Encryption**:
- API tokens: Stored in Keychain
- User passwords: Never stored locally (use tokens)
- Sensitive files: Encrypt with CryptoKit before saving
- Database: SwiftData encryption enabled (if available)

**Communication Security**:
- All API calls over HTTPS
- TLS 1.2+ required
- Certificate pinning: Consider for Phase 2 if high security needed
- No hardcoded secrets in code (use environment config)

### 5.2 Privacy

**Privacy Manifest** (PrivacyInfo.xcprivacy):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeEmailAddress</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <!-- List any required reason APIs used -->
    </array>
</dict>
</plist>
```

**Data Collection Policy**:
- Collect minimum data necessary
- Document what data is collected and why
- Provide clear privacy policy
- Allow users to delete their data
- No tracking without explicit consent

**App Tracking Transparency**:
- Only if analytics/ads used
- Request permission with clear explanation
- App must work if denied

---

## 6. Performance Considerations

### 6.1 App Launch Optimization

**Cold Launch** (< 1.5s target):
- Defer non-critical initialization
- Use lazy loading for heavy components
- Optimize image assets (compress, use asset catalogs)
- Profile with Instruments (Time Profiler)

**Warm Launch** (< 0.5s target):
- Keep memory footprint low
- Proper state restoration

### 6.2 Memory Management

**Best Practices**:
- Use value types (structs) where possible
- Avoid retain cycles with `[weak self]` in closures
- Use `@MainActor` for UI updates
- Profile with Instruments (Leaks, Allocations)
- Implement proper deinitialization

**Image Handling**:
- Lazy loading with AsyncImage
- Downsample large images
- Cache thumbnail versions
- Use proper image formats (HEIC for photos)

### 6.3 Background Task Handling

**Background Refresh**:
```swift
// If needed for data sync
func scheduleBackgroundRefresh() {
    BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.app.refresh",
        using: nil
    ) { task in
        self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
    }
}
```

**Background URLSession**:
- For large downloads/uploads
- Continues even if app terminated
- Implement URLSessionDelegate

### 6.4 Launch Time Optimization

**Strategies**:
- Minimize work in app launch path
- Defer heavy operations to background
- Use lazy initialization
- Optimize image assets
- Remove unused frameworks

---

## 7. Testing Strategy

### 7.1 Unit Testing

**Coverage Target**: 70%+ for business logic

**What to Test**:
- ViewModels: All business logic methods
- Services: API calls, data transformations
- Models: Validation logic, computed properties
- Utilities: Pure functions

**Testing Framework**: XCTest

**Example**:
```swift
import XCTest
@testable import [AppName]

final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockAPIClient: MockAPIClient!
    var mockDataManager: MockDataManager!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        mockDataManager = MockDataManager()
        sut = HomeViewModel(
            apiClient: mockAPIClient,
            dataManager: mockDataManager
        )
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        mockDataManager = nil
        super.tearDown()
    }

    func testLoadItems_Success() async throws {
        // Given
        let expectedItems = [Item(id: UUID(), name: "Test")]
        mockAPIClient.itemsToReturn = expectedItems

        // When
        await sut.loadItems()

        // Then
        XCTAssertEqual(sut.items, expectedItems)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showError)
    }

    func testLoadItems_Failure() async throws {
        // Given
        mockAPIClient.shouldThrowError = true

        // When
        await sut.loadItems()

        // Then
        XCTAssertTrue(sut.showError)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.items.isEmpty)
    }
}
```

### 7.2 UI Testing

**Coverage Target**: Critical user journeys only (~10% of tests)

**What to Test**:
- Onboarding flow
- Core feature happy paths
- Error state handling
- Navigation flows

**Framework**: XCTest with XCUITest

**Best Practices**:
- Use accessibility identifiers
- Test user-facing behavior, not implementation
- Keep tests independent
- Use test plans for different configurations

### 7.3 Integration Testing

**What to Test**:
- API integration (with mock backend or staging)
- SwiftData CRUD operations
- Background tasks
- Deep linking

### 7.4 Mocking Strategy

**Mock Types**:
- Protocol-based mocks for dependencies
- In-memory storage for tests
- Mock API client with canned responses

**Dependency Injection**:
- Use initializer injection for testability
- Provide default values for production
- Override with mocks in tests

---

## 8. Deployment & DevOps

### 8.1 Build Configurations

**Debug**:
- Optimization: None (-Onone)
- Assertions: Enabled
- Logging: Verbose
- API endpoint: Development/Staging
- Crashlytics: Disabled

**Release**:
- Optimization: Speed (-O)
- Assertions: Disabled
- Logging: Errors only
- API endpoint: Production
- Crashlytics: Enabled
- Strip debug symbols: Yes

### 8.2 Environment Management

**Configuration**:
```swift
enum Environment {
    case development
    case staging
    case production

    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    var apiBaseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://dev.api.example.com")!
        case .staging:
            return URL(string: "https://staging.api.example.com")!
        case .production:
            return URL(string: "https://api.example.com")!
        }
    }
}
```

### 8.3 CI/CD

**Recommended**: Xcode Cloud or GitHub Actions

**Pipeline Stages**:
1. **On Pull Request**:
   - Run SwiftLint
   - Build project
   - Run unit tests
   - Generate code coverage report

2. **On Merge to Main**:
   - Full test suite (unit + UI)
   - Build release configuration
   - Archive build

3. **On Tag** (e.g., v1.0.0):
   - Build release
   - Upload to TestFlight
   - Create GitHub release

**Example GitHub Actions** (placeholder):
```yaml
name: CI
on: [pull_request, push]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and Test
        run: |
          xcodebuild clean build test \
            -scheme [AppName] \
            -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 8.4 Feature Flags

**Implementation**: (If needed for gradual rollouts)
- Use remote config (Firebase Remote Config, Launch Darkly, or custom)
- Local override for testing
- A/B testing capability

---

## 9. Technical Risks & Mitigations

### Risk 1: SwiftData Maturity (iOS 17+ framework)

**Risk**: SwiftData is relatively new, may have bugs or limitations
**Impact**: Data loss, migration issues, performance problems
**Probability**: Medium
**Mitigation**:
- Thorough testing of CRUD operations
- Implement backup mechanism
- Have Core Data migration path ready as fallback
- Monitor SwiftData-related crashes closely
**Fallback**: Migrate to Core Data if critical issues found

### Risk 2: iOS 17+ Minimum Version

**Risk**: Limits addressable market (older iOS versions excluded)
**Impact**: Reduced potential user base
**Probability**: Certain
**Mitigation**:
- Validate market data (% of users on iOS 17+)
- Accept trade-off for modern APIs
- Plan for iOS 16 support in future if needed
**Decision**: Accept for MVP, modern APIs worth the trade-off

### Risk 3: Network Dependency

**Risk**: App requires network for most features
**Impact**: Poor user experience in offline scenarios
**Probability**: High
**Mitigation**:
- Implement robust offline support with local caching
- Sync when network available
- Clear messaging when offline
- Core features work offline where possible
**Fallback**: None - core to architecture

### Risk 4: Third-Party API Reliability

**Risk**: Backend API downtime or rate limiting
**Impact**: App functionality degraded
**Probability**: Low-Medium
**Mitigation**:
- Implement proper error handling
- Retry logic with exponential backoff
- Cache responses locally
- Graceful degradation
- Monitor API health

---

## 10. Future Considerations

### Phase 2 Enhancements

**After MVP Launch**:
1. **iPad Support**: Adapt layouts for larger screens
2. **macOS Catalyst**: Cross-platform desktop version
3. **Widgets**: Home screen and Lock screen widgets
4. **Watch App**: Companion watchOS app
5. **App Clips**: Lightweight app clip for quick access
6. **CloudKit Sync**: Cross-device synchronization
7. **Offline-First**: Enhance offline capabilities
8. **Performance**: Optimize based on real-world metrics
9. **Accessibility**: Enhanced VoiceOver support, keyboard shortcuts
10. **Localization**: Additional languages

### Technology Updates

**Monitor**:
- SwiftUI updates in future iOS versions
- SwiftData improvements and bug fixes
- New Apple frameworks (announced at WWDC)
- Swift language evolution proposals

---

## 11. Documentation & Knowledge Sharing

**Code Documentation**:
- Use Swift DocC comments for public APIs
- Document complex algorithms
- Keep README updated
- Maintain CHANGELOG

**Architecture Decision Records (ADRs)**:
- Document major architectural decisions
- Include context, options considered, decision, consequences
- Store in docs/architecture/decisions/

**Onboarding**:
- Architecture overview for new developers
- Setup guide (README.md)
- Coding standards document
- PR review checklist

---

## 12. Success Metrics

**Technical KPIs**:
- Crash-free rate: > 99.5%
- App launch time (cold): < 1.5s
- App launch time (warm): < 0.5s
- Network request latency (95th percentile): < 2s
- Test coverage: > 70% for business logic
- Build time: < 10 minutes (for CI)

**Monitoring**:
- Crashlytics / Firebase Crashlytics
- Performance monitoring (Xcode Organizer, MetricKit)
- Network monitoring (URLSession metrics)
- Custom analytics (if needed)

---

## Appendix A: Coding Standards

### Swift Style Guide
- Follow [Swift.org API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for consistency
- Naming conventions:
  - Types: PascalCase
  - Variables/functions: camelCase
  - Constants: camelCase (not SCREAMING_SNAKE_CASE)

### SwiftUI Best Practices
- Keep views small and focused
- Extract subviews for reusability
- Use @ViewBuilder for custom DSLs
- Prefer property wrappers (@State, @Binding) over manual management

### Concurrency
- Always use async/await over completion handlers
- Mark UI updates with @MainActor
- Use actors for thread-safe shared state
- Avoid @unchecked Sendable unless necessary

---

## Appendix B: Reference Links

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

**Document History**:
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | [Date] | [Name] | Initial architecture design |

```

## Execution Instructions

When activated, follow these steps:

1. **Read PRD**
   ```
   Read docs/PRD.md
   Extract:
   - Core features and complexity level
   - Non-functional requirements
   - Platform requirements (iOS version)
   - Data model hints from user stories
   - Technical requirements section
   ```

2. **Assess Complexity**
   - Simple (1-3 core features, basic CRUD): MVVM with SwiftUI
   - Medium (4-8 features, some complexity): MVVM or Clean Architecture
   - Complex (9+ features, high complexity): Clean Architecture or TCA

3. **Make Technology Decisions**
   Based on PRD requirements and iOS version target:
   - iOS 17+ → SwiftUI + SwiftData + @Observable (recommended)
   - iOS 16+ → SwiftUI + Core Data + Combine
   - UIKit → Only if strong reason (legacy, specific UI needs)

4. **Ask User Preferences** (if needed)
   ```
   Quick questions about the architecture:

   1. Do you have a preference for UI framework?
      - SwiftUI (modern, recommended for iOS 17+)
      - UIKit (if you need more control or have existing UIKit code)

   2. Do you have a backend API already?
      - Yes → Focus on networking layer
      - No → Focus on local-first architecture

   3. Any required third-party libraries?
      - List them, or say "minimize dependencies"
   ```

5. **Create Output Directory**
   ```bash
   mkdir -p docs
   ```

6. **Generate ARCHITECTURE.md**
   - Use template above
   - Fill in all sections with specific, opinionated choices
   - Make architectural decisions and explain reasoning
   - Design data models based on PRD features
   - Define complete module structure

7. **Write to File**
   ```
   Write to: docs/ARCHITECTURE.md
   ```

8. **Present Summary**
   ```
   ✅ Technical Architecture generated!

   🏗️ **Architecture Summary**:
   - Document: docs/ARCHITECTURE.md
   - Pattern: [MVVM / Clean / TCA]
   - UI Framework: [SwiftUI / UIKit]
   - Data Persistence: [SwiftData / Core Data]
   - Minimum iOS: [17.0 / 16.0 / 15.0]
   - Third-party deps: [X] (or "None - Apple frameworks only")
   - Data models: [X] entities defined

   **Key Decisions**:
   1. [Decision 1]: [Choice] - [Reason]
   2. [Decision 2]: [Choice] - [Reason]
   3. [Decision 3]: [Choice] - [Reason]

   **Next Steps**:
   1. Review the architecture in docs/ARCHITECTURE.md
   2. Confirm technology stack choices
   3. Once approved, we can proceed to UX spec

   Any questions or changes to the architecture?
   ```

9. **Iterate if Needed**
   - If user wants different tech stack, regenerate relevant sections
   - If user disagrees with pattern choice, explain and offer alternative
   - Update document with changes

## Quality Guidelines

1. **Be Opinionated**: Make clear technology choices
   - BAD: "You could use SwiftUI or UIKit"
   - GOOD: "Using SwiftUI because iOS 17+ target allows modern APIs and declarative UI is more maintainable"

2. **Explain Reasoning**: Every major decision should have rationale
   - Why this architecture pattern?
   - Why these frameworks?
   - Why these trade-offs?

3. **Be Specific**: Provide actual code examples
   - Show data model structure
   - Show networking client design
   - Show ViewModel pattern

4. **Consider Trade-offs**: Document risks and mitigations
   - What could go wrong?
   - How do we handle it?
   - What's the backup plan?

5. **Stay Current**: Use modern Swift and iOS features
   - iOS 17+: SwiftData, @Observable, ContentUnavailableView
   - async/await over completion handlers
   - Actors for thread safety

6. **Follow Apple HIG**: Architecture should enable HIG compliance
   - Native patterns (NavigationStack, TabView)
   - Platform conventions
   - Accessibility built-in

## Integration with Workflow

This skill is typically:
- **Second step** in implementation specification generation (after prd-generator)
- Activated after PRD is approved
- Followed by ux-spec, implementation-guide, test-spec, release-spec

The architecture document guides all downstream technical decisions.

## Notes

- Be pragmatic: Choose technologies that fit the problem
- Start simple: MVVM + SwiftUI + SwiftData is a great default
- Document decisions: Future developers will thank you
- Consider team skills: If team is UIKit-expert, maybe stick with UIKit
- Balance modern vs stable: Bleeding edge isn't always best
- MVP mindset: Perfect is enemy of shipped

### Source: `product/competitive-analysis`

# Competitive Analysis Skill

Performs deep competitive analysis for iOS/macOS app ideas. Goes beyond basic discovery to provide detailed competitor insights, feature matrices, and differentiation opportunities.

## When This Skill Activates

Use this Skill when the user wants to:
- Understand competitors in detail
- Compare features across competitors
- Analyze competitor pricing strategies
- Identify competitive strengths/weaknesses
- Find differentiation opportunities
- Map market positioning
- Deep-dive after initial problem discovery

**This is a follow-up to the product-agent skill** — use this when you need more competitive depth.

## What This Skill Does

### 1. Competitor Identification
- Identifies direct and indirect competitors
- Categorizes by market position (leaders, challengers, niche)
- Includes App Store rankings and ratings

### 2. Feature Comparison
- Creates feature comparison matrix
- Identifies unique features per competitor
- Highlights feature gaps (opportunities)

### 3. Pricing Analysis
- Compares pricing models (free, paid, subscription, freemium)
- Analyzes price points
- Identifies pricing strategies

### 4. SWOT Analysis
- Strengths of each competitor
- Weaknesses and limitations
- Opportunities for differentiation
- Threats to new entrants

### 5. Market Positioning
- How competitors position themselves
- Target audience differences
- Brand messaging analysis

### 6. Differentiation Strategy
- **Key output:** How to be different
- Feature gaps in market
- Underserved user segments
- Unique value propositions

## How to Use

### Basic Usage

Start with the **product-agent** skill for baseline problem discovery, then enhance with deep competitor research using WebSearch and WebFetch.

### Workflow

1. **Start with discovery** using the product-agent skill to identify competitors. Extract the `current_solutions` field for the competitor list.

2. **Research each competitor** using WebSearch/WebFetch:
   - Search for "[competitor name] app features"
   - Search for "[competitor name] pricing"
   - Fetch their App Store page
   - Fetch their website

3. **Create comparison matrix** from gathered data

4. **Identify differentiation opportunities** based on gaps

## Output Structure

When performing competitive analysis, create this structure:

```json
{
  "competitors": [
    {
      "name": "Competitor Name",
      "category": "market_leader | challenger | niche",
      "app_store_rating": "4.5/5",
      "downloads": "estimated range",
      "pricing": {
        "model": "subscription | one-time | freemium",
        "price": "$X/month or $Y one-time",
        "tiers": ["free", "pro", "business"]
      },
      "key_features": [
        "Feature 1",
        "Feature 2"
      ],
      "unique_features": [
        "Feature only they have"
      ],
      "strengths": [
        "What they do well"
      ],
      "weaknesses": [
        "What they lack or do poorly"
      ],
      "target_audience": "Who they target",
      "positioning": "How they position themselves"
    }
  ],
  "feature_matrix": {
    "Feature A": {"Competitor1": true, "Competitor2": false, "Competitor3": true},
    "Feature B": {"Competitor1": false, "Competitor2": true, "Competitor3": true}
  },
  "feature_gaps": [
    "Feature nobody offers well",
    "Feature with poor implementation across board"
  ],
  "pricing_insights": {
    "average_price": "$X",
    "pricing_range": "$Y - $Z",
    "common_model": "subscription",
    "pricing_gaps": ["No good free tier", "No lifetime option"]
  },
  "differentiation_opportunities": [
    {
      "opportunity": "AI-powered feature X",
      "reasoning": "None of the competitors do this well",
      "potential_impact": "high | medium | low"
    }
  ],
  "market_positioning_map": {
    "axes": ["Price (low to high)", "Features (simple to complex)"],
    "competitors": [
      {"name": "Competitor1", "position": [3, 8]},
      {"name": "Competitor2", "position": [8, 9]}
    ],
    "opportunity_quadrant": "Low price, high features"
  },
  "recommendation": "Strategic positioning recommendation"
}
```

## Best Practices

### 1. Start Broad, Then Focus

```
Step 1: Use product-agent skill to identify competitors
Step 2: Pick top 3-5 most relevant competitors
Step 3: Deep dive on each using web research
Step 4: Create comparison matrix
```

### 2. Look Beyond Direct Competitors

Include:
- **Direct competitors:** Same problem, same solution
- **Indirect competitors:** Same problem, different solution
- **Alternative solutions:** How users solve this today without apps

### 3. Focus on Actionable Insights

Don't just list features. Answer:
- **What can we do better?**
- **What gaps exist?**
- **Where can we differentiate?**

### 4. Verify with App Store Data

When analyzing iOS/macOS apps:
- Check App Store ratings
- Read recent reviews (last 3 months)
- Note update frequency
- Check developer responsiveness

### 5. Pricing Intelligence

Understand:
- How competitors monetize
- What features are behind paywall
- Trial periods and refund policies
- Upgrade paths

## Example Analysis Flow

**User asks:** "Do competitive analysis for task management apps"

**You do:**

1. **Initial Discovery**

   Run the product-agent skill with the idea "Task management app with AI prioritization."

   Result: Identifies Todoist, Things, OmniFocus, TickTick as main competitors

2. **Deep Research Each Competitor**

   For Todoist:
   - WebSearch: "Todoist features list 2026"
   - WebFetch: https://todoist.com/features
   - WebSearch: "Todoist pricing 2026"
   - WebFetch: https://todoist.com/pricing
   - WebSearch: "Todoist app store reviews"

   Repeat for Things, OmniFocus, TickTick

3. **Create Feature Matrix**

   | Feature | Todoist | Things | OmniFocus | TickTick |
   |---------|---------|--------|-----------|----------|
   | Subtasks | ✓ | ✓ | ✓ | ✓ |
   | AI Prioritization | ✗ | ✗ | ✗ | ✗ |
   | Calendar Integration | ✓ | ✓ | ✓ | ✓ |
   | Natural Language Input | ✓ | ✗ | ✗ | ✓ |

4. **Identify Gaps**
   - AI prioritization: Nobody does it well
   - Smart scheduling: Limited implementations
   - Context-aware suggestions: Missing entirely

5. **Present Findings**
   ```
   Competitive Analysis: Task Management Apps

   **Top 4 Competitors:**
   1. Todoist (Market Leader) - $4/mo, strong features, weak AI
   2. Things (Premium) - $50 one-time, beautiful UI, limited power features
   3. OmniFocus (Power Users) - $100 one-time, complex, steep learning curve
   4. TickTick (Budget) - $2/mo, feature-rich, less polished

   **Feature Gaps (Opportunities):**
   1. AI-powered prioritization - None do this well
   2. Context-aware task suggestions - Missing
   3. Smart deadline suggestions - Limited

   **Differentiation Strategy:**
   Position as "AI-first task manager" with:
   - Automatic prioritization based on context
   - Smart deadline suggestions
   - Learning from user behavior

   **Pricing Recommendation:**
   $3-4/month (between TickTick and Todoist)
   Free tier with core features to build user base
   ```

## Common Pitfalls to Avoid

### ❌ Don't Just List Competitors
```
Bad: "Competitors are Todoist, Things, OmniFocus"
Good: "Todoist leads with 30% market share at $4/mo, strong in
      collaboration but weak in AI features..."
```

### ❌ Don't Ignore Indirect Competition
```
Bad: Only analyzing dedicated task apps
Good: Also include: Notion (general productivity), Apple Reminders
      (free built-in), pen and paper (no-tech solution)
```

### ❌ Don't Skip Pricing Analysis
```
Bad: "They have a subscription"
Good: "Freemium model with $4/mo premium. 70% on free tier,
      30% convert to paid. Premium unlocks collaboration and integrations."
```

### ❌ Don't Forget the "So What?"
```
Bad: "Competitor X has feature Y"
Good: "Competitor X has feature Y, but it's poorly implemented
      (3.2/5 rating in reviews). This is an opportunity to do it better."
```

## Integration with Other Skills

This Skill works best **after** using the product-agent skill:

```
1. product-agent → Quick validation (problem discovery)
2. competitive-analysis → Deep competitor insights
3. market-research → Market size and opportunity
4. MVP scoping → What to build based on competitive gaps
```

## Tips for Effective Analysis

1. **Recent Data Only**: Focus on 2025-2026 data. Old reviews don't matter.

2. **User Voice**: Read actual user reviews. What do they complain about? What do they love?

3. **Pricing Psychology**: Don't just note prices. Understand the strategy:
   - Freemium = land and expand
   - One-time = premium positioning
   - Subscription = recurring revenue focus

4. **Feature vs. Benefit**: Map features to benefits:
   - "Subtasks" = Benefit: "Break big tasks into manageable steps"

5. **Market Position**: Understand where you fit:
   - Cheaper? Position as "affordable alternative"
   - Better? Position as "premium experience"
   - Simpler? Position as "easy to use"
   - Different? Position as "unique approach"

## When to Run This Analysis

**Perfect timing:**
- After initial discovery shows "MODERATE" or "STRONG" opportunity
- Before starting development (validate differentiation strategy)
- When planning features (fill competitive gaps)
- Before pricing decisions (market rate analysis)
- When pitching to investors (competitive landscape)

**Too early:**
- Before basic discovery (use the product-agent skill first)
- If discovery said "DON'T BUILD" (no point analyzing dead market)

**Too late:**
- After building MVP without checking competition (too late to differentiate)
- After pricing decision (should inform pricing)

## Deliverables

After running competitive analysis, you should have:

1. ✅ List of 3-5 main competitors with details
2. ✅ Feature comparison matrix
3. ✅ Pricing comparison table
4. ✅ SWOT for each competitor
5. ✅ 3-5 differentiation opportunities identified
6. ✅ Positioning recommendation
7. ✅ Pricing strategy recommendation

## Output File Location

Save competitive analysis results to one of these locations:
- `competitive-analysis.md` (project root)
- `docs/competitive-analysis.md` (if docs folder exists)

**Format**: Use the JSON structure in the Output Structure section, wrapped in a markdown code block.

**Integration**: The PRD generator skill will automatically look for this file and integrate the insights into the PRD's Competitive Context section.

## Follow-up Actions

Based on competitive analysis, next steps:

**If gaps found:**
- Proceed with MVP scoping
- Design features that fill gaps
- Position around differentiation

**If no clear gaps:**
- Consider pivoting idea
- Target different user segment
- Explore adjacent market

**If too competitive:**
- Find niche within market
- Bundle with other features
- Or abandon and try different idea

---

**Remember:** Competitive analysis should lead to action. The goal is not to document competitors, but to find your **unique wedge** into the market.

### Source: `product/idea-generator`

# Idea Generator Skill

Generates a ranked shortlist of 3-5 app ideas tailored to the developer's skills, interests, and constraints. Output is formatted to feed directly into the product-agent skill for validation.

## When This Skill Activates

Use this skill when the user:
- Doesn't have an app idea yet
- Says "what should I build?" or "I don't know what to build"
- Wants to brainstorm app ideas
- Is stuck after a previous idea was rejected or abandoned
- Wants to explore what's possible with a specific technology (e.g., "what can I build with Foundation Models?")
- Wants inspiration based on their skills or domain expertise
- Asks for a brainstorm session

**Already has a specific idea?** Skip this skill. Use the product-agent skill instead.

## What This Skill Does

### 1. Developer Profile Elicitation

Gathers context about the developer to personalize ideas:
- **Technical skills** — Languages, frameworks, platforms (Swift, SwiftUI, UIKit, CloudKit, etc.)
- **Domain interests** — Health, finance, productivity, education, creativity, etc.
- **Platform preference** — iOS, macOS, iPadOS, watchOS, visionOS, or multi-platform
- **Time availability** — Side project (5-10 hrs/week), full-time, weekend hack
- **Constraints** — Budget, backend experience, design skills, existing audience

### 2. Five Brainstorming Lenses

Each lens generates 5-8 raw ideas. Lenses are applied in order:

1. **Skills & Interests** — What can you uniquely build given what you know?
2. **Problem-First** — What took 30 seconds today that should take 5? What's annoying?
3. **Technology-First** — Which Apple frameworks have few indie apps? (Foundation Models, ActivityKit, WidgetKit, VisionKit, WeatherKit, MapKit)
4. **Market Gap** — Where are App Store categories underserved, stale, or overpriced?
5. **Trend-Based** — What macro trends create new app opportunities? (AI-native, privacy-first, health/wellness, single-use utilities, Apple Silicon productivity)

### 3. Feasibility Filtering

Each raw idea is evaluated against five filters:

| Filter | Question |
|--------|----------|
| Solo Dev Scope | Can one developer ship an MVP in 4-8 weeks? |
| Platform API Fit | Does this leverage Apple platform APIs well? |
| Monetization Viability | Is there a clear path to revenue? |
| Competition Density | How crowded is this space? |
| Technical Complexity | Does the developer have the skills to build this? |

### 4. Scoring and Ranking

Each surviving idea is scored across five dimensions:

| Dimension | WEAK (1-2) | MODERATE (3-5) | STRONG (6-8) | EXCELLENT (9-10) |
|-----------|------------|----------------|--------------|------------------|
| Solo Dev Scope | 6+ months | 3-6 months | 4-8 weeks | 2-4 weeks |
| Platform API Fit | Generic/cross-platform | Some native APIs | Good platform integration | Deep Apple API usage |
| Monetization | Unclear model | Ad-supported or low ARPU | Subscription viable | Premium pricing justified |
| Competition | Dominated by incumbents | Crowded but fragmented | Few quality options | Blue ocean |
| Technical Fit | Major skill gaps | Some learning needed | Good skill match | Perfect skill match |

**Overall Score** = weighted average on 1-10 scale (Solo Dev Scope and Technical Fit weighted 1.5x).

### 5. Shortlist Output

Final output is a ranked list of 3-5 ideas, each with:
- One-liner description
- Which lens generated it
- Problem statement and target user
- Feasibility scores
- Monetization model
- MVP scope estimate
- `next_step` description for feeding the idea into the product-agent skill

## Output Structure

```json
{
  "developer_profile": {
    "skills": ["Swift", "SwiftUI", "HealthKit", "Core Motion"],
    "interests": ["fitness", "wearables", "data visualization"],
    "platform": "iOS + watchOS",
    "time_availability": "side project (10 hrs/week)",
    "constraints": ["no backend experience", "solo developer"]
  },
  "brainstorm_lenses_used": [
    "skills_and_interests",
    "problem_first",
    "technology_first",
    "market_gap",
    "trend_based"
  ],
  "shortlist": [
    {
      "rank": 1,
      "idea": "Workout Recovery Timer",
      "lens": "skills_and_interests",
      "one_liner": "Apple Watch app that tracks heart rate recovery between sets and suggests optimal rest periods",
      "platform": "watchOS + iOS companion",
      "problem_statement": "Gym-goers either rest too long (wasting time) or too short (risking injury). No app uses real-time HR data to personalize rest periods.",
      "target_user": "Regular gym-goers who wear Apple Watch during workouts",
      "feasibility": {
        "solo_dev_scope": "STRONG (6 weeks — HealthKit + WatchKit + simple UI)",
        "platform_api_fit": "EXCELLENT (HealthKit, WorkoutKit, Live Activities)",
        "monetization_viability": "STRONG (subscription $3.99/mo — fitness users pay for tools)",
        "competition_density": "STRONG (few apps focus specifically on HR-based rest timing)",
        "technical_fit": "EXCELLENT (matches HealthKit + Core Motion skills)"
      },
      "overall_score": 8.4,
      "monetization_model": "Freemium — free with 3 workouts/week, $3.99/mo unlimited + insights",
      "competition_notes": "Strong Timer+ and Intervals Pro exist but focus on pre-set timers, not adaptive HR-based rest",
      "mvp_scope": "Watch app with HR monitoring during rest, vibration alert when ready, basic iOS companion for history",
      "next_step": "Run the product-agent skill with idea: 'Apple Watch app that tracks heart rate recovery between sets and suggests optimal rest periods based on real-time HR data' for watchOS + iOS"
    },
    {
      "rank": 2,
      "idea": "Walking Meetings Tracker",
      "lens": "problem_first",
      "one_liner": "Track steps, route, and calories during meetings — share walking meeting summaries with attendees",
      "platform": "iOS + watchOS",
      "problem_statement": "Walking meetings are popular for health but there's no way to track the health benefit or share it. Calendar apps don't connect to HealthKit.",
      "target_user": "Knowledge workers and managers who take walking meetings",
      "feasibility": {
        "solo_dev_scope": "STRONG (5 weeks — HealthKit + MapKit + Calendar integration)",
        "platform_api_fit": "EXCELLENT (HealthKit, MapKit, EventKit, WidgetKit)",
        "monetization_viability": "MODERATE (niche audience, $2.99 one-time or $1.99/mo)",
        "competition_density": "EXCELLENT (no dedicated walking meeting app exists)",
        "technical_fit": "STRONG (HealthKit skills transfer, MapKit is new but manageable)"
      },
      "overall_score": 7.6,
      "monetization_model": "One-time purchase $4.99 with optional $1.99/mo for team features",
      "competition_notes": "Pedometer apps exist but none integrate with calendar or frame walking as meetings",
      "mvp_scope": "Start/stop walking meeting, auto-detect from calendar, log steps + route, share summary",
      "next_step": "Run the product-agent skill with idea: 'iOS app that tracks steps, route, and calories during walking meetings and shares summaries with attendees' for iOS + watchOS"
    },
    {
      "rank": 3,
      "idea": "Gym Equipment Wait Time",
      "lens": "market_gap",
      "one_liner": "Crowdsourced gym equipment availability — see which machines are free before you go",
      "platform": "iOS",
      "problem_statement": "Gyms are crowded at peak hours. No way to know if the squat rack is free without going. Leads to wasted time and frustration.",
      "target_user": "Gym members at commercial gyms (Planet Fitness, LA Fitness, Equinox)",
      "feasibility": {
        "solo_dev_scope": "MODERATE (8 weeks — needs crowdsource mechanics and gym database)",
        "platform_api_fit": "MODERATE (MapKit for gym location, but core logic is custom)",
        "monetization_viability": "STRONG (subscription or gym partnership revenue)",
        "competition_density": "STRONG (no quality solution exists — GymBook is workout logging, not availability)",
        "technical_fit": "MODERATE (needs backend for crowdsource data — outside current skills)"
      },
      "overall_score": 6.8,
      "monetization_model": "Freemium — free for 1 gym, $2.99/mo for multiple gyms + predictions",
      "competition_notes": "Some gyms have their own capacity apps but no cross-gym equipment-level tracking exists",
      "mvp_scope": "Single gym support, manual check-in/check-out for equipment, peak time predictions",
      "next_step": "Run the product-agent skill with idea: 'Crowdsourced gym equipment availability app that shows which machines are free at your gym' for iOS"
    }
  ],
  "ideas_filtered_out": [
    {
      "idea": "AI Personal Trainer",
      "lens": "technology_first",
      "reason": "Extremely competitive (Fitbod, Future, Hevy). Would need 6+ months to differentiate. Failed solo_dev_scope filter."
    },
    {
      "idea": "Sleep Architecture Analyzer",
      "lens": "trend_based",
      "reason": "Apple's own sleep tracking in watchOS 10+ covers most of this. Failed competition_density filter — competing with platform owner."
    }
  ],
  "recommendation": "Start with Rank 1 (Workout Recovery Timer). It scores highest, leverages your exact skills (HealthKit + Core Motion), has a clear monetization path, and can ship in 6 weeks. Run the product-agent skill to validate the problem before committing."
}
```

## How to Generate Ideas

### Step 1: Gather Developer Profile

If the user hasn't provided context, ask using AskUserQuestion:

**Questions to ask:**
- What programming languages and frameworks do you know? (Swift, SwiftUI, UIKit, etc.)
- What topics or domains interest you? (health, finance, productivity, etc.)
- Which Apple platforms do you want to target?
- How much time can you dedicate? (side project, full-time, weekend hack)
- Any constraints? (no backend, solo dev, no design skills, etc.)

If the user provides partial info, infer reasonable defaults and state assumptions.

### Step 2: Apply Skills & Interests Lens

Generate 5-8 ideas from the intersection of what the developer knows and cares about.

**Process:**
1. List the developer's top 3-5 skills
2. List their top 3-5 interests
3. For each skill-interest pair, ask: "What app could a developer with [skill] build for people interested in [interest]?"
4. Prefer ideas that use 2+ of their skills simultaneously

**Example:** Swift + HealthKit + fitness interest → workout recovery timer, exercise form checker, fitness challenge app

### Step 3: Apply Problem-First Lens

Find real problems worth solving.

**Process:**
1. Ask the developer: "What took 30 seconds today that should take 5?"
2. Think about common daily friction points in their domain
3. Search for complaint threads: `"[domain] app sucks" OR "[domain] app wish" site:reddit.com`
4. Look for manual processes people do with spreadsheets or notes

**Example:** "I always forget which supplements I took" → supplement tracking app

### Step 4: Apply Technology-First Lens

Identify Apple frameworks with few quality indie apps.

**High-opportunity frameworks (2026):**
- **Foundation Models** — On-device LLM, few indie apps yet
- **ActivityKit / Live Activities** — Sports, cooking, transit, workout tracking
- **WidgetKit** — Glanceable info apps (many categories underserved)
- **VisionKit** — Document scanning, text recognition, visual lookup
- **WeatherKit** — Hyper-local weather for niche use cases
- **SensorKit / Core Motion** — Movement, posture, activity detection
- **DeviceActivity / Screen Time API** — Digital wellness, parental controls

**Process:**
1. Pick 2-3 frameworks matching the developer's platform preference
2. Search App Store for apps using that framework
3. Identify gaps — what should exist but doesn't?

### Step 5: Apply Market Gap Lens

Use WebSearch to find underserved App Store categories.

**Searches to run:**
```
"underserved App Store categories 2026"
"indie app opportunities iOS 2026"
"App Store category [domain] top apps" (check staleness)
"[category] app reviews complaints" site:reddit.com
```

**Signals of opportunity:**
- Top apps haven't been updated in 12+ months
- Reviews complain about the same issues across multiple apps
- Premium pricing ($9.99+) with mediocre ratings (< 4.0)
- Category has few apps but clear demand

### Step 6: Apply Trend Lens

Identify macro trends creating new app opportunities.

**Current trends (2026):**
- **AI-native apps** — Apps that couldn't exist without on-device AI
- **Privacy-first** — Apps that explicitly don't collect data (selling point)
- **Health & wellness** — Mental health, sleep, nutrition, fitness
- **Single-use utilities** — Do one thing exceptionally well
- **Apple Silicon productivity** — Pro tools for Mac (M-series GPU, Neural Engine)
- **Aging population** — Accessibility, health monitoring, simplified tech
- **Creator economy** — Tools for content creators, freelancers

**Process:**
1. Pick 2-3 trends relevant to the developer's interests
2. For each trend, generate 2-3 ideas that serve the trend
3. Prefer trend + skill intersections

### Step 7: Filter, Score, and Rank

**Filter phase:**
1. Collect all raw ideas from Steps 2-6 (typically 25-40 ideas)
2. Apply the five feasibility filters (see Section 3)
3. Remove any idea that scores WEAK on Solo Dev Scope or Technical Fit
4. Remove any idea that scores WEAK on 3+ dimensions

**Score phase:**
1. Score each surviving idea on all five dimensions
2. Calculate overall score (Solo Dev Scope and Technical Fit weighted 1.5x)
3. Rank by overall score descending

**Output phase:**
1. Take the top 3-5 ideas
2. Write full entries with all fields from Output Structure
3. Format `next_step` as description for the product-agent skill
4. List 1-3 filtered-out ideas with reasons
5. Write a recommendation highlighting Rank 1 and why

## End-to-End Example

**Developer profile:**
> Maya, backend engineer (Python, some Swift), interested in nutrition and cooking. Wants to build her first iOS app as a side project (8 hrs/week). No design skills. Comfortable with APIs but no HealthKit experience.

**Lens application:**

1. **Skills & Interests →** Recipe nutrition calculator (Swift + API skills + nutrition interest), meal prep planner, ingredient substitution finder
2. **Problem-First →** "I never know if my meals hit my protein target" → macro tracker that works from photos, "grocery lists from recipes are always wrong" → smart grocery list
3. **Technology-First →** Foundation Models → describe leftovers and get recipe suggestions, VisionKit → scan nutrition labels and auto-log
4. **Market Gap →** Searched "nutrition app complaints reddit" → users hate manual food logging, want simpler interfaces, tired of ads in free tier
5. **Trend →** AI-native + health/wellness → on-device food recognition, privacy-first nutrition tracking (no cloud data)

**After filtering and scoring:**

| Rank | Idea | Score | Key Strength |
|------|------|-------|-------------|
| 1 | AI Leftover Recipe Finder | 8.1 | Foundation Models + cooking interest, blue ocean |
| 2 | Photo Macro Tracker | 7.4 | Problem-first (everyone hates manual logging) |
| 3 | Smart Grocery List | 6.9 | Simple scope, clear monetization |

**Recommendation:** "Start with AI Leftover Recipe Finder. It uses Foundation Models (few competitors), aligns with your cooking interest, and can ship a basic version in 5 weeks. Run the product-agent skill to validate demand."

## Integration with Other Skills

```
Phase 0: idea-generator (THIS SKILL)
    ↓ pick 1 idea from shortlist
Phase 1: product-agent → validate the problem
    ↓
Phase 2: market-research / competitive-analysis → size the opportunity
    ↓
Phase 3: prd-generator → define features
    ↓
Phase 4: architecture-spec → technical design
    ↓
Phase 5+: ux-spec, implementation-guide, test-spec, release-spec
```

The `next_step` field in each shortlist entry describes what to feed into the product-agent skill. After the user picks their favorite idea, they can run it directly to kick off Phase 1 validation.

## When NOT to Use This Skill

- **Already has a specific idea** — Go directly to the product-agent skill
- **Already validated an idea** — Go to `market-research` or `competitive-analysis`
- **Wants code generation** — Use the `generators/` skills
- **Building to learn only** — Skip feasibility filtering; just pick what's fun
- **Hard deadline** — Skip brainstorming; go straight to the product-agent skill with whatever idea you have

## Deliverables

At the end of this skill, you should have:

- [ ] Developer profile captured (skills, interests, platform, time, constraints)
- [ ] All 5 brainstorming lenses applied
- [ ] Feasibility filtering applied (5 filters)
- [ ] Shortlist of 3-5 ideas with full scoring
- [ ] Ideas ranked by overall_score (highest first)
- [ ] Each idea has `next_step` for the product-agent skill
- [ ] Filtered-out ideas listed with reasons
- [ ] Recommendation paragraph highlighting Rank 1

## Output File Location

Save results to:
- `idea-shortlist.json` (project root)

**Format:** Use the JSON structure from the Output Structure section.

**Next action:** Feed Rank 1 into the product-agent skill using the `next_step` description.

---

**Generate fast, filter ruthlessly, validate before committing.** The best app idea is the one that matches your skills, solves a real problem, and can ship in weeks — not months.

### Source: `product/implementation-guide`

# Implementation Guide Skill

Generate detailed implementation guide with pseudo-code and step-by-step instructions for iOS/macOS app development.

## Metadata
- **Name**: implementation-guide
- **Version**: 1.0.0
- **Role**: Senior iOS/macOS Developer
- **Author**: ProductAgent Team

## When This Skill Activates

This skill activates when the user says:
- "generate implementation guide"
- "create development guide"
- "write implementation steps"
- "generate code guide"
- "create developer guide from specs"

## Description

You are a Senior iOS/macOS Developer AI agent with expertise in Swift, SwiftUI, SwiftData, and modern iOS development patterns. Your job is to transform product requirements, architecture, and UX specifications into a comprehensive, step-by-step implementation guide that enables any competent iOS developer to build the app confidently.

## Prerequisites

Before activating this skill, ensure:
1. PRD exists (from prd-generator skill) with all features defined
2. ARCHITECTURE.md exists (from architecture-spec skill) with tech stack and structure
3. UX_SPEC.md exists (from ux-spec skill) with wireframes and interactions
4. DESIGN_SYSTEM.md exists with colors, typography, components

## Input Sources

Read and extract information from:

1. **docs/PRD.md**
   - All features and user stories
   - Acceptance criteria
   - Success metrics
   - Timeline estimates

2. **docs/ARCHITECTURE.md**
   - Architecture pattern (MVVM, Clean, TCA)
   - Technology stack decisions
   - Data models and relationships
   - Module structure
   - Networking layer design

3. **docs/UX_SPEC.md**
   - All screens and wireframes
   - User flows
   - Interactions and gestures
   - States (empty, loading, error)

4. **docs/DESIGN_SYSTEM.md**
   - Colors, typography, spacing
   - Component styles
   - Animation timings
   - Design tokens

5. **User clarifications** (ask if needed):
   - Xcode version / minimum iOS version preferences
   - Any existing codebase to integrate with
   - CI/CD preferences (Xcode Cloud, GitHub Actions, Fastlane)

## Output

Generate: **docs/IMPLEMENTATION_GUIDE.md**

Structure (comprehensive, ~3000-5000 lines):

```markdown
# Implementation Guide: [App Name]

**Version**: 1.0.0
**Last Updated**: [Date]
**Platform**: iOS [Version]+
**Language**: Swift 5.9+
**Framework**: SwiftUI
**Xcode**: 15.0+

---

## 0. Quick Start

For the impatient developer:

```bash
# 1. Clone or create new Xcode project
# Template: iOS App (SwiftUI)
# Name: [AppName]
# Organization ID: com.yourcompany.appname
# Language: Swift
# Storage: SwiftData
# Include Tests: Yes

# 2. Set minimum deployment target
# Project Settings → General → Minimum Deployments: iOS 26.0 (or iOS 17+ for broader reach)

# 3. Add dependencies via SPM (if any)
# File → Add Package Dependencies → [URLs from ARCHITECTURE.md]

# 4. Create folder structure (see Section 2)

# 5. Follow implementation phases (Section 3)

# 6. Run tests frequently
xcodebuild test -scheme [AppName]

# 7. Launch and iterate
```

**Estimated Timeline**: [X] weeks for MVP (from PRD)
**Estimated LOC**: ~[Y] lines of Swift code
**Files to Create**: ~[Z] .swift files

---

## 1. Project Setup

### 1.1 Create Xcode Project

1. Open Xcode 15+
2. File → New → Project
3. Choose template: **iOS → App**
4. Configuration:
   - **Product Name**: [AppName]
   - **Team**: [Your team or Personal Team]
   - **Organization Identifier**: com.yourcompany.appname
   - **Bundle Identifier**: [Auto-generated]
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData [or Core Data based on ARCHITECTURE]
   - **Include Tests**: ✅ Yes
   - **Create Git repository**: ✅ Optional but recommended

5. Click Create

### 1.2 Project Configuration

**File**: Select project in Navigator → General tab

**Deployment Info**:
- **Minimum Deployments**: iOS 26.0 [adjust based on ARCHITECTURE — iOS 17+ still supported for broader reach]
- **Supported Destinations**: iPhone (✅), iPad (based on requirements)
- **Device Orientation**:
  - Portrait (✅ Required)
  - Landscape Left (based on requirements)
  - Landscape Right (based on requirements)

**App Icons & Launch Screen**:
- **App Icon**: Add 1024x1024 icon to Assets.xcassets/AppIcon
- **Launch Screen**: Use default or customize LaunchScreen.storyboard

**Signing & Capabilities**:
- **Team**: Select your development team
- **Signing Certificate**: Automatically manage signing (recommended)
- **Capabilities**: Add as needed:
  - Push Notifications (if required)
  - iCloud (if using CloudKit sync)
  - Background Modes (if needed)

### 1.3 Add Dependencies (if any)

**From ARCHITECTURE.md**, add these packages:

**Example** (adjust based on actual ARCHITECTURE):
```
File → Add Package Dependencies

[If networking library needed]
1. Alamofire: https://github.com/Alamofire/Alamofire
   Version: 5.9.0+

[If image loading needed]
2. Kingfisher: https://github.com/onevcat/Kingfisher
   Version: 7.10.0+

[Add only packages specified in ARCHITECTURE.md]
```

**Important**: Minimize third-party dependencies. Use native frameworks when possible.

### 1.4 Configure SwiftData

**File**: [AppName]App.swift

```swift
import SwiftUI
import SwiftData

@main
struct AppNameApp: App {
    // Define the data model container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // List all @Model classes here
            User.self,
            Item.self,
            // Add all data models from ARCHITECTURE.md
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false  // Persist to disk
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

---

## 2. File Structure

Create this folder hierarchy in your project:

```
[AppName]/
├── App/
│   ├── [AppName]App.swift           # Entry point
│   └── ContentView.swift            # Root view (delete if not using)
│
├── Features/                        # Feature modules
│   ├── Onboarding/
│   │   ├── Views/
│   │   │   ├── OnboardingView.swift
│   │   │   ├── OnboardingStep1View.swift
│   │   │   └── OnboardingStep2View.swift
│   │   └── ViewModels/
│   │       └── OnboardingViewModel.swift
│   │
│   ├── Home/
│   │   ├── Views/
│   │   │   ├── HomeView.swift
│   │   │   ├── HomeCardView.swift
│   │   │   └── HomeEmptyStateView.swift
│   │   ├── ViewModels/
│   │   │   └── HomeViewModel.swift
│   │   └── Models/
│   │       └── HomeFilter.swift         # View-specific models
│   │
│   ├── ItemDetail/
│   │   ├── Views/
│   │   │   ├── ItemDetailView.swift
│   │   │   └── ItemDetailHeaderView.swift
│   │   └── ViewModels/
│   │       └── ItemDetailViewModel.swift
│   │
│   ├── AddEditItem/
│   │   ├── Views/
│   │   │   └── AddEditItemView.swift
│   │   └── ViewModels/
│   │       └── AddEditItemViewModel.swift
│   │
│   └── Settings/
│       ├── Views/
│       │   ├── SettingsView.swift
│       │   └── AccountView.swift
│       └── ViewModels/
│           └── SettingsViewModel.swift
│
├── Core/                            # Shared infrastructure
│   ├── Networking/
│   │   ├── APIClient.swift          # Base HTTP client
│   │   ├── Endpoint.swift           # API endpoint definitions
│   │   ├── NetworkError.swift       # Error types
│   │   └── APIService.swift         # High-level API service
│   │
│   ├── Storage/
│   │   ├── DataManager.swift        # SwiftData operations wrapper
│   │   └── CacheManager.swift       # Optional: in-memory cache
│   │
│   ├── Extensions/
│   │   ├── View+Extensions.swift    # SwiftUI view modifiers
│   │   ├── Color+Extensions.swift   # Design system colors
│   │   ├── Font+Extensions.swift    # Custom font extensions
│   │   └── Date+Extensions.swift    # Date formatting
│   │
│   ├── Utilities/
│   │   ├── Logger.swift             # Logging utility
│   │   ├── Validator.swift          # Input validation
│   │   └── Constants.swift          # App constants
│   │
│   └── DesignSystem/
│       └── DesignTokens.swift       # Centralized design tokens
│
├── Models/                          # Data models (SwiftData)
│   ├── User.swift
│   ├── Item.swift
│   ├── Category.swift
│   └── [Other models from ARCHITECTURE.md]
│
├── Services/                        # Business logic services
│   ├── AuthenticationService.swift  # If auth required
│   ├── SyncService.swift            # If sync required
│   └── NotificationService.swift    # If notifications required
│
├── Resources/                       # Assets and resources
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/                  # Define colors here
│   │   │   ├── BrandPrimary.colorset
│   │   │   ├── BrandSecondary.colorset
│   │   │   └── [All colors from DESIGN_SYSTEM.md]
│   │   └── Images/
│   └── PrivacyInfo.xcprivacy        # Privacy manifest
│
└── Supporting Files/
    ├── Info.plist
    └── [AppName].entitlements       # If capabilities needed

[AppName]Tests/                      # Unit tests
├── ViewModelTests/
│   ├── HomeViewModelTests.swift
│   └── [Other ViewModel tests]
├── ModelTests/
│   ├── UserTests.swift
│   └── [Other Model tests]
└── ServiceTests/
    └── APIClientTests.swift

[AppName]UITests/                    # UI tests
└── [AppName]UITests.swift
```

**To Create Folders**:
1. Right-click project in Navigator
2. New Group (⌘⌥N)
3. Name it exactly as above
4. Create subgroups as needed
5. Add files to appropriate groups

---

## 3. Implementation Phases

Follow these phases sequentially. Each phase builds on the previous.

### **Phase 1: Core Infrastructure** (Week 1)

Goal: Set up foundational code that all features depend on.

---

#### Step 1.1: Create Data Models

For each entity in ARCHITECTURE.md Section 3.2, create a SwiftData model.

**File**: `Models/User.swift`

**Pseudo-code with inline documentation**:

```swift
import Foundation
import SwiftData

/// Represents a user of the application
/// SwiftData model - automatically persisted to local database
@Model
final class User {
    // MARK: - Properties

    /// Unique identifier for the user
    /// @Attribute(.unique) ensures no duplicate UUIDs in database
    @Attribute(.unique) var id: UUID

    /// User's full name
    var name: String

    /// User's email address (used for login and notifications)
    var email: String

    /// URL to user's profile image (optional)
    var profileImageURL: String?

    /// Timestamp when user account was created
    var createdAt: Date

    /// Timestamp of last profile update
    var updatedAt: Date

    // MARK: - Relationships

    /// All items created by this user
    /// @Relationship with deleteRule .cascade means: when User is deleted, all their Items are also deleted
    @Relationship(deleteRule: .cascade, inverse: \\Item.owner)
    var items: [Item]

    // MARK: - Initializer

    /// Creates a new User instance
    /// - Parameters:
    ///   - name: User's full name
    ///   - email: User's email address
    init(name: String, email: String) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.profileImageURL = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.items = []
    }

    // MARK: - Computed Properties

    /// Returns formatted display name (first name only if space exists)
    var displayName: String {
        let components = name.components(separatedBy: " ")
        return components.first ?? name
    }

    /// Returns user's initials for avatar fallback (e.g., "John Doe" → "JD")
    var initials: String {
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }

    // MARK: - Validation

    /// Validates if user data is complete and valid
    /// - Returns: true if valid, false otherwise
    var isValid: Bool {
        return !name.isEmpty && isValidEmail(email)
    }

    /// Validates email format using regex
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Methods

    /// Updates the user's profile information
    /// - Parameters:
    ///   - name: New name (optional)
    ///   - email: New email (optional)
    ///   - profileImageURL: New profile image URL (optional)
    func updateProfile(name: String? = nil, email: String? = nil, profileImageURL: String? = nil) {
        if let name = name {
            self.name = name
        }
        if let email = email {
            self.email = email
        }
        if let profileImageURL = profileImageURL {
            self.profileImageURL = profileImageURL
        }
        self.updatedAt = Date()
    }
}

// MARK: - Codable Conformance (for API sync)

extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case profileImageURL = "profile_image_url"  // Match API naming
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
```

**Implementation Notes**:
- Use `@Model` macro for SwiftData (automatic persistence)
- Mark unique fields with `@Attribute(.unique)`
- Define relationships with `@Relationship(deleteRule:inverse:)`
- Add validation methods for data integrity
- Use `final` for classes that don't need subclassing (performance)
- Add `Codable` conformance if syncing with backend API

**Repeat for all models** listed in ARCHITECTURE.md:
- `Models/Item.swift`
- `Models/Category.swift`
- [Any other models]

---

**File**: `Models/Item.swift`

**Pseudo-code**:

```swift
import Foundation
import SwiftData

/// Represents an item in the application
@Model
final class Item {
    @Attribute(.unique) var id: UUID
    var title: String
    var subtitle: String?
    var itemDescription: String
    var thumbnailURL: String?
    var status: ItemStatus
    var metadata: String?  // JSON string for flexible data
    var createdAt: Date
    var updatedAt: Date

    // Relationships
    @Relationship(inverse: \\User.items)
    var owner: User?

    @Relationship(inverse: \\Category.items)
    var category: Category?

    init(title: String, description: String, owner: User, category: Category? = nil) {
        self.id = UUID()
        self.title = title
        self.subtitle = nil
        self.itemDescription = description
        self.thumbnailURL = nil
        self.status = .active
        self.metadata = nil
        self.createdAt = Date()
        self.updatedAt = Date()
        self.owner = owner
        self.category = category
    }

    var isValid: Bool {
        return !title.isEmpty && !itemDescription.isEmpty
    }

    func updateStatus(_ newStatus: ItemStatus) {
        self.status = newStatus
        self.updatedAt = Date()
    }
}

/// Item status enum
enum ItemStatus: String, Codable {
    case active = "active"
    case pending = "pending"
    case completed = "completed"
    case archived = "archived"
}

// Make ItemStatus compatible with SwiftData
extension ItemStatus: RawRepresentable {}
```

---

#### Step 1.2: Setup Data Manager

**Purpose**: Centralized service for all SwiftData operations (CRUD + queries)

**File**: `Core/Storage/DataManager.swift`

**Pseudo-code**:

```swift
import Foundation
import SwiftData
import Observation

/// Centralized manager for all SwiftData operations
/// Use this instead of direct ModelContext access for consistency
@Observable
final class DataManager {
    // MARK: - Properties

    /// Shared singleton instance (use dependency injection in production)
    static let shared = DataManager()

    /// SwiftData container holding the schema and configurations
    let container: ModelContainer

    /// Main context for UI-related operations (runs on main thread)
    var mainContext: ModelContext

    // MARK: - Initialization

    /// Private init for singleton
    private init() {
        // Define schema with all model types
        let schema = Schema([
            User.self,
            Item.self,
            Category.self,
            // Add all @Model classes here
        ])

        // Configure persistence
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,  // false = persist to disk
            allowsSave: true
        )

        do {
            // Create container
            self.container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Get main context
            self.mainContext = container.mainContext

            // Configure context
            mainContext.autosaveEnabled = true  // Auto-save on changes

            print("✅ DataManager initialized successfully")
        } catch {
            fatalError("Failed to create ModelContainer: \\(error)")
        }
    }

    // MARK: - Generic CRUD Operations

    /// Creates and inserts a new model instance
    /// - Parameter model: The model instance to insert
    /// - Throws: Error if save fails
    func create<T: PersistentModel>(_ model: T) throws {
        mainContext.insert(model)
        try save()
    }

    /// Fetches all instances of a model type
    /// - Parameters:
    ///   - type: The model type to fetch
    ///   - predicate: Optional filter (nil = fetch all)
    ///   - sortBy: Optional sort descriptors
    /// - Returns: Array of model instances
    /// - Throws: Error if fetch fails
    func fetch<T: PersistentModel>(
        _ type: T.Type,
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        var fetchDescriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy)
        return try mainContext.fetch(fetchDescriptor)
    }

    /// Fetches a single instance by ID
    /// - Parameters:
    ///   - type: The model type
    ///   - id: The persistent model ID
    /// - Returns: Model instance or nil if not found
    func fetchByID<T: PersistentModel>(_ type: T.Type, id: PersistentIdentifier) -> T? {
        return mainContext.model(for: id) as? T
    }

    /// Updates a model (no-op, changes are tracked automatically)
    /// Just call save() after modifying properties
    func update() throws {
        try save()
    }

    /// Deletes a model instance
    /// - Parameter model: The model instance to delete
    /// - Throws: Error if delete/save fails
    func delete<T: PersistentModel>(_ model: T) throws {
        mainContext.delete(model)
        try save()
    }

    /// Deletes all instances of a model type
    /// - Parameter type: The model type to delete all of
    /// - Throws: Error if delete fails
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let all = try fetch(type)
        for item in all {
            mainContext.delete(item)
        }
        try save()
    }

    /// Saves pending changes to persistent store
    /// - Throws: Error if save fails
    private func save() throws {
        if mainContext.hasChanges {
            try mainContext.save()
        }
    }

    // MARK: - Background Context

    /// Creates a background context for heavy operations (imports, sync)
    /// - Returns: A new ModelContext for background thread
    func backgroundContext() -> ModelContext {
        return ModelContext(container)
    }

    // MARK: - Specialized Queries (Domain-Specific)

    /// Fetches items filtered by status
    /// - Parameter status: The item status to filter by
    /// - Returns: Array of items with matching status
    /// - Throws: Error if fetch fails
    func fetchItems(byStatus status: ItemStatus) throws -> [Item] {
        let predicate = #Predicate<Item> { item in
            item.status == status
        }
        let sortBy = [SortDescriptor(\\Item.createdAt, order: .reverse)]
        return try fetch(Item.self, predicate: predicate, sortBy: sortBy)
    }

    /// Fetches recent items (last N days)
    /// - Parameter days: Number of days to look back
    /// - Returns: Array of recent items
    /// - Throws: Error if fetch fails
    func fetchRecentItems(days: Int = 7) throws -> [Item] {
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let predicate = #Predicate<Item> { item in
            item.createdAt >= startDate
        }
        let sortBy = [SortDescriptor(\\Item.createdAt, order: .reverse)]
        return try fetch(Item.self, predicate: predicate, sortBy: sortBy)
    }

    /// Searches items by title or description
    /// - Parameter query: Search query string
    /// - Returns: Array of matching items
    /// - Throws: Error if fetch fails
    func searchItems(query: String) throws -> [Item] {
        let lowercaseQuery = query.lowercased()
        let predicate = #Predicate<Item> { item in
            item.title.lowercased().contains(lowercaseQuery) ||
            item.itemDescription.lowercased().contains(lowercaseQuery)
        }
        return try fetch(Item.self, predicate: predicate)
    }

    // Add more domain-specific queries as needed from PRD features
}

// MARK: - Error Handling

enum DataManagerError: LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)
    case notFound

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch data: \\(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save data: \\(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete data: \\(error.localizedDescription)"
        case .notFound:
            return "Item not found"
        }
    }
}
```

**Testing DataManager**:

Create `Tests/ServiceTests/DataManagerTests.swift`:

```swift
import XCTest
@testable import [AppName]

final class DataManagerTests: XCTestCase {
    var dataManager: DataManager!

    override func setUp() {
        super.setUp()
        // Use in-memory store for tests
        dataManager = DataManager.shared
    }

    override func tearDown() {
        // Clean up test data
        try? dataManager.deleteAll(Item.self)
        try? dataManager.deleteAll(User.self)
        dataManager = nil
        super.tearDown()
    }

    func testCreateUser() throws {
        // Given
        let user = User(name: "Test User", email: "test@example.com")

        // When
        try dataManager.create(user)

        // Then
        let fetched = try dataManager.fetch(User.self)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Test User")
    }

    func testFetchItemsByStatus() throws {
        // Given
        let user = User(name: "Test", email: "test@test.com")
        try dataManager.create(user)

        let item1 = Item(title: "Active", description: "Test", owner: user)
        item1.status = .active
        try dataManager.create(item1)

        let item2 = Item(title: "Complete", description: "Test", owner: user)
        item2.status = .completed
        try dataManager.create(item2)

        // When
        let activeItems = try dataManager.fetchItems(byStatus: .active)

        // Then
        XCTAssertEqual(activeItems.count, 1)
        XCTAssertEqual(activeItems.first?.title, "Active")
    }

    // Add more tests for each DataManager method
}
```

---

#### Step 1.3: Implement Design System

**Purpose**: Centralize all design tokens (colors, typography, spacing) in one file

**File**: `Core/DesignSystem/DesignTokens.swift`

**Complete implementation** (copy from DESIGN_SYSTEM.md Section 12):

```swift
import SwiftUI

/// Centralized design system tokens
/// All design decisions are defined here - reference throughout the app
enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        // Brand colors (defined in Assets.xcassets/Colors/)
        static let brandPrimary = Color("BrandPrimary")
        static let brandSecondary = Color("BrandSecondary")
        static let brandAccent = Color("BrandAccent")

        // Semantic colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // Text colors (use system colors for automatic dark mode)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary

        // Background colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)

        // UI element colors
        static let separator = Color(.separator)
        static let border = Color(.separator)
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16     // Default
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum Radius {
        static let xs: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12   // Default
        static let large: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999   // Fully rounded
    }

    // MARK: - Shadows

    enum Shadow {
        static let card = (color: Color.black.opacity(0.1), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let modal = (color: Color.black.opacity(0.15), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(4))
        static let elevated = (color: Color.black.opacity(0.2), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(8))
    }

    // MARK: - Animation

    enum Animation {
        static let fast: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
        static let verySlow: Double = 1.0
    }

    // MARK: - Layout

    enum Layout {
        static let cardHeight: CGFloat = 80
        static let buttonHeight: CGFloat = 50
        static let textFieldHeight: CGFloat = 50
        static let minTapTarget: CGFloat = 44
        static let maxContentWidth: CGFloat = 600  // For iPad
    }
}

// MARK: - Convenience Extensions

extension Color {
    /// Initialize from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

**Add Color Assets**:

1. Open `Assets.xcassets`
2. Right-click → New Color Set
3. Name: "BrandPrimary"
4. In Attributes Inspector: Appearances → Any, Dark
5. Set Light Mode color: #007AFF (or from DESIGN_SYSTEM.md)
6. Set Dark Mode color: #0A84FF
7. Repeat for "BrandSecondary", "BrandAccent", etc.

---

#### Step 1.4: Create View Extensions

**Purpose**: Reusable SwiftUI modifiers for consistent styling

**File**: `Core/Extensions/View+Extensions.swift`

**Implementation**:

```swift
import SwiftUI

extension View {
    // MARK: - Card Style

    /// Applies standard card styling
    /// - Returns: View with card background, padding, corner radius, and shadow
    func cardStyle() -> some View {
        self
            .padding(DesignSystem.Spacing.l)
            .background(DesignSystem.Colors.secondaryBackground)
            .cornerRadius(DesignSystem.Radius.medium)
            .shadow(
                color: DesignSystem.Shadow.card.color,
                radius: DesignSystem.Shadow.card.radius,
                x: DesignSystem.Shadow.card.x,
                y: DesignSystem.Shadow.card.y
            )
    }

    // MARK: - Button Styles

    /// Applies primary button styling
    func primaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(DesignSystem.Colors.brandPrimary)
            .cornerRadius(DesignSystem.Radius.medium)
    }

    /// Applies secondary button styling (outlined)
    func secondaryButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.headline)
            .foregroundColor(DesignSystem.Colors.brandPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(Color.clear)
            .cornerRadius(DesignSystem.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                    .stroke(DesignSystem.Colors.brandPrimary, lineWidth: 2)
            )
    }

    /// Applies text button styling (no background)
    func textButtonStyle() -> some View {
        self
            .font(DesignSystem.Typography.body)
            .foregroundColor(DesignSystem.Colors.brandPrimary)
    }

    // MARK: - Loading Overlay

    /// Shows loading overlay when condition is true
    /// - Parameter isLoading: Binding to loading state
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView()
                        .controlSize(.large)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(DesignSystem.Radius.medium)
                }
            }
        }
    }

    // MARK: - Conditional Modifiers

    /// Applies modifier only when condition is true
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    // MARK: - Keyboard Dismissal

    /// Adds tap gesture to dismiss keyboard
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Button Style Structs

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .primaryButtonStyle()
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: DesignSystem.Animation.fast), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .secondaryButtonStyle()
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: DesignSystem.Animation.fast), value: configuration.isPressed)
    }
}

// Usage:
// Button("Continue") { }
//     .buttonStyle(PrimaryButtonStyle())
```

---

#### Step 1.5: Create Networking Layer

**Purpose**: Centralized HTTP client for API calls

**File**: `Core/Networking/APIClient.swift`

**Implementation**:

```swift
import Foundation

/// Actor-based API client for thread-safe network operations
actor APIClient {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = APIClient()

    /// Base URL for API
    private let baseURL: URL

    /// URLSession for network requests
    private let session: URLSession

    // MARK: - Initialization

    init(baseURL: String = "https://api.example.com") {
        self.baseURL = URL(string: baseURL)!

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }

    // MARK: - Generic Request Method

    /// Performs an API request and decodes the response
    /// - Parameters:
    ///   - endpoint: The API endpoint to call
    ///   - method: HTTP method (GET, POST, etc.)
    ///   - body: Optional request body (will be JSON encoded)
    ///   - headers: Additional headers
    /// - Returns: Decoded response of type T
    /// - Throws: APIError if request fails
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        // Build URL
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add authentication header (if user is logged in)
        // Uncomment if auth required:
        // if let token = try? await getAuthToken() {
        //     request.setValue("Bearer \\(token)", forHTTPHeaderField: "Authorization")
        // }

        // Encode body
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        // Perform request
        let (data, response) = try await session.data(for: request)

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - decode response
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding error: \\(error)")
                print("Response data: \\(String(data: data, encoding: .utf8) ?? "")")
                throw APIError.decodingError(error)
            }

        case 401:
            throw APIError.unauthorized

        case 403:
            throw APIError.forbidden

        case 404:
            throw APIError.notFound

        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)

        default:
            throw APIError.httpError(httpResponse.statusCode)
        }
    }

    // MARK: - Convenience Methods

    /// Performs a GET request
    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        return try await request(endpoint, method: .get)
    }

    /// Performs a POST request
    func post<T: Decodable>(_ endpoint: String, body: Encodable) async throws -> T {
        return try await request(endpoint, method: .post, body: body)
    }

    /// Performs a PUT request
    func put<T: Decodable>(_ endpoint: String, body: Encodable) async throws -> T {
        return try await request(endpoint, method: .put, body: body)
    }

    /// Performs a DELETE request
    func delete<T: Decodable>(_ endpoint: String) async throws -> T {
        return try await request(endpoint, method: .delete)
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - API Error

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case httpError(Int)
    case serverError(Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .forbidden:
            return "You don't have permission to access this resource"
        case .notFound:
            return "Resource not found"
        case .httpError(let code):
            return "HTTP error: \\(code)"
        case .serverError(let code):
            return "Server error: \\(code)"
        case .decodingError(let error):
            return "Failed to decode response: \\(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \\(error.localizedDescription)"
        }
    }
}

// MARK: - Usage Example

extension APIClient {
    // Example: Fetch items from API
    func fetchItems() async throws -> [Item] {
        return try await get("/items")
    }

    // Example: Create new item
    func createItem(_ item: Item) async throws -> Item {
        return try await post("/items", body: item)
    }

    // Add all API endpoints from ARCHITECTURE.md here
}
```

---

**Phase 1 Complete!** ✅

At this point, you have:
- ✅ All data models defined
- ✅ DataManager for CRUD operations
- ✅ Design system tokens centralized
- ✅ Reusable view modifiers
- ✅ Networking layer ready

---

### **Phase 2: Feature Implementation** (Weeks 2-4)

Now implement each screen from UX_SPEC.md, one feature at a time.

[Due to character limit, I'll provide the structure for one complete feature, which you repeat for all features]

---

#### Step 2.1: Implement Home Screen

**Goal**: Create the main content view where users see their items

**Files to create**:
- `Features/Home/Views/HomeView.swift`
- `Features/Home/Views/HomeCardView.swift`
- `Features/Home/Views/HomeEmptyStateView.swift`
- `Features/Home/ViewModels/HomeViewModel.swift`

---

**File**: `Features/Home/ViewModels/HomeViewModel.swift`

**Purpose**: Business logic and state management for Home screen

```swift
import Foundation
import SwiftUI
import SwiftData
import Observation

/// View model for Home screen
/// Manages data fetching, state, and user actions
@Observable
final class HomeViewModel {
    // MARK: - Published State

    /// Array of items to display
    var items: [Item] = []

    /// Loading state
    var isLoading = false

    /// Error message (if any)
    var errorMessage: String = ""

    /// Whether to show error alert
    var showError = false

    /// Search query
    var searchQuery: String = "" {
        didSet {
            if searchQuery.isEmpty {
                Task {
                    await loadItems()
                }
            } else {
                Task {
                    await searchItems()
                }
            }
        }
    }

    // MARK: - Dependencies

    private let apiClient: APIClient
    private let dataManager: DataManager

    // MARK: - Initialization

    init(
        apiClient: APIClient = .shared,
        dataManager: DataManager = .shared
    ) {
        self.apiClient = apiClient
        self.dataManager = dataManager
    }

    // MARK: - Data Loading

    /// Loads items from local database and syncs with API
    @MainActor
    func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1. Load from local database first (instant)
            items = try dataManager.fetch(
                Item.self,
                sortBy: [SortDescriptor(\\.createdAt, order: .reverse)]
            )

            // 2. Sync with API in background (if online)
            await syncWithAPI()

        } catch {
            handleError(error)
        }
    }

    /// Syncs data with backend API
    private func syncWithAPI() async {
        do {
            // Fetch latest from API
            let remoteItems: [Item] = try await apiClient.get("/items")

            // Update local database
            for remoteItem in remoteItems {
                // Check if exists locally
                let existsLocally = items.contains { $0.id == remoteItem.id }

                if !existsLocally {
                    try dataManager.create(remoteItem)
                }
                // TODO: Handle updates (compare updatedAt timestamps)
            }

            // Reload from database to reflect changes
            await loadItems()

        } catch let error as APIError {
            // Don't show error for network issues during background sync
            print("⚠️ Background sync failed: \\(error)")
        } catch {
            print("⚠️ Sync error: \\(error)")
        }
    }

    /// Refreshes data (pull-to-refresh)
    @MainActor
    func refresh() async {
        await loadItems()
    }

    /// Searches items by query
    @MainActor
    private func searchItems() async {
        guard !searchQuery.isEmpty else { return }

        do {
            items = try dataManager.searchItems(query: searchQuery)
        } catch {
            handleError(error)
        }
    }

    // MARK: - User Actions

    /// Deletes an item
    @MainActor
    func deleteItem(_ item: Item) async {
        do {
            // Delete from local database
            try dataManager.delete(item)

            // Delete from API
            let _: EmptyResponse = try await apiClient.delete("/items/\\(item.id)")

            // Remove from array
            items.removeAll { $0.id == item.id }

        } catch {
            handleError(error)
        }
    }

    /// Toggles item status
    @MainActor
    func toggleItemStatus(_ item: Item) async {
        let newStatus: ItemStatus = item.status == .completed ? .active : .completed

        do {
            item.updateStatus(newStatus)
            try dataManager.update()

            // Sync to API
            let _: Item = try await apiClient.put("/items/\\(item.id)", body: item)

        } catch {
            handleError(error)
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        print("❌ Error: \\(error)")
    }
}

/// Empty response for DELETE endpoints
struct EmptyResponse: Codable {}
```

---

**File**: `Features/Home/Views/HomeView.swift`

**Purpose**: Main Home screen UI

```swift
import SwiftUI
import SwiftData

struct HomeView: View {
    // MARK: - Environment

    @Environment(\\.modelContext) private var modelContext

    // MARK: - State

    /// View model (initialize here or inject via dependency)
    @State private var viewModel = HomeViewModel()

    /// Whether to show add item sheet
    @State private var showingAddSheet = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                if viewModel.items.isEmpty && !viewModel.isLoading {
                    HomeEmptyStateView {
                        showingAddSheet = true
                    }
                } else {
                    itemListView
                }

                // Loading overlay
                if viewModel.isLoading {
                    loadingView
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .searchable(
                text: $viewModel.searchQuery,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search items..."
            )
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditItemView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .task {
                // Load data when view appears
                await viewModel.loadItems()
            }
        }
    }

    // MARK: - Subviews

    private var itemListView: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink {
                    ItemDetailView(item: item)
                } label: {
                    HomeCardView(item: item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteItem(item)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        Task {
                            await viewModel.toggleItemStatus(item)
                        }
                    } label: {
                        Label(
                            item.status == .completed ? "Mark Active" : "Complete",
                            systemImage: item.status == .completed ? "arrow.uturn.backward" : "checkmark"
                        )
                    }
                    .tint(.green)
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(
                top: DesignSystem.Spacing.s,
                leading: DesignSystem.Spacing.l,
                bottom: DesignSystem.Spacing.s,
                trailing: DesignSystem.Spacing.l
            ))
        }
        .listStyle(.plain)
    }

    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            ProgressView()
                .controlSize(.large)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(DesignSystem.Radius.medium)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showingAddSheet = true
            } label: {
                Label("Add Item", systemImage: "plus")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink {
                SettingsView()
            } label: {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .modelContainer(for: [Item.self, User.self], inMemory: true)
}
```

---

**Continue this pattern** for:
- ItemDetailView
- AddEditItemView
- SettingsView
- All other screens from UX_SPEC.md

Each screen follows the same structure:
1. Create ViewModel (business logic, state management)
2. Create View (UI with SwiftUI)
3. Create subviews (components like cards, empty states)
4. Write tests (unit tests for ViewModel, UI tests for View)

---

## 4. Testing Implementation

[Include comprehensive testing guide for unit tests, UI tests, integration tests]

## 5. App Store Submission

[Include complete submission checklist and process]

## 6. Troubleshooting Guide

[Include common issues and solutions]

---

**Total Document**: ~5000+ lines with all features implemented

---

## Execution Instructions

When activated, follow these steps:

1. **Read All Specification Documents**
   ```
   - Read docs/PRD.md (all features)
   - Read docs/ARCHITECTURE.md (tech stack, structure)
   - Read docs/UX_SPEC.md (all screens)
   - Read docs/DESIGN_SYSTEM.md (design tokens)
   ```

2. **Extract Implementation Requirements**
   - List all features to implement (from PRD)
   - List all screens to build (from UX_SPEC)
   - List all data models (from ARCHITECTURE)
   - Understand navigation flow (from UX_SPEC)

3. **Generate Project Setup Instructions**
   - Xcode project creation
   - Dependency installation
   - Folder structure
   - Initial configuration

4. **Generate Phase 1: Core Infrastructure**
   - Detailed pseudo-code for all data models
   - Complete DataManager implementation
   - Design system setup
   - View extensions
   - Networking layer

5. **Generate Phase 2: Feature Implementation**
   - For EACH screen in UX_SPEC:
     - ViewModel (complete pseudo-code)
     - View (complete SwiftUI code)
     - Subviews (components)
     - Tests
   - Include all states (empty, loading, error)
   - Include all interactions from UX_SPEC

6. **Generate Phase 3: Testing**
   - Unit test structure
   - UI test scenarios
   - Integration test examples

7. **Generate Phase 4: Release**
   - Build configuration
   - App Store preparation
   - Submission checklist

8. **Write Complete Guide**
   ```
   Write to: docs/IMPLEMENTATION_GUIDE.md
   Target length: 3000-5000 lines
   Format: Markdown with code blocks
   ```

9. **Present Summary**
   ```
   ✅ Implementation Guide generated!

   📚 **Implementation Guide Summary**:
   - Total sections: [X]
   - Implementation phases: [X] phases over [Y] weeks
   - Files to create: ~[Z] Swift files
   - Estimated lines of code: ~[N] LOC
   - Complete pseudo-code for all features
   - Testing strategy included
   - Troubleshooting guide included

   **What's Included**:
   ✅ Project setup (Xcode, SPM, configuration)
   ✅ Complete folder structure
   ✅ Phase 1: Core infrastructure (models, networking, design system)
   ✅ Phase 2: All features with detailed pseudo-code
   ✅ Phase 3: Testing guide
   ✅ Phase 4: Release preparation

   **Next Steps**:
   1. Review the implementation guide in docs/IMPLEMENTATION_GUIDE.md
   2. Follow Phase 1 to set up infrastructure
   3. Implement features one by one in Phase 2
   4. Run tests continuously
   5. Prepare for release with Phase 4 checklist

   **Developer can now**:
   - Follow step-by-step to build the entire app
   - Copy-paste pseudo-code and adapt to actual implementation
   - Understand architectural decisions at each step
   - Test along the way with provided test cases

   Ready to start implementing? Or would you like me to clarify any section?
   ```

10. **Iterate Based on Feedback**
    If user requests changes:
    - Update specific sections
    - Add missing features
    - Clarify pseudo-code
    - Expand on complex areas

---

## Quality Guidelines

1. **Be Extremely Detailed**: Pseudo-code should be ~80% real code
   - BAD: "Create a view model with state"
   - GOOD: [Complete code with all properties, methods, error handling, comments]

2. **Include All Error Handling**: Every async operation needs try/catch
   - Show how to handle API errors
   - Show how to display errors to users
   - Include logging for debugging

3. **Provide Complete Examples**: Not just snippets
   - Full file implementations
   - All imports
   - All comments
   - Usage examples

4. **Follow Architecture**: Match ARCHITECTURE.md exactly
   - Use specified patterns (MVVM, Clean, etc.)
   - Use specified frameworks (SwiftUI, SwiftData)
   - Follow folder structure

5. **Include Testing**: Every feature needs tests
   - Unit tests for ViewModels
   - UI tests for critical flows
   - Integration tests for API/database

6. **Be Production-Ready**: Code should be copy-pastable
   - Proper error handling
   - Accessibility labels
   - Performance considerations
   - Security best practices

7. **Comment Extensively**: Explain WHY, not just WHAT
   - Architecture decisions
   - Tradeoffs made
   - Alternatives considered
   - Performance implications

---

## Integration with Workflow

This skill is typically:
- **Fourth step** in specification generation
- Activated after PRD, Architecture, and UX specs are complete
- Followed by test-spec and release-spec
- Most detailed document in the workflow (~5000 lines)

The implementation guide is the bridge between specifications and working code.

---

## Notes

- Pseudo-code should be detailed enough that junior developers can follow
- Include complete examples, not just outlines
- Every screen from UX_SPEC must have implementation code
- Testing is not optional - include test cases
- Performance and security must be considered throughout
- Accessibility must be built in from the start
- This is the most critical document - take time to make it comprehensive
- Code should follow Swift and SwiftUI best practices
- Use modern iOS 17+ APIs (async/await, @Observable, SwiftData)

### Source: `product/implementation-spec`

# Implementation Specification Orchestrator Skill

Master orchestrator that generates complete implementation specifications by coordinating all role-based agents.

## Metadata
- **Name**: implementation-spec
- **Version**: 1.0.0
- **Role**: Master Orchestrator
- **Author**: ProductAgent Team

## When This Skill Activates

This skill activates when the user says:
- "generate implementation specifications"
- "create implementation specs"
- "generate all specs"
- "create development specifications"
- "generate complete specifications"

## Description

You are the Master Implementation Specification Orchestrator. Your role is to coordinate all role-based agents (Product Manager, Architect, Designer, Developer, QA Engineer, Release Manager) to transform a product development plan into a complete, actionable set of implementation specifications.

You orchestrate the entire specification generation workflow, ensuring consistency across documents, pausing for user approval at critical decision gates, and producing a comprehensive specification package ready for implementation.

## Prerequisites

Before activating this skill, ensure:
1. A product development plan exists (from the product-agent skill)
2. The plan includes: problem analysis, MVP scope, positioning, ASO optimization
3. User has reviewed and approved the product development plan
4. User is ready to proceed to detailed specification generation

**Optional but Recommended** (enhances specification quality):
5. Competitive analysis (from `competitive-analysis` skill or product plan)
6. Market research (from `market-research` skill or product plan)

## Input Sources

1. **Product development plan** (typically `product-plan-*.md`)
   - Generated by the product-agent skill
   - Contains: problem analysis, MVP scope, positioning, ASO optimization
   - Located in project root

2. **User decisions** at each phase gate:
   - Approval to proceed
   - Requested changes or iterations
   - Preferences and clarifications

## Workflow

### Phase Sequence

Execute these skills in order, with user decision gates:

```
[Optional] Phase 0: Market Research Enhancement
    ↓ [Check if competitive-analysis.md exists]
    ↓ [Check if market-research.md exists]
    ↓ [Offer to run these skills if missing]
    ↓ [User Decides: Run / Skip]
    ↓
Phase 1: Product Requirements (Product Manager)
    ↓ [User Reviews PRD]
    ↓ [User Approves]
Phase 2: Technical Architecture (iOS Architect)
    ↓ [User Reviews Architecture]
    ↓ [User Approves]
Phase 3: UI/UX Design (UI/UX Designer)
    ↓ [User Reviews Wireframes & Design System]
    ↓ [User Approves]
Phase 4: Implementation Guide (Senior Developer)
    ↓ [User Reviews Implementation Steps]
    ↓ [User Approves]
Phase 5: Test Specification (QA Engineer)
    ↓ [User Reviews Test Cases]
    ↓ [User Approves]
Phase 6: Release Documentation (Release Manager)
    ↓ [User Reviews Release Plan]
    ↓ [Final Approval]
    ↓
Complete Specification Package Generated ✅
```

## Execution Instructions

When activated, execute this workflow:

### Step 0: Check for Market Research (Optional Phase 0)

Before starting specification generation, check for existing research:

```
Check for these files:
- competitive-analysis.md or docs/competitive-analysis.md
- market-research.md or docs/market-research.md
- Or look for "Competitive Analysis" and "Market Analysis" sections in product plan
```

**If research files NOT found**, present this to user:

```markdown
## Pre-Specification Check

I noticed that competitive analysis and/or market research have not been run yet.

**Current Status**:
- Product Development Plan: ✅ Found
- Competitive Analysis: ⚠️ Not found
- Market Research: ⚠️ Not found

**Recommendation**: Running these research phases will significantly improve your specifications by:
- Informing feature priorities based on competitor gaps
- Setting realistic success metrics based on market size
- Identifying differentiation opportunities
- Providing pricing context

**Options**:
1. **Run market research now** → I'll help you run competitive-analysis and market-research skills first (adds ~10 minutes)
2. **Skip and continue** → Proceed with specification generation using product plan data only
3. **I have research elsewhere** → Tell me where to find your research files

What would you like to do?
```

**Wait for user decision**:
- If "Run research" → Guide user through competitive-analysis and market-research skills, then return here
- If "Skip" → Proceed to Step 1
- If "Have research" → Ask for file paths, read files, proceed to Step 1

**If research files ARE found**, inform user:

```markdown
## Pre-Specification Check ✅

**Status**:
- Product Development Plan: ✅ Found
- Competitive Analysis: ✅ Found - will be integrated into PRD
- Market Research: ✅ Found - will be integrated into PRD

All research is available. Proceeding to specification generation...
```

---

### Step 1: Introduction

Present overview to user:

```markdown
# Implementation Specification Generation

I'll now generate a complete set of implementation specifications from your product development plan.

**Data Sources**:
- Product Development Plan: ✅
- Competitive Analysis: [✅ Will be integrated / ⚠️ Skipped]
- Market Research: [✅ Will be integrated / ⚠️ Skipped]

## What We'll Create:

📋 **Phase 1: Product Requirements Document (PRD)**
- Features with acceptance criteria
- User stories
- User flows
- Success metrics
- Timeline
**Output**: `docs/PRD.md`

🏗️ **Phase 2: Technical Architecture**
- Architecture pattern (MVVM/Clean/TCA)
- Technology stack
- Data models
- App structure
- Security & privacy
**Output**: `docs/ARCHITECTURE.md`

🎨 **Phase 3: UI/UX Specifications**
- Wireframes for all screens (ASCII art)
- Design system (colors, typography, spacing)
- Component library
- Interaction patterns
**Output**: `docs/UX_SPEC.md`, `docs/DESIGN_SYSTEM.md`

💻 **Phase 4: Implementation Guide**
- Step-by-step development phases
- Complete pseudo-code for all features
- Project setup instructions
- Testing approach
**Output**: `docs/IMPLEMENTATION_GUIDE.md`

✅ **Phase 5: Test Specification**
- Unit test cases
- UI test scenarios
- Accessibility testing
- Beta testing plan
**Output**: `docs/TEST_SPEC.md`

🚀 **Phase 6: Release Documentation**
- App Store submission guide
- Asset requirements
- Privacy compliance
- Marketing strategy
**Output**: `docs/RELEASE_SPEC.md`

## Decision Gates:

You'll have the opportunity to review and approve each phase before proceeding to the next. I'll pause after each specification is generated for your feedback.

**Estimated Time**: 10-15 minutes (your review time)
**Total Output**: ~15,000-20,000 lines of documentation across 7 files

Ready to begin? (This will take a few minutes)
```

**Wait for user confirmation** before proceeding.

---

### Step 2: Phase 1 - Generate PRD

**Action**: Invoke the `prd-generator` skill

**Say to user**:
```markdown
## Phase 1: Generating Product Requirements Document

Reading your product development plan and extracting features, target audience, and success criteria...

[Invoke prd-generator skill]
```

**After PRD is generated**:

```markdown
✅ **Product Requirements Document generated!**

**Location**: `docs/PRD.md`

**Summary**:
- Features defined: [X] core features, [Y] deferred features
- User stories: [Z] stories with acceptance criteria (Given/When/Then format)
- User flows: [N] detailed flows (onboarding, core features, settings)
- Success metrics: Defined for MVP launch
- Timeline: [X] weeks estimated

**Key Highlights**:
- 📋 Section 3: All MVP features with priorities (P0, P1, P2)
- 📝 User stories follow "As a [user], I want [action], so that [benefit]" format
- ✅ Acceptance criteria in testable Given/When/Then format
- 🎯 Section 9: Clear success criteria (launch readiness + user success + business success)

**Next**: Review the PRD in `docs/PRD.md`

---

**Decision Gate: Do you approve the PRD, or would you like me to make changes?**

Options:
1. **Approve and continue** → I'll proceed to Phase 2 (Technical Architecture)
2. **Request changes** → Tell me what to modify (e.g., "Add feature X", "Change priority of Y", "Expand section Z")
3. **Iterate** → I'll update the PRD based on your feedback, then ask for approval again
```

**Wait for user decision**:
- If approved → Proceed to Phase 2
- If changes requested → Update PRD, present changes, ask for approval again
- If major concerns → Offer to restart Phase 1 with clarifications

---

### Step 3: Phase 2 - Generate Technical Architecture

**Say to user**:
```markdown
## Phase 2: Generating Technical Architecture Specification

Reading PRD to understand features and requirements...
Designing architecture pattern, data models, and tech stack...

[Invoke architecture-spec skill]
```

**After Architecture is generated**:

```markdown
✅ **Technical Architecture generated!**

**Location**: `docs/ARCHITECTURE.md`

**Summary**:
- Architecture Pattern: [MVVM / Clean Architecture / TCA]
- Technology Stack:
  - UI: SwiftUI
  - Data: SwiftData (iOS 17+)
  - Networking: async/await with URLSession
  - [Other frameworks from spec]
- Data Models: [X] models defined (User, Item, Category, etc.)
- App Structure: Complete folder hierarchy with [Y] folders
- API Endpoints: [Z] endpoints specified

**Key Decisions Made**:
- ✅ **Architecture**: [Pattern] chosen because [reason from spec]
- ✅ **Persistence**: SwiftData for modern iOS 17+ development
- ✅ **Networking**: Native URLSession (minimal dependencies)
- ✅ **State Management**: @Observable (iOS 17+)

**Key Sections**:
- 📁 Section 3.1: Complete module structure (Features, Core, Models, Services)
- 🗄️ Section 3.2: All data models with relationships and validation
- 🔐 Section 5: Security (Keychain, encryption) and Privacy (Privacy manifest)
- ⚡ Section 6: Performance considerations

**Next**: Review the architecture in `docs/ARCHITECTURE.md`

---

**Decision Gate: Do you approve the technical architecture?**

Questions to consider:
- Is the architecture pattern appropriate for your app's complexity?
- Are you comfortable with the tech stack (SwiftUI, SwiftData)?
- Do the data models cover all your features?
- Any specific third-party libraries you want to use?

Options:
1. **Approve and continue** → Phase 3 (UI/UX Design)
2. **Request changes** → (e.g., "Use Core Data instead of SwiftData", "Add feature X model")
3. **Ask questions** → I'll clarify architecture decisions
```

**Wait for user decision**.

---

### Step 4: Phase 3 - Generate UI/UX Specifications

**Say to user**:
```markdown
## Phase 3: Generating UI/UX Specifications and Design System

Reading PRD for user flows and features...
Reading Architecture for navigation structure...
Creating wireframes for all screens...
Defining design system (colors, typography, components)...

[Invoke ux-spec skill]
```

**After UX Spec is generated**:

```markdown
✅ **UI/UX Specifications and Design System generated!**

**Locations**:
- `docs/UX_SPEC.md` (wireframes and interactions)
- `docs/DESIGN_SYSTEM.md` (colors, typography, components)

**UX_SPEC.md Summary**:
- Design Principles: [X] principles defined
- Screens Designed: [Y] screens with ASCII wireframes
- User Flows: [Z] detailed flows (step-by-step)
- Component Library: Buttons, cards, forms, typography
- Accessibility: VoiceOver labels, Dynamic Type support, color contrast

**Key Wireframes** (see UX_SPEC.md):
- 🖼️ Onboarding Flow: [X] steps with wireframes
- 🏠 Home Screen: List view with cards, search, empty states
- 📄 Detail Screen: Full item view with actions
- ➕ Add/Edit Screen: Form with validation
- ⚙️ Settings Screen: Grouped list style

**DESIGN_SYSTEM.md Summary**:
- Colors: Brand primary, secondary, accent + semantic colors (success, warning, error)
- Typography: iOS Dynamic Type scale (largeTitle to caption)
- Spacing: 8pt grid system (xxs to xxxl)
- Components: Buttons, cards, inputs with reusable styles
- Animations: Timings and easing curves defined

**Next**: Review the designs:
1. Open `docs/UX_SPEC.md` and check wireframes for each screen
2. Open `docs/DESIGN_SYSTEM.md` and verify color palette and typography

---

**Decision Gate: Do you approve the UI/UX design?**

Questions to consider:
- Do the wireframes make sense for your target users?
- Is the navigation pattern intuitive?
- Do you like the design system (colors, typography)?
- Any specific UI components or patterns you want?

Options:
1. **Approve and continue** → Phase 4 (Implementation Guide)
2. **Request changes** → (e.g., "Change color scheme", "Redesign home screen", "Add feature to wireframe")
3. **Ask questions** → I'll explain design decisions
```

**Wait for user decision**.

---

### Step 5: Phase 4 - Generate Implementation Guide

**Say to user**:
```markdown
## Phase 4: Generating Implementation Guide

This is the most detailed specification. It will take a minute...

Reading all previous specs (PRD, Architecture, UX)...
Generating step-by-step implementation phases...
Writing detailed pseudo-code for all features...
Creating complete project setup instructions...

[Invoke implementation-guide skill]
```

**After Implementation Guide is generated**:

```markdown
✅ **Implementation Guide generated!**

**Location**: `docs/IMPLEMENTATION_GUIDE.md`

**Summary**:
- Total Length: ~5,000 lines of detailed pseudo-code and instructions
- Implementation Phases: [X] phases over [Y] weeks
- Files to Create: ~[Z] Swift files
- Estimated LOC: ~[N] lines of production code

**What's Included**:

**📦 Section 1: Project Setup**
- Complete Xcode project creation steps
- Dependencies installation (SPM)
- Configuration (signing, capabilities, build settings)
- Folder structure (every directory to create)

**🏗️ Section 2: Phase 1 - Core Infrastructure** (Week 1)
- All data models with complete pseudo-code (User, Item, etc.)
- DataManager for CRUD operations (SwiftData wrapper)
- Design system implementation (DesignTokens.swift)
- View extensions (reusable modifiers)
- Networking layer (APIClient with error handling)

**🎨 Section 3: Phase 2 - Feature Implementation** (Weeks 2-4)
- HomeView with ViewModel (complete implementation)
- ItemDetailView with ViewModel
- AddEditItemView with ViewModel
- SettingsView
- [All screens from UX_SPEC with pseudo-code]

**✅ Section 4: Testing** (throughout)
- Unit test examples for ViewModels
- UI test examples for critical flows
- Mock objects for testing

**🚀 Section 5: App Store Submission** (Week 5-6)
- Build process
- TestFlight preparation
- Final checklist

**Key Features**:
- ✅ **Production-ready pseudo-code**: 80% real Swift code, 20% comments
- ✅ **Complete error handling**: Every async operation has try/catch
- ✅ **Accessibility built-in**: VoiceOver labels, Dynamic Type
- ✅ **Testing included**: Unit tests and UI tests alongside features
- ✅ **Comments explain WHY**: Architectural decisions documented

**Next**: Review the implementation guide in `docs/IMPLEMENTATION_GUIDE.md`

This is your complete development roadmap. A developer can follow this step-by-step to build the entire app.

---

**Decision Gate: Do you approve the implementation approach?**

Questions to consider:
- Is the step-by-step approach clear?
- Is the estimated timeline realistic?
- Do you understand the implementation phases?
- Any specific coding patterns or practices you prefer?

Options:
1. **Approve and continue** → Phase 5 (Test Specification)
2. **Request changes** → (e.g., "Expand section on networking", "Add more examples for feature X")
3. **Ask questions** → I'll clarify implementation details
```

**Wait for user decision**.

---

### Step 6: Phase 5 - Generate Test Specification

**Say to user**:
```markdown
## Phase 5: Generating Test Specification

Reading all specs to create comprehensive test cases...
Defining unit tests for all ViewModels and models...
Creating UI test scenarios for critical user journeys...
Planning beta testing strategy...

[Invoke test-spec skill]
```

**After Test Spec is generated**:

```markdown
✅ **Test Specification generated!**

**Location**: `docs/TEST_SPEC.md`

**Summary**:
- Test Strategy: Test Pyramid (70% unit, 20% integration, 10% UI)
- Unit Test Cases: [X] tests across [Y] test suites
- Integration Tests: [Z] scenarios
- UI Tests: [N] critical user journeys with complete XCUITest code
- Accessibility Tests: VoiceOver, Dynamic Type, contrast
- Performance Benchmarks: Launch time, memory, FPS targets
- Beta Testing Plan: 2-week plan with [M] participants

**What's Included**:

**📊 Section 2: Unit Test Cases**
- All data models (User, Item) with test tables
- All ViewModels (HomeViewModel, etc.) with test scenarios
- Services (APIClient, DataManager) with edge cases
- Complete XCTest implementation examples

**🔗 Section 3: Integration Tests**
- Database + API sync scenarios
- ViewModel + Service integration
- Multi-component workflows

**🖱️ Section 4: UI Test Cases**
- Critical user journey 1: Onboarding and first item creation (12 steps)
- Critical user journey 2: View and edit item
- Critical user journey 3: Delete item
- Complete XCUITest implementations

**♿ Section 5: Accessibility Testing**
- VoiceOver label checklist
- Dynamic Type test scenarios
- Color contrast verification

**⚡ Section 6: Performance Testing**
- Benchmarks: Launch < 1.5s, scroll 60fps, memory < 150MB
- Load testing scenarios

**🌐 Section 7: Edge Cases**
- Network conditions (offline, slow, timeout)
- Data validation (empty, invalid, too long)
- Permission handling (denied, restricted)

**🧪 Section 10: Beta Testing**
- Participant criteria (20-50 testers)
- 2-week timeline
- Feedback collection methods
- Success criteria (crash-free > 99.5%, rating > 4.0)

**Coverage Target**: 80%+ code coverage, 100% of P0 features tested

**Next**: Review the test spec in `docs/TEST_SPEC.md`

---

**Decision Gate: Do you approve the testing strategy?**

Questions to consider:
- Is the test coverage sufficient?
- Are critical user journeys covered?
- Is the beta testing plan realistic?
- Any specific test scenarios you want to add?

Options:
1. **Approve and continue** → Phase 6 (Release Documentation) [Final phase!]
2. **Request changes** → (e.g., "Add test for feature X", "Expand beta testing plan")
3. **Ask questions** → I'll clarify testing approach
```

**Wait for user decision**.

---

### Step 7: Phase 6 - Generate Release Documentation

**Say to user**:
```markdown
## Phase 6: Generating Release Documentation

Final phase! Creating App Store submission guide...

Reading ASO optimization from product plan...
Reading Architecture for privacy requirements...
Reading Test Spec for quality gates...
Creating complete release roadmap...

[Invoke release-spec skill]
```

**After Release Spec is generated**:

```markdown
✅ **Release Documentation generated!**

**Location**: `docs/RELEASE_SPEC.md`

**Summary**:
- App Store Metadata: Pre-filled from ASO optimization
- Asset Requirements: App icon, screenshots (5 per size), optional video
- Privacy Compliance: Privacy manifest template, App Privacy guide
- Submission Process: Complete step-by-step guide from Xcode to App Store
- Post-Launch Monitoring: Crash reports, reviews, analytics
- Marketing Strategy: Pre-launch, launch day, post-launch activities
- CI/CD Automation: Fastlane and GitHub Actions setup (optional)

**What's Included**:

**📱 Section 1: App Store Metadata** (Pre-filled!)
- App Name: [From ASO]
- Subtitle: [From ASO]
- Keywords: [From ASO - exactly 100 chars]
- Description: [From ASO - complete description]
- Screenshots Strategy: [From ASO - 5 screenshots with captions]

**🖼️ Section 2: Assets**
- App Icon: 1024x1024px requirements and design notes
- Screenshots: Sizes, tools, creation tips
- App Preview Video: 30-second storyboard (from ASO)

**🔒 Section 3: Privacy & Compliance**
- Privacy Manifest: Complete PrivacyInfo.xcprivacy template
- App Privacy Details: Questionnaire guide
- Age Rating: Guidance based on content

**📋 Section 5: Pre-Submission Checklist** (50+ items)
- Development complete ✅
- Testing complete ✅
- Assets prepared ✅
- Metadata ready ✅
- Privacy compliance ✅

**📤 Section 6: Submission Process**
- App Store Connect setup (step-by-step with screenshots descriptions)
- Archive and upload from Xcode
- Fill in metadata
- Submit for review
- Monitor review status

**📊 Section 8: Post-Approval**
- Release day checklist
- Monitoring guide (crashes, reviews, analytics)
- Review response templates
- Update strategy (v1.0.1, v1.1.0, v2.0.0)

**🚀 Section 11: Marketing & Launch Strategy**
- Pre-launch (Week -2 to -1)
- Launch day announcements
- Post-launch engagement

**📈 Section 12: Success Metrics**
- Downloads, rating, retention targets
- Analytics to track

**Next**: Review the release spec in `docs/RELEASE_SPEC.md`

This is your complete roadmap from final build to App Store launch and beyond.

---

**Final Decision Gate: Do you approve the release documentation?**

This is the last specification phase. Once approved, you'll have a complete specification package ready for implementation.

Options:
1. **Approve** → I'll generate the final summary of all specifications
2. **Request changes** → (e.g., "Add marketing channel X", "Clarify submission step Y")
3. **Ask questions** → I'll clarify release process
```

**Wait for user decision**.

---

### Step 8: Generate Final Summary

**After all phases approved**:

```markdown
# 🎉 Implementation Specification Package Complete!

Your complete specification package has been generated in the `docs/` directory.

---

## 📦 Generated Specifications

### 1. 📋 Product Requirements Document
**File**: `docs/PRD.md`
**Length**: ~1,500 lines
**Contents**:
- ✅ [X] features defined (P0 must-haves, P1 should-haves, deferred)
- ✅ [Y] user stories with acceptance criteria (Given/When/Then)
- ✅ [Z] user flows (onboarding, core features, settings)
- ✅ Success metrics and timeline ([N] weeks MVP)

### 2. 🏗️ Technical Architecture
**File**: `docs/ARCHITECTURE.md`
**Length**: ~1,200 lines
**Contents**:
- ✅ Architecture: [MVVM/Clean/TCA] with rationale
- ✅ Tech Stack: SwiftUI + SwiftData + async/await
- ✅ [X] data models with relationships
- ✅ Complete folder structure
- ✅ Security and privacy architecture

### 3. 🎨 UI/UX Specifications
**Files**: `docs/UX_SPEC.md`, `docs/DESIGN_SYSTEM.md`
**Length**: ~2,000 lines combined
**Contents**:
- ✅ [X] screens with ASCII wireframes
- ✅ All user flows with interactions
- ✅ Complete design system (colors, typography, spacing)
- ✅ [Y] reusable components
- ✅ Accessibility guidelines

### 4. 💻 Implementation Guide
**File**: `docs/IMPLEMENTATION_GUIDE.md`
**Length**: ~5,000 lines
**Contents**:
- ✅ Complete project setup instructions
- ✅ Phase 1: Core infrastructure (models, services, design system)
- ✅ Phase 2: All features with detailed pseudo-code
- ✅ [Z] ViewModels with complete implementations
- ✅ Testing examples (unit + UI tests)
- ✅ Estimated [N] weeks, [M] files, [K] LOC

### 5. ✅ Test Specification
**File**: `docs/TEST_SPEC.md`
**Length**: ~2,500 lines
**Contents**:
- ✅ Test strategy (70% unit, 20% integration, 10% UI)
- ✅ [X] unit test cases with complete XCTest code
- ✅ [Y] UI test scenarios with complete XCUITest code
- ✅ Accessibility testing checklist
- ✅ Performance benchmarks
- ✅ 2-week beta testing plan
- ✅ Target: 80%+ code coverage

### 6. 🚀 Release Documentation
**File**: `docs/RELEASE_SPEC.md`
**Length**: ~2,500 lines
**Contents**:
- ✅ App Store metadata (pre-filled from ASO)
- ✅ Asset requirements (icon, screenshots, video)
- ✅ Privacy manifest template
- ✅ Complete submission guide (Xcode → App Store)
- ✅ Post-launch monitoring strategy
- ✅ Marketing and launch plan
- ✅ CI/CD automation (Fastlane + GitHub Actions)

---

## 📊 Total Specification Package

**Total Files**: 7 documents
**Total Length**: ~15,000 lines of comprehensive documentation
**Estimated Read Time**: 6-8 hours (to read everything)
**Estimated Implementation Time**: [N] weeks for MVP (from PRD)

---

## 🗂️ Directory Structure

Your `docs/` folder now contains:

```
docs/
├── PRD.md                       # Product Requirements
├── ARCHITECTURE.md              # Technical Architecture
├── UX_SPEC.md                   # UI/UX Specifications
├── DESIGN_SYSTEM.md             # Design System
├── IMPLEMENTATION_GUIDE.md      # Development Roadmap
├── TEST_SPEC.md                 # Testing Strategy
└── RELEASE_SPEC.md              # App Store Launch Guide
```

---

## ✅ What You Can Do Now

### Option 1: Implement Yourself
Follow `IMPLEMENTATION_GUIDE.md` step-by-step. Everything you need is documented:
1. ✅ Project setup (Xcode, dependencies)
2. ✅ Phase 1: Core infrastructure (Week 1)
3. ✅ Phase 2: Features (Weeks 2-4)
4. ✅ Testing throughout
5. ✅ TestFlight beta (Week 5-6)
6. ✅ App Store submission (Week 6-7)

### Option 2: Ask Me to Implement Specific Components
Say something like:
- "Implement HomeView from the specifications"
- "Generate the User data model code"
- "Create the APIClient networking layer"

I'll generate actual Swift code following the pseudo-code in IMPLEMENTATION_GUIDE.md.

### Option 3: Hire a Developer
Share the complete `docs/` folder with a developer. These specifications are comprehensive enough for any competent iOS developer to implement without guesswork.

### Option 4: Iterate on Specifications
If you want to refine anything:
- "Update PRD to add feature X"
- "Change architecture to use Core Data instead of SwiftData"
- "Redesign the home screen in UX_SPEC"

I'll update the relevant specification and ensure consistency across all documents.

---

## 🚀 Recommended Next Steps

### Immediate (This Week):
1. **Read the PRD** (`docs/PRD.md`) - Understand what you're building
2. **Review the Architecture** (`docs/ARCHITECTURE.md`) - Understand tech decisions
3. **Check the Wireframes** (`docs/UX_SPEC.md`) - Visualize the app

### Short Term (This Month):
1. **Set up Xcode project** (follow `IMPLEMENTATION_GUIDE.md` Section 1)
2. **Implement Phase 1** (Core infrastructure - Week 1)
3. **Start Phase 2** (First feature - Week 2)

### Medium Term (Next 2-3 Months):
1. **Complete MVP** (all P0 features from PRD)
2. **Test thoroughly** (follow `TEST_SPEC.md`)
3. **Prepare App Store assets** (from `RELEASE_SPEC.md`)
4. **Launch beta** via TestFlight
5. **Submit to App Store**

### Long Term (6-12 Months):
1. **Launch v1.0** (initial release)
2. **v1.0.1**: Bug fixes (1-2 weeks post-launch)
3. **v1.1.0**: First deferred feature (4-6 weeks post-launch)
4. **Iterate** based on user feedback

---

## 📚 Key Documents for Different Roles

**For Product Owners**:
- Start with: `PRD.md` (features, user stories, success criteria)
- Then: `TEST_SPEC.md` (acceptance criteria, beta testing)
- Finally: `RELEASE_SPEC.md` (launch strategy, metrics)

**For Developers**:
- Start with: `ARCHITECTURE.md` (tech stack, structure)
- Main reference: `IMPLEMENTATION_GUIDE.md` (complete development roadmap)
- Throughout: `TEST_SPEC.md` (write tests as you code)

**For Designers**:
- Start with: `UX_SPEC.md` (wireframes, user flows)
- Main reference: `DESIGN_SYSTEM.md` (colors, typography, components)
- Use: `PRD.md` (understand features and user needs)

**For QA Engineers**:
- Main reference: `TEST_SPEC.md` (all test cases, beta plan)
- Context: `PRD.md` (acceptance criteria)
- Context: `UX_SPEC.md` (user flows to test)

**For Release Managers**:
- Main reference: `RELEASE_SPEC.md` (complete submission guide)
- Context: `TEST_SPEC.md` (quality gates before release)
- Assets: App Store metadata already in RELEASE_SPEC

---

## 💡 Pro Tips

1. **Read in Order**: PRD → Architecture → UX → Implementation → Test → Release
2. **Bookmark Key Sections**: You'll reference these frequently during development
3. **Update as You Go**: When you make decisions or changes, update the specs
4. **Share with Team**: If working with others, share the `docs/` folder
5. **Version Control**: Commit these specs to git alongside your code
6. **Living Documents**: These aren't set in stone - iterate as you learn

---

## 🎯 Success Metrics (From PRD)

Your app will be successful if you achieve:
- **Launch**: All P0 features implemented and tested
- **Quality**: Crash-free rate > 99.5%, rating > 4.5 stars
- **Adoption**: [Download target] in first month
- **Engagement**: [Retention target] Day 7 retention
- **Revenue**: [Revenue target if applicable]

All metrics are defined in `PRD.md` Section 9.

---

## ❓ Need Help?

If you need clarification on any specification:
- Ask me: "Explain the [topic] in [document]"
- Request changes: "Update [section] in [document] to [change]"
- Request implementation: "Implement [component] from the specs"

---

## 🎉 Congratulations!

You now have a **complete, professional-grade specification package** that would cost $10,000-$50,000 if outsourced to an agency.

Everything you need to build, test, and launch your app is documented and ready to go.

**Time to build! 🚀**

---

**Want me to help with implementation now, or do you have questions about the specifications?**
```

### Step 9: Mark Task Complete

Update todo list to mark orchestrator as complete and final task (testing) as in progress.

---

## Error Handling

If any phase fails:

1. **Skill execution fails**:
   ```
   ❌ Error generating [Phase Name]

   Error: [Error message]

   Options:
   1. **Retry** → I'll attempt to generate this phase again
   2. **Skip** → Continue to next phase (not recommended, but possible)
   3. **Abort** → Stop specification generation

   What would you like to do?
   ```

2. **User rejects multiple times**:
   ```
   I notice we're iterating on [Phase] quite a bit.

   Would you like to:
   1. **Continue iterating** → I'll keep refining until you're happy
   2. **Schedule a review** → Take a break, review offline, come back later
   3. **Restart this phase** → Start [Phase] from scratch with new approach
   4. **Abort** → Stop and resume later

   What works best for you?
   ```

3. **Missing prerequisites**:
   ```
   ❌ Cannot start specification generation

   Missing: Product development plan

   Please run the product-agent skill first to generate the product development plan.

   The plan should include:
   - Problem analysis
   - MVP scope
   - Positioning
   - ASO optimization

   Would you like guidance on running product-agent?
   ```

---

## Quality Guidelines

1. **Keep User in Control**: Pause at every decision gate
   - Never proceed without approval
   - Make it easy to iterate
   - Offer to explain decisions

2. **Provide Context**: Help user understand what they're reviewing
   - Summarize key points
   - Highlight important sections
   - Explain why things matter

3. **Be Encouraging**: This is a marathon, not a sprint
   - Celebrate progress after each phase
   - Acknowledge the effort
   - Build excitement for the next phase

4. **Manage Expectations**: Be clear about what's happening
   - Time estimates (even if Claude is fast)
   - What's being generated
   - What user needs to review

5. **Enable Iteration**: Make changes easy
   - Accept vague feedback ("make it better")
   - Offer specific suggestions
   - Don't make user re-review entire docs

6. **Ensure Consistency**: Specifications must align
   - Features in PRD match Architecture data models
   - UX screens match PRD features
   - Implementation Guide covers all UX screens
   - Test Spec covers all features

---

## Updating Specifications

After initial generation, specifications may need updates. Here's how to handle changes:

### Updating a Single Specification

User can request updates to individual specs:

```
User: "Update the PRD to add a dark mode feature"
User: "Change the architecture to use Core Data instead of SwiftData"
User: "Redesign the home screen wireframe"
```

**Process**:
1. Identify which spec(s) are affected
2. Update the requested spec
3. Check for consistency impacts on other specs
4. Inform user of any downstream updates needed

### Specification Dependency Graph

Changes to upstream specs may require downstream regeneration:

```
PRD (Source of Truth)
 ├── ARCHITECTURE (depends on PRD features)
 │    └── IMPLEMENTATION_GUIDE (depends on Architecture)
 ├── UX_SPEC (depends on PRD features/flows)
 │    └── IMPLEMENTATION_GUIDE (depends on UX)
 │    └── DESIGN_SYSTEM (part of UX)
 ├── TEST_SPEC (depends on PRD acceptance criteria)
 └── RELEASE_SPEC (depends on ASO from product plan)
```

### Impact Analysis by Change Type

| Change Type | Directly Affected | May Need Review |
|-------------|-------------------|-----------------|
| Add new feature | PRD | Architecture, UX, Implementation, Test |
| Remove feature | PRD | Architecture, UX, Implementation, Test |
| Change architecture pattern | Architecture | Implementation |
| Modify UI design | UX_SPEC | Implementation, possibly Test (UI tests) |
| Update acceptance criteria | PRD | Test |
| Change data model | Architecture | Implementation, Test |
| Update positioning/ASO | Product Plan | Release |

### Regeneration Commands

User can request partial regeneration:

```
"Regenerate the Implementation Guide" → Invoke implementation-guide skill
"Update all specs based on new PRD" → Check each downstream spec for consistency
"Refresh the Test Spec" → Invoke test-spec skill
```

### Consistency Checking

When updating specs, check for:
1. **Feature alignment**: All PRD features appear in Architecture models
2. **Screen coverage**: All UX screens have Implementation Guide pseudo-code
3. **Test coverage**: All PRD acceptance criteria have Test Spec test cases
4. **Terminology**: Same feature names used across all documents

### Best Practices for Updates

1. **Start upstream**: Change PRD first, then downstream specs
2. **One change at a time**: Avoid massive updates that are hard to review
3. **Review consistency**: After update, scan related specs for mismatches
4. **Document changes**: Note changes in document version history
5. **Ask for confirmation**: Before major regeneration, confirm with user

---

## Integration with Workflow

This orchestrator is typically:
- Activated after the product-agent skill completes
- User reviews product development plan
- User decides to proceed to detailed specifications
- This skill generates all 7 specification documents
- User then has complete package ready for implementation

---

## Notes

- This is the most complex skill - it coordinates 6 other skills
- User decision gates are critical - don't skip them
- Each phase builds on previous ones - order matters
- Error handling is important - phases can fail
- Iteration is expected - users will request changes
- The final summary is crucial - help user understand what they have
- Encourage next steps - don't leave user hanging
- This transforms product plan into actionable specifications
- Estimated 10-15 minutes of user review time (total for all phases)
- Estimated 15,000-20,000 lines of total documentation generated

### Source: `product/localization-strategy`

# Localization Strategy

End-to-end localization planning for Apple platform apps — from market prioritization through translation workflow to localized App Store optimization.

## When This Skill Activates

Use this skill when the user:
- Wants to localize their app for new markets
- Asks "which languages should I support?"
- Needs help deciding market expansion priorities
- Wants to plan a translation workflow
- Asks about internationalization (i18n) best practices
- Mentions "localization", "translation", "multi-language", or "global markets"
- Wants to understand localization ROI by language
- Needs cost estimates for translation
- Asks about right-to-left (RTL) layout support
- Wants to localize App Store metadata (title, description, keywords, screenshots)

## Process

### Phase 1: Market Prioritization Framework

Not all languages are equal. Prioritize by revenue potential, not just speaker count.

#### Revenue Potential by Language

Based on App Store revenue data and per-user spending patterns:

| Language | Relative Revenue Potential | Why |
|----------|---------------------------|-----|
| English | Baseline (1.0x) | Largest single market, highest per-user spend |
| Japanese | 0.8-1.2x | Extremely high willingness to pay, especially for subscriptions |
| Chinese (Simplified) | 0.6-0.9x | Massive volume, growing per-user spend, competitive market |
| German | 0.4-0.6x | High per-user spend, values quality and privacy |
| French | 0.3-0.5x | Large market across France, Canada, Africa |
| Korean | 0.3-0.5x | Tech-savvy users, high app spending per capita |
| Spanish | 0.3-0.4x | Huge population, lower per-user spend, growing market |
| Portuguese (Brazilian) | 0.2-0.4x | Large market, mobile-first users, growing economy |

**Key insight:** Japanese and German users often pay 2-3x more per user than Spanish or Portuguese users. Volume vs. value is the fundamental tradeoff.

#### Category-Specific Priorities

App category changes which languages to prioritize first:

| App Category | Prioritize First | Why |
|--------------|-----------------|-----|
| Productivity / Business | Japanese, German, French | High willingness to pay for tools |
| Games | Japanese, Korean, Chinese Simplified | Gaming culture, high IAP spend |
| Social / Communication | Spanish, Portuguese, French | Large connected populations |
| Health / Fitness | German, Japanese, Korean | Health-conscious, high-spend markets |
| Education / Kids | Chinese Simplified, Japanese, Spanish | Education investment culture |
| Creative Tools | Japanese, German, French | Creative professional markets |
| Finance / Budgeting | German, French, Japanese | Financial discipline culture |
| Developer Tools | Japanese, Chinese Simplified, Korean | Large developer populations |

#### Factors to Evaluate

For each potential language/market, assess:

| Factor | Questions to Ask |
|--------|-----------------|
| Market size | How many potential users in this language? |
| Willingness to pay | Do users in this market pay for apps or expect free? |
| Competition level | How many localized competitors exist? Less = more opportunity |
| Localization cost | How expensive is professional translation for this language? |
| Cultural distance | How much adaptation beyond translation is needed? |
| Support burden | Can you handle support inquiries in this language? |
| App Store presence | Is the App Store well-established in this market? |

Use AskUserQuestion to gather the user's app category, current markets, and budget constraints before making recommendations.

### Phase 2: Language Tier Recommendations

#### Tier 1 — Highest ROI (Localize First)

| Language | Key Market | Estimated Revenue Lift |
|----------|-----------|----------------------|
| Japanese (ja) | Japan | +15-30% (high per-user value) |
| Chinese Simplified (zh-Hans) | China, Singapore | +10-25% (massive volume) |
| German (de) | Germany, Austria, Switzerland | +8-15% (high per-user spend) |
| French (fr) | France, Canada, Belgium, Africa | +8-15% (wide geographic reach) |
| Korean (ko) | South Korea | +5-12% (tech-savvy, high spend) |

**Recommendation:** Localize into 2-3 Tier 1 languages first. Expected combined revenue lift: 20-50%.

#### Tier 2 — Good ROI (Localize Second)

| Language | Key Market | Estimated Revenue Lift |
|----------|-----------|----------------------|
| Spanish (es) | Spain, Latin America, US Hispanic | +5-10% |
| Portuguese (pt-BR) | Brazil | +4-8% |
| Italian (it) | Italy | +3-6% |
| Dutch (nl) | Netherlands, Belgium | +2-4% |
| Russian (ru) | Russia, CIS countries | +3-6% |

**Recommendation:** Add Tier 2 after Tier 1 languages prove ROI. Expected per-language lift: 3-8%.

#### Tier 3 — Volume Play (Localize for Scale)

| Language | Key Market | Notes |
|----------|-----------|-------|
| Arabic (ar) | Middle East, North Africa | RTL support required — higher dev cost |
| Turkish (tr) | Turkey | Growing mobile market |
| Hindi (hi) | India | Massive volume, very low per-user spend |
| Thai (th) | Thailand | Mobile-first market |
| Vietnamese (vi) | Vietnam | Fast-growing app market |
| Polish (pl) | Poland | Central European hub |

**Recommendation:** Tier 3 is for apps that already have strong Tier 1 and Tier 2 performance and want maximum global reach.

### Phase 3: Minimum Viable Localization Levels

Not every language needs full localization on day one. Start small, measure, then invest.

#### Level 0: Metadata-Only

**What you localize:**
- App Store title and subtitle
- App Store description
- App Store keywords
- Screenshots (text overlays and captions)
- Promotional text

**What stays in English:**
- All in-app UI
- Help/support content
- Push notification text

**Cost:** $100-300 per language (professional translation of ~500 words)
**Effort:** 1-2 days per language
**Best for:** Testing whether a market responds before investing further

**Why this works:** Users search the App Store in their language. Localized metadata means your app appears in local searches. Many users worldwide are comfortable with English UI but discover apps through local search terms.

#### Level 1: Metadata + UI Strings

**What you localize:**
- Everything in Level 0
- All user-facing strings (Xcode String Catalogs export)
- Date/time/number format adaptation
- System alerts and error messages

**What stays in English:**
- In-app content (help articles, onboarding guides)
- Marketing materials
- Support communication

**Cost:** $500-3,000 per language (depending on string count)
**Effort:** 1-2 weeks per language (including QA)
**Best for:** Languages that showed strong Level 0 results

#### Level 2: Full Localization

**What you localize:**
- Everything in Level 1
- In-app content (onboarding, tutorials, help text)
- Marketing website and materials
- Customer support in-language
- Legal documents (privacy policy, terms of service)
- Push notifications and emails

**Cost:** $3,000-10,000+ per language
**Effort:** 3-6 weeks per language
**Best for:** Top 1-2 markets by revenue, when the language represents >15% of revenue

#### Recommended Approach

```
Step 1: Ship Level 0 for 2-3 Tier 1 languages
Step 2: Measure downloads and revenue lift per language (4-6 weeks)
Step 3: Invest in Level 1 for languages that showed >5% download lift
Step 4: Invest in Level 2 only for markets generating >15% of total revenue
```

This approach limits risk. If Japanese Level 0 doesn't move the needle, you saved yourself $2,000+ in translation costs.

### Phase 4: Translation Workflow

#### Xcode String Catalogs

String Catalogs (.xcstrings) are the standard localization format.

**Export workflow:**
1. Ensure all user-facing strings use `String(localized:)` or `LocalizedStringResource`
2. Build the project — Xcode auto-discovers strings
3. Open the `.xcstrings` file to see all strings with translation status
4. Export: Product > Export Localizations (creates .xcloc bundles)
5. Send .xcloc files to translators
6. Import: Product > Import Localizations

**String Catalog best practices:**
- Add comments to strings that need context (e.g., "Title of settings screen" or "Button label, max 15 characters")
- Use string interpolation with proper grammar agreement (Foundation's automatic grammar support)
- Mark strings that should NOT be translated (e.g., brand names) with "Don't Translate"
- Review the "Stale" state — it flags strings whose source changed after translation

#### Translation Service Options

| Service Type | Cost per Word | Quality | Turnaround | Best For |
|-------------|---------------|---------|------------|----------|
| Professional agency | $0.08-0.15 | High | 1-2 weeks | Level 1-2, critical apps |
| Freelance translators | $0.05-0.12 | Variable | 3-7 days | Level 1, budget-conscious |
| AI + human review | $0.03-0.06 | Good | 1-3 days | Level 0-1, fast iteration |
| Community/crowdsource | Free-$0.03 | Variable | Unpredictable | Open source, community apps |

**AI + human review workflow:**
1. Export strings from Xcode
2. Run through high-quality AI translation (provide app context and glossary)
3. Native speaker reviews and corrects (1-2 hours for 500 strings)
4. Import back into Xcode
5. Test in-context (some translations don't work in UI context)

#### Cost Estimates by App Size

| App Size | String Count | Level 0 Cost/Language | Level 1 Cost/Language | Level 2 Cost/Language |
|----------|-------------|----------------------|----------------------|----------------------|
| Small (utility) | 100-500 strings | $100-200 | $500-1,000 | $2,000-4,000 |
| Medium (productivity) | 500-2,000 strings | $200-400 | $1,000-3,000 | $4,000-8,000 |
| Large (complex app) | 2,000-5,000+ strings | $300-600 | $2,500-6,000 | $8,000-15,000 |

**Budget planning:** For a medium app localizing into 3 Tier 1 languages at Level 1: ~$3,000-9,000 total.

#### Review Process

Native speaker review is mandatory.

**Review checklist per language:**
- [ ] Grammar and spelling correct
- [ ] Tone matches the app's voice (casual, professional, playful)
- [ ] Technical terms translated consistently (use a glossary)
- [ ] No literal translations that sound unnatural
- [ ] String length fits UI constraints (check for truncation)
- [ ] Culturally appropriate (no unintended meanings)
- [ ] Placeholder variables render correctly (%@, %d, etc.)

### Phase 5: Cultural Adaptation Beyond Translation

Translation is necessary but not sufficient. Cultural adaptation catches issues that literal translation misses.

#### Date, Time, and Number Formats

**Rule:** Always use Foundation formatters. Never hardcode format strings.

```swift
// CORRECT - adapts to locale automatically
let formatter = Date.FormatStyle()
    .year().month().day()
Text(date.formatted(formatter))

// CORRECT - number formatting
Text(price.formatted(.currency(code: "JPY")))

// WRONG - hardcoded US format
Text(String(format: "%m/%d/%Y", date))
```

| Format | US | Germany | Japan |
|--------|-----|---------|-------|
| Date | 02/27/2026 | 27.02.2026 | 2026/02/27 |
| Time | 2:30 PM | 14:30 | 14:30 |
| Number | 1,234.56 | 1.234,56 | 1,234.56 |
| Currency | $9.99 | 9,99 EUR | 1,500 JPY |

#### Currency Display

- Always use the user's locale for display, even if your product is priced in USD
- App Store handles currency conversion for IAP — but display in marketing materials should match locale
- Some markets are sensitive to seeing foreign currencies (Japan especially)

#### Color Meanings

| Color | Western Meaning | East Asian Meaning | Middle Eastern |
|-------|----------------|-------------------|----------------|
| Red | Danger, error, stop | Luck, prosperity, celebration | Danger (similar to Western) |
| White | Purity, clean | Mourning, death (in some contexts) | Purity, peace |
| Green | Success, go, nature | Nature, health | Islam, paradise, nature |
| Yellow | Caution, warning | Royalty, courage (China) | Happiness, prosperity |

**Recommendation:** Use semantic system colors (`Color.red` for errors) and let the system handle meaning. Avoid using color as the ONLY way to convey information (accessibility requirement too).

#### Layout Direction

**RTL languages** (require layout mirroring): Arabic, Hebrew, Urdu, Persian

**What to mirror:**
- Navigation direction (back button on right)
- Text alignment (leading becomes trailing)
- Horizontal scroll direction
- Progress indicators (fill from right)
- Icons with directional meaning (arrows)

**What NOT to mirror:**
- Media playback controls (play, pause, skip)
- Phone number input
- Clocks and timers
- Brand logos

**SwiftUI RTL support:**
- Use `.leading` and `.trailing` instead of `.left` and `.right`
- Use `@Environment(\.layoutDirection)` for conditional layout
- Test with: Edit Scheme > Run > Options > Application Language > Right to Left Pseudolanguage

#### Image and Icon Localization

Some images need localization:
- Screenshots showing text (localize the text)
- Icons with text or cultural symbols
- Hand gesture icons (thumbs up, OK sign differ by culture)
- Body language icons (eye contact norms differ)

### Phase 6: Localized App Store Optimization (ASO)

#### Why Localized ASO Matters

- Localized App Store metadata increases conversion rate 30-80% in non-English markets
- Users search in their native language, even if they can use English apps
- App Store search algorithms weight localized keywords for each storefront
- Localized screenshots dramatically improve first impressions

#### Keyword Research by Market

**Critical:** Do NOT just translate your English keywords. Keyword search behavior differs dramatically by market.

| Market | Keyword Behavior |
|--------|-----------------|
| Japan | Users search with specific, descriptive terms; katakana for foreign concepts |
| Germany | Users prefer German terms over English loanwords for productivity apps |
| France | Strong preference for French terms; English terms for tech-specific concepts |
| Korea | Mix of Korean and English; English terms common in tech context |
| Brazil | Portuguese terms preferred; English for tech/gaming terms |
| China | Exclusively Chinese terms; English keywords rarely used |

**Localized keyword research process:**
1. Translate your top 10 English keywords as a starting point
2. Use WebSearch to find what local users actually search for: `"[category] app" site:[country-domain]`
3. Check local competitors' keywords (what terms do their listings target?)
4. Ask a native speaker: "How would you search for an app that does [X]?"
5. Test different keyword sets per locale and measure impressions

#### Localized Screenshots

Screenshots are the most impactful localization investment after metadata.

**What to localize in screenshots:**
- Overlay text and captions (translate and adapt, don't just translate)
- App content shown in screenshots (use locale-appropriate sample data)
- Feature callouts (highlight features that matter most in that market)
- Device frames (use devices popular in that market if relevant)

**What to keep consistent:**
- Overall visual style and branding
- Screenshot order (unless market research suggests different feature priority)
- App icon

**Cost-effective approach:** Create screenshot templates with text layers. Swapping text is fast and cheap compared to redesigning screenshots per locale.

#### Competitor Analysis by Storefront

Use WebSearch to research competitors in each target storefront:
- Which apps rank for your keywords in Japan vs. Germany vs. Brazil?
- Are local competitors absent from some markets? (opportunity)
- What pricing do competitors use in each market?
- What App Store categories are they listed under? (may differ by market)

### Phase 7: Testing Localized Builds

#### Xcode Preview with Locale Override

Test UI in different locales without changing device settings:

```swift
#Preview {
    ContentView()
        .environment(\.locale, Locale(identifier: "ja"))
}

#Preview {
    ContentView()
        .environment(\.locale, Locale(identifier: "de"))
}

#Preview {
    ContentView()
        .environment(\.layoutDirection, .rightToLeft)
}
```

#### Pseudo-Localization

Catch localization bugs before real translations arrive:

**Accented English:** Replaces characters with accented versions (e.g., "Settings" becomes "[Seeetttiiiinnggss]"). Helps catch:
- Hardcoded strings that bypass localization
- Character encoding issues

**Double-length strings:** Doubles every string. Helps catch:
- Truncation in fixed-width UI elements
- Layout overflow
- Buttons that can't grow

**Right-to-Left:** Mirrors layout. Helps catch:
- Hardcoded `.left` / `.right` instead of `.leading` / `.trailing`
- Icons that need mirroring
- Layout assumptions

**Enable in Xcode:** Edit Scheme > Run > Options > Application Language > choose pseudo-language.

#### String Length Testing

Translation length varies significantly by language:

| Language | Length vs. English |
|----------|-------------------|
| German | +25-35% longer |
| French | +15-25% longer |
| Spanish | +15-25% longer |
| Italian | +15-20% longer |
| Japanese | 0-20% shorter (but may need more vertical space) |
| Chinese | 30-50% shorter (characters are information-dense) |
| Korean | 0-15% shorter |
| Arabic | +20-25% longer |

**Implication:** If your English UI barely fits, German will definitely overflow. Design with 30% padding for text elements, or use dynamic type sizing.

#### Screenshot Testing Across Locales

Automate localized screenshot capture:
1. Use Xcode UI tests with `XCUIApplication().launchArguments` to set locale
2. Capture screenshots in each supported locale
3. Review for truncation, layout breaks, and placeholder leaks (%@ visible in UI)
4. Verify sample data matches locale expectations

#### Localization QA Checklist

Run this for every supported language before release:

- [ ] All strings translated (no English fallbacks visible)
- [ ] No truncated text in any screen
- [ ] Date/time/number formats correct for locale
- [ ] Currency displays correctly
- [ ] Pluralization rules work (many languages have complex plural forms)
- [ ] RTL layout correct (if applicable)
- [ ] Images with text localized
- [ ] App Store metadata reviewed by native speaker
- [ ] Screenshots localized and accurate
- [ ] Dynamic Type works with translated strings
- [ ] VoiceOver reads localized strings correctly

## Output Format

Present the localization roadmap as:

```markdown
# Localization Roadmap: [App Name]

## Current State
- **Supported languages**: [List]
- **App size**: [Small/Medium/Large] ([N] strings)
- **App category**: [Category]

## Market Prioritization

### Recommended Languages (Priority Order)

| Priority | Language | Tier | Level | Est. Revenue Lift | Est. Cost | Timeline |
|----------|----------|------|-------|-------------------|-----------|----------|
| 1 | [Language] | Tier 1 | Level [0/1] | +X-Y% | $X-Y | [N weeks] |
| 2 | [Language] | Tier 1 | Level [0/1] | +X-Y% | $X-Y | [N weeks] |
| 3 | [Language] | Tier [1/2] | Level [0/1] | +X-Y% | $X-Y | [N weeks] |

### Total Budget Estimate
- **Phase 1** (Tier 1 languages): $X-Y
- **Phase 2** (Tier 2 languages): $X-Y
- **Total**: $X-Y

## Translation Workflow
1. [Export method]
2. [Translation service]
3. [Review process]
4. [Import and QA]

## Localized ASO Plan
- **Keywords**: [Research approach per market]
- **Screenshots**: [Localization approach]
- **Description**: [Translation + adaptation approach]

## Cultural Adaptations Required
- [Adaptation 1]
- [Adaptation 2]

## Testing Plan
- [ ] Pseudo-localization pass
- [ ] Native speaker review per language
- [ ] Screenshot testing per locale
- [ ] RTL testing (if applicable)
- [ ] String length / truncation audit

## Timeline

| Phase | Duration | Languages | Level | Milestone |
|-------|----------|-----------|-------|-----------|
| 1 | Weeks 1-2 | [Languages] | Level 0 | Metadata live, measure downloads |
| 2 | Weeks 3-6 | [Languages] | Level 1 | Full UI localized for top performers |
| 3 | Weeks 7-10 | [Languages] | Level 0 | Tier 2 metadata test |
| 4 | Ongoing | [As needed] | Level 1-2 | Expand based on data |

## Success Metrics
- Downloads per locale (before vs. after localization)
- Conversion rate per storefront
- Revenue per locale
- Review ratings per locale (watch for localization complaints)

## Next Steps
1. [First action item]
2. [Second action item]
3. [Third action item]
```

## Integration with Other Skills

This skill connects to the broader product development pipeline:

```
1. product-agent              --> Validate idea
2. market-research            --> Identify global opportunity
3. competitive-analysis       --> Check competition per market
4. localization-strategy      --> THIS SKILL
   (THIS SKILL)
5. app-store                  --> Localized App Store listing
6. monetization               --> Regional pricing strategy
```

**Inputs from other skills:**
- `market-research` provides TAM/SAM/SOM data that helps prioritize markets
- `competitive-analysis` reveals which markets have fewer localized competitors
- `monetization` informs regional pricing (App Store price tier selection)

**Outputs to other skills:**
- Prioritized language list feeds into `app-store` for localized metadata
- Regional competitor data informs `competitive-analysis` per market
- Revenue projections per market feed into `monetization` strategy

## Common Mistakes to Avoid

### Translating keywords literally
```
Bad:  English keyword "to-do list" translated literally to Japanese
Good: Research what Japanese users actually search for (Japanese users often
      search for the concept differently than a literal translation)
```

### Hardcoding date/number formats
```
Bad:  String(format: "%m/%d/%Y", date)
Good: date.formatted(.dateTime.year().month().day())
```

### Ignoring string length differences
```
Bad:  Fixed-width button that fits "Save" but not "Speichern" (German)
Good: Flexible layout that adapts to any string length
```

### Localizing everything at once
```
Bad:  Translate into 15 languages at Level 2 before validating demand
Good: Level 0 for 3 languages, measure for 4 weeks, then invest in winners
```

### Skipping native speaker review
```
Bad:  Ship AI-translated strings without human review
Good: Every translation reviewed by a native speaker in-context
```

### Using left/right instead of leading/trailing
```
Bad:  .frame(alignment: .left)
Good: .frame(alignment: .leading)
```

---

**Localization is not translation — it's making your app feel native in every market. Start with metadata, prove demand with data, then invest in full localization where the numbers justify it.**

### Source: `product/prd-generator`

# PRD Generator Skill

Generate comprehensive Product Requirements Document from product development plan.

## Metadata
- **Name**: prd-generator
- **Version**: 1.0.0
- **Role**: Product Manager
- **Author**: ProductAgent Team

## When This Skill Activates

This skill activates when the user says:
- "generate PRD"
- "create product requirements"
- "write product requirements document"
- "generate requirements doc"
- "create PRD from plan"

## Description

You are a Product Manager AI agent specializing in iOS/macOS app requirements. Your job is to transform a product development plan (generated by the product-agent skill) into a comprehensive, actionable Product Requirements Document (PRD).

## Prerequisites

Before activating this skill, ensure:
1. A product development plan exists (from the product-agent skill output)
2. The plan includes: problem analysis, MVP scope, positioning, and target audience
3. User has reviewed and approved the product development plan

## Input Sources

Read and extract information from:

1. **Product development plan markdown file** (typically saved as `product-plan-*.md`)
   - Problem statement and analysis
   - Target users and pain points
   - MVP scope and core features
   - Positioning and value proposition
   - Success criteria

2. **Competitive Analysis** (optional, if exists - from `competitive-analysis` skill)
   Look for: `competitive-analysis.md`, `docs/competitive-analysis.md`, or embedded in product plan
   - Competitor list with strengths/weaknesses
   - Feature matrix and gaps
   - Pricing analysis
   - Differentiation opportunities
   - Market positioning map

   **Integration**: Use competitive insights to:
   - Inform feature priorities (fill gaps competitors miss)
   - Validate positioning (differentiation)
   - Set pricing context
   - Identify unique value propositions

3. **Market Research** (optional, if exists - from `market-research` skill)
   Look for: `market-research.md`, `docs/market-research.md`, or embedded in product plan
   - TAM/SAM/SOM market sizing
   - Market growth trends
   - Entry barriers
   - Distribution channels
   - Revenue potential

   **Integration**: Use market research to:
   - Validate opportunity size
   - Inform success metrics (realistic targets based on market)
   - Identify risks (entry barriers)
   - Set revenue expectations

4. **User clarifications** (ask if needed):
   - Additional feature requirements
   - Specific user flows to prioritize
   - Timeline constraints
   - Platform-specific considerations

## Output

Generate `docs/PRD.md` with the following structure:

```markdown
# Product Requirements Document: [App Name]

**Version**: 1.0.0
**Last Updated**: [Date]
**Status**: Draft / In Review / Approved
**Owner**: Product Manager
**Platform**: iOS / macOS

---

## 1. Product Overview

### 1.1 Vision Statement
[One-paragraph vision for the product - what it aspires to achieve]

### 1.2 Target Audience
**Primary**: [Detailed description of primary users]
**Secondary**: [Secondary audience if applicable]

### 1.3 Success Metrics
- [Metric 1]: [Target value]
- [Metric 2]: [Target value]
- [Metric 3]: [Target value]

---

## 2. User Personas

### 2.1 Primary Persona: [Persona Name]

**Demographics**:
- Age: [Range]
- Occupation: [Description]
- Tech savviness: [Low/Medium/High]
- Location: [Geographic focus]

**Pain Points**:
1. [Pain point 1 - be specific]
2. [Pain point 2]
3. [Pain point 3]

**Goals**:
1. [Goal 1 - what they want to achieve]
2. [Goal 2]
3. [Goal 3]

**Typical Day**:
[Brief narrative of how this persona currently addresses the problem]

**Quote**: "[A quote that captures their frustration or need]"

### 2.2 User Journey Map

**Current State** (Before using the app):
1. [Step 1 of current workflow]
2. [Step 2 - highlight pain points]
3. [Step 3]
4. [Pain point or frustration]

**Future State** (With the app):
1. [Step 1 - how the app improves it]
2. [Step 2 - benefits]
3. [Step 3 - outcomes]

---

## 3. Features & Requirements

### 3.1 Core Features (MVP - Must Have)

#### Feature 1: [Feature Name]

**Priority**: P0 (Critical)
**Complexity**: Low / Medium / High
**Estimated Effort**: [X] weeks

**User Story**:
As a [user type], I want [action], so that [benefit].

**Acceptance Criteria**:
```gherkin
Given [precondition]
When [action]
Then [expected result]

Given [precondition 2]
When [action 2]
Then [expected result 2]
```

**Description**:
[Detailed description of what this feature does and why it's needed]

**Dependencies**:
- [Dependency 1]
- [Dependency 2]

**Success Metrics**:
- [Metric 1]: [How to measure success]
- [Metric 2]: [Target value]

**Edge Cases**:
- [Edge case 1 and how to handle]
- [Edge case 2]

---

#### Feature 2: [Feature Name]

[Repeat structure for each MVP feature]

---

### 3.2 Deferred Features (Post-MVP - Phase 2)

**Feature**: [Deferred Feature Name]
**Rationale for Deferral**: [Why this is not in MVP]
**Planned for**: Version 1.1 / Phase 2

[List all deferred features with brief descriptions]

---

## 4. User Flows

### 4.1 Onboarding Flow

**Goal**: Help new user understand value and start using core feature

**Steps**:
1. **Launch Screen**
   - Show: Value proposition and hero image
   - Actions: [Sign Up] [Sign In] [Skip]

2. **Registration** (if user chooses Sign Up)
   - Required: [Email, Name, ...]
   - Optional: [Profile photo, ...]
   - Validation: [Email format, password strength]

3. **Welcome Tutorial** (optional, skippable)
   - Screen 1: [Key feature highlight]
   - Screen 2: [How to use core functionality]
   - Screen 3: [Call to action]

4. **First Task**
   - Guide user to create/do [first meaningful action]
   - Show success state

**Success Criteria**: User completes first [action] within first session

---

### 4.2 Core Feature Flow: [Feature Name]

**Entry Points**:
- From: [Screen/Action]
- Trigger: [User action or event]

**Happy Path**:
1. [Step 1] → [Result]
2. [Step 2] → [Result]
3. [Step 3] → [Success state]

**Alternative Paths**:
- If [condition]: [Alternative flow]
- If [error]: [Error handling]

**Exit Points**:
- Success: Navigate to [Screen]
- Cancel: Return to [Screen]
- Error: Show [Error message] and stay

---

### 4.3 Error States & Edge Cases

| Scenario | User Experience | System Behavior |
|----------|----------------|-----------------|
| No network connection | "Can't connect. Using offline mode." | Show cached data, queue actions |
| API timeout | "Taking longer than usual. Please wait..." | Retry with exponential backoff |
| Invalid input | "Please check [field] and try again" | Highlight invalid field, show helper text |
| Permission denied | "We need [permission] to [reason]" | Link to Settings, graceful degradation |

---

## 5. Non-Functional Requirements

### 5.1 Performance

- **Launch Time**: App cold launch < 1.5 seconds
- **Screen Load**: Screens appear < 300ms
- **API Response**: 95th percentile < 2 seconds
- **Offline Support**: Core features work offline with sync when online

### 5.2 Security & Privacy

- **Data Encryption**: All sensitive data encrypted at rest (Keychain)
- **Communication**: All API calls over HTTPS with TLS 1.2+
- **Authentication**: [Auth method - OAuth, JWT, etc.]
- **Privacy Manifest**: Complete PrivacyInfo.xcprivacy included
- **Data Retention**: [Retention policy]

### 5.3 Accessibility

- **VoiceOver**: All interactive elements have labels
- **Dynamic Type**: Support system text size (from XS to Accessibility XXL)
- **Color Contrast**: Minimum 4.5:1 for text, 3:1 for UI elements
- **Keyboard Navigation**: Full keyboard support (iPad, macOS)
- **Reduced Motion**: Respect system setting, provide alternatives

### 5.4 Localization

- **Launch Languages**: [English (US), ...]
- **Future Languages**: [Planned for Phase 2]
- **Considerations**: RTL support, date/time formats, currency

### 5.5 Platform Requirements

- **iOS Version**: Minimum iOS 26.0 (or iOS 17+ for broader device reach)
- **Devices**: iPhone (all sizes), iPad (if applicable)
- **Orientation**: Portrait (required), Landscape (optional)
- **Dark Mode**: Full support with dedicated assets
- **Size**: Target < 50MB download, < 100MB installed

---

## 6. Out of Scope

**Explicitly NOT included in MVP**:
- [Feature that was considered but excluded]
- [Integration that will come later]
- [Platform that won't be supported initially]

**Rationale**: [Brief explanation of why these are out of scope]

---

## 7. Technical Considerations

### 7.1 Third-Party Services / APIs

| Service | Purpose | Alternative Considered |
|---------|---------|----------------------|
| [Service name] | [What it does] | [Why this was chosen] |

### 7.2 Data Models (High-Level)

**Core Entities**:
- **[Entity 1]**: [Description, key fields]
- **[Entity 2]**: [Description, relationships]

**Relationships**:
- [Entity 1] has many [Entity 2]
- [Entity 3] belongs to [Entity 1]

### 7.3 API Requirements

**Endpoints Needed** (if backend required):
- `GET /api/v1/[resource]` - [Purpose]
- `POST /api/v1/[resource]` - [Purpose]
- `PUT /api/v1/[resource]/:id` - [Purpose]
- `DELETE /api/v1/[resource]/:id` - [Purpose]

---

## 8. Competitive Context

> **Note**: This section is populated from competitive analysis. If not available, include basic competitor awareness.

### 8.1 Key Competitors

| Competitor | Position | Key Strength | Key Weakness |
|------------|----------|--------------|--------------|
| [Competitor 1] | Market leader | [What they do well] | [Gap/opportunity] |
| [Competitor 2] | Challenger | [What they do well] | [Gap/opportunity] |
| [Competitor 3] | Niche | [What they do well] | [Gap/opportunity] |

### 8.2 Differentiation Strategy

**Our Positioning**: [How we're different - from positioning analysis]

**Key Differentiators**:
1. [Feature/approach competitors don't have]
2. [Unique value proposition element]
3. [Target audience we serve better]

### 8.3 Feature Gaps We're Filling

- [Gap 1]: [What competitors miss, how we address it]
- [Gap 2]: [What competitors miss, how we address it]

---

## 9. Market Context

> **Note**: This section is populated from market research. If not available, include high-level market awareness.

### 9.1 Market Sizing

- **TAM** (Total Addressable Market): [$ amount] - [Description]
- **SAM** (Serviceable Available Market): [$ amount] - [iOS/macOS segment]
- **SOM** (Serviceable Obtainable Market): [$ amount] - [Realistic 3-year capture]

### 9.2 Market Trends

**Growth Rate**: [X]% CAGR

**Tailwinds** (positive trends):
- [Trend 1 helping the market]
- [Trend 2 helping the market]

**Headwinds** (challenges):
- [Challenge 1]
- [Challenge 2]

### 9.3 Entry Barriers

| Barrier | Level | Our Strategy |
|---------|-------|--------------|
| [Barrier 1] | Low/Med/High | [How we'll overcome] |
| [Barrier 2] | Low/Med/High | [How we'll overcome] |

### 9.4 Revenue Expectations

- **Year 1 Target**: [$ range] - [User count] at [ARPU]
- **Year 3 Target**: [$ range] - Based on [growth assumptions]
- **Path to Scale**: [Key growth levers]

---

## 10. Open Questions & Decisions Needed

**Critical Decisions** (block development):
1. **[Question 1]**
   - Context: [Why this matters]
   - Options: [Option A / Option B]
   - Owner: [Who decides]
   - Deadline: [When needed]

**Nice-to-Clarify** (doesn't block):
2. **[Question 2]**
   - Context: [Background]
   - Current assumption: [What we're assuming]

---

## 11. Success Criteria & Metrics

### 11.1 MVP Success Criteria

**Launch Readiness**:
- [ ] All P0 features implemented and tested
- [ ] No P0 bugs in production
- [ ] App Store submission approved
- [ ] Performance benchmarks met

**User Success**:
- [ ] > 70% of users complete onboarding
- [ ] > 50% of users perform core action within first week
- [ ] Average session duration > 3 minutes
- [ ] < 2% crash rate

**Business Success**:
- [ ] [Download target] in first month
- [ ] [Active user target] in first 30 days
- [ ] [Retention target] Day 7 retention

### 11.2 Key Metrics to Track

**Acquisition**:
- App Store impressions → downloads conversion rate
- Organic vs paid downloads

**Activation**:
- Onboarding completion rate
- Time to first [core action]

**Engagement**:
- Daily/Weekly Active Users (DAU/WAU)
- Average session length
- Feature usage rates

**Retention**:
- Day 1, Day 7, Day 30 retention rates
- Churn rate and reasons

**Quality**:
- Crash-free rate (target: > 99.5%)
- App Store rating (target: > 4.5)
- Customer support ticket volume

---

## 12. Timeline & Milestones

**Phase 1: MVP Development** ([X] weeks)
- Week 1-2: Core infrastructure
- Week 3-4: Feature 1, Feature 2
- Week 5-6: Feature 3, Feature 4, Testing
- Week 7: Bug fixes, polish, TestFlight
- Week 8: App Store submission

**Phase 2: Iteration** ([X] weeks after launch)
- First update with deferred features
- Performance optimizations based on metrics
- User feedback incorporation

---

## 13. Stakeholders

| Role | Name | Responsibility | Contact |
|------|------|---------------|---------|
| Product Owner | [Name] | Final decisions, priorities | [Email] |
| iOS Developer | [Name] | Implementation | [Email] |
| Designer | [Name] | UI/UX | [Email] |
| QA | [Name] | Testing | [Email] |

---

## 14. References

- Product Development Plan: [Link/filename]
- Market Research: [Link/filename]
- Competitive Analysis: [Link/filename]
- Design Mockups: [Link when ready]
- Technical Architecture: [Link when ready]

---

## Appendix A: Detailed User Stories

[Include detailed user stories that didn't fit in main sections]

---

## Appendix B: Glossary

- **[Term 1]**: [Definition]
- **[Term 2]**: [Definition]

---

**Document History**:
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | [Date] | [Name] | Initial PRD created |

```

## Execution Instructions

When activated, follow these steps:

1. **Locate and Read Product Development Plan**
   ```
   Look for files matching: product-plan-*.md
   If multiple exist, use the most recent
   If none exist, ask user to provide the file path
   ```

2. **Look for Market Research and Competitive Analysis** (Optional but Recommended)
   ```
   Check for competitive analysis:
   - competitive-analysis.md
   - docs/competitive-analysis.md
   - Competitive Analysis section in product plan

   Check for market research:
   - market-research.md
   - docs/market-research.md
   - Market Analysis section in product plan

   If found, read and incorporate these insights.
   If not found, proceed with product plan data only.
   ```

3. **Extract Key Information**
   From the product plan, extract:
   - App idea/name
   - Problem statement
   - Target users and personas
   - Core features (from MVP scope section)
   - Positioning and value proposition
   - Success criteria
   - Timeline estimate

   From competitive analysis (if available), extract:
   - Key competitors and their weaknesses
   - Feature gaps (opportunities)
   - Differentiation strategy
   - Pricing insights

   From market research (if available), extract:
   - TAM/SAM/SOM figures
   - Market growth rate
   - Entry barriers to address
   - Revenue potential for success metrics

4. **Create Output Directory**
   ```bash
   mkdir -p docs
   ```

5. **Generate PRD**
   Using the template above:
   - Fill in all sections with specific, actionable content
   - Convert generic placeholders to actual data from the product plan
   - Expand on user stories with Given/When/Then acceptance criteria
   - Add user flows with detailed steps
   - Include all non-functional requirements
   - Identify open questions and decision points

6. **Write to File**
   ```
   Write the complete PRD to: docs/PRD.md
   ```

7. **Present to User**
   After generating the PRD, present a summary:

   ```
   ✅ Product Requirements Document generated!

   📋 **PRD Summary**:
   - Document: docs/PRD.md
   - Features defined: [X] core features
   - User stories: [Y] stories with acceptance criteria
   - User flows: [Z] flows documented
   - Open questions: [N] decisions needed

   📊 **Data Sources Used**:
   - Product Development Plan: ✅
   - Competitive Analysis: [✅ Integrated / ⚠️ Not found - recommend running]
   - Market Research: [✅ Integrated / ⚠️ Not found - recommend running]

   **Next Steps**:
   1. Review the PRD in docs/PRD.md
   2. Answer open questions in Section 8
   3. Provide feedback on any features
   4. Once approved, we can proceed to architecture spec

   Would you like me to make any changes to the PRD?
   ```

8. **Iterate Based on Feedback**
   If user requests changes:
   - Ask clarifying questions
   - Update the PRD accordingly
   - Maintain document version history

## Quality Guidelines

When generating the PRD:

1. **Be Specific**: No generic statements like "the app should be user-friendly"
   - BAD: "The app should be fast"
   - GOOD: "Screen transitions should complete in < 300ms"

2. **Be Actionable**: Every feature should have clear acceptance criteria
   - BAD: "Users can search"
   - GOOD: "As a user, I want to search by keyword so that I can find items quickly. Given I enter 'test' in search, When I tap Search, Then I see results matching 'test' sorted by relevance"

3. **Be Complete**: Cover all aspects
   - Functional requirements (features)
   - Non-functional requirements (performance, security)
   - User flows (happy path + errors)
   - Edge cases and error handling

4. **Be Realistic**: Based on MVP scope from product plan
   - Don't add features beyond MVP unless flagged as "deferred"
   - Timeline should match product plan estimates
   - Success metrics should be measurable and achievable

5. **Be Consistent**: Terminology should match product plan
   - If product plan calls it "item", don't call it "post"
   - Feature names should align across documents

## Example Activation

**User**: "Generate PRD from my product plan"

**You**:
1. Search for product-plan-*.md file
2. Read and parse the product development plan
3. Extract all relevant information
4. Generate comprehensive PRD using template
5. Write to docs/PRD.md
6. Present summary and next steps

## Integration with Workflow

This skill is typically:
- **First step** in implementation specification generation
- Activated after the product-agent skill completes
- Followed by architecture-spec, ux-spec, implementation-guide, test-spec, release-spec

The PRD serves as the source of truth for all downstream specifications.

## Notes

- The PRD is a living document - expect iterations
- All features should trace back to solving user pain points from discovery
- Keep stakeholder informed with clear decision points
- Document version history for accountability
