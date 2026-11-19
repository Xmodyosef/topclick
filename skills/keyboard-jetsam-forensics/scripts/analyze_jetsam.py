#!/usr/bin/env python3
"""Extract evidence from iOS JetsamEvent JSON or a legacy text report.

Keeps rpages as page counts unless --page-size is supplied (never invent MiB).
Flags reason values such as per-process-limit for keyboard extensions.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


PROCESS_NAME_KEYS = ("name", "procName", "processName", "command", "process")
REASON_KEYS = ("reason", "terminationReason", "killReason")


def walk(value: Any):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)


def parse_json_event(document: Any, target: str) -> dict:
    matches = []
    for item in walk(document):
        names = [str(item.get(key, "")) for key in PROCESS_NAME_KEYS if item.get(key) is not None]
        if any(target.casefold() in name.casefold() for name in names):
            if any(key in item for key in ("rpages", "lifetimeMax", *REASON_KEYS)):
                matches.append(item)
    if not matches:
        raise ValueError(f"no process record matching {target!r} with memory/termination fields")
    process = max(matches, key=lambda item: int(item.get("rpages", 0) or 0))
    metadata = document if isinstance(document, dict) else {}
    return {
        "format": "json",
        "target_process": target,
        "matched_process": next(
            (str(process.get(key)) for key in PROCESS_NAME_KEYS if process.get(key) is not None),
            target,
        ),
        "timestamp": metadata.get("timestamp") or metadata.get("captureTime"),
        "model": metadata.get("modelCode") or metadata.get("model"),
        "os_version": metadata.get("os_version") or metadata.get("osVersion"),
        "reason": next((process.get(key) for key in REASON_KEYS if process.get(key) is not None), None),
        "rpages": process.get("rpages"),
        "lifetimeMax": process.get("lifetimeMax"),
        "states": process.get("states"),
        "raw_fields": {
            key: process.get(key)
            for key in ("pid", "uuid", "coalition", "priority", "states", "rpages", "lifetimeMax")
            if key in process
        },
    }


def parse_text_event(text: str, target: str) -> dict:
    lines = text.splitlines()
    process_blocks: list[list[str]] = []
    current: list[str] = []
    for line in lines:
        if re.search(r"(?i)\b(?:process|procName|name)\s*[:=]", line):
            if current:
                process_blocks.append(current)
            current = [line]
        elif current:
            current.append(line)
    if current:
        process_blocks.append(current)
    matching = [
        block for block in process_blocks
        if any(target.casefold() in line.casefold() for line in block)
    ]
    block = matching[0] if matching else lines if target.casefold() in text.casefold() else []
    if not block:
        raise ValueError(f"no text section matching {target!r}")

    def value(pattern: str):
        match = re.search(pattern, "\n".join(block), re.I)
        return match.group(1).strip() if match else None

    rpages = value(r"\brpages\s*[:=]\s*([0-9]+)")
    lifetime = value(r"\blifetimeMax\s*[:=]\s*([0-9]+)")
    reason = value(r"\b(?:reason|terminationReason|killReason)\s*[:=]\s*([^\n]+)")
    process_name = value(r"\b(?:process|procName|name)\s*[:=]\s*([^\n]+)")
    return {
        "format": "text",
        "target_process": target,
        "matched_process": process_name or target,
        "timestamp": value(r"\b(?:timestamp|captureTime)\s*[:=]\s*([^\n]+)"),
        "model": value(r"\b(?:modelCode|model)\s*[:=]\s*([^\n]+)"),
        "os_version": value(r"\b(?:os_version|osVersion)\s*[:=]\s*([^\n]+)"),
        "reason": reason,
        "rpages": int(rpages) if rpages else None,
        "lifetimeMax": int(lifetime) if lifetime else None,
        "states": None,
        "raw_fields": {},
    }


def analyze(path: Path, target: str = "KeyboardExtension", page_size_bytes: int | None = None) -> dict:
    raw = path.read_text(encoding="utf-8", errors="replace")
    try:
        document = json.loads(raw)
        report = parse_json_event(document, target)
    except json.JSONDecodeError:
        report = parse_text_event(raw, target)
    report["page_size_bytes_supplied"] = page_size_bytes
    report["rpages_estimated_bytes"] = (
        int(report["rpages"]) * page_size_bytes
        if page_size_bytes is not None and report["rpages"] is not None
        else None
    )
    report["memory_estimate_label"] = (
        "estimate using explicitly supplied page size"
        if report["rpages_estimated_bytes"] is not None
        else "not calculated; page size not supplied"
    )
    report["root_cause_identified"] = False
    report["interpretation"] = (
        "Termination evidence only. Jetsam data does not identify the "
        "allocation site or prove which feature caused memory growth."
    )
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("report", type=Path, help="original JetsamEvent .ips or text log")
    parser.add_argument("--process", default="KeyboardExtension")
    parser.add_argument("--page-size-bytes", type=int, default=None)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    if args.page_size_bytes is not None and args.page_size_bytes <= 0:
        parser.error("--page-size-bytes must be positive")
    try:
        report = analyze(args.report, args.process, args.page_size_bytes)
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        for key in ("matched_process", "timestamp", "model", "os_version", "reason", "rpages", "lifetimeMax"):
            print(f"{key}: {report.get(key) if report.get(key) is not None else 'unknown'}")
        print(f"memory: {report['memory_estimate_label']}")
        if report["rpages_estimated_bytes"] is not None:
            print(f"rpages estimate: {report['rpages_estimated_bytes']} bytes")
        print(report["interpretation"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
