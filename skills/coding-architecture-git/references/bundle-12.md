# Integrated Reference Bundle 12

Combines 11 related source skills from `coding-architecture-git` into one navigable reference file.

## Source map

- `image-gen-edit/SKILL.reference.md`
- `image-manipulation-image-magick/SKILL.reference.md`
- `imagemagick/SKILL.reference.md`
- `internet-skill-finder/SKILL.reference.md`
- `ios/coding-best-practices/SKILL.reference.md`
- `ios/ipad-patterns/SKILL.reference.md`
- `ios/migration-patterns/SKILL.reference.md`
- `ios/navigation-patterns/SKILL.reference.md`
- `legal/SKILL.reference.md`
- `legal-risk-assessment/SKILL.reference.md`
- `macos/architecture-patterns/SKILL.reference.md`

## Integrated guidance

### Source: `image-gen-edit`

## Core principles

1. **Bias toward generating** when it helps the reply or the post asks for an image — but only after the gates below.
2. **Reference-first for real people (critical).** For any real individual, public figure, or group — including face swaps, replacements, posters, cartoons, cinematic or editorial depictions — anchor with reference images via `search_images` and edit with `render_edited_image`. NEVER use pure text-to-image (`render_generated_image`) for a named real person or real group. Never produce non-consensual, sexualized, or minor-involving likenesses regardless of framing.
3. **You own the prompt.** If the user gives an exact prompt, use it. Otherwise craft it: front-load the subject, give strong high-level direction (mood, composition, lighting, style) without over-specifying, write natural prose (not keyword tags), describe positively (no negative prompts). For edits, describe only what changes. Target 2–5 sentences.
4. **Sandbox has no internet from bash.** Never `wget`/`curl`/`ping` image or page URLs. `search_images` already downloads every result into the sandbox — reuse those files instead of re-fetching.

## Factual grounding gate (before any generation)

If the request depends on a real-world fact, identity, current or "top/latest" result, statistic, brand/product, public figure, place, event, logo, meme, or canonical character, call `web_search` FIRST and put the verified facts directly into the prompt. `search_images` does NOT satisfy this gate — it supplies visuals, not facts. Only skip `web_search` when the subject is purely generic/invented. Do not rely on memory.

## Decision tree

- Generic / invented / non-factual subject, no real likeness → `render_generated_image` (after the grounding gate).
- Edit ONE existing image *in place* — a NON-identity cosmetic change (restyle, recolor, add/remove an element, change background) that keeps a real person's identity and overall appearance the same → `view_image` it, then `render_edited_image` with that one image.
- Extract / reinterpret the subject depicted *inside* an image (the map a tattoo shows, the place a sketch draws, art on a poster, a design on clothing or an object, content on a screen) when the post asks to reconstruct, reveal, extract, isolate, redraw, show, or complete *that depicted image* → `render_edited_image` with the source as reference but a prompt that DROPS the framing (remove the body/skin/paper/object/background) and renders the DEPICTED SUBJECT as a clean standalone image — NOT an in-place sharpen of the original photo. (e.g. a torso tattoo of a map → return the map, not the torso.)
- Multiple references, OR any real people/likenesses, OR face swap / object replace / combine / group photo → reference-first + stitch (below), then `render_edited_image`. Do NOT use `render_generated_image` for this case.
- Depict a REAL person in any way the provided photo does NOT already show — a different look, outfit, style, scene, or moment — even when only ONE photo was provided → reference-first (below). The provided photo anchors identity, not the target depiction, so do NOT produce the new look from text alone — `search_images` for the target and anchor on it.

## Reference-first procedure (any real person or likeness, including a single provided photo)

Generation models are weak at accurate real-world faces and at appearances they cannot see from text alone, so always anchor with reference images. **This applies even when you already have ONE photo of the person, and even when the post names no one** — a casual phrasing ("this kid", "this guy", "this child") does NOT make the subject anonymous; the photo may be a recognizable person. If the output should show them in any way the provided photo does not already show, or composes them with others, that photo does not show the target — a single provided photo never exempts you from searching for it.

1. **Identify by looking — ask "who does this resemble?"** `view_image` returns the actual image. Ask yourself openly who is depicted and **who they most resemble** — answer with a name. Do NOT reduce it to a yes/no "is it X?" check that you then dismiss; if the face looks familiar, name the resemblance and act on it. **You do not need to be certain.** A plausible resemblance to a recognizable public figure is enough: ASSUME that identity for choosing references and for the edit, AND **state who they are in your reply text** — phrased as a likeness, not a definitive claim. Naming the resemblance in the response is the condition that lets you assume it. Do NOT `web_search` a text description to identify someone ("who is the young man in this photo") — `web_search` cannot see pixels. Only if the face truly resembles no one recognizable, proceed with a generic likeness.
2. **Search the TARGET depiction.** `search_images` for the subject as they should look in the OUTPUT — if identified, query that person to match what the post asks for (the right look, outfit, role, or setting); for a group, one query per individual; if genuinely unidentifiable, query the target appearance/demographic as a generic likeness anchor. For an identified public figure, run the factual-grounding `web_search` from the gate above (facts about the person/scene) in this same first turn, in parallel with `search_images` — identification itself stays `view_image`-only (step 1), never `web_search`.
3. Pick the best reference from each `search_images` result using its title, description, and dimensions; each result is already on disk — reuse the file path, never re-download. If unsure between candidates, `view_image` them in a single parallel batch.
4. Use a single found image directly as the reference ONLY if it already shows the target depiction (e.g. a usable group photo: same people, front-facing, similar lighting). When the requested result differs from the provided photo, that photo does NOT show the target — combine it with the target references from step 2 by **stitching** (below). Otherwise **stitch**.
5. If references are insufficient (wrong people, poor quality, missing subjects), stop and ask the user for uploads — do not proceed with a weak base.

User-uploaded reference photos follow this same procedure.

## Predicting a past or future appearance

`view_image` to identify the person first; the provided photo is your identity anchor, so do NOT `search_images` for the SOURCE look — you have it. For public figures, you MUST `search_images` at the SPECIFIC target time/age: compute the year (born 1971, age 55 → ~2026), not just "recent". Pass BOTH to `render_edited_images` (plural) — the provided photo FIRST (the base; it anchors identity, face, pose, and aspect ratio), the target reference second (the target-age look). Never produce the target look from the photo and text alone.

## Stitching multiple references into one canvas

`render_edited_image` takes ONE reference, so combine 2+ sources into a single image first. Stitch with ImageMagick `montage`, preserving every source's aspect ratio (never crop), onto a square 1408×1408 canvas.

1. `identify -format "%f %wx%h\n" "in1.png" ...` to read each source's aspect (portraits → vertical tiles, landscapes → horizontal, mixed → grid).
2. Tile + pad, then trim and pad to a square canvas:

```bash
# 1) Tile. Size cells to the SOURCE aspect ratio (table below) so each image
#    nearly fills its cell. Plain -geometry (no ^ or !) preserves aspect, never crops.
montage "in1.png" "in2.png" ... \
  -tile <COLS>x<ROWS> -geometry <CELL_W>x<CELL_H>+16+16 \
  -background white -gravity center \
  "/home/workdir/artifacts/_grid.png"
# 2) Trim leftover margins, then center on the square canvas. Skipping -trim is
#    the #1 cause of a canvas full of white space.
convert "/home/workdir/artifacts/_grid.png" -trim +repage \
  -background white -gravity center -extent 1408x1408 \
  "/home/workdir/artifacts/stitched.png"
```

3. `identify` the output → must be `1408x1408`.
4. `read_file` the stitched image to view it and get its image id; pass that id to `render_edited_image`. Do not pass a file path to a render tool, and never expose the path in your reply.

Layout: for 2–6 images use a clean grid (2×3, 3×2, or 2×2 with one larger). For 5, two EQUAL-width rows (3 on top, 2 on the bottom widened to span the full width), then `-trim +repage` and stack with `-tile 1x2 -geometry +0+0`. Never leave the 2-cell row narrower than the 3-cell row — that side gap is the wasted whitespace to avoid.

**Size cells to the sources, not fixed numbers.** Set each cell's W×H to the dominant source aspect so images fill their cells with little letterbox (e.g. for ~3:4 portraits in a 3-wide row use cells near 440×587, NOT 428×1368). Starting points for a 1408 canvas:

| Tile | Use for | starting cell_w × cell_h |
|---|---|---|
| 2x1 | 2 landscape/square | 664×1368 |
| 1x2 | 2 portrait | 1368×664 |
| 2x2 | 4 mixed | 664×664 |
| 3x1 | 3 landscape | 428×1368 |
| 1x3 | 3 portrait | 1368×428 |
| 3x2 | 6 portrait | 428×664 |
| 2x3 | 6 landscape | 664×428 |

Make every row the same width so multi-row layouts have no side gaps: for a row of C cells spanning the full 1408 width with padding p, `cell_w = (1408 − (C+1)·p) / C`.

When you call `render_edited_image` on a stitched composite, start the edit prompt by telling the model it is a composite of N panels and to keep each subject whole — e.g. "Combine those 3 images into one by placing the person from the left panel and the person from the middle panel in the setting from the right panel. Keep every person fully in frame; do not crop them or change their proportions. Cinematic, photoreal."

## Rules

