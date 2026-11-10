# 2026-11-10 — Session 70: v3.0.0 "Starship Program"

## Goals
- Thiago: "Think of a V3 version... Build it. Be super creative. Improve graphics to more realistic. New dynamics, levels, etc."
- Context: v2.3.0 (Session 69) is code complete but not yet on TestFlight; Thiago is away from his computers and asked Jarvis (his home-Mac agent) to run `Scripts/release_testflight.sh`.

## Changes Made

### 1. Campaign Chapter 2 — Starship Program (levels 11–15)
**What:** Starbase (tower chopsticks catch on pad C), Belly Flop (spawn at 90°, flip and burn), Phobos (0.7 g, 45% fuel), Ceres (meteor shower with warnings), Mars Night (darkness + landing light + pad beacons). Briefings on the pre-flight overlay; chapter headers in Level Select; 45 stars.
**Files:** `Models/LevelDefinition.swift`, `GameScene+Chapter2.swift` (new), `GameScene.swift`, `Views/LevelSelectView.swift`, `Views/GameContainerView.swift`, `Views/HowToPlayView.swift`, `Models/CampaignState.swift`, `ContentView.swift`, `Views/LeaderboardView.swift`

### 2. Atmosphere model + reentry plasma
**What:** Attitude-dependent quadratic drag on chapter 2 worlds; plasma glow on the leading face above ~200 pts/s.
**Files:** `GameScene+Chapter2.swift`, `GameScene.swift`

### 3. Ghost replay
**What:** Best landing per Classic/Campaign level recorded at 20 Hz and replayed as a translucent "BEST" ghost.
**Files:** `Models/GhostRun.swift` (new), `GameScene+Chapter2.swift`

### 4. Realistic rendering + folding legs
**What:** Lit brushed-steel hull, soot, gradient flaps, shock diamonds, procedural terrain, boulders, sphere-lit planets with halos/corona, Mars features (previously unused), concrete pads with hazard stripes and floodlight pools; legs stowed until 200 pts altitude.
**Files:** `StarshipArt.swift`, `GameScene+Setup.swift`, `GameScene+Juice.swift`

### 5. Control catch-up window 0.05 → 0.1 s
**Why:** CI simulator frames below 20 fps still under-thrusted (Classic autopilot crash in screenshots).
**Files:** `GameScene.swift`, `GameScene+Chapter2.swift`

### 6. Tests and tooling
**Files:** `RocketLanderTests/ChapterTwoTests.swift` (new), `LevelDefinitionTests.swift`, `CampaignStateTests.swift`, `Scripts/ci_screenshots.sh`, `Scripts/setup_game_center.py`, `RocketLander.xcodeproj/project.pbxproj`, `RocketLander/Info.plist` (3.0.0 / 40)

## Research / Ideas Discussed
- Analog throttle control; chapter 2 Game Center achievements; weekly missions; sonic boom / new audio via `Scripts/generate_sounds.py`; booster (Super Heavy) catch as its own mode.

## Technical Notes
- First CI run: build + all tests green; screenshots showed the tower half off-screen and the night "hole" far too wide — both fixed in the follow-up commit.
- Orange full-screen frames in CI screenshots are the launch screen (AccentColor) during slow simulator relaunches; seen on different levels across runs.

## Decisions
1. Chapter 2 via new campaign levels with defaulted `LevelDefinition` fields so chapter 1 is unchanged (DECISIONS.md).
2. Ghost replay local only (DECISIONS.md).
3. `maxStep` 0.1 s (DECISIONS.md).

## Definition of Done
- [x] CI build + tests green
- [x] Simulator screenshots of all five new levels reviewed
- [x] Docs sweep (STATUS, PROJECT_LOG, CHANGELOG, README, DECISIONS, RELEASE_NOTES, this summary)
- [ ] TestFlight upload (after v2.3.0)
- [ ] Device test of chapter 2 feel

## Commits
- See `git log claude/v300-starship-program` (PR stacked on #4).

## Repo Housekeeping
- [x] Working tree clean
- [x] README structure updated
- [x] No secrets in tracked files

## Next Actions
- [ ] Upload Build 40 after Build 39
- [ ] Create `campaign_11`–`campaign_15` leaderboards in ASC
- [ ] Device-test belly flop timing, night darkness, meteor frequency
