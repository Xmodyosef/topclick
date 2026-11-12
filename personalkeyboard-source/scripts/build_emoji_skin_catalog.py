#!/usr/bin/env python3
"""Collapse Fitzpatrick skin-tone variants in emoji_catalog.json and emit emoji_skin_map.json.

Run from repo root or personalkeyboard-source:
  python3 scripts/build_emoji_skin_catalog.py

Does not run inside the keyboard extension. Regenerates Resources only.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

MODS = ["\U0001F3FB", "\U0001F3FC", "\U0001F3FD", "\U0001F3FE", "\U0001F3FF"]


def strip_skin(s: str) -> str:
    for m in MODS:
        s = s.replace(m, "")
    return s


def has_skin(s: str) -> bool:
    return any(m in s for m in MODS)


def primary_mod(s: str) -> str | None:
    for m in MODS:
        if m in s:
            return m
    return None


def build(catalog: list) -> tuple[list, dict[str, list[str]], dict]:
    global_forms: dict[str, set[str]] = {}
    new_catalog: list[dict] = []

    for cat in catalog:
        icon = cat.get("icon") or "😀"
        items = cat.get("items") or []
        bases_order: list[str] = []
        seen_base: set[str] = set()
        for e in items:
            if not e or not isinstance(e, str):
                continue
            base = strip_skin(e)
            if not base:
                continue
            global_forms.setdefault(base, set()).add(e)
            if base not in seen_base:
                seen_base.add(base)
                bases_order.append(base)
        new_catalog.append({"icon": icon, "items": bases_order})

    skin_map: dict[str, list[str]] = {}
    for base, forms in global_forms.items():
        skinned = [f for f in forms if has_skin(f)]
        if not skinned:
            continue
        base_form = base
        tones = [base_form]
        for m in MODS:
            candidate = None
            simple = base_form + m
            if simple in forms:
                candidate = simple
            else:
                matches = [f for f in forms if strip_skin(f) == base and primary_mod(f) == m]
                if matches:
                    matches.sort(key=lambda x: (sum(x.count(mm) for mm in MODS), len(x)))
                    candidate = matches[0]
                elif "\u200d" not in base_form:
                    candidate = base_form + m
            if candidate and candidate not in tones:
                tones.append(candidate)
        if len(tones) >= 2:
            skin_map[base_form] = tones

    ordered: dict[str, list[str]] = {}
    for cat in new_catalog:
        for b in cat["items"]:
            if b in skin_map and b not in ordered:
                ordered[b] = skin_map[b]
    for k, v in skin_map.items():
        if k not in ordered:
            ordered[k] = v

    stats = {
        "categories": len(new_catalog),
        "items_after": sum(len(c["items"]) for c in new_catalog),
        "skin_keys": len(ordered),
        "skinned_left": sum(1 for c in new_catalog for e in c["items"] if has_skin(e)),
    }
    return new_catalog, ordered, stats


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--resources",
        type=Path,
        default=Path(__file__).resolve().parents[1] / "KeyboardExtension" / "Resources",
    )
    args = ap.parse_args()
    resources: Path = args.resources
    # Prefer the uncollapsed source next to this script (not embedded in the appex).
    full = Path(__file__).resolve().parent / "emoji_data" / "emoji_catalog.full.json"
    src = full if full.is_file() else resources / "emoji_catalog.json"
    catalog = json.loads(src.read_text(encoding="utf-8"))
    if not isinstance(catalog, list):
        raise SystemExit("emoji_catalog.json must be a list of categories")
    before = sum(len(c.get("items") or []) for c in catalog)
    new_catalog, skin_map, stats = build(catalog)
    (resources / "emoji_catalog.json").write_text(
        json.dumps(new_catalog, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    (resources / "emoji_skin_map.json").write_text(
        json.dumps(skin_map, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    print(f"before_items={before} after_items={stats['items_after']} skin_keys={stats['skin_keys']} skinned_left={stats['skinned_left']}")
    if stats["skinned_left"] != 0:
        raise SystemExit("catalog still contains skin-tone modifiers")
    if "👋" not in skin_map or len(skin_map["👋"]) < 2:
        raise SystemExit("skin map missing wave tones")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