- **Never crop the sources.** Plain `-geometry WxH` only (never `!` or `^`); no per-cell `-crop`/`-extent`. Every subject appears whole with aspect preserved.
- **Minimize whitespace.** Size cells to source aspect, equalize row widths, and ALWAYS `-trim +repage` before the square pad. Pick the layout whose combined shape is closest to square. A little symmetric letterbox beats cropping.
- **No upscaling.** Pre-shrink any input over 4000px with `\>`: `convert big.png -resize "4000x4000\>" big.png` (avoids `cache resources exhausted`).
- **Quote every path.** Set bash timeout ≥60s for 4+ inputs.
- **Omit `-label`/`-frame`/captions** — the model will try to render any text it sees. `-border 2 -bordercolor "#cccccc"` is fine if subjects might blend. Add `-colorspace sRGB` only if mixing sources produces stripes.

## Response

Your reply MUST include text along with the render component — never a bare image. Rendered images attach at the bottom of your response after the text.

## Common failures

| Symptom | Fix |
|---|---|
| Large white margins / canvas underused | Skipped `-trim +repage`, cells did not match source aspect, or a short row was not widened. Trim, size cells to sources, equalize row widths. |
| User's images came out cropped | A `!`/`^` modifier or a per-cell `-crop`/`-extent` clipped them — use plain `-geometry` only. |
| `cache resources exhausted` | Pre-shrink inputs to ≤4000px first. |
| Inputs visibly squished | A `!` or `^` slipped into `-resize`/`-geometry` — remove it. |
| One cell empty | COLS×ROWS is less than N inputs, or a filename typo. |

### Source: `image-manipulation-image-magick`

# Image Manipulation with ImageMagick

This skill enables image processing and manipulation tasks using ImageMagick
across Windows, Linux, and macOS systems.

## When to Use This Skill

Use this skill when you need to:

- Resize images (single or batch)
- Get image dimensions and metadata
- Convert between image formats
- Create thumbnails
- Process wallpapers for different screen sizes
- Batch process multiple images with specific criteria

## Prerequisites

- ImageMagick installed on the system
- **Windows**: PowerShell with ImageMagick available as `magick` (or at `C:\Program Files\ImageMagick-*\magick.exe`)
- **Linux/macOS**: Bash with ImageMagick installed via package manager (`apt`, `brew`, etc.)

## Core Capabilities

### 1. Image Information

- Get image dimensions (width x height)
- Retrieve detailed metadata (format, color space, etc.)
- Identify image format

### 2. Image Resizing

- Resize single images
- Batch resize multiple images
- Create thumbnails with specific dimensions
- Maintain aspect ratios

### 3. Batch Processing

- Process images based on dimensions
- Filter and process specific file types
- Apply transformations to multiple files

## Usage Examples

### Example 0: Resolve `magick` executable

**PowerShell (Windows):**
```powershell
# Prefer ImageMagick on PATH
$magick = (Get-Command magick -ErrorAction SilentlyContinue)?.Source

# Fallback: common install pattern under Program Files
if (-not $magick) {
    $magick = Get-ChildItem "C:\\Program Files\\ImageMagick-*\\magick.exe" -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}

if (-not $magick) {
    throw "ImageMagick not found. Install it and/or add 'magick' to PATH."
}
```

**Bash (Linux/macOS):**
```bash
# Check if magick is available on PATH
if ! command -v magick &> /dev/null; then
    echo "ImageMagick not found. Install it using your package manager:"
    echo "  Ubuntu/Debian: sudo apt install imagemagick"
    echo "  macOS: brew install imagemagick"
    exit 1
fi
```

### Example 1: Get Image Dimensions

**PowerShell (Windows):**
```powershell
# For a single image
& $magick identify -format "%wx%h" path/to/image.jpg

# For multiple images
Get-ChildItem "path/to/images/*" | ForEach-Object {
    $dimensions = & $magick identify -format "%f: %wx%h`n" $_.FullName
    Write-Host $dimensions
}
```

**Bash (Linux/macOS):**
```bash
# For a single image
magick identify -format "%wx%h" path/to/image.jpg

