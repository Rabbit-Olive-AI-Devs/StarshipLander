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
SCORES='[{"name":"Thiago","score":18420,"stars":3},{"name":"Nova","score":16950,"stars":3},{"name":"Orion","score":15280,"stars":2}]'
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

burst() { # prefix frames args...
  local prefix="$1" frames="$2"; shift 2
  xcrun simctl terminate "$SIM_ID" "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl launch "$SIM_ID" "$BUNDLE_ID" "$@" >/dev/null
  sleep 2
  for i in $(seq -w 1 "$frames"); do
    xcrun simctl io "$SIM_ID" screenshot "$OUT/${prefix}_f${i}.png" >/dev/null
    sleep 0.5
  done
  echo "captured $prefix x$frames"
}

# Warm-up launch (first launch is slow on CI)
shoot 00_warmup 12 -screen menu
shoot 01_menu 6 -screen menu "${STATE[@]}" -hangarSelectedSkin lunarGold
shoot 02_hangar 6 -screen hangar "${STATE[@]}" -hangarSelectedSkin synthwave
shoot 03_levels 6 -screen levels "${STATE[@]}"
shoot 04_daily 6 -screen game -mode daily "${STATE[@]}" -hangarSelectedSkin europaIce
burst 10_classic 18 -screen game -mode classic -autopilot -pad b "${STATE[@]}" -hangarSelectedSkin stainless
burst 11_mars 16 -screen game -mode campaign -level 2 -autopilot -pad c "${STATE[@]}" -hangarSelectedSkin redPlanet
burst 12_jupiter 16 -screen game -mode campaign -level 10 -autopilot -pad b "${STATE[@]}" -hangarSelectedSkin synthwave
burst 13_europa 16 -screen game -mode campaign -level 4 -autopilot -pad a "${STATE[@]}" -hangarSelectedSkin europaIce
burst 14_io 16 -screen game -mode campaign -level 9 -autopilot -pad c "${STATE[@]}" -hangarSelectedSkin nightOps
burst 15_moon 16 -screen game -mode campaign -level 1 -autopilot -pad b "${STATE[@]}" -hangarSelectedSkin lunarGold
rm -f "$OUT/00_warmup.png"
ls -la "$OUT"
