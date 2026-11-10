#!/usr/bin/env bash
# Archive + upload the current version to TestFlight from a Mac signed in to Xcode
# (Xcode > Settings > Accounts with team 6XK6BNVURL). No keys are read or stored.
#   Usage: Scripts/release_testflight.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

VERSION=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' RocketLander/Info.plist)
BUILD=$(/usr/libexec/PlistBuddy -c 'Print CFBundleVersion' RocketLander/Info.plist)
ARCHIVE="build/RocketLander-$VERSION-$BUILD.xcarchive"
mkdir -p build

echo "== Archiving Starship Lander $VERSION ($BUILD) =="
xcodebuild archive \
  -project RocketLander.xcodeproj -scheme RocketLander -configuration Release \
  -destination 'generic/platform=iOS' -archivePath "$ARCHIVE" \
  -allowProvisioningUpdates | tail -5

cat > build/ExportOptions-upload.plist <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>app-store-connect</string>
  <key>destination</key><string>upload</string>
  <key>teamID</key><string>6XK6BNVURL</string>
  <key>signingStyle</key><string>automatic</string>
  <key>uploadSymbols</key><true/>
</dict>
</plist>
PLIST

echo "== Uploading to App Store Connect =="
xcodebuild -exportArchive -archivePath "$ARCHIVE" \
  -exportPath build/export -exportOptionsPlist build/ExportOptions-upload.plist \
  -allowProvisioningUpdates

echo "Done. Build $VERSION ($BUILD) will appear in TestFlight after Apple finishes processing (~10-30 min)."
