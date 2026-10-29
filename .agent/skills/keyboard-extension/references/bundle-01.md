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
