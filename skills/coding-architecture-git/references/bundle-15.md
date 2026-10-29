# Integrated Reference Bundle 15

Combines 11 related source skills from `coding-architecture-git` into one navigable reference file.

## Source map

- `plan-mode-orchestrator/SKILL.reference.md`
- `pptx/SKILL.reference.md`
- `pr-address-comments/SKILL.reference.md`
- `pr-creator/SKILL.reference.md`
- `pr-summarise/SKILL.reference.md`
- `programmatic-seo/SKILL.reference.md`
- `project-autonomy-bootstrap/SKILL.reference.md`
- `prs/SKILL.reference.md`
- `python-expert/SKILL.reference.md`
- `realtime-agent-orchestra/SKILL.reference.md`
- `refactor/SKILL.reference.md`

## Integrated guidance

### Source: `plan-mode-orchestrator`

# Plan Mode Orchestrator

The single most important skill in this arsenal. Enforces disciplined agentic work.

## When to Use
- User asks for a plan or explicitly says "plan mode"
- Task is larger than a single obvious edit
- Risk of breaking changes, architecture impact, or many files
- User says "don't write code yet"

## Core Behavior

1. **Immediately enter or confirm Plan Mode mindset.**
   - Explicitly state: "Entering Plan Mode. I will not edit files until you approve a plan."

2. **Investigate first (read-only where possible).**
   - Use subagents for broad investigation if the scope is large.
   - Run `grok inspect` if configuration or skills may be relevant.
   - Gather evidence: relevant files, existing patterns, tests, risks.

3. **Produce a high-quality plan with these sections:**
   - Goal (one sentence)
   - Current state (what exists today)
   - Proposed changes (numbered, smallest possible steps)
   - Files likely to change
   - Risks and mitigations
   - Verification method (tests, manual steps, `grok inspect`, etc.)
   - Estimated diff size / complexity

4. **Present the plan and STOP.**
   - Do not proceed to implementation.
   - Ask for approval: "Does this plan look good? Any changes before I proceed?"

5. **After approval:**
   - Execute one step at a time where possible.
   - Re-verify after each meaningful chunk.
   - Use other skills (tdd-intelligence, git-discipline, etc.) as appropriate.

## Subagent Usage
For large investigations, spawn 2–4 subagents with clear charters (e.g., "backend impact", "frontend impact", "test surface", "security surface") then synthesize.

## Success Criteria
- User has explicitly approved the plan (or a revised version).
- All subsequent edits are traceable to the approved plan.
- Verification steps from the plan were actually performed.

## Anti-Patterns to Avoid
- Jumping into edits "just to explore".
- Vague plans ("I'll refactor the auth layer").
- Plans that are really just implementation notes.

## Example Trigger Phrases
- "Plan the migration to the new MCP protocol"
- "Use Plan Mode to add the arena runner feature"
- "Don't edit anything yet, just plan the security hardening"

### Source: `pptx`

# PPTX Skill

## Workflow Selection

| Situation | Action |
|-----------|--------|
| User attaches or references a `.pptx` file | Read [editing.md](editing.md) — edit the template directly |
| No `.pptx` provided — create from scratch | Read [creating.md](creating.md) — use PptxGenJS templates |
| Read/analyze an existing presentation | See Reading Content below |

**When in doubt:** If ANY `.pptx` file is attached or mentioned, use the
editing workflow. The creating workflow is ONLY for when no existing
presentation exists at all.

---

## Reading Content

```bash
# Text extraction
python -m markitdown presentation.pptx

# Visual overview
python scripts/thumbnail.py presentation.pptx

# Raw XML
python scripts/office/unpack.py presentation.pptx unpacked/

# Structured inspection (placeholders, text, images, media — USE THIS)
python scripts/inspect_slide.py unpacked/ --theme --media
```


---

## QA (Required)

**Assume there are problems. Your job is to find them.**

Your first render is almost never correct. Approach QA as a bug hunt, not a confirmation step. If you found zero issues on first inspection, you weren't looking hard enough.

### Overlap Check & Auto-Fix (Before Packing)

**Run this on the unpacked XML before packing** — it catches overlapping text boxes instantly without needing a render, and `--fix` auto-applies text auto-shrink:

```bash
# Check and auto-fix (enables normAutofit on overlapping text shapes)
python scripts/check_overlaps.py unpacked/ --fix

# Check only (no modifications)
python scripts/check_overlaps.py unpacked/
```

The `--fix` flag adds `<a:normAutofit/>` to every text shape involved in an overlap or off-slide overflow. This makes PowerPoint auto-shrink text to fit the box. If issues remain after `--fix`, shorten text or resize shapes manually.

### Content QA

```bash
python -m markitdown output.pptx
```

Check for missing content, typos, wrong order.

**When using templates, check for leftover placeholder text:**

```bash
python -m markitdown output.pptx | grep -iE "xxxx|lorem|ipsum|this.*(page|slide).*layout"
```

If grep returns results, fix them before declaring success.

### Automated Checks

Run these before visual inspection to catch common issues automatically:

```bash
python scripts/detect_fonts.py output.pptx
python scripts/office/unpack.py output.pptx unpacked/
python scripts/check_overlaps.py unpacked/ --fix
python scripts/clean.py unpacked/
python scripts/office/pack.py unpacked/ final_output.pptx --original output.pptx
```

Fix any issues these report before proceeding to visual QA.

### Visual QA

You've been staring at the code and will see what you expect, not what's there.

Convert slides to images, then look for:

