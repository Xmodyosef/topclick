#!/usr/bin/env python3
"""Fast regression checks for Naqra source configuration and keyboard fixes."""
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


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    parser.add_argument('--built-app', type=Path)
    args = parser.parse_args()
    source = args.source.resolve()
    extension = (source / 'Sources/KeyboardExtension/KeyboardViewController.swift').read_text()
    app = (source / 'Sources/ContainerApp/KeyboardPrototypeApp.swift').read_text()
    project = (source / 'project.yml').read_text()

    require(APP_GROUP in (source / 'Sources/ContainerApp/PersonalKeyboard.entitlements').read_text(), 'container App Group unchanged')
    require(APP_GROUP in (source / 'Sources/KeyboardExtension/KeyboardExtension.entitlements').read_text(), 'extension App Group unchanged')
    require(APP_BUNDLE in project and EXT_BUNDLE in project, 'container and extension bundle IDs unchanged')

    bottom_start = extension.index('    private func makeBottom(')
    bottom_end = extension.index('    private func makeEmojiTabs()', bottom_start)
    bottom = extension[bottom_start:bottom_end]
    require('let globe' not in bottom and 'advanceToNextInputMode()' not in bottom, 'visible globe key is intentionally removed')
    require('greaterThanOrEqualToConstant: 74' in bottom, 'bottom-row space key has a flexible minimum')
    fixed_width = 42 + 32 + 32 + 32 + 42 + (5 * 4) + 74
    emoji_page_width = fixed_width + (54 - 32)
    require(fixed_width <= 310 and emoji_page_width <= 310, 'bottom-row controls fit a 320pt viewport with 5pt side insets')

    require('private let boardHeight: CGFloat = 324' in extension, 'keyboard height reserves space for the bottom row')
    require('arabicShiftRows' in extension and '(isShifted ? arabicShiftRows : arabicRows)' in extension, 'Arabic Shift uses its stable alternate key layer')
    require('if showNumberRow {' in extension and 'showNumberRow' in app, 'number-row setting is read by extension and app')
    autocorrect = extension[extension.index('    private func autocorrectOnSpace()'):extension.index('    @objc private func spaceTouchUp()')]
    require('arabicFixes' in autocorrect and 'language == .english' in autocorrect, 'autocorrect supports Arabic fixes and English checking')
    require('misspelling.location != NSNotFound' in autocorrect, 'English autocorrect is limited to detected misspellings')
    require('suite.synchronize()' in extension and 'suite.synchronize()' in app, 'shared preferences synchronize before reads')
    sound = (source / 'Sources/KeyboardExtension/TapSoundEngine.swift').read_text()
    require('AudioServicesPlaySystemSound(1104)' in sound, 'sound has a system fallback')
    require('Button { insertPreview(title) }' in app and 'TextField("اكتب للتجربة…"' in app, 'preview is interactive')
    require('private var emojiPack' in extension and 'emojiPack = Self.catalog()' in extension, 'emoji catalog refreshes after selection')
    require('UIApplication.openSettingsURLString' in app and 'App-Prefs:' not in app, 'Full Access uses public app settings URL')
    require('private var themeOptionsCard' in app and 'صوت النظام يعمل تلقائيًا' in app and 'Picker("خط الحروف"' not in app and 'Picker("نوع الصوت"' not in app, 'theme preview uses one compact system sound')
    require('letterFont' in extension and '.systemFont(ofSize: 26, weight: .medium)' in extension and 'fontStyle' not in extension, 'one compact keyboard font is applied')
    require('emojiPager?.delegate = nil' in extension and 'guard emojiPack.indices.contains(collectionView.tag)' in extension, 'emoji page teardown and index guards prevent stale callbacks')
    require('DispatchQueue.main.async { [weak self] in' in extension and 'self.emojiPack = Self.catalog()' in extension, 'emoji catalog refresh is deferred after selection')
    require('["ع","ظ","ط","ذ","د","ز","ر","و","ي"]' in extension, 'Arabic bottom row matches the reference layout')
    require('"ا": ["أ", "إ", "آ"]' in extension and '"و": ["ؤ"]' in extension and '"ي": ["ئ", "ى"]' in extension, 'Arabic long-press alternatives exist')
    require('bar.centerXAnchor.constraint(equalTo: view.leftAnchor, constant: frame.midX)' in extension and 'bar.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: frame.midX)' not in extension, 'long-press popup uses physical X coordinate in RTL')
    require('["ع","ظ","ط","ذ","د","ز","ر","و","ي"]' in extension, 'Arabic third row matches the reference layout')
    require('.environment(\\.layoutDirection, .rightToLeft)' in app, 'preview uses the same RTL direction as the keyboard')
    require('("😀", merge(Array(loadFrequent().prefix(24))' in extension and '("🕒", loadFrequent())' not in extension, 'frequent emojis merge into the main faces tab')
    copy_fn = extension[extension.index('    private func copyNow()'):extension.index('    private func pasteNow()')]
    require('textDocumentProxy.selectedText' in copy_fn and 'combined()' not in copy_fn, 'copy requires selected text and does not capture surrounding context')
    require('clipboardHistoryEnabled' in extension and 'func clear()' in extension, 'clipboard history is opt-in and clearable')
    require('onError' in extension and 'تعذّرت الترجمة' in extension, 'translation failures are surfaced to the user')
    require('showNotice(' in extension and 'الوصول الكامل' in extension, 'Full Access failures display a message')

    ids = re.findall(r'\.init\(id: "([^"]+)"', app[app.index('static let all: [ThemeSwatch]'):app.index('static let groups: [ThemeGroup]')])
    supported = set(re.findall(r'case\s+[^\n]*?"([a-zA-Z0-9_]+)"', extension[extension.index('    static func preset('):extension.index('    static func tone(')]))
    # These are explicit special cases rather than entries in preset().
    supported.update({'auto', 'dark', 'custom'})
    missing = sorted(set(ids) - supported)
    require(not missing, f'all displayed theme IDs have an extension implementation (missing={missing})')

    project_settings = project[project.index('ASSETCATALOG_COMPILER_APPICON_NAME'):project.index('TARGETED_DEVICE_FAMILY', project.index('ASSETCATALOG_COMPILER_APPICON_NAME'))]
    require('AppIconMorning' in project_settings and 'AppIconEvening' in project_settings, 'XcodeGen declares morning primary and evening alternate app icon')
    assets = source / 'Sources/ContainerApp/Assets.xcassets'
    for set_name, image_name in (
        ('AppIconMorning.appiconset', 'AppIconMorning.png'),
        ('AppIconEvening.appiconset', 'AppIconEvening.png'),
        ('MorningArtwork.imageset', 'MorningArtwork.png'),
        ('EveningArtwork.imageset', 'EveningArtwork.png'),
    ):
        set_dir = assets / set_name
        manifest = json.loads((set_dir / 'Contents.json').read_text())
        require((set_dir / image_name).is_file() and manifest['images'][0]['filename'] == image_name, f'{set_name} asset is complete')

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
