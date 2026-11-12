# Starship Lander

A physics-based rocket landing game for iOS, inspired by SpaceX Starship landings.

**Version:** 2.3.0
**Platform:** iOS 15.0+
**Language:** Swift 5.0
**Frameworks:** SwiftUI, SpriteKit, CoreMotion, GameKit
**Developer:** Rabbit Olive Studios

## Game Overview

Guide your Starship through a controlled descent and land safely on one of three landing platforms. Master thrust control, manage your fuel efficiently, and achieve the perfect landing! Play Classic Mode for free-form practice or tackle Campaign Mode across 10 solar system destinations.

### Features

- **Realistic Physics**: SpriteKit-powered physics simulation
- **Starship Design**: Stylized SpaceX Starship-inspired rocket with stainless body shading, black heat-shield tiles, flaps, engines, and landing legs
- **Three Landing Platforms**: Training Zone (1x), Precision Target (2x), Elite Landing (5x)
- **Campaign Mode**: 10 levels across the solar system with unique gravity and mechanics
- **Dual Control Modes**: Touch buttons or accelerometer (tilt to rotate)
- **Haptic Feedback**: Tactile responses for thrust, rotation, landing, and crashes
- **16-Bit Sound Effects**: Retro chiptune audio for all actions
- **Star Rating System**: Earn 1-3 stars per landing based on platform difficulty
- **Landing Messages**: Contextual feedback with deterministic cause-based crash diagnostics
- **Randomized Crash Headlines**: 20 fun crash messages (SpaceX references, space mission quotes, gaming humor)
- **HUD Tilt Display**: Real-time tilt angle in degrees with directional color coding
- **Final Stats Panel**: HUD-style Flight Data with icons, OK/HARD/FAIL badges, 3-color values, and "RAPID UNSCHEDULED DISASSEMBLY" badge on crashes
- **Campaign Reentry Challenge**: Ships spawn with tilt and drift in Campaign mode
- **Skill-Based Scoring**: Up to 23,100 points with platform and fuel multipliers
- **High Score Leaderboard**: Track your top 3 landings
- **Game Center Integration**: 13 leaderboards (classic + 10 campaign + galaxy_rank + daily_challenge), 10 achievements, Galaxy Rank aggregate
- **Share Score Card**: Generate and share landing results as images via native share sheet
- **Daily Challenge**: New challenge every UTC day, same worldwide. 75 rotating templates with 6 constraint types across all 10 planets. Auto-computed difficulty (1-5★). Countdown timer for timed challenges with time bonus scoring. Pre-challenge briefing screen. See [Daily Challenge Catalog](#daily-challenge-catalog) for full list.
- **Blue Star Currency**: Earn through daily challenges (+1), streaks (+3 bonus at 5 days), and campaign milestones (10/20/30 stars)
- **AdMob Integration**: Banner + interstitial ads with App Tracking Transparency support
- **Pilot Rank (v2.3.0)**: 10 ranks from Cadet to Starship Legend. Every flight earns XP (bonuses for harder pads, clean landings, landing streaks, daily challenges); each promotion awards 5 Blue Stars
- **Hangar (v2.3.0)**: 7 Starship paint schemes (Stainless, Night Ops, Red Planet, Lunar Gold, Europa Ice, Synthwave, Legend) unlocked with Blue Stars or by Pilot Rank; engine plume color matches the livery
- **Cinematic Landing Camera (v2.3.0)**: smooth zoom toward the ship on final approach, camera shake on touchdown/explosions
- **Flight Guidance (v2.3.0)**: descent guide line (green when both legs fit the pad below), on-ship ↓speed/altitude readout colored by the pad's limits, first-flight tips
- **RCS Attitude Hold (v2.3.0)**: spin is damped when rotation input is released (requires fuel)
- **Visual Overhaul (v2.3.0)**: per-planet sky gradients, horizon glow, hazy distant ridges, shooting stars, particle engine plume, ground dust, particle explosions with hull debris, touchdown dust and sparks

### Controls

| Control | Action |
|---------|--------|
| **THRUST** (center) | Fire main engines |
| **L** (left) | Rotate counter-clockwise |
| **R** (right) | Rotate clockwise |
| **Tilt** (accelerometer mode) | Tilt phone left/right to rotate |

Toggle between button and accelerometer controls in the main menu.

### Scoring System

**Continuous scoring with dual multipliers (Max ~23,100 points)**

| Component | Max Points | Description |
|-----------|------------|-------------|
| Base | 100 | Successful landing |
| Soft Landing | 550 | Lower vertical speed = more points |
| Horizontal Precision | 450 | Less drift = more points |
| Platform Center | 600 | Closer to center = more points |
| Rotation | 250 | More upright = more points |
| Approach Control | 150 | Controlled descent = more points |
| **Subtotal** | **2100** | Before multipliers |
| **Fuel Multiplier** | **1.0x - 2.2x** | More fuel = higher multiplier |
| **Platform Multiplier** | **1x / 2x / 5x** | Harder platform = higher multiplier |
| **Maximum** | **~23,100** | Perfect landing + 100% fuel + Platform C |

**Formula:** `subtotal × fuelMultiplier × platformMultiplier`

### Landing Platforms

| Platform | Position | Width | Multiplier | Stars | Color |
|----------|----------|-------|------------|-------|-------|
| A — Training Zone | Left (18%) | 130pt | 1x | 1 | Green |
| B — Precision Target | Center (50%) | 110pt | 2x | 2 | Yellow |
| C — Elite Landing | Right (82%) | 80pt | 5x | 3 | Red |

### Campaign Levels

| # | Name | Gravity | Thrust | Special Mechanic |
|---|------|---------|--------|------------------|
| 1 | Moon | 1.6 | 8.0 | None (tutorial) |
| 2 | Mars | 2.0 | 9.5 | Light dust wind |
| 3 | Titan | 2.2 | 10.0 | Dense atmosphere |
| 4 | Europa | 2.5 | 11.0 | Cryogeysers |
| 5 | Earth | 2.8 | 12.0 | Moving platforms |
| 6 | Venus | 3.2 | 13.0 | Vertical updrafts |
| 7 | Mercury | 3.5 | 14.0 | Heat interference |
| 8 | Ganymede | 3.8 | 15.0 | Deep craters |
| 9 | Io | 4.2 | 16.5 | Deadly volcanic debris |
| 10 | Jupiter | 5.2 | 18.5 | Sudden wind gusts |

*Gravity and thrust increase progressively by level. Each planet has a unique thrust feel — higher gravity levels have more powerful but tighter-margin engines. Values are game-balanced for playability, not real-world accurate.*

## Project Structure

```
StarshipLander/
├── RocketLander/
│   ├── RocketLanderApp.swift        # App entry point, ATT & AdMob init
│   ├── ContentView.swift            # ContentView + MenuView (navigation root)
│   ├── GameScene.swift              # Core update loop, physics, collision
│   ├── GameScene+Setup.swift        # Starfield, terrain, platforms, rocket creation
│   ├── GameScene+Effects.swift      # Engine plume, touchdown, explosions, level effects
│   ├── GameScene+Juice.swift        # Landing camera, flight guidance, dust, hazard callouts, DEBUG autopilot
│   ├── StarshipArt.swift            # Starship node + plume factory, particle textures, Hangar preview scene
│   ├── GameScene+Sound.swift        # All sound methods
│   ├── GameScene+Scoring.swift      # Score calculation, platform detection
│   ├── BannerAdView.swift           # AdMob banner + ad config
│   ├── InterstitialAdManager.swift  # Interstitial ads (every 7 attempts)
│   ├── Info.plist                   # App configuration
│   ├── RocketLander.entitlements    # Game Center capability
│   ├── Models/
│   │   ├── GameState.swift          # ObservableObject game state
│   │   ├── HighScoreManager.swift   # High score persistence
│   │   ├── LandingPlatform.swift    # Platform A/B/C definitions
│   │   ├── LandingMessages.swift    # Success messages + deterministic crash diagnostics
│   │   ├── LandingThresholds.swift  # Per-platform speed bands (SAFE/HARD/FAIL)
│   │   ├── LevelDefinition.swift    # 10 campaign level definitions
│   │   ├── CampaignState.swift      # Campaign progress persistence
│   │   ├── GameCenterManager.swift  # Game Center auth, leaderboards, achievements
│   │   ├── BlueStarManager.swift    # Blue star currency (earn + spend)
│   │   ├── PilotProgress.swift      # Pilot Rank XP, landing streaks, flight stats
│   │   ├── ShipSkin.swift           # Paint schemes + HangarManager (ownership/selection)
│   │   └── DailyChallenge.swift     # Daily challenge spec, constraints, templates
│   ├── Views/
│   │   ├── GameContainerView.swift  # Game container + SpriteKit bridge
│   │   ├── GameOverView.swift       # Game over screen with stars + final stats panel
│   │   ├── HUDViews.swift           # Top HUD + velocity + tilt display
│   │   ├── ControlViews.swift       # Bottom controls + buttons
│   │   ├── HangarView.swift         # Hangar: browse, unlock, equip skins
│   │   ├── ProgressionViews.swift   # Ship preview, Pilot Rank card, XP reward panel
│   │   ├── LeaderboardView.swift     # Dedicated leaderboard screen
│   │   ├── HowToPlayView.swift      # How to Play info sheet
│   │   ├── LevelSelectView.swift    # Campaign level grid
│   │   ├── ShareScoreCardView.swift # Share score card rendering + share helper
│   │   └── DailyChallengeBriefingView.swift # Pre-challenge briefing screen
│   ├── Haptics/
│   │   └── HapticManager.swift      # Haptic feedback manager
│   ├── Assets.xcassets/             # App icons and colors
│   └── Sounds/                      # Audio files
│       ├── thrust.wav               # Engine loop
│       ├── rotate.wav               # Rotation blip
│       ├── land_success.wav         # Victory fanfare
│       └── explosion.wav            # Crash sound
├── RocketLanderTests/
│   ├── ScoringTests.swift             # Scoring formula verification (16 tests)
│   ├── HighScoreManagerTests.swift    # High score persistence (9 tests)
│   ├── CampaignStateTests.swift       # Campaign state management (10 tests)
│   ├── LevelDefinitionTests.swift     # Level data integrity (8 tests)
│   ├── LandingMessagesTests.swift     # Message selection logic (4 tests)
│   ├── GameStateTests.swift           # Game state management (3 tests)
│   ├── LandingPlatformTests.swift     # Platform data verification (5 tests)
│   ├── CrashDiagnosticTests.swift     # Crash classification + determinism (14 tests)
│   ├── LandingEvaluationTests.swift   # Per-platform speed + tilt band tests (20 tests)
│   ├── PilotProgressTests.swift       # Rank thresholds, XP formula, streaks, promotions
│   ├── ShipSkinTests.swift            # Hangar ownership, rank unlocks, Blue Star spending
│   └── ScoringHelper.swift            # Test-only scoring formula replica
├── Docs/
│   ├── chats/                       # Session summaries (context restoration)
│   ├── GROWTH_PLAN.md               # Organic growth strategy (ASO, share triggers, screenshots)
│   └── DIAGNOSTIC_velocity_thresholds.md  # Critical bug analysis (Build 19)
├── Screenshots/
│   ├── v2.0.0/                      # App Store screenshots (1284x2778)
│   ├── v2.0.3-bugs/                 # Bug evidence from v2.0.3 device testing
│   └── achievements/                # Achievement icons (1024x1024 PNG)
├── Scripts/
│   ├── generate_sounds.py           # Sound effect generator
│   ├── generate_icon.py             # App icon generator
│   ├── generate_screenshots.py      # Screenshot generator
│   ├── generate_store_screenshots.py # App Store screenshot set from CI captures (v2.3.0)
│   ├── update_app_store_v230.py     # App Store Connect listing + submission (v2.3.0)
│   ├── release_app_store_version.py # Publish an approved version (or report its review state)
│   ├── caption_screenshots.py       # App Store screenshot captioning
│   ├── calculate_perfect_scores.py  # Perfect landing score analysis
│   ├── setup_game_center.py        # ASC API: create GC leaderboards + achievements + upload images
│   ├── generate_achievement_icons.py # Achievement icon generator (Pillow)
│   ├── app_store_metadata.json      # App Store metadata reference
│   ├── export_chat_transcripts.py   # Claude Code transcript exporter
│   ├── ci_xcodebuild.sh             # CI build + test
│   ├── ci_screenshots.sh            # CI simulator screenshots (DEBUG launch args, seeded state, scripted autopilot)
│   └── release_testflight.sh        # Archive + upload to TestFlight from a signed-in Mac
├── .github/
│   ├── pull_request_template.md     # PR checklist template
│   └── workflows/                   # ios-ci.yml (build/test/screenshots), testflight.yml (upload)
├── RocketLander.xcodeproj           # Xcode project
├── CLAUDE.md                        # Claude Code session guidelines
├── STATUS.md                        # Authoritative project snapshot
├── CHANGELOG.md                     # Version history
├── PROJECT_LOG.md                   # Development session logs (last 10 sessions)
├── PROJECT_LOG_ARCHIVE.md           # Archived session logs (older sessions)
├── RELEASE_NOTES.md                 # App Store release notes
├── DECISIONS.md                     # Architectural/design decision records
└── README.md                        # This file
```

## Development

### Prerequisites

- macOS with Xcode 15.0+
- iOS Simulator or physical device
- Apple Developer Account (for device testing & App Store)
- Python 3 (optional, for sound/icon generation)

### Dependencies

Managed via **Swift Package Manager**:
- Google Mobile Ads SDK (v12.14.0)
- Google User Messaging Platform

### Building

```bash
# Open project
open RocketLander.xcodeproj

# Build for simulator
xcodebuild -scheme RocketLander \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

# Run unit tests
xcodebuild test -scheme RocketLander \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Archive for App Store
xcodebuild -scheme RocketLander \
  -destination 'generic/platform=iOS' \
  -archivePath ./build/RocketLander.xcarchive \
  archive
```

### Regenerating Sound Effects

```bash
python3 Scripts/generate_sounds.py
```

## Technical Specifications

### Game Physics (Classic Mode)
- Gravity: 2.0 units/frame²
- Thrust power: 12.0 velocity/frame
- Rotation power: 0.04 angular velocity/frame (buttons)
- Per-frame values are tuned at 60 fps and scaled by real elapsed time (v2.3.0), so frame drops no longer weaken thrust
- Angular damping: 0.7 while rotating; 2.6 RCS attitude hold when rotation is released (v2.3.0)
- Thrust vectoring: proportional lateral force when tilted while thrusting (0.15 factor)
- Accelerometer sensitivity: 0.06 with 0.1 dead zone

### Landing Thresholds (Per-Platform Speed Bands)

| Platform | V Safe | V Hard | V Fail | H Safe | H Hard | H Fail |
|----------|--------|--------|--------|--------|--------|--------|
| A (Training) | ≤70 | ≤100 | >100 | ≤50 | ≤80 | >80 |
| B (Precision) | ≤50 | ≤75 | >75 | ≤40 | ≤60 | >60 |
| C (Elite) | ≤33 | ≤52 | >52 | ≤28 | ≤48 | >48 |

**Tilt Bands (all platforms):**

| Band | Threshold | Effect |
|------|-----------|--------|
| SAFE | ≤0.05 rad (~2.9°) | Full rotation score |
| HARD | ≤0.10 rad (~5.7°) | Partial credit, landing succeeds |
| FAIL | >0.10 rad (~5.7°) | Crash |

- Velocity and rotation scoring use hard threshold as denominator — smooth curve from max to 0, HARD landings get partial credit
- FAIL (speed or tilt) = crash
- HUD displays Platform C safe thresholds (V<33, H<28) as reference

### Fuel Consumption
- Thrust: 0.27% per frame
- Rotation (buttons): 0.07% per frame
- Rotation (accelerometer): scales with tilt intensity (0.035 × tilt)

## Daily Challenge Catalog

75 unique challenges rotating on a deterministic UTC daily cycle (`dayOfYear % 75`). Every player worldwide gets the same challenge at the same moment. Difficulty is auto-computed based on planet gravity/hazards, number of constraints, constraint tightness, platform requirement, and time pressure (planet-aware).

<details>
<summary><strong>1★ Very Easy (7 challenges)</strong></summary>

| # | Title | Planet | Objectives |
|--:|-------|--------|------------|
| 0 | Target Practice | Moon | Platform B |
| 1 | Easy Does It | Moon | V.Speed < 50 |
| 2 | Stay Level | Moon | Tilt < 3° |
| 3 | Steady Approach | Mars | H.Speed < 25 |
| 4 | Fuel Saver | Moon | Fuel > 40% |
| 5 | Feather Touch | Mars | V.Speed < 45 |
| 10 | Quick Drop | Mars | Time < 20s |

</details>

<details>
<summary><strong>2★ Easy (10 challenges)</strong></summary>

| # | Title | Planet | Objectives |
|--:|-------|--------|------------|
| 6 | Steady Hands | Titan | Tilt < 2.5° |
| 7 | Fuel Miser | Moon | Fuel > 50% |
| 8 | Speed Run | Moon | Time < 15s, Platform A |
| 9 | Zero Drift | Mars | H.Speed < 18 |
| 11 | Titan Target | Titan | Platform B |
| 12 | Moon Elite | Moon | Platform C |
| 13 | Smooth Operator | Mars | V.Speed < 40, Tilt < 3° |
| 14 | Dense Efficiency | Titan | Fuel > 45% |
| 22 | Ice Level | Europa | Tilt < 2° |
| 28 | Titan Express | Titan | Time < 22s |

</details>

<details>
<summary><strong>3★ Moderate (23 challenges)</strong></summary>

| # | Title | Planet | Objectives |
|--:|-------|--------|------------|
| 15 | Precision Descent | Europa | Platform C |
| 16 | Whisper Landing | Earth | V.Speed < 35, H.Speed < 25 |
| 17 | Fuel Master | Venus | Fuel > 40% |
| 18 | Razor's Edge | Mercury | Platform B |
| 19 | Lightning Strike | Europa | Time < 22s, Platform B |
| 20 | Hover Expert | Titan | V.Speed < 40, Fuel > 35% |
| 21 | Speed Demon | Earth | Time < 18s |
| 23 | Barge Hunter | Earth | Platform B, V.Speed < 40 |
| 24 | Venus Calm | Venus | Tilt < 2.5°, V.Speed < 45 |
| 26 | Mars Bullseye | Mars | Platform C, Tilt < 2.5° |
| 27 | Europa Thrift | Europa | Fuel > 35%, Platform B |
| 29 | Efficient Barge | Earth | Fuel > 40% |
| 30 | Venus Target | Venus | Platform B |
| 31 | Mercury Reserve | Mercury | Fuel > 35% |
| 32 | Moon Sprint | Moon | Time < 18s, Platform C |
| 33 | Geyser Dodge | Europa | V.Speed < 38, Tilt < 2.5° |
| 34 | Mars Rush | Mars | Time < 18s, Platform B |
| 35 | Titan Elite | Titan | Platform C, Fuel > 30% |
| 37 | Mercury Dash | Mercury | Time < 20s |
| 38 | Venus Feather | Venus | V.Speed < 42 |
| 39 | Mars Balance | Mars | Fuel > 45%, V.Speed < 42 |
| 42 | Conservation | Io | Fuel > 30% |
| 48 | Crater Sprint | Ganymede | Time < 20s |

</details>

<details>
<summary><strong>4★ Hard (22 challenges)</strong></summary>

| # | Title | Planet | Objectives |
|--:|-------|--------|------------|
| 25 | Mercury Crawl | Mercury | V.Speed < 40, H.Speed < 22 |
| 36 | Barge Surgeon | Earth | Tilt < 2°, H.Speed < 20 |
| 40 | Elite Touch | Ganymede | Platform C, Tilt < 3° |
| 41 | Gentle Giant | Jupiter | V.Speed < 50 |
| 43 | Total Control | Venus | Tilt < 2°, H.Speed < 20 |
| 44 | Crater Glide | Ganymede | V.Speed < 38, Fuel > 30% |
| 45 | Io Precision | Io | Platform B, Tilt < 2.5° |
| 46 | Jupiter Target | Jupiter | Platform B |
| 47 | Mercury Elite | Mercury | Platform C, V.Speed < 40 |
| 49 | Io Whisper | Io | V.Speed < 45, H.Speed < 25 |
| 50 | Venus Elite | Venus | Platform C, Fuel > 30% |
| 51 | Wind Walker | Jupiter | H.Speed < 25 |
| 52 | Ganymede Thrift | Ganymede | Platform B, Fuel > 35% |
| 53 | Io Blitz | Io | Time < 20s, Platform A |
| 54 | Mercury Surgeon | Mercury | Tilt < 1.5°, V.Speed < 38 |
| 55 | Barge Blitz | Earth | Platform C, Time < 18s |
| 56 | Europa Triple | Europa | Platform C, V.Speed < 35, Fuel > 25% |
| 57 | Venus Sprint | Venus | Time < 18s, V.Speed < 42 |
| 58 | Volcanic Elite | Io | Platform C |
| 59 | Jupiter Steady | Jupiter | Tilt < 3°, Fuel > 20% |
| 71 | Jupiter Express | Jupiter | Time < 18s |
| 73 | Venus Lightning | Venus | Time < 16s, Platform B |

</details>

<details>
<summary><strong>5★ Expert (13 challenges)</strong></summary>

| # | Title | Planet | Objectives |
|--:|-------|--------|------------|
| 60 | Absolute Precision | Ganymede | Platform C, V.Speed < 35, Tilt < 2° |
| 61 | Impossible Landing | Jupiter | Platform C, Fuel > 25% |
| 62 | Io Masterclass | Io | Platform C, Tilt < 2°, Fuel > 25% |
| 63 | Jupiter Surgeon | Jupiter | V.Speed < 40, H.Speed < 20, Tilt < 2.5° |
| 64 | Crater Blitz | Ganymede | Platform C, Time < 18s |
| 65 | Io Rush | Io | Platform B, V.Speed < 38, Time < 20s |
| 66 | Storm Rider | Jupiter | Platform B, V.Speed < 42, Fuel > 20% |
| 67 | Mercury Perfection | Mercury | Platform C, Tilt < 1.5°, V.Speed < 35 |
| 68 | Venus Mastery | Venus | Platform C, Tilt < 2°, Fuel > 30% |
| 69 | Barge Perfect | Earth | Platform C, V.Speed < 30, H.Speed < 18 |
| 70 | Io Zen | Io | Fuel > 35%, V.Speed < 40, Tilt < 2° |
| 72 | Ganymede Triple | Ganymede | Platform C, Fuel > 30%, Tilt < 2° |
| 74 | The Final Test | Jupiter | Platform C, V.Speed < 40, Tilt < 2° |

</details>

### Difficulty Distribution

| Difficulty | Count | % of Total |
|-----------|------:|----------:|
| 1★ Very Easy | 7 | 9% |
| 2★ Easy | 10 | 13% |
| 3★ Moderate | 23 | 31% |
| 4★ Hard | 22 | 29% |
| 5★ Expert | 13 | 17% |
| **Total** | **75** | **100%** |

### Planet Distribution

| Planet | Count |
|--------|------:|
| Moon | 8 |
| Mars | 8 |
| Titan | 6 |
| Europa | 6 |
| Earth | 7 |
| Venus | 9 |
| Mercury | 7 |
| Ganymede | 7 |
| Io | 8 |
| Jupiter | 9 |

### Constraint Type Usage

| Constraint | Appearances |
|-----------|----------:|
| Platform | 36 |
| V.Speed | 26 |
| H.Speed | 10 |
| Tilt | 21 |
| Fuel | 22 |
| Time | 16 |

---

## App Store

**Available on the App Store**: [Starship Lander](https://apps.apple.com/app/starship-lander/id6757563869)

**Developer Website**: https://rabbitolivestudios.github.io

## License

Proprietary - All rights reserved.
© 2026 Rabbit Olive Studios

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

| Version | Date | Description |
|---------|------|-------------|
| 2.3.0 | Build 39 (TestFlight) | Mission Control update: Pilot Rank XP, Hangar skins, cinematic landing camera, flight guidance, RCS hold, visual overhaul, solid terrain, sound/haptics settings fix, frame-rate independent controls |
| 2.2.1 | Build 38 Submitted | Campaign startup crash fix; local SSD Xcode and GitHub Actions CI verified; submitted for App Store review |
| 2.2.0 | Build 37 Published | Daily Challenge, Blue Stars, interstitial ads, global rank on game-over; approved/distributed 2026-05-03 but affected by Campaign startup crash |
| 2.1.1 | 2026-02-06 | Share card redesign: crash sharing, compact colored stats, App Store link |
| 2.1.0 | 2026-02-06 | **Live on App Store** — Game Center: 12 leaderboards, 10 achievements, Galaxy Rank, share card |
| 2.0.3 | 2026-02-06 | Scoring rebalance, tilt bands, Europa cryogeysers, HUD-style Flight Data, randomized crash messages |
| 2.0.2 | 2026-02-03 | Campaign polish: scoring, thrust vectoring, planet differentiation |
| 2.0.1 | 2026-01-31 | Dedicated leaderboard screen, version label fix |
| 2.0.0 | 2026-01-30 | Campaign mode, per-planet physics, visual effects |
| 1.1.5 | 2026-01-16 | New scoring system, HUD fixes, version display |
| 1.1.4 | 2026-01-15 | Complete fix for high score input bug, new icon |
| 1.1.3 | 2026-01-14 | Developer website URLs |
| 1.1.2 | 2026-01-12 | Accelerometer controls, reduced rotation sensitivity |
| 1.1.0 | 2026-01-10 | AdMob integration, App Tracking Transparency |
| 1.0.0 | 2026-01-08 | Initial App Store release |
