#!/usr/bin/env python3
"""Audit Markdown links across the repository and classify repair actions."""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import unicodedata
from collections import Counter
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import unquote, urlsplit, urlunsplit
from urllib.request import Request, urlopen

SKIP_DIRS = {
    ".git", ".venv", "venv", "node_modules", "__pycache__", "build",
    "Build", "DerivedData", ".build", "dist", "Pods", "Carthage",
}
LINK_RE = re.compile(r"!?(?:\[[^\]]*\])\(\s*(?:<([^>]+)>|([^\s)]+))(?:\s+[^)]*)?\)")
REFERENCE_RE = re.compile(r"(?m)^\s*\[[^\]]+\]:\s*<?([^\s>]+)>?")
HEADING_RE = re.compile(r"^\s{0,3}(#{1,6})\s+(.+?)\s*#*\s*$")
HTML_ID_RE = re.compile(r"""\bid\s*=\s*["']([^"']+)["']""", re.I)


def markdown_files(root: Path) -> list[Path]:
    return sorted(
        path for path in root.rglob("*.md")
        if not any(part in SKIP_DIRS for part in path.relative_to(root).parts)
        and not path.name.endswith(".pyc")
    )


def slugify_heading(text: str) -> str:
    text = re.sub(r"!?\[([^\]]+)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"\[([^\]]+)\]\[[^]]*\]", r"\1", text)
    text = re.sub(r"<[^>]+>", "", text)
    text = text.replace("`", "")
    text = text.lower().strip()
    chars = []
    for char in text:
        category = unicodedata.category(char)
        if char.isspace():
            chars.append("-")
        elif char in "-_" or category[0] in {"L", "N", "M"}:
            chars.append(char)
    slug = re.sub(r"-+", "-", "".join(chars)).strip("-")
    return slug


def anchors_for(text: str) -> set[str]:
    anchors: set[str] = set()
    counts: Counter[str] = Counter()
    for line in text.splitlines():
        match = HEADING_RE.match(line)
        if match:
            base = slugify_heading(match.group(2))
            index = counts[base]
            counts[base] += 1
            anchors.add(base if index == 0 else f"{base}-{index}")
        anchors.update(HTML_ID_RE.findall(line))
    return anchors


def mask_code(text: str) -> str:
    """Blank fenced and inline code while preserving line numbers and offsets."""
    output: list[str] = []
    in_fence = False
    fence_char = ""
    fence_size = 0
    for line in text.splitlines(keepends=True):
        fence = re.match(r"^\s{0,3}(`{3,}|~{3,})", line)
        if not in_fence and fence:
            in_fence = True
            fence_char = fence.group(1)[0]
            fence_size = len(fence.group(1))
            output.append(re.sub(r"[^\n]", " ", line))
            continue
        if in_fence:
            output.append(re.sub(r"[^\n]", " ", line))
            if re.match(r"^\s{0,3}" + re.escape(fence_char) + r"{" + str(fence_size) + r",}\s*$", line.rstrip("\n")):
                in_fence = False
            continue
        output.append(re.sub(r"`+[^\n`]*`+", lambda match: re.sub(r"[^\n]", " ", match.group()), line))
    return "".join(output)


def parse_links(text: str):
    masked = mask_code(text)
    patterns = (LINK_RE, REFERENCE_RE,
                re.compile(r"<(https?://[^\s>]+)>"),
                re.compile(r"""<a\b[^>]*\bhref\s*=\s*["']([^"']+)["']""", re.I))
    matches = []
    for pattern in patterns:
        matches.extend(pattern.finditer(masked))
    for match in sorted(matches, key=lambda item: item.start()):
        target = next((group for group in match.groups() if group), "")
        if target:
            yield masked.count("\n", 0, match.start()) + 1, target


