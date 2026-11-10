# 2026-11-10 — Session 69: v2.3.0 "Mission Control" Engagement Update

## Goals
- Thiago: "Improve every aspect of the game — game design, graphics, code, response, fun and playability, new features. Full authority to make a new version and submit it to TestFlight. Don't ask, just go." Also improve the analytics dashboard (separate repo, see its Docs/chats session 07).

## Audit Findings (before changes)
- Sound and Haptics settings toggles were stored but never read.
- Thrust/rotation/fuel applied per frame → engine weaker whenever frames drop.
- Terrain had no collision except Ganymede: missing a pad meant sinking through the hills to a hidden floor at y=10.
- Rocket collision box ended ~11 pts above the feet.
- Level `skyColorTop/Bottom` were defined for all 10 worlds but never used (every world had the same background).
- Blue Stars had no use (earn-only); nothing rewarded ordinary flights.
- Engine flame relied on a missing `RocketFlame.sks` and node filtering hacks; explosion particles were SKShapeNodes spawned via DispatchQueue.

## Changes Made

### 1. Pilot Rank (retention)
**What:** XP for every flight, 10 ranks, landing streaks, 5 Blue Stars per promotion; menu rank card; animated XP panel + promotion banner on game over.
**Files:** `Models/PilotProgress.swift` (new), `Views/ProgressionViews.swift` (new), `Views/GameOverView.swift`, `ContentView.swift`, `GameScene.swift`

### 2. Hangar (Blue Star sink)
**What:** 7 cosmetic paint schemes with matching plume colors; buy with Blue Stars or unlock by rank; live SpriteKit previews; equipped skin used in game and on the menu.
**Files:** `Models/ShipSkin.swift` (new), `Views/HangarView.swift` (new), `StarshipArt.swift` (new), `Models/BlueStarManager.swift`

### 3. Landing feel and guidance
**What:** Approach zoom camera with clamping, shake; descent guide line (green/yellow), ↓speed/ALT readout by the ship, ground dust, Jupiter gust callout; RCS attitude hold; pre-flight prompt + rookie tips; results shown after a short beat.
**Files:** `GameScene+Juice.swift` (new), `GameScene.swift`, `Views/GameContainerView.swift`

### 4. Visual overhaul
**What:** Per-planet sky gradients, horizon glow, distant ridge, sprite starfield (dimmed on bright skies), shooting stars, particle plume + glow, touchdown dust/sparks/ring, explosion flash/shockwave/fireball/smoke/paint-matched debris.
**Files:** `GameScene+Setup.swift`, `GameScene+Effects.swift`, `StarshipArt.swift`

### 5. Bug fixes
**What:** Sound/Haptics settings honored; frame-rate independent controls; solid terrain everywhere; collision box covers legs; menu play buttons above the fold; remembered pilot name.
**Files:** `GameScene+Sound.swift`, `Haptics/HapticManager.swift`, `Models/GameState.swift`, `GameScene.swift`, `GameScene+Setup.swift`, `ContentView.swift`, `Views/GameOverView.swift`

### 6. CI / release tooling
**What:** `claude/**` branches trigger CI; screenshot job using DEBUG-only launch args (`-screen menu|hangar|game`, `-mode`, `-level`, `-autopilot`) publishing PNGs to the `ci-screenshots` branch; TestFlight workflow (API key via GitHub secrets, `testflight/*` tags); `Scripts/release_testflight.sh` for a signed-in Mac.
**Files:** `.github/workflows/ios-ci.yml`, `.github/workflows/testflight.yml` (new), `Scripts/ci_screenshots.sh` (new), `Scripts/release_testflight.sh` (new), `RocketLanderApp.swift` (DebugLaunch), `ContentView.swift`

### 7. Version + docs
- 2.3.0 (Build 39). How To Play: Flight Aids + Pilot Rank & Hangar sections. Removed `Views/ShapeViews.swift`.
- New tests: `PilotProgressTests`, `ShipSkinTests`.

## Research / Ideas Discussed
- Missions/contracts (e.g., "land on 3 Elite pads this week") on top of Pilot Rank.
- Ghost replay of personal best per level.
- Rank-gated Hangar "premium realistic skin" from the earlier concept art.
- In-app analytics events (would need a privacy review per CLAUDE.md before any SDK).

## Technical Notes
- No Mac reachable from the session (device bridge offline); all builds/tests ran on GitHub Actions macOS runners.
- CI simulators render SpriteKit in software at low FPS; this is what exposed the per-frame thrust bug. The classic run also showed the orange launch screen (AccentColor) for ~10 s on one launch — CI slowness, not reproducible in other launches.
- The screenshot job pushes to an orphan `ci-screenshots` branch with `GITHUB_TOKEN` (pushes by GITHUB_TOKEN don't retrigger CI).

## Decisions
1. Pilot Rank + Hangar as the retention loop (DECISIONS.md 2026-11-10).
2. Flight feel fixes at the root (RCS hold, dt scaling, solid terrain, collision box) without changing thresholds or scoring.
3. Release automation that never handles credentials in the session.

## Definition of Done
- [x] Builds on CI (Xcode, iOS simulator)
- [x] Full test suite passes on CI (existing + new tests)
- [x] Simulator screenshots reviewed (menu, hangar, gameplay on several worlds, landing, crash, results)
- [x] Docs sweep (STATUS, PROJECT_LOG, CHANGELOG, README, DECISIONS, RELEASE_NOTES, this summary)
- [ ] TestFlight upload (blocked on credentials — see Next Actions)
- [ ] Device test on a physical iPhone

## Commits
- See `git log claude/v230-mission-control` (PR to `main`).

## Repo Housekeeping
- [x] Working tree clean
- [x] .gitignore up to date (build/ already ignored)
- [x] README project structure matches files
- [x] No secrets or credentials in tracked files

## Next Actions
- [ ] Add GitHub secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` and push tag `testflight/v2.3.0-b39` — or run `Scripts/release_testflight.sh` on the Mac
- [ ] Device-test RCS hold, landing zoom, Hangar purchase flow, sound/haptics toggles
- [ ] Merge the PR, then submit 2.3.0 for review with the RELEASE_NOTES copy
