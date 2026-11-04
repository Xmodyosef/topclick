#!/usr/bin/env python3
"""Create an immutable baseline manifest and inspect every resource archive."""
from __future__ import annotations

import hashlib
import json
import subprocess
import tarfile
import tempfile
from pathlib import Path

BASELINE_COMMIT = "8cec58ffc14f62acb24633edc7e3cce1031cdd1f"
MAIN_SUFFIXES = {".swift", ".plist", ".entitlements", ".yml", ".yaml", ".py", ".md"}
ROOT_MAIN = {"AGENTS.md", "SKILLS.md", "README.md", "LESSONS_LEARNED.md"}

def git(*args: str) -> bytes:
    return subprocess.check_output(["git", *args])

def main() -> None:
    rows = []
    listing = git("ls-tree", "-r", "-l", "--full-tree", BASELINE_COMMIT).decode()
    for line in listing.splitlines():
        meta, path = line.split("\t", 1)
        mode, kind, blob, size = meta.split()
        rows.append({"path": path, "mode": mode, "type": kind, "blob_sha": blob, "size": int(size)})

    main_files = []
    for row in rows:
        path = row["path"]
        p = Path(path)
        is_main = (
            path in ROOT_MAIN
            or path.startswith(".github/")
            or (path.startswith("personalkeyboard-source/") and p.suffix.lower() in MAIN_SUFFIXES)
            or (path.startswith("skills/") and (p.name == "SKILL.md" or ("/scripts/" in path and p.suffix == ".py")))
        )
        if is_main:
            content = git("show", f"{BASELINE_COMMIT}:{path}")
            main_files.append({**row, "sha256": hashlib.sha256(content).hexdigest()})

    archives = []
    for row in rows:
        if not row["path"].endswith("resources.tar.gz"):
            continue
        raw = git("show", f'{BASELINE_COMMIT}:{row["path"]}')
        members = []
        with tempfile.NamedTemporaryFile(suffix=".tar.gz") as tmp:
            tmp.write(raw)
            tmp.flush()
            with tarfile.open(tmp.name, "r:gz") as archive:
                for member in archive.getmembers():
                    members.append({
                        "name": member.name,
                        "type": "directory" if member.isdir() else "file" if member.isfile() else "other",
                        "size": member.size,
                    })
        archives.append({
            "path": row["path"],
            "blob_sha": row["blob_sha"],
            "sha256": hashlib.sha256(raw).hexdigest(),
            "size": len(raw),
            "members": members,
        })

    manifest = {
        "baseline_commit": BASELINE_COMMIT,
        "baseline_tree": git("rev-parse", f"{BASELINE_COMMIT}^{{tree}}").decode().strip(),
        "total_files": len(rows),
        "files": rows,
        "main_file_sha256": main_files,
        "resource_archives": archives,
    }
    out = Path("remediation-baseline")
    out.mkdir(exist_ok=True)
    (out / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
    lines = [
        "# Remediation Baseline",
        "",
        f"- Baseline commit: `{manifest['baseline_commit']}`",
        f"- Baseline tree: `{manifest['baseline_tree']}`",
        f"- Files captured: {len(rows)}",
        f"- Main files with SHA-256: {len(main_files)}",
        f"- Resource archives inventoried: {len(archives)}",
        "",
        "## Main-file SHA-256",
        "",
        "| Path | SHA-256 |",
        "|---|---|",
    ]
    lines.extend(f"| `{x['path']}` | `{x['sha256']}` |" for x in main_files)
    lines += ["", "## Resource archive inventory", ""]
    for archive in archives:
        lines += [
            f"### `{archive['path']}`",
            f"- SHA-256: `{archive['sha256']}`",
            f"- Members: {len(archive['members'])}",
        ]
        lines.extend(f"  - `{m['name']}` ({m['type']}, {m['size']} bytes)" for m in archive["members"])
        lines.append("")
    (out / "baseline-report.md").write_text("\n".join(lines) + "\n")
    print(f"Baseline created: {len(rows)} files, {len(main_files)} SHA-256 entries, {len(archives)} archives.")

if __name__ == "__main__":
    main()
