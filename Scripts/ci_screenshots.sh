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

# Saved-game state for store-quality captures, passed as launch arguments
# (UserDefaults argument domain), so nothing is written to the simulator.
hex_json() { python3 -c 'import sys; print("<" + sys.argv[1].encode().hex() + ">")' "$1"; }
SCORES='[{"name":"Thiago","score":19640,"stars":3},{"name":"Nova","score":18420,"stars":3},{"name":"Orion","score":17950,"stars":3}]'
CAMPAIGN="$(python3 -c '
import json
top = [{"name": n, "score": s, "stars": 3} for n, s in (("Thiago", 19100), ("Nova", 18800), ("Orion", 18650))]
levels = range(1, 11)
print(json.dumps({
    "unlockedLevels": list(levels),
    "starsByLevel": {str(i): (3 if i < 7 else 2 if i < 10 else 1) for i in levels},
    "scoresByLevel": {str(i): top for i in levels},
    "personalBestScoresByLevel": {str(i): 19100 - i * 420 for i in levels},
}))')"
PROGRESS='{"xp":2650,"landingStreak":6,"bestLandingStreak":11,"totalFlights":212,"totalLandings":148}'
STATE=(
  -topScores "$(hex_json "$SCORES")"
  -campaignState "$(hex_json "$CAMPAIGN")"
  -pilotProgress.v1 "$(hex_json "$PROGRESS")"
  -blueStars 185
  -lastPilotName Thiago
  -hangarOwnedSkins "(stainless,nightOps,redPlanet,lunarGold,europaIce,synthwave)"
)

hover() { # prefix args... : three frames of the ship holding above its pad
  local prefix="$1"; shift
  xcrun simctl terminate "$SIM_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$SIM_ID" "$BUNDLE_ID" -screen game -autopilot -delay 8 "${STATE[@]}" "$@" >/dev/null
  sleep 20
  for i in 1 2 3; do
    xcrun simctl io "$SIM_ID" screenshot "$OUT/${prefix}_f${i}.png" >/dev/null
    sleep 2
  done
  echo "captured $prefix"
}

# Warm-up launch (first launch is slow on CI)
shoot 00_warmup 12 -screen menu
shoot 01_menu 10 -screen menu "${STATE[@]}" -hangarSelectedSkin lunarGold
shoot 02_hangar 10 -screen hangar "${STATE[@]}" -hangarSelectedSkin synthwave
shoot 03_levels 10 -screen levels "${STATE[@]}"
shoot 04_daily 12 -screen game -mode daily "${STATE[@]}" -hangarSelectedSkin europaIce
hover 10_classic -mode classic -pad c -hold 110 -hangarSelectedSkin stainless
hover 11_mars -mode campaign -level 2 -pad b -hold 150 -hangarSelectedSkin redPlanet
hover 12_jupiter -mode campaign -level 10 -pad b -hold 120 -hangarSelectedSkin synthwave
hover 13_europa -mode campaign -level 4 -pad c -hold 130 -hangarSelectedSkin europaIce
hover 14_io -mode campaign -level 9 -pad b -hold 140 -hangarSelectedSkin nightOps
hover 15_moon -mode campaign -level 1 -pad c -hold 100 -hangarSelectedSkin lunarGold
hover 16_daily -mode daily -pad c -hold 120 -hangarSelectedSkin lunarGold
shoot 20_result 30 -screen game -mode classic -autopilot -delay 8 -pad c "${STATE[@]}" -hangarSelectedSkin stainless
rm -f "$OUT/00_warmup.png"
ls -la "$OUT"
