# Integrated Reference Bundle 01

Combines 11 related source skills from `product-release-growth` into one navigable reference file.

## Source map

- `app-store/SKILL.reference.md`
- `app-store/ad-attribution/SKILL.reference.md`
- `app-store/app-description-writer/SKILL.reference.md`
- `app-store/apple-search-ads/SKILL.reference.md`
- `app-store/iap-finalizer/SKILL.reference.md`
- `app-store/keyword-optimizer/SKILL.reference.md`
- `app-store/marketing-strategy/SKILL.reference.md`
- `app-store/originality-check/SKILL.reference.md`
- `app-store/ratings-mechanics/SKILL.reference.md`
- `app-store/rejection-handler/SKILL.reference.md`
- `app-store/review-response-writer/SKILL.reference.md`

## Integrated guidance

### Source: `app-store`

# App Store Optimization & Marketing Skills

Skills for optimizing your app's App Store presence and building promotional strategies — from descriptions to comprehensive marketing campaigns.

## When This Skill Activates

Use this skill when the user:
- Needs to write App Store description or promotional text
- Wants to plan screenshot sequence and captions
- Asks about ASO (App Store Optimization) or keywords
- Needs help responding to App Store reviews
- Wants to improve app discoverability
- Asks about marketing strategy, promotion, or user acquisition
- Wants to use App Store features (events, custom pages, offers, featuring)
- Asks about paid acquisition or Apple Search Ads
- App was rejected or wants to avoid rejection

## Available Skills

### marketing-strategy/ ⭐ NEW
Comprehensive marketing strategy advisor — describe your app and get a tailored promotional plan.
- Analyzes app type, monetization model, audience, and lifecycle stage
- Recommends the right App Store features for your situation
- Builds promotional calendar with implementation roadmap
- Orchestrates generator sub-skills for implementation
- Strategy templates for subscription, paid, freemium, and game apps

### app-description-writer/
Generate compelling App Store descriptions that convert.
- Promotional text (170 chars)
- Full description (4000 chars)
- What's New text for updates
- Localization guidance

### screenshot-planner/
Plan App Store screenshot sequences with captions.
- 5-10 screenshot storyboard
- Caption writing
- Device frame recommendations
- Localization considerations

### keyword-optimizer/
Optimize app title, subtitle, and keywords for search.
- Keyword research methodology
- Character limit optimization (100 chars)
- Competitor analysis
- Localization keyword strategy
- **NEW:** Advanced tactics (cross-localization, screenshot indexing)
- **NEW:** Keyword criteria (Pop/Diff sweet spots, opportunity scoring)
- **NEW:** Existing app strategy (safe optimization)

### review-response-writer/
Professional responses to App Store reviews.
- Templates for common scenarios
- Tone and brand voice guidelines
- Turning negative reviews into opportunities
- When to respond vs. when not to

### apple-search-ads/
Apple Search Ads campaign strategy for indie developers.
- Readiness assessment (minimum thresholds before spending)
- Campaign types and keyword strategy
- Budget planning by app stage (launch, growth, scale)
- Bid optimization with CPT benchmarks by category
- Campaign structure templates and measurement KPIs
- Custom Product Pages integration for ad groups

