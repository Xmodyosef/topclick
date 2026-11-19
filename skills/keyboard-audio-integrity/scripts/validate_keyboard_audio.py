#!/usr/bin/env python3
"""Validate CAF chunk structure and the keyboard sound asset pipeline."""
from __future__ import annotations

import argparse
import json
import math
import re
import struct
import sys
from pathlib import Path


class CAFError(ValueError):
    pass


def parse_caf(path: Path) -> dict:
    data = path.read_bytes()
    if len(data) < 8 or data[:4] != b"caff":
        raise CAFError("missing CAF file header")
    version, file_flags = struct.unpack(">HH", data[4:8])
    if version != 1 or file_flags != 0:
        raise CAFError(f"unsupported CAF header version={version} flags={file_flags}")

    offset = 8
    chunks: dict[str, list[bytes]] = {}
    while offset < len(data):
        if offset + 12 > len(data):
            raise CAFError("truncated chunk header")
        chunk_type = data[offset:offset + 4].decode("ascii", errors="replace")
        chunk_size = struct.unpack(">q", data[offset + 4:offset + 12])[0]
        offset += 12
        if chunk_size == -1:
            payload = data[offset:]
            offset = len(data)
        elif chunk_size < 0 or offset + chunk_size > len(data):
            raise CAFError(f"invalid {chunk_type!r} chunk size {chunk_size}")
        else:
            payload = data[offset:offset + chunk_size]
            offset += chunk_size
        chunks.setdefault(chunk_type, []).append(payload)
        if chunk_size == -1 and offset != len(data):
            raise CAFError("unknown-size chunk must end the file")

    if not chunks or next(iter(chunks)) != "desc":
        raise CAFError("CAF desc chunk must be the first chunk after the file header")
    if len(chunks.get("desc", [])) != 1 or len(chunks.get("data", [])) != 1:
        raise CAFError("keyboard CAF requires exactly one desc and one data chunk")
    desc = chunks["desc"][0]
    if len(desc) < 32:
        raise CAFError("desc chunk is shorter than CAFAudioFormat")
    sample_rate, format_id, format_flags, bytes_per_packet, frames_per_packet, channels, bits = struct.unpack(
        ">d4sIIIII", desc[:32]
    )
    if format_id != b"lpcm":
        raise CAFError(f"expected lpcm, found {format_id!r}")
    if not math.isfinite(sample_rate) or sample_rate <= 0:
        raise CAFError("invalid sample rate")
    if channels < 1 or bits < 1 or frames_per_packet < 1 or bytes_per_packet < 1:
        raise CAFError("invalid PCM packet geometry")
    if format_flags & ~0x3:
        raise CAFError(f"reserved CAF LPCM flag bits set: 0x{format_flags:x}")
    is_float = bool(format_flags & 0x1)
    is_little_endian = bool(format_flags & 0x2)
    # Naqra click assets use mono, signed-integer, 16-bit, little-endian LPCM.
    # CAF flags are not the wider AudioStreamBasicDescription flag bitfield.
    if is_float or not is_little_endian:
        raise CAFError("keyboard click assets must be signed-integer little-endian PCM")
    if (channels, bits, frames_per_packet, bytes_per_packet) != (1, 16, 1, 2):
        raise CAFError("keyboard click assets must use mono 16-bit LPCM with 2-byte packets")

    audio_chunk = chunks["data"][0]
    if len(audio_chunk) < 4:
        raise CAFError("data chunk is missing its edit-count field")
    edit_count = struct.unpack(">I", audio_chunk[:4])[0]
    audio_bytes = len(audio_chunk) - 4
    if audio_bytes <= 0 or audio_bytes % bytes_per_packet:
        raise CAFError("audio payload is empty or not aligned to complete packets")
    frame_count = (audio_bytes // bytes_per_packet) * frames_per_packet
    return {
        "path": str(path),
        "bytes": len(data),
        "sample_rate": sample_rate,
        "format_id": "lpcm",
        "format_flags": format_flags,
        "is_float": is_float,
        "is_little_endian": is_little_endian,
        "channels": channels,
        "bits_per_channel": bits,
        "bytes_per_packet": bytes_per_packet,
        "frames_per_packet": frames_per_packet,
        "edit_count": edit_count,
        "audio_bytes": audio_bytes,
        "frame_count": frame_count,
        "duration_seconds": frame_count / sample_rate,
    }


def sound_mappings(sound_source: str) -> dict[str, str]:
    block = re.search(r"sampleAssets[^\n=]*=\s*\[(.*?)\]", sound_source, re.S)
    if not block:
        raise ValueError("could not locate TapSoundEngine.sampleAssets")
    return dict(re.findall(r'"([A-Za-z0-9_-]+)"\s*:\s*"([A-Za-z0-9_-]+)"', block.group(1)))


def validate(source: Path, built_appex: Path | None = None) -> dict:
    engine = source / "KeyboardExtension/Sources/Features/TapSoundEngine.swift"
    project = source / "project.yml"
    resources = source / "KeyboardExtension/Resources"
    for required in (engine, project, resources):
        if not required.exists():
            raise FileNotFoundError(f"required audio pipeline path missing: {required}")
    engine_text = engine.read_text(encoding="utf-8")
    mappings = sound_mappings(engine_text)
    project_text = project.read_text(encoding="utf-8")
    assets = []
    errors = []
    # Extension-safe playback contract (Apple AudioServices ≤30s; Signal caches SystemSoundID).
    if any(token in engine_text for token in ("AVAudioEngine", "AVAudioPlayerNode", "scheduleBuffer")):
        errors.append("TapSoundEngine must not use AVAudioEngine/AVAudioPlayerNode/scheduleBuffer")
    if "AudioServicesCreateSystemSoundID" not in engine_text or "AudioServicesPlaySystemSound" not in engine_text:
        errors.append("TapSoundEngine must use AudioServicesCreateSystemSoundID + AudioServicesPlaySystemSound")
    if "AudioServicesDisposeSystemSoundID" not in engine_text:
        errors.append("TapSoundEngine should dispose SystemSoundIDs to avoid leaks across extension reloads")
    if "maximumPendingPlayRequests" not in engine_text:
        errors.append("TapSoundEngine should bound pending play requests (queue cap)")
    if "func configure(" not in engine_text:
        errors.append("TapSoundEngine needs configure(...) so preferences can refresh without killing the host app")
    for choice, asset in sorted(mappings.items()):
        relative = f"KeyboardExtension/Resources/{asset}.caf"
        source_asset = resources / f"{asset}.caf"
        if not source_asset.is_file():
            errors.append(f"{choice} maps to missing {relative}")
            continue
        if relative not in project_text:
            errors.append(f"{relative} is not registered in project.yml")
        try:
            info = parse_caf(source_asset)
            info["choice"] = choice
            assets.append(info)
            # Apple: system sounds should be short; reject clearly oversized assets.
            if info["duration_seconds"] > 30.0:
                errors.append(f"{relative}: duration {info['duration_seconds']:.3f}s exceeds AudioServices 30s limit")
            elif info["duration_seconds"] > 5.0:
                errors.append(f"{relative}: duration {info['duration_seconds']:.3f}s is long for a key click (prefer ≤5s)")
            if info.get("sample_rate", 0) and info["sample_rate"] not in (22050.0, 24000.0, 32000.0, 44100.0, 48000.0):
                # soft finding — unusual rate still playable
                pass
        except (OSError, CAFError) as error:
            errors.append(f"{relative}: {error}")
            continue
        if built_appex is not None and not (built_appex / f"{asset}.caf").is_file():
            errors.append(f"built extension is missing {asset}.caf")
    return {
        "status": "findings" if errors else "pass",
        "mapped_sound_count": len(mappings),
        "validated_asset_count": len(assets),
        "assets": assets,
        "errors": errors,
        "device_playback_verified": False,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="personalkeyboard-source directory")
    parser.add_argument("--built-appex", type=Path, help="optional built KeyboardExtension.appex directory")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--strict", action="store_true", help="return non-zero when asset issues are found")
    args = parser.parse_args()
    try:
        report = validate(args.source.resolve(), args.built_appex.resolve() if args.built_appex else None)
    except (OSError, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2
    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print(f"Audio integrity: {report['status']} — {report['validated_asset_count']}/{report['mapped_sound_count']} assets")
        for asset in report["assets"]:
            print(
                f"PASS {asset['choice']}: {asset['sample_rate']:g} Hz, "
                f"{asset['channels']} ch, {asset['bits_per_channel']} bit, "
                f"flags=0x{asset['format_flags']:x}, {asset['duration_seconds']:.3f}s"
            )
        for error in report["errors"]:
            label = "FAIL" if args.strict else "FINDING"
            print(f"{label}: {error}")
        print("Physical-device playback: NOT VERIFIED")
    return 1 if args.strict and report["errors"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
