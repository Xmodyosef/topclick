from __future__ import annotations

import importlib.util
import json
import struct
import subprocess
import sys
from pathlib import Path

sys.dont_write_bytecode = True

ROOT = Path(__file__).resolve().parents[1]


def load_script(name: str, relative: str):
    path = ROOT / relative
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


audio = load_script(
    "validate_keyboard_audio",
    "skills/keyboard-audio-integrity/scripts/validate_keyboard_audio.py",
)
jetsam = load_script(
    "analyze_jetsam",
    "skills/keyboard-jetsam-forensics/scripts/analyze_jetsam.py",
)
language = load_script(
    "audit_language_switch",
    "skills/keyboard-language-switch-qa/scripts/audit_language_switch.py",
)
routing = load_script(
    "verify_skill_links",
    "skills/skill-routing-integrity/scripts/verify_skill_links.py",
)


def make_caf(path: Path, flags: int = 2, samples: bytes = b"\x00\x00\x01\x00\x02\x00\x03\x00") -> Path:
    header = b"caff" + struct.pack(">HH", 1, 0)
    desc = struct.pack(">d4sIIIII", 44100.0, b"lpcm", flags, 2, 1, 1, 16)
    desc_chunk = b"desc" + struct.pack(">q", len(desc)) + desc
    data_payload = struct.pack(">I", 0) + samples
    data_chunk = b"data" + struct.pack(">q", len(data_payload)) + data_payload
    path.write_bytes(header + desc_chunk + data_chunk)
    return path


def make_language_fixture(root: Path, primary_language: bool = True) -> Path:
    source = root / "personalkeyboard-source"
    input_dir = source / "KeyboardExtension/Sources/Input"
    lifecycle_dir = source / "KeyboardExtension/Sources/Lifecycle"
    input_dir.mkdir(parents=True)
    lifecycle_dir.mkdir(parents=True)
    primary = '        primaryLanguage = language == .arabic ? "ar" : "en"\n' if primary_language else ""
    (input_dir / "KeyboardViewController+Input.swift").write_text(
        "    func scheduleLanguageRebuild() {\n"
        "        guard !languageRebuildScheduled else { return }\n"
        "        languageRebuildScheduled = true\n"
        "        DispatchQueue.main.async { [weak self] in\n"
        "            guard let self else { return }\n"
        "            self.languageRebuildScheduled = false\n"
        "            self.rebuild()\n"
        "        }\n"
        "    }\n"
        "    func toggleLanguage() {\n"
        "        language = language == .arabic ? .english : .arabic\n"
        + primary +
        "        scheduleLanguageRebuild()\n"
        "    }\n"
        "    @objc func languageTapped() {\n"
        "        toggleLanguage()\n"
        "    }\n"
        "    @objc func spaceTouchUp() {\n"
        "        if shouldSwitch { textDocumentProxy.deleteBackward(); toggleLanguage() }\n"
        "    }\n"
        "    func suggestions() -> [String] {\n"
        "        let checker = textChecker\n"
        "        return checker.completions(forPartialWordRange: range, in: token, language: code) ?? []\n"
        "    }\n",
        encoding="utf-8",
    )
    (lifecycle_dir / "KeyboardViewController.swift").write_text(
        "    lazy var textChecker = UITextChecker()\n",
        encoding="utf-8",
    )
    return source


def test_caf_parser_accepts_caf_little_endian_integer_pcm(tmp_path: Path) -> None:
    report = audio.parse_caf(make_caf(tmp_path / "valid.caf", flags=2))
    assert report["format_id"] == "lpcm"
    assert report["is_little_endian"] is True
    assert report["is_float"] is False
    assert report["channels"] == 1
    assert report["bits_per_channel"] == 16
    assert report["duration_seconds"] > 0


def test_caf_parser_rejects_reserved_flags_instead_of_treating_as_asbd_flags(tmp_path: Path) -> None:
    path = make_caf(tmp_path / "invalid-flags.caf", flags=12)
    try:
        audio.parse_caf(path)
    except audio.CAFError as error:
        assert "reserved" in str(error)
    else:
        raise AssertionError("CAF reserved flag bits must be rejected")


