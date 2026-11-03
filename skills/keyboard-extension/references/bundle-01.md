# Integrated Reference Bundle 01

Combines 2 related source skills from `keyboard-extension` into one navigable reference file.

## Source map

- `copy-html-clipboard/SKILL.reference.md`
- `ios-keyboard-limitations/SKILL.reference.md`

## Integrated guidance

### Source: `copy-html-clipboard`

# Copy HTML to Clipboard

## When to use

Use when the user wants to paste rich content (lists with links, headings, bold) into Gmail or another rich-text editor, and wants the destination's default styling. Not Times New Roman, not embedded fonts.

Do **not** use `pbcopy` alone (plain text only, links won't render) or `textutil ... -convert rtf | pbcopy` (works but embeds a font that overrides the destination's default).

## How

Run the bundled script. It accepts a file path or HTML on stdin.

```bash
# From a file
scripts/copy_html.sh /path/to/file.html

# From stdin (preferred for ad-hoc lists)
cat <<'EOF' | scripts/copy_html.sh
<ul>
  <li><a href="https://example.com/1">First item</a></li>
  <li><a href="https://example.com/2">Second item</a></li>
</ul>
EOF
```

The script strips em-dashes (U+2014) from the input, hex-encodes the bytes, and runs `osascript -e 'set the clipboard to «data HTML...»'`, which writes the `public.html` clipboard flavor directly. Gmail and friends use their own font when pasting.

### Em-dash stripping

Em-dashes are a tell for AI-generated text, so the script removes them:

- " — " (em-dash with surrounding spaces) becomes " - "
- "—" (bare em-dash) becomes "-"

En-dashes (U+2013) are left alone since they have legitimate uses like number ranges and compound names ("UK–Australia").

If you want a different substitution (period + new sentence, comma, etc.), do it in the input HTML before piping to the script.

## Authoring tips for clean Gmail paste

- Omit `<html>`, `<head>`, `<body>`, `<style>`, and inline `style=` attributes. Anything you set will override Gmail's defaults.
- Use semantic tags: `<ul>/<ol>/<li>`, `<a href>`, `<b>`, `<i>`, `<h2>`, `<p>`. Gmail styles them with its own font and spacing.
- For an issue/PR list, embed the link on the title:
  `<li><a href="URL">#123 Title here</a></li>`
- Avoid em-dashes in source HTML. The script strips them, but writing without them keeps phrasing natural (periods or commas usually read better than auto-substituted " - ").

## Verifying

To confirm the HTML flavor landed on the clipboard:

```bash
osascript -e 'the clipboard as «class HTML»' | head -c 200
```

Output starts with `«data HTML...»` followed by hex bytes.

### Source: `ios-keyboard-limitations`

iOS Keyboard Limits: Microphone DISALLOWED. Opening other apps BLOCKED. Memory limit 30-60MB (silent crash if exceeded). Persistence only via App Groups. Network requires 'Full Access' enabled by user.

## Naqra specialist workflow: Keyboard Runtime Performance & Memory Auditor

### Trigger

Use this audit when changing keyboard rendering, input handling, JSON/resource loading, emoji panels, sound, clipboard history, App Group access, or any long-lived keyboard state.

### Audit sequence

1. Record device model, iOS version, keyboard configuration, enabled features, and a reproducible interaction sequence.
2. Establish a baseline on a physical iPhone for cold keyboard presentation, first key response, repeated key presses, language switching, emoji-panel open/close, and long-session behavior.
3. Profile allocations, resident memory, CPU, and main-thread work with Instruments or equivalent Xcode diagnostics. Separate container-app measurements from the keyboard extension process.
4. Look for retained view/controller graphs, duplicated decoded JSON, unbounded caches, repeated file reads, synchronous disk work on input callbacks, and expensive SwiftUI body recomputation.
5. Repeat the same sequence after the change. Compare distributions and memory growth rather than relying on one timing sample.
6. Verify that memory returns to a stable plateau after dismissing panels and switching away from the keyboard; record any persistent growth and the object/resource responsible.

### Acceptance and constraints

- Treat the keyboard extension's constrained memory budget as a hard design constraint; do not assume the container app's memory headroom is available to the extension.
- Keep key-down and text insertion paths short and free of avoidable disk, network, decoding, or blocking work.
- Load immutable catalogs once where safe, avoid duplicate decoded copies, and bound all caches.
- Never add microphone capture or assume the extension can launch another app. Network access requires the user's explicit Full Access setting.
- Do not invent universal latency or memory thresholds. Record device-specific baseline, p50/p95 where measurable, peak memory, and observed memory plateau.
- A simulator build is useful for correctness but does not replace a physical-device memory and latency check.

### Report

Include device/iOS, build SHA, exact scenario, baseline and post-change measurements, profiler evidence, regressions, and checks that remain unverified.
 
## Naqra specialist workflow: Clipboard Privacy & Data Integrity Auditor

### Trigger

Use when changing clipboard history, clipboard persistence, migration, App Group storage, clear-history behavior, retention, or clipboard-related diagnostics.

### Audit sequence

1. Map every read/write path and identify whether data lives in the App Group suite, standard defaults, files, logs, backups, or caches.
2. Verify clipboard history is opt-in and defaults to disabled. Confirm disabled state does not read, retain, or expose stored history.
3. Verify a versioned Codable/JSON format, strict schema/version checks, maximum item count, per-item character limit, and aggregate character limit.
4. For legacy migration, preserve the original bytes before replacement, write the new representation, read it back, validate it, and compare the decoded items before marking migration successful.
5. Keep the backup for the documented seven-day period after verified migration. Delete it only after the deadline and a fresh successful validation of the new JSON; record migration-success and backup-deletion timestamps.
6. Test malformed JSON, unsupported versions, empty input, oversized entries, aggregate overflow, duplicate items, Unicode, and U+001F within an item. Explain that legacy delimiter data containing an actual U+001F inside an item is inherently ambiguous and cannot be reconstructed reliably.
7. Confirm clear-history and retention behavior against the owner's explicit policy. Do not silently change backup retention or restore deleted history.
8. Inspect logs, crash reports, analytics, and test fixtures to ensure clipboard contents are never emitted.

### Acceptance

- No clipboard content in logs or telemetry.
- No unbounded persistence or migration path.
- No destructive overwrite before verified replacement.
- Backup retention and deletion are deterministic and auditable.
- App Group and standard-defaults fallback behavior is explicitly tested.
- Tests use harmless synthetic strings, never real passwords or personal messages.

### Report

List storage keys/locations, migration states, size limits, retention semantics, tests and outcomes, and any unrecoverable legacy-data ambiguity.


## External review notes

See [Naqra upstream audit notes](naqra-upstream-audit-notes.md) for pinned public references and the practices adapted from them.