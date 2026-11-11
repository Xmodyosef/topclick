# TOOLS INDEX

Quick reference for all tools in this repo. Search by keyword to find fast.

## 1) Local Scripts

| Script | Path | Purpose |
|---|---|---|
| check_keyboard_release.py | skills/ios-keyboard-release-gate/scripts/ | App Group / signing / version gate before release |
| a11y_static_audit.py | skills/iphone-keyboard-accessibility-qa/scripts/ | Finds buttons missing accessibilityLabel |
| verify_skill_links.py | skills/skill-routing-integrity/scripts/ | Checks skill index + link integrity |

## 2) CI Workflows

| Workflow | File | Triggers | Purpose |
|---|---|---|---|
| Build Fresh Unsigned IPA | .github/workflows/build-ipa.yml | push/PR to main, manual | validate + XCTest + build unsigned IPA |
| Agent Guard | .github/workflows/agent-guard.yml | PR to main | skills layout, pytest, scope guard, secrets, contracts |
| Security Review | .github/workflows/security-review.yml | push/PR | security scan |
| Remediation Baseline | .github/workflows/remediation-baseline.yml | manual/custom | remediation tracking |

## 3) External Skills (with scripts)

| Repo | Scripts | Focus |
|---|---|---|
| conorluddy/ios-simulator-skill | build_and_test.py, log_monitor, simctl_boot, simctl_erase, simctl_create, simctl_delete (27-30 Python scripts) | Simulator boot, hang watcher, erase, CI fix for XCTest hang |
| ioloro/iOS-Testing | iostesting CLI (Swift) + hook | Swift Testing, XCTest, XCUITest, performance, a11y testing |
| Abdo-codes/iOS-development-agent-skills | audit-localization.sh | apple-arabic-localization, RTL/LTR audit |
| Livsy90/iOS-Performance-Agent-Skills | audit scripts | launch time, memory, Instruments |
| rusel95/ios-agent-skills | 850+ assertions across 3 models | ios-testing, swift-concurrency |
| superagents-lab/xcode27-skills | official Xcode 27 | SwiftUI, Swift Testing, security |
| AvdLee/SwiftUI-Agent-Skill | analyze_trace.py | SwiftUI expert, 3.8k stars |
| artemnovichkov/xcode-skills | check.py, sync-xcode-skills | Xcode 27.3: touch gestures on Mac, Siri integration, Siri evaluation |

## 4) Kept Skills (4, executable only)

| Skill | Type |
|---|---|
| keyboard-extension | keyboard-specific scripts |
| ios-keyboard-release-gate | release gate script |
| skill-routing-integrity | index + link verification |
| iphone-keyboard-accessibility-qa | a11y audit script |

Pruned 7 heavy reference-only bundles (~14MB) down to these 4.

## 5) How to Add a New Tool

1. Add a row to the right table above.
2. Keep SKILL.md only if it has executable scripts — no reference-only bundles.
3. Run verify_skill_links.py to confirm index integrity.
4. One tool per PR; no Swift changes in the same PR.

## 6) GitHub Connected Tools (25 write tools)

| Action | Tool |
|---|---|
| Close PR | github___update_pull_request (state: closed) |
| Open PR | github___create_pull_request |
| Merge PR | github___merge_pull_request |
| Review PR | github___create_review |
| Update PR branch | github___update_pull_request_branch |
| Create/update file | github___create_or_update_file |
| Delete file | github___delete_file |
| Push multiple files | github___push_files |
| Create branch | github___create_branch |
| Search code | github___search_code |
| Search commits | github___search_commits |
| Search repos | github___search_repositories |
| Get file contents | github___get_file_contents |
| Get repo tree | github___get_repository_tree |
| Get commit | github___get_commit |
| Get me | github___get_me |
| Create repo | github___create_repository |

All other connected services (Gmail, Pipeworx, libgen, Hugging Face, Cloudflare, AWS, Microsoft Learn, Firecrawl, Exa, MetaMesh-UGA, AgentIndex, ToolRoute, Boar Blockchain, Context7, DeepWiki, Context, IndustryLens, Automations) are listed in project memory, not here.