def external_result(url: str, timeout: float) -> tuple[str, str]:
    request = Request(url, method="HEAD", headers={"User-Agent": "Naqra-Markdown-Link-Audit/1.0"})
    try:
        with urlopen(request, timeout=timeout) as response:
            final = response.geturl()
            return ("redirect" if final != url else "reachable", final)
    except HTTPError as error:
        if error.code in {403, 405, 501}:
            try:
                request = Request(url, method="GET", headers={"User-Agent": "Naqra-Markdown-Link-Audit/1.0"})
                with urlopen(request, timeout=timeout) as response:
                    final = response.geturl()
                    return ("redirect" if final != url else "reachable", final)
            except Exception as retry_error:
                return "unverifiable", str(retry_error)
        return "broken", f"HTTP {error.code}"
    except (URLError, TimeoutError, OSError) as error:
        return "unverifiable", str(error)


def audit(root: Path, check_external: bool = True, timeout: float = 8.0) -> list[dict[str, object]]:
    root = root.resolve()
    files = markdown_files(root)
    contents = {path: path.read_text(encoding="utf-8", errors="replace") for path in files}
    by_name: dict[str, list[Path]] = {}
    for path in files:
        by_name.setdefault(path.name.casefold(), []).append(path)

    results: list[dict[str, object]] = []
    checked_external: dict[str, tuple[str, str]] = {}
    for source, text in contents.items():
        for line, target in parse_links(text):
            parsed = urlsplit(target)
            if parsed.scheme.lower() in {"http", "https"}:
                if not check_external:
                    status, detail = "unverified-external", "network checks disabled"
                else:
                    request_url = urlunsplit((parsed.scheme, parsed.netloc, parsed.path, parsed.query, ""))
                    if target not in checked_external:
                        checked_external[target] = external_result(request_url, timeout)
                    status, detail = checked_external[target]
                if status != "reachable":
                    results.append({"status": status, "source": str(source.relative_to(root)), "line": line, "url": target, "action": detail})
                continue
            if parsed.scheme or target.startswith("//") or target.startswith("mailto:"):
                continue

            raw_path = unquote(parsed.path)
            destination = (source.parent / raw_path).resolve() if raw_path else source.resolve()
            if raw_path.startswith("/"):
                destination = (root / raw_path.lstrip("/")).resolve()
            if destination.is_dir():
                candidates = [destination / "README.md", destination / "index.md"]
                destination = next((candidate for candidate in candidates if candidate.is_file()), destination)

            if not destination.is_file():
                matches = by_name.get(Path(raw_path).name.casefold(), []) if raw_path else []
                if len(matches) == 1:
                    status = "moved"
                    action = str(matches[0].relative_to(root))
                elif source.name.startswith("bundle-") and raw_path:
                    # Bundles aggregate upstream skill files; relative links may
                    # retain their original directory context, which is not encoded
                    # in the flattened bundle. Report rather than silently discard.
                    status = "unresolved-bundle-reference"
                    action = "upstream relative path context is absent; inspect source skill or restore the referenced file"
                else:
                    status = "missing"
                    action = "repair or remove the target"
                results.append({"status": status, "source": str(source.relative_to(root)), "line": line, "url": target, "action": action})
                continue

            if parsed.fragment:
                target_text = contents.get(destination)
                if target_text is None:
                    target_text = destination.read_text(encoding="utf-8", errors="replace")
                fragment = unquote(parsed.fragment)
                if fragment not in anchors_for(target_text):
                    results.append({"status": "broken-anchor", "source": str(source.relative_to(root)), "line": line, "url": target, "action": f"verify heading/id '{fragment}'"})

    return results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=None)
    parser.add_argument("--no-network", action="store_true", help="classify external URLs without making requests")
    parser.add_argument("--timeout", type=float, default=8.0)
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    args = parser.parse_args()
    root = args.root.resolve() if args.root else Path(__file__).resolve().parents[3]
    results = audit(root, check_external=not args.no_network, timeout=args.timeout)
    if args.json:
        print(json.dumps(results, ensure_ascii=False, indent=2))
    else:
        counts = Counter(item["status"] for item in results)
        print(f"Markdown files: {len(markdown_files(root))}")
        print(f"Link issues: {len(results)}")
        for status, count in sorted(counts.items()):
            print(f"{status}: {count}")
        for item in results:
            print("{status}: {source}:{line} -> {url} | action: {action}".format(**item))
    return 1 if any(item["status"] in {"missing", "broken-anchor", "broken"} for item in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