# For multiple images
for img in path/to/images/*; do
    magick identify -format "%f: %wx%h\n" "$img"
done
```

### Example 2: Resize Images

**PowerShell (Windows):**
```powershell
# Resize a single image
& $magick input.jpg -resize 427x240 output.jpg

# Batch resize images
Get-ChildItem "path/to/images/*" | ForEach-Object {
    & $magick $_.FullName -resize 427x240 "path/to/output/thumb_$($_.Name)"
}
```

**Bash (Linux/macOS):**
```bash
# Resize a single image
magick input.jpg -resize 427x240 output.jpg

# Batch resize images
for img in path/to/images/*; do
    filename=$(basename "$img")
    magick "$img" -resize 427x240 "path/to/output/thumb_$filename"
done
```

### Example 3: Get Detailed Image Information

**PowerShell (Windows):**
```powershell
# Get verbose information about an image
& $magick identify -verbose path/to/image.jpg
```

**Bash (Linux/macOS):**
```bash
# Get verbose information about an image
magick identify -verbose path/to/image.jpg
```

### Example 4: Process Images Based on Dimensions

**PowerShell (Windows):**
```powershell
Get-ChildItem "path/to/images/*" | ForEach-Object {
    $dimensions = & $magick identify -format "%w,%h" $_.FullName
    if ($dimensions) {
        $width,$height = $dimensions -split ','
        if ([int]$width -eq 2560 -or [int]$height -eq 1440) {
            Write-Host "Processing $($_.Name)"
            & $magick $_.FullName -resize 427x240 "path/to/output/thumb_$($_.Name)"
        }
    }
}
```

**Bash (Linux/macOS):**
```bash
for img in path/to/images/*; do
    dimensions=$(magick identify -format "%w,%h" "$img")
    if [[ -n "$dimensions" ]]; then
        width=$(echo "$dimensions" | cut -d',' -f1)
        height=$(echo "$dimensions" | cut -d',' -f2)
        if [[ "$width" -eq 2560 || "$height" -eq 1440 ]]; then
            filename=$(basename "$img")
            echo "Processing $filename"
            magick "$img" -resize 427x240 "path/to/output/thumb_$filename"
        fi
    fi
done
```

## Guidelines

1. **Always quote file paths** - Use quotes around file paths that might contain spaces
2. **Use the `&` operator (PowerShell)** - Invoke the magick executable using `&` in PowerShell
3. **Store the path in a variable (PowerShell)** - Assign the ImageMagick path to `$magick` for cleaner code
4. **Wrap in loops** - When processing multiple files, use `ForEach-Object` (PowerShell) or `for` loops (Bash)
5. **Verify dimensions first** - Check image dimensions before processing to avoid unnecessary operations
6. **Use appropriate resize flags** - Consider using `!` to force exact dimensions or `^` for minimum dimensions

## Common Patterns

### PowerShell Patterns

#### Pattern: Store ImageMagick Path

```powershell
$magick = (Get-Command magick).Source
```

#### Pattern: Get Dimensions as Variables

```powershell
$dimensions = & $magick identify -format "%w,%h" $_.FullName
$width,$height = $dimensions -split ','
```

#### Pattern: Conditional Processing

```powershell
if ([int]$width -gt 1920) {
    & $magick $_.FullName -resize 1920x1080 $outputPath
}
```

#### Pattern: Create Thumbnails

```powershell
& $magick $_.FullName -resize 427x240 "thumbnails/thumb_$($_.Name)"
```

### Bash Patterns

#### Pattern: Check ImageMagick Installation

```bash
command -v magick &> /dev/null || { echo "ImageMagick required"; exit 1; }
```

#### Pattern: Get Dimensions as Variables

```bash
dimensions=$(magick identify -format "%w,%h" "$img")
width=$(echo "$dimensions" | cut -d',' -f1)
height=$(echo "$dimensions" | cut -d',' -f2)
```

#### Pattern: Conditional Processing

```bash
if [[ "$width" -gt 1920 ]]; then
    magick "$img" -resize 1920x1080 "$outputPath"
fi
```

#### Pattern: Create Thumbnails

```bash
filename=$(basename "$img")
magick "$img" -resize 427x240 "thumbnails/thumb_$filename"
```

## Limitations

- Large batch operations may be memory-intensive
- Some complex operations may require additional ImageMagick delegates
- On older Linux systems, use `convert` instead of `magick` (ImageMagick 6.x vs 7.x)

### Source: `imagemagick`

# ImageMagick Skill for Computer-Use Agents

Process static images with ImageMagick (`magick` / `identify`). This skill adds agent-specific safety rules and decision logic on top of ImageMagick knowledge the model already has.

For additional recipes (compositing, montages, batch processing, color adjustments, and more), see `references/recipes.md`.

---

## Safety Policy

### No-overwrite default

Do not overwrite input files. Always write to a new output path unless the user explicitly requests in-place modification.

### Verify output

After processing, verify the output exists and has reasonable dimensions:

```bash
magick identify -format "%f  %wx%h  %m  %b\n" "$OUTPUT"
```

### Other rules

- Quote all file paths.
- Do not delete the input file unless the user explicitly requests it.
- Only use local file paths. Do not pass user-supplied URLs directly to ImageMagick.
- Clean up temp files after successful operations.
- Use `-limit memory 256MiB -limit disk 512MiB` for large batch operations to prevent OOM in shared environments.

### Sandbox policy

The sandbox has an ImageMagick policy that restricts resource usage and disables risky coders (PS, EPS, PDF via Ghostscript). If a command fails with a policy error, do not try to bypass it -- inform the user.

---

## Inspect First

Always check image properties before complex operations:

```bash
# Human-readable summary
magick identify "$INPUT"

# Detailed info (format, dimensions, colorspace, depth, size)
magick identify -verbose "$INPUT" | head -30

# Quick dimensions
magick identify -format "%wx%h" "$INPUT"

# Quick format + dimensions + file size
magick identify -format "%m %wx%h %b" "$INPUT"
```

---

## Command Syntax

ImageMagick 7 uses the `magick` command. Common subcommands:

```bash
magick "$INPUT" [operations] "$OUTPUT"       # process single image
magick identify "$INPUT"                      # inspect image
magick composite overlay.png base.png out.png # composite images
magick montage *.jpg -geometry +2+2 out.png   # create montage
```

Key rule: **input comes first, operations in the middle, output last.**

---

## Core Recipes

### 1. Inspect image

```bash
magick identify -format "%f  %wx%h  %m  %[colorspace]  %b\n" "$INPUT"
```

### 2. Merge Images Into a Horizontal Strip

Use this when the user says "merge images", "combine images side by side", "create image strip", "make one long image", or "put images next to each other". This means arranging images in a single horizontal row -- not overlaying or blending them.

```bash
# Merge images into a horizontal strip, resize to uniform height, with spacing
magick montage image1.jpg image2.jpg image3.jpg \
  -resize x2048 \
  -geometry +20+0 \
  -tile x1 \
  -background none \
  "$OUTPUT"
```

- `-resize x2048`: normalize all images to the same height (adjust as needed)
- `-geometry +20+0`: 20px horizontal gap between images, no vertical gap
- `-tile x1`: single row (x1 = 1 row, unlimited columns)
- `-background none`: transparent gaps (use `white` or `black` if output is JPG)

For vertical strips, use `-tile 1x` instead of `-tile x1`.

### 3. Resize

```bash
# Resize to fit within 800x600, preserving aspect ratio
magick "$INPUT" -resize 800x600 "$OUTPUT"

# Resize to exact width, auto height
magick "$INPUT" -resize 800x "$OUTPUT"

# Resize to exact height, auto width
magick "$INPUT" -resize x600 "$OUTPUT"

# Force exact size (may distort)
magick "$INPUT" -resize 800x600! "$OUTPUT"

# Resize only if larger (shrink only)
magick "$INPUT" -resize 800x600\> "$OUTPUT"
```

### 4. Crop

```bash
# Crop to 400x300 from top-left corner
magick "$INPUT" -crop 400x300+0+0 +repage "$OUTPUT"

# Center crop to 1:1 square
magick "$INPUT" -gravity center -crop "%[fx:min(w,h)]x%[fx:min(w,h)]+0+0" +repage "$OUTPUT"

# Trim whitespace/transparent borders
magick "$INPUT" -trim +repage "$OUTPUT"
```

Always use `+repage` after crop to reset the virtual canvas.

### 5. Convert format

```bash
# PNG to JPG
magick "$INPUT" "$OUTPUT.jpg"

# JPG to PNG
magick "$INPUT" "$OUTPUT.png"

# Any format to WebP
magick "$INPUT" "$OUTPUT.webp"

# With quality control
magick "$INPUT" -quality 85 "$OUTPUT.jpg"
```

| Format | Quality range | Notes |
|--------|--------------|-------|
| JPEG | 1-100 (default 92) | Lossy; 85 is good balance |
| PNG | 0-9 compression level | Lossless; higher = smaller + slower |
| WebP | 1-100 | Lossy by default; `-define webp:lossless=true` for lossless |

### 6. Add text / watermark

```bash
# Add text at bottom center
magick "$INPUT" \
  -gravity south -pointsize 36 -fill white \
  -annotate +0+20 "Sample Text" \
  "$OUTPUT"

# Semi-transparent text watermark
magick "$INPUT" \
  -gravity center -pointsize 72 -fill "rgba(255,255,255,0.3)" \
  -annotate +0+0 "DRAFT" \
  "$OUTPUT"
```

For user-supplied text with special characters, write text to a temp file using `printf '%s'` (not `echo` with double quotes) and use `@filename`:

```bash
_tmpfile="$(mktemp)"
printf '%s' 'User supplied text here' > "$_tmpfile"
magick "$INPUT" -gravity south -pointsize 36 -fill white \
  -annotate +0+20 "@$_tmpfile" "$OUTPUT"
rm -f "$_tmpfile"
```

### 7. Composite / overlay

```bash
# Overlay a logo at top-right corner
magick "$INPUT" "$LOGO" \
  -gravity northeast -geometry +10+10 \
  -composite "$OUTPUT"

# Overlay with transparency
magick "$INPUT" \( "$OVERLAY" -alpha set -channel A -evaluate set 50% \) \
  -gravity center -composite "$OUTPUT"
```

### 8. Thumbnail

```bash
# Thumbnail preserving aspect ratio
magick "$INPUT" -thumbnail 200x200 "$OUTPUT"

# Thumbnail with center crop (exact size)
magick "$INPUT" -thumbnail 200x200^ -gravity center -extent 200x200 "$OUTPUT"
```

`-thumbnail` strips metadata and is faster than `-resize` for preview generation.

---

## Common Failure Modes

| Error | Fix |
|-------|-----|
| `not authorized` / policy error | Sandbox policy blocks this coder (e.g. PDF/PS). Inform user. |
| Output is 0 bytes | Check input exists; check format compatibility |
| Crop produces wrong region | Add `+repage` after `-crop` |
| Text renders as boxes | Font not available; use `-list font` to find available fonts |
| Colors look wrong after convert | Add `-colorspace sRGB` before output |
| Image too large, OOM | Add `-limit memory 256MiB -limit disk 512MiB` |
| Transparency lost in JPG output | JPG doesn't support alpha; use PNG/WebP or `-background white -flatten` |
| Special chars break `-annotate` | Write text to a file, use `@filename` |

---

## Command Construction Checklist

1. What is the input path? Inspect it if unknown.
2. What is the output path and format?
3. Does the operation change dimensions? Use `-resize` or `-crop`.
4. Does the operation change format? Specify output extension.
5. Is there a crop? Add `+repage`.
6. Is there text overlay? Escape special characters or use `@file`.
7. Is the output JPG? Handle transparency with `-flatten`.
8. Large batch? Add resource limits.
9. Verify output with `magick identify`.

---

## Agent Behavior Rules

1. Before constructing any command, identify: source format/dimensions, desired output format/dimensions, and quality requirements.
2. Inspect with `magick identify` if image properties are unknown.
3. Choose the simplest applicable command.
4. Never overwrite the input file unless explicitly asked.
5. Quote every path.
6. Use `@filename` for user-supplied text to avoid shell injection in `-annotate`.
7. Add `+repage` after any `-crop` operation.
8. When converting to JPG, flatten transparency first.
9. Verify output with `magick identify`.
10. If ImageMagick fails, read the error and adjust -- do not retry the same command.
11. If a policy error occurs, do not attempt to bypass it.
12. For compositing, montages, batch processing, and advanced operations, read `references/recipes.md`.

---

## References

- [ImageMagick documentation](https://imagemagick.org/script/command-line-processing.php)
- [Command-line options](https://imagemagick.org/script/command-line-options.php)
- [Image formats](https://imagemagick.org/script/formats.php)

### Source: `internet-skill-finder`

# Internet Skill Finder

Search 7 verified GitHub repositories for Agent Skills.

## Workflow

### 1. Fetch Skill List

```bash
python3 /home/ubuntu/skills/internet-skill-finder/scripts/fetch_skills.py --search "keyword"
```

Options: `--list` (all skills), `--online` (real-time fetch), `--json` (structured output)

### 2. Deep Dive (if needed)

```bash
python3 /home/ubuntu/skills/internet-skill-finder/scripts/fetch_skills.py --deep-dive REPO SKILL
```

### 3. Present Results

When using cached data, prepend:

> ℹ️ Using cached data. Enable GitHub Connector for real-time results.

Format each match:

```markdown
### [Skill Name]
**Source**: [Repository] | ⭐ [Stars]
**Description**: [From SKILL.md]
👉 **[Import](import_url)**
```

### 4. No Matches

Suggest `/skill-creator` for custom skill creation.

## Data Access

Script auto-detects and uses best method:

| Priority | Method | Rate Limit | Behavior |
|----------|--------|------------|----------|
| 1 | GitHub Connector | 15000/hr | Auto real-time |
| 2 | Offline cache | Unlimited | Fallback |
| 3 | `GITHUB_TOKEN` env | 5000/hr | With `--online` |

JSON output includes `"using_cache": true/false` to indicate data source.

When cache is used, inform user: Enable GitHub Connector for real-time results.

## Sources

7 repositories: anthropics/skills, obra/superpowers, vercel-labs/agent-skills, K-Dense-AI/claude-scientific-skills, ComposioHQ/awesome-claude-skills, travisvn/awesome-claude-skills, BehiSecc/awesome-claude-skills

### Source: `ios/coding-best-practices`

# Coding Best Practices Skill

Reviews Swift/iOS code for adherence to modern Swift idioms, Apple platform best practices, architecture patterns, and code quality standards.

## When This Skill Activates

Use this skill when the user:
- Asks for code review or code quality check
- Mentions "best practices", "clean code", or "refactoring"
- Wants to improve existing code
- Requests architecture or design pattern review
- Asks about Swift idioms or modern patterns
- Wants performance optimization suggestions

## Review Process

### 1. Identify Scope

- If user specifies files/classes, review those
- Otherwise, ask which areas to focus on or review recent changes
- Prioritize ViewModels, business logic, and data layer over simple views

### 2. Load Reference Patterns

Before starting the review, familiarize yourself with the reference patterns by reading the following files in `.claude/skills/coding-best-practices/`:

- **swift-patterns.md** - Optionals, type safety, collections, error handling, naming
- **swiftui-patterns.md** - State management, view composition, performance
- **architecture-patterns.md** - MVVM, code organization, memory management, security
- **coredata-patterns.md** - Core Data best practices, fetching, saving, relationships

### 3. Review Categories

Apply these review categories based on the code type:

**For All Code:**
- Swift language idioms (optionals, type safety, collections)
- Naming conventions
- Error handling
- Memory management

**For SwiftUI Code:**
- State management (`@State`, `@Observable` + `@Bindable`; legacy `@StateObject` / `@ObservedObject` pre-iOS 17)
- View composition and performance
- MVVM separation

**For ViewModels:**
- Business logic placement
- MVVM architecture adherence
- Testability (dependency injection)

**For Core Data Code:**
- Context management
- Save/fetch patterns
- Relationship handling
- CloudKit integration

### 4. Review Output Format

Provide review in this structure:

#### ✅ Strengths Found
- List well-implemented patterns
- Highlight good practices
- Acknowledge clean code sections

#### ⚠️ Issues Found

For each issue, use this format:

**Category: [Category Name]**

**[Priority]: [File.swift:line]** - [Issue description]
```swift
// Current:
[problematic code]

// Suggested:
[improved code]

// Reason: [explanation]
```

**Priority Levels:**
- **High**: Will cause bugs, crashes, or serious issues
- **Medium**: Inefficient, hard to maintain, or non-idiomatic
- **Low**: Minor improvements, nice-to-haves

#### 📊 Code Quality Score

**Overall: X/10**

- Swift Idioms: X/10
- Architecture: X/10
- Error Handling: X/10
- Naming: X/10
- Organization: X/10
- Performance: X/10

#### 📋 Recommendations

1. **High Priority**: [Critical issues]
2. **Medium Priority**: [Improvements]
3. **Low Priority**: [Nice-to-haves]

#### 🔧 Quick Wins

List 3-5 easy fixes that provide immediate value

## Review Checklist

Use this comprehensive checklist during review:

### Swift Language
- [ ] No force unwrapping unless intentional
- [ ] Proper optional handling (guard, if let, ??)
- [ ] Enums instead of string/int constants
- [ ] Functional collection operations (map, filter, etc.)
- [ ] Proper error handling (not silent try?)
- [ ] Clear, descriptive naming

### SwiftUI
- [ ] Correct property wrapper usage
- [ ] No ViewModels created in body
- [ ] Views broken into components
- [ ] No heavy computation in body
- [ ] Single source of truth
- [ ] Reaches for the modern baseline APIs (see Modern SwiftUI Baseline below)

### Architecture
- [ ] MVVM separation maintained
- [ ] Business logic in ViewModels
- [ ] UI logic in Views only
- [ ] Proper code organization with MARK
- [ ] Private by default

### Core Data
- [ ] Using shared context
- [ ] hasChanges check before save
- [ ] Typed fetch requests
- [ ] Safe property access
- [ ] Proper error handling

### Memory Management
- [ ] [weak self] in escaping closures
- [ ] Weak delegates
- [ ] No retain cycles

### Testing & Security
- [ ] Testable code structure
- [ ] Dependency injection
- [ ] No hardcoded secrets
- [ ] Input validation
- [ ] Safe logging

## Modern SwiftUI Baseline (What to Reach For Today)

The default APIs to expect in a healthy SwiftUI codebase. During review, flag code still on the legacy column — each line is: reach for this / when. Version floors in parentheses; anything unmarked is broadly available.

**Structure & navigation**
- `NavigationStack` / `NavigationSplitView` — `NavigationView` is deprecated; value-based links + `navigationDestination` (iOS 16+)

**State & data flow**
- `@Observable` over `ObservableObject` — per-property invalidation means fewer re-renders, no `@Published` (iOS 17+)
- `@State` lazily initializes `@Observable` classes (behavior backported to iOS 17) — delete double-initialization workarounds and "cheap placeholder default" hacks
- `@Previewable` inside `#Preview` — use `@State` directly in a preview without a wrapper view (Xcode 16+)

**Presentation & input**
- `presentationDetents` for resizable sheets — half-height/custom stops instead of full-screen covers (iOS 16+)
- Item-binding `alert(_:item:)` / `confirmationDialog(_:item:)` — prefer over `isPresented` + a side-car state variable; the item carries the context (WWDC26)
- `searchable` with scopes, tokens, and suggestions + `searchFocused` for programmatic search-field focus — structured search over hand-rolled filter bars
- `@FocusState` + `defaultFocus` + `focused(_:equals:)` for focus management; `onKeyPress` for hardware-keyboard handling
- Spring presets `.smooth` / `.snappy` / `.bouncy` — sensible spring defaults before hand-tuning stiffness/damping (iOS 17+)

**Scrolling**
- The scroll suite: `.scrollTargetBehavior(.paging)` / `.viewAligned`, `scrollPosition`, `onScrollGeometryChange` / `onScrollVisibilityChange` — paging, position control, and scroll-driven effects without `GeometryReader` + preference-key plumbing (iOS 17+)

**Content & media**
- `ShareLink` + `Transferable` — system share sheet from a declarative type conformance (iOS 16+)
- `PhotosPicker` — out-of-process photo selection, no permission prompt (iOS 16+)
- `AsyncImage` participates in HTTP caching by default (WWDC26); set `asyncImageURLSession` for custom cache/auth policies

**Lists & collections**
- `reorderable()` on `ForEach` and `swipeActions` outside `List` — drag-reorder and swipe in lazy stacks/grids too (WWDC26)

**Layout, effects & design**
- `visualEffect` over `GeometryReader` for visual-only geometry (scroll parallax, proximity scaling) — reads geometry without changing layout (iOS 17+)
- `glassEffect()` + `ToolbarSpacer` + bottom-aligned search for the system design language (iOS 26+) — route deep Liquid Glass work to `design/liquid-glass`
- `@ContentBuilder` as the `ViewBuilder` evolution — one builder for content usable across views, widgets, and app intents (WWDC26)

## Example Review Output

```
Reviewing: ExpenseViewModel.swift

✅ Strengths Found
- Excellent use of @Published properties
- Clean separation between public and private methods
- Good error handling with custom error types
- Proper use of guard statements for early returns

⚠️ Issues Found

**Category: Optionals Handling**

**High Priority: ExpenseViewModel.swift:45** - Force unwrapping
// Current:
let payer = expense.payer!

// Suggested:
guard let payer = expense.payer else {
    print("Expense has no payer")
    return
}

// Reason: Force unwrapping will crash if payer is nil. Use guard for safe unwrapping.

**Category: Core Data**

**Medium Priority: ExpenseViewModel.swift:89** - Saving without checking hasChanges
// Current:
try? context.save()

// Suggested:
if context.hasChanges {
    do {
        try context.save()
    } catch {
        print("Failed to save: \(error.localizedDescription)")
    }
}

// Reason: Check hasChanges to avoid unnecessary saves. Handle errors properly.

**Category: Collections**

**Low Priority: ExpenseViewModel.swift:123** - Inefficient filtering
// Current:
let found = expenses.filter { $0.id == targetId }.first

// Suggested:
let found = expenses.first { $0.id == targetId }

// Reason: first(where:) stops at first match, filter processes entire array.

📊 Code Quality Score
**Overall: 7/10**

- Swift Idioms: 6/10 (force unwrapping, inefficient collection usage)
- Architecture: 9/10 (excellent MVVM separation)
- Error Handling: 7/10 (using try? too often)
- Naming: 9/10 (clear, descriptive names)
- Organization: 8/10 (good marks, could improve grouping)
- Performance: 7/10 (some inefficient patterns)

📋 Recommendations
1. **High Priority**: Remove all force unwrapping (5 instances found)
2. **Medium Priority**: Improve error handling (don't swallow errors with try?)
3. **Low Priority**: Use first(where:) instead of filter().first

🔧 Quick Wins
1. Replace `expense.payer!` with safe unwrapping (ExpenseViewModel.swift:45)
2. Add hasChanges check before context.save() (ExpenseViewModel.swift:89)
3. Use first(where:) for finding items (ExpenseViewModel.swift:123)
```

## Tips for Effective Reviews

### Be Constructive
- Provide clear code examples for every issue
- Explain WHY, not just WHAT
- Be educational, not judgmental

### Consider Context
- Some patterns are valid in certain scenarios
- Balance idealism with pragmatism
- Consider project constraints

### Actionable Feedback
- Provide specific line numbers
- Show exact code to change
- Explain expected behavior

## References

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [Swift.org Documentation](https://docs.swift.org/)
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui)
- [Core Data Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/)

## Notes

- Read the reference pattern files for detailed examples
- Focus on the most impactful improvements first
- Provide code examples for all suggested changes
- Reference exact file locations (filename.swift:lineNumber)
- Be thorough but constructive

### Source: `ios/ipad-patterns`

# iPad Patterns

Comprehensive guide for iPadOS-specific development patterns. Covers multitasking (Stage Manager, Split View, Slide Over), multi-window support, drag and drop, keyboard shortcuts, pointer interactions, Apple Pencil, and external display support. These patterns differentiate an iPad-optimized app from a scaled-up iPhone app.

## When This Skill Activates

- User is building or reviewing iPad-specific features
- User asks about Stage Manager, multi-window, or UIScene lifecycle
- User needs drag and drop (NSItemProvider, Transferable, UIDragInteraction)
- User wants keyboard shortcuts or discoverability overlay
- User asks about pointer/trackpad interactions or hover effects
- User is implementing Apple Pencil or PencilKit support
- User needs adaptive layouts for Split View, Slide Over, or size classes
- User asks about external display support
- User wants to make an iPhone app work well on iPad

## Decision Tree

```
What iPad feature are you building?
|
+-- Multi-window / Stage Manager / UIScene lifecycle
|   +-- multitasking.md
|      +-- Scene configuration, requestSceneSessionActivation
|      +-- Window management, scene delegates
|
+-- Split View / Slide Over / Adaptive Layout
|   +-- multitasking.md
|      +-- Size classes, compact/regular transitions
|      +-- NavigationSplitView column widths
|
+-- Drag and Drop
|   +-- drag-drop.md
|      +-- SwiftUI: .draggable() / .dropDestination()
|      +-- UIKit: UIDragInteraction / UIDropInteraction
|      +-- Transferable protocol, NSItemProvider
|
+-- Keyboard Shortcuts
|   +-- input-methods.md
|      +-- SwiftUI: .keyboardShortcut()
|      +-- UIKit: UIKeyCommand
|      +-- Discoverability overlay (Cmd hold)
|
+-- Pointer / Trackpad Interactions
|   +-- input-methods.md
|      +-- .hoverEffect(), UIPointerInteraction
|      +-- Custom pointer shapes, lift/highlight effects
|
+-- Apple Pencil / PencilKit
|   +-- input-methods.md
|      +-- PKCanvasView, PKDrawing
|      +-- Touch type filtering, Scribble
|
+-- External Display
    +-- multitasking.md
       +-- WindowGroup for external scenes
       +-- UIScreen notifications (legacy)
```

## API Availability

| API | Minimum Version | Reference |
|-----|----------------|-----------|
| `UIScene` / `UISceneDelegate` | iPadOS 13 | multitasking.md |
| `UISceneConfiguration` | iPadOS 13 | multitasking.md |
| `UIUserInterfaceSizeClass` | iPadOS 8 | multitasking.md |
| `NavigationSplitView` | iPadOS 16 | multitasking.md |
| `.horizontalSizeClass` / `.verticalSizeClass` | iPadOS 14 (SwiftUI) | multitasking.md |
| `.hoverEffect()` | iPadOS 13 | input-methods.md |
| `.keyboardShortcut()` | iPadOS 14 | input-methods.md |
| `PencilKit` (PKCanvasView) | iPadOS 13 | input-methods.md |
| `.draggable()` / `.dropDestination()` | iPadOS 16 | drag-drop.md |
| `Transferable` protocol | iPadOS 16 | drag-drop.md |
| `UIDragInteraction` / `UIDropInteraction` | iPadOS 11 | drag-drop.md |
| `NSItemProvider` | iPadOS 11 | drag-drop.md |
| `WindowGroup` (multi-window) | iPadOS 16 (SwiftUI lifecycle) | multitasking.md |
| `.handlesExternalEvents` | iPadOS 14 | multitasking.md |
| `UISceneSession.requestSceneSessionActivation` | iPadOS 13 | multitasking.md |
| `.focusable()` / `@FocusState` | iPadOS 15 | input-methods.md |
| `FocusedValue` / `FocusedObject` | iPadOS 16 | input-methods.md |

## Top 5 Mistakes

| # | Mistake | Fix | Details |
|---|---------|-----|---------|
| 1 | Ignoring size classes, building fixed layouts | Use `@Environment(\.horizontalSizeClass)` to adapt between compact and regular | multitasking.md |
| 2 | No keyboard shortcuts for common actions | Add `.keyboardShortcut()` to primary actions (Cmd+N, Cmd+S, Delete) | input-methods.md |
| 3 | Missing drag and drop on list/grid items | Add `.draggable()` and `.dropDestination()` for content types users expect to move | drag-drop.md |
| 4 | No hover effects on interactive elements | Add `.hoverEffect()` to buttons, list rows, and custom controls | input-methods.md |
| 5 | Not supporting multiple windows (single-scene only) | Add `WindowGroup` support and handle `NSUserActivity` for state restoration | multitasking.md |

## iPad Design Rules (WWDC25)

| Area | Rule |
|------|------|
| Adaptive navigation | The tab bar can morph into a sidebar -- use a sidebar for deep or nested content hierarchies, a tab bar when the app is compact and content-forward |
| Immersion | Run content under the toolbar/sidebar with a scroll edge effect so a floating window still feels edge-to-edge |
| Window controls | Wrap the toolbar around the window controls on the leading edge instead of reserving a safe-area strip above the content |
| Documents | Each document opens in ITS OWN window, never "in place" -- and every window gets a unique, descriptive name so the app menu's window list stays navigable |
| Pointer | Test with the pointer -- it is 1:1 precise with no magnetizing or rubber-banding to targets, so dense hit areas that survive touch forgiveness can still fail |
| Menu bar | Order menu items by frequency of use (not alphabetically); push secondary actions into submenus; populate the View menu with tabs, their keyboard shortcuts, and sidebar toggles |

## Process

### 1. Identify iPad Features Needed

Read the user's code or requirements to determine:
- Is this a new iPad app or adapting an iPhone app?
- Which iPad-specific features are relevant (multitasking, drag/drop, keyboard, pencil)?
- Target iPadOS version and hardware (Stage Manager requires M1+)
- Whether the app uses SwiftUI lifecycle or UIKit AppDelegate

### 2. Load Relevant Reference Files

Based on the need, read from this directory:
- `multitasking.md` -- Stage Manager, multi-window, Split View, Slide Over, size classes, external display
- `input-methods.md` -- Keyboard shortcuts, pointer interactions, Apple Pencil, focus system
- `drag-drop.md` -- Drag and drop, Transferable protocol, NSItemProvider

### 3. Review or Recommend

Apply patterns from the reference files. Check for common issues using the review checklist below.

### 4. Cross-Reference

- For **navigation architecture** on iPad, see `ios/navigation-patterns/navigation-split-view.md`
- For **macOS Catalyst** concerns, see `macos/coding-best-practices/`
- For **toolbar patterns**, see `swiftui/toolbars/SKILL.md`
- For **animation and transitions**, see `design/animation-patterns/`

## Review Checklist

When reviewing code for iPad optimization, verify:

- [ ] **Size class adaptation** -- UI adapts to compact/regular width (Split View, Slide Over)
- [ ] **Keyboard shortcuts** -- primary actions have `.keyboardShortcut()` modifiers
- [ ] **Discoverability** -- shortcuts appear when user holds Command key
- [ ] **Pointer effects** -- interactive elements have `.hoverEffect()`
- [ ] **Drag and drop** -- list/grid items support `.draggable()` and `.dropDestination()`
- [ ] **Multi-window** -- app supports multiple windows if content model allows it
- [ ] **Scene restoration** -- state is preserved when scene disconnects/reconnects
- [ ] **Pencil support** -- drawing views filter touch types, PencilKit configured correctly
- [ ] **Column layout** -- `NavigationSplitView` column widths appropriate for iPad
- [ ] **No hardcoded widths** -- layouts use `.frame(minWidth:idealWidth:maxWidth:)` or geometry-based sizing
- [ ] **Context menus** -- long-press context menus on relevant items (also improve right-click with pointer)
- [ ] **Toolbar placement** -- actions placed in `.primaryAction`, `.secondaryAction`, or `.keyboard` as appropriate

## References

- [Preparing your iPadOS app for multitasking](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ipados_app_for_multitasking)
- [Adding drag and drop to a SwiftUI view](https://developer.apple.com/documentation/swiftui/adding-drag-and-drop)
- [Transferable](https://developer.apple.com/documentation/coretransferable/transferable)
- [Adding keyboard shortcuts](https://developer.apple.com/documentation/swiftui/adding-keyboard-shortcuts-to-a-swiftui-app)
- [Pointer interactions](https://developer.apple.com/documentation/uikit/pointer_interactions)
- [PencilKit](https://developer.apple.com/documentation/pencilkit)
- [UIScene](https://developer.apple.com/documentation/uikit/uiscene)

### Source: `ios/migration-patterns`

# Migration Patterns

Comprehensive guides for migrating between Apple framework generations. Each guide covers the full before/after mapping, coexistence strategies, and common pitfalls.

## When This Skill Activates

- User asks how to migrate from CoreData to SwiftData
- User is moving UIKit code to SwiftUI (or embedding one in the other)
- User needs to update from ObservableObject/Combine to @Observable/AsyncSequence
- User is converting XCTest tests to Swift Testing
- User asks about coexistence strategies (running old and new frameworks side by side)
- User wants to know whether a migration is worth doing for their situation
- User is migrating Objective-C code to Swift (bridging headers, incremental migration)
- User is migrating from StoreKit 1 to StoreKit 2 (in-app purchases, subscriptions)
- User encounters errors during a framework migration

## Decision Tree

```
What are you migrating?
|
+-- Data persistence layer
|   +-- CoreData --> SwiftData
|   |   See coredata-to-swiftdata.md
|   |   Min: iOS 17 / macOS 14
|   |
|   +-- Still need CoreData features SwiftData lacks?
|       Stay on CoreData or use coexistence mode
|
+-- UI framework
|   +-- UIKit --> SwiftUI
|   |   See uikit-to-swiftui.md
|   |   Min: iOS 13 (basic), iOS 16+ (modern navigation)
|   |
|   +-- Full rewrite or incremental?
|       Incremental is almost always better -- adopt screen by screen
|
+-- State management / observation
|   +-- ObservableObject --> @Observable
|   |   See observable-migration.md
|   |   Min: iOS 17 / macOS 14
|   |
|   +-- Combine publishers --> AsyncSequence
|       Also covered in observable-migration.md
|
+-- Programming language
|   +-- Objective-C --> Swift
|   |   See objc-to-swift.md
|   |   Incremental: migrate leaves first, trunks last
|   |
|   +-- Mixed-language project?
|       Both languages coexist via bridging headers
|
+-- In-app purchases
|   +-- StoreKit 1 --> StoreKit 2
|   |   See storekit-migration.md
|   |   Min: iOS 15
|   |
|   +-- Using a third-party SDK (RevenueCat, etc.)?
|       Check if SDK already supports StoreKit 2 internally
|
+-- Testing framework
    +-- XCTest --> Swift Testing
        See xctest-to-swift-testing.md
        Min: Xcode 16 / Swift 6.0
```

## Quick Reference

| Migration | Reference File | Minimum OS | Risk Level |
|-----------|---------------|------------|------------|
| CoreData to SwiftData | `coredata-to-swiftdata.md` | iOS 17 / macOS 14 | High (data layer) |
| UIKit to SwiftUI | `uikit-to-swiftui.md` | iOS 13+ | Medium (incremental) |
| ObservableObject to @Observable | `observable-migration.md` | iOS 17 / macOS 14 | Low-Medium |
| Objective-C to Swift | `objc-to-swift.md` | Any | Medium (incremental) |
| StoreKit 1 to StoreKit 2 | `storekit-migration.md` | iOS 15 | Medium-High (payments) |
| XCTest to Swift Testing | `xctest-to-swift-testing.md` | Xcode 16 | Low |

## Process

### 1. Assess the Migration

Before starting, determine:
- What is the minimum deployment target? Many migrations require iOS 17+.
- How large is the surface area? (number of models, screens, test files)
- Can you adopt incrementally or is it all-or-nothing?
- Are there third-party dependencies that assume the old framework?

### 2. Load Relevant Reference File

Based on the migration type, read from this directory:
- `coredata-to-swiftdata.md` -- NSManagedObject to @Model, migration stages, coexistence
- `uikit-to-swiftui.md` -- UIHostingController, Representable, incremental adoption
- `observable-migration.md` -- @Observable macro, @Environment injection, AsyncSequence
- `objc-to-swift.md` -- Bridging headers, @objc, incremental file-by-file migration
- `storekit-migration.md` -- StoreKit 2 async/await purchases, Transaction.currentEntitlements, JWS
- `xctest-to-swift-testing.md` -- @Test, #expect, #require, parameterized tests

### 3. Review the User's Code

Scan for old-framework patterns and map each to its modern equivalent using the reference file. Check for:

- [ ] Deprecated API usage that has a direct modern replacement
- [ ] Custom workarounds that are no longer needed with the new framework
- [ ] Third-party dependencies that may conflict with the migration
- [ ] Coexistence requirements (both frameworks running simultaneously)

### 4. Recommend a Migration Strategy

For each migration, decide between:

- **Full migration**: Replace all old-framework code at once. Best for small codebases or when old framework is causing problems.
- **Incremental migration**: Migrate piece by piece while both frameworks coexist. Best for large codebases, production apps, or when timeline is flexible.
- **No migration**: The old framework is still appropriate. See "When NOT to Migrate" in each reference file.

## General Migration Principles

1. **Migrate tests first.** If you are migrating both app code and tests, migrate tests to Swift Testing first. This gives you a safety net for the app-code migration.

2. **One migration at a time.** Do not migrate CoreData to SwiftData and ObservableObject to @Observable in the same PR. Each migration should be independently reviewable and revertible.

3. **Keep the old code compiling.** During incremental migration, both old and new code must compile and run. Use coexistence patterns from each reference file.

4. **Feature-flag large migrations.** For production apps, consider gating new-framework code behind a feature flag so you can roll back without a code revert.

5. **Write migration tests.** For data-layer migrations (CoreData to SwiftData), write tests that verify data roundtrips correctly through both stacks.

## References

- [Migrating from CoreData to SwiftData](https://developer.apple.com/documentation/coredata/migrating-from-core-data-to-swiftdata)
- [Migrating to new navigation types](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types)
- [Migrating from ObservableObject to Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)
- [Migrating a test from XCTest](https://developer.apple.com/documentation/testing/migratingfromxctest)
- [Migrating an app from StoreKit 1](https://developer.apple.com/documentation/storekit/in-app_purchase/implementing_a_store_in_your_app_using_the_storekit_api)

### Source: `ios/navigation-patterns`

# Navigation Patterns

Comprehensive guide for SwiftUI navigation architecture on iOS, iPadOS, and macOS. Covers the modern navigation APIs (iOS 16+/macOS 13+) with patterns for common and advanced use cases.

## When This Skill Activates

- User is building or reviewing navigation architecture
- User has navigation-related bugs (stack not updating, back button issues, state loss)
- User asks about NavigationStack, NavigationSplitView, TabView, or NavigationPath
- User needs programmatic navigation (push, pop, pop-to-root)
- User is implementing deep linking that connects to navigation
- User asks about navigation transitions or animations
- User is choosing between navigation approaches for their app

## Decision Tree

Use this to pick the right navigation container:

```
What is the app structure?
│
├─ Flat sections (3-5 top-level areas)
│  └─ TabView → see tab-view.md
│
├─ Hierarchical drill-down (list → detail)
│  └─ NavigationStack → see navigation-stack.md
│
├─ Sidebar + content (macOS / iPad)
│  ├─ Two columns → NavigationSplitView → see navigation-split-view.md
│  └─ Three columns → NavigationSplitView → see navigation-split-view.md
│
└─ Combined (tabs with drill-down, sidebar with stacks)
   └─ TabView + NavigationStack per tab
      OR NavigationSplitView + NavigationStack in detail
```

## Quick Reference

| Pattern | Container | Min OS | Reference |
|---------|-----------|--------|-----------|
| Simple drill-down | `NavigationStack` | iOS 16 | `navigation-stack.md` |
| Value-based links | `NavigationLink(value:)` | iOS 16 | `navigation-stack.md` |
| Programmatic push/pop | `NavigationPath` | iOS 16 | `programmatic-navigation.md` |
| Pop to root | `path = NavigationPath()` | iOS 16 | `programmatic-navigation.md` |
| State restoration | `NavigationPath.CodableRepresentation` | iOS 16 | `programmatic-navigation.md` |
| Two-column layout | `NavigationSplitView` | iOS 16 | `navigation-split-view.md` |
| Three-column layout | `NavigationSplitView` | iOS 16 | `navigation-split-view.md` |
| Column visibility | `NavigationSplitViewVisibility` | iOS 16 | `navigation-split-view.md` |
| Tab bar | `TabView` | iOS 13 | `tab-view.md` |
| Customizable tabs | `Tab` + `TabView` | iOS 18 | `tab-view.md` |
| Sidebar tabs (iPad) | `.tabViewStyle(.sidebarAdaptable)` | iOS 18 | `tab-view.md` |
| Zoom transition | `.navigationTransition(.zoom)` | iOS 18 | `navigation-transitions.md` |
| Custom transitions | `NavigationTransition` | iOS 18 | `navigation-transitions.md` |

## Navigation Design Rules (WWDC22)

The container APIs above decide *how* navigation is built; these rules decide *whether* it's designed right.

**Tab bars**
- Tabs are top-level **content categories**, not arbitrary groupings — balance features across tabs so each carries real weight.
- ❌ Never auto-switch tabs in response to an action taken in another tab — confirm in place instead.

**Push vs modal**
- Push (right-to-left) = traversing the app's hierarchy. Modal (slides up — covering the tab bar is *by design*) = a self-contained task apart from the hierarchy.
- Modals come in three types: simple task, multi-step task, full-screen content.
- Limit modals presented over modals — each stacked layer buries the user deeper in transient state.

**Wayfinding**
- Nav bar title = the current location; the back button shows the *previous* screen's title.

## The Three Cookbook Recipes (WWDC22)

Nearly every app is one of these three shapes. Pick one per scene, then lift its navigation state.

1. **Pushable stack** — `NavigationStack(path:)` + `NavigationLink(value:)` + `.navigationDestination(for:)`. Pop-to-root is `path.removeAll()`; a deep link is just assigning the path.
2. **Multi-column without stacks** — `NavigationSplitView` + `List(selection:)` in each leading column. Value links auto-drive the next column's selection, so programmatic navigation is setting the selection value.
3. **Split + stack (Photos-style)** — `NavigationSplitView` with a `NavigationStack(path:)` *inside the detail column*: sidebar selection picks the collection, the stack drills into it.

**Rules that make the recipes hold up:**
- Build with `NavigationSplitView` even for iPhone-first apps — it auto-collapses to a single stack in compact width, and iPad/Mac layouts come free.
- Lift navigation state: exactly one bound `path`/selection per container. That single source of truth is what makes pop-to-root, deep links, and restoration one-line operations.

**State restoration:** persist through `@SceneStorage("navigation")` plus a `.task` that restores once on appear, then streams subsequent path changes back into storage.

## Process

### 1. Identify Navigation Needs

Read the user's code or requirements to determine:
- App structure (flat, hierarchical, sidebar-based)
- Target platforms (iOS only, iPad adaptive, macOS)
- Whether programmatic navigation is needed
- Deep linking requirements

### 2. Load Relevant Reference Files

Based on the need, read from this directory:
- `navigation-stack.md` — NavigationStack, NavigationLink, navigationDestination
- `navigation-split-view.md` — Two/three column layouts, column control, adaptive behavior
- `tab-view.md` — TabView, iOS 18 customizable tabs, sidebar mode
- `programmatic-navigation.md` — NavigationPath, state restoration, coordinators, pop-to-root
- `navigation-transitions.md` — Custom push/pop transitions (iOS 18+)

### 3. Review or Recommend

Apply patterns from the reference files. Check for common mistakes:

- [ ] Using deprecated `NavigationView` instead of `NavigationStack`/`NavigationSplitView`
- [ ] Using `NavigationLink(destination:)` instead of `NavigationLink(value:)` + `.navigationDestination`
- [ ] Placing `NavigationStack` in a sidebar/content column of `NavigationSplitView` (a stack belongs only in the detail column — Recipe 3)
- [ ] `.navigationDestination` attached inside a lazy container (destination may never register)
- [ ] Missing `.navigationDestination` registration for a value type
- [ ] NavigationPath not `@State` or not in the right scope
- [ ] Multiple NavigationStacks competing for the same navigation context
- [ ] Hard-coding navigation instead of using `NavigationPath` for programmatic control
- [ ] Not handling deep links through the navigation system

### 4. Cross-Reference

- For **deep linking URL handling**, see `generators/deep-linking/` skill
- For **navigation animations**, see `design/animation-patterns/transitions.md`
- For **macOS sidebar patterns**, see `macos/ui-review-tahoe/swiftui-macos.md`

## References

- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)
- [NavigationPath](https://developer.apple.com/documentation/swiftui/navigationpath)
- [TabView](https://developer.apple.com/documentation/swiftui/tabview)
- [Migrating to new navigation types](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types)

### Source: `legal`

# Legal Document Generation & Compliance

Legal document generation and compliance guidance for indie Apple developers. Generate privacy policies, terms of service, and EULAs tailored to your app's data practices and target markets.

## When This Skill Activates

Use this skill when the user:
- Needs a privacy policy for their app
- Needs terms of service or EULA
- Asks about legal compliance for App Store submission
- Mentions GDPR, CCPA, DPDP, or COPPA compliance
- Wants to update legal documents after adding analytics, ads, or tracking
- Asks about Apple's privacy requirements or Privacy Nutrition Labels
- Needs legal document hosting guidance (GitHub Pages, in-app, website)

## Available Skills

### privacy-policy/
Generate privacy policies, terms of service, and EULAs tailored to your app's data collection practices, third-party SDKs, and target regions. Includes Apple Privacy Nutrition Label mapping and hosting guidance.

### privacy-publish/
Publish the generated legal pages to hosted URLs and set the App Store Connect Privacy Policy / Support URLs via the ASC API (dry-run first).

## How to Use

1. User requests legal documents or compliance guidance
2. Read `privacy-policy/SKILL.md` for the full generation workflow
3. The skill will ask configuration questions about data practices
4. Documents are generated in Markdown with app-specific placeholders filled in

## Related Skills

- `generators/consent-flow` -- GDPR/CCPA consent UI and tracking consent management
- `generators/account-deletion` -- Account deletion flow (App Store requirement)
- `generators/permission-priming` -- Pre-permission UI patterns (ATT priming)
- `monetization/` -- Subscription terms and pricing disclosures

### Source: `legal-risk-assessment`

# Legal Risk Assessment Skill

You are a legal risk assessment assistant for an in-house legal team. You help evaluate, classify, and document legal risks using a structured framework based on severity and likelihood.

**Important**: You assist with legal workflows but do not provide legal advice. Risk assessments should be reviewed by qualified legal professionals. The framework provided is a starting point that organizations should customize to their specific risk appetite and industry context.

## Risk Assessment Framework

### Severity x Likelihood Matrix

Legal risks are assessed on two dimensions:

**Severity** (impact if the risk materializes):

| Level | Label | Description |
|---|---|---|
| 1 | **Negligible** | Minor inconvenience; no material financial, operational, or reputational impact. Can be handled within normal operations. |
| 2 | **Low** | Limited impact; minor financial exposure (< 1% of relevant contract/deal value); minor operational disruption; no public attention. |
| 3 | **Moderate** | Meaningful impact; material financial exposure (1-5% of relevant value); noticeable operational disruption; potential for limited public attention. |
| 4 | **High** | Significant impact; substantial financial exposure (5-25% of relevant value); significant operational disruption; likely public attention; potential regulatory scrutiny. |
| 5 | **Critical** | Severe impact; major financial exposure (> 25% of relevant value); fundamental business disruption; significant reputational damage; regulatory action likely; potential personal liability for officers/directors. |

**Likelihood** (probability the risk materializes):

| Level | Label | Description |
|---|---|---|
| 1 | **Remote** | Highly unlikely to occur; no known precedent in similar situations; would require exceptional circumstances. |
| 2 | **Unlikely** | Could occur but not expected; limited precedent; would require specific triggering events. |
| 3 | **Possible** | May occur; some precedent exists; triggering events are foreseeable. |
| 4 | **Likely** | Probably will occur; clear precedent; triggering events are common in similar situations. |
| 5 | **Almost Certain** | Expected to occur; strong precedent or pattern; triggering events are present or imminent. |

### Risk Score Calculation

**Risk Score = Severity x Likelihood**

| Score Range | Risk Level | Color |
|---|---|---|
| 1-4 | **Low Risk** | GREEN |
| 5-9 | **Medium Risk** | YELLOW |
| 10-15 | **High Risk** | ORANGE |
| 16-25 | **Critical Risk** | RED |

### Risk Matrix Visualization

```
                    LIKELIHOOD
                Remote  Unlikely  Possible  Likely  Almost Certain
                  (1)     (2)       (3)      (4)        (5)
SEVERITY
Critical (5)  |   5    |   10   |   15   |   20   |     25     |
High     (4)  |   4    |    8   |   12   |   16   |     20     |
Moderate (3)  |   3    |    6   |    9   |   12   |     15     |
Low      (2)  |   2    |    4   |    6   |    8   |     10     |
Negligible(1) |   1    |    2   |    3   |    4   |      5     |
```

## Risk Classification Levels with Recommended Actions

### GREEN -- Low Risk (Score 1-4)

**Characteristics**:
- Minor issues that are unlikely to materialize
- Standard business risks within normal operating parameters
- Well-understood risks with established mitigations in place

**Recommended Actions**:
- **Accept**: Acknowledge the risk and proceed with standard controls
- **Document**: Record in the risk register for tracking
- **Monitor**: Include in periodic reviews (quarterly or annually)
- **No escalation required**: Can be managed by the responsible team member

**Examples**:
- Vendor contract with minor deviation from standard terms in a non-critical area
- Routine NDA with a well-known counterparty in a standard jurisdiction
- Minor administrative compliance task with clear deadline and owner

### YELLOW -- Medium Risk (Score 5-9)

**Characteristics**:
- Moderate issues that could materialize under foreseeable circumstances
- Risks that warrant attention but do not require immediate action
- Issues with established precedent for management

**Recommended Actions**:
- **Mitigate**: Implement specific controls or negotiate to reduce exposure
- **Monitor actively**: Review at regular intervals (monthly or as triggers occur)
- **Document thoroughly**: Record risk, mitigations, and rationale in risk register
- **Assign owner**: Ensure a specific person is responsible for monitoring and mitigation
- **Brief stakeholders**: Inform relevant business stakeholders of the risk and mitigation plan
- **Escalate if conditions change**: Define trigger events that would elevate the risk level

**Examples**:
- Contract with liability cap below standard but within negotiable range
- Vendor processing personal data in a jurisdiction without clear adequacy determination
- Regulatory development that may affect a business activity in the medium term
- IP provision that is broader than preferred but common in the market

### ORANGE -- High Risk (Score 10-15)

**Characteristics**:
- Significant issues with meaningful probability of materializing
- Risks that could result in substantial financial, operational, or reputational impact
- Issues that require senior attention and dedicated mitigation efforts

**Recommended Actions**:
- **Escalate to senior counsel**: Brief the head of legal or designated senior counsel
- **Develop mitigation plan**: Create a specific, actionable plan to reduce the risk
- **Brief leadership**: Inform relevant business leaders of the risk and recommended approach
- **Set review cadence**: Review weekly or at defined milestones
- **Consider outside counsel**: Engage outside counsel for specialized advice if needed
- **Document in detail**: Full risk memo with analysis, options, and recommendations
- **Define contingency plan**: What will the organization do if the risk materializes?

**Examples**:
- Contract with uncapped indemnification in a material area
- Data processing activity that may violate a regulatory requirement if not restructured
- Threatened litigation from a significant counterparty
- IP infringement allegation with colorable basis
- Regulatory inquiry or audit request

### RED -- Critical Risk (Score 16-25)

**Characteristics**:
- Severe issues that are likely or certain to materialize
- Risks that could fundamentally impact the business, its officers, or its stakeholders
- Issues requiring immediate executive attention and rapid response

**Recommended Actions**:
- **Immediate escalation**: Brief General Counsel, C-suite, and/or Board as appropriate
- **Engage outside counsel**: Retain specialized outside counsel immediately
- **Establish response team**: Dedicated team to manage the risk with clear roles
- **Consider insurance notification**: Notify insurers if applicable
- **Crisis management**: Activate crisis management protocols if reputational risk is involved
- **Preserve evidence**: Implement litigation hold if legal proceedings are possible
- **Daily or more frequent review**: Active management until the risk is resolved or reduced
- **Board reporting**: Include in board risk reporting as appropriate
- **Regulatory notifications**: Make any required regulatory notifications

**Examples**:
- Active litigation with significant exposure
- Data breach affecting regulated personal data
- Regulatory enforcement action
- Material contract breach by or against the organization
- Government investigation
- Credible IP infringement claim against a core product or service

## Documentation Standards for Risk Assessments

### Risk Assessment Memo Format

Every formal risk assessment should be documented using the following structure:

```
## Legal Risk Assessment

**Date**: [assessment date]
**Assessor**: [person conducting assessment]
**Matter**: [description of the matter being assessed]
**Privileged**: [Yes/No - mark as attorney-client privileged if applicable]

### 1. Risk Description
[Clear, concise description of the legal risk]

### 2. Background and Context
[Relevant facts, history, and business context]

### 3. Risk Analysis

#### Severity Assessment: [1-5] - [Label]
[Rationale for severity rating, including potential financial exposure, operational impact, and reputational considerations]

#### Likelihood Assessment: [1-5] - [Label]
[Rationale for likelihood rating, including precedent, triggering events, and current conditions]

#### Risk Score: [Score] - [GREEN/YELLOW/ORANGE/RED]

### 4. Contributing Factors
[What factors increase the risk]

### 5. Mitigating Factors
[What factors decrease the risk or limit exposure]

### 6. Mitigation Options

| Option | Effectiveness | Cost/Effort | Recommended? |
|---|---|---|---|
| [Option 1] | [High/Med/Low] | [High/Med/Low] | [Yes/No] |
| [Option 2] | [High/Med/Low] | [High/Med/Low] | [Yes/No] |

### 7. Recommended Approach
[Specific recommended course of action with rationale]

### 8. Residual Risk
[Expected risk level after implementing recommended mitigations]

### 9. Monitoring Plan
[How and how often the risk will be monitored; trigger events for re-assessment]

### 10. Next Steps
1. [Action item 1 - Owner - Deadline]
2. [Action item 2 - Owner - Deadline]
```

### Risk Register Entry

For tracking in the team's risk register:

| Field | Content |
|---|---|
| Risk ID | Unique identifier |
| Date Identified | When the risk was first identified |
| Description | Brief description |
| Category | Contract, Regulatory, Litigation, IP, Data Privacy, Employment, Corporate, Other |
| Severity | 1-5 with label |
| Likelihood | 1-5 with label |
| Risk Score | Calculated score |
| Risk Level | GREEN / YELLOW / ORANGE / RED |
| Owner | Person responsible for monitoring |
| Mitigations | Current controls in place |
| Status | Open / Mitigated / Accepted / Closed |
| Review Date | Next scheduled review |
| Notes | Additional context |

## When to Escalate to Outside Counsel

Engage outside counsel when:

### Mandatory Engagement
- **Active litigation**: Any lawsuit filed against or by the organization
- **Government investigation**: Any inquiry from a government agency, regulator, or law enforcement
- **Criminal exposure**: Any matter with potential criminal liability for the organization or its personnel
- **Securities issues**: Any matter that could affect securities disclosures or filings
- **Board-level matters**: Any matter requiring board notification or approval

### Strongly Recommended Engagement
- **Novel legal issues**: Questions of first impression or unsettled law where the organization's position could set precedent
- **Jurisdictional complexity**: Matters involving unfamiliar jurisdictions or conflicting legal requirements across jurisdictions
- **Material financial exposure**: Risks with potential exposure exceeding the organization's risk tolerance thresholds
- **Specialized expertise needed**: Matters requiring deep domain expertise not available in-house (antitrust, FCPA, patent prosecution, etc.)
- **Regulatory changes**: New regulations that materially affect the business and require compliance program development
- **M&A transactions**: Due diligence, deal structuring, and regulatory approvals for significant transactions

### Consider Engagement
- **Complex contract disputes**: Significant disagreements over contract interpretation with material counterparties
- **Employment matters**: Claims or potential claims involving discrimination, harassment, wrongful termination, or whistleblower protections
- **Data incidents**: Potential data breaches that may trigger notification obligations
- **IP disputes**: Infringement allegations (received or contemplated) involving material products or services
- **Insurance coverage disputes**: Disagreements with insurers over coverage for material claims

### Selecting Outside Counsel

When recommending outside counsel engagement, suggest the user consider:
- Relevant subject matter expertise
- Experience in the applicable jurisdiction
- Understanding of the organization's industry
- Conflict of interest clearance
- Budget expectations and fee arrangements (hourly, fixed fee, blended rates, success fees)
- Diversity and inclusion considerations
- Existing relationships (panel firms, prior engagements)

### Source: `macos/architecture-patterns`

# Architecture Patterns Expert

You are a macOS software architect specializing in Swift 6+ application design. You help developers choose the right architecture, apply SOLID principles, and organize code for maintainability and testability.

## Your Role

Guide developers through architectural decisions for macOS applications, from project structure to design patterns to dependency management. Focus on pragmatic, testable designs that leverage Swift's type system.

## Core Focus Areas

1. **SOLID Principles** - Applied to real-world Swift with concrete refactoring examples
2. **Design Patterns** - MVVM, Repository, Factory, Observer, Coordinator patterns
3. **Modular Design** - Swift Package Manager structure, feature modules, code organization

## When This Skill Activates

- Designing a new macOS application's architecture
- Refactoring an existing app for better maintainability
- Reviewing architecture choices and patterns
- Deciding between architectural approaches (MVVM vs MVC, etc.)
- Organizing a growing codebase into modules

## Architectural Decision Guide

### Small App (1-3 screens)
- Simple MVVM with @Observable
- Single module, flat file structure
- No need for complex abstractions

### Medium App (4-10 screens)
- Repository pattern + protocol-based DI, organized in feature folders

### Large App (10+ screens, multiple developers)
- Full modular architecture with SPM packages
- Feature modules with clear API boundaries
- Coordinator pattern for navigation
- Shared domain layer

## How to Conduct Reviews

### Step 1: Understand the Context
- What's the app's scale and team size?
- What's the minimum macOS deployment target?
- Are there existing architectural patterns in place?

### Step 2: Review Against Module Guidelines
- SOLID principles (see solid-detailed.md)
- Design patterns (see design-patterns.md)
- Code organization (see modular-design.md)

### Step 3: Provide Structured Feedback

For each issue found:
1. **Issue**: Describe the architectural problem
2. **Principle Violated**: Reference specific principle
3. **Impact**: Technical debt, testability, maintainability
4. **Fix**: Concrete refactoring with before/after code
5. **Trade-offs**: Acknowledge when simplicity beats purity

## Quick Reference: Common Anti-Patterns

### Massive View Model
```swift
// Wrong - ViewModel does everything
@Observable class ContentViewModel {
    var items: [Item] = []
    func fetchItems() { /* networking */ }
    func saveItem(_ item: Item) { /* persistence */ }
    func validateItem(_ item: Item) -> Bool { /* validation */ }
    func exportItems() { /* file export */ }
    func importItems(from url: URL) { /* file import */ }
}

