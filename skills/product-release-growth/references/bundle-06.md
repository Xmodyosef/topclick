# Integrated Reference Bundle 06

Combines 10 related source skills from `product-release-growth` into one navigable reference file.

## Source map

- `growth/SKILL.reference.md`
- `growth/analytics-interpretation/SKILL.reference.md`
- `growth/community-building/SKILL.reference.md`
- `growth/indie-business/SKILL.reference.md`
- `growth/press-media/SKILL.reference.md`
- `growth/store-growth-audit/SKILL.reference.md`
- `growth/store-signals/SKILL.reference.md`
- `growth_1256/store-growth-audit/SKILL.reference.md`
- `growth_1256/store-signals/SKILL.reference.md`
- `monetization/SKILL.reference.md`

## Integrated guidance

### Source: `growth`

# Growth Skills

Growth skills for indie Apple developers — from analytics interpretation to press outreach to community building. Covers the non-code aspects of building a sustainable app business.

## When This Skill Activates

Use this skill when the user:
- Asks about growing their app or user acquisition
- Wants to understand app metrics or analytics
- Asks about press/media outreach or getting reviews
- Wants to build a community around their app
- Asks about indie business operations (LLC, taxes, hiring)
- Mentions growth strategy, marketing, or user engagement
- Wants data-driven guidance on what to improve next

## Available Skills

### store-growth-audit/
Stage-by-stage audit of an app's App Store growth machinery against a 54-item P0–P9 playbook — every item scored from an ASC read, a codebase check, or an explicit question, then routed to the skill that fixes it. Read-only; works for live apps (audit) and pre-launch apps (growth plan).

### store-signals/
Close the post-launch loop — turn a live app's App Store signals (reviews, analytics, sales, crashes, listing conversion) into a metric-tagged backlog, and verify whether last cycle's changes moved the metric they promised to move.

### analytics-interpretation/
Interpret app metrics and make data-driven decisions. Covers DAU/MAU, retention curves, LTV/ARPU, App Store Connect analytics, funnel analysis (AARRR), cohort analysis, and decision trees for what to fix based on which metric is underperforming.

### press-media/
Get press coverage and media attention for your app. Covers press kit preparation, finding relevant journalists/bloggers/YouTubers, pitch timing and embargo strategy, indie developer story angles, and email templates for outreach.

### community-building/
Build and engage a user community around your app. Covers platform selection (Twitter/X, Mastodon, Reddit, Discord), building in public strategy, content calendars for solo developers, and converting community members into advocates.

### indie-business/
Business fundamentals for indie app developers. Covers business entity setup (LLC, S-Corp), Apple Small Business Program, tax basics for app revenue, revenue tracking, when to hire, and financial planning for indie sustainability.

## How to Use

1. Identify what growth stage the user is at:
   - **Pre-launch**: store-growth-audit (seed the growth plan), press-media (prepare press kit), community-building (build anticipation)
   - **Just launched**: analytics-interpretation (baseline metrics), press-media (launch outreach)
   - **Growing**: store-signals (monthly loop), analytics-interpretation (optimize funnel), community-building (scale engagement)
   - **Established**: store-growth-audit (quarterly re-audit), indie-business (formalize operations), analytics-interpretation (advanced cohorts)
2. Read the relevant sub-skill's SKILL.md for detailed workflow
3. Ask clarifying questions about the user's app, audience, and current metrics
4. Provide actionable guidance tailored to their specific situation

### Source: `growth/analytics-interpretation`

# Analytics Interpretation

Interpret your app's metrics, diagnose problems, and make data-driven decisions. Works with App Store Connect data, third-party analytics, or raw numbers the user provides.

## When This Skill Activates

Use this skill when the user:
- Wants to understand their app metrics or analytics
- Asks about retention, LTV, ARPU, or churn
- Wants to know if their metrics are good or bad
- Needs help interpreting App Store Connect analytics
- Wants a data-driven growth plan
- Asks "what should I focus on to grow?"
- Has metrics data and wants to know what it means

## Process

### Step 1: Gather Context

Ask the user via AskUserQuestion:

1. **App type and monetization model**
   - Free with ads, freemium, subscription, paid upfront, or hybrid?
2. **Current metrics they have access to**
   - App Store Connect? Third-party analytics (Mixpanel, Firebase, Amplitude)?
3. **Specific numbers they can share**
   - Downloads, DAU/MAU, retention, revenue, conversion rates?
4. **What they want to know**
   - "Are my metrics good?" / "What should I fix?" / "Should I keep going?"

Also pull App Store Connect **peer group benchmarks** (App Analytics → Benchmarks) before interpreting any trend — they establish whether a metric is "bad for you" or "bad for the category."

#### How Peer Group Benchmarks Work

- **Peer group** = App Store category + business model (free / freemium / paid / paidmium / subscription) + download-volume band
- **Benchmarked metrics**: conversion rate, D1/D7/D28 retention, crash rate, average proceeds per paying user
- You see the peer group's **25th / 50th / 75th percentile** bands (example: day-1 retention 13.4% / 21.3% / 27.4%)
- Differential privacy adds noise and groups have minimum sizes — judge by **which quartile you're in**, not exact deltas
- Improving ≠ done: an app that lifted conversion +5.5% over 90 days can still sit in the bottom half of its peer group

| Below peers on... | Reach for... |
|-------------------|--------------|
| Conversion rate | Product Page Optimization + Custom Product Pages |
| Retention | In-app events + App Clips |
| Proceeds per paying user | Pricing tier review + promoted in-app purchases |

### Step 2: Identify Key Metrics by App Type

Different monetization models have different north star metrics.

#### Free with Ads
| Metric | Why It Matters |
|--------|---------------|
| DAU/MAU | More daily users = more ad impressions |
| Session length | Longer sessions = more ad views |
| Sessions per day | More sessions = more revenue opportunities |
| Ad impressions/revenue | Direct revenue driver |
| D1/D7/D30 retention | Users must come back for ads to work |

#### Freemium (One-Time Unlock)
| Metric | Why It Matters |
|--------|---------------|
| Conversion rate (free → paid) | Primary revenue driver |
| Time to conversion | How long before users see enough value |
| Feature adoption | Which features drive upgrades |
| Revenue per download | Overall monetization efficiency |
| D7 retention (free users) | Must retain long enough to convert |

#### Subscription
| Metric | Why It Matters |
|--------|---------------|
| Trial start rate | Top of subscription funnel |
| Trial → paid conversion | Critical conversion point |
| Monthly churn rate | Determines LTV |
| LTV (lifetime value) | Revenue per subscriber over their lifetime |
| Payback period | Months to recoup acquisition cost |
| MRR / ARR | Business health snapshot |
| Subscriber retention (Month 1-12) | Long-term revenue curve |

#### Paid Upfront
| Metric | Why It Matters |
|--------|---------------|
| Downloads per day/week | Direct revenue driver |
| Revenue per download | Should equal price minus Apple's cut |
| Refund rate | Product quality signal (keep < 5%) |
| Ratings and reviews | Social proof drives more downloads |
| Organic vs. paid ratio | Sustainability indicator |

### Step 3: App Store Connect Analytics Interpretation

#### The App Store Funnel

```
Impressions (your app appeared in search/browse)
    ↓ Tap-through rate = Product Page Views / Impressions
Product Page Views (user tapped to see your page)
    ↓ Conversion rate = Downloads / Product Page Views
Downloads (user installed your app)
    ↓ D1 retention
Day 1 Active Users
    ↓ D7 retention
Day 7 Active Users
    ↓ D30 retention
Day 30 Active Users
    ↓ Monetization
Paying Users
```

#### App Store Connect Definitions (get these right)

- **Conversion rate** = total downloads ÷ **unique** impressions (not raw impressions)
- **Total downloads** = first-time downloads + redownloads; auto-downloads (device syncing) are excluded
- Segment every funnel metric by the **4 source types** — App Store browse, App Store search, app referrer, web referrer — and by **page type**: product page vs. store sheet vs. no page. A strong product-page CVR can hide a weak store-sheet CVR
- Up to **7 filters** stack per metric (WWDC25) — e.g. search traffic + one territory + store sheet
- **Payer metrics** (WWDC25): Download-to-Paid Conversion and Average Proceeds per Download connect acquisition quality to revenue

#### Interpreting Each Funnel Step

**Impressions → Product Page Views (Tap-Through Rate)**

| Rating | TTR | Interpretation |
|--------|-----|---------------|
| Good | > 8% | Icon and title are compelling |
| Average | 4-8% | Room to improve first impression |
| Poor | < 4% | Icon, title, or subtitle need work |

What to fix if low:
- App icon not standing out (test bolder colors, simpler design)
- Title not communicating value (add keyword after brand name)
- Subtitle too vague (make it specific: "Budget Tracker" not "Finance App")
- Poor search ranking (see keyword-optimizer skill)

**Product Page Views → Downloads (Conversion Rate)**

| Rating | CVR | Interpretation |
|--------|-----|---------------|
| Good | > 40% | Screenshots and description are effective |
| Average | 25-40% | Some friction on the product page |
| Poor | < 25% | Major product page issues |

What to fix if low:
- First 3 screenshots not showing core value
- No app preview video (adds 15-25% lift)
- Description too long before showing key benefits
- Bad ratings visible (address review issues first)
- Price too high relative to perceived value

**Downloads → Day 1 Retention**

| Rating | D1 | Interpretation |
|--------|-----|---------------|
| Good | > 35% | Onboarding delivers on promise |
| Average | 20-35% | Some users confused or disappointed |
| Poor | < 20% | App not delivering expected value |

What to fix if low:
- Onboarding too long or confusing
- App Store screenshots overpromised
- Core value not visible in first session
- Permissions requested too early (camera, notifications)
- Performance issues (slow launch, crashes)

**Day 1 → Day 7 Retention**

| Rating | D7 | Interpretation |
|--------|-----|---------------|
| Good | > 20% | Users forming habit |
| Average | 10-20% | Some users finding value |
| Poor | < 10% | Most users abandoning after trying |

What to fix if low:
- No reason to come back (add notifications, reminders, streaks)
- Core loop not engaging enough
- Too complex — users haven't learned enough features
- Missing "aha moment" in first week

**Day 7 → Day 30 Retention**

| Rating | D30 | Interpretation |
|--------|-----|---------------|
| Good | > 10% | Strong product-market fit signal |
| Average | 5-10% | Decent but room to grow |
| Poor | < 5% | Retention cliff — users churning |

What to fix if low:
- Feature depth too shallow (users exhaust value)
- No progression or new content
- Competitor doing it better
- Consider: is this a "use once" tool, not a habit app?

### Step 4: AARRR Funnel Analysis

The pirate metrics framework — diagnose where your funnel leaks.

#### Acquisition: How do users find you?

| Metric | Benchmark | Diagnostic |
|--------|-----------|-----------|
| Organic search impressions | Growing month-over-month | Are your keywords working? |
| Browse impressions | Category-dependent | Are you getting featured/editorial? |
| Referral traffic | > 10% of total | Do users share your app? |
| Paid acquisition CPA | < 1/3 of LTV | Is paid acquisition sustainable? |

**Questions to ask:**
- What are your top 3 acquisition sources?
- Is organic growing or shrinking?
- What's your cost per install (if running ads)?

#### Activation: Do users experience the core value?

| Metric | Benchmark | Diagnostic |
|--------|-----------|-----------|
| Onboarding completion | > 70% | Is onboarding too long? |
| "Aha moment" reached | > 50% in first session | Do users discover core value? |
| First key action taken | > 40% of installs | Are users doing the main thing? |

**Questions to ask:**
- What is the one action that defines "this user gets it"?
- How many steps to reach that action?
- What percentage of new users complete it?

#### Retention: Do users come back?

| Metric | Benchmark | Diagnostic |
|--------|-----------|-----------|
| D1 retention | 25-40% | First impression quality |
| D7 retention | 15-25% | Habit formation |
| D30 retention | 8-15% | Product-market fit |
| DAU/MAU ratio | 15-30% | Daily engagement strength |

**Questions to ask:**
- Where is the biggest retention drop-off?
- What do retained users do differently from churned users?
- Is there a retention cliff at a specific day?

#### Revenue: Are users paying?

| Metric | Benchmark | Diagnostic |
|--------|-----------|-----------|
| Free → trial rate | 10-30% | Is the paywall compelling? |
| Trial → paid rate | 40-60% | Does the trial demonstrate value? |
| ARPU (all users) | Category-dependent | Overall monetization efficiency |
| ARPPU (paying users) | 5-20x ARPU | Are payers happy with value? |

**Questions to ask:**
- At what point do users encounter the paywall?
- What's the conversion rate at each paywall touchpoint?
- Do longer-retained users convert at higher rates?

#### Referral: Do users tell others?

| Metric | Benchmark | Diagnostic |
|--------|-----------|-----------|
| Organic multiplier | > 1.0 | Each user brings > 1 new user |
| Share rate | > 5% of MAU | Users actively sharing |
| Rating/review rate | > 1% of MAU | Users willing to vouch publicly |
| Average rating | > 4.5 | High satisfaction |