def test_caf_parser_rejects_truncated_chunk(tmp_path: Path) -> None:
    path = make_caf(tmp_path / "truncated.caf")
    path.write_bytes(path.read_bytes()[:-3])
    try:
        audio.parse_caf(path)
    except audio.CAFError:
        pass
    else:
        raise AssertionError("truncated CAF data must be rejected")


def test_sound_mapping_parser_extracts_all_selectable_assets() -> None:
    mappings = audio.sound_mappings(
        'private static let sampleAssets: [String: String] = ['
        '"soft": "soft", "piano": "piano", "typewriter": "typewriter"'
        ']'
    )
    assert mappings == {"soft": "soft", "piano": "piano", "typewriter": "typewriter"}


def test_jetsam_json_preserves_process_termination_evidence(tmp_path: Path) -> None:
    event = {
        "timestamp": "2026-11-17 08:36:59 +0400",
        "modelCode": "iPhone12,5",
        "os_version": "iOS 18.7",
        "processes": [{
            "name": "KeyboardExtension",
            "rpages": 4928,
            "lifetimeMax": 4928,
            "reason": "per-process-limit",
            "states": ["frontmost"],
        }],
    }
    path = tmp_path / "JetsamEvent.ips"
    path.write_text(json.dumps(event), encoding="utf-8")
    report = jetsam.analyze(path)
    assert report["reason"] == "per-process-limit"
    assert report["rpages"] == 4928
    assert report["model"] == "iPhone12,5"
    assert report["rpages_estimated_bytes"] is None
    assert report["root_cause_identified"] is False


def test_jetsam_memory_conversion_requires_explicit_page_size(tmp_path: Path) -> None:
    path = tmp_path / "JetsamEvent.ips"
    path.write_text(json.dumps({
        "processes": [{
            "name": "KeyboardExtension",
            "rpages": 100,
            "reason": "per-process-limit",
        }]
    }), encoding="utf-8")
    report = jetsam.analyze(path, page_size_bytes=16384)
    assert report["rpages_estimated_bytes"] == 1_638_400
    assert "explicitly supplied" in report["memory_estimate_label"]


def test_jetsam_text_fallback_reads_legacy_fields(tmp_path: Path) -> None:
    path = tmp_path / "JetsamEvent.txt"
    path.write_text(
        "Process: KeyboardExtension\n"
        "rpages: 4928\n"
        "lifetimeMax: 4928\n"
        "reason: per-process-limit\n",
        encoding="utf-8",
    )
    report = jetsam.analyze(path)
    assert report["format"] == "text"
    assert report["rpages"] == 4928
    assert report["reason"] == "per-process-limit"


def test_language_switch_audit_passes_complete_transition_contract(tmp_path: Path) -> None:
    source = make_language_fixture(tmp_path)
    report = language.audit(source)
    assert report["status"] == "pass"
    assert report["finding_count"] == 0


def test_language_switch_audit_flags_missing_primary_language_sync(tmp_path: Path) -> None:
    source = make_language_fixture(tmp_path, primary_language=False)
    report = language.audit(source)
    codes = {item["code"] for item in report["findings"]}
    assert "LANG001" in codes


def test_skill_inventory_ignores_python_and_tool_caches(tmp_path: Path) -> None:
    root = tmp_path / "skills"
    pack = root / "example-skill"
    (pack / "scripts" / "__pycache__").mkdir(parents=True)
    (pack / "SKILL.md").write_text("skill", encoding="utf-8")
    (pack / "scripts" / "audit.py").write_text("print(1)", encoding="utf-8")
    (pack / "scripts" / "__pycache__" / "audit.cpython-313.pyc").write_bytes(b"cache")
    assert len(routing.visible_skill_files(root)) == 2


def test_skill_cli_scripts_have_executable_entrypoints() -> None:
    scripts = (
        "skills/keyboard-language-switch-qa/scripts/audit_language_switch.py",
        "skills/keyboard-audio-integrity/scripts/validate_keyboard_audio.py",
        "skills/keyboard-jetsam-forensics/scripts/analyze_jetsam.py",
        "skills/iphone-keyboard-accessibility-qa/scripts/a11y_static_audit.py",
    )
    for relative in scripts:
        result = subprocess.run(
            [sys.executable, str(ROOT / relative), "--help"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        assert result.returncode == 0, f"{relative}: {result.stdout}{result.stderr}"
        assert "usage:" in result.stdout.lower()
