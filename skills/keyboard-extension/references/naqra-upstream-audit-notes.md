# Naqra audit methods — external skill review notes

Reviewed 2026-11-04. These are independent public references. No upstream skill file was copied wholesale; the checklists below were adapted to this repository's iOS 17 / Swift 5.9 keyboard-extension constraints.

## SwiftUI performance and memory

- [swift-ios-skills: swiftui-performance](https://github.com/dpearson2699/swift-ios-skills/blob/8d90fd121a263355a4fb44fd082af1416a5c1c2a/skills/swiftui-performance/SKILL.md)
- [claude-code-apple-skills: performance profiling](https://github.com/rshankras/claude-code-apple-skills/blob/main/skills/performance/profiling/SKILL.md)

Adopted practices:
- Treat code inspection as a hypothesis, not proof of a performance defect.
- Establish a reproducible Release-build baseline and compare the same scenario before/after.
- Use SwiftUI Instruments lanes together with Time Profiler and Hangs/Hitches.
- Inspect identity churn, broad observation dependencies, synchronous decode/I/O, and memory lifetime before refactoring.
- Keep physical-device keyboard-extension profiling separate from simulator correctness checks. Do not invent a universal memory budget or latency target.

## RTL and localization

- [swift-ios-skills: ios-localization](https://github.com/dpearson2699/swift-ios-skills/blob/8d90fd121a263355a4fb44fd082af1416a5c1c2a/skills/ios-localization/SKILL.md)
- [claude-skills: i18n-localization](https://github.com/alirezarezvani/claude-skills/blob/main/engineering/i18n-localization/skills/i18n-localization/SKILL.md)
- [zeroes-ones: localization-engineer](https://github.com/zeroes-ones/Skills/blob/16b1447d820081e3ba7c5a019d2c7c6752298467/skills/05-development/localization-engineer/SKILL.md)

Adopted practices:
- Test Arabic-only, English-only, and mixed-script strings independently.
- Include digits, punctuation, brackets, URLs, email addresses, emoji, and cursor/deletion operations.
- Assert behavior and caret semantics, not only screenshots.
- Do not force a global layout direction to solve a local component issue.
- If localized string catalogs are introduced later, add locale-aware plural/placeholder validation and a pseudo-locale/bidi visual pass; the current keyboard does not gain a localization pipeline merely by adding these tests.

## Clipboard privacy and architecture contracts

- [claude-code-apple-skills: fitness-functions](https://github.com/rshankras/claude-code-apple-skills/blob/main/skills/testing/fitness-functions/SKILL.md)
- [swift-ios-skills: swift-testing](https://github.com/dpearson2699/swift-ios-skills/blob/8d90fd121a263355a4fb44fd082af1416a5c1c2a/skills/swift-testing/SKILL.md)

Adopted practices:
- Convert hard rules into deterministic tests that run in the normal test gate.
- Pin exact privacy defaults, bounded storage, supported schema versions, and data-retention invariants.
- Test both successful and malformed/oversized inputs; test failure recovery rather than only happy-path round trips.
- Keep tests isolated and avoid relying on test execution order.
- Clipboard tests use synthetic non-sensitive strings only.

## Scope and applicability

The upstream repositories contain many unrelated workflows (App Store marketing, backend profiling, web localization, and other platform-specific material). Those were not imported into Naqra. Only practices directly applicable to SwiftUI, iOS localization/RTL, test architecture, and clipboard data integrity were adapted. Review the pinned source revisions before relying on upstream details after future toolchain changes.