**Questions to ask:**
- Is there a share feature in the app?
- Do you ask for ratings at the right moment?
- What triggers a user to recommend your app?

### Step 5: Cohort Analysis (Subscription Apps)

#### How to Read a Cohort Retention Table

```
              Month 0  Month 1  Month 2  Month 3  Month 4  Month 5
Jan cohort    100%     62%      55%      50%      48%      46%
Feb cohort    100%     58%      51%      46%      44%      —
Mar cohort    100%     65%      59%      54%      —        —
Apr cohort    100%     70%      63%      —        —        —
May cohort    100%     68%      —        —        —        —
```

**What to look for:**

1. **Month 0 → Month 1 drop**: The biggest drop. Industry average is 30-50% churn. If yours is > 50%, trial experience needs work.

2. **Flattening curve**: Retention should flatten over time. If Month 3 → Month 4 → Month 5 are similar, you've found your "natural retention floor."

3. **Improving cohorts**: Compare Jan vs. Apr cohorts at the same month. If Apr Month 1 (70%) > Jan Month 1 (62%), your product improvements are working.

4. **Retention cliff**: A sudden drop at a specific month often indicates:
   - Month 1: Annual subscribers who don't renew
   - Month 3: Users who gave it a fair try and decided no
   - Month 12: Annual subscribers hitting renewal

#### Comparing Cohorts to Measure Impact

When you ship a change, compare cohorts before and after:

```
Before change (Jan-Mar avg):  Month 1 retention = 58%
After change (Apr-May avg):   Month 1 retention = 69%

Improvement: +11 percentage points → significant positive impact
```

**Rules of thumb:**
- < 3 percentage point change: likely noise
- 3-10 percentage point change: meaningful, keep the change
- > 10 percentage point change: major win, double down on this direction

#### App Store Connect Subscription Metrics (WWDC25)

App Analytics carries 50+ subscription metrics, organized as **states** (subscribers in an offer, paying full price, with billing issues, churned) and **events** (movement between states):

- **Net Paid Plans** — new paid starts vs. voluntary + involuntary churn — is the single best subscription health headline
- Track **Subscription Retention** two ways: by months-since-subscribing and by offer start (example shape: 67% trial→paid, then 78% retained at 3 months, 73% at 6)
- Offers do three jobs — **acquire** (introductory), **retain** (promotional), **win back** — measure offer→full-price conversion for each job separately

#### Segment Cohorts by Acquisition Source

Cohort tables get sharper when split by source or custom product page. Example: a "runner" CPP segment converting at 1.3% vs. 3% overall means three different levers from one segmented number — fix that page's creative, redirect its ad spend, and re-engage its cohort via in-app events.

### Step 6: Diagnostic Decision Trees

Use these when the user says "my [metric] is bad, what do I do?"

#### Low Impressions (< 1,000/day for established app)
```
Low impressions
├── Are you ranking for any keywords?
│   ├── NO → ASO problem: optimize title, subtitle, keywords
│   │        See keyword-optimizer skill
│   └── YES → Are those keywords high-volume?
│       ├── NO → Target higher-volume keywords
│       └── YES → Are you ranking in top 10?
│           ├── NO → Improve rankings (more ratings, better conversion)
│           └── YES → Expand to more keywords or new markets
```

#### High Impressions, Low Product Page Views (TTR < 4%)
```
Low tap-through rate
├── Is your icon professional and distinctive?
│   ├── NO → Redesign icon (test 3 variants)
│   └── YES → Is your title clear and keyword-rich?
│       ├── NO → Rewrite title: [Brand] - [Value Keyword]
│       └── YES → Is your subtitle compelling?
│           ├── NO → Rewrite subtitle with specific benefit
│           └── YES → Check competitor positioning — are you differentiated?
```

#### Good Downloads, Bad Retention (D1 < 25%)
```
Poor day-1 retention
├── Is onboarding complete rate > 70%?
│   ├── NO → Simplify onboarding (fewer steps, skip option)
│   └── YES → Do users reach "aha moment" in first session?
│       ├── NO → Restructure first-run experience to show core value immediately
│       └── YES → Are there performance issues (crashes, slow load)?
│           ├── YES → Fix stability first (check crash reports)
│           └── NO → Does the app match what screenshots promised?
│               ├── NO → Align marketing with actual product
│               └── YES → Core value may not be strong enough → user research needed
```

#### Good Retention, Low Revenue (conversion < 3%)
```
Low monetization
├── Do users see the paywall?
│   ├── NO → Add natural paywall touchpoints (feature gates, usage limits)
│   └── YES → Is the paywall compelling?
│       ├── NO → Redesign paywall (show value, social proof, feature comparison)
│       └── YES → Is the price right?
│           ├── TOO HIGH → Test lower price point or add cheaper tier
│           ├── TOO LOW → Users may not perceive enough value — test higher price
│           └── SEEMS RIGHT → Is trial experience showcasing premium features?
│               ├── NO → Onboard users to premium features during trial
│               └── YES → Test different trial lengths or offer types
```

### Step 7: Invest, Iterate, Pivot, or Sunset?

Based on the overall picture, recommend one of four paths:

#### Invest (Double Down)
**Signals:**
- D7 retention > 40%
- Growing organically (installs increasing without paid acquisition)
- Users actively requesting features
- Conversion rate improving over time
- Strong ratings (> 4.5 stars)

**Action:** Increase development speed, consider marketing spend, expand to new platforms.

#### Iterate (Keep Improving)
**Signals:**
- D7 retention 20-40%
- Some organic growth but not accelerating
- Mixed user feedback (some love it, some confused)
- Conversion rate stable but not great

**Action:** Focus on the retention cliff. Find what retained users do differently and make all users do that. A/B test paywall and onboarding.

#### Pivot (Change Direction)
**Signals:**
- D7 retention < 20% after 3+ iterations
- Engagement concentrated in unexpected feature
- Users using app differently than intended
- Specific segment retains well, others don't

**Action:** Double down on the unexpected use case. Rebuild around what users actually do, not what you planned.

#### Sunset (Move On)
**Signals:**
- Declining metrics across the board
- No organic growth despite multiple iterations
- Users not engaging even after onboarding improvements
- Opportunity cost too high (other ideas with more potential)

**Action:** Put app in maintenance mode. Stop active development. Consider open-sourcing or selling. Redirect energy to next project.

**Important caveat:** Sunsetting is not failure. Most successful indie developers shipped several apps before finding the one that worked.

## Reference Files

See **metrics-reference.md** for:
- Detailed metric definitions and formulas
- Benchmark ranges by app category (social, productivity, games, utilities)
- App Store Connect specific metric definitions
- Red/yellow/green thresholds for all key metrics

## Output Format

Present analysis as an Analytics Health Report:

```markdown
# Analytics Health Report: [App Name]

## Overview
**App type:** [Free/Freemium/Subscription/Paid]
**Stage:** [Pre-launch/Early/Growing/Established]
**Data period:** [Date range analyzed]

## Funnel Health

| Stage | Metric | Value | Rating | Action |
|-------|--------|-------|--------|--------|
| Acquisition | Impressions/day | X,XXX | 🟢/🟡/🔴 | ... |
| Acquisition | Tap-through rate | X.X% | 🟢/🟡/🔴 | ... |
| Activation | Conversion rate | X.X% | 🟢/🟡/🔴 | ... |
| Retention | D1 retention | XX% | 🟢/🟡/🔴 | ... |
| Retention | D7 retention | XX% | 🟢/🟡/🔴 | ... |
| Retention | D30 retention | XX% | 🟢/🟡/🔴 | ... |
| Revenue | Conversion rate | X.X% | 🟢/🟡/🔴 | ... |
| Revenue | LTV | $XX.XX | 🟢/🟡/🔴 | ... |

## Primary Bottleneck
**[Stage name]** — [One sentence explanation of the biggest problem]

## Recommended Actions (Priority Order)
1. 🔴 [Critical fix] — Expected impact: [X]
2. 🟠 [High priority] — Expected impact: [X]
3. 🟡 [Medium priority] — Expected impact: [X]

## Overall Assessment
**Recommendation:** [Invest / Iterate / Pivot / Sunset]
**Rationale:** [2-3 sentences]
```

## References

