from __future__ import annotations

import importlib.util
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "skills/skill-routing-integrity/scripts/verify_markdown_links.py"
SPEC = importlib.util.spec_from_file_location("verify_markdown_links", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)


def test_heading_slug_and_duplicate_anchors() -> None:
    assert MODULE.slugify_heading("Hello, World!") == "hello-world"
    assert MODULE.anchors_for("# Repeated\n# Repeated\n## Mixed عربى") == {
        "repeated", "repeated-1", "mixed-عربى"
    }


def test_local_links_classify_missing_moved_and_bad_anchor(tmp_path: Path) -> None:
    docs = tmp_path / "docs"
    docs.mkdir()
    (docs / "one.md").write_text(
        "[ok](two.md#section) [missing](absent.md) [bad](two.md#nope) [moved](old.md)\n"
        "[external](https://example.com/path)\n",
        encoding="utf-8",
    )
    (docs / "two.md").write_text("# Section\n", encoding="utf-8")
    legacy = tmp_path / "archive"
    legacy.mkdir()
    (legacy / "old.md").write_text("# Old\n", encoding="utf-8")
    (tmp_path / "__pycache__").mkdir()
    (tmp_path / "__pycache__" / "ignored.md").write_text("[x](absent.md)", encoding="utf-8")

    results = MODULE.audit(tmp_path, check_external=False)
    statuses = [item["status"] for item in results]
    assert "missing" in statuses
    assert "moved" in statuses
    assert "broken-anchor" in statuses
    assert "unverified-external" in statuses
    assert all("ignored.md" not in str(item) for item in results)


def test_fragment_only_link_checks_current_file(tmp_path: Path) -> None:
    (tmp_path / "page.md").write_text("# Local\n[here](#local)\n", encoding="utf-8")
    assert MODULE.audit(tmp_path, check_external=False) == []


def test_flattened_bundle_context_is_reported_without_false_missing(tmp_path: Path) -> None:
    refs = tmp_path / "skills" / "sample" / "references"
    refs.mkdir(parents=True)
    (refs / "bundle-01.md").write_text("[upstream](references/original.md)\n", encoding="utf-8")
    results = MODULE.audit(tmp_path, check_external=False)
    assert len(results) == 1
    assert results[0]["status"] == "unresolved-bundle-reference"
