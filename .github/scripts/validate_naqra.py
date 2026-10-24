#!/usr/bin/env python3
"""Regression checks for Naqra — split-aware (reads all KeyboardExtension + ContainerApp sources)."""
from __future__ import annotations
import argparse
import json
import plistlib
from pathlib import Path
import re
import sys

APP_GROUP = 'group.app.personal.PersonalKeyboard'
APP_BUNDLE = 'app.personal.PersonalKeyboard'
EXT_BUNDLE = 'app.personal.PersonalKeyboard.KeyboardExtension'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)
    print(f'PASS: {message}')


def concat_swift(folder: Path) -> str:
    parts = []
    for p in sorted(folder.rglob('*.swift')):
        parts.append(p.read_text(encoding='utf-8'))
    return '\n'.join(parts)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('--built-app', type=Path, default=None)
    args = parser.parse_args()
    source = args.source

    ext_dir = source / 'Sources/KeyboardExtension'
    app_dir = source / 'Sources/ContainerApp'
    extension = concat_swift(ext_dir)
    app = concat_swift(app_dir)
    project = (source / 'project.yml').read_text(encoding='utf-8')

    require(APP_GROUP in (source / 'Sources/ContainerApp/PersonalKeyboard.entitlements').read_text(encoding='utf-8'), 'container App Group unchanged')
    require(APP_GROUP in (source / 'Sources/KeyboardExtension/KeyboardExtension.entitlements').read_text(encoding='utf-8'), 'extension App Group unchanged')
    require(APP_BUNDLE in project and EXT_BUNDLE in project, 'container and extension bundle IDs unchanged')

    # Split structure
    require((ext_dir / 'KeyboardViewController.swift').is_file(), 'core KeyboardViewController exists')
    require((ext_dir / 'KeyboardViewController+BuildUI.swift').is_file(), 'BuildUI extension exists')
    require((ext_dir / 'KeyboardDataLoader.swift').is_file(), 'KeyboardDataLoader exists')
    require((ext_dir / 'Resources/keyboard_layouts.json').is_file(), 'layouts JSON exists')
    require((ext_dir / 'Resources/emoji_catalog.json').is_file(), 'emoji JSON exists')
    require((ext_dir / 'Resources/arabic_lexicon.json').is_file(), 'lexicon JSON exists')
    require('path: Sources/KeyboardExtension/Resources' in project, 'project.yml registers Resources')

    layouts = json.loads((ext_dir / 'Resources/keyboard_layouts.json').read_text(encoding='utf-8'))
    hold = layouts.get('hold_map') or {}
    require(hold.get('ا') == ['أ', 'إ', 'آ'] and 'و' in hold and 'ي' in hold, 'Arabic long-press alternatives in layouts JSON')
    arabic_rows = layouts.get('arabic_rows') or []
    require(len(arabic_rows) == 3 and [len(row) for row in arabic_rows] == [11, 11, 9], 'Arabic letter rows match keyboard row widths')
    require(arabic_rows[2] == ["ع","ظ","ط","ذ","د","ز","ر","و","ي"], 'Arabic third row matches reference layout')
    arabic_shift = layouts.get('arabic_shift_rows') or []
    require(len(arabic_shift) == len(arabic_rows) and [len(row) for row in arabic_shift] == [len(row) for row in arabic_rows], 'Arabic Shift rows match keyboard row widths')
    require(arabic_shift != arabic_rows, 'Arabic Shift layout differs from normal Arabic letters')

    emoji = json.loads((ext_dir / 'Resources/emoji_catalog.json').read_text(encoding='utf-8'))
    require(isinstance(emoji, list) and len(emoji) >= 8, 'emoji catalog has categories')
    require(sum(len(c.get('items', [])) for c in emoji) >= 200, 'emoji catalog has substantial items')

    require('func makeBottom' in extension, 'makeBottom present')
    require('greaterThanOrEqualToConstant: 74' in extension or '>= 74' in extension or '74' in extension, 'bottom-row space sizing present')
    require('boardHeight' in extension and '324' in extension, 'keyboard height constant present')
    loader = (ext_dir / 'KeyboardDataLoader.swift').read_text(encoding='utf-8')
    controller = (ext_dir / 'KeyboardViewController.swift').read_text(encoding='utf-8')
    require('arabicShiftRows' in extension and 'isShifted ? arabicShiftRows : arabicRows' in extension, 'Arabic Shift layer used')
    require('rows2("arabic_shift_rows")' in loader and 'layouts().arabicShiftRows' in controller, 'Arabic Shift JSON is loaded by the keyboard')
    lifecycle = re.search(r'override func viewWillDisappear\(_ animated: Bool\) \{(.*?)\n    \}', controller, re.S)
    require(lifecycle is not None and all(token in lifecycle.group(1) for token in ['holdTimer?.invalidate()', 'holdTimer = nil', 'hideHoldPopup()', 'pendingInserted = false']), 'viewWillDisappear cleans long-press state')
    require('showNumberRow' in extension and 'showNumberRow' in app, 'number-row setting shared')
    require('numberRow' in extension, 'number row keys defined')
    require('func autocorrectOnSpace' in extension and 'arabicFixes' in extension, 'autocorrect supports Arabic fixes')
    require('language == .english' in extension and 'UITextChecker' in extension, 'English spelling path present')
    require('misspelling.location != NSNotFound' in extension, 'English autocorrect limited to misspellings')

    sound = (ext_dir / 'TapSoundEngine.swift').read_text(encoding='utf-8')
    require('AudioServicesPlaySystemSound' in sound or 'AVAudioEngine' in sound, 'sound engine present')
    none_branch = re.search(r'if choice == "none"\s*\{([^}]*)\}', sound)
    require(none_branch is not None and 'return' in none_branch.group(1) and 'AudioServicesPlaySystemSound' not in none_branch.group(1), 'none sound choice is silent')
    require('ThemeIO.bool("sounds") != false' in sound, 'sound engine respects disabled sound preference')

    require('Button { insertPreview(title) }' in app and 'TextField("اكتب للتجربة…"' in app, 'preview is interactive')
    preview = (app_dir / 'KeyboardPreviewTab.swift').read_text(encoding='utf-8')
    settings = (app_dir / 'SettingsTab.swift').read_text(encoding='utf-8')
    require('ThemeStore.bool("sounds") ?? true' in preview and 'soundChoice != "none"' in preview, 'preview reads saved sound preferences')
    require('ThemeStore.write("sounds", value: true)' not in preview and 'ThemeStore.write("soundChoice", value: "system")' not in preview, 'preview does not force sound settings')
    require('Toggle("تفعيل صوت النقر", isOn: $sounds)' in settings and 'Picker("نوع الصوت", selection: $soundChoice)' in settings, 'sound toggle and picker are exposed in settings')
    require('ThemeStore.write("sounds", value: isEnabled)' in settings and 'ThemeStore.write("soundChoice", value: nextChoice)' in settings and 'ThemeStore.write("soundChoice", value: choice)' in settings, 'sound toggle and picker keep both stored preferences in sync')
    require(not re.search(r'(?m)^\s*sounds\s*=\s*ThemeStore\.bool\("sounds"\)', settings), 'no orphan sound assignment in SettingsTab')
    require('UIApplication.openSettingsURLString' in app and 'App-Prefs:' not in app, 'Full Access uses public app settings URL')
    require('letterFont' in extension and '.systemFont(ofSize: 26, weight: .medium)' in extension, 'compact keyboard font')
    require('UIVisualEffectView(effect: nil)' in extension and 'shadowOpacity = 0' in extension, 'keyboard avoids live blur and key shadows')
    build_ui = (ext_dir / 'KeyboardViewController+BuildUI.swift').read_text(encoding='utf-8')
    require('b.isOpaque = true' in build_ui and 'b.opaque = true' not in build_ui, 'UIButton opacity uses current UIKit property')
    require('emojiPager?.delegate = nil' in extension and 'emojiPack.indices.contains' in extension, 'emoji teardown + guards')
    require('emojiPack = Self.catalog()' in extension or 'KeyboardDataLoader.emojiCatalog' in extension, 'emoji catalog load path')
    require('KeyboardDataLoader' in extension, 'data loader wired')
    require('textDocumentProxy.selectedText' in extension, 'copy uses selected text')
    require('clipboardHistoryEnabled' in extension, 'clipboard history opt-in')
    require('showNotice(' in extension and 'الوصول الكامل' in extension, 'Full Access notices')
    require('onError' in extension, 'translation error path')

    # No giant literals left in source
    require('😀 😃 😄 😁 😆 😅 😂 🤣 😊 😇 🙂 😉' not in extension, 'emoji bulk not inlined in Swift')
    require('suite.synchronize()' not in extension and 'suite.synchronize()' not in app, 'no UserDefaults.synchronize')

    # Theme IDs vs palette presets
    ids = re.findall(r'\.init\(id: "([^"]+)"', app[app.index('static let all: [ThemeSwatch]'):app.index('static let groups: [ThemeGroup]')])
    preset_block = extension[extension.index('static func preset('):extension.index('static func tone(')] if 'static func preset(' in extension else ''
    supported = set(re.findall(r'"([a-zA-Z0-9_]+)"', preset_block))
    supported.update({'auto', 'dark', 'custom'})
    missing = sorted(set(ids) - supported)
    require(not missing, f'all displayed theme IDs have extension implementation (missing={missing})')

    project_settings = project[project.index('ASSETCATALOG_COMPILER_APPICON_NAME'):project.index('TARGETED_DEVICE_FAMILY', project.index('ASSETCATALOG_COMPILER_APPICON_NAME'))]
    require('AppIconMorning' in project_settings and 'AppIconEvening' in project_settings, 'XcodeGen morning/evening icons')

    assets = source / 'Sources/ContainerApp/Assets.xcassets'
    for set_name, image_name in (
        ('AppIconMorning.appiconset', 'AppIconMorning.png'),
        ('AppIconEvening.appiconset', 'AppIconEvening.png'),
        ('MorningArtwork.imageset', 'MorningArtwork.png'),
        ('EveningArtwork.imageset', 'EveningArtwork.png'),
    ):
        set_dir = assets / set_name
        manifest = json.loads((set_dir / 'Contents.json').read_text(encoding='utf-8'))
        require((set_dir / image_name).is_file() and manifest['images'][0]['filename'] == image_name, f'{set_name} complete')

    # Container split
    require((app_dir / 'KeyboardPrototypeApp.swift').is_file(), 'App entry exists')
    require('enum NaqraColors' not in (app_dir / 'KeyboardPrototypeApp.swift').read_text(encoding='utf-8'), 'App entry is slim')
    require((app_dir / 'SettingsTab.swift').is_file() and (app_dir / 'ThemesTab.swift').is_file(), 'settings/themes split')
    require('sounds' in app, 'sounds setting exposed in app')
    require('Undo' not in (source / 'README.md').read_text(encoding='utf-8'), 'README does not claim unimplemented Undo')

    # RTL preview (MiniKeyboardView)
    require('.environment(\\.layoutDirection, .rightToLeft)' in app, 'preview uses RTL')

    if args.built_app:
        info_path = args.built_app / 'Info.plist'
        with info_path.open('rb') as handle:
            info = plistlib.load(handle)
        icons = info.get('CFBundleIcons', {})
        alternates = icons.get('CFBundleAlternateIcons', {})
        require('AppIconEvening' in alternates, 'built Info.plist includes AppIconEvening alternate icon')
        require(info.get('CFBundleIdentifier') == APP_BUNDLE, 'built application bundle ID remains unchanged')
        require(info.get('CFBundleShortVersionString') == '0.2', 'built app version is 0.2')

    print('All Naqra regression checks passed.')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f'FAIL: {error}', file=sys.stderr)
        sys.exit(1)