- Overlapping elements (text through shapes, lines through words, stacked elements)
- Text overflow or cut off at edges/box boundaries
- Decorative lines positioned for single-line text but title wrapped to two lines
- Source citations or footers colliding with content above
- Elements too close (< 0.3" gaps) or cards/sections nearly touching
- Uneven gaps (large empty area in one place, cramped in another)
- Insufficient margin from slide edges (< 0.5")
- Columns or similar elements not aligned consistently
- Low-contrast text (e.g., light gray text on cream-colored background)
- Low-contrast icons (e.g., dark icons on dark backgrounds without a contrasting circle)
- Text boxes too narrow causing excessive wrapping
- Leftover placeholder content
- **Style consistency** — does every slide feel like it belongs to the same deck?

For each slide, list issues or areas of concern, even if minor.

Read and analyze these images:
1. /path/to/slide-01.jpg (Expected: [brief description])
2. /path/to/slide-02.jpg (Expected: [brief description])

### Verification Loop

1. Generate slides → Convert to images → Inspect
2. Run `detect_fonts.py` and `check_overlaps.py`
3. **List issues found** (if none found, look again more critically)
4. Fix issues
5. **Re-verify affected slides** — one fix often creates another problem
6. Repeat until a full pass reveals no new issues

**Do not declare success until you've completed at least one fix-and-verify cycle.**

---

## Converting to Images

Convert presentations to individual slide images for visual inspection:

```bash
# Preferred — auto-calculates DPI from slide dimensions, with ODP fallback
python scripts/render_slides.py output.pptx

# Or with custom target resolution
python scripts/render_slides.py output.pptx --output_dir slides/ --width 1920 --height 1080
```

This creates `slide-1.png`, `slide-2.png`, etc. in a folder named after the input file.

**Fallback** (if render_slides.py dependencies aren't available):

```bash
python scripts/office/soffice.py --headless --convert-to pdf output.pptx
pdftoppm -jpeg -r 150 output.pdf slide
```

---

## Images

### Image Aspect Ratio Rule

**Always preserve the original aspect ratio of images.** When resizing, compute the target height from the source image's natural aspect ratio (or vice versa) — never set width and height independently, as this stretches or squashes the image.


### Image Sources

```javascript
// From file path
slide.addImage({ path: "images/chart.png", x: 1, y: 1, w: 5, h: 3 });

// From URL
slide.addImage({ path: "https://example.com/image.jpg", x: 1, y: 1, w: 5, h: 3 });

// From base64 (faster, no file I/O)
slide.addImage({ data: "image/png;base64,iVBORw0KGgo...", x: 1, y: 1, w: 5, h: 3 });
```

### Image Options

```javascript
slide.addImage({
  path: "image.png",
  x: 1, y: 1, w: 5, h: 3,
  rotate: 45,              // 0-359 degrees
  rounding: true,          // Circular crop
  transparency: 50,        // 0-100
  flipH: true,             // Horizontal flip
  flipV: false,            // Vertical flip
  altText: "Description",  // Accessibility
  hyperlink: { url: "https://example.com" }
});
```

### Image Sizing Modes

```javascript
// Contain - fit inside, preserve ratio
{ sizing: { type: 'contain', w: 4, h: 3 } }

// Cover - fill area, preserve ratio (may crop)
{ sizing: { type: 'cover', w: 4, h: 3 } }

// Crop - cut specific portion
{ sizing: { type: 'crop', x: 0.5, y: 0.5, w: 2, h: 2 } }
```

### Calculate Dimensions (preserve aspect ratio)

```javascript
const origWidth = 1978, origHeight = 923, maxHeight = 3.0;
const calcWidth = maxHeight * (origWidth / origHeight);
const centerX = (10 - calcWidth) / 2;

slide.addImage({ path: "image.png", x: centerX, y: 1.2, w: calcWidth, h: maxHeight });
```

---

## Dependencies

**All-in-one install:**

```bash
pip install "markitdown[pptx]" Pillow pdf2image python-pptx numpy defusedxml
npm install -g pptxgenjs
```

**System packages** (pre-installed in the Docker image):
- LibreOffice (`soffice`) — PDF conversion (auto-configured via `scripts/office/soffice.py`)
- Poppler (`pdftoppm`) — PDF to images
- fontconfig (`fc-list`) — font detection

### Source: `pr-address-comments`

You are helping the user address comments on their Pull Request. These comments may have come from an automated review agent or a team member.

OBJECTIVE: Help the user review and address comments on their PR.

# Comment Review Procedure

1. Run the `scripts/fetch-pr-info.js` script to get PR info and state. MAKE SURE you read the entire output of the command, even if it gets truncated.
2. Summarize the review status by analyzing the diff, commit log, and comments to see which still need to be addressed. Pay attention to the current user's comments. For resolved threads, summarize as a single line with a ✅. For open threads, provide a reference number e.g. [1] and the comment content.
3. Present your summary of the feedback and current state and allow the user to guide you as to what to fix/address/skip. DO NOT begin fixing issues automatically.

### Source: `pr-creator`

# Pull Request Creator

This skill guides the creation of high-quality Pull Requests that adhere to the
repository's standards.

## Workflow

Follow these steps to create a Pull Request:

1.  **Branch Management**: **CRITICAL:** Ensure you are NOT working on the
    `main` branch.
    - Run `git branch --show-current`.
    - If the current branch is `main`, you MUST create and switch to a new
      descriptive branch:
      ```bash
      git checkout -b <new-branch-name>
      ```

2.  **Commit Changes**: Verify that all intended changes are committed.
    - Run `git status` to check for unstaged or uncommitted changes.
    - If there are uncommitted changes, stage and commit them with a descriptive
      message before proceeding. NEVER commit directly to `main`.
      ```bash
      git add .
      git commit -m "type(scope): description"
      ```

3.  **Locate Template**: Search for a pull request template in the repository.
    - Check `.github/pull_request_template.md`
    - Check `.github/PULL_REQUEST_TEMPLATE.md`
    - If multiple templates exist (e.g., in `.github/PULL_REQUEST_TEMPLATE/`),
      ask the user which one to use or select the most appropriate one based on
      the context (e.g., `bug_fix.md` vs `feature.md`).

4.  **Read Template**: Read the content of the identified template file.

5.  **Draft Description**: Create a PR description that strictly follows the
    template's structure.
    - **Headings**: Keep all headings from the template.
    - **Checklists**: Review each item. Mark with `[x]` if completed. If an item
      is not applicable, leave it unchecked or mark as `[ ]` (depending on the
      template's instructions) or remove it if the template allows flexibility
      (but prefer keeping it unchecked for transparency).
    - **Content**: Fill in the sections with clear, concise summaries of your
      changes.
    - **Related Issues**: Link any issues fixed or related to this PR (e.g.,
      "Fixes #123").

6.  **Preflight Check**: Before creating the PR, run the workspace preflight
    script to ensure all build, lint, and test checks pass.
    ```bash
    npm run preflight
    ```
    If any checks fail, address the issues before proceeding to create the PR.

7.  **Push Branch**: Push the current branch to the remote repository.
    **CRITICAL SAFETY RAIL:** Double-check your branch name before pushing.
    NEVER push if the current branch is `main`.
    ```bash
    # Verify current branch is NOT main
    git branch --show-current
    # Push non-interactively
    git push -u origin HEAD
    ```

8.  **Create PR**: Use the `gh` CLI to create the PR. To avoid shell escaping
    issues with multi-line Markdown, write the description to a temporary file
    first.
    ```bash
    # 1. Write the drafted description to a temporary file
    # 2. Create the PR using the --body-file flag
    gh pr create --title "type(scope): succinct description" --body-file <temp_file_path>
    # 3. Remove the temporary file
    rm <temp_file_path>
    ```
    - **Title**: Ensure the title follows the
      [Conventional Commits](https://www.conventionalcommits.org/) format if the
      repository uses it (e.g., `feat(ui): add new button`,
      `fix(core): resolve crash`).

## Principles

- **Safety First**: NEVER push to `main`. This is your highest priority.
- **Compliance**: Never ignore the PR template. It exists for a reason.
- **Completeness**: Fill out all relevant sections.
- **Accuracy**: Don't check boxes for tasks you haven't done.

### Source: `pr-summarise`

# pr-summarise

Read one PR, print one table that lets the maintainer decide what to do with it, list the files worth reviewing by hand and how to test it manually, and open an interactive HTML explainer. Read-only on GitHub: never comment, approve, or push. The only thing written is the local HTML file.

## Resolve the PR

1. If the user passed a number, `#N`, or a PR URL, use that.
2. Else use the PR for the current branch. If there is none, stop and ask for a number.

## Gather

```bash
gh pr view <PR> --json number,title,body,author,url,additions,deletions,changedFiles,files,labels,closingIssuesReferences,reviewDecision,statusCheckRollup
gh pr diff <PR>
```

Read the whole diff, not just the description. Descriptions are claims; the diff is the evidence. Also read:

- Linked issues (`gh issue view N --comments`): reactions and distinct reporters are the best signal for how many users care.
- Surrounding code where the diff alone doesn't show whether something is exported, or what a changed function's callers do.

## Judge

Every answer is backed by the diff. Cite `file:line` in the Evidence column wherever a specific line drives the answer.

- **Solves**: one sentence, in terms of what a user can now do or no longer hits. Not a restatement of the title.
- **Important to solve**: Yes / Somewhat / No. A real bug or blocked use case with reporters is Yes. Speculative, cosmetic, or a single user's preference is No.
- **Adds complexity**: Yes / Slightly / No / Reduces. Count new options, config, branches, abstractions, dependencies, and concepts a user or maintainer must now hold. Net deletion is "Reduces".
- **Fallbacks that should be errors**: list each one. Look for `catch` blocks that swallow or log and continue, `?? default` / `|| default` on values that should be required, optional chaining that hides a missing value, silent retries, and "if unsupported, do something else" branches. A fallback is fine only when the fallback result is still correct; if it hides a caller's mistake or a broken invariant, it should throw.
- **Public type or API changes**: list each changed export, type, function signature, option, event shape, wire format, or CLI flag, marked breaking or additive. "None" only after checking what the changed files export.
- **Users positively affected**: an estimate with its basis, e.g. "Most: every user of `chat()` with streaming" or "Few: only custom adapter authors (1 reporter, 3 thumbs up)". Use Few / Some / Most / All and an approximate figure when the evidence supports one. Don't invent precision.
- **Users negatively affected**: same scale. Count anyone hit by a breaking change, a changed default, a performance cost, or a new required step. "None" is a valid answer.
- **Standards compliance**: does it change behaviour covered by [AG-UI](https://docs.ag-ui.com) (event types, event ordering, message and tool-call shapes) or any other standard or spec the repo follows (check README, CLAUDE.md, docs for claims such as OpenAPI, JSON Schema, MCP, OpenTelemetry, semver, WCAG)? Answer Improves / Neutral / Breaks, naming the standard and the rule. If the repo follows no relevant standard, say "N/A".
- **Better / proper fix**: is this the right fix, or is there a better one? Check whether it patches a symptom while the root cause sits elsewhere (grep the other callers of what it touches: are they still broken?), whether it duplicates something the codebase or a dependency already provides, and whether a smaller or more general change would do the same job. Answer "No, this is the proper fix" or describe the better fix in one or two sentences with where it would go.
- **Verdict**: exactly one of
  - **Approve**: correct, worth having, mergeable as is.
  - **Fix**: worth having but needs specific changes first. List them.
  - **Reject**: not worth solving, wrong approach, or costs outweigh the benefit. Say which.

A fallback that should be an error, an unintended breaking change, or a compliance break means the verdict is Fix at best. If a better fix exists, the verdict is Fix (rework it that way) or Reject (the better fix replaces this PR).

## Output

Print the PR title as a link, then exactly this table, then stop.

```markdown
[#N Title](url) by @author, +A/-D across F files

| | Answer | Evidence |
|---|---|---|
| Solves | | |
| Important to solve | | |
| Adds complexity | | |
| Fallbacks that should be errors | | |
| Public type / API changes | | |
| Users positively affected | | |
| Users negatively affected | | |
| AG-UI / standards compliance | | |
| Better / proper fix | | |
| **Verdict** | **Approve / Fix / Reject** | one-line reason |
```

If the verdict is Fix, follow the table with a numbered list of the required changes, each with `file:line`.

Then print **Review manually**: the 3 to 7 files where a human's eyes add the most, ranked, each with `path:line-range` and one line on what to check there. Prefer files holding core logic, public API or type changes, fallbacks flagged above, concurrency or security paths, and anything the tests don't cover. Skip lockfiles, generated code, snapshots, and pure renames. If the PR touches fewer files than that, list only the ones that matter.

```markdown
**Review manually**
1. `src/stream.ts:40-88` — new retry loop; check it can't swallow an abort.
2. ...
```

Then print **Test manually**: numbered steps a human can run to see the change work (and see the old bug, if it fixes one). Name the exact commands, inputs, or UI path, and the expected result after the PR versus before it. Include one edge case aimed at the riskiest part found above. Get the setup from the repo (README, `package.json` scripts, examples, tests the PR adds); don't invent commands. If the change can't be exercised by hand (types-only, internal refactor), say so and name the test that covers it.

```markdown
**Test manually**
1. `pnpm --filter example-chat dev`, open http://localhost:3000.
2. Send a message, then hit Stop mid-stream. Expect: stream ends, no error toast (before: "AbortError" toast).
3. Edge case: ...
```

Finish with the path of the HTML explainer. Nothing else: no preamble, no walkthrough of the diff.

## HTML explainer

Write one self-contained file to `${TMPDIR:-/tmp}/pr-<N>-explainer.html` (inline CSS and JS, no external requests), then open it (`open` on macOS, `xdg-open` on Linux). It explains the PR to someone who hasn't read it, in under two minutes. Keep every section short: sentences, not paragraphs.

Sections, in order:

1. **Header**: PR title, link, author, +A/-D, and the verdict as a coloured badge (Approve green, Fix amber, Reject red).
2. **In one breath**: two or three sentences on what changes and why.
3. **Before / After**: a toggle (or tabs) that swaps between the behaviour before and after the PR. For each, a short description plus the most telling code snippet or a small diagram (inline SVG or CSS boxes) of the flow. Pick the one or two changes that best show the difference, not every hunk.
4. **What's to love**: bullet list of the genuine strengths of the design, each tied to a file.
5. **What's bad**: bullet list of design problems, risks, fallbacks that should be errors, and the better fix if there is one, each tied to `file:line`. If there's nothing bad, say so in one line; don't invent problems.
6. **Review manually**: the same file list as the terminal output, each item expandable (`<details>`) to show the relevant diff excerpt.
7. **Test manually**: the same steps as the terminal output, as a checklist (`<input type="checkbox">`) with each command in a code block.

Interactivity stays native: `<details>`, a radio-button or button toggle for before/after, nothing heavier. Follow the system light/dark theme with `prefers-color-scheme`. Escape any code you embed (`<`, `>`, `&`).

### Source: `programmatic-seo`

# Programmatic SEO

You are an expert in programmatic SEO—building SEO-optimized pages at scale using templates and data. Your goal is to create pages that rank, provide value, and avoid thin content penalties.

## Initial Assessment

**Check for product marketing context first:**
If `.agents/product-marketing.md` exists (or `.claude/product-marketing.md`, or the legacy `product-marketing-context.md` filename, in older setups), read it before asking questions. Use that context and only ask for information not already covered or specific to this task.

Before designing a programmatic SEO strategy, understand:

1. **Business Context**
   - What's the product/service?
   - Who is the target audience?
   - What's the conversion goal for these pages?

2. **Opportunity Assessment**
   - What search patterns exist?
   - How many potential pages?
   - What's the search volume distribution?

3. **Competitive Landscape**
   - Who ranks for these terms now?
   - What do their pages look like?
   - Can you realistically compete?

---

## Core Principles

### 1. Unique Value Per Page
- Every page must provide value specific to that page
- Not just swapped variables in a template
- Maximize unique content—the more differentiated, the better

### 2. Proprietary Data Wins
Hierarchy of data defensibility:
1. Proprietary (you created it)
2. Product-derived (from your users)
3. User-generated (your community)
4. Licensed (exclusive access)
5. Public (anyone can use—weakest)

### 3. Clean URL Structure
**Use subfolders, not subdomains** — subfolders consolidate domain authority while subdomains split it:
- Good: `yoursite.com/templates/resume/`
- Bad: `templates.yoursite.com/resume/`

### 4. Genuine Search Intent Match
Pages must actually answer what people are searching for.

### 5. Quality Over Quantity
Better to have 100 great pages than 10,000 thin ones.

### 6. Avoid Google Penalties
- No doorway pages
- No keyword stuffing
- No duplicate content
- Genuine utility for users

---

## The 12 Playbooks (Overview)

| Playbook | Pattern | Example |
|----------|---------|---------|
| Templates | "[Type] template" | "resume template" |
| Curation | "best [category]" | "best website builders" |
| Conversions | "[X] to [Y]" | "$10 USD to GBP" |
| Comparisons | "[X] vs [Y]" | "webflow vs wordpress" |
| Examples | "[type] examples" | "landing page examples" |
| Locations | "[service] in [location]" | "dentists in austin" |
| Personas | "[product] for [audience]" | "crm for real estate" |
| Integrations | "[product A] [product B] integration" | "slack asana integration" |
| Glossary | "what is [term]" | "what is pSEO" |
| Translations | Content in multiple languages | Localized content |
| Directory | "[category] tools" | "ai copywriting tools" |
| Profiles | "[entity name]" | "stripe ceo" |

**For detailed playbook implementation**: See [references/playbooks.md](references/playbooks.md)

---

## Choosing Your Playbook

| If you have... | Consider... |
|----------------|-------------|
| Proprietary data | Directories, Profiles |
| Product with integrations | Integrations |
| Design/creative product | Templates, Examples |
| Multi-segment audience | Personas |
| Local presence | Locations |
| Tool or utility product | Conversions |
| Content/expertise | Glossary, Curation |
| Competitor landscape | Comparisons |

You can layer multiple playbooks (e.g., "Best coworking spaces in San Diego").

---

## Implementation Framework

### 1. Keyword Pattern Research

**Identify the pattern:**
- What's the repeating structure?
- What are the variables?
- How many unique combinations exist?

**Validate demand:**
- Aggregate search volume
- Volume distribution (head vs. long tail)
- Trend direction

### 2. Data Requirements

**Identify data sources:**
- What data populates each page?
- Is it first-party, scraped, licensed, public?
- How is it updated?

### 3. Template Design

**Page structure:**
- Header with target keyword
- Unique intro (not just variables swapped)
- Data-driven sections
- Related pages / internal links
- CTAs appropriate to intent

**Ensuring uniqueness:**
- Each page needs unique value
- Conditional content based on data
- Original insights/analysis per page

### 4. Internal Linking Architecture

**Hub and spoke model:**
- Hub: Main category page
- Spokes: Individual programmatic pages
- Cross-links between related spokes

**Avoid orphan pages:**
- Every page reachable from main site
- XML sitemap for all pages
- Breadcrumbs with structured data

### 5. Indexation Strategy

- Prioritize high-volume patterns
- Noindex very thin variations
- Manage crawl budget thoughtfully
- Separate sitemaps by page type

### 6. Choose the Build Platform

Check that the platform can hold the page count, refresh the data, render server-side HTML, branch on data for conditional sections, and control indexation per page. Prefer the existing site's CMS if it can; otherwise serve the set on a subpath of the main domain. Options and tradeoffs: [references/implementation-platforms.md](references/implementation-platforms.md).

---

## Quality Checks

### Pre-Launch Checklist

**Content quality:**
- [ ] Each page provides unique value
- [ ] Answers search intent
- [ ] Readable and useful

**Technical SEO:**
- [ ] Unique titles and meta descriptions
- [ ] Proper heading structure
- [ ] Schema markup implemented
- [ ] Page speed acceptable

**Internal linking:**
- [ ] Connected to site architecture
- [ ] Related pages linked
- [ ] No orphan pages

**Indexation:**
- [ ] In XML sitemap
- [ ] Crawlable
- [ ] No conflicting noindex

### Post-Launch Monitoring

Track: Indexation rate, Rankings, Traffic, Engagement, Conversion

Watch for: Thin content warnings, Ranking drops, Manual actions, Crawl errors

---

## Common Mistakes

- **Thin content**: Just swapping city names in identical content
- **Keyword cannibalization**: Multiple pages targeting same keyword
- **Over-generation**: Creating pages with no search demand
- **Poor data quality**: Outdated or incorrect information
- **Ignoring UX**: Pages exist for Google, not users

---

## Output Format

### Strategy Document
- Opportunity analysis
- Implementation plan
- Content guidelines

### Page Template
- URL structure
- Title/meta templates
- Content outline
- Schema markup

---

## Task-Specific Questions

1. What keyword patterns are you targeting?
2. What data do you have (or can acquire)?
3. How many pages are you planning?
4. What does your site authority look like?
5. Who currently ranks for these terms?
6. What's your technical stack?

---

## Related Skills

- **seo-audit**: For auditing programmatic pages after launch
- **schema**: For adding structured data
- **site-architecture**: For page hierarchy, URL structure, and internal linking
- **competitors**: For comparison page frameworks

### Source: `project-autonomy-bootstrap`

# Project Autonomy Bootstrap

## Overview

Single entry-point skill that applies the full set of autonomy-enhancing capabilities at session or project start and keeps them active throughout the work. It coordinates the six specialized skills listed below so that every complex task begins with rigorous planning, continuous evaluation, research depth when needed, multi-agent options, and automatic completion of unfinished work.

## Bundled Capabilities

This skill orchestrates:
- task-decomposition-verifier
- skill-gap-analyzer
- agent-eval-improver
- autonomous-research-synthesizer
- realtime-agent-orchestra
- background-completion-swarm
- product-delivery-swarm
- autonomous-ship-deploy

Load the individual skill files only when their detailed procedures are required. Prefer the coordinated workflow below for routine use.

## Startup Protocol (apply at the beginning of a chat or project)

1. Clarify the current goal or project state
   - Restate the highest-level objective in one precise sentence.
   - Note any prior context, open items, or constraints supplied by the user.

2. Run rapid skill-gap and readiness check
   - Confirm whether existing skills cover the required capabilities.
   - If material gaps exist, surface them immediately and offer to create or extend skills before proceeding.

3. Produce a verified high-effort plan
   - Apply hierarchical decomposition with explicit success criteria, verification checkpoints, and adversarial critique.
   - Identify parallelizable work and points that benefit from multi-agent orchestration.
   - Flag any sub-tasks that require deep multi-source research.

4. Establish evaluation criteria
   - Define measurable dimensions of thoroughness, autonomy, correctness, and completeness for the overall goal and key milestones.
   - These criteria will be used for ongoing scoring and improvement proposals.

5. Offer optional accelerators
   - Multi-agent setup (via realtime-agent-orchestra) when the work benefits from parallel specialized agents.
   - Background autonomous completion for any unfinished code or long-running items.
   - Focused research synthesis when evidence quality is critical.

6. Present the bootstrap summary
   - Concise verified plan.
   - Active evaluation criteria.
   - Recommended next actions ranked by impact on autonomy and thoroughness.
   - Explicit confirmation points where human input remains valuable versus fully automatable steps.

## Ongoing Protocol (while the project continues)

- After major milestones or when the user requests progress, re-score against the established evaluation criteria and surface improvement proposals.
- When new sub-goals appear, re-apply lightweight decomposition and gap analysis rather than starting from scratch.
- Prefer invoking the specialized skills by name only when their full depth is required; otherwise keep the coordinated lightweight path.

## Constraints

- Keep the startup summary short and actionable. Do not overwhelm the user with full skill text.
- Never invent project requirements or expand scope.
- Respect user preference for speed versus maximum thoroughness; default to high effort unless the user indicates otherwise.
- All individual skill rules (naming, safety, local-only operation, etc.) remain in force when those skills are activated.

### Source: `prs`

# Skill: GitHub PR & Git Management

## Goal

Standardize how the Gemini CLI Bot stages its changes, generates Pull Request
descriptions, and manages the lifecycle of both new and existing PRs.

## Staging & Patch Preparation (MANDATORY)

If you are proposing fixes and PR creation is enabled (per the System Directive):

1.  **Surgical Changes**: Only propose a **single improvement or fix per PR**.
    - **No Bundling**: You are STRICTLY FORBIDDEN from bundling unrelated
      changes. Changes are unrelated if they address different root causes.
    - **Examples**: Do not combine a script fix with a documentation update, an
      unrelated refactor, or a metrics script update. Metrics and fixes MUST
      be in separate PRs.
2.  **Generate PR Description**: Use the `write_file` tool to create
    `pr-description.md`.
    - **Title**: The very first line MUST be a concise, conventional title.
    - **Body**: The rest should be the markdown body explaining the change, why
      it is recommended, and the expected impact.
3.  **Stage Fixes**: You MUST explicitly stage your fixes using the
    `git add <files>` command.
4.  **Internal File Protection (CRITICAL)**: You are STRICTLY FORBIDDEN from
    staging internal bot management files. If they are accidentally staged, you
    MUST unstage them using `git reset <file>`.
    - **NEVER STAGE**: `pr-description.md`, `lessons-learned.md`,
      `branch-name.txt`, `pr-comment.md`, `pr-number.txt`, `issue-comment.md`, or
      anything in `history/`.

## Unblocking & PR Updates (Recovery)

If you are continuing work on an existing Task or responding to a comment on an
existing bot PR:

1.  **Target Existing Branch**: Use `write_file` to generate `branch-name.txt`
    containing the current branch name (e.g., `bot/task-BT-01`).
2.  **Track PR ID**: Use `write_file` to generate `pr-number.txt` containing the
    numeric PR ID.
3.  **Respond to Maintainers**:
    - For general responses, write your markdown comment to `issue-comment.md`.
    - For specific PR feedback, write your markdown response to `pr-comment.md`.
4.  **Handle CI Failures**: Diagnose failing checks using `gh run view`. Your
    priority must be generating a new patch and staging it with `git add` to fix
    the failure.

### Source: `python-expert`

# Python Expert

Ship idiomatic Python with tests, typing, and boring operational behavior.

## Grok Build Mode

- Use Plan Mode for package layout changes, API changes, async rewrites, migrations, or dependency upgrades.
- Use subagents when scope is broad:
  - `api`: public interfaces, routes, schemas, CLI commands.
  - `tests`: pytest coverage and fixtures.
  - `types`: mypy/pyright/ruff/typing issues.
  - `runtime`: async, IO, DB queries, performance.
- Arena-style comparison: if Arena Mode is available, compare alternative implementations for risky refactors. Otherwise ask subagents for independent approaches and choose the simplest verified path.

## Workflow

1. Detect project tooling from `pyproject.toml`, `setup.cfg`, `tox.ini`, `noxfile.py`, `requirements*.txt`, and CI.
2. Follow existing style and framework patterns.
3. Prefer small functions, explicit errors, and typed boundaries.
4. Add or update pytest tests for changed behavior.
5. Run the narrowest relevant command:
   - `pytest path/to/test.py -q`
   - `ruff check .`
   - `ruff format .`
   - `mypy .` or `pyright`
6. Summarize changed files, tests, and residual risk.

## Python Rules

- Do not add dependencies without a plan.
- Keep sync/async boundaries explicit.
- Use context managers for files, network clients, DB sessions, and locks.
- Validate external inputs with the project's existing validation layer.
- Preserve public APIs unless a breaking change is approved.
- Prefer `pathlib`, dataclasses/Pydantic where already used, and structured logging.

## Example Prompts

```text
Use python-expert. Add tests first, then fix this FastAPI bug. Run the narrowest pytest command.
```

```text
Use python-expert with subagents for API, tests, types, and runtime. Plan before editing.
```

### Source: `realtime-agent-orchestra`

# Realtime Agent Orchestra (RAO)

You are an autonomous expert at designing, scaffolding, and delivering complete realtime agentic orchestration systems. When this skill activates (via "start rao", "/rao", "/rao quick", or any matching phrase), fully comprehend the user's plain-English request (even vague or incomplete ones) and immediately deliver a complete, actionable suite of options or a full project. Do not ask clarifying questions unless the request is pure nonsense. Default to the richest feature set.

## Activation Modes

- **Normal mode** (`start rao`, `/rao`, or natural language): Present 4–6 ranked options with full details.
- **Quickstart mode** (`/rao quick` or "give me the default stack"): Skip the menu and immediately deliver one opinionated, production-ready hybrid stack (LangGraph + Pipecat + browser-use + FastAPI + Docker) as a complete runnable project.
- **Full-repo mode**: When user says "expand", "give me the full thing", "full repo", or picks an option for expansion, generate every file needed and offer a zip or direct GitHub push.
- **Daily Overview mode** (`daily overview`, `progress report`, `what's needing attention`, or similar): Scan the entire conversation history (and any previously generated projects/scaffolds mentioned) and produce a clear, prioritized daily stand-up style report covering progress made, open items, blockers, and what needs attention next.

## Core Behavior

1. Parse the request for desired features (chat UI, voice, browser/computer-use, multi-user, memory, streaming, tools, language preference Python/TS, specific frameworks, deployment target, security needs).
2. Check conversation history for any previously stated preferences (preferred models, UI, frameworks, "always use X"). Apply them silently and note that you remembered.
3. Present 4–6 concrete options ranked by fit (or the single quickstart stack).
4. For every option include:
   - One-sentence philosophy + pros/cons
   - Ready-to-paste system prompts / agent role definitions
   - Minimal but complete code scaffolding (or full project tree)
   - Docker Compose + one-command local launch
   - One-click cloud deploy configs (Modal, Railway, Fly.io)
   - Streaming / realtime transport notes
   - Memory, tool, MCP, multi-user auth patterns
   - Security & isolation rules
   - Eval / observability harness
   - Rough cost estimator (even with no hard limits)
5. Always prefer modern 2026 stacks with no cost ceilings.
6. Generate actual runnable code and prompts. Never leave TODOs.
7. End with a clear invitation to expand any option into a full repo, zip it, or push to GitHub.

## Preferred Default Stack (Quickstart & Fallback)

- Orchestration: LangGraph (stateful graphs, checkpointing, streaming, HITL)
- Sub-crews: CrewAI when role-based speed is needed
- LLM: Strongest available (Grok, Claude, GPT, Gemini) + local Ollama fallback
- Tools / MCP: native MCP + Playwright MCP + custom tools
- Voice: Pipecat (primary) or LiveKit Agents
- Browser / Computer Use: browser-use + Playwright MCP (sandboxed)
- Chat UI: FastAPI + WebSockets (full control) or Gradio for demos
- Hybrid UI: Voice + text simultaneous (Pipecat transport + text WebSocket)
- Memory: LangGraph checkpointers (SQLite/Postgres) + vector store
- Multi-user: session-based rooms with simple token or OAuth stub
- Runtime: Docker Compose local → Modal / Railway / Fly.io
- Observability: LangSmith + basic success-rate eval harness
- Language: Python primary, TypeScript secondary lane always offered

## Option Generation Template

**Option N — [Name] (Best for X)**
- Philosophy: ...
- Pros / Cons: ...
- Core prompts: (paste-ready)
- Scaffold: key files or "full project available on expand"
- Launch: `docker compose up` + cloud one-liners
- Realtime notes: transport, latency tips
- Security: isolation rules applied
- Multi-user / Auth: how it is handled
- Eval / Observability: included harness
- Cost estimate: rough tokens + infra
- Extensibility: voice / browser / TS version

Always include at least:
- Pure LangGraph supervisor + workers
- CrewAI hierarchical crew
- OpenAI Agents SDK / Swarm-style handoffs
- Voice-first Pipecat pipeline (multi-agent capable)
- Browser-agent focused (browser-use + orchestrator)
- Full hybrid (LangGraph + voice + computer use + multi-user)
- TypeScript variant (Vercel AI SDK / Mastra + LiveKit)

## Full-Repo & Scaffolding Rules

- When expanding, produce a complete project tree:
  - requirements.txt / package.json
  - main.py or index.ts
  - agents/ or agents/
  - docker-compose.yml
  - .env.example
  - README.md with exact run instructions
  - optional: Modal/Railway/Fly configs
  - eval/ harness
  - security notes
- Offer to zip the entire tree or push directly to a GitHub repo the user names.
- Use assets/ and scripts/ templates when available; copy and customize rather than inventing from scratch every time.
- Async everywhere. Streaming by default. Error recovery + HITL nodes included.
- For browser agents: always run inside isolated containers or cloud browser services. Never grant unrestricted host access.
- For multi-user: include simple room + token auth pattern or note OAuth stubs.

## Security & Isolation (always apply)

- Browser / computer-use agents must run in Docker or Browserbase / Stagehand cloud browsers.
- API keys only via environment variables; never hard-code.
- Multi-user sessions isolated by room ID + short-lived tokens.
- Human-in-the-loop gates for any destructive or external actions.
- Explicit user confirmation required before any agent is given file-system or network privileges beyond the sandbox.

## Cost Estimator

Even with no hard limits, always give a rough order-of-magnitude:
- LLM tokens (input/output per typical turn)
- Voice minutes (STT + TTS)
- Browser hours
- Infra (Modal / Railway free tier vs paid)

## Preference Memory

- Scan the current conversation for any stated likes/dislikes ("I always want Gradio", "prefer Grok", "no voice", "TypeScript only", etc.).
- Apply them automatically and say "Remembering your preference for X".
- At the end of a session offer to summarize preferences so the user can paste them next time or save them.

## TypeScript / JS Track

Always offer at least one pure TypeScript option using:
- Vercel AI SDK or Mastra for agents
- LiveKit Agents or Pipecat JS where available
- Next.js or plain Fastify + WebSockets for UI
- Same security, multi-user, eval, and deploy patterns

## Eval & Observability Templates

Every scaffold includes:
- Simple success-rate / tool-call success counter
- LangSmith tracing (or OpenTelemetry)
- Basic logging of latency and error rates
- Optional human feedback collection endpoint

## Medium-Spice Features Always Available

- Multi-user room patterns with auth tokens
- Simultaneous voice + text hybrid UI
- One-click Modal / Railway / Fly.io deploy configs
- Cost estimator on every option
- Security checklist baked into every scaffold

## Daily Overview / Progress Report Rules

When the user asks for a daily overview, progress report, status, or "what needs attention":

1. Thoroughly scan the full conversation history for:
   - Projects or scaffolds previously generated or discussed
   - Decisions made (chosen options, preferences, frameworks)
   - Open invitations ("pick one and expand", pending zips, GitHub pushes)
   - Any explicit TODOs, blockers, or next steps mentioned
   - Preference statements that are still active
2. Produce a clean, prioritized report with these sections:
   - **Progress since last check**: what was completed or advanced
   - **Open items needing attention**: ranked by urgency (blockers first)
   - **Pending decisions**: options still waiting for the user to pick
   - **Suggested next actions**: concrete, ordered list of what to do right now
   - **Preferences remembered**: current active preferences
3. Be brutally honest and concise. Highlight anything that is stalled or requires the user's input.
4. End with an offer to immediately act on the highest-priority item.

## Autonomy Rules

- Vague requests → invent a sensible default use-case (personal research orchestra, support swarm, coding agents, etc.) and still deliver the full rich suite.
- Expand any mentioned feature to the richest practical implementation.
- After delivering, stay in the loop: offer expansion to full repo, zip, GitHub push, modifications, or preference updates.
- Daily overviews are always available and should be proactive when the conversation has accumulated open work.

## References & Assets

Load on demand:
- references/framework-comparison.md
- references/voice-pipelines.md
- references/browser-computer-use.md
- references/scaffolding-templates.md
- references/security-isolation.md
- references/multi-user-auth.md
- references/eval-observability.md
- references/deploy-configs.md
- references/cost-estimator.md
- assets/ (copy real template files when generating full repos)
- scripts/ (helper generators if present)

### Source: `refactor`

# Refactor

## Overview

Improve code structure and readability without changing external behavior. Refactoring is gradual evolution, not revolution. Use this for improving existing code, not rewriting from scratch.

## When to Use

Use this skill when:

- Code is hard to understand or maintain
- Functions/classes are too large
- Code smells need addressing
- Adding features is difficult due to code structure
- User asks "clean up this code", "refactor this", "improve this"

---

## Refactoring Principles

### The Golden Rules

1. **Behavior is preserved** - Refactoring doesn't change what the code does, only how
2. **Small steps** - Make tiny changes, test after each
3. **Version control is your friend** - Commit before and after each safe state
4. **Tests are essential** - Without tests, you're not refactoring, you're editing
5. **One thing at a time** - Don't mix refactoring with feature changes

### When NOT to Refactor

```
- Code that works and won't change again (if it ain't broke...)
- Critical production code without tests (add tests first)
- When you're under a tight deadline
- "Just because" - need a clear purpose
```

---

## Common Code Smells & Fixes

### 1. Long Method/Function

```diff
# BAD: 200-line function that does everything
- async function processOrder(orderId) {
-   // 50 lines: fetch order
-   // 30 lines: validate order
-   // 40 lines: calculate pricing
-   // 30 lines: update inventory
-   // 20 lines: create shipment
-   // 30 lines: send notifications
- }

# GOOD: Broken into focused functions
+ async function processOrder(orderId) {
+   const order = await fetchOrder(orderId);
+   validateOrder(order);
+   const pricing = calculatePricing(order);
+   await updateInventory(order);
+   const shipment = await createShipment(order);
+   await sendNotifications(order, pricing, shipment);
+   return { order, pricing, shipment };
+ }
```

### 2. Duplicated Code

```diff
# BAD: Same logic in multiple places
- function calculateUserDiscount(user) {
-   if (user.membership === 'gold') return user.total * 0.2;
-   if (user.membership === 'silver') return user.total * 0.1;
-   return 0;
- }
-
- function calculateOrderDiscount(order) {
-   if (order.user.membership === 'gold') return order.total * 0.2;
-   if (order.user.membership === 'silver') return order.total * 0.1;
-   return 0;
- }

# GOOD: Extract common logic
+ function getMembershipDiscountRate(membership) {
+   const rates = { gold: 0.2, silver: 0.1 };
+   return rates[membership] || 0;
+ }
+
+ function calculateUserDiscount(user) {
+   return user.total * getMembershipDiscountRate(user.membership);
+ }
+
+ function calculateOrderDiscount(order) {
+   return order.total * getMembershipDiscountRate(order.user.membership);
+ }
```

### 3. Large Class/Module

```diff
# BAD: God object that knows too much
- class UserManager {
-   createUser() { /* ... */ }
-   updateUser() { /* ... */ }
-   deleteUser() { /* ... */ }
-   sendEmail() { /* ... */ }
-   generateReport() { /* ... */ }
-   handlePayment() { /* ... */ }
-   validateAddress() { /* ... */ }
-   // 50 more methods...
- }

# GOOD: Single responsibility per class
+ class UserService {
+   create(data) { /* ... */ }
+   update(id, data) { /* ... */ }
+   delete(id) { /* ... */ }
+ }
+
+ class EmailService {
+   send(to, subject, body) { /* ... */ }
+ }
+
+ class ReportService {
+   generate(type, params) { /* ... */ }
+ }
+
+ class PaymentService {
+   process(amount, method) { /* ... */ }
+ }
```

### 4. Long Parameter List

```diff
# BAD: Too many parameters
- function createUser(email, password, name, age, address, city, country, phone) {
-   /* ... */
- }

# GOOD: Group related parameters
+ interface UserData {
+   email: string;
+   password: string;
+   name: string;
+   age?: number;
+   address?: Address;
+   phone?: string;
+ }
+
+ function createUser(data: UserData) {
+   /* ... */
+ }

# EVEN BETTER: Use builder pattern for complex construction
+ const user = UserBuilder
+   .email('test@example.com')
+   .password('secure123')
+   .name('Test User')
+   .address(address)
+   .build();
```

### 5. Feature Envy

```diff
# BAD: Method that uses another object's data more than its own
- class Order {
-   calculateDiscount(user) {
-     if (user.membershipLevel === 'gold') {
+       return this.total * 0.2;
+     }
+     if (user.accountAge > 365) {
+       return this.total * 0.1;
+     }
+     return 0;
+   }
+ }

# GOOD: Move logic to the object that owns the data
+ class User {
+   getDiscountRate(orderTotal) {
+     if (this.membershipLevel === 'gold') return 0.2;
+     if (this.accountAge > 365) return 0.1;
+     return 0;
+   }
+ }
+
+ class Order {
+   calculateDiscount(user) {
+     return this.total * user.getDiscountRate(this.total);
+   }
+ }
```

### 6. Primitive Obsession

```diff
# BAD: Using primitives for domain concepts
- function sendEmail(to, subject, body) { /* ... */ }
- sendEmail('user@example.com', 'Hello', '...');

- function createPhone(country, number) {
-   return `${country}-${number}`;
- }

# GOOD: Use domain types
+ class Email {
+   private constructor(public readonly value: string) {
+     if (!Email.isValid(value)) throw new Error('Invalid email');
+   }
+   static create(value: string) { return new Email(value); }
+   static isValid(email: string) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email); }
+ }
+
+ class PhoneNumber {
+   constructor(
+     public readonly country: string,
+     public readonly number: string
+   ) {
+     if (!PhoneNumber.isValid(country, number)) throw new Error('Invalid phone');
+   }
+   toString() { return `${this.country}-${this.number}`; }
+   static isValid(country: string, number: string) { /* ... */ }
+ }
+
+ // Usage
+ const email = Email.create('user@example.com');
+ const phone = new PhoneNumber('1', '555-1234');
```

### 7. Magic Numbers/Strings

```diff
# BAD: Unexplained values
- if (user.status === 2) { /* ... */ }
- const discount = total * 0.15;
- setTimeout(callback, 86400000);

# GOOD: Named constants
+ const UserStatus = {
+   ACTIVE: 1,
+   INACTIVE: 2,
+   SUSPENDED: 3
+ } as const;
+
+ const DISCOUNT_RATES = {
+   STANDARD: 0.1,
+   PREMIUM: 0.15,
+   VIP: 0.2
+ } as const;
+
+ const ONE_DAY_MS = 24 * 60 * 60 * 1000;
+
+ if (user.status === UserStatus.INACTIVE) { /* ... */ }
+ const discount = total * DISCOUNT_RATES.PREMIUM;
+ setTimeout(callback, ONE_DAY_MS);
```

### 8. Nested Conditionals

```diff
# BAD: Arrow code
- function process(order) {
-   if (order) {
-     if (order.user) {
-       if (order.user.isActive) {
-         if (order.total > 0) {
-           return processOrder(order);
+         } else {
+           return { error: 'Invalid total' };
+         }
+       } else {
+         return { error: 'User inactive' };
+       }
+     } else {
+       return { error: 'No user' };
+     }
+   } else {
+     return { error: 'No order' };
+   }
+ }

# GOOD: Guard clauses / early returns
+ function process(order) {
+   if (!order) return { error: 'No order' };
+   if (!order.user) return { error: 'No user' };
+   if (!order.user.isActive) return { error: 'User inactive' };
+   if (order.total <= 0) return { error: 'Invalid total' };
+   return processOrder(order);
+ }

# EVEN BETTER: Using Result type
+ function process(order): Result<ProcessedOrder, Error> {
+   return Result.combine([
+     validateOrderExists(order),
+     validateUserExists(order),
+     validateUserActive(order.user),
+     validateOrderTotal(order)
+   ]).flatMap(() => processOrder(order));
+ }
```

### 9. Dead Code

```diff
# BAD: Unused code lingers
- function oldImplementation() { /* ... */ }
- const DEPRECATED_VALUE = 5;
- import { unusedThing } from './somewhere';
- // Commented out code
- // function oldCode() { /* ... */ }

# GOOD: Remove it
+ // Delete unused functions, imports, and commented code
+ // If you need it again, git history has it
```

### 10. Inappropriate Intimacy

```diff
# BAD: One class reaches deep into another
- class OrderProcessor {
-   process(order) {
-     order.user.profile.address.street;  // Too intimate
-     order.repository.connection.config;  // Breaking encapsulation
+   }
+ }

# GOOD: Ask, don't tell
+ class OrderProcessor {
+   process(order) {
+     order.getShippingAddress();  // Order knows how to get it
+     order.save();  // Order knows how to save itself
+   }
+ }
```

---

## Extract Method Refactoring

### Before and After

```diff
# Before: One long function
- function printReport(users) {
-   console.log('USER REPORT');
-   console.log('============');
-   console.log('');
-   console.log(`Total users: ${users.length}`);
-   console.log('');
-   console.log('ACTIVE USERS');
-   console.log('------------');
-   const active = users.filter(u => u.isActive);
-   active.forEach(u => {
-     console.log(`- ${u.name} (${u.email})`);
-   });
-   console.log('');
-   console.log(`Active: ${active.length}`);
-   console.log('');
-   console.log('INACTIVE USERS');
-   console.log('--------------');
-   const inactive = users.filter(u => !u.isActive);
-   inactive.forEach(u => {
-     console.log(`- ${u.name} (${u.email})`);
-   });
-   console.log('');
-   console.log(`Inactive: ${inactive.length}`);
- }

# After: Extracted methods
+ function printReport(users) {
+   printHeader('USER REPORT');
+   console.log(`Total users: ${users.length}\n`);
+   printUserSection('ACTIVE USERS', users.filter(u => u.isActive));
+   printUserSection('INACTIVE USERS', users.filter(u => !u.isActive));
+ }
+
+ function printHeader(title) {
+   const line = '='.repeat(title.length);
+   console.log(title);
+   console.log(line);
+   console.log('');
+ }
+
+ function printUserSection(title, users) {
+   console.log(title);
+   console.log('-'.repeat(title.length));
+   users.forEach(u => console.log(`- ${u.name} (${u.email})`));
+   console.log('');
+   console.log(`${title.split(' ')[0]}: ${users.length}`);
+   console.log('');
+ }
```

---

## Introducing Type Safety

### From Untyped to Typed

```diff
# Before: No types
- function calculateDiscount(user, total, membership, date) {
-   if (membership === 'gold' && date.getDay() === 5) {
-     return total * 0.25;
-   }
-   if (membership === 'gold') return total * 0.2;
-   return total * 0.1;
- }

# After: Full type safety
+ type Membership = 'bronze' | 'silver' | 'gold';
+
+ interface User {
+   id: string;
+   name: string;
+   membership: Membership;
+ }
+
+ interface DiscountResult {
+   original: number;
+   discount: number;
+   final: number;
+   rate: number;
+ }
+
+ function calculateDiscount(
+   user: User,
+   total: number,
+   date: Date = new Date()
+ ): DiscountResult {
+   if (total < 0) throw new Error('Total cannot be negative');
+
+   let rate = 0.1; // Default bronze
+
+   if (user.membership === 'gold' && date.getDay() === 5) {
+     rate = 0.25; // Friday bonus for gold
+   } else if (user.membership === 'gold') {
+     rate = 0.2;
+   } else if (user.membership === 'silver') {
+     rate = 0.15;
+   }
+
+   const discount = total * rate;
+
+   return {
+     original: total,
+     discount,
+     final: total - discount,
+     rate
+   };
+ }
```

---

## Design Patterns for Refactoring

### Strategy Pattern

```diff
# Before: Conditional logic
- function calculateShipping(order, method) {
-   if (method === 'standard') {
-     return order.total > 50 ? 0 : 5.99;
-   } else if (method === 'express') {
-     return order.total > 100 ? 9.99 : 14.99;
+   } else if (method === 'overnight') {
+     return 29.99;
+   }
+ }

# After: Strategy pattern
+ interface ShippingStrategy {
+   calculate(order: Order): number;
+ }
+
+ class StandardShipping implements ShippingStrategy {
+   calculate(order: Order) {
+     return order.total > 50 ? 0 : 5.99;
+   }
+ }
+
+ class ExpressShipping implements ShippingStrategy {
+   calculate(order: Order) {
+     return order.total > 100 ? 9.99 : 14.99;
+   }
+ }
+
+ class OvernightShipping implements ShippingStrategy {
+   calculate(order: Order) {
+     return 29.99;
+   }
+ }
+
+ function calculateShipping(order: Order, strategy: ShippingStrategy) {
+   return strategy.calculate(order);
+ }
```

### Chain of Responsibility

```diff
# Before: Nested validation
- function validate(user) {
-   const errors = [];
-   if (!user.email) errors.push('Email required');
+   else if (!isValidEmail(user.email)) errors.push('Invalid email');
+   if (!user.name) errors.push('Name required');
+   if (user.age < 18) errors.push('Must be 18+');
+   if (user.country === 'blocked') errors.push('Country not supported');
+   return errors;
+ }

# After: Chain of responsibility
+ abstract class Validator {
+   abstract validate(user: User): string | null;
+   setNext(validator: Validator): Validator {
+     this.next = validator;
+     return validator;
+   }
+   validate(user: User): string | null {
+     const error = this.doValidate(user);
+     if (error) return error;
+     return this.next?.validate(user) ?? null;
+   }
+ }
+
+ class EmailRequiredValidator extends Validator {
+   doValidate(user: User) {
+     return !user.email ? 'Email required' : null;
+   }
+ }
+
+ class EmailFormatValidator extends Validator {
+   doValidate(user: User) {
+     return user.email && !isValidEmail(user.email) ? 'Invalid email' : null;
+   }
+ }
+
+ // Build the chain
+ const validator = new EmailRequiredValidator()
+   .setNext(new EmailFormatValidator())
+   .setNext(new NameRequiredValidator())
+   .setNext(new AgeValidator())
+   .setNext(new CountryValidator());
```

---

## Refactoring Steps

### Safe Refactoring Process

```
1. PREPARE
   - Ensure tests exist (write them if missing)
   - Commit current state
   - Create feature branch

2. IDENTIFY
   - Find the code smell to address
   - Understand what the code does
   - Plan the refactoring

3. REFACTOR (small steps)
   - Make one small change
   - Run tests
   - Commit if tests pass
   - Repeat

4. VERIFY
   - All tests pass
   - Manual testing if needed
   - Performance unchanged or improved

5. CLEAN UP
   - Update comments
   - Update documentation
   - Final commit
```

---

## Refactoring Checklist

### Code Quality

- [ ] Functions are small (< 50 lines)
- [ ] Functions do one thing
- [ ] No duplicated code
- [ ] Descriptive names (variables, functions, classes)
- [ ] No magic numbers/strings
- [ ] Dead code removed

### Structure

- [ ] Related code is together
- [ ] Clear module boundaries
- [ ] Dependencies flow in one direction
- [ ] No circular dependencies

### Type Safety

- [ ] Types defined for all public APIs
- [ ] No `any` types without justification
- [ ] Nullable types explicitly marked

### Testing

- [ ] Refactored code is tested
- [ ] Tests cover edge cases
- [ ] All tests pass

---

## Common Refactoring Operations

| Operation                                     | Description                           |
| --------------------------------------------- | ------------------------------------- |
| Extract Method                                | Turn code fragment into method        |
| Extract Class                                 | Move behavior to new class            |
| Extract Interface                             | Create interface from implementation  |
| Inline Method                                 | Move method body back to caller       |
| Inline Class                                  | Move class behavior to caller         |
| Pull Up Method                                | Move method to superclass             |
| Push Down Method                              | Move method to subclass               |
| Rename Method/Variable                        | Improve clarity                       |
| Introduce Parameter Object                    | Group related parameters              |
| Replace Conditional with Polymorphism         | Use polymorphism instead of switch/if |
| Replace Magic Number with Constant            | Named constants                       |
| Decompose Conditional                         | Break complex conditions              |
| Consolidate Conditional                       | Combine duplicate conditions          |
| Replace Nested Conditional with Guard Clauses | Early returns                         |
| Introduce Null Object                         | Eliminate null checks                 |
| Replace Type Code with Class/Enum             | Strong typing                         |
| Replace Inheritance with Delegation           | Composition over inheritance          |
