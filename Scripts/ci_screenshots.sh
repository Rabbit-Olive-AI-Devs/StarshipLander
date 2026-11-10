#!/usr/bin/env bash
# Builds a Debug simulator app and captures screenshots of key screens using the
# DEBUG-only launch arguments in RocketLanderApp.swift (DebugLaunch).
# Output: build/screens/*.png
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BUNDLE_ID="com.tboliveira.StarshipLander"
OUT="build/screens"
DERIVED="build/dd"
mkdir -p "$OUT"

SIM_ID="$(xcrun simctl list devices available -j | python3 -c '
import json, sys
devices = [d for r in json.load(sys.stdin)["devices"].values() for d in r]
for name in ["iPhone 17 Pro", "iPhone 16 Pro", "iPhone 16", "iPhone 15 Pro"]:
    for d in devices:
        if d["name"] == name:
            print(d["udid"]); sys.exit(0)
print(next(d["udid"] for d in devices if d["name"].startswith("iPhone")))
')"
echo "Simulator: $SIM_ID"
xcrun simctl boot "$SIM_ID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$SIM_ID" -b
xcrun simctl status_bar "$SIM_ID" override --time "9:41" --batteryLevel 100 --batteryState charged || true

xcodebuild build \
  -project RocketLander.xcodeproj -scheme RocketLander -configuration Debug \
  -destination "id=$SIM_ID" -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO | tail -5

APP="$(find "$DERIVED/Build/Products/Debug-iphonesimulator" -maxdepth 1 -name '*.app' | head -1)"
xcrun simctl install "$SIM_ID" "$APP"

shoot() { # name delay args...
  local name="$1" delay="$2"; shift 2
  xcrun simctl terminate "$SIM_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$SIM_ID" "$BUNDLE_ID" "$@" >/dev/null
  sleep "$delay"
  xcrun simctl io "$SIM_ID" screenshot "$OUT/$name.png" >/dev/null
  echo "captured $name"
}

shoot_sequence() { # prefix "t1 t2 ..." args...
  local prefix="$1" times="$2"; shift 2
  xcrun simctl terminate "$SIM_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$SIM_ID" "$BUNDLE_ID" "$@" >/dev/null
  local elapsed=0
  for t in $times; do
    sleep $((t - elapsed)); elapsed=$t
    xcrun simctl io "$SIM_ID" screenshot "$OUT/${prefix}_${t}s.png" >/dev/null
    echo "captured ${prefix}_${t}s"
  done
}

# Warm-up launch (first launch is slow on CI)
shoot 00_warmup 12 -screen menu
shoot 01_menu 5 -screen menu
shoot 02_hangar 5 -screen hangar
shoot 03_preflight_mars 5 -screen game -mode campaign -level 2
shoot_sequence 04_classic_autopilot "8 12 16 20" -screen game -mode classic -autopilot
shoot 05_venus 6 -screen game -mode campaign -level 6
shoot 06_levels 6 -screen levels
shoot 07_starbase 7 -screen game -mode campaign -level 11
shoot_sequence 08_bellyflop_autopilot "10 15 20" -screen game -mode campaign -level 12 -autopilot
shoot 09_phobos 12 -screen game -mode campaign -level 13
shoot_sequence 10_ceres_autopilot "6 10" -screen game -mode campaign -level 14 -autopilot
shoot_sequence 11_marsnight_autopilot "6 11" -screen game -mode campaign -level 15 -autopilot
rm -f "$OUT/00_warmup.png"
ls -la "$OUT"