- **metrics-reference.md** — Metric definitions, formulas, and benchmarks
- **app-store/keyword-optimizer/** — For ASO-related fixes
- **monetization/** — For pricing and paywall optimization
- **testing/** — For A/B test methodology

### Source: `growth/community-building`

# Community Building

Build and engage a community around your indie Apple app. Practical strategies for solo developers who have limited time but want meaningful growth through community.

## When This Skill Activates

Use this skill when the user:
- Wants to build a community around their app
- Asks about growing their social media presence
- Wants to start building in public
- Needs a content strategy for promoting their app
- Asks about developer marketing
- Wants to turn users into advocates

## Process

### Step 1: Gather Context

Ask the user via AskUserQuestion:

1. **Current presence**: Are you on any social platforms? How many followers?
2. **Time budget**: How many hours per week can you dedicate to community?
3. **Comfort level**: Are you comfortable sharing revenue, progress, struggles?
4. **App stage**: Pre-launch, just launched, growing, or established?
5. **Target audience**: Developers, general consumers, or a specific niche?

### Step 2: Platform Selection

Choose 1-2 platforms to focus on rather than spreading thin across many.

#### Platform Comparison

**Twitter/X**
- Audience: Large Apple developer community, tech enthusiasts
- Strengths: Fast feedback loops, viral potential, networking with other devs
- Weaknesses: Noisy, algorithm-dependent, declining trust among some users
- Best for: Developer tools, productivity apps, building in public
- Time investment: 15-30 min/day
- Growth speed: Moderate (1-3 months to gain traction)

**Mastodon (mastodon.social / indieweb.social)**
- Audience: Growing indie dev community, privacy-conscious users
- Strengths: No algorithm (chronological), supportive community, less noise
- Weaknesses: Smaller audience, less viral potential, fragmented servers
- Best for: Privacy-focused apps, developer tools, indie community engagement
- Time investment: 10-20 min/day
- Growth speed: Slow but genuine (3-6 months)

**Reddit**
- Audience: Highly engaged niche communities
- Strengths: Targeted subreddits, long-form discussion, SEO value
- Weaknesses: Anti-self-promotion rules, can be hostile, requires genuine participation
- Best for: Category-specific apps (r/productivity, r/fitness, r/budgeting)
- Subreddits: r/iOSProgramming, r/apple, r/SwiftUI, r/macapps, plus your app's category
- Time investment: 15-20 min/day (mostly commenting, not posting)
- Growth speed: Moderate if you contribute genuinely

**Discord**
- Audience: Power users, beta testers, engaged community members
- Strengths: Real-time interaction, deep engagement, beta testing hub
- Weaknesses: Requires active moderation, conversations are ephemeral, onboarding friction
- Best for: Apps with power users who want to discuss features and help shape the roadmap
- Time investment: 20-30 min/day (or batch in dedicated hours)
- Growth speed: Slow (requires seeding initial members)

**Threads**
- Audience: Growing, overlaps with Instagram audience
- Strengths: Growing platform, casual tone, integrated with Instagram
- Weaknesses: Still maturing, less developer-focused, algorithm-driven
- Best for: Consumer apps, visual apps, casual updates
- Time investment: 10-15 min/day
- Growth speed: Moderate (riding platform growth)

**Blog / Newsletter (Owned Platform)**
- Audience: Subscribers who opted in — highest intent
- Strengths: You own the audience, SEO benefits, long-form depth, email is reliable
- Weaknesses: Slow to build, requires consistent writing, higher effort per post
- Best for: Every app (this should be your long-term play, even if secondary)
- Platforms: Ghost, Buttondown, Substack, WordPress, or static site
- Time investment: 2-4 hours/week (one post per week)
- Growth speed: Very slow but most durable (6-12 months to meaningful audience)

#### Recommended Combinations

| Audience | Primary | Secondary |
|----------|---------|-----------|
| Developers | Twitter/X | Blog/newsletter |
| General consumers | Threads or Twitter/X | Newsletter |
| Privacy-conscious | Mastodon | Blog |
| Niche category | Reddit | Newsletter |
| Power users | Discord | Twitter/X |

### Step 3: Building in Public Strategy

Building in public means sharing your development journey transparently. It builds trust, creates accountability, and attracts early users.

#### What to Share

**High engagement (share often):**
- Progress updates with screenshots or short videos
- Design decisions and iterations (before/after)
- Milestones: download counts, revenue milestones, ratings
- Polls asking community to choose between features/designs
- Bugs you found and how you fixed them (relatable and educational)
- Weekly/monthly progress summaries

**Medium engagement (share periodically):**
- Revenue numbers and growth metrics (if comfortable)
- Lessons learned from mistakes
- Tools and processes you use
- App Store optimization experiments and results
- User testimonials and reviews

**Use sparingly:**
- Technical deep-dives (save for blog posts)
- Long threads (1-3 per month maximum)
- Philosophical musings about indie development

#### What NOT to Share

- Proprietary algorithms or trade secrets
- Features too far in advance (competitors watching, user expectations)
- Negative commentary about competitors
- Customer complaints or private messages
- Anything that could create legal liability
- Personal drama unrelated to the app journey

#### Transparency Levels

Choose your comfort level:

| Level | What You Share | Example |
|-------|---------------|---------|
| Fully transparent | Revenue, downloads, expenses, decisions | "March: $3,200 MRR, 847 subscribers, $400 in expenses" |
| Mostly transparent | Growth trends, decisions, learnings | "Crossed 800 subscribers this month, up 15% from February" |
| Selectively transparent | Progress, design, features | "Shipped the new dashboard this week, here's how it looks" |
| Journey-focused | Process, challenges, milestones | "Working on search — here's my approach to full-text indexing" |

All levels work. Pick what you are genuinely comfortable with and stay consistent.

### Step 4: Content Calendar (Realistic for Solo Developers)

This calendar assumes 3-5 hours per week total for community building.

#### Weekly Rhythm

| Day | Content Type | Time | Example |
|-----|-------------|------|---------|
| Monday | What I'm working on this week | 10 min | "This week: finishing the share sheet extension and fixing 3 bugs from user reports" |
| Wednesday | Tip, tutorial, or behind-the-scenes | 15 min | Screenshot of a SwiftUI trick, design iteration, or tool recommendation |
| Friday | Progress update or shipped feature | 15 min | "Shipped! Here's what's new in v2.3" or "Week in review: here's what got done" |

#### Monthly Additions

| Cadence | Content Type | Time | Example |
|---------|-------------|------|---------|
| 1st of month | Revenue/growth update | 30 min | Monthly metrics recap with takeaways |
| Mid-month | Blog post or tutorial | 2-3 hours | Technical post, lesson learned, or app development guide |
| End of month | Retrospective | 30 min | "What worked, what didn't, what's next" |

#### Batching Strategy

Do not create content in real-time throughout the week. Instead:

1. **Capture constantly**: Screenshot interesting moments as they happen (design iterations, bugs, metrics). Takes 30 seconds each.
2. **Batch create**: Dedicate 2 hours on Sunday (or whenever) to write all posts for the week using your captured screenshots.
3. **Schedule posts**: Use a scheduling tool (Buffer, Typefully, or native scheduling) so posts go out on the right days.
4. **Engage daily**: Spend 10-15 minutes responding to replies and engaging with others. This is separate from content creation.

### Step 5: Community Engagement Without Full-Time Effort

#### Daily Habits (10-15 minutes)

- Respond to every mention, reply, and DM (brevity is fine)
- Like/boost 3-5 posts from other developers in your space
- Comment genuinely on 2-3 posts from people you follow
- Check for your app's name/keywords being mentioned

#### Weekly Habits (30 minutes)

- Participate in relevant hashtags: #indiedev, #iosdev, #buildinpublic, #swiftui, #indieapps
- Share or boost someone else's launch/milestone (goodwill compounds)
- Respond to any App Store reviews (use review-response-writer skill)
- Check Reddit for relevant discussions where you can add value (not promote)

#### Monthly Habits (1 hour)

- Review your analytics: which posts got the most engagement? Do more of those.
- Follow new people in your space (genuine follow, not follow-for-follow)
- Reach out to 1-2 developers for potential collaboration or cross-promotion
- Update your bio/links if anything has changed

#### Engagement Rules

- **Be genuine**: Forced engagement is obvious. Only comment when you have something real to say.
- **Give more than you take**: The ratio should be roughly 80% supporting others, 20% promoting yourself.
- **Respond to everyone**: When you are small, responding to every comment builds loyalty.
- **Do not automate engagement**: Auto-likes, auto-comments, and bot followers backfire.
- **Be consistent, not constant**: Better to post 3 times per week every week than 10 times one week and nothing for a month.

### Step 6: Converting Community Members to Users and Advocates

#### Early Access and Beta Testing

- Offer TestFlight access to engaged followers before public launch
- Create a private Discord/Slack channel for beta testers
- Give beta testers a voice in feature prioritization
- Thank beta testers publicly when the app launches

#### Feature Requests and Public Roadmap

- Maintain a public roadmap (GitHub Projects, Notion, or Canny)
- When a community member suggests a feature you build, credit them publicly
- Let community vote on feature priority (creates investment in the product)
- When you ship a requested feature, tag the person who requested it

#### Referral and Sharing

- Build a share feature into your app (share results, creations, or achievements)
- Create share-worthy moments (streaks, milestones, completions)
- Make it easy to leave a review (use SKStoreReviewController at the right moment)
- Consider a referral program (if your app model supports it)

#### Social Proof Collection

| Source | How to Collect | How to Display |
|--------|---------------|----------------|
| App Store reviews | Screenshot 5-star reviews | App Store screenshots, website |
| Twitter/X testimonials | Screenshot positive tweets | Website testimonials section |
| Beta tester quotes | Ask directly during beta | App Store description, press kit |
| Usage milestones | Track in analytics | Social media posts ("10K users!") |

**When to ask for testimonials:**
- After a user complements your app (strike while the iron is hot)
- After successfully resolving a support request
- After a user shares your app organically
- After a major update that users are excited about

**How to ask:**
- "Thanks so much! Would you mind if I shared your kind words on our website?"
- "Would you be willing to leave a review on the App Store? It really helps indie apps like mine."
- Keep it low-pressure. Never guilt or pressure users.

### Step 7: Developer Blog as Marketing Channel

A blog is the highest-effort but highest-long-term-value community asset.

#### Content Types That Work

**Technical blog posts** (attract developer respect and SEO traffic):
- "How I built [feature] with SwiftUI"
- "Migrating from UIKit to SwiftUI: lessons learned"
- "Using Core ML to [interesting use case]"
- These get shared on Twitter, Hacker News, and iOS Dev Weekly

**Behind-the-scenes posts** (attract potential users):
- "Designing [App Name]'s onboarding"
- "Why I chose subscription pricing"
- "How I reduced my app's launch time by 60%"

**User-focused posts** (attract end-user awareness):
- "[App Name] tips and tricks you might not know"
- "How to [solve specific problem] with [App Name]"
- "What's coming in [App Name] 3.0"

#### Posting Cadence

- Minimum: 1 post per month (consistency matters more than frequency)
- Ideal: 2 posts per month (one technical, one behind-the-scenes)
- Maximum: 1 post per week (only if you enjoy writing and have content)

#### Distribution

After publishing a blog post:
1. Share on Twitter/X with a hook and key takeaway
2. Share on Mastodon
3. Submit to relevant newsletters (iOS Dev Weekly, Swift Weekly Brief)
4. Post to relevant Reddit communities (if it adds value, not just self-promotion)
5. Submit technical posts to Hacker News
6. Include in your next newsletter

## Output Format

Present community strategy as:

```markdown
# Community Building Plan: [App Name]

## Platform Strategy
**Primary:** [Platform] — [Why]
**Secondary:** [Platform] — [Why]

## Building in Public
**Transparency level:** [Fully/Mostly/Selectively/Journey-focused]
**Key themes:** [3-4 topics you'll share about]

## Weekly Content Calendar
| Day | Content | Platform |
|-----|---------|----------|
| Mon | [Type] | [Platform] |
| Wed | [Type] | [Platform] |
| Fri | [Type] | [Platform] |

## Monthly Content
- [ ] Revenue/growth update
- [ ] Blog post: [topic]
- [ ] Retrospective

## Engagement Plan
- Daily: [specific actions, 10-15 min]
- Weekly: [specific actions, 30 min]
- Monthly: [specific actions, 1 hour]

## Community → Users Pipeline
1. [How you'll convert followers to beta testers]
2. [How you'll convert beta testers to users]
3. [How you'll convert users to advocates]

## Metrics to Track
- Followers/subscribers (monthly)
- Engagement rate (weekly)
- Referral traffic to App Store (monthly)
- Community-driven downloads (if trackable)
```

## References

- **press-media/** — For media outreach beyond community
- **app-store/review-response-writer/** — For responding to App Store reviews
- **indie-business/** — For business context around community investment

### Source: `growth/indie-business`

# Indie Business Operations

Business fundamentals for indie Apple app developers. Covers the non-code aspects of running an app business — entity setup, taxes, revenue tracking, hiring, and financial planning.

**Disclaimer:** This skill provides general guidance, not legal or tax advice. Always consult a qualified accountant or attorney for your specific situation.

## When This Skill Activates

Use this skill when the user:
- Asks about business setup for their app (LLC, S-Corp)
- Wants to understand tax implications of app revenue
- Asks when to form an LLC or incorporate
- Wants guidance on hiring contractors or freelancers
- Asks about financial planning for going indie
- Mentions the Apple Small Business Program
- Wants to understand Apple's payment schedule and revenue tracking

## Process

### Step 1: Gather Context

Ask the user via AskUserQuestion:

1. **Location**: What country/state are you in? (tax implications vary significantly)
2. **Current status**: Full-time employed, part-time indie, or full-time indie?
3. **Revenue level**: Approximate monthly/annual app revenue (or expected if pre-launch)
4. **Business entity**: Do you currently have an LLC or company? Filing as sole proprietor?
5. **Specific question**: What business aspect are you trying to figure out?

### Step 2: Business Entity Options

#### United States

| Entity | Setup Cost | Annual Cost | Liability Protection | Tax Complexity | Best For |
|--------|-----------|-------------|---------------------|---------------|----------|
| Sole Proprietor | $0 | $0 | None | Lowest (Schedule C) | Hobby / early stage / < $10K/year |
| Single-Member LLC | $50-500 (state-dependent) | $0-800/year (state-dependent) | Yes | Low (pass-through) | Most indie developers |
| Multi-Member LLC | $50-500 | $0-800/year | Yes | Medium | Partnerships, co-founders |
| S-Corporation | $100-500 + legal fees | $500-2,000/year (payroll, filings) | Yes | High (payroll + corp return) | Revenue > $80-100K/year |

**Sole Proprietor**
- How: Just start earning. Report on Schedule C of personal tax return.
- Pros: Zero paperwork, zero cost, simplest possible setup.
- Cons: No personal liability protection. Your personal assets are at risk if someone sues.
- When to use: Testing the waters, revenue < $10K/year, minimal risk app (no user data, no health claims).

**Single-Member LLC (Recommended for Most Indie Devs)**
- How: File articles of organization with your state. Get an EIN from the IRS (free).
- Pros: Personal liability protection, flexible tax treatment, professional credibility, separate bank account.
- Cons: Annual state fees ($0 in many states, $800/year in California), must maintain separation between personal and business finances.
- When to upgrade from sole proprietor: Revenue exceeds $10-20K/year, OR you handle user data, OR users rely on your app for health/finance/safety.

**S-Corporation Election**
- How: Form an LLC, then file Form 2553 to elect S-Corp tax treatment.
- Pros: Payroll tax savings on profits above "reasonable salary."
- Cons: Must pay yourself a "reasonable salary" with payroll, quarterly payroll tax filings, more complex bookkeeping, annual corporate tax return.

**When to upgrade entity (decision tree):**
```
Revenue < $10K/year and low-risk app?
├── YES → Sole proprietor is fine
└── NO → Do you handle sensitive user data or have liability risk?
    ├── YES → Form an LLC now
    └── NO → Revenue > $20K/year?
        ├── YES → Form an LLC
        └── NO → Sole proprietor, but plan for LLC soon

Already have an LLC and net profit > $80K/year?
├── YES → Talk to a CPA about S-Corp election
└── NO → Stay as LLC
```

#### United Kingdom

| Entity | Best For |
|--------|----------|
| Sole Trader | Revenue < GBP 50K, simple setup |
| Limited Company (Ltd) | Revenue > GBP 50K, liability protection, tax efficiency |

- Sole trader: Register with HMRC for Self Assessment. Simple but no liability protection.
- Ltd company: Register with Companies House. Corporation tax on profits (25%), then dividend tax on drawings. More tax-efficient at higher revenue.

#### European Union (General Guidance)

- Most EU countries have sole proprietor equivalents and limited liability company options.
- VAT registration thresholds vary by country (but Apple handles VAT on app sales).
- Consider your country's social security implications for self-employment income.
- Consult a local accountant — EU tax rules are country-specific.

#### India

| Entity | Best For |
|--------|----------|
| Sole Proprietor | Starting out, simple |
| LLP (Limited Liability Partnership) | Liability protection, flexible |
| Private Limited Company | Scale, investors, credibility |

- GST registration may be required above threshold (currently INR 20 lakh).
- TDS (Tax Deducted at Source) applies to payments from Apple (check DTAA with Ireland/US).
- Private Limited preferred if you plan to raise investment.

### Step 3: Apple Small Business Program

#### Overview

- 15% commission (vs. 30% standard) on the first $1M in annual proceeds, applying to all app and in-app purchase revenue.
- Auto-enrollment: Apple enrolls you when you are eligible. No application needed if under $1M.
- Resets annually on January 1.

#### Impact Calculation

| Annual Revenue | Standard (30%) | Small Business (15%) | You Save |
|---------------|----------------|---------------------|----------|
| $10,000 | $3,000 | $1,500 | $1,500 |
| $50,000 | $15,000 | $7,500 | $7,500 |
| $100,000 | $30,000 | $15,000 | $15,000 |
| $500,000 | $150,000 | $75,000 | $75,000 |
| $1,000,000 | $300,000 | $150,000 | $150,000 |

Year-2+ subscriptions are already taxed at 15% regardless of enrollment, so the program's benefit concentrates in:
- Paid upfront apps
- One-time IAP revenue
- First-year subscription revenue

#### Important Details

- Revenue from all apps under your developer account is combined for the $1M threshold.
- If you have multiple developer accounts (e.g., personal + company), each is evaluated separately.

### Step 4: Tax Basics for App Revenue

#### What Apple Handles (You Don't Need to Worry About)

- **Sales tax / VAT**: Apple collects and remits sales tax, VAT, and equivalent taxes in virtually all jurisdictions. The price users pay includes these taxes, and Apple deducts them before your payout.
- **Tax forms to developers**: Apple provides 1099-MISC (US) or equivalent tax documentation annually.

#### What You Must Handle

**Reporting Income (US)**

Apple pays you monthly. All payouts are taxable income.

| Entity | How to Report | Tax Form |
|--------|--------------|----------|
| Sole Proprietor | Schedule C on personal return (1040) | 1040 + Schedule C + Schedule SE |
| Single-Member LLC | Same as sole proprietor (disregarded entity) | 1040 + Schedule C + Schedule SE |
| Multi-Member LLC | Partnership return | 1065 + K-1s |
| S-Corporation | Corporate return + salary W-2 | 1120-S + W-2 |

**Quarterly Estimated Taxes (US)**

If you expect to owe more than $1,000 in taxes for the year, you must make quarterly estimated payments. Missing these results in penalties.

| Quarter | Covers | Due Date |
|---------|--------|----------|
| Q1 | Jan-Mar | April 15 |
| Q2 | Apr-May | June 15 |
| Q3 | Jun-Aug | September 15 |
| Q4 | Sep-Dec | January 15 (next year) |

**How to estimate:** Take your expected annual net profit, multiply by your effective tax rate (federal + state + self-employment). Divide by 4.

**Deductible Expenses**

These reduce your taxable income. Keep receipts and records for everything.

| Expense | Example | Deductible? |
|---------|---------|------------|
| Apple Developer Program | $99/year | Yes |
| Hardware | Mac, iPhone, iPad for development | Yes (may need to depreciate) |
| Software | Xcode is free, but design tools, analytics, etc. | Yes |
| Hosting | Server costs, API services, CDN | Yes |
| Design | Freelance designer for app icon, screenshots | Yes |
| Marketing | Ad spend, press kit costs | Yes |
| Home office | Portion of rent/mortgage (if dedicated space) | Yes (with rules) |
| Conference travel | WWDC, local meetups | Yes |
| Education | Courses, books, tutorials for development skills | Yes |
| Professional services | Accountant, lawyer fees | Yes |
| Internet | Business portion of home internet | Partially |
| Health insurance (US) | Self-employed health insurance deduction | Yes (if self-employed) |

**International Considerations**

- If you sell apps globally, Apple handles international tax collection.
- US developers: file W-9 with Apple. Non-US developers: file W-8BEN or W-8BEN-E.
- Tax treaties between your country and Ireland/US may reduce withholding.
- Some countries require you to report worldwide income, including Apple payouts.

### Step 5: Revenue Tracking and Bookkeeping

#### Apple's Payment Schedule

- Apple pays monthly, approximately 33 days after the end of their fiscal month.
- Apple's fiscal months don't always align with calendar months (check your agreement).
- Payments are made via direct deposit to your bank account.
- Minimum payout threshold varies by region (often $10-150 depending on country).

#### Bookkeeping Setup

**Option 1: Spreadsheet (Free, < $50K revenue)**

Track monthly:
```
Month | Gross Revenue | Apple Commission | Net Revenue | Expenses | Net Profit
Jan   | $1,200        | $180             | $1,020      | $150     | $870
Feb   | $1,350        | $203             | $1,148      | $99      | $1,049
...
```

Categories to track:
- Gross revenue (total sales)
- Apple commission (15% or 30%)
- Net revenue (what Apple pays you)
- Development expenses
- Marketing expenses
- Tools and services
- Professional services
- Net profit (net revenue minus all expenses)
- Tax set-aside (25-35% of net profit)

**Option 2: Accounting Software ($50K+ revenue or if you want automation)**

| Software | Cost | Best For |
|----------|------|----------|
| Wave | Free | Simple invoicing and tracking |
| QuickBooks Self-Employed | $15/mo | US sole proprietors, auto-categorization |
| QuickBooks Online | $30/mo | LLCs and S-Corps, full accounting |
| Xero | $13/mo | International, clean interface |
| Bench | $249/mo | Full bookkeeping service (they do it for you) |

**Tax Reserve Rule**

Set aside 25-35% of net revenue (after Apple's cut) for taxes.

| Tax Component (US) | Approximate Rate |
|--------------------|-----------------|
| Federal income tax | 12-37% (bracket-dependent) |
| Self-employment tax | 15.3% (on first ~$160K) |
| State income tax | 0-13% (state-dependent) |
| **Combined effective rate** | **25-40%** |

Open a separate savings account, transfer ~30% of every payout in, and use it only for quarterly tax payments.

### Step 6: When to Hire

Hiring too early burns cash. Hiring too late burns you out. Use these guidelines.

#### Designers

**When to hire:**
- Your app icon looks amateurish compared to competitors
- Users comment on visual design in reviews
- You have maxed out SF Symbols and system UI components
- You need a marketing website, press kit, or App Store screenshots

**What to pay:**
- App icon: $200-1,000 (one-time)
- Full app design: $2,000-10,000 (one-time)
- Ongoing design: $50-150/hour (contract)

**Where to find:**
- Dribbble, Behance (portfolios)
- Twitter/X indie design community
- Referrals from other indie developers

#### Customer Support

**When to hire:**
- You spend > 5 hours/week on support emails
- Response time > 48 hours (users notice)
- Support is taking time away from development

**What to pay:**
- Part-time VA: $15-30/hour
- Dedicated support: $2,000-4,000/month

**Where to find:**
- Online communities for virtual assistants
- Referrals from other indie developers
- Start with a part-time contractor, not full-time

#### Marketing

**When to hire:**
- You have confirmed product-market fit (good retention)
- You know your acquisition cost and LTV
- Growth is limited by awareness, not product quality

**What to pay:**
- Freelance marketing: $50-150/hour
- ASO consultant: $500-2,000/month
- Content creator: $100-500/post

#### Contract Developers

**When to hire:**
- One-time platform expansion (watchOS, macOS port, widgets)
- Feature that requires expertise you lack (ML, AR, accessibility)
- You want to ship faster for a specific launch window

**What to pay:**
- iOS developer (contract): $75-200/hour
- Specialized (ML, AR): $100-250/hour
- Fixed-price project: define scope clearly, include revisions

#### Budget Rule

Do not hire until you can pay for 3 months from app revenue. Do not use personal savings to hire for a side project. The app should fund its own growth.

```
Can you pay this person for 3 months from app revenue alone?
├── YES → Hire (start with a trial project / 1-month contract)
└── NO → Wait until revenue supports it, or do it yourself
```

### Step 7: Insurance and Liability

#### Professional Liability Insurance (Errors and Omissions)

- Covers claims that your app caused harm due to errors, bugs, or bad advice.
- Cost: $500-1,500/year for indie developers.
- Consider if: your app gives health, financial, or safety-related advice.
- Providers: Hiscox, Hartford, biBERK, general business insurance brokers.

#### Cyber Liability Insurance

- Covers data breach costs (notification, credit monitoring, legal defense).
- Cost: $500-2,000/year depending on data volume.
- Consider if: you store personal user data on your servers.
- Less relevant if: your app is fully offline / on-device only.

#### LLC as Liability Shield

- An LLC separates your personal assets from business liabilities.
- If someone sues your app business, they cannot (generally) take your house or personal savings.
- Must maintain separation: separate bank account, do not commingle funds, sign contracts as the LLC.
- An LLC does NOT protect you from personal negligence or fraud.

### Step 8: Financial Planning for Indie Sustainability

#### Before Going Full-Time Indie

Checklist:
- [ ] 6 months of personal expenses saved (emergency fund)
- [ ] App revenue covers at least 50% of personal expenses (and growing)
- [ ] Health insurance sorted (US: marketplace, spouse's plan, or COBRA)
- [ ] Tax situation understood (talked to CPA)
- [ ] Spouse/partner on board with the plan and timeline
- [ ] Defined a "go back" threshold (if revenue drops below $X for Y months)

#### Revenue Milestones

| Monthly Net Revenue | What It Means | Action |
|--------------------|---------------|--------|
| $100-500/mo | Hobby money | Reinvest in tools, keep your day job |
| $500-2,000/mo | Side income | Cover app-related expenses, start saving |
| $2,000-5,000/mo | Part-time viable | Could reduce day job hours (if flexible) |
| $5,000-10,000/mo | Full-time viable (LCOL) | Full-time possible with lower cost of living |
| $10,000+/mo | Full-time viable (most areas) | Sustainable indie business |

Note: These are NET revenue figures (after Apple's cut and expenses, before taxes). Adjust for your location's cost of living.

#### Multiple Revenue Streams

Do not depend on a single app for your entire income. Strategies for diversification:

| Stream | Effort | Revenue Potential | Risk |
|--------|--------|-------------------|------|
| Second app | High | High | Platform risk |
| Consulting/freelancing | Medium | Medium-High | Time-limited |
| Technical writing | Low-Medium | Low-Medium | Consistent |
| Course/tutorial creation | High (upfront) | Medium (recurring) | One-time effort |
| Open source sponsorship | Low | Low | Unpredictable |
| Conference speaking | Low | Low (+ networking) | Seasonal |

**Recommended portfolio for sustainability:**
- 1-2 apps generating recurring revenue (primary income)
- Part-time consulting/freelancing (stable fallback)
- Content creation / writing (builds authority, generates leads for consulting)

#### Runway Calculation

```
Monthly personal expenses:        $______
Monthly app net revenue:           $______
Monthly consulting revenue:        $______
Total monthly income:              $______

Monthly surplus/deficit:           $______ (income - expenses)
Emergency fund balance:            $______
Runway (months):                   emergency fund / monthly expenses = ______ months

Sustainability ratio:              monthly income / monthly expenses = ______
                                   > 1.0 = sustainable
                                   > 1.5 = comfortable
                                   > 2.0 = thriving
```

## Output Format

Present business guidance as:

```markdown
# Indie Business Assessment: [User's Situation]

## Current Status
**Location:** [Country/State]
**Entity:** [Current entity type]
**Revenue:** [Approximate level]
**Status:** [Full-time employed / Part-time indie / Full-time indie]

## Recommendations

### Business Entity
**Recommendation:** [Entity type]
**Why:** [1-2 sentences]
**Action items:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Tax Obligations
- [ ] [Specific tax obligation based on their situation]
- [ ] [Another obligation]
**Estimated tax rate:** [X-X%]
**Quarterly payment amount:** ~$[X]

### Financial Health
| Metric | Current | Target |
|--------|---------|--------|
| Monthly net revenue | $X | $X |
| Expense ratio | X% | < 30% |
| Tax reserve | $X | $X |
| Emergency fund | X months | 6 months |
| Sustainability ratio | X.X | > 1.5 |

### Next Steps (Priority Order)
1. 🔴 [Most urgent action]
2. 🟠 [Important but not urgent]
3. 🟡 [Plan for this quarter]
```

## References

- **analytics-interpretation/** — For understanding if your metrics support business decisions
- **monetization/** — For pricing strategy and revenue model selection
- **community-building/** — For organic growth that reduces acquisition costs
- Apple Small Business Program: https://developer.apple.com/app-store/small-business-program/

### Source: `growth/press-media`

# Press & Media Outreach

Get press coverage and media attention for your indie Apple app. Covers everything from press kit preparation to finding the right journalists to crafting pitches that get responses.

## When This Skill Activates

Use this skill when the user:
- Wants press coverage for their app
- Is preparing for a launch and wants PR
- Wants to create a media kit or press kit
- Is looking for reviewers, bloggers, or YouTubers
- Asks about getting featured by Apple-focused outlets
- Wants to pitch their app to podcasts

## Process

### Step 1: Gather Context

Ask the user via AskUserQuestion:

1. **App details**: What does the app do? What platform(s)?
2. **Launch timing**: When is/was the launch? Is this a new app or major update?
3. **Story angle**: What makes this app unique or interesting?
4. **Previous coverage**: Have you been covered before? Any existing press kit?
5. **Budget**: Any budget for PR, or purely organic outreach?

### Step 2: Press Kit Preparation

A press kit makes it easy for journalists to write about your app. If they have to hunt for information, they will skip you.

#### Required Assets

| Asset | Specification | Notes |
|-------|--------------|-------|
| App icon | 1024x1024 PNG, no rounded corners | Journalists crop it themselves |
| Screenshots | 5-8 key screens, with and without device frames | Both raw and framed versions |
| App description (short) | 1 sentence, < 150 characters | For quick mentions |
| App description (medium) | 1 paragraph, 3-4 sentences | For brief coverage |
| App description (long) | 3 paragraphs | For feature articles |
| Developer bio | 2-3 sentences about you | Include relevant background |
| Developer photo | Headshot, 800x800+ | Professional but approachable |
| Fact sheet | Structured data | See template below |
| Promo video | 30-60 seconds (optional) | Dramatically increases coverage odds |

#### Fact Sheet Template

```
APP NAME: [Name]
DEVELOPER: [Your Name / Company]
LAUNCH DATE: [Date or "Available Now"]
PRICE: [Free / $X.XX / Free with subscription ($X.XX/mo)]
PLATFORMS: [iOS / macOS / iPadOS / watchOS / visionOS]
REQUIREMENTS: [iOS 17+ / macOS 14+]
WEBSITE: [URL]
APP STORE: [App Store link]
PRESS KIT: [URL to downloadable press kit]
CONTACT: [press@yourdomain.com]

KEY FEATURES:
- [Feature 1]: [One sentence description]
- [Feature 2]: [One sentence description]
- [Feature 3]: [One sentence description]
- [Feature 4]: [One sentence description]
- [Feature 5]: [One sentence description]

WHAT MAKES IT DIFFERENT:
[2-3 sentences on unique value proposition]
```

#### Press Kit Hosting Options

| Option | Cost | Pros | Cons |
|--------|------|------|------|
| presskit.html on your website | Free (hosting cost) | Professional, SEO benefits | Requires web dev |
| Notion page | Free | Easy to update, looks clean | Less professional URL |
| GitHub repo | Free | Easy asset downloads | Slightly technical feel |
| presskit() generator | Free | Industry standard format | Template-based |
| Dedicated presskit page | Free-$10/mo | Purpose-built for press kits | Another service to manage |

**Recommendation:** A `/press` page with a downloadable ZIP, everything inline so journalists can copy-paste without downloading.

### Step 3: Finding Relevant Journalists and Outlets

Build a targeted list of 20-30 contacts. Quality over quantity — 20 personalized pitches outperform 200 generic ones.

#### Apple-Focused Outlets

**Tier 1 — Major Coverage (hardest to get, biggest impact)**
| Outlet | Focus | Best For |
|--------|-------|----------|
| MacStories | In-depth iOS/Mac app reviews | Thoughtful, well-designed apps |
| 9to5Mac | Apple news and app coverage | News-worthy launches and updates |
| The Verge | Tech culture and reviews | Apps with broad appeal |
| TechCrunch | Startup and tech news | Apps with a business/funding angle |
| Daring Fireball | Apple commentary | Apps John Gruber would personally use |

**Tier 2 — Focused Coverage (more accessible, strong reach)**
| Outlet | Focus | Best For |
|--------|-------|----------|
| iMore | Apple ecosystem guides | How-to and practical apps |
| Six Colors | Apple analysis (Jason Snell) | Productivity and creative tools |
| Club MacStories | App discovery | Polished, design-forward apps |
| TUAW / Cult of Mac | Apple enthusiast coverage | Consumer-friendly apps |
| Indie App Santa | Indie app promotion | Well-designed indie apps |

**Tier 3 — Niche and Community (most accessible, targeted reach)**
| Outlet | Focus | Best For |
|--------|-------|----------|
| SwiftUI Weekly / iOS Dev Weekly | Developer newsletters | Developer tools and technical apps |
| Product Hunt | Launch platform | Any new app launch |
| Hacker News | Tech community | Technical or privacy-focused apps |
| Category-specific blogs | Niche audiences | Apps serving specific verticals |

#### YouTube Reviewers

Search for "best iOS apps" or "best Mac apps" on YouTube. Look for:
- Channels with 10K-500K subscribers (large enough for reach, small enough to respond)
- Recent uploads (active channel)
- Previous indie app coverage (not just major apps)
- Professional review style (not just listicles)

#### Podcast Hosts

| Podcast | Focus | Format |
|---------|-------|--------|
| AppStories (MacStories) | App discovery and discussion | Weekly discussion |
| Launched (Charlie Chapman) | Indie developer stories | Interview |
| Under the Radar (Marco/David) | Indie development | Discussion |
| Stacktrace | Apple dev and design | Discussion |
| Core Intuition (Jalkut/Simmons) | Indie Mac/iOS | Discussion |
| Accidental Tech Podcast | Apple tech (if relevant) | Discussion |

### Step 4: Pitch Timing

#### When to Reach Out

| Timing | Action |
|--------|--------|
| 3-4 weeks before launch | Reach out to Tier 1 outlets for exclusive/embargo |
| 2-3 weeks before launch | Broader outreach to Tier 2 and 3 |
| 1 week before launch | Follow up with non-responders (once only) |
| Launch day | Share on social media, Product Hunt, Hacker News |
| 1 week after launch | Thank journalists who covered you |

#### Best Days and Times
- **Best days:** Tuesday, Wednesday, Thursday
- **Best time:** 9-11 AM in the journalist's time zone
- **Worst days:** Monday (inbox overload), Friday (winding down)
- **Avoid:** Major Apple events (WWDC, iPhone launch, iPad event), CES week, holiday weeks

#### Follow-Up Cadence
- Send initial pitch
- Wait 5-7 business days
- Send ONE follow-up (add new info or angle, don't just repeat)
- If no response after follow-up, move on — do NOT keep emailing
- Never guilt-trip or get frustrated in follow-ups

### Step 5: Embargo Strategy

Embargoes let you give journalists early access in exchange for coordinated coverage on launch day.

#### Exclusive Strategy (Tier 1)
1. Pick ONE top-tier outlet that covers your app's category
2. Offer 1-2 week exclusive access before launch
3. Provide TestFlight build, press kit, and personal demo offer
4. Agree on publish date (your launch day)
5. Benefits: deep review, stronger relationship, headline coverage

#### Broader Embargo (Tier 2-3)
1. After exclusive is confirmed, invite 5-10 outlets under embargo
2. Set clear embargo lift date and time (usually launch day, 9 AM ET)
3. Include TestFlight link and press kit
4. Benefits: wave of coverage on launch day

#### Rules of Embargoes
- Always put embargo date/time in writing
- Honor the exclusive — don't give the same story to competitors
- If someone breaks embargo, never work with them again
- Be understanding if a small outlet publishes early by accident

### Step 6: Story Angles That Get Coverage

Journalists don't write about apps — they write about stories. Frame your pitch around a story, not a feature list.

#### Story Angles That Work for Indie Developers

**The Solo Developer Story**
- "I quit my job at [Big Tech] to build the app I always wanted"
- "I built this while recovering from [life event]"
- "A 22-year-old student built a top-rated [category] app"
- Why it works: readers love underdog stories

**Scratching Your Own Itch**
- "I couldn't find a [category] app that [specific need], so I built one"
- "As a [profession], I needed [specific tool] — it didn't exist"
- Why it works: authentic, relatable, shows deep domain knowledge

**Innovative Apple Technology Use**
- "First app to use [new iOS/macOS feature]"
- "Built entirely with SwiftUI and [new framework]"
- "Uses on-device ML for [clever application]"
- Why it works: Apple-focused outlets love showcasing platform capabilities

**Privacy-First Alternative**
- "A [category] app that keeps your data on your device"
- "No accounts, no servers, no tracking"
- Why it works: privacy is a hot topic, especially for Apple audience

**Accessibility Champion**
- "Designed VoiceOver-first for visually impaired users"
- "Built to help people with [condition]"
- Why it works: feel-good story, Apple values accessibility

**Design Excellence**
- "What happens when a designer builds their own app"
- Award-worthy UI/UX (Apple Design Awards angle)
- Why it works: Apple-focused outlets value design deeply

#### Story Angles That Do NOT Work
- "My app is better than [competitor]" — sounds petty
- "My app has 50 features" — feature lists are boring
- "My app is the best [category] app" — let reviewers decide
- "I need coverage to grow" — journalists are not your marketing team
- "Check out my app" (no angle at all) — gives them nothing to write about

### Step 7: After Coverage

#### When You Get Coverage
1. Thank the journalist publicly (tweet/post) and privately (email)
2. Share the article on all your channels
3. Add "As featured in..." to your App Store description and website
4. Screenshot the coverage for future press kit
5. Note which angle worked — use it for future pitches

#### When You Don't Get Coverage
- Do NOT send angry or disappointed emails
- Evaluate: was the pitch personalized? Was the timing right? Was the angle strong?
- Try a different angle next time (update, milestone, seasonal)
- Build the relationship anyway — comment on their articles, engage on social media
- Remember: most pitches don't get responses. A 10-20% response rate is normal.

## Reference Files

See **pitch-templates.md** for:
- Launch pitch email template
- Update/feature pitch template
- Story angle pitch template
- Podcast pitch template
- Follow-up template

## Output Format

Present outreach plan as:

```markdown
# Press Outreach Plan: [App Name]

## Press Kit Status
- [ ] App icon (1024x1024)
- [ ] Screenshots (X screens, framed and raw)
- [ ] Description (short / medium / long)
- [ ] Developer bio and photo
- [ ] Fact sheet
- [ ] Press kit hosted at [URL]

## Story Angle
**Primary:** [The main story angle]
**Secondary:** [Backup angle if primary doesn't land]

## Target List (20-30 contacts)

### Tier 1 — Exclusive Target
| Outlet | Contact | Why Them |
|--------|---------|----------|
| [outlet] | [name] | [reason] |

### Tier 2 — Embargo Group
| Outlet | Contact | Why Them |
|--------|---------|----------|
| ... | ... | ... |

### Tier 3 — Broad Outreach
| Outlet | Contact | Why Them |
|--------|---------|----------|
| ... | ... | ... |

## Timeline
| Date | Action |
|------|--------|
| [T-3 weeks] | Send exclusive pitch to Tier 1 |
| [T-2 weeks] | Send embargo pitches to Tier 2 |
| [T-1 week] | Send broad pitches to Tier 3, follow up Tier 1 |
| [Launch day] | Embargo lifts, social media push, Product Hunt |
| [T+1 week] | Thank journalists, share coverage |

## Pitch Drafts
[See pitch-templates.md for templates, customize for each contact]
```

## References

- **pitch-templates.md** — Email templates for all pitch types
- **community-building/** — For organic promotion via social media
- **app-store/** — For optimizing the product page journalists will link to

### Source: `growth/store-growth-audit`

# Store Growth Audit

Walk an app — new or live — through the full App Store growth playbook, phase by phase, and
produce a scorecard: what's installed, what's missing, what to do next, and who fixes it.

> The invariant: **every item has a detection rule**. Status comes from an ASC read, a codebase
> check, or an explicit question — never from vibes. If the user doesn't know, the item is
> 🟠 *unverified*, not assumed ✅.

## Where it fits (read the seams)

- **Not `store-signals`.** That is the continuous *signal → backlog* loop: are the numbers moving,
  did last cycle's bets pay off? This is the *structural* audit: is the machinery even installed?
  Run this quarterly (or pre-launch); run store-signals monthly. Trend questions route there.
- **Not `analytics-interpretation`.** Metric-quality judgments ("is 3.2% conversion good?") route
  there; this skill only records the baseline and whether benchmarks were checked.
- **Fixes never happen here.** Every 🔴/🟠 routes to a named sibling skill and (when driven from
  SwiftShip) an `/apple:*` command. This skill detects, scores, and routes. Read-only on ASC.

## When This Skill Activates

- "Audit my app's growth / store presence / what levers am I missing"
- A new app is approaching first submission and needs a growth plan, not just metadata
- Quarterly re-audit cadence, or after a launch that undershot expectations
- Before deciding to spend on paid acquisition ("is the free machinery done first?")
- Portfolio triage: "which of my apps is leaving the most on the table"

## The Model: P0–P9

54 items across ten phases. Each phase is a theme; the item detail lives in the checklist files.

| Phase | Theme | Items | Goal |
|-------|-------|-------|------|
| P0 | Day-one money toggles | 4 | Free margin + a measurement baseline before anything else |
| P1 | On-metadata ASO | 7 | Every indexed field working (title, subtitle, keywords, events, IAPs) |
| P2 | Conversion assets | 5 | Icon, screenshots, trust signals that convert impressions |
| P3 | Localization | 5 | Metadata-first market expansion + PPP pricing |
| P4 | Ratings machinery | 4 | Prompting, replying, and protecting the rating |
| P5 | Experimentation | 4 | PPO, CPPs, events as a testing habit |
| P6 | Featuring & free discovery | 6 | Nominations, new-OS adoption, storefronts, web presence |
| P7 | Paid & external traffic | 8 | Apple Ads ladder, launch spikes, pre-orders, codes |
| P8 | Earnings | 7 | Paywall experiments, win-backs, web checkout, bundles |
| P9 | Retention loop & ops | 4 | Retention surfaces + the recurring refresh calendar |

**Compressed priority** (used for action selection, not the maturity ladder): P0 money toggles
first → P1–P3 (metadata, conversion, localization) → P8.4 web checkout + P8.6 volume purchasing
(the 2026-era revenue unlocks) → everything else → P7 paid traffic last. Paid spend on top of
broken free machinery is burned money.

## Reference Files

| File | Purpose |
|------|---------|
| `detection-playbook.md` | Gather-once machinery: the MCP batch table, the codebase grep table, the single MANUAL question batch |
| `audit-checklist-p0-p4.md` | Items P0.1–P4.4 (25): foundations — money toggles through ratings |
| `audit-checklist-p5-p9.md` | Items P5.1–P9.4 (29): growth loops — experimentation through ops |

## Audit Process

1. **Resolve app, mode, and scope.** Get the `appId` (from `.planning/STATE.md` when driven by
   SwiftShip, else `list_apps` + confirm with the user). App live on the store → *existing* mode;
   not yet shipped → *pre-launch* mode. Scope defaults to the full P0–P9; a named phase runs
   scoped (see **Scoped Runs**). A prior scorecard (`GROWTH.md`), if present, is the diff baseline.
2. **Gather evidence — one pass, per `detection-playbook.md`.** Run the full MCP read batch, the
   full codebase grep pass, and ONE batched AskUserQuestion round for every MANUAL item. Never
   interleave gathering with scoring; never ask questions one at a time.
3. **Score all 54 items** against the gathered evidence using each item's `rule:`. Honor
   `applies-if:` guards (⚪ N/A) and ⏳ ANNOUNCED flags. Every status carries a terse, citable
   evidence string (`locales: en-US only`, `SBP: enrolled (user, 2026-07)`).
4. **Compute phase scores + maturity level** (rules below), and — when a prior scorecard exists —
   per-item deltas: fixed / regressed / new since last audit.
5. **Select the top 5 actions** (rule below).
6. **Write or refresh the scorecard** — in a SwiftShip project this is `.planning/GROWTH.md`
   (schema in SwiftShip's `templates/GROWTH.md`); standalone, write `GROWTH.md` beside the audit.
   Append an audit-history row; refresh the recurring calendar's next-due dates.
7. **Print the digest and route.** Maturity level, phase bar, top-5 with routes, deltas,
   unanswered MANUAL items, next three calendar due-dates, and the suggested next command/skill.

## Item Record Format

Each checklist item is a stanza:

```markdown
#### P3.1 Metadata-only localization (ja de fr es pt ko zh-Hans) — core
- detect: MCP `list_locales`
- rule: ✅ ≥7 target locales localized · 🟠 1–6 non-English locales · 🔴 en-only
- new-app: plan — seed target locales in the first submission
- fix: product/localization-strategy → /apple:localize
```

- **ID** (`P<phase>.<n>`) is stable forever — scorecards diff by ID; never renumber.
- **Flags** after the name: `core` (phase-gating), `RECURRING` (calendar-driven), `⏳ ANNOUNCED (WWDC26)`.
- **detect:** `MCP <tool>` · `CODE <grep>` · `MANUAL <question>` · `HYBRID` (combination).
- **rule:** explicit ✅/🟠/🔴 thresholds; optional `applies-if:` guard → ⚪ N/A when it fails.
- **new-app:** how pre-launch mode scores it — `plan` / `code` / `defer` (see Modes).
- **fix:** `sibling-skill → /apple:command` — the skill path works standalone; the command half
  applies when driven from SwiftShip.

**Status vocabulary:** ✅ done/healthy · 🟠 partial, stale, or unverified · 🔴 missing ·
⚪ N/A (applies-if failed; excluded from denominators) · ⏳ ANNOUNCED (not yet scoreable; excluded
from denominators; carries `prep:` and `recheck:` lines instead of a live rule).

## Scoring & Maturity

- **Phase score:** `✅ n / N applicable` — ⚪ and ⏳ items are excluded from N.
- **Phase grade:**
  - `Complete` — all applicable items ✅
  - `Working` — ≥50% ✅ **and no `core` item 🔴**
  - `Gaps` — any `core` item 🔴, or <50% ✅
  - `Not started` — no applicable item ✅
- **`core` items (13):** P0.1, P0.2, P1.1, P2.2, P2.4, P3.1, P4.1, P4.2, P5.1, P6.1, P8.1, P8.4, P9.2.
- **Growth maturity level (0–9):** the highest P such that every phase ≤ P grades at least
  `Working`. An app with P0–P3 working but P4 in gaps is Level 3, no matter how good P5–P9 look.
  The ladder follows numeric phase order; the compressed priority shapes only action selection.

**Top-5 action selection:** from all applicable 🔴 + 🟠 items, order by compressed-priority tier
(T1: P0 · T2: P1–P3 · T3: P8.4 + P8.6-when-live · T4: P4–P6, rest of P8, P9 · T5: P7), then within
a tier: `core` first, 🔴 before 🟠, lowest effort first. Two overrides: an **overdue RECURRING**
calendar item jumps to the top; always include at least one metadata-only quick win (shippable
without a binary release).

## Modes: Existing vs Pre-Launch

| | Existing app | Pre-launch |
|---|---|---|
| Evidence | ASC reads + codebase + MANUAL | `.planning/` docs + codebase + MANUAL |
| `new-app: plan` items | scored normally | planned-in-docs → 🟠 `planned`; absent → 🔴 |
| `new-app: code` items | scored normally | scored normally (greps work pre-launch) |
| `new-app: defer` items | scored normally | ⚪ with an activation trigger noted (e.g. "30 days post-launch") |
| Output framing | audit + deltas | launch plan (history row tagged `mode: pre-launch`) |

The first post-launch audit diffs cleanly against the pre-launch scorecard — same IDs, same schema.

## Scoped Runs (single phase)

"Run phase 3" = audit + worklist for that stage only.

- **Scope**: one phase (`P3`, bare `3` accepted) or a short range/list (`P1-P3`, `P0,P4`).
  Default remains the full P0–P9 audit.
- **Evidence**: pull only the `detection-playbook.md` rows whose items are in scope — MCP calls,
  greps, and MANUAL questions alike. A P1 run needs `get_metadata`/`list_locales`/`list_iap`/
  `list_app_events`, not sales reports or paywall greps.
- **Scorecard**: update only the in-scope phase tables and their Phase Scores rows; every other
  row stays untouched (stable IDs make the partial update safe). Append an Audit History row
  tagged `scope: P3`. Recompute the maturity level from the refreshed rows plus the untouched
  remainder — mark it `(est.)` if any out-of-scope phase has never been audited.
- **Output**: instead of the top-5, print the **phase worklist** — every applicable in-scope item
  with status, evidence, and route — ordered `core` first, 🔴 before 🟠, lowest effort first.
  End by offering to start the first route (gated, as always).
- A scoped run never rewrites items outside its scope, and never counts as a full re-audit for
  the Recurring Calendar's "announced-features recheck" row unless the ⏳ items are in scope.

## Output Format

The scorecard file (schema = SwiftShip `templates/GROWTH.md`):
header (app, date, mode, maturity) · phase-score table · top-5 actions · ten per-phase tables
(`ID | Item | Status | Evidence | Next step | Route`) · Watchlist (⏳ announced) · Recurring
Calendar · Baseline Metrics Snapshot · append-only Audit History.

The printed digest never dumps 54 rows:

```
Growth audit: <App> — Level 4/9 (existing, re-audit)
P0 ▓▓▓░ 3/4 · P1 ▓▓▓▓▓░░ 5/7 · P2 ▓▓▓░░ 3/5 · P3 ▓░░░░ 1/5 · P4 ▓▓▓▓ 4/4 …
Top 5: 1) P0.1 Apply to Small Business Program (route: growth/indie-business) …
Since last audit: 3 fixed, 1 regressed (P9.3 update freshness)
Unverified (you were unsure): P0.3 peer benchmarks, P7.2 brand defense
Calendar: featuring nomination due in 12 days · keyword refresh due 2026-10-01
Next: /apple:localize (or product/localization-strategy standalone)
```

## Routing Map

The only place the full route list lives; stanzas carry the short form.

| Audit area | Sibling skill (canonical) | SwiftShip command |
|---|---|---|
| SBP, business ops | `growth/indie-business` | — (ASC manual) |
| Billing grace/retry, subscription lifecycle | `generators/subscription-lifecycle` | `/apple:subscription` |
| Analytics baseline, benchmarks | `growth/analytics-interpretation` | `/apple:learn-from-store` |
| Keywords, metadata fields, AI tagging | `app-store/keyword-optimizer` | `/apple:metadata` (or `/apple:aso` if installed) |
| Apple Ads (discovery, exact, halo, brand) | `app-store/apple-search-ads` | `/apple:aso` if installed |
| Screenshots, previews, Creative Assets | `app-store/screenshot-planner` | `/apple:screenshots` |
| Icon + PPO + CPP experiments | `generators/product-page-optimization`, `generators/custom-product-pages` | `/apple:experiment` |
| In-app events | `generators/in-app-events` | `/apple:event` |
| Localization + PPP pricing | `product/localization-strategy`, `monetization` (pricing-models) | `/apple:localize` |
| Ratings: prompting, replies, protection | `app-store/ratings-mechanics`, `generators/review-prompt`, `app-store/review-response-writer` | `/apple:ratings` (health + replies); `/apple:ship` (phased release) |
| Featuring nominations | `generators/featuring-nomination` | — (ASC manual, calendar-driven) |
| New-OS adoption | — | `/apple:modernize` |
| App Intents / Spotlight | `apple-intelligence/app-intents`, `generators/spotlight-indexing` | `/apple:plan` |
| Web SEO, landing page, deal sites | `app-store/web-presence` | — |
| Pre-orders, offer codes, waitlist | `generators/pre-orders`, `generators/offer-codes-setup`, `product/beta-testing` | `/apple:testflight` |
| Paywall + pricing experiments | `generators/paywall-generator`, `monetization` | `/apple:subscription` |
| Win-backs, retention messaging | `generators/win-back-offers` | `/apple:subscription` |
| External purchase links / web checkout | `monetization/external-purchases` | — |
| Bundles, Family Sharing, volume licensing | `monetization/bundles-and-licensing` | — |
| Retention surfaces | `generators/onboarding-generator`, `generators/push-notifications`, `generators/widget-generator`, `generators/live-activity-generator` | `/apple:plan` |

## Caveats

- **Read-only on ASC.** The audit never mutates anything — not even analytics report setup (that
  routes to store-signals / `/apple:learn-from-store`). Surface → score → route.
- **MANUAL honesty.** Ask once, in one batch. "I don't know" scores 🟠 *unverified* — the
  scorecard tells the user what to go check, it never guesses.
- **⏳ items are rechecked every audit.** Apple ships announced features on its own schedule; each
  ⏳ stanza carries a dormant detection rule — when the feature is live, apply it and drop the flag.
- **Never reset the ratings summary** (P4.4). That item is a guardrail, not a task: resetting
  discards accumulated social proof and is almost never recoverable. Default ✅; flip to 🔴 only
  if a reset is planned or happened — then route to `app-store/ratings-mechanics` to stop it.
- Stable IDs. New items get new numbers; retired items keep their row with status `retired`.

### Source: `growth/store-signals`

# Store Signals

Pull what the *shipped* app is actually telling you and convert it into the next backlog — then
verify whether last cycle's bets paid off.

> This is the missing arc that turns build → ship into a **loop**:
> `ship → MEASURE → DIAGNOSE → next PLAN → build → ship → measure again…`
> The ledger (`SIGNALS.md`) is what makes it a loop and not a monthly report.

## Where it fits (read the seams)

- **Not `analytics-interpretation`.** That *interprets* a metric you hand it (is 14% D7 good?). This
  is the end-to-end operate loop: gather every signal → cluster → diagnose → **write a metric-tagged
  backlog** → **close last cycle's hypotheses**. It *uses* analytics-interpretation's benchmarks.
- **Read-only on ASC.** Never responds to reviews, never mutates metadata/pricing. It surfaces, gates
  on explicit OK, and routes the change to the right command (`next-version`, `bugfix`, `metadata`).
- **Feeds planning.** Output is a dated backlog appended to `ROADMAP.md` + rows in `SIGNALS.md`,
  consumed by `/apple:next-version` / `/apple:release`.

## Prerequisites

- A live (or TestFlight) app; resolve its `appId` from `.planning/STATE.md`, else `list_apps` + confirm.
- `.planning/` context: `STATE.md`, `APP.md`, `POSITIONING.md` (job-to-be-done + guardrails).
- `.planning/SIGNALS.md` if present — the OPEN hypotheses from prior runs (each with a target metric,
  recorded baseline, and "check-after" date). See **signals-ledger.md** for the ledger + backlog formats.

## Flow

1. **Load prior hypotheses.** Read `SIGNALS.md` → the OPEN rows to verify in step 5.
2. **Pull the signals (read-only), this period vs trailing:**
   - **Reviews / ratings** — `list_reviews` (recent, lowest-star first; flag unanswered), `get_review` for detail.
   - **Analytics** — `get_analytics_report`: retention, funnel/conversion, acquisition, impression→download.
     No report configured yet → `setup_analytics_reports` and note "retention/funnel lands next cycle."
   - **Sales** — `get_sales_report`: proceeds/units vs trailing 7/30-day.
   - **Stability / perf** — `get_diagnostics` (crash/hang signatures) + `get_perf_metrics` (launch, memory, energy).
   - **Beta** — `list_beta_feedback_crashes` if in TestFlight.
   - **Listing** — `get_metadata` to spot ASO conversion problems against current copy.
3. **Normalize & cluster.** Dedupe reviews into recurring themes (requests / complaints / praise) with
   frequency; attach magnitude (users / revenue / retention implicated). Weight by **frequency ×
   revenue impact**, not by how loud one reviewer is.
4. **Diagnose, filter, prioritize.** Map each cluster to the core metric it moves (rating · D7 · Pro
   conversion · crash-free rate · ASO conversion · proceeds); score **impact × confidence ÷ effort**.
   **Strategy filter:** cross-check `POSITIONING.md` — on-strategy → backlog; off-strategy → list under
   **"Declined (why)"** (never silently drop, never silently build). Carry the app's guardrails forward.
   Small-N (new app): say so, lean on qualitative reviews, flag low confidence.
5. **Close the prior loop.** For each OPEN hypothesis whose change shipped and whose "check-after" date
   passed: compare the target metric now vs its baseline → **WIN / REGRESSION / NEUTRAL**. WIN → resolve;
   REGRESSION → open a revert/rethink task; NEUTRAL → keep watching or retire.
6. **Write the backlog.** Append a dated, metric-tagged section to `ROADMAP.md` and update `SIGNALS.md`
   (one row per hypothesis; formats in **signals-ledger.md**). Then output a ranked digest (top 3-5
   "what's hurting most, why, the proposed move"), the loop-closure results, and a suggested next
   command (`/apple:next-version`, `/apple:bugfix` for a hot crash, `/apple:metadata` for an ASO fix).

## Portfolio mode

With no single app (or `--portfolio`): run steps 2-4 across every app in `list_apps`, then rank which
app to invest in next — biggest fixable revenue/retention/rating gap first (pairs with
`portfolio-health-monitor`). Output one line per app + the single highest-ROI move overall.

## Done

- A ranked cited digest, the WIN/REGRESSION/NEUTRAL loop-closure for last cycle, and a metric-tagged
  backlog written to `ROADMAP.md` + `SIGNALS.md`, with a routed next command.

## Caveats

- **Read-only on ASC** — never auto-apply pricing, metadata, or review responses; surface → gate → route.
- **Evidence over vibes** — every backlog item cites its signal + magnitude; the loudest reviewer is
  not the roadmap.
- **Always verify last cycle (step 5) before planning the next** — that closure is the whole point.
- Apple delivers analytics on its own schedule; a freshly configured report is empty until next cycle.

### Source: `growth_1256/store-growth-audit`

# Store Growth Audit

Walk an app — new or live — through the full App Store growth playbook, phase by phase, and
produce a scorecard: what's installed, what's missing, what to do next, and who fixes it.

> The invariant: **every item has a detection rule**. Status comes from an App Store Connect read, a codebase
> check, or an explicit question — never from vibes. If the user doesn't know, the item is
> 🟠 *unverified*, not assumed ✅.

## Where it fits (read the seams)

- **Not `store-signals`.** That is the continuous *signal → backlog* loop: are the numbers moving,
  did last cycle's bets pay off? This is the *structural* audit: is the machinery even installed?
  Run this quarterly (or pre-launch); run store-signals monthly. Trend questions route there.
- **Not `analytics-interpretation`.** Metric-quality judgments ("is 3.2% conversion good?") route
  there; this skill only records the baseline and whether benchmarks were checked.
- **Fixes never happen here.** Every 🔴/🟠 routes to a named sibling skill. This skill detects,
  scores, and routes. Read-only on App Store Connect.

## When This Skill Activates

- "Audit my app's growth / store presence / what levers am I missing"
- A new app is approaching first submission and needs a growth plan, not just metadata
- Quarterly re-audit cadence, or after a launch that undershot expectations
- Before deciding to spend on paid acquisition ("is the free machinery done first?")
- Portfolio triage: "which of my apps is leaving the most on the table"

## The Model: P0–P9

54 items across ten phases. Each phase is a theme; the item detail lives in the checklist files.

| Phase | Theme | Items | Goal |
|-------|-------|-------|------|
| P0 | Day-one money toggles | 4 | Free margin + a measurement baseline before anything else |
| P1 | On-metadata ASO | 7 | Every indexed field working (title, subtitle, keywords, events, IAPs) |
| P2 | Conversion assets | 5 | Icon, screenshots, trust signals that convert impressions |
| P3 | Localization | 5 | Metadata-first market expansion + PPP pricing |
| P4 | Ratings machinery | 4 | Prompting, replying, and protecting the rating |
| P5 | Experimentation | 4 | PPO, CPPs, events as a testing habit |
| P6 | Featuring & free discovery | 6 | Nominations, new-OS adoption, storefronts, web presence |
| P7 | Paid & external traffic | 8 | Apple Ads ladder, launch spikes, pre-orders, codes |
| P8 | Earnings | 7 | Paywall experiments, win-backs, web checkout, bundles |
| P9 | Retention loop & ops | 4 | Retention surfaces + the recurring refresh calendar |

**Compressed priority** (used for action selection, not the maturity ladder): P0 money toggles
first → P1–P3 (metadata, conversion, localization) → P8.4 web checkout + P8.6 volume purchasing
(the 2026-era revenue unlocks) → everything else → P7 paid traffic last. Paid spend on top of
broken free machinery is burned money.

## Common Mistakes

✅ Every status cites its evidence (an App Store Connect read, a code check, or the user's answer).
❌ Marking an item ✅ because it "sounds done" — unknown is 🟠 unverified.

## Reference Files

| File | Purpose |
|------|---------|
| `detection-playbook.md` | Gather-once machinery: the App Store Connect read table (with endpoints), the codebase grep table, the single MANUAL question batch |
| `audit-checklist-p0-p4.md` | Items P0.1–P4.4 (25): foundations — money toggles through ratings |
| `audit-checklist-p5-p9.md` | Items P5.1–P9.4 (29): growth loops — experimentation through ops |

## Audit Process

1. **Resolve app, mode, and scope.** Get the `appId` (`list_apps` filtered by bundle id, confirmed
   with the user). App live on the store → *existing* mode;
   not yet shipped → *pre-launch* mode. Scope defaults to the full P0–P9; a named phase runs
   scoped (see **Scoped Runs**). A prior scorecard (`docs/GROWTH.md`), if present, is the diff baseline.
2. **Gather evidence — one pass, per `detection-playbook.md`.** Run the full App Store Connect read batch, the
   full codebase grep pass, and ONE batched AskUserQuestion round for every MANUAL item. Never
   interleave gathering with scoring; never ask questions one at a time.
3. **Score all 54 items** against the gathered evidence using each item's `rule:`. Honor
   `applies-if:` guards (⚪ N/A) and ⏳ ANNOUNCED flags. Every status carries a terse, citable
   evidence string (`locales: en-US only`, `SBP: enrolled (user, 2026-07)`).
4. **Compute phase scores + maturity level** (rules below), and — when a prior scorecard exists —
   per-item deltas: fixed / regressed / new since last audit.
5. **Select the top 5 actions** (rule below).
6. **Write or refresh the scorecard** at `docs/GROWTH.md` (schema under **Output Format**).
   Append an audit-history row; refresh the recurring calendar's next-due dates.
7. **Print the digest and route.** Maturity level, phase bar, top-5 with routes, deltas,
   unanswered MANUAL items, next three calendar due-dates, and the suggested next skill.

## Item Record Format

Each checklist item is a stanza:

```markdown
#### P3.1 Metadata-only localization (ja de fr es pt ko zh-Hans) — core
- detect: ASC `list_locales`
- rule: ✅ ≥7 target locales localized · 🟠 1–6 non-English locales · 🔴 en-only
- new-app: plan — seed target locales in the first submission
- fix: product/localization-strategy
```

- **ID** (`P<phase>.<n>`) is stable forever — scorecards diff by ID; never renumber.
- **Flags** after the name: `core` (phase-gating), `RECURRING` (calendar-driven), `⏳ ANNOUNCED (WWDC26)`.
- **detect:** `ASC <read>` (a row in `detection-playbook.md`) · `CODE <grep>` · `MANUAL <question>` · `HYBRID` (combination).
- **rule:** explicit ✅/🟠/🔴 thresholds; optional `applies-if:` guard → ⚪ N/A when it fails.
- **new-app:** how pre-launch mode scores it — `plan` / `code` / `defer` (see Modes).
- **fix:** the sibling skill(s) that make the change.

**Status vocabulary:** ✅ done/healthy · 🟠 partial, stale, or unverified · 🔴 missing ·
⚪ N/A (applies-if failed; excluded from denominators) · ⏳ ANNOUNCED (not yet scoreable; excluded
from denominators; carries `prep:` and `recheck:` lines instead of a live rule).

## Scoring & Maturity

- **Phase score:** `✅ n / N applicable` — ⚪ and ⏳ items are excluded from N.
- **Phase grade:**
  - `Complete` — all applicable items ✅
  - `Working` — ≥50% ✅ **and no `core` item 🔴**
  - `Gaps` — any `core` item 🔴, or <50% ✅
  - `Not started` — no applicable item ✅
- **`core` items (13):** P0.1, P0.2, P1.1, P2.2, P2.4, P3.1, P4.1, P4.2, P5.1, P6.1, P8.1, P8.4, P9.2.
- **Growth maturity level (0–9):** the highest P such that every phase ≤ P grades at least
  `Working`. An app with P0–P3 working but P4 in gaps is Level 3, no matter how good P5–P9 look.
  The ladder follows numeric phase order; the compressed priority shapes only action selection.

**Top-5 action selection:** from all applicable 🔴 + 🟠 items, order by compressed-priority tier
(T1: P0 · T2: P1–P3 · T3: P8.4 + P8.6-when-live · T4: P4–P6, rest of P8, P9 · T5: P7), then within
a tier: `core` first, 🔴 before 🟠, lowest effort first. Two overrides: an **overdue RECURRING**
calendar item jumps to the top; always include at least one metadata-only quick win (shippable
without a binary release).

## Modes: Existing vs Pre-Launch

| | Existing app | Pre-launch |
|---|---|---|
| Evidence | App Store Connect reads + codebase + MANUAL | project docs (PRD, keyword table, launch plan) + codebase + MANUAL |
| `new-app: plan` items | scored normally | planned-in-docs → 🟠 `planned`; absent → 🔴 |
| `new-app: code` items | scored normally | scored normally (greps work pre-launch) |
| `new-app: defer` items | scored normally | ⚪ with an activation trigger noted (e.g. "30 days post-launch") |
| Output framing | audit + deltas | launch plan (history row tagged `mode: pre-launch`) |

The first post-launch audit diffs cleanly against the pre-launch scorecard — same IDs, same schema.

## Scoped Runs (single phase)

"Run phase 3" = audit + worklist for that stage only.

- **Scope**: one phase (`P3`, bare `3` accepted) or a short range/list (`P1-P3`, `P0,P4`).
  Default remains the full P0–P9 audit.
- **Evidence**: pull only the `detection-playbook.md` rows whose items are in scope — App Store
  Connect reads, greps, and MANUAL questions alike. A P1 run needs `get_metadata`/`list_locales`/
  `list_iap`/`list_app_events`, not sales reports or paywall greps.
- **Scorecard**: update only the in-scope phase tables and their Phase Scores rows; every other
  row stays untouched (stable IDs make the partial update safe). Append an Audit History row
  tagged `scope: P3`. Recompute the maturity level from the refreshed rows plus the untouched
  remainder — mark it `(est.)` if any out-of-scope phase has never been audited.
- **Output**: instead of the top-5, print the **phase worklist** — every applicable in-scope item
  with status, evidence, and route — ordered `core` first, 🔴 before 🟠, lowest effort first.
  End by offering to start the first route (gated, as always).
- A scoped run never rewrites items outside its scope, and never counts as a full re-audit for
  the Recurring Calendar's "announced-features recheck" row unless the ⏳ items are in scope.

## Output Format

The scorecard file, `docs/GROWTH.md`:
header (app, date, mode, maturity) · phase-score table · top-5 actions · ten per-phase tables
(`ID | Item | Status | Evidence | Next step | Route`) · Watchlist (⏳ announced) · Recurring
Calendar · Baseline Metrics Snapshot · append-only Audit History.

The printed digest never dumps 54 rows:

```
Growth audit: <App> — Level 4/9 (existing, re-audit)
P0 ▓▓▓░ 3/4 · P1 ▓▓▓▓▓░░ 5/7 · P2 ▓▓▓░░ 3/5 · P3 ▓░░░░ 1/5 · P4 ▓▓▓▓ 4/4 …
Top 5: 1) P0.1 Apply to Small Business Program (route: growth/indie-business) …
Since last audit: 3 fixed, 1 regressed (P9.3 update freshness)
Unverified (you were unsure): P0.3 peer benchmarks, P7.2 brand defense
Calendar: featuring nomination due in 12 days · keyword refresh due 2026-10-01
Next: product/localization-strategy
```

## Routing Map

The only place the full route list lives; stanzas carry the short form.

| Audit area | Skill |
|---|---|
| SBP, business ops | `growth/indie-business` |
| Billing grace/retry, subscription lifecycle | `generators/subscription-lifecycle` |
| Analytics baseline, benchmarks | `growth/analytics-interpretation` |
| Keywords, metadata fields, AI tagging | `app-store/keyword-optimizer` |
| Apple Ads (discovery, exact, halo, brand) | `app-store/apple-search-ads` |
| Screenshots, previews, Creative Assets | `app-store/screenshot-planner` |
| Icon + PPO + CPP experiments | `generators/product-page-optimization`, `generators/custom-product-pages` |
| In-app events | `generators/in-app-events` |
| Localization + PPP pricing | `product/localization-strategy`, `monetization` (pricing-models) |
| Ratings: prompting, replies, protection | `app-store/ratings-mechanics`, `generators/review-prompt`, `app-store/review-response-writer` |
| Featuring nominations | `generators/featuring-nomination` |
| New-OS adoption | `ios/migration-patterns`, `design/liquid-glass`, `apple-intelligence/on-device-ai-kit` |
| App Intents / Spotlight | `apple-intelligence/app-intents`, `generators/spotlight-indexing` |
| Web SEO, landing page, deal sites | `app-store/web-presence` |
| Pre-orders, offer codes, waitlist | `generators/pre-orders`, `generators/offer-codes-setup`, `product/beta-testing` |
| Paywall + pricing experiments | `generators/paywall-generator`, `monetization` |
| Win-backs, retention messaging | `generators/win-back-offers` |
| External purchase links / web checkout | `monetization/external-purchases` |
| Bundles, Family Sharing, volume licensing | `monetization/bundles-and-licensing` |
| Retention surfaces | `generators/onboarding-generator`, `generators/push-notifications`, `generators/widget-generator`, `generators/live-activity-generator` |

## Caveats

- **Read-only on App Store Connect.** The audit never mutates anything — not even analytics report
  setup (that routes to `growth/store-signals`). Surface → score → route.
- **MANUAL honesty.** Ask once, in one batch. "I don't know" scores 🟠 *unverified* — the
  scorecard tells the user what to go check, it never guesses.
- **⏳ items are rechecked every audit.** Apple ships announced features on its own schedule; each
  ⏳ stanza carries a dormant detection rule — when the feature is live, apply it and drop the flag.
- **Never reset the ratings summary** (P4.4). That item is a guardrail, not a task: resetting
  discards accumulated social proof and is almost never recoverable. Default ✅; flip to 🔴 only
  if a reset is planned or happened — then route to `app-store/ratings-mechanics` to stop it.
- Stable IDs. New items get new numbers; retired items keep their row with status `retired`.

## References

- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [App Store Connect Analytics](https://developer.apple.com/help/app-store-connect-analytics/)
- Related: `growth/store-signals`, `growth/analytics-interpretation`, `app-store/keyword-optimizer`

### Source: `growth_1256/store-signals`

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

### Source: `monetization`

# Monetization Strategy

End-to-end monetization guidance for Apple platform apps — from "should I charge?" to "here's your pricing page structure."

Sub-skills in this category: `external-purchases/` (US web checkout via the External Purchase Link entitlement, commission-flip architecture) and `bundles-and-licensing/` (own-app bundles, Family Sharing, cross-developer suites, institutional volume licensing). Route there when the question is beyond the single-app price tag.

## When This Skill Activates

Use this skill when the user:
- Asks "should I monetize my app?" or "is my app ready to charge?"
- Wants help choosing between freemium, subscription, or one-time purchase
- Needs pricing tier recommendations
- Asks about free trial strategy
- Wants to plan monetization for a specific app type (kids, therapy, productivity, etc.)
- Mentions "pricing", "revenue model", or "how to make money from my app"
- Wants to understand Apple's commission structure

## Process

### Phase 1: Readiness Assessment

Before recommending a pricing model, evaluate whether the app is ready to monetize. Ask these questions via AskUserQuestion:

**1. App Stage**
- Pre-launch (idea/prototype)
- Beta / TestFlight
- Live with users (< 1K)
- Live with traction (1K+ users)

**2. Value Proposition**
- What problem does your app solve?
- Who is the target user?
- What alternatives exist (including doing nothing)?

**3. Current State**
- Do you have active users?
- What's your retention like? (Day 1, Day 7, Day 30)
- Are users asking for features / willing to pay?

#### Readiness Scorecard

Evaluate against these criteria:

| Signal | Ready | Not Ready |
|--------|-------|-----------|
| Core value | Clear, differentiated | Still finding product-market fit |
| User retention | D7 > 20% | D7 < 10% |
| User feedback | "I'd pay for this" | Silence or complaints |
| Feature depth | Enough for free + paid split | Everything feels essential |
| Competition | You offer something unique | Commodity feature set |
| Polish | Professional quality | Rough edges everywhere |

**Recommendation thresholds:**
- 5-6 Ready signals → Monetize now
- 3-4 Ready signals → Soft-launch pricing (low price, gather data)
- 0-2 Ready signals → Focus on product first, monetize later

### Phase 2: Pricing Model Selection

Based on app type and user behavior, recommend the right model.

#### Decision Framework

```
Is the app used daily/weekly?
├── YES → Does it provide ongoing value?
│   ├── YES → SUBSCRIPTION
│   └── NO → ONE-TIME PURCHASE (with optional tip jar)
└── NO → Is it a utility/tool?
    ├── YES → ONE-TIME PURCHASE or FREEMIUM
    └── NO → Is it content-based?
        ├── YES → SUBSCRIPTION or CONSUMABLE IAP
        └── NO → FREEMIUM with premium unlock
```

#### Model Comparison

Read **pricing-models.md** for detailed comparison of each model:
- Subscriptions (auto-renewable)
- One-time purchase (paid upfront or freemium unlock)
- Consumable IAP (credits, tokens)
- Non-consumable IAP (feature unlock)
- Tip jar / patronage
- Ad-supported with premium upgrade

#### App-Type Recommendations

Read **app-type-guides.md** for specific guidance by app category:
- Productivity / task management
- Health / therapy / wellness
- Kids / education
- Creative tools
- Social / community
- Developer tools
- Finance / budgeting

### Phase 3: Tier Structure

Once a model is selected, design the tier structure.

#### Subscription Tiers (if applicable)

**Two-tier structure** (recommended for most indie apps):
```
FREE                    PRO ($X.99/mo or $XX.99/yr)
─────────────────────   ─────────────────────────────
Core functionality      Everything in Free
Limited usage/storage   Unlimited usage
Basic features          Advanced features
                        Priority support (optional)
                        Early access to new features
```

**Three-tier structure** (for apps with clear user segments):
```
FREE          PLUS ($X.99/mo)     PRO ($XX.99/mo)
────────────  ──────────────────  ──────────────────
Basic use     Power user          Professional/team
Ads/limits    No ads, more quota  Unlimited + extras
```

#### Pricing Psychology

- **Anchor pricing**: Show yearly first to make monthly look expensive
- **Price ending**: Use .99 for < $10, round numbers for premium ($19, $29)
- **Yearly discount**: 15-40% off monthly equivalent (sweet spot: ~30%)
- **Decoy effect**: Three tiers where middle looks like best value
- **Regional pricing**: Use App Store price tiers for automatic localization

#### Free vs. Paid Feature Split

The hardest decision. Follow these principles:

**Free tier should:**
- Demonstrate the core value proposition
- Be genuinely useful (not a crippled demo)
- Create natural upgrade moments ("you've hit the limit")
- Let users invest time/data before hitting the paywall

**Paid tier should:**
- Unlock power/convenience, not basic functionality
- Feel like "more of what you love" not "removing annoyances"
- Include at least one "hero feature" worth paying for alone

**❌ Bad splits:**
- Free: Can view data → Paid: Can edit data (feels hostile)
- Free: 3-day trial → Paid: Everything (no ongoing free value)
- Free: Everything → Paid: Remove ads (weak value prop)

**✅ Good splits:**
- Free: 5 projects → Paid: Unlimited projects + templates
- Free: Basic tracking → Paid: Insights, trends, export
- Free: Single device → Paid: Sync across devices + widgets

### Phase 4: Free Trial Strategy

#### Trial Types

| Type | Best For | Apple Support |
|------|----------|---------------|
| Introductory offer (free) | Subscriptions | Built-in via App Store |
| Introductory offer (discounted) | High-value subscriptions | Built-in via App Store |
| Feature-limited free tier | Freemium apps | N/A (your logic) |
| Time-limited full access | Productivity apps | Built-in via App Store |

#### Trial Duration Recommendations

| App Type | Trial Length | Reason |
|----------|-------------|--------|
| Daily-use productivity | 7 days | Quick to see value |
| Health/fitness tracking | 14 days | Need time to build habit |
| Creative tools | 7 days | One project cycle |
| Business/professional | 14-30 days | Need to integrate into workflow |
| Education/learning | 7 days | One learning cycle |

#### Trial Conversion Tactics

1. **Onboard to premium features** during trial (not free features)
2. **Show "trial ending" reminder** 2-3 days before expiration
3. **Highlight value received** ("You tracked 47 workouts this month")
4. **Offer annual option** at trial end (bigger commitment but better price)
5. **Win-back offer** if they don't convert (promotional offer after 30 days)

### Phase 5: Implementation Guidance

After strategy is set, guide implementation.

#### Apple Commission Structure

| Scenario | Apple's Cut | You Keep |
|----------|-------------|----------|
| Standard (Year 1) | 30% | 70% |
| After Year 1 of subscription | 15% | 85% |
| Small Business Program (< $1M/yr) | 15% | 85% |
| Small Business + Year 2 subscription | 15% | 85% |

**Important:** Revenue calculations should always account for Apple's cut. A $9.99/mo subscription with Small Business Program = ~$8.49/mo to you.

#### StoreKit 2 Implementation

For code generation, refer users to the **paywall-generator** skill:
```
Use the paywall-generator skill to create:
- StoreKit 2 subscription management
- Paywall UI (SwiftUI)
- Receipt validation
- Subscription status tracking
```

#### Paywall UI Patterns (HIG-Compliant)

**Do:**
- Show feature comparison (free vs. paid)
- Display price per period clearly
- Highlight savings on annual plan
- Include "Restore Purchases" button
- Show terms of service and privacy policy links
- Use system subscription views where available (iOS 18.4+)

**Don't:**
- Block the app immediately on launch
- Use dark patterns (hidden close button, confusing language)
- Make it hard to dismiss the paywall
- Misrepresent subscription terms
- Auto-select the most expensive option

#### App Store Review Guidelines (Monetization)

Key rules to follow:
- **3.1.1**: In-app purchase required for digital content/features
- **3.1.2**: Subscriptions must provide ongoing value
- **3.1.3**: "Reader" apps can link to web for account management
- **3.2.2**: Unacceptable business models (bait-and-switch, etc.)
- **5.6**: Developer Code of Conduct (no manipulative tactics)

## Output Format

Present monetization strategy as:

```markdown
# Monetization Strategy: [App Name]

## Readiness Assessment
**Score**: X/6 — [Ready to monetize / Soft-launch / Focus on product]

| Signal | Status | Notes |
|--------|--------|-------|
| Core value | ✅/❌ | ... |
| Retention | ✅/❌ | ... |
| User demand | ✅/❌ | ... |
| Feature depth | ✅/❌ | ... |
| Differentiation | ✅/❌ | ... |
| Polish | ✅/❌ | ... |

## Recommended Model
**[Model Name]** — [One-line rationale]

## Tier Structure

| Feature | Free | Pro ($X.99/mo) |
|---------|------|-----------------|
| ... | ✅ | ✅ |
| ... | Limited | Unlimited |
| ... | ❌ | ✅ |

**Annual pricing**: $XX.99/yr (XX% savings)

## Free Trial
**Type**: [Introductory offer / Feature-limited / etc.]
**Duration**: [X days]
**Conversion tactics**: [Bullet list]

## Revenue Projections (Conservative)

| Metric | Estimate |
|--------|----------|
| Monthly price | $X.99 |
| Annual price | $XX.99 |
| Conversion rate (free→paid) | X-X% |
| Revenue per 1K MAU | $XXX-$XXX/mo |

## Implementation Checklist
- [ ] Configure products in App Store Connect
- [ ] Implement StoreKit 2 (use paywall-generator skill)
- [ ] Design paywall UI
- [ ] Set up introductory offers
- [ ] Add analytics for conversion tracking
- [ ] Test with StoreKit Configuration file
- [ ] Submit for review

## Next Steps
1. [First action item]
2. [Second action item]
3. [Third action item]
```

## References

- **pricing-models.md** — Detailed comparison of all pricing models
- **app-type-guides.md** — Category-specific monetization recommendations
- **paywall-generator** skill — For StoreKit 2 code generation
- **app-store** skill — For App Store description optimization
- Apple App Store Review Guidelines §3 (Business)
- Apple StoreKit 2 documentation
