#!/usr/bin/env python3
"""Check the repository's skill index, active manifests, and bundle references."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

COUNTS = {
    "Active skill files": "packs",
    "Integrated bundle files": "bundles",
    "Resource archives": "archives",
    "Visible files inside `skills/`": "visible",
}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=None, help="repository root (default: inferred from this script)")
    args = parser.parse_args()
    root = args.root.resolve() if args.root else Path(__file__).resolve().parents[3]
    index = root / "SKILLS.md"
    skills_root = root / "skills"
    errors: list[str] = []

    def fail(message: str) -> None:
        errors.append(message)
        print(f"FAIL: {message}")

    if not index.is_file() or not skills_root.is_dir():
        print("FAIL: run from a repository containing SKILLS.md and skills/", file=sys.stderr)
        return 2
    index_text = index.read_text(encoding="utf-8")
    agents_path = root / "AGENTS.md"
    agents_text = agents_path.read_text(encoding="utf-8") if agents_path.is_file() else ""
    for phrase in ("اختيار المهارة المناسبة", "قراءة ملف `SKILL.md`", "اقرأ `SKILLS.md`", "تنفيذ السكربتات الموجودة"):
        if phrase not in agents_text:
            fail(f"AGENTS.md does not require skill routing step: {phrase}")
    packs = sorted(path for path in skills_root.iterdir() if path.is_dir())
    bundle_files = list(skills_root.rglob("bundle-*.md"))
    archives = list(skills_root.rglob("resources.tar.gz"))
    visible_files = [path for path in skills_root.rglob("*") if path.is_file()]
    actual_counts = {"packs": len(packs), "bundles": len(bundle_files), "archives": len(archives), "visible": len(visible_files)}

    for label, key in COUNTS.items():
        match = re.search(rf"(?:\*\*)?{re.escape(label)}:(?:\*\*)?\s*(\d+)", index_text)
        if not match:
            fail(f"SKILLS.md is missing count '{label}'")
        elif int(match.group(1)) != actual_counts[key]:
            fail(f"{label} says {match.group(1)} but filesystem has {actual_counts[key]}")

    for target in re.findall(r"\]\(([^)]+)\)", index_text):
        if target.startswith(("http://", "https://", "#")):
            continue
        if not (root / target).is_file():
            fail(f"broken skill index link: {target}")

    names: set[str] = set()
    for pack in packs:
        manifest = pack / "SKILL.md"
        if not manifest.is_file():
            fail(f"missing manifest: {manifest.relative_to(root)}")
            continue
        text = manifest.read_text(encoding="utf-8")
        frontmatter = re.match(r"^---\n(.*?)\n---\s*", text, re.S)
        if not frontmatter:
            fail(f"invalid frontmatter: {manifest.relative_to(root)}")
            continue
        name = re.search(r"(?m)^name:\s*([a-z0-9-]+)\s*$", frontmatter.group(1))
        description = re.search(r"(?m)^description:\s*(.+)$", frontmatter.group(1))
        if not name or name.group(1) != pack.name:
            fail(f"skill name must match directory: {manifest.relative_to(root)}")
        elif name.group(1) in names:
            fail(f"duplicate skill name: {name.group(1)}")
        else:
            names.add(name.group(1))
        if not description or len(description.group(1).strip("\"' ")) < 30:
            fail(f"skill description is missing or too short: {manifest.relative_to(root)}")
        if "references/source/" in text:
            fail(f"stale references/source path: {manifest.relative_to(root)}")
        for target in re.findall(r"\]\(([^)]+)\)", text):
            if target.startswith(("http://", "https://", "#")):
                continue
            if not (pack / target).is_file():
                fail(f"broken relative link in {manifest.relative_to(root)}: {target}")
        for number in re.findall(r"bundle-(\d+)\.md", text):
            target = pack / "references" / f"bundle-{number}.md"
            if not target.is_file():
                fail(f"missing bundle {target.relative_to(root)} referenced by {manifest.relative_to(root)}")

    for label, key in COUNTS.items():
        print(f"INFO: {label}: {actual_counts[key]}")
    if errors:
        print(f"\n{len(errors)} skill-routing check(s) failed.", file=sys.stderr)
        return 1
    print("All skill-routing checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