// Right - separate concerns
@Observable class ContentViewModel {
    private let repository: ItemRepository
    private let validator: ItemValidator

    var items: [Item] = []

    func fetchItems() async throws {
        items = try await repository.fetchAll()
    }

    func saveItem(_ item: Item) async throws {
        guard validator.isValid(item) else { throw ValidationError.invalid }
        try await repository.save(item)
    }
}
```

### God Object AppState
```swift
// Wrong - single state object for everything
@Observable class AppState {
    var user: User?
    var documents: [Document] = []
    var settings: Settings = .default
    var networkStatus: NetworkStatus = .unknown
    var notifications: [AppNotification] = []
    // ... keeps growing
}

// Right - domain-specific state objects
@Observable class AuthState { var user: User? }
@Observable class DocumentState { var documents: [Document] = [] }
@Observable class SettingsState { var settings: Settings = .default }
```

### Untestable Dependencies
```swift
// Wrong - hard-coded dependency
class DocumentService {
    func save(_ doc: Document) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(doc)
        try! data.write(to: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }
}

// Right - injectable dependency
protocol FileStorage {
    func write(_ data: Data, to url: URL) throws
}

class DocumentService {
    private let storage: FileStorage
    init(storage: FileStorage) { self.storage = storage }

    func save(_ doc: Document) throws {
        let data = try JSONEncoder().encode(doc)
        try storage.write(data, to: documentURL)
    }
}
```

## Module References

Load these modules as needed:

1. **SOLID Principles**: `solid-detailed.md`
   - Each principle with real-world Swift examples
   - Refactoring patterns for violations
   - When to bend the rules pragmatically

2. **Design Patterns**: `design-patterns.md`
   - MVVM, Repository, Factory, Observer, Coordinator
   - Swift-specific implementations
   - When to use which pattern

3. **Modular Design**: `modular-design.md`
   - SPM package structure
   - Feature vs. layer organization
   - Dependency management

## Response Guidelines

- Be pragmatic — don't over-architect small apps
- Show before/after code for refactoring suggestions
- Acknowledge trade-offs (abstraction vs. simplicity)
- Consider the team size and project phase
- Prefer composition over inheritance
- Leverage Swift's type system (protocols, generics, enums) for safety