### ad-attribution/
Privacy-preserving paid-traffic measurement with AdAttributionKit (SKAdNetwork's successor) — install + re-engagement attribution, conversion-value design under crowd anonymity, postback testing. (Apple Ads itself attributes via AdServices — see apple-search-ads.)

### rejection-handler/
Handle App Store rejections and prepare submissions to avoid them.
- Pre-submission audit checklist by guideline section
- Rejection analysis and response strategy
- Resolution Center response templates
- Appeal escalation path (Resolution Center → phone → App Review Board)
- Top 20 common rejections with fixes (common-rejections.md)

### originality-check/
Guideline 4.3 anti-spam / originality gate — verify an app (and each portfolio addition) is meaningfully distinct in function, content, and metadata before you invest or submit.

### iap-finalizer/
Take a one-time In-App Purchase from MISSING_METADATA to READY_TO_SUBMIT via the App Store Connect API — price tier plus localized name/description.

### ratings-mechanics/
How ratings actually behave — per-storefront isolation (your US stars show nowhere else), the never-reset rule, and phased release + manual release as rating protection.

### web-presence/
Discovery outside the store app — the apps.apple.com page as a Google citizen, an owned landing page with Smart App Banner, and the deal-site ecosystem that auto-amplifies price drops.

## Related Generator Skills

These generator skills produce code, metadata, and configuration for App Store features:

| Skill | Purpose |
|-------|---------|
| `generators/subscription-offers` | StoreKit 2 code for all subscription offer types |
| `generators/win-back-offers` | Win-back flow for churned subscribers |
| `generators/promoted-iap` | Promoted In-App Purchase setup |
| `generators/in-app-events` | In-App Event metadata templates |
| `generators/custom-product-pages` | Custom Product Page strategy and metadata |
| `generators/product-page-optimization` | A/B test plans for product page |
| `generators/featuring-nomination` | App Store featuring pitch templates |
| `generators/offer-codes-setup` | Offer code distribution strategies |
| `generators/pre-orders` | Pre-order setup and launch timelines |
| `generators/app-store-assets` | Asset specs for all App Store media |

## How to Use

1. User requests App Store help
2. For strategy questions → Read `marketing-strategy/SKILL.md`
3. For paid acquisition → Read `apple-search-ads/SKILL.md`
4. For rejections or submission prep → Read `rejection-handler/SKILL.md`
5. For specific content → Read the relevant sub-skill's SKILL.md
6. For code/implementation → Read the relevant generator skill
7. Ask clarifying questions about the app
8. Generate optimized content
9. Provide alternatives and explain choices

## Key Principles

### 1. User-Focused Copy
- Lead with benefits, not features
- Speak to user pain points
- Use clear, simple language
- Include social proof where possible

### 2. Platform Guidelines
- Stay within character limits
- Follow Apple's content guidelines
- Avoid prohibited terms (free, best, #1)
- Don't mention competing platforms

### 3. Search Optimization
- Use high-value keywords naturally
- Don't stuff keywords
- Consider localized search terms
- Update for seasonal relevance

### Source: `app-store/ad-attribution`

# Ad Attribution (AdAttributionKit)

You can't optimize paid traffic you can't measure. AdAttributionKit is Apple's
privacy-preserving attribution framework — interoperable with SKAdNetwork, and the go-forward
path (it also works in alternative marketplaces). This skill covers the *advertised-app* side:
what an indie running paid campaigns must implement and how to design conversion signals that
survive privacy thresholds.

Note the seam: **Apple Ads attribution uses the AdServices framework, not AdAttributionKit** —
campaigns there are measured in the Apple Ads console (see `app-store/apple-search-ads`). This
skill is for every *other* paid channel (ad networks, social, publishers).

## When This Skill Activates

- Running or planning paid user acquisition outside Apple Ads
- "How do I know which campaign drove installs?" / measuring re-engagement ads
- Designing or debugging conversion values / postbacks
- Migrating from SKAdNetwork (fully interoperable — registered networks need no re-enrollment)

## How it works (the 60-second model)

Ad network signs an ad (compact JWS impression) → publisher app shows it → user installs (or
re-engages) → after a privacy-delayed measurement window, a **postback** with your conversion
info goes to the ad network (and optionally to you). Attribution requires no user tracking;
the price is coarser data, governed by **crowd anonymity**.

## Conversion-value strategy (the part that's actually yours)

- Two granularities: **fine value 0–63** and **coarse low/medium/high**. Low crowd sizes
  downgrade fine → coarse and can trim the 4-digit campaign `source-identifier` to as few as
  its **first 2 digits** — so encode what matters most (campaign family, geo tier) in the
  first two digits, detail in the rest.
- Map values to *revenue-predictive* early behavior (completed onboarding, trial start, first
  purchase), not vanity events. 64 slots go fast; reserve ranges (e.g. 0–15 activation,
  16–47 monetization ladder, 48–63 reserved).
- Update with `updateConversionValue(_:)` / `PostbackUpdate`; set `lockPostback` when the value
  is final to schedule transmission (still privacy-delayed, never instant).
- Re-engagement postbacks are separate from install postbacks: update them independently via
  `conversionTypes` (.install / .reengagement); the **first re-engagement update must land
  within 48 hours**.
- Multiple simultaneous re-engagement campaigns need **conversion tags** (iOS 18.4+): read the
  tag from the re-engagement URL's query items, store it, and pass it in `PostbackUpdate` —
  without a tag, updates hit only the most recent conversion.

## Publisher-side mechanics (if your app also *shows* ads)

- Click-through: `UIEventAttributionView` over the tappable ad + `appImpression.handleTap()`
  within **15 minutes** of creating the impression.
- View-through: `beginView()`/`endView()` on the same instance; **≥2 seconds** on screen to
  count; one open view-through per network per advertised app.
- `SKOverlay` / `SKStoreProductViewController`: attach the impression — they count view on
  present, click on tap.

## Attribution windows & cooldowns (iOS 18.4+ configurability)

- Defaults: **30 days click-through, 1 day view-through** (install ads).
- Override per ad network and interaction type in Info.plist
  (`AdAttributionKitConfigurations` → `AttributionWindows`); you can ignore "view" or "click"
  (not both) per network.
- Set **cooldowns** (`install-cooldown-hours`, `reengagement-cooldown-hours`) so a
  re-engagement tap minutes after an install isn't double-attributed.
- Country-level postback data (iOS 18.4): storefront country at install, gated behind an extra
  crowd-anonymity tier — a bonus signal when volume allows, never guaranteed.
- Overlapping re-engagement conversions require opting in:
  `EligibleForAdAttributionKitOverlappingConversions` = YES in Info.plist.

## Testing — never ship blind

- **Developer Mode → Settings → Developer → Ad Attribution Testing**: removes time
  randomization, shortens all conversion windows, sends postbacks on demand — full end-to-end
  rehearsal in minutes instead of days.
- Point development postbacks at a **separate dev endpoint**, never production: they're signed
  with a different key (`kid`), the network ID is always `development.adattributionkit`, and
  the advertised item ID may be 0 from Xcode.
- ✅ Verify the postback pipeline before spending a dollar. ❌ Debugging attribution *after*
  a live campaign burns budget on unmeasurable installs.

## Checklist

- [ ] Conversion-value map documented (0–63 + coarse fallback + first-2-digit priority)
- [ ] `lockPostback` fired once value is final; re-engagement first update < 48h
- [ ] Conversion tags wired if >1 re-engagement campaign runs at once
- [ ] Cooldowns configured; windows tuned per network where defaults don't fit
- [ ] Dev-endpoint postback rehearsal done in Developer Mode
- [ ] Campaign readout joined with `growth/analytics-interpretation` (source-type funnel) —
      attribution tells you *which ad*, App Analytics tells you *what they did after*

## References

- https://developer.apple.com/documentation/adattributionkit
- https://developer.apple.com/videos/play/wwdc2024/10060/ (Meet AdAttributionKit)
- https://developer.apple.com/videos/play/wwdc2025/221/ (What's new in AdAttributionKit)
- Related skills: `app-store/apple-search-ads` (Apple Ads uses AdServices, not this), `growth/analytics-interpretation`, `growth/store-growth-audit` (P7.3 halo tracking)

### Source: `app-store/app-description-writer`

# App Description Writer

Generate compelling App Store descriptions that convert browsers into users.

## When This Skill Activates

- User needs to write initial App Store description
- User wants to improve existing description
- User is preparing for a major update
- User asks about promotional text or What's New

## Information Gathering

Before writing, ask about:

1. **App Basics**
   - What does the app do? (one sentence)
   - Who is it for? (target audience)
   - What problem does it solve?

2. **Key Features**
   - Top 3-5 features
   - What makes it unique vs competitors?
   - Any awards or recognition?

3. **Social Proof**
   - Number of users/downloads (if impressive)
   - Notable reviews or press mentions
   - Any partnerships or integrations?

4. **Tone**
   - Professional / Casual / Fun / Technical?
   - Brand voice keywords?

## Output Format

Generate all three text types:

### 1. Promotional Text (170 characters)
- First thing users see
- Should create curiosity or urgency
- Can be updated without app review
- Good for seasonal/sale messaging

### 2. Full Description (4000 characters max)
Structure:
```
[Opening Hook - 1-2 sentences, problem/benefit focused]

[Key Features with emoji bullets]
• Feature 1 - benefit
• Feature 2 - benefit
• Feature 3 - benefit

[Social Proof paragraph - optional]

[How it works - brief explanation]

[Call to action]

[Support/contact info]
```

### 3. What's New (4000 characters)
For updates:
```
[Version X.X highlights]

NEW
• Feature addition

IMPROVED
• Enhancement

FIXED
• Bug fix

Thank you for your feedback!
```

## Best Practices

### Do's
- Lead with the biggest benefit
- Use short paragraphs (2-3 lines max)
- Include relevant keywords naturally
- Use emojis sparingly for scannability
- End with clear call-to-action
- Mention if there's a free trial/tier

### Don'ts
- Don't start with "Welcome to..."
- Don't use ALL CAPS excessively
- Don't include URLs (they're not clickable)

## Examples

### Promotional Text Examples

**Productivity App:**
```
Transform chaos into clarity. The task manager that adapts to how YOU work.
```

**Weather App:**
```
Know before you go. Hyperlocal forecasts down to your street corner. ⛅️
```

**Finance App:**
```
Your money, finally making sense. Budgeting that doesn't feel like homework.
```

### Description Opening Examples

**Problem-First:**
```
Tired of losing track of important tasks? [App] turns your scattered thoughts
into organized action plans in seconds.
```

**Benefit-First:**
```
Capture ideas the moment they strike. [App] is the fastest way to go from
thought to organized note, anywhere.
```

**Curiosity-First:**
```
What if your to-do list actually helped you get things done? Introducing
a smarter way to manage your day.
```

## Localization Tips

When localizing descriptions:
- Don't just translate—adapt to cultural context
- Research local competitors' descriptions
- Adjust feature emphasis by market
- Use native speakers for review
- Consider character limits in other languages (German expands ~30%)

## Character Limits Reference

| Field | Limit |
|-------|-------|
| App Name | 30 characters |
| Subtitle | 30 characters |
| Promotional Text | 170 characters |
| Description | 4000 characters |
| What's New | 4000 characters |
| Keywords | 100 characters |

## Templates

### Template: Utility App
```
[One-line value proposition]

Stop [pain point]. Start [desired outcome].

✨ KEY FEATURES

• [Feature 1] — [Benefit in user terms]
• [Feature 2] — [Benefit in user terms]
• [Feature 3] — [Benefit in user terms]
• [Feature 4] — [Benefit in user terms]

💡 HOW IT WORKS

[2-3 sentences explaining the core flow]

🎯 PERFECT FOR

• [User type 1]
• [User type 2]
• [User type 3]

[Social proof if available]

Download now and [call to action with benefit].

Questions? We're here to help: [support email]
```

### Template: Creative App
```
[Evocative opening that sparks imagination]

[App Name] puts [creative power] in your pocket.

🎨 CREATE

• [Creative feature 1]
• [Creative feature 2]
• [Creative feature 3]

📤 SHARE

• [Sharing/export feature]
• [Community feature if applicable]

🔓 UNLOCK YOUR CREATIVITY

[Inspirational paragraph about what users can achieve]

Join [X] creators already using [App Name].

[Call to action]
```

### Template: What's New
```
Thanks for using [App Name]! Here's what's new in version X.X:

🆕 NEW
• [Major new feature with brief explanation]

⚡️ IMPROVED
• [Performance improvement]
• [UX enhancement]

🔧 FIXED
• [Bug fix users complained about]

Love [App Name]? Leave us a review — it helps more than you know! 💙

Feedback? [support email]
```

### Source: `app-store/apple-search-ads`

# Apple Search Ads for Indie Developers

Plan, launch, and optimize Apple Search Ads campaigns that deliver profitable user acquisition for indie apps.

## When This Skill Activates

Use this skill when the user:
- Asks about paid user acquisition or running ads for their app
- Mentions "Apple Search Ads", "Search Ads", or "ASA"
- Wants to set up ad campaigns in the App Store
- Asks about keyword bidding, CPT, or CPA optimization
- Needs help with campaign structure or budget allocation
- Wants to understand if paid acquisition makes sense for their app
- Asks how to complement ASO with paid promotion

## Pre-Requisite Check: Are You Ready for Ads?

Before recommending any campaign setup, verify these minimum thresholds. Running ads on an unoptimized listing burns money.

### Minimum Thresholds

| Requirement | Threshold | Why |
|-------------|-----------|-----|
| Organic downloads | 100+/month | Proves baseline demand exists |
| App Store page CVR | > 20% | Ads amplify your listing — a bad listing wastes spend |
| Screenshots | 5+ optimized | Paid traffic sees your product page first |
| Ratings | 3.5+ stars (or none) | Low ratings kill conversion from ads |
| Crash-free rate | > 99% | Crashes destroy ROAS through refunds and bad reviews |
| Monetization | Active | No point acquiring users you can't monetize |

**If thresholds are not met:**
- Focus on organic ASO first (use `keyword-optimizer` skill)
- Fix product page conversion (use `screenshot-planner` and `app-description-writer` skills)
- Improve app quality and ratings before spending on acquisition

### Readiness Decision

```
Have 100+ organic downloads/month?
├── NO → Stop. Fix organic first.
└── YES → Is your product page CVR > 20%?
    ├── NO → Optimize listing first, then run ads.
    └── YES → Ready for Apple Search Ads.
```

## Campaign Types

Apple Search Ads offers four placement types. Not all are useful for indie developers. All placements price as **cost-per-tap on a second-price auction** — you pay just above the next-highest bid, never your max — with **no minimum spend**, and daily budgets are adjustable anytime.

### Search Results (Recommended Starting Point)

- **Where**: Top of search results when users search specific keywords
- **Targeting**: Keyword-based (exact match or broad match)
- **Cost model**: Cost Per Tap (CPT)
- **Best for**: High-intent users actively looking for your category
- **Indie priority**: Start here. This is where you get the most control and best ROAS.

### Search Tab

- **Where**: Top of the Search tab before user types anything
- **Targeting**: Audience-based (demographics, customer type)
- **Cost model**: Cost Per Tap (CPT)
- **Best for**: Brand awareness and discovery
- **Indie priority**: Use after Search Results campaigns are profitable. Good for launch visibility.

### Today Tab

- **Where**: Today tab in the App Store
- **Targeting**: Audience-based
- **Cost model**: Cost Per Tap (CPT)
- **Requirements**: Ads always come from a Custom Product Page with **≥4 portrait or ≥5 landscape assets**, and undergo a separate creative review
- **Best for**: Mass awareness, seasonal pushes
- **Indie priority**: Usually too expensive for indie budgets. Skip unless budget allows $500+/day.

### Product Page (You Might Also Like)

- **Where**: "You Might Also Like" section on other apps' product pages
- **Targeting**: Audience and category-based
- **Cost model**: Cost Per Tap (CPT)
- **Best for**: Reaching users browsing competitor or related apps
- **Indie priority**: Good second campaign after Search Results. Lower intent but can find relevant users.

### Recommended Progression for Indie Developers

```
Stage 1: Search Results (exact match keywords)
    ↓ profitable?
Stage 2: Search Results (broad match for discovery)
    ↓ profitable?
Stage 3: Product Page (competitor audiences)
    ↓ profitable?
Stage 4: Search Tab (brand awareness)
```

### Discovery Campaigns as Keyword Research

Beyond acquisition, a low-budget broad-match discovery campaign is the cheapest source of Apple's official keyword popularity data and the real queries users type. Even if it never turns a profit, harvest the Search Terms report into your organic metadata — see `keyword-optimizer` advanced tactics (§14) for the quarterly routine.

## Keyword Strategy

### Keyword Categories

**1. Brand Keywords (Your App Name)**
- Bid on these ONLY if competitors are bidding on your name
- Check by searching your app name — if a competitor appears above you, bid
- Otherwise, save the budget; you already rank #1 organically

**2. Category Keywords (Generic Terms)**
- Examples: "todo app", "weather radar", "habit tracker"
- High volume, high competition, expensive
- Target long-tail variants: "simple todo app", "habit tracker no account"
- These are your bread and butter for growth

**3. Competitor Keywords (Rival App Names)**
- Legal and common practice in Apple Search Ads
- Lower conversion (users wanted the other app) but can be effective
- Best when your app has a clear advantage over that competitor
- Use Custom Product Pages to message directly against competitors

**4. Discovery Keywords (Problem/Solution)**
- Examples: "stop procrastinating", "save money automatically", "focus while studying"
- Lower volume but very high intent
- Often cheapest CPT because few advertisers target them
- Excellent ROAS potential

### The ASA → Organic Halo

Paid conversions on a keyword lift that keyword's **organic** rank — Apple's algorithm reads them as conversion velocity. Two implications:

- Run exact-match campaigns on your target organic terms to accelerate ranking while metadata changes take hold
- Always defend your brand term once competitors bid on it — brand CPAs are the cheapest in your account, and losing the top slot bleeds organic installs too

### Keyword Research Process

1. **Start with brainstorming** — List 50+ terms a user might search
2. **Use Search Ads keyword suggestions** — Apple provides recommendations in the campaign manager
3. **Mine your ASO research** — Keywords from `keyword-optimizer` skill that you can't rank organically
4. **Check autocomplete** — Type partial queries in the App Store
5. **Analyze competitors** — What keywords trigger their ads?
6. **Use Search Ads intelligence tools** — SearchAds.com, SplitMetrics Acquire, AppTweak

### Keyword Selection Criteria

| Factor | Target | Notes |
|--------|--------|-------|
| Relevance | High | Only bid on keywords your app genuinely serves |
| Search volume | Medium-High | Low volume = too few impressions to matter |
| Competition | Low-Medium | High competition = expensive CPT |
| Intent | Transactional | "best X app" > "what is X" |

## Budget Planning

### Budget by App Stage

| Stage | Daily Budget | Monthly Budget | Strategy |
|-------|-------------|----------------|----------|
| **Launch** (first 30 days) | $10-30/day | $300-900 | Discovery, keyword validation |
| **Growth** (months 2-6) | $50-100/day | $1,500-3,000 | Scale winners, cut losers |
| **Scale** (6+ months) | $100+/day | $3,000+ | Maximize profitable keywords |

### Launch Budget Allocation

```
Total: $20/day example

Search Results (Exact Match): $12/day (60%)
  → 10-15 carefully chosen keywords
  → Focus on category + discovery keywords

Search Results (Broad Match): $5/day (25%)
  → 3-5 broad terms for keyword discovery
  → Mine Search Terms report weekly for new exact match targets

Product Page Ads: $3/day (15%)
  → Target 2-3 competitor categories
  → Test which audiences convert
```

### When to Increase Budget

- ROAS > 1.5x target → Increase budget 20-30%
- High impression share on profitable keywords → Increase bid, not budget
- Discovered new profitable keyword clusters → Add budget for new ad groups

### When to Decrease Budget

- ROAS < 0.5x target for 7+ days → Pause or reduce
- CPT climbing with flat CVR → Market is getting competitive, reassess
- Seasonal dip in your category → Reduce and wait

## Bid Optimization

### CPT Benchmarks by Category

These are approximate ranges for the US market. Actual CPT varies by competition and keyword.

| Category | Low CPT | Median CPT | High CPT |
|----------|---------|------------|----------|
| Utilities | $0.30 | $0.80 | $2.00 |
| Productivity | $0.50 | $1.50 | $4.00 |
| Health & Fitness | $0.60 | $1.80 | $5.00 |
| Finance | $1.00 | $3.00 | $8.00 |
| Games (Casual) | $0.20 | $0.60 | $1.50 |
| Games (Mid-core) | $0.50 | $1.50 | $4.00 |
| Education | $0.40 | $1.20 | $3.00 |
| Photo & Video | $0.30 | $1.00 | $3.00 |
| Social | $0.40 | $1.20 | $3.50 |
| Shopping | $0.50 | $1.50 | $4.00 |

### Bid Strategy

**Starting bids:**
- Set initial bids at the median CPT for your category
- Let campaigns run for 3-5 days before adjusting
- Need at least 100 impressions per keyword to evaluate

**Raise bids when:**
- Impression share is low on a profitable keyword (you're being outbid)
- CVR is high but volume is low (more taps would mean more installs)
- ROAS is well above target (room to pay more per user)

**Lower bids when:**
- CPT is above your CPA target and CVR is average
- Impressions are high but TTR is low (keyword may not be relevant)
- ROAS is negative after 7+ days of data

**Pause keywords when:**
- 1000+ impressions, zero installs
- CPA is 3x+ your target after 14 days
- Keyword is clearly irrelevant (check Search Terms report)

## Custom Product Pages Integration

Apple Search Ads supports linking ad groups to Custom Product Pages (CPPs) for tailored messaging.

### When to Use CPPs with Ads

| Scenario | CPP Strategy |
|----------|-------------|
| Competitor keywords | Highlight advantages over that competitor |
| Feature keywords | Show the specific feature being searched |
| Audience segments | Different messaging for students vs. professionals |
| Seasonal campaigns | Holiday or event-themed screenshots/descriptions |

### The Pairing Rule

Every exact-match ad group should point to a CPP whose **first screenshots match that keyword's intent** — 35 CPP slots is enough for every major keyword theme. A user searching "habit tracker" who lands on habit-first screenshots taps through and converts measurably better than one landing on your default page.

### CPP Setup for Ads

1. Create Custom Product Pages in App Store Connect (max 35)
2. Design screenshots and promotional text for each audience
3. In Search Ads, create separate ad groups per CPP
4. Assign relevant keywords to each ad group
5. Monitor CVR per CPP to see which messaging converts best

Use the `generators/custom-product-pages` skill for CPP metadata and strategy.

## Campaign Structure Template

### Recommended Organization

```
CAMPAIGN: [App Name] - Search Results
├── AD GROUP: Brand Defense
│   ├── Keywords: [your app name], [your app name + category]
│   ├── Match: Exact
│   ├── CPP: Default product page
│   └── Budget: 10% of campaign
│
├── AD GROUP: Category - Core
│   ├── Keywords: [top 10 category terms, exact match]
│   ├── Match: Exact
│   ├── CPP: Feature-focused product page
│   └── Budget: 40% of campaign
│
├── AD GROUP: Category - Discovery
│   ├── Keywords: [5 broad category terms]
│   ├── Match: Broad
│   ├── Negative keywords: [brand terms, irrelevant terms]
│   ├── CPP: Default product page
│   └── Budget: 20% of campaign
│
├── AD GROUP: Competitor
│   ├── Keywords: [competitor app names]
│   ├── Match: Exact
│   ├── CPP: Comparison-focused product page
│   └── Budget: 15% of campaign
│
└── AD GROUP: Problem/Solution
    ├── Keywords: [pain point searches]
    ├── Match: Exact
    ├── CPP: Problem-solution product page
    └── Budget: 15% of campaign

CAMPAIGN: [App Name] - Product Page
├── AD GROUP: Related Category
│   └── Audience: Users browsing [related category]
└── AD GROUP: Competitor Users
    └── Audience: Users viewing [competitor apps]
```

## Measurement & KPIs

### Key Metrics

| Metric | Definition | Target Range |
|--------|-----------|--------------|
| **TTR** (Tap-Through Rate) | Taps / Impressions | 5-12% |
| **CVR** (Conversion Rate) | Installs / Taps | 30-60% |
| **CPT** (Cost Per Tap) | Spend / Taps | Category-dependent (see benchmarks) |
| **CPA** (Cost Per Acquisition) | Spend / Installs | < Customer LTV |
| **ROAS** (Return on Ad Spend) | Revenue / Spend | > 1.0 (ideally > 2.0) |

Apple cites **~60% average conversion rate** for search ads — if your CVR sits well below that, the product page (not the bid) is the problem. Also test the campaign destination: full product page vs. in-app store sheet (`SKStoreProductViewController`) — "the choice you make may meaningfully impact your conversion" (per Apple's App Analytics Tech Talk).

### Interpreting Metrics

**High TTR + Low CVR:**
- Your ad is attractive but your product page doesn't convert
- Fix: Improve screenshots, description, ratings
- Check: Is the keyword truly relevant to your app?

**Low TTR + High CVR:**
- Users who do tap convert well, but few are tapping
- Fix: Raise bid to get better placement, review keyword relevance
- Consider: Your app name/icon may not stand out in results

**High CPA + High CVR:**
- You're paying too much per tap but converting well
- Fix: Find cheaper keywords with similar intent
- Consider: Lower bids and accept fewer impressions

**Low CPA + Low ROAS:**
- Cheap installs but users aren't monetizing
- Fix: Check onboarding-to-conversion funnel, not the ad
- Consider: The keyword may attract wrong user segment

### Reporting Cadence

| Frequency | What to Check | Action |
|-----------|---------------|--------|
| Daily | Spend, CPA | Pause runaway spend |
| Weekly | Keyword performance, Search Terms | Add negatives, find new keywords |
| Bi-weekly | ROAS, campaign-level metrics | Adjust bids, reallocate budget |
| Monthly | Overall ROI, LTV/CPA ratio | Strategic changes, new campaigns |

## Common Mistakes

### 1. Bidding on Your Own Brand Name Too Early

- You already rank #1 organically for your name
- Brand defense is only needed when competitors actively bid on your name
- Check first by searching — if no competitor ad appears, save the budget

### 2. Starting with Broad Match Only

- Broad match burns budget on irrelevant queries
- Always start with exact match on validated keywords
- Use broad match in a separate, low-budget discovery ad group
- Mine the Search Terms report to find exact match winners

### 3. No Negative Keywords

- Without negative keywords, broad match campaigns waste 30-50% of spend
- Add negative keywords weekly from Search Terms report
- Pre-load obvious negatives: competitor names in discovery groups, unrelated terms

### 4. Running Ads Before Optimizing Your Listing

- Ads drive traffic to your product page — if it doesn't convert, ads just cost money
- Optimize screenshots, description, and ratings FIRST
- Target 30%+ CVR organically before turning on ads

### 5. Setting Daily Budget Too High Initially

- Start small ($10-20/day) to gather data
- Scale only after 2+ weeks of data confirms profitability
- A $100/day budget on day one with no data is gambling, not marketing

### 6. Ignoring the Search Terms Report

- This is the most valuable data Apple gives you
- Shows ACTUAL queries that triggered your broad match ads
- Review weekly, add winners as exact match, add losers as negatives

### 7. Not Linking Custom Product Pages

- Generic product page for all keyword intents wastes conversion potential
- Different searchers need different messaging
- Even 2-3 CPPs can significantly improve CVR

### 8. Expecting Instant Results

- Apple Search Ads needs 7-14 days minimum to gather meaningful data
- Don't change bids daily — let data accumulate
- Statistical significance requires volume: aim for 100+ taps per keyword before judging

## Output Format

When advising on Apple Search Ads, produce this document:

```markdown
# Apple Search Ads Strategy: [App Name]

## Readiness Assessment
| Requirement | Status | Notes |
|-------------|--------|-------|
| Organic downloads | ✅/❌ | [X/month] |
| Product page CVR | ✅/❌ | [X%] |
| Screenshots | ✅/❌ | [X screenshots] |
| Ratings | ✅/❌ | [X.X stars] |
| Crash-free rate | ✅/❌ | [X%] |
| Monetization | ✅/❌ | [Model] |

**Verdict**: [Ready / Optimize first / Not ready]

## Recommended Campaign Structure

### Campaign 1: [Name]
- **Type**: [Search Results / Product Page / etc.]
- **Daily budget**: $X
- **Ad groups**: [List]

### Ad Group: [Name]
- **Keywords**: [List with match type]
- **Starting CPT bid**: $X.XX
- **Custom Product Page**: [Default / specific CPP]
- **Target CPA**: $X.XX

[Repeat for each ad group]

## Keyword Plan

| Keyword | Match | Category | Est. CPT | Priority |
|---------|-------|----------|----------|----------|
| [keyword] | Exact | Category | $X.XX | High |
| [keyword] | Exact | Discovery | $X.XX | High |
| [keyword] | Broad | Discovery | $X.XX | Medium |

## Budget Summary

| Campaign | Daily | Monthly | % of Total |
|----------|-------|---------|------------|
| [Campaign 1] | $X | $X | X% |
| [Campaign 2] | $X | $X | X% |
| **Total** | **$X** | **$X** | **100%** |

## KPI Targets

| Metric | Target | Review Frequency |
|--------|--------|-----------------|
| TTR | X% | Weekly |
| CVR | X% | Weekly |
| CPA | $X.XX | Bi-weekly |
| ROAS | X.Xx | Monthly |

## Negative Keywords (Pre-loaded)
- [List of terms to exclude from broad match]

## Week 1-2 Action Items
1. [First thing to set up]
2. [Second thing to set up]
3. [Third thing to set up]

## Month 1 Review Checklist
- [ ] Review Search Terms report
- [ ] Add negative keywords
- [ ] Evaluate keyword-level ROAS
- [ ] Adjust bids on top/bottom performers
- [ ] Consider CPP creation for top ad groups
```

## References

- Related: `app-store/keyword-optimizer` — ASO keyword strategy (organic, complements paid)
- Related: `app-store/screenshot-planner` — Product page optimization (improves ad CVR)
- Related: `generators/custom-product-pages` — Custom Product Page creation for ad groups
- Related: `app-store/marketing-strategy` — Overall marketing strategy including paid acquisition
- Apple Search Ads documentation: https://searchads.apple.com

### Source: `app-store/iap-finalizer`

# IAP Finalizer

Finish a **one-time** in-app purchase on the store side: **price + localization**, the two fields the `asc-metadata` MCP can't set (it exposes only reference name / review note / family-sharing). Moves an IAP from `MISSING_METADATA` → `READY_TO_SUBMIT` so it can ship with the build.

> **This finalizes; it does not define.** The product id, tier, and price *decision* come from Phase 4 (Monetization / StoreKit). The ASC IAP record must already exist (created via the MCP `create_iap` or the ASC UI). This skill sets the metadata on that existing record.

## Where it fits (read the seams)

- **Not Phase 4.** Phase 4 builds the IAP *into the app* (StoreKit 2, paywall) and *decides* the price. This is Phase 6 store-metadata finalization.
- **Price = one source of truth.** Do **not** re-ask the price. **Read it** from the monetization decision in `.planning/` (e.g. `MONETIZATION.md` / `PLAN.md`); only *confirm* it. Re-eliciting risks drift from the paywall/StoreKit price.
- **Not `promoted-iap`.** That generator displays promoted IAPs in-app; this sets ASC price/localization. Different jobs.
- **One-time IAPs only.** Subscriptions are a separate ASC flow (groups/offers) — out of scope here.

## Prerequisites

- `_shared/asc-api/` set up (see its README — key + `~/.appstoreconnect/`).
- Set `ASC="python3 <path to asc.py>"`. `asc.py` lives at `_shared/asc-api/asc.py` under the same `skills/` root as this skill — resolve it **relative to this SKILL.md file's location** (`../../_shared/asc-api/asc.py` from this skill's directory), never relative to the project cwd (skills run with cwd = the user's project). Known install locations:
  - SwiftShip symlink install: `~/.claude/swiftship-skills/_shared/asc-api/asc.py`
  - Copied install: `.claude/skills/_shared/asc-api/asc.py` (project) or `~/.claude/skills/_shared/asc-api/asc.py` (global)
  - Plugin install: resolve from this file's location — the `_shared/` tree ships with the plugin.
- The IAP already exists in ASC. Get its id with the MCP: `list_iap` → pick the product.
- Price decided in Phase 4. Read it from `.planning/` and confirm — don't invent it.

## Flow — dry-run → confirm → apply

1. **Confirm state.** MCP `get_iap` → current state + `productId`. Read the target price + Display Name (≤30) + Description (≤45) from `.planning/`; confirm with the user via `AskUserQuestion` if anything is missing.
2. **Find the price point.**
   ```
   $ASC GET "/v1/inAppPurchases/<IAP_ID>/pricePoints?filter[territory]=USA"
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
6. **Verify:** MCP `get_iap` → state no longer `MISSING_METADATA`.

## Done

- IAP priced + localized in ASC; state advanced; ready to submit with the build.

## Caveats

- **Verify each endpoint/field against the current [ASC API reference](https://developer.apple.com/documentation/appstoreconnectapi) before `--apply`** (captured 2026-07).
- Every write is **dry-run first** — show the body, confirm, then `--apply`. Never `--apply` a price the user hasn't seen.
- One-time IAPs only. Subscriptions → the MCP `create_subscription*` tools + a separate flow.

### Source: `app-store/keyword-optimizer`

# Keyword Optimizer

Optimize app title, subtitle, and keywords for maximum App Store discoverability.

## When This Skill Activates

- User is launching a new app
- User wants to improve search rankings
- User asks about ASO (App Store Optimization)
- User is entering new markets/languages
- User wants to analyze keyword opportunities
- User needs safe optimization for existing apps

## Reference Files

Before optimizing, load these reference materials:

| File | Purpose |
|------|---------|
| **keyword-criteria.md** | Popularity/Difficulty sweet spots, opportunity scoring |
| **advanced-tactics.md** | Cross-localization, screenshot indexing, velocity boost |
| **existing-app-strategy.md** | Safe optimization for apps with existing traffic |

## Information Gathering

Before optimizing, ask about:

1. **App Identity**
   - What does the app do in one sentence?
   - What category is it in?
   - What's the current app name (if exists)?

2. **Target Keywords**
   - What would users search to find this app?
   - What problem words would they use?
   - Any branded terms to include?

3. **Competition**
   - Main competitors?
   - What keywords do they target?
   - Where can you realistically compete?

4. **Goals**
   - Brand awareness vs. category traffic?
   - Specific markets to prioritize?

## Keyword Strategy

### Where Keywords Count

| Field | Limit | Weight | Notes |
|-------|-------|--------|-------|
| **App Name** | 30 chars | Highest | Most valuable real estate |
| **Subtitle** | 30 chars | High | Visible in search, below name |
| **Keywords** | 100 chars | Medium | Not visible to users |
| **Description** | 4000 chars | Low* | *Apple says indexed, debated |

### Keyword Types

1. **Branded** - Your app name, company name
2. **Category** - Generic terms (e.g., "todo app", "weather")
3. **Feature** - Specific functionality (e.g., "offline maps")
4. **Problem** - User pain points (e.g., "forget tasks")
5. **Long-tail** - Specific phrases (e.g., "minimalist habit tracker")

## Optimization Process

### Step 1: Keyword Research

**Generate Initial List:**
```
1. Brainstorm 50+ keywords
2. What would YOU search for this app?
3. Check competitor names/subtitles
4. Use autocomplete suggestions
5. Consider misspellings users make
```

**Research Tools:**
- App Store Search Autocomplete
- AppFollow, Sensor Tower, AppTweak (paid)
- Google Keyword Planner (related terms)
- Competitor subtitle/keyword analysis

### Step 2: Prioritize Keywords

Rate each keyword on:

| Factor | Question |
|--------|----------|
| **Relevance** | Does it accurately describe your app? |
| **Volume** | Do people actually search this? |
| **Difficulty** | Can you realistically rank? |
| **Intent** | Will searchers want your app? |

**Priority Matrix:**
```
High Volume + Low Difficulty = 🎯 Target First
High Volume + High Difficulty = 💪 Long-term Goal
Low Volume + Low Difficulty = ✅ Easy Wins
Low Volume + High Difficulty = ❌ Skip
```

### Step 3: Allocate Keywords

**App Name (30 characters):**
```
[Brand Name] - [Top Keyword Phrase]
or
[Brand Name]: [Value Proposition]

Examples:
"Notion - Notes & Docs"
"Calm: Sleep & Meditation"
"Fantastical - Calendar & Tasks"
```

**Subtitle (30 characters):**
```
[Second Priority Keywords] / [Unique Value]

Examples:
"Focus Timer & Daily Planner"
"Simple Habit Building"
"Weather Radar & Forecasts"
```

**Keywords Field (100 characters):**
```
Rules:
- Comma-separated, NO spaces after commas
- No plurals (Apple handles it)
- No duplicates from name/subtitle
- No category name (already indexed)
- Single words perform better than phrases

Example:
"timer,pomodoro,focus,concentration,study,productivity,work,session,break,technique"
```

## Character Optimization

### Maximize 100 Characters

**Bad (wastes characters):**
```
task manager, todo list, productivity app, reminder app, checklist
```

**Good (efficient):**
```
task,todo,productivity,reminder,checklist,planner,organize,gtd,schedule,daily
```

**Savings:**
- Remove spaces after commas
- Don't repeat words in different forms
- Skip obvious words (app, free, best)

### Word Combinations

Apple combines words from all fields:

```
Name: "Focus Timer"
Subtitle: "Pomodoro Technique"
Keywords: "study,productivity,work,session"

Searchable combinations:
- "focus timer"
- "pomodoro timer"
- "focus productivity"
- "study timer"
- "work focus"
(and more...)
```

## Cross-Field Deduplication

Apple indexes words from **all three fields** for the same locale — a word only needs to appear **once**. If a word appears in Title, don't repeat it in Subtitle or Keywords; if it appears in Subtitle, don't repeat it in Keywords.

### Before & After Example

```
❌ BEFORE (duplicated words waste ~38 characters):
Title:    "Focus Timer - Stay Productive"
Subtitle: "Pomodoro Timer & Focus Sessions"
Keywords: "timer,focus,pomodoro,productive,study,work,session,break"

✅ AFTER (zero duplication, 5 new keywords gained):
Title:    "Focus Timer - Stay Productive"
Subtitle: "Pomodoro Technique & Deep Work"
Keywords: "study,concentration,interval,tomato,distraction,block,exam,revision,flowstate,desk"
```

### Quick Dedup Check

| Check | Rule |
|-------|------|
| Title word in Subtitle or Keywords? | Remove from the lower field |
| Subtitle word in Keywords? | Remove from Keywords |
| Plural/singular variant across fields? | Keep only in highest field |
| Stop words (a, the, and, for)? | Don't include anywhere — auto-indexed |

## Common Mistakes

❌ **Don't Do This:**
- Using spaces after commas in keywords
- Duplicating words across fields
- Including your category name
- Using competitor brand names
- Adding "app" or "application"
- Including "free" (filterable separately)
- Using special characters or emoji
- Repeating singular/plural forms

✅ **Do This:**
- Research before guessing
- Prioritize relevance over volume
- Update keywords quarterly
- Track ranking changes
- Localize keywords per market

## Keyword Template

```
APP NAME STRATEGY
━━━━━━━━━━━━━━━━━
Current: [existing name or blank]
Proposed: [Brand] - [Keywords]
Characters: [X/30]
Primary keywords: [list]

SUBTITLE STRATEGY
━━━━━━━━━━━━━━━━━
Current: [existing subtitle or blank]
Proposed: [keyword-rich subtitle]
Characters: [X/30]
Secondary keywords: [list]

KEYWORDS FIELD (100 chars)
━━━━━━━━━━━━━━━━━━━━━━━━━
Proposed: keyword1,keyword2,keyword3,...
Characters: [X/100]

EXPECTED COMBINATIONS
━━━━━━━━━━━━━━━━━━━━━
• [combination 1]
• [combination 2]
• [combination 3]
...
```

## Localization Strategy

### Priority Markets by Revenue

1. 🇺🇸 United States (English)
2. 🇨🇳 China (Simplified Chinese)
3. 🇯🇵 Japan (Japanese)
4. 🇬🇧 UK (British English - can differ!)
5. 🇩🇪 Germany (German)
6. 🇫🇷 France (French)
7. 🇰🇷 South Korea (Korean)
8. 🇪🇸 Spain (Spanish)
9. 🇮🇹 Italy (Italian)
10. 🇧🇷 Brazil (Portuguese)

### Localization Tips

- Don't just translate—research local search terms
- Some markets search in English even for local apps
- Character limits may be tighter in some languages
- Hire native speakers to verify keywords make sense
- Consider cultural differences in app usage

## Tracking & Iteration

### What to Track

- Keyword rankings (use ASO tools)
- Impressions (App Store Connect)
- Conversion rate
- Download sources

### When to Update

- **Weekly:** Check ranking changes
- **Monthly:** Assess underperforming keywords
- **Quarterly:** Major keyword refresh
- **Seasonally:** Add seasonal keywords

### A/B Testing

App Store Connect allows testing:
- App icons
- Screenshots
- App previews

Use Product Page Optimization to test different approaches.

## Quick Reference

### Prohibited Terms
- "Free" (use pricing filter instead)
- "#1" or "best" without verification
- Competitor names
- "App" or "application"
- Pricing information

### Always Include
- Core functionality words
- Problem/solution words
- Category-relevant terms
- Action verbs users would search

### Character Limits
```
App Name:      30 characters
Subtitle:      30 characters
Keywords:     100 characters
Description: 4000 characters (low SEO value)
```

## Indie Developer Strategy

For building apps that generate $200-2,000/month:

### The Sweet Spot Formula
```
Target keywords where:
- Popularity > 20 (enough traffic)
- Difficulty < 60 (beatable competition)

Ideal: Popularity 25-50, Difficulty < 45
```

### Process
1. Find underserved keywords using ASO tools (Astro, AppTweak)
2. Build simple, single-feature apps around those keywords
3. Double down on winners, abandon losers
4. Portfolio effect compounds (30 apps × $500 = $15k/month)

See **keyword-criteria.md** for detailed scoring and evaluation.

## Advanced Tactics Summary

### Cross-Localization (Double Keywords)
Add Spanish (Mexico) locale with English keywords for US market.
See **advanced-tactics.md** for all locales.

### Screenshot Text Indexing (June 2025)
Apple OCR reads screenshot captions for keyword ranking.
Put keywords in top/bottom of screenshots.

### Existing App Optimization
Never change what's working. Use phased rollout.
See **existing-app-strategy.md** for safe optimization.

### Source: `app-store/marketing-strategy`

# App Store Marketing Strategy

Analyzes your app's type, monetization model, audience, and lifecycle stage, then builds a tailored promotional strategy using Apple's App Store features. Calls relevant sub-skills to generate implementation code and metadata.

## When This Skill Activates

Use this skill when the user:
- Asks "how should I market my app?" or "what App Store features should I use?"
- Wants a promotional strategy for launch, growth, or re-engagement
- Mentions "App Store promotion", "user acquisition", or "app marketing"
- Wants to increase downloads or reduce churn
- Asks about in-app events, custom product pages, or win-back offers
- Is preparing for a major update or seasonal campaign
- Wants to get featured on the App Store

## Process

### Phase 1: App Profile Collection

Gather information via AskUserQuestion:

**1. App Identity**
- App name and one-line description
- App Store category (primary + secondary)
- Platform(s): iOS, macOS, iPadOS, watchOS, visionOS

**2. Monetization Model**
- Free (ad-supported)
- Freemium (free + IAP/subscription)
- Paid upfront
- Subscription only
- Free (no monetization yet)

**3. Target Audience**
- Primary demographic (age, role, context)
- Secondary audience (if any)
- Geographic focus

**4. Lifecycle Stage**
- Pre-launch (building / TestFlight)
- Launch (first 30 days)
- Growth (active, adding users)
- Mature (stable user base, seeking retention)
- Re-engagement (declining, need to win back users)

**5. Current State**
- Monthly active users (approximate)
- Existing promotional features already configured
- Upcoming updates or milestones
- Marketing budget (none / small / moderate)

### Phase 2: Strategy Analysis

Read **decision-matrix.md** to map the app profile to recommended features.

The decision matrix evaluates these dimensions:
- Monetization model → Which offer types apply
- Lifecycle stage → Which tactics are highest priority
- App category → Which featuring angles work
- Audience segments → Whether custom product pages help
- Content/events → Whether in-app events fit
- **Minimum eligibility thresholds** → Whether the app has sufficient scale for each feature

**CRITICAL — Check Eligibility Before Recommending:**
Not every feature makes sense at every scale. The decision matrix (Dimension 6) defines minimum thresholds. Features that require traffic volume (PPO, CPPs) or user base size (win-back, promotional offers) should NOT be recommended for apps below those thresholds. Instead, recommend the alternatives specified in the matrix. Always be honest about what will and won't work at the app's current scale — recommending PPO to an app with 200 impressions/month wastes their time.

### Phase 3: Strategy Generation

Based on the analysis, read the appropriate strategy template:
- `strategy-templates/subscription-app.md` — For subscription-based apps
- `strategy-templates/paid-app.md` — For paid upfront apps
- `strategy-templates/freemium-app.md` — For freemium with IAP
- `strategy-templates/game-app.md` — For games (any monetization)

Customize the template with the app's specific details.

### Phase 4: Implementation Roadmap

For each recommended feature, provide:
1. **Priority** (High / Medium / Low)
2. **Effort** (Quick win / Moderate / Significant)
3. **Expected impact** on the primary goal (downloads, retention, revenue)
4. **Implementation skill** to call for code/metadata generation

#### Available Sub-Skills

| Feature | Generator Skill | What It Produces |
|---------|----------------|------------------|
| Introductory/promotional offers | `generators/subscription-offers` | StoreKit 2 offer code + eligibility |
| Win-back campaigns | `generators/win-back-offers` | Win-back flow + Message API handling |
| Promoted IAP on product page | `generators/promoted-iap` | StoreKit 2 promoted purchase setup |
| In-App Events | `generators/in-app-events` | Event metadata + image specs |
| Custom Product Pages | `generators/custom-product-pages` | Page metadata + screenshot strategy |
| Product Page Optimization | `generators/product-page-optimization` | A/B test plan + optimization checklist |
| App Store featuring | `generators/featuring-nomination` | Nomination form + pitch template |
| Offer codes distribution | `generators/offer-codes-setup` | Distribution strategy + configuration |
| Pre-launch / pre-orders | `generators/pre-orders` | Pre-order setup + launch timeline |
| Promotional assets | `generators/app-store-assets` | Asset specs + guidelines |

### Phase 5: Timeline & Calendar

Build a promotional calendar based on:
- App launch date or next update
- Seasonal opportunities (back to school, holidays, New Year)
- Apple events (WWDC, iPhone launch, etc.)
- Category-specific timing (tax season for finance, January for fitness)

## Output Format

Present the strategy as:

```markdown
# Marketing Strategy: [App Name]

## App Profile
| Attribute | Value |
|-----------|-------|
| Category | [Category] |
| Model | [Monetization model] |
| Stage | [Lifecycle stage] |
| Audience | [Primary audience] |
| Platform | [Platforms] |

## Strategic Goals
1. [Primary goal based on lifecycle stage]
2. [Secondary goal]
3. [Tertiary goal]

## Recommended Features (Eligible Now)

### 🔴 High Priority

#### [Feature Name]
- **Why**: [Rationale for this app]
- **Effort**: [Quick win / Moderate / Significant]
- **Impact**: [Expected outcome]
- **Skill**: `generators/[skill-name]`
- **Action**: [Specific next step]

### 🟠 Medium Priority
[Same format]

### 🟢 Nice to Have
[Same format]

## Not Yet Recommended (Scale Thresholds Not Met)

| Feature | Minimum Needed | Your Current Level | When to Revisit |
|---------|---------------|-------------------|-----------------|
| [Feature] | [Threshold] | [Current metric] | [Milestone to hit] |

> These features will become effective once you reach the indicated thresholds.
> Focus on the eligible features above to grow toward these milestones.

## Promotional Calendar

| Month | Action | Feature | Notes |
|-------|--------|---------|-------|
| [M1] | [Action] | [Feature] | [Context] |
| [M2] | [Action] | [Feature] | [Context] |

## Implementation Order

1. **Week 1-2**: [First actions — quick wins]
2. **Week 3-4**: [Second wave — moderate effort]
3. **Month 2**: [Bigger initiatives]
4. **Ongoing**: [Recurring activities]

## Revenue Impact Estimate

| Feature | Estimated Lift | Confidence |
|---------|---------------|------------|
| [Feature] | [+X% downloads / -X% churn] | [High/Medium/Low] |

## Next Steps
1. [Immediate action item]
2. [Call specific generator skill]
3. [Prepare specific asset or metadata]
```

## Strategy Examples

### Example: Speech Therapy App (Subscription, Growth Stage)
**Profile**: Blow Quest, freemium + subscription, targeting parents of kids in speech therapy
**Recommended**:
- 🔴 In-App Events → Weekly breath challenges to drive engagement
- 🔴 Custom Product Pages → One for parents, one for SLPs (speech-language pathologists)
- 🟠 Win-Back Offers → Re-engage churned subscribers with 50% off
- 🟠 Featuring Nomination → Accessibility + Health angle
- 🟢 Promoted IAP → Show subscription on product page
- 🟢 Offer Codes → Partner with SLP clinics for distribution

### Example: Watch Meditation App (Subscription, Launch Stage)
**Profile**: ChantFlow, Apple Watch, paid + subscription, meditation
**Recommended**:
- 🔴 Introductory Offer → 7-day free trial for subscription
- 🔴 App Store Assets → watchOS screenshots + short-form video
- 🟠 Product Page Optimization → A/B test meditation vs. mindfulness positioning
- 🟠 Featuring Nomination → Mindfulness + Apple Watch angle
- 🟢 Pre-Orders → Build anticipation before major update
- 🟢 In-App Events → Monthly meditation challenges

### Example: Productivity App (Freemium, Mature Stage)
**Profile**: TaskFlow, freemium with premium unlock, 50K MAU, stable
**Recommended**:
- 🔴 Win-Back Offers → Re-engage lapsed premium users
- 🔴 Product Page Optimization → Test benefit-led vs. feature-led screenshots
- 🟠 Custom Product Pages → Pages for students, freelancers, teams
- 🟠 In-App Events → Productivity Week challenge (January)
- 🟢 Offer Codes → Influencer/reviewer distribution
- 🟢 Promotional Offers → Loyalty discount for long-term free users

## References

- **decision-matrix.md** — Feature recommendation logic by app attributes
- **strategy-templates/** — Monetization-specific strategy playbooks
- Related: `app-store/keyword-optimizer` — ASO keyword strategy
- Related: `app-store/app-description-writer` — Product page copy
- Related: `app-store/screenshot-planner` — Screenshot sequences
- Related: `monetization` — Pricing and tier strategy

### Source: `app-store/originality-check`

# Originality Check

Decide, with evidence, whether an app is *distinct enough to exist* — before you build it or submit it.

> At portfolio scale, shipping many similar small apps risks **Guideline 4.3 (spam / duplicate)**
> — this is the go/no-go distinctness gate that keeps that from happening.

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
- Optional: `.planning/VALIDATION.md` (competitor + market data). If missing/stale, gather fresh
  via WebSearch or the `product/competitive-analysis` skill.
- Optional ASC access to read the developer's existing portfolio (`list_apps` / `get_metadata`).

## Flow

1. **Internal check (your own portfolio).** `list_apps` → for each shipped app read its positioning
   (`get_metadata`). Does the candidate overlap one you already ship in **function**, **code
   template**, or **metadata**? Two apps that differ only in theme/reskin = 4.3 risk.
2. **External check (the market).** Read `VALIDATION.md` if present; otherwise `WebSearch` for close
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
5. **Record.** Write the verdict + reasoning to `.planning/` (VALIDATION or STATE). For a
   borderline-approved app, record the wedge as a build requirement so `plan`/`build` deliver it.

## Done

- A written verdict (distinct / borderline+wedge / duplicate) with per-dimension reasoning, and —
  if borderline — the specific differentiation that must ship before submission.

## Caveats

- **Cosmetic theming ≠ differentiation** — Apple judges function + metadata similarity, not intent.
- **Protect the account.** When in doubt between "borderline ship" and "consolidate," prefer one
  strong app over several thin ones.
- Guideline numbers/text drift — confirm current 4.3 wording at the
  [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) (captured 2026-07).

### Source: `app-store/ratings-mechanics`

# Ratings Mechanics

The rating is an asset with mechanics most developers learn the hard way. This skill covers the
four rules that aren't obvious from the ASC UI. Prompting *code* lives in
`generators/review-prompt`; reply *writing* lives in `app-store/review-response-writer` — this
skill is the strategy layer that tells you when each matters.

## When This Skill Activates

- Localizing or expanding into new storefronts ("why does my app show no rating in Japan?")
- Considering the "reset ratings summary" option on a version release
- Choosing release options before submitting (phased vs immediate, auto vs manual)
- Planning a per-market ratings strategy alongside `product/localization-strategy`
- A bad build or review-bomb is threatening the rating

## Rule 1: Ratings are per-storefront — they do not travel

Your 4.8★ from 2,000 US ratings renders as **no rating at all** on the Japanese storefront until
Japanese users rate the app there. Every storefront starts from zero.

Consequences:

- ✅ Entering a new market = re-running the early-days ratings playbook *in that market*: prompt
  eagerly (within guidelines), localize the prompt moment, reply to every early review.
- ✅ Weight `requestReview` triggers by storefront maturity — a market with 12 ratings needs the
  prompt more than the home market with 5,000.
- ❌ Assuming social proof transfers with the binary. A localized listing with zero local ratings
  converts like an unknown app, because there it *is* one.
- The written-review pool is also per-storefront: expect empty review sections in fresh markets
  and seed them via TestFlight communities or launch outreach in that region.

## Rule 2: Never reset the ratings summary

ASC offers a reset when you release a new version. It is almost always a mistake:

- Reset discards the count as well as the average — 4.2★ from 3,000 ratings converts better than
  a naked 5.0★ from 6, and the count never comes back except one rating at a time.
- The instinct to reset ("v2 is a big rewrite, old reviews don't apply") is better served by
  replying to outdated negative reviews (updated ratings **replace** the old score — see
  `review-response-writer`) and by the What's New copy.
- ✅ Legitimate near-exception: a catastrophic launch (sub-3★, low count, fixed root cause) on an
  app with almost no ratings mass. Even then, run the math on count loss first.
- ❌ Resetting an established app to chase a higher average. You'll rank and convert worse for
  months.

## Rule 3: Phased release + manual release are rating armor

Two ASC toggles turn a bad build from a rating catastrophe into a contained incident:

- **Manual version release** — approval ≠ release. Release when you're awake and watching
  crash dashboards, not whenever review finishes.
- **Phased release** — 7-day staged rollout (1% → 2% → 5% → 10% → 20% → 50% → 100%) to users
  with automatic updates. A crashing build caught on day 1–2 has burned ~3% of your users;
  **pause** the rollout, fix, resubmit. Without it, 100% of users get the bad build and the
  1-star flood arrives before the hotfix does.
- ✅ Default for every release: phased ON + manual release + monitor day-1 crash rate.
- ❌ Halting a phased release as a rollback. Pausing stops *new* deliveries only — users who got
  the build keep it, and manual App Store downloads always get the new version. The armor is
  damage *limitation*; the fix still has to ship.

## Rule 4: The prompt-and-reply loop is the only rating input you control

- **Prompt** at success moments with `requestReview` — never at launch, never mid-task. Aim the
  moment, cap the frequency, and localize what "success" means per market. Implementation:
  `generators/review-prompt`.
- **Reply** to negative reviews — when a user updates their review after a reply, the new score
  replaces the old one in the average. Replies are the only mechanism that converts existing
  1-stars into 4-stars. Templates: `app-store/review-response-writer`.
- Per-storefront corollary: track "unanswered negative reviews" per market, not globally — a
  5-review storefront is one bad review away from 60% negative.

## Output Format

When auditing an app's ratings posture, report per storefront:

```
Storefront | Rating (count) | Unanswered 1–3★ (90d) | Prompt localized? | Phased+manual habit?
```

flagging: fresh storefronts with no prompting plan, any reset consideration (🔴 stop), and
releases going out unphased.

## References

- https://developer.apple.com/documentation/storekit/requesting-app-store-reviews
- https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases
- https://developer.apple.com/help/app-store-connect/monitor-app-performance/reset-your-app-s-summary-rating
- Related skills: `generators/review-prompt`, `app-store/review-response-writer`, `product/localization-strategy`, `growth/store-growth-audit`

### Source: `app-store/rejection-handler`

# App Store Rejection Handler

Guide developers through handling App Store rejections — from understanding why the rejection happened, to crafting effective responses, to escalating when appropriate.

## When This Skill Activates

Use this skill when the user:
- Says their app was rejected by App Review
- Asks for help understanding a rejection notice
- Wants to prepare a submission to minimize rejection risk
- Needs help writing a response in Resolution Center
- Wants to appeal a rejection decision
- Asks about common App Store rejection reasons
- Mentions "App Review", "guideline violation", or "rejection"
- Wants a pre-submission audit for guideline compliance

## Reference Files

Before handling a rejection, load:

| File | Purpose |
|------|---------|
| **common-rejections.md** | Top 20 rejection reasons with fixes and response templates |

## Pre-Submission Audit Checklist

Run through this before submitting to avoid the most common rejections. Each item maps to a specific App Store Review Guideline.

### App Completeness (Guideline 2.1)

- [ ] App launches without crashing on all supported devices
- [ ] All features described in metadata are functional
- [ ] No placeholder content (lorem ipsum, test data, TODO screens)
- [ ] No broken links or dead-end navigation
- [ ] All buttons and interactive elements work
- [ ] Demo/test accounts provided in App Review notes if login is required
- [ ] Beta or test labels removed from UI and metadata

### Accurate Metadata (Guideline 2.3)

- [ ] App name matches what the app actually does
- [ ] Screenshots show the actual current app UI
- [ ] Description accurately represents functionality
- [ ] Category selection is appropriate
- [ ] No misleading claims ("best", "#1") without substantiation
- [ ] Age rating reflects actual content
- [ ] What's New text describes actual changes (not marketing copy)
- [ ] Keywords do not include competitor names or misleading terms

### Software Requirements (Guideline 2.5)

- [ ] App uses only public APIs (no private frameworks)
- [ ] No deprecated APIs that are marked for removal
- [ ] App works on the oldest supported iOS/macOS version claimed
- [ ] No remote code execution (no downloading and running code)
- [ ] IPv6 networking compatibility

### In-App Purchase Compliance (Guideline 3.1)

- [ ] All digital content/features use Apple's IAP (not Stripe, PayPal, etc.)
- [ ] Physical goods/services CAN use external payment
- [ ] Subscription terms are clear before purchase
- [ ] "Restore Purchases" button exists and works
- [ ] Subscription management is accessible within the app
- [ ] No language directing users to purchase outside the app
- [ ] Free trial terms are clearly stated

### Design Quality (Guideline 4.0)

- [ ] App uses native UI components (not a web wrapper for existing website)
- [ ] Supports current device screen sizes
- [ ] No empty states without guidance
- [ ] Error messages are user-friendly
- [ ] Loading states exist for async operations
- [ ] App provides meaningful functionality (not a glorified bookmark)

### Privacy Compliance (Guideline 5.1)

- [ ] Privacy policy URL is provided and accessible
- [ ] Privacy policy accurately describes data collection
- [ ] App Tracking Transparency prompt shown before tracking (if applicable)
- [ ] Privacy Nutrition Labels in App Store Connect match actual behavior
- [ ] Data minimization — only collect what you need
- [ ] User data deletion mechanism exists (if data is collected)
- [ ] Privacy manifest included (required for certain APIs, iOS 17+)

### Legal Requirements (Guideline 5.2)

- [ ] App complies with local laws in all territories where distributed
- [ ] Required age gates for restricted content
- [ ] Health/medical disclaimers if applicable
- [ ] Financial disclaimers if applicable

### App Review Notes (Submission)

- [ ] Demo account credentials provided (if login required)
- [ ] Special hardware instructions noted (if needed)
- [ ] Backend requirements explained (if features need server access)
- [ ] Explain non-obvious features or flows
- [ ] Mention any entitlements and why they're needed

## Rejection Handling Process

### Step 1: Read the Rejection Notice Carefully

When a user reports a rejection, gather:

1. **The exact guideline cited** (e.g., "Guideline 4.2 - Design - Minimum Functionality")
2. **The full rejection message text** (Apple provides specific details)
3. **Any screenshots or annotations** Apple included
4. **Whether this is a first submission or re-submission**

Ask via AskUserQuestion:
- "Can you paste the full rejection message from App Store Connect?"
- "Which guideline number was cited?"
- "Is this the first time this app has been submitted?"
- "Have you made changes since a previous rejection?"

### Step 2: Identify the Rejection Category

Read **common-rejections.md** and match the cited guideline to the detailed breakdown. Determine:

- Is the rejection objectively correct? (crash, privacy violation, missing IAP)
- Is the rejection subjective? (minimum functionality, design quality)
- Is the rejection possibly in error? (reviewer misunderstood the app)

### Step 3: Determine Response Strategy

```
Is the rejection objectively correct?
├── YES → Fix the issue and resubmit (Phase A)
└── NO → Did the reviewer misunderstand?
    ├── YES → Clarify with evidence (Phase B)
    └── NO → Is it a subjective judgment call?
        ├── YES → Evaluate: fix or push back? (Phase C)
        └── NO → Appeal (Phase D)
```

### Phase A: Fix and Resubmit

For clear violations (crashes, missing privacy policy, private API usage):

1. Fix the specific issue cited
2. Test thoroughly on the device types Apple may have tested on
3. In the Resolution Center reply, briefly state what was fixed
4. Resubmit the binary

**Response template (Fix and Resubmit):**
```
Thank you for the review.

We've addressed the issue cited in Guideline [X.X]:

- [Specific change made]
- [How it was verified]

The updated build ([version] [build number]) has been submitted
for review.

Please let us know if you have any further questions.
```

### Phase B: Clarify with Evidence

For rejections based on misunderstanding:

1. Do NOT be defensive or argumentative
2. Explain clearly what the app does and why it doesn't violate the guideline
3. Provide screenshots, video, or step-by-step instructions
4. Reference the specific guideline language and explain how you comply

**Response template (Clarification):**
```
Thank you for reviewing our app.

We'd like to provide additional context regarding Guideline [X.X].

[Clear explanation of how the feature/app works]

To demonstrate this:
1. [Step-by-step instructions to see the relevant feature]
2. [Step-by-step instructions continued]

[Optional: screenshot or video link]

We believe this addresses the concern raised. We're happy to
provide any additional information or make a call to discuss
further.
```

### Phase C: Evaluate Subjective Rejections

For "minimum functionality" (4.2), "spam" (4.3), or "design" (4.0) rejections, decide:

**When to fix (usually the better path):**
- If you honestly agree the app could be more substantial
- If adding 2-3 features would make a meaningful difference
- If the reviewer's feedback, while harsh, has a point
- If you're early in development and can improve quickly

**When to push back:**
- If the app intentionally does one thing well (it's a focused tool, not incomplete)
- If similar apps exist on the App Store with less functionality
- If the reviewer appears to have missed core features
- If you have user testimonials or metrics showing the app delivers value

**Response template (Pushing Back on Subjective Rejection):**
```
Thank you for your feedback on our app.

We respectfully believe [App Name] provides meaningful
functionality as outlined in Guideline [X.X]:

1. [Core value proposition]
2. [Specific features that demonstrate depth]
3. [User benefit that differentiates from a simple website]

[App Name] is designed as a focused [type of app] that excels
at [specific purpose]. This intentional focus is a design
decision, not a limitation.

[Optional: "Similar apps like [X] and [Y] are available on the
App Store with comparable scope."]

We'd welcome the opportunity to discuss this further or
demonstrate the app's functionality in detail.
```

### Phase D: Formal Appeal

If Resolution Center responses don't resolve the issue, escalate.

## Appeal Escalation Path

### Level 1: Resolution Center Reply (First Response)

- Reply directly in Resolution Center
- Be professional, concise, and evidence-based
- Include demo video if helpful
- Response time: 1-3 business days typically

### Level 2: Request a Phone Call

If the Resolution Center reply doesn't resolve it:

- In Resolution Center, explicitly request: "We'd appreciate the opportunity to discuss this via phone call with the App Review team."
- Apple sometimes offers this for complex cases
- Prepare a clear, concise verbal explanation
- Have the app ready to demo live
- Response time: 3-7 business days

### Level 3: App Review Board Appeal

If Level 1 and Level 2 fail:

- Submit a formal appeal at https://developer.apple.com/contact/app-store/
- Choose "App Review" and then "Appeal"
- This goes to a separate board, not the same reviewer
- One appeal per rejection — make it count
- Response time: 5-14 business days

**Appeal writing tips:**
- Lead with facts, not emotions
- Reference specific guideline language
- Explain why the rejection criteria don't apply or are being misapplied
- Mention comparable apps on the App Store (carefully — don't name-shame, but establish precedent)
- Keep it under 500 words
- Include a demo video link if the issue is about functionality

### When to Change Approach vs. Push Back

**Apple is usually right about:**
- Crashes and bugs (fix them)
- Privacy violations (fix them)
- Missing IAP for digital goods (implement IAP)
- Misleading metadata (fix it)
- Private API usage (use public APIs)

**Apple is sometimes wrong about:**
- "Minimum functionality" for intentionally focused apps
- "Spam" for apps that serve distinct user segments
- "Could be a website" for apps with native features (widgets, notifications, offline)
- "Not enough native UI" for apps with legitimate custom interfaces
- Feature misunderstandings when reviewers don't find non-obvious functionality

**Rule of thumb:** If 3 people independently look at the rejection and all say "Apple has a point," fix the issue. If they all say "this seems wrong," push back with evidence.

## Timeline Expectations

### Typical Review Times

| Scenario | Expected Timeline |
|----------|------------------|
| Initial submission | 1-3 days (24-48 hours typical) |
| Resubmission after rejection | 1-3 days |
| Expedited review request | Same day to 1 day |
| Resolution Center reply | 1-3 business days |
| Phone call request | 3-7 business days |
| App Review Board appeal | 5-14 business days |

### When to Request Expedited Review

Apple allows expedited review requests for:
- Critical bug fixes for live apps
- Time-sensitive events (conference launch, holiday tie-in)
- Security patches

Do NOT request expedited review for:
- Initial submissions (no urgency justification)
- Feature updates (plan ahead)
- Rejected apps (use Resolution Center instead)

### Seasonal Considerations

- **WWDC (June)**: Slight delays as team focuses on new OS reviews
- **September-October**: iPhone launch creates surge, slightly longer times
- **December holidays**: Reduced staff, plan submissions before mid-December
- **App Store freeze**: Typically Dec 23-27, no new submissions processed

## Resolution Center Best Practices

### Tone

- Professional and respectful, always
- Concise — reviewers handle hundreds of cases
- Evidence-based — screenshots, videos, step-by-step instructions
- Solution-oriented — "here's what we changed" or "here's why this complies"

### What to Include

- Reference the specific guideline number
- Quote the specific language from the rejection
- Provide clear evidence (screenshots, demo video, step-by-step reproduction)
- If you fixed something, state exactly what changed and in which build
- If you're clarifying, provide a walkthrough of the misunderstood feature

### What to Avoid

- Emotional language ("this is unfair", "we worked so hard")
- Threats (legal action, press coverage, social media complaints)
- Comparing to competitor apps in a negative way
- Long, rambling responses (keep under 300 words for replies)
- Multiple replies in quick succession (wait for a response)

### Response Length

- First reply: 100-200 words
- Clarification with evidence: 200-300 words
- Appeal: 300-500 words

## Output Format

When handling a rejection, produce this assessment:

```markdown
# Rejection Analysis: [App Name]

## Rejection Details
- **Guideline**: [X.X] - [Guideline Name]
- **Submission type**: Initial / Resubmission
- **Rejection message**: [Quoted text]

## Assessment
- **Category**: Objective violation / Subjective judgment / Possible error
- **Validity**: [Is Apple right? Partially right? Wrong?]
- **Recommended strategy**: Fix and resubmit / Clarify / Push back / Appeal

## Recommended Response

[Draft Resolution Center response]

## If Fixing: Action Items
1. [Specific change needed]
2. [Specific change needed]
3. [Verification step before resubmitting]

## If Appealing: Evidence to Prepare
- [Screenshot/video needed]
- [Comparable App Store precedent]
- [Guideline language to reference]

## Pre-Resubmission Checklist
- [ ] Issue addressed
- [ ] Tested on [device types]
- [ ] App Review notes updated
- [ ] Demo account credentials current
- [ ] Resolution Center response sent
```

## Related Skills

- **common-rejections.md** — Detailed breakdown of top 20 rejection reasons with fix guides
- Related: `release-review` — Pre-release audit that catches rejection-causing issues
- Related: `security/privacy-manifests` — Privacy manifest compliance
- Related: `app-store/app-description-writer` — Metadata accuracy (prevents Guideline 2.3 rejections)
- Related: `monetization` — IAP compliance guidance (prevents Guideline 3.1 rejections)

### Source: `app-store/review-response-writer`

# Review Response Writer

Write professional, empathetic responses to App Store reviews that build trust and turn critics into fans.

## When This Skill Activates

- User needs to respond to negative reviews
- User wants templates for common review types
- User asks about review management strategy
- User wants to improve customer relationships

## Response Philosophy

### Why Respond?

1. **Shows you care** - Active developer = trustworthy app
2. **Helps others** - Future users read responses
3. **Converts critics** - Can change rating with good response
4. **Provides feedback** - Reviews reveal real issues
5. **Builds community** - Creates loyal users

### When to Respond

| Review Type | Respond? | Priority |
|-------------|----------|----------|
| 1-2 stars with feedback | **Yes** | High |
| 3 stars with suggestions | Yes | Medium |
| Bug reports (any rating) | **Yes** | High |
| 4-5 stars with content | Yes | Low |
| 4-5 stars generic praise | Optional | Low |
| Abusive/inappropriate | Report, don't respond | - |
| Competitor spam | Report, don't respond | - |

### Response Timing

Negative reviews and bug reports: 24-48 hours. Positive reviews: weekly batch is fine.
Follow up after fixing an issue to notify the reviewer.

## Response Framework

### The A.C.T. Formula

```
A - Acknowledge their experience
C - Clarify or provide solution
T - Thank them and invite continued feedback
```

### Template Structure

```
[Greeting - use their name if signed]

[Acknowledge their frustration/praise]

[Address specific points they raised]

[Provide solution, workaround, or update info]

[Thank + future-focused closing]

[Sign-off with name/team]
```

## Response Templates

### Negative Review: Bug Report

**Review:** "App crashes every time I try to export. Waste of money. 1 star."

**Response:**
```
Hi [Name],

I'm really sorry about the export crashes — that's frustrating,
especially when you're trying to get work done.

We identified this issue and it's fixed in version X.X, which is
now available. If you update and still experience problems, please
reach out to support@yourapp.com and we'll help you directly.

Thank you for taking the time to report this. It helps us improve.

— [Your Name], [App] Team
```

### Negative Review: Missing Feature

**Review:** "No dark mode? In 2024? Uninstalled."

**Response:**
```
Hi there,

You're absolutely right — dark mode is important, and we hear you.

Good news: dark mode is in active development and planned for our
next major update. If you'd like to be notified when it's ready,
drop us a note at support@yourapp.com.

Thanks for the feedback. We hope to welcome you back soon!

— [Your Name], [App] Team
```

### Negative Review: User Error (Diplomatic)

**Review:** "Can't figure out how to do X. Bad design."

**Response:**
```
Hi [Name],

Thanks for reaching out. I can see how [X] might not be obvious
at first — we could definitely make it clearer.

Quick tip: you can access [X] by [simple instructions]. We're also
adding an in-app tutorial in our next update to help with this.

If you're still stuck, email us at support@yourapp.com and we'll
walk you through it.

— [Your Name], [App] Team
```

### Negative Review: Pricing Complaint

**Review:** "Too expensive for what it does."

**Response:**
```
Hi [Name],

Thanks for sharing your thoughts on pricing. I understand — value
is important.

A few things that might help:
• We offer a free trial so you can test before committing
• The subscription includes [key benefits]
• We regularly run promotions — follow us @handle for updates

We're always working to add more value. If there's a specific
feature you'd find worth the price, we'd love to hear about it.

— [Your Name], [App] Team
```

### Negative Review: Generic/Vague

**Review:** "Doesn't work. Terrible app."

**Response:**
```
Hi there,

I'm sorry to hear you're having trouble. We'd really like to help,
but need a bit more info to figure out what's going wrong.

Could you email us at support@yourapp.com with:
• What you were trying to do
• What happened instead
• Your device and iOS version

We respond quickly and will do our best to get you sorted.

— [Your Name], [App] Team
```

### Positive Review: With Feature Request

**Review:** "Love this app! Would be perfect if it had X."

**Response:**
```
Thank you so much for the kind words! 🙏

Great suggestion on [X] — you're not the first to ask, and it's
on our roadmap. Can't promise exact timing, but it's coming.

If you have other ideas, we're all ears at feedback@yourapp.com.

Thanks for being a [App] user!

— [Your Name]
```

### Positive Review: Simple Thanks

**Review:** "Great app, use it every day. 5 stars!"

**Response:**
```
Thank you! Reviews like this make our day. We're glad [App] is
helping you. If you ever need anything, we're here!

— The [App] Team
```

### After Fixing a Bug

**Review:** [Previously reported bug]

**Follow-up Response:**
```
Hi [Name],

Quick update: the [issue] you reported has been fixed in version
X.X, now available in the App Store.

Thank you again for letting us know — you helped us make [App]
better for everyone.

If you get a chance to try the update, we'd love to know if it
resolved things for you.

— [Your Name], [App] Team
```

## Tone Guidelines

### Always

- Be genuinely helpful
- Stay professional but warm
- Take responsibility (never blame user)
- Be specific (not generic)
- Keep it concise

### Never

- Be defensive or argumentative
- Make excuses
- Ignore valid criticism
- Use corporate jargon
- Copy-paste identical responses
- Promise specific timelines you can't keep

### Tone by Situation

| Situation | Tone |
|-----------|------|
| Bug report | Apologetic, solution-focused |
| Feature request | Appreciative, forward-looking |
| Confusion | Helpful, educational |
| Angry review | Calm, empathetic |
| Positive review | Grateful, personable |

## Difficult Situations

### Abusive Reviews

**Don't respond.** Report to Apple instead if it violates guidelines — profanity, hate speech,
personal attacks, or clear spam.

### Competitor Attacks

Signs of competitor spam:
- Multiple similar reviews at once
- No specific details
- Account has reviewed many competing apps
- Unrealistic claims

**Action:** Report to Apple, don't engage.

### Impossible to Satisfy

Some users can't be pleased. After one genuine attempt:
- Don't keep responding
- Document for your records
- Move on

### Legal Threats

If a review contains legal threats:
- Don't respond publicly
- Consult with legal
- Document everything

## Metrics to Track

### Response Metrics
- Response rate (aim for 100% of actionable)
- Response time (aim for <48 hours)
- Follow-up conversion (ratings changed after response)

### Review Health
- Average rating trend
- Review volume
- Sentiment analysis
- Common themes

## Workflow

### Daily (5 minutes)
1. Check for new reviews
2. Flag urgent issues (bugs, crashes)
3. Respond to critical reviews

### Weekly (15 minutes)
1. Respond to remaining reviews
2. Track themes and patterns
3. Share feedback with team

### Monthly (30 minutes)
1. Analyze rating trends
2. Update response templates if needed
3. Report key feedback to product team

## Quick Reference

### Response Length
- **Ideal:** 50-100 words
- **Maximum:** 150 words
- **Never:** Wall of text

### Sign-off Options
- "— The [App] Team"
- "— [Name], [App] Support"
- "— [Name], Founder of [App]"

### Contact Options to Offer
- support@yourapp.com
- In-app support chat
- @TwitterHandle
- yourapp.com/help
