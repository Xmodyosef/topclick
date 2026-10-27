#!/usr/bin/env bash
# ship.sh — one command from source to a tester's phone.
#
#   scripts/ship.sh check        # verify prerequisites, change nothing
#   scripts/ship.sh device       # build + install + launch on the USB/Wi-Fi iPhone (free or paid account)
#   scripts/ship.sh testflight   # archive + upload to TestFlight (paid account + App Store Connect API key)
#
# Configuration lives in .env.ship (git-ignored) next to this script's parent dir:
#   SCHEME=MyApp
#   TEAM_ID=ABCDE12345
#   ASC_KEY_ID=XXXXXXXXXX            # testflight only
#   ASC_ISSUER_ID=xxxxxxxx-xxxx-...  # testflight only
#   ASC_KEY_PATH=$HOME/.appstoreconnect/private_keys/AuthKey_XXXXXXXXXX.p8
#   INTERNAL_ONLY=1                  # optional: build can never go to external testers/App Store
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
[ -f .env.ship ] && set -a && . ./.env.ship && set +a

MODE="${1:-check}"
BUILD_DIR="$ROOT/build"
ARCHIVE="$BUILD_DIR/${SCHEME:-App}.xcarchive"

die() { echo "✗ $*" >&2; exit 1; }
ok()  { echo "✓ $*"; }

# Regenerate the project if it is XcodeGen-managed, so project.yml is the source of truth.
regenerate() {
    if [ -f project.yml ]; then
        command -v xcodegen >/dev/null || die "project.yml found but xcodegen missing: brew install xcodegen"
        xcodegen generate --quiet
    fi
}

container_flag() {
    local ws proj
    ws=$(find . -maxdepth 1 -name '*.xcworkspace' | head -1)
    proj=$(find . -maxdepth 1 -name '*.xcodeproj' | head -1)
    if [ -n "$ws" ]; then echo "-workspace $ws"
    elif [ -n "$proj" ]; then echo "-project $proj"
    else die "no .xcodeproj/.xcworkspace in $ROOT"; fi
}

check() {
    command -v xcodebuild >/dev/null || die "Xcode not installed"
    ok "$(xcodebuild -version | head -1)"
    [ -n "${SCHEME:-}" ] || die "SCHEME not set (.env.ship)"
    [ -n "${TEAM_ID:-}" ] || die "TEAM_ID not set — Xcode ▸ Settings ▸ Accounts ▸ your team, or developer.apple.com/account ▸ Membership"
    ok "scheme=$SCHEME team=$TEAM_ID"
    if [ "$MODE" = "testflight" ] || [ "$MODE" = "check" ]; then
        if [ -n "${ASC_KEY_ID:-}" ] && [ -n "${ASC_ISSUER_ID:-}" ] && [ -f "${ASC_KEY_PATH:-/nonexistent}" ]; then
            ok "App Store Connect API key present"
        elif [ "$MODE" = "testflight" ]; then
            die "ASC_KEY_ID / ASC_ISSUER_ID / ASC_KEY_PATH missing — App Store Connect ▸ Users and Access ▸ Integrations ▸ Team Keys (role: App Manager)"
        else
            echo "• no App Store Connect key — 'device' works, 'testflight' will not"
        fi
    fi
}

device() {
    check
    regenerate
    # shellcheck disable=SC2046
    xcodebuild build $(container_flag) -scheme "$SCHEME" \
        -configuration Debug \
        -destination 'generic/platform=iOS' \
        -derivedDataPath "$BUILD_DIR/dd" \
        DEVELOPMENT_TEAM="$TEAM_ID" \
        -allowProvisioningUpdates -allowProvisioningDeviceRegistration \
        -quiet
    APP=$(find "$BUILD_DIR/dd/Build/Products/Debug-iphoneos" -maxdepth 1 -name '*.app' | head -1)
    [ -n "$APP" ] || die "build produced no .app"
    # Xcode 27's devicectl table mixes simulators in and names contain spaces — parse JSON, not columns.
    DEVJSON="$BUILD_DIR/devices.json"
    xcrun devicectl list devices --json-output "$DEVJSON" >/dev/null 2>&1
    DEV=$(python3 -c '
import json, sys
devs = [d for d in json.load(open(sys.argv[1]))["result"]["devices"]
        if d["hardwareProperties"].get("reality") == "physical"
        and d["hardwareProperties"].get("platform") == "iOS"]
devs.sort(key=lambda d: d["connectionProperties"].get("tunnelState") != "connected")
print(devs[0]["identifier"] if devs else "")
' "$DEVJSON")
    [ -n "$DEV" ] || die "no paired iPhone — plug in, unlock, tap Trust, and turn on Developer Mode"
    BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$APP/Info.plist")
    xcrun devicectl device install app --device "$DEV" "$APP"
    xcrun devicectl device process launch --device "$DEV" "$BUNDLE_ID" \
        || echo "• installed; launch blocked — on the phone: Settings ▸ General ▸ VPN & Device Management ▸ trust your developer profile"
    ok "installed $BUNDLE_ID on $DEV"
}

testflight() {
    check
    regenerate
    rm -rf "$ARCHIVE"
    # Timestamp build number: monotonic, unique per upload, no file edits to commit.
    BUILD_NUMBER="$(date -u +%Y%m%d%H%M)"
    AUTH=(-authenticationKeyPath "$ASC_KEY_PATH" -authenticationKeyID "$ASC_KEY_ID" -authenticationKeyIssuerID "$ASC_ISSUER_ID")

    # shellcheck disable=SC2046
    xcodebuild archive $(container_flag) -scheme "$SCHEME" \
        -configuration Release \
        -destination 'generic/platform=iOS' \
        -archivePath "$ARCHIVE" \
        DEVELOPMENT_TEAM="$TEAM_ID" CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
        -allowProvisioningUpdates "${AUTH[@]}" \
        -quiet

    OPTS="$BUILD_DIR/ExportOptions.plist"
    cat > "$OPTS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key><string>app-store-connect</string>
    <key>destination</key><string>upload</string>
    <key>teamID</key><string>$TEAM_ID</string>
    <key>signingStyle</key><string>automatic</string>
    <key>manageAppVersionAndBuildNumber</key><false/>
    <key>uploadSymbols</key><true/>
    <key>testFlightInternalTestingOnly</key><$( [ "${INTERNAL_ONLY:-0}" = "1" ] && echo true || echo false )/>
</dict>
</plist>
PLIST

    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE" \
        -exportOptionsPlist "$OPTS" \
        -exportPath "$BUILD_DIR/export" \
        -allowProvisioningUpdates "${AUTH[@]}"

    ok "uploaded build $BUILD_NUMBER — processing takes ~5–15 min, then internal testers get it automatically"
}

case "$MODE" in
    check)      check ;;
    device)     device ;;
    testflight) testflight ;;
    *)          die "usage: $0 check|device|testflight" ;;
esac
