"""Contract tests for emoji catalog, skin map, EmojiCell presence, and symbol pages.

Scope locked 2026-11-19. Do not widen without owner sign-off.

Checked:
- emoji_catalog.json: parses; exactly 9 categories; no empty category;
  no duplicate category icon.
- emoji_skin_map.json: parses; exactly 313 keys; every key is a base emoji
  that appears in some category's items; every value is a non-empty list
  whose first element equals the base.
- EmojiCell.swift: exists and declares `final class EmojiCell`. Presence only.
- KeyboardSymbolCatalog.swift: arabic and english each have two pages, and
  in each page the last row is shorter than the rows above it.

NOT checked:
- every symbol unique across the keyboard (# and _ repeat on purpose)
- key order or grid density
- RTL/LTR correctness from a text scan
"""
from __future__ import annotations

import json
import re
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "personalkeyboard-source"


def _find(name: str) -> Path:
    matches = [path for path in SOURCE.rglob(name) if path.is_file()]
    if len(matches) != 1:
        pytest.fail(f"expected exactly one {name}, found {matches}")
    return matches[0]


def _categories() -> list[dict]:
    raw = json.loads(_find("emoji_catalog.json").read_text(encoding="utf-8"))
    if not isinstance(raw, list):
        pytest.fail("emoji_catalog.json must be a list of categories")
    return raw


def _category_items(category: dict) -> list[str]:
    items = category.get("items", [])
    if not isinstance(items, list) or not all(isinstance(item, str) for item in items):
        pytest.fail(f"category {category.get('icon')!r} items must be a list of strings")
    return items


def test_emoji_catalog_structure() -> None:
    categories = _categories()
    assert len(categories) == 9, f"expected 9 categories, got {len(categories)}"
    icons: list[str] = []
    for category in categories:
        icon = category.get("icon")
        assert isinstance(icon, str) and icon, f"category missing icon: {category!r}"
        icons.append(icon)
        assert _category_items(category), f"category {icon!r} is empty"
    assert len(icons) == len(set(icons)), "duplicate category icon"


def test_emoji_skin_map_keys_are_bases() -> None:
    present: set[str] = set()
    for category in _categories():
        present.update(_category_items(category))

    skin_map = json.loads(_find("emoji_skin_map.json").read_text(encoding="utf-8"))
    assert isinstance(skin_map, dict), "emoji_skin_map.json must be an object"
    assert len(skin_map) == 313, f"expected 313 skin keys, got {len(skin_map)}"

    for base, tones in skin_map.items():
        assert base in present, f"skin base not present in any category: {base!r}"
        assert isinstance(tones, list) and tones, f"skin list empty for {base!r}"
        assert tones[0] == base, f"skin list for {base!r} does not start with the base"


def test_emoji_cell_present() -> None:
    source = _find("EmojiCell.swift").read_text(encoding="utf-8")
    assert re.search(r"\bfinal\s+class\s+EmojiCell\b", source), (
        "EmojiCell.swift does not declare final class EmojiCell"
    )


def _matching_bracket(source: str, open_at: int) -> str:
    """Return the `[...]` slice starting at open_at, respecting Swift strings."""
    depth = 0
    i = open_at
    in_string = False
    escaped = False
    while i < len(source):
        char = source[i]
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
        else:
            if char == '"':
                in_string = True
            elif char == "[":
                depth += 1
            elif char == "]":
                depth -= 1
                if depth == 0:
                    return source[open_at:i + 1]
        i += 1
    pytest.fail("unclosed Swift array while parsing KeyboardSymbolCatalog.swift")


def _quoted(blob: str) -> list[str]:
    return re.findall(r'"(?:[^"\\]|\\.)*"', blob)


def _symbol_pages(source: str, symbol_name: str) -> list[list[list[str]]]:
    """Parse `static let <name>: [[[String]]] = [ page, page ]`."""
    marker = f"static let {symbol_name}: [[[String]]] = "
    start = source.find(marker)
    if start < 0:
        pytest.fail(f"could not locate {symbol_name} in KeyboardSymbolCatalog.swift")
    open_at = source.find("[", start + len(marker) - 1)
    outer = _matching_bracket(source, open_at)
    # outer is [ page, page ]; each page is [ row, row, ... ]
    pages: list[list[list[str]]] = []
    index = 1
    while index < len(outer) - 1:
        if outer[index] == "[":
            page_blob = _matching_bracket(outer, index)
            rows: list[list[str]] = []
            row_index = 1
            while row_index < len(page_blob) - 1:
                if page_blob[row_index] == "[":
                    row_blob = _matching_bracket(page_blob, row_index)
                    rows.append(_quoted(row_blob))
                    row_index += len(row_blob)
                    continue
                row_index += 1
            pages.append(rows)
            index += len(page_blob)
            continue
        index += 1
    return pages


def test_symbol_pages_two_last_row_shorter() -> None:
    source = _find("KeyboardSymbolCatalog.swift").read_text(encoding="utf-8")
    for symbol_name in ("builtinArabicSymbols", "builtinEnglishSymbols"):
        pages = _symbol_pages(source, symbol_name)
        assert len(pages) == 2, f"{symbol_name}: expected 2 pages, got {len(pages)}"
        for page_index, rows in enumerate(pages, start=1):
            assert len(rows) >= 2, f"{symbol_name} page {page_index} has fewer than 2 rows"
            sizes = [len(row) for row in rows]
            assert all(size > 0 for size in sizes), f"{symbol_name} page {page_index} has an empty row"
            assert sizes[-1] < min(sizes[:-1]), (
                f"{symbol_name} page {page_index}: last row has {sizes[-1]} cells, "
                f"not shorter than every row above {sizes[:-1]}"
            )
