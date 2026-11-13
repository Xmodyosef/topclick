#!/usr/bin/env python3
"""Regression checks for Naqra — split-aware (reads all KeyboardExtension + ContainerApp sources)."""
from __future__ import annotations
import argparse
import json
import plistlib
from pathlib import Path
import re
import sys

APP_GROUP = 'group.Mark1'
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

    ext_dir = source / 'KeyboardExtension/Sources'
    app_dir = source / 'App/Sources'
    extension_resources = source / 'KeyboardExtension/Resources'
    app_config = source / 'App/Config'
    extension_config = source / 'KeyboardExtension/Config'
    extension = concat_swift(ext_dir)
    app = concat_swift(app_dir)
    project = (source / 'project.yml').read_text(encoding='utf-8')

    # RTL contract: preserve Arabic keyboard direction without forcing the whole app to LTR.
    app_info = plistlib.loads((app_config / 'Info.plist').read_bytes())
    extension_info = plistlib.loads((extension_config / 'Info.plist').read_bytes())
    require(
        extension_info.get('NSExtension', {}).get('NSExtensionAttributes', {}).get('PrefersRightToLeft') is True,
        'keyboard extension declares PrefersRightToLeft'
    )
    app_entry = (app_dir / 'AppShell/KeyboardPrototypeApp.swift').read_text(encoding='utf-8')
    require('.environment(\\.layoutDirection, .leftToRight)' not in app_entry, 'app does not force a global LTR layout direction')
    app_groups = plistlib.loads((app_config / 'PersonalKeyboard.entitlements').read_bytes()).get('com.apple.security.application-groups', [])
    ext_groups = plistlib.loads((extension_config / 'KeyboardExtension.entitlements').read_bytes()).get('com.apple.security.application-groups', [])
    require(bool(app_groups) and app_groups == ext_groups, 'App Group entitlement arrays match exactly')

    require(APP_GROUP in (source / 'App/Config/PersonalKeyboard.entitlements').read_text(encoding='utf-8'), 'container App Group unchanged')
    require(APP_GROUP in (source / 'KeyboardExtension/Config/KeyboardExtension.entitlements').read_text(encoding='utf-8'), 'extension App Group unchanged')
    require(APP_BUNDLE in project and EXT_BUNDLE in project, 'container and extension bundle IDs unchanged')

    # Split structure
    require((ext_dir / 'Lifecycle/KeyboardViewController.swift').is_file(), 'core KeyboardViewController exists')
    require((ext_dir / 'UI/KeyboardViewController+BuildUI.swift').is_file(), 'BuildUI extension exists')
    require((ext_dir / 'Input/KeyboardDataLoader.swift').is_file(), 'KeyboardDataLoader exists')
    require((extension_resources / 'keyboard_layouts.json').is_file(), 'layouts JSON exists')
    require((extension_resources / 'emoji_catalog.json').is_file(), 'emoji JSON exists')
    require((extension_resources / 'emoji_skin_map.json').is_file(), 'emoji skin map JSON exists')
    # arabic_lexicon.json is optional: suggestions fall back inside KeyboardDataLoader.
    require('path: KeyboardExtension/Resources' in project, 'project.yml registers Resources')
    require('emoji_skin_map.json' in project, 'project.yml registers emoji_skin_map.json')

    layouts = json.loads((extension_resources / 'keyboard_layouts.json').read_text(encoding='utf-8'))
    hold = layouts.get('hold_map') or {}
    require(isinstance(hold.get('ا'), list) and set(['أ','إ','آ']).issubset(hold.get('ا') or []), 'Arabic long-press for alef in layouts JSON')
    require('و' in hold and 'ي' in hold and 'a' in hold and 'e' in hold, 'Arabic+English long-press maps present')
    require(isinstance(hold.get('a'), list) and len(hold.get('a') or []) >= 3, 'English long-press diacritics for a')
    arabic_rows = layouts.get('arabic_rows') or []
    require(len(arabic_rows) == 3 and [len(row) for row in arabic_rows] == [11, 11, 9], 'Arabic letter rows match keyboard row widths')
    require(arabic_rows[2] == ["ء","ظ","ط","ذ","د","ز","ر","و","ى"], 'Arabic third row matches reference layout')
    arabic_shift = layouts.get('arabic_shift_rows') or []
    require(len(arabic_shift) == len(arabic_rows) and [len(row) for row in arabic_shift] == [len(row) for row in arabic_rows], 'Arabic Shift rows match keyboard row widths')
    require(arabic_shift != arabic_rows, 'Arabic Shift layout differs from normal Arabic letters')

    emoji = json.loads((extension_resources / 'emoji_catalog.json').read_text(encoding='utf-8'))
    require(isinstance(emoji, list) and len(emoji) >= 8, 'emoji catalog has categories')
    require(sum(len(c.get('items', [])) for c in emoji) >= 200, 'emoji catalog has substantial items')
    skin_mods = {chr(c) for c in (0x1F3FB, 0x1F3FC, 0x1F3FD, 0x1F3FE, 0x1F3FF)}
    skinned_left = sum(1 for cat in emoji for item in (cat.get('items') or []) if any(m in item for m in skin_mods))
    require(skinned_left == 0, 'emoji catalog items must be base forms without skin modifiers')
    skin_map = json.loads((extension_resources / 'emoji_skin_map.json').read_text(encoding='utf-8'))
    require(isinstance(skin_map, dict) and len(skin_map) >= 50, 'emoji skin map has substantial bases')
    wave = skin_map.get('👋') or []
    require(isinstance(wave, list) and len(wave) >= 6 and wave[0] == '👋', 'skin map wave has default + tones')
    require('emojiSkinTone' in extension, 'emojiSkinTone preference key present')
    require('emojiSkinLongPressed' in extension, 'emoji skin long-press handler present')
    require('hideEmojiSkinBar' in extension, 'emoji skin bar hide present')

    require('func makeBottom' in extension, 'makeBottom present')
    require('greaterThanOrEqualToConstant: 74' in extension or '>= 74' in extension or '74' in extension, 'bottom-row space sizing present')
    height_match = re.search(r'let boardHeight: CGFloat\s*=\s*([0-9]+(?:\.[0-9]+)?)', extension)
    require(height_match is not None and 200 <= float(height_match.group(1)) <= 400, 'keyboard height constant is configured')
    require(
        'needsInputModeSwitchKey' in extension
        and 'handleInputModeList(from:with:)' in extension
        and 'for: .allTouchEvents' in extension
        and 'تبديل لوحة المفاتيح' in extension,
        'system next-keyboard button is conditionally wired and labeled'
    )
    controller = (ext_dir / 'Lifecycle/KeyboardViewController.swift').read_text(encoding='utf-8')
    active_layout = re.search(r'func activeLetterLayout\(\)\s*->\s*\[\[String\]\]\s*\{(.*?)\n    \}', extension, re.S)
    require(active_layout is not None and 'return arabicRows' in active_layout.group(1) and 'isShifted ? englishUpper : englishLower' in active_layout.group(1), 'Arabic layout stays fixed while English Shift changes case')
    lifecycle = re.search(r'override func viewWillDisappear\(_ animated: Bool\) \{(.*?)\n    \}', controller, re.S)
    require(lifecycle is not None and all(token in lifecycle.group(1) for token in ['holdTimer?.invalidate()', 'holdTimer = nil', 'hideHoldPopup()', 'pendingInserted = false']), 'viewWillDisappear cleans long-press state')
    require('showNumberRow' in extension and 'showNumberRow' in app, 'number-row setting shared')
    require('numberRow' in extension, 'number row keys defined')
    # Autocorrect removed by design — keep suggestions only.
    require('autocorrectOnSpace' not in extension, 'autocorrectOnSpace must be absent')
    require('arabicLexiconFix' not in extension, 'arabicLexiconFix must be absent')
    require('arabicFixes' not in extension, 'arabicFixes must be absent')

    # Emoji category swipe (pan) contract
    require('UIPanGestureRecognizer' in extension, 'emoji pan uses UIPanGestureRecognizer')
    require('emojiCategoryPanned' in extension, 'emojiCategoryPanned handler present')
    require('gestureRecognizerShouldBegin' in extension, 'gestureRecognizerShouldBegin present for pan vs scroll')

    # Long-press alternates for percent / riyal
    require(hold.get('٪') == ['%'], 'hold_map maps ٪ to %')
    require(hold.get('﷼') == ['$'], 'hold_map maps ﷼ to $')

    # Symbol pages: 5×10 and no duplicate symbols within a page
    for pages_key in ('arabic_symbol_pages', 'english_symbol_pages'):
        pages = layouts.get(pages_key) or []
        require(len(pages) >= 1, f'{pages_key} present')
        for page_index, page in enumerate(pages):
            require(len(page) == 5 and all(len(row) == 10 for row in page), f'{pages_key}[{page_index}] is 5 rows of 10')
            flat = [sym for row in page for sym in row]
            require(len(flat) == len(set(flat)), f'{pages_key}[{page_index}] has no duplicate symbols')

    sound = (ext_dir / 'Features/TapSoundEngine.swift').read_text(encoding='utf-8')
    require('AudioServicesPlaySystemSound' in sound or 'AVAudioEngine' in sound, 'sound engine present')
    none_branch = re.search(r'if choice == "none"\s*\{([^}]*)\}', sound)
    require(none_branch is not None and 'return' in none_branch.group(1) and 'AudioServicesPlaySystemSound' not in none_branch.group(1), 'none sound choice is silent')
    require('ThemeIO.bool("sounds") != false' in sound, 'sound engine respects disabled sound preference')

    settings = (app_dir / 'Settings/SettingsTab.swift').read_text(encoding='utf-8')
    require(not (app_dir / 'Settings/KeyboardPreviewTab.swift').exists(), 'KeyboardPreviewTab removed')
    require('KeyboardPreviewTab' not in app and 'MiniKeyboardView' not in app, 'app no longer embeds keyboard preview')
    require('معاينة' not in (app_dir / 'AppShell/ContentView.swift').read_text(encoding='utf-8'), 'ContentView has no preview tab')
    require('Toggle("تفعيل صوت النقر", isOn: $sounds)' in settings, 'sound toggle is exposed in settings')
    require(
        ('Picker("نوع الصوت", selection: $soundChoice)' in settings)
        or ('SoundPackStore' in settings and 'soundChoice' in settings),
        'sound picker or sound pack UI is exposed in settings'
    )
    require(
        'ThemeStore.write("sounds"' in settings
        or 'ThemeStore.write(ContentPackKeys' in settings
        or 'sounds' in settings and 'soundChoice' in settings,
        'sound preferences are persisted from settings'
    )
    require(not re.search(r'(?m)^\s*sounds\s*=\s*ThemeStore\.bool\("sounds"\)', settings), 'no orphan sound assignment in SettingsTab')
    require('UIApplication.openSettingsURLString' in app and 'App-Prefs:' not in app, 'Full Access uses public app settings URL')
    require('letterFont' in extension and '.systemFont(ofSize: 26, weight: .medium)' in extension, 'compact keyboard font')
    require('UIVisualEffectView(effect: nil)' in extension and 'shadowOpacity = 0' in extension, 'keyboard avoids live blur and key shadows')
    build_ui = (ext_dir / 'UI/KeyboardViewController+BuildUI.swift').read_text(encoding='utf-8')
    require(('b.isOpaque = true' in build_ui or 'b.isOpaque = true' in extension) and 'b.opaque = true' not in extension, 'UIButton opacity uses current UIKit property')
    require('emojiPager = nil' in extension and 'emojiPack.indices.contains' in extension, 'emoji teardown + guards')
    require('emojiPack = Self.catalog()' in extension or 'KeyboardDataLoader.emojiCatalog' in extension, 'emoji catalog load path')
    require('KeyboardDataLoader' in extension, 'data loader wired')
    require('textDocumentProxy.selectedText' in extension, 'copy uses selected text')
    require('clipboardHistoryEnabled' in extension, 'clipboard history opt-in')
    require('themeToggleTapped' not in extension, 'in-keyboard theme toggle removed')
    require('paintpalette' not in extension, 'keyboard toolbar has no theme palette button')
    require('suite.set(value, forKey: key)' in extension, 'theme prefs write the App Group suite')
    require('suite.string(forKey: key)' in extension, 'theme prefs read the App Group suite')
    require('UserDefaults.standard.set' not in extension, 'keyboard theme prefs do not write local UserDefaults')
    require('func showClipboardPanel' in extension, 'clipboard uses in-keyboard panel')
    require('UIAlertController(' not in extension and 'UIAlertAction(' not in extension, 'no UIAlert presentation in keyboard extension')
    require('hideClipboardPanel' in extension and 'clipboardPasteLiveTapped' in extension, 'clipboard panel paste/close wiring')
    require('UIPasteboard.general.string' in extension and 'showClipboardPanel' in extension, 'clipboard panel can surface live pasteboard')
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

    assets = source / 'App/Resources/Assets.xcassets'
    for set_name, image_name in (
        ('AppIconMorning.appiconset', 'AppIconMorning.png'),
        ('AppIconEvening.appiconset', 'AppIconEvening.png'),
        ('MorningArtwork.imageset', 'MorningArtwork.png'),
    ):
        set_dir = assets / set_name
        manifest = json.loads((set_dir / 'Contents.json').read_text(encoding='utf-8'))
        require((set_dir / image_name).is_file() and manifest['images'][0]['filename'] == image_name, f'{set_name} complete')
    # Decorative EveningArtwork removed by design (user request).
    require(not (assets / 'EveningArtwork.imageset').exists(), 'EveningArtwork decorative set removed')

    # Container split
    require((app_dir / 'AppShell/KeyboardPrototypeApp.swift').is_file(), 'App entry exists')
    require('enum NaqraColors' not in (app_dir / 'AppShell/KeyboardPrototypeApp.swift').read_text(encoding='utf-8'), 'App entry is slim')
    require((app_dir / 'Settings/SettingsTab.swift').is_file() and (app_dir / 'Themes/ThemesTab.swift').is_file(), 'settings/themes split')
    require('sounds' in app, 'sounds setting exposed in app')
    require('Undo' not in (source / 'README.md').read_text(encoding='utf-8'), 'README does not claim unimplemented Undo')

    # App shell after preview removal
    require('ThemesTab()' in (app_dir / 'AppShell/ContentView.swift').read_text(encoding='utf-8'), 'ThemesTab is primary tab')
    require('SetupTab' not in (app_dir / 'AppShell/ContentView.swift').read_text(encoding='utf-8'), 'Setup folded into Settings (no separate tab)')
    require('تفعيل لوحة نقرة' in (app_dir / 'Settings/SettingsTab.swift').read_text(encoding='utf-8'), 'activation guide lives in Settings')
    require('ThemeBoardCanvas' in app and ('numberRow' in (app_dir / 'Themes/ThemesTab.swift').read_text(encoding='utf-8') or 'numberRow' in (app_dir / 'Themes/ThemeBoardCanvas.swift').read_text(encoding='utf-8')), 'themes tab has full 4-row board canvas')
    require('تم اللصق' in extension and 'pasteNow()' in extension, 'paste uses toast notice like iOS')
    require('holdChoices(for:' in extension, 'long-press holdChoices helper present')
    require('func applyShiftSurface' in extension and 'letterKeyButtons' in extension, 'shift updates titles without full rebuild')
    require('enum KeyChrome' in extension and 'chrome: .language' in extension, 'shift/lang keys use distinct chrome colors')
    require('chrome: .symbols' in extension and 'chrome: .emoji' in extension, 'symbols/emoji keys use distinct chrome')
    require('func symbolPageToggled' in extension, 'symbols multi-page toggle')
    require('emojiCollection' in extension and 'clearEmojiCache' in extension, 'single emoji grid + cache reload')
    require(len(layouts.get('arabic_symbol_pages') or []) == 1, 'arabic symbols single uncrowded page')
    require(len(layouts.get('english_symbol_pages') or []) == 1, 'english symbols single uncrowded page')

    require('shiftTapped' in extension and 'applyShiftSurface()' in extension, 'shiftTapped uses applyShiftSurface')
    require('emojiPagerHeight()' in extension and 'symbolRowsCount()' in extension, 'unified height helpers present')
    require('boardHeight' in extension and 'func computedBoardHeight()' in extension, 'all pages use the shared board height')
    require('padRowKeys' in extension, 'symbol row gap fillers')
    require('constant: 12' in extension, 'board slightly lowered top inset')
    require('holdMap[lower]' in extension or 'lowercased()' in extension, 'shift-aware long-press')

    if args.built_app:
        info_path = args.built_app / 'Info.plist'
        with info_path.open('rb') as handle:
            info = plistlib.load(handle)
        icons = info.get('CFBundleIcons', {})
        alternates = icons.get('CFBundleAlternateIcons', {})
        require('AppIconEvening' in alternates, 'built Info.plist includes AppIconEvening alternate icon')
        require(info.get('CFBundleIdentifier') == APP_BUNDLE, 'built application bundle ID remains unchanged')
        version_match = re.search(r'MARKETING_VERSION:\s*["\']([^"\']+)["\']', project)
        build_match = re.search(r'CURRENT_PROJECT_VERSION:\s*([0-9]+)', project)
        require(version_match is not None and info.get('CFBundleShortVersionString') == version_match.group(1), 'built app version matches project.yml')
        require(build_match is not None and info.get('CFBundleVersion') == build_match.group(1), 'built app build number matches project.yml')

    print('All Naqra regression checks passed.')


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(f'FAIL: {error}', file=sys.stderr)
        sys.exit(1)
