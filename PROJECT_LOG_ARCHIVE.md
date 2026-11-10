# Starship Lander — Project Log Archive

> **Archived sessions from PROJECT_LOG.md.** Sessions 1-57 (2026-01-07 through 2026-02-06).
> Moved here to keep PROJECT_LOG.md under size limits.
>
> For current project state, see `PROJECT_LOG.md`. For authoritative snapshot, see `STATUS.md`.
> For decision rationale, see `DECISIONS.md`.

---

## Project History Summary

Key milestones from Sessions 1-48:

- **Sessions 1-3 (Jan 7-8)**: Initial development, v1.0 submission. Core SpriteKit physics, thrust/rotation controls, fuel system, terrain generation, high scores.
- **Sessions 4-6 (Jan 8-10)**: AdMob integration, ATT prompt (v1.0 rejected for missing ATT, fixed in v1.1).
- **Sessions 7-9 (Jan 12-15)**: v1.1 published. Accelerometer controls added. TextField bug fix saga (3 attempts across v1.1.1-v1.1.4).
- **Session 10 (Jan 16)**: v1.1.5 — continuous scoring system, HUD fixes, App Store screenshots.
- **Sessions 11-19 (Jan 30)**: Massive v2.0.0 sprint. File split (2→21 files). Campaign mode (10 levels), three landing platforms, per-planet physics/thrust, visual effects, haptics, star ratings, landing messages, Ganymede craters, astronaut easter eggs. App Store submission.
- **Sessions 20-28 (Jan 31)**: STATUS.md created. Dedicated leaderboard (v2.0.1). v2.1.0/v2.2.0 planning (Game Center, IAP). TestFlight setup. Device testing revealed accelerometer bug (fixed). v2.0.2 campaign polish (scoring rebalance, thrust vectoring, planet differentiation).
- **Session 29 (Feb 1)**: Replaced v2.0.0 submission with v2.0.2 (Build 16).
- **Session 30 (Feb 1)**: Added 89 unit tests (XCTest) across 10 test files.
- **Session 31 (Feb 1)**: Perfect landing score analysis script (all 33 level/platform combos).
- **Session 32 (Feb 1)**: v2.0.3 campaign engagement — reentry state, tilt HUD, flight stats panel, deterministic crash diagnostics.
- **Sessions 33-34 (Feb 1)**: CRITICAL discovery — velocity thresholds were dead code since initial commit. SpriteKit zeros velocities before collision callback. All prior builds accepted any-speed landings.
- **Session 35 (Feb 1)**: Scoring overhaul — per-platform speed bands (SAFE/HARD/FAIL), removed explicit HARD penalty (natural velocity loss is the penalty), post-thrust velocity tracking, HUD threshold fix. Build 21 uploaded to TestFlight.
- **Session 36 (Feb 1)**: Menu ad banner clipping fix, Build 22 uploaded.
- **Session 37 (Feb 1)**: Code housekeeping — removed dead code, fixed imports, deleted stale files. Tests 90→89.
- **Session 38 (Feb 2)**: Device testing bug fixes — text truncation, menu ad moved outside ScrollView.
- **Sessions 39-41 (Feb 2)**: Build 23-24 TestFlight uploads. How To Play info sheet replacing inline section.
- **Session 42 (Feb 2)**: Build hygiene — .gitignore hardened, prints wrapped in DEBUG, ATT optimized, player name capped.
- **Session 43 (Feb 2)**: Documentation cleanup, credential protection guardrails added to CLAUDE.md, git history cleanup.
- **Session 44 (Feb 2)**: Build 25 TestFlight upload.
- **Session 45 (Feb 3)**: Flight Data panel HUD-style redesign, randomized crash headlines (20 messages), PROJECT_LOG archiving workflow established. Build 26.
- **Session 46 (Feb 5)**: v2.0.3 gameplay feedback — 10 fixes including speed threshold tightening, Jupiter wind overhaul, Europa ice effect, celestial body corrections. Build 27.
- **Session 47 (Feb 5)**: Europa cryogeysers replacing punishing ice slide. Build 28.
- **Session 48 (Feb 5)**: Scoring rebalance (HARD partial credit, component boost, fuel tuning), tilt bands (SAFE/HARD/FAIL). Tests 89→91. Build 30 submitted for App Store.

---

## Archived Session Entries

### Session 1 (2026-01-07) - Initial Development
- Created core game with SpriteKit physics
- Implemented thrust and rotation controls
- Added fuel management system
- Created landing detection logic
- Built procedurally generated terrain
- Added high score leaderboard (top 3)
- Created placeholder for AdMob ads

### Session 2 (2026-01-08) - v1.0 Enhancements
- **Starship Redesign:** Changed rocket visual to resemble SpaceX Starship
  - Cylindrical silver body with dome nose
  - 2 forward flaps, 2 aft flaps (dark gray)
  - 3 engine nozzles with landing legs
  - Updated menu illustration to match

- **Sound Effects:** Added 16-bit retro sounds
  - `thrust.wav` - Engine loop while thrusting
  - `rotate.wav` - Blip on rotation input
  - `land_success.wav` - Victory fanfare
  - `explosion.wav` - Crash sound
  - Generated via Python script (`Scripts/generate_sounds.py`)

- **Scoring System Revamp:**
  - Base: 100 points
  - Fuel efficiency: 0-500 points (exponential, main differentiator)
  - Soft landing: 0-300 points
  - Horizontal precision: 0-200 points
  - Platform center: 0-150 points
  - Rotation precision: 0-100 points
  - Approach control: 0-100 points
  - Max possible: ~1450 points

- **High Score Flow:** Simplified - name input appears directly when score qualifies

- **Bug Fix:** Thrust sound not playing - fixed with URL-based SKAudioNode initializer

### Session 3 (2026-01-08) - v1.0 Submission
- Removed ad placeholders for clean initial release
- Updated bundle ID to com.tboliveira.StarshipLander
- Configured Xcode signing with Apple Developer account
- Registered test device (iPhone 16 TBO)
- Successfully archived and uploaded v1.0 (build 2) to App Store Connect
- Submitted for Apple review

### Session 4 (2026-01-08) - v1.1 AdMob Integration
- User added Google Mobile Ads SDK via Swift Package Manager
- Updated `BannerAdView.swift` with real GADBannerView implementation
- Updated `RocketLanderApp.swift` to initialize Mobile Ads SDK
- Added banner ads to menu and game screens in `ContentView.swift`
- Configured Info.plist with AdMob App ID
- Updated API calls for latest SDK (BannerView, Request, AdSizeBanner)
- Updated version to 1.1 (build 3)
- Successfully archived and uploaded to App Store Connect
- **Waiting for v1.0 approval before submitting v1.1**

### Session 5 (2026-01-08) - v1.2 Planning
- Discussed v1.2 feature options
- Selected: **Haptic Feedback** + **Campaign Mode**
- Refined campaign concept to **Solar System Theme**
- Each level = a celestial body with unique physics and visuals
- Created detailed implementation plan

### Session 6 (2026-01-10) - App Store Rejection Fix
- v1.0 rejected for Guideline 5.1.2 (tracking without ATT permission)
- Root cause: App Privacy indicated Device ID tracking, but no ATT prompt
- Solution: Implement App Tracking Transparency for v1.1
- Added `AppTrackingTransparency` framework
- ATT permission prompt on app launch
- Added `NSUserTrackingUsageDescription` to Info.plist
- Updated build to 4
- Uploaded v1.1 (build 4) to App Store Connect
- **v1.1 (build 4) SUBMITTED FOR REVIEW**

### Session 7 (2026-01-12) - v1.1 Published + Bug Fixes + Accelerometer

**v1.1 APPROVED AND PUBLISHED!**

**Bugs Found After Release:**
1. High score name TextField restarts game when tapped
2. Ads not showing (expected - AdMob takes 24-48h for new apps)

**v1.1.1 Bug Fixes (Build 5):**
- Fixed TextField restart by hiding `BottomControlsView` when `gameOver` is true
- Added `BannerViewDelegate` for ad loading diagnostics
- Did not upload - superseded by v1.1.2

**v1.1.2 Control Improvements (Build 6):**
- User reported rotation controls too sensitive
- Implemented BOTH fixes:
  1. Reduced button rotation power (0.05 -> 0.025)
  2. Added accelerometer controls option

**Accelerometer Implementation:**
- CoreMotion framework for device tilt detection
- Dead zone (0.1) prevents drift when holding phone level
- Sensitivity (0.06) for smooth rotation response
- Fuel consumption scales with tilt intensity
- Settings toggle in MenuView with UserDefaults persistence
- Dynamic UI: rotation buttons hidden in accelerometer mode

### Session 8 (2026-01-14) - v1.1.3 Bug Fix + Developer Website

**v1.1.2 APPROVED AND PUBLISHED!**

- High score TextField still not working (game restarts on tap)
- GitHub Pages Setup: rabbitolivestudios.github.io
- v1.1.3 Bug Fix (Build 7): Added `.allowsHitTesting(!gameState.gameOver)`
- App Store Connect URLs Updated

**v1.1.3 PUBLISHED** (2026-01-14)

### Session 9 (2026-01-15) - v1.1.4 Complete TextField Bug Fix

- Root cause: `didChangeSize()` calling `setupScene()` when keyboard appeared
- Fix: Added `!gameState.gameOver` check in `didChangeSize()`
- New Starship App Icon
- v1.1.4 (build 10) uploaded
- **PUBLISHED** (2026-01-15)

### Session 10 (2026-01-16) - v1.1.5 Scoring System + Screenshots

- Redesigned scoring from tier-based to continuous with fuel multiplier
- Max ~5000 points (subtotal 2000 x 2.5 fuel multiplier)
- HUD text wrapping fixes
- Version number display on menu
- New App Store screenshots
- v1.1.5 (build 11) **SUBMITTED FOR REVIEW**

### Session 11 (2026-01-30) - v1.2 Major Implementation

**Massive codebase restructure and feature implementation.**

#### Phase 0: File Splitting
Split 2 monolithic files (~900 lines each) into 21 organized files across 4 directories:

**New Directory Structure:**
```
RocketLander/
├── Models/              (6 files)
│   ├── GameState.swift          — ObservableObject with new platform/campaign properties
│   ├── HighScoreManager.swift   — High score persistence
│   ├── LandingPlatform.swift    — Platform A/B/C enum (widths, multipliers, colors)
│   ├── LandingMessages.swift    — Success/crash messages with teaching nudges
│   ├── LevelDefinition.swift    — 10 campaign levels (gravity, visuals, mechanics)
│   └── CampaignState.swift      — Campaign persistence (unlocked levels, stars, scores)
├── Views/               (6 files)
│   ├── ShapeViews.swift         — RocketIllustration, StarshipBody, Parallelogram, Triangle
│   ├── HUDViews.swift           — TopHUDView, VelocityHUDView
│   ├── ControlViews.swift       — BottomControlsView, ControlButton, ThrustButton
│   ├── GameContainerView.swift  — GameContainerView + GameSceneView UIViewRepresentable
│   ├── GameOverView.swift       — Game over with stars, platform info, campaign buttons
│   └── LevelSelectView.swift    — Campaign level grid (lock/unlock, stars, best scores)
├── Haptics/             (1 file)
│   └── HapticManager.swift      — Thrust, rotation, landing, crash haptics
├── GameScene.swift              — Core update loop, physics, collision, campaign mechanics
├── GameScene+Setup.swift        — Scene setup: starfield, terrain, platforms, rocket
├── GameScene+Effects.swift      — Flames, explosions, success particles, shimmer, volcanic
├── GameScene+Sound.swift        — All sound methods
├── GameScene+Scoring.swift      — Scoring with platform multiplier
├── ContentView.swift            — ContentView + MenuView (Classic/Campaign buttons)
├── BannerAdView.swift           — AdMob (unchanged)
├── RocketLanderApp.swift        — App entry (unchanged)
└── Info.plist
```

#### Phase 1: Core Gameplay Improvements (v1.2)

**1.1 Lateral Control Fix:**
- `rotationPower`: 0.025 -> 0.04 (60% increase)
- `angularDamping`: 1.0 -> 0.7 (30% reduction)
- Lateral assist: when rocket tilted >5deg, small horizontal nudge (~2.0 units) applied in tilt direction (simulates RCS thrusters)

**1.2 Three Landing Platforms:**
| Platform | Position | Width | Multiplier | Lights | Stars |
|----------|----------|-------|------------|--------|-------|
| A "Training Zone" | x=18% | 130pt | 1x | Green | 1 |
| B "Precision Target" | x=50% | 110pt | 2x | Yellow | 2 |
| C "Elite Landing" | x=82% | 80pt | 5x | Red | 3 |

- Rocket starts from upper-left (x=15%, y=height-100)
- Terrain generates valleys around each platform position
- Each platform has label + multiplier text below it
- On collision, determines which platform was contacted
- **Scoring:** `finalScore = subtotal * fuelMultiplier * platformMultiplier`
- Max theoretical: 2000 * 2.5 * 5 = 25,000 points

**1.3 Landing Messages:**
- Success messages rotate: "Landing confirmed.", "Precision achieved.", etc.
- Elite (platform C): "Elite landing.", "Near-perfect execution."
- Rare message (1/50 chance, score > 4500): "This was exceptional."
- Crash messages: "Descent unstable." + teaching nudge ("Try a slower approach.")
- Star display: 1-3 stars based on platform landed on

**1.4 Haptic Feedback:**
- Thrust: light continuous pulse every 100ms while thrusting
- Rotation: medium impact on rotation start
- Landing: success notification haptic
- Crash: heavy double-tap impact

#### Phase 2: Campaign Mode (v1.3 features, implemented early)

**10 Campaign Levels:**
| # | Name | Gravity | Special Mechanic |
|---|------|---------|------------------|
| 1 | Moon | -1.6 | None (tutorial) |
| 2 | Mars | -3.7 | Light dust wind (constant force) |
| 3 | Titan | -1.4 | Dense atmosphere (high linear damping) |
| 4 | Europa | -1.3 | Ice surface (low friction platforms) |
| 5 | Earth | -9.8 | Moving barge (platform B oscillates) |
| 6 | Venus | -8.9 | Heavy turbulence (sine-wave variable wind) |
| 7 | Mercury | -3.7 | Heat shimmer (visual distortion effect) |
| 8 | Ganymede | -1.4 | Deep craters (elevated terrain between platforms) |
| 9 | Io | -1.8 | Volcanic eruptions (particle emissions from terrain) |
| 10 | Jupiter | -24.8 | Extreme wind gusts (strong oscillating force) |

**Campaign System:**
- `CampaignState` persisted to UserDefaults via Codable
- Level 1 always unlocked; completing a level unlocks the next
- Stars: best per level (platform A=1, B=2, C=3)
- Per-level high scores (top 3)
- Total stars displayed on menu (/30 max)

**UI Changes:**
- Menu: "CLASSIC" button (orange) + "CAMPAIGN" button (blue/purple)
- Level select grid: 2-column layout, lock/unlock states, stars, best scores, descriptions
- Game over: stars display, platform name + multiplier, "Next Level" button in campaign mode

**GameScene Campaign Integration:**
- Gravity set from `LevelDefinition` for each level
- Unique sky/terrain/celestial body visuals per level
- Special mechanics applied per-frame in update loop:
  - Wind forces (constant, sine-wave, extreme)
  - Moving platform (platform B oscillation with bounds)
  - Dense atmosphere (increased linear damping)
  - Ice surface (low friction physics bodies)
  - Heat shimmer (visual distortion action)
  - Volcanic eruptions (periodic particle emissions)
  - Deep craters (elevated terrain generation)

**Files Created:** 17 new files
**Files Modified:** ContentView.swift, GameScene.swift, project.pbxproj
**Build Status:** Compiles with 0 errors, 0 warnings

**Chat Transcript Export:**
- Created `Scripts/export_chat_transcripts.py` to convert JSONL transcripts to readable Markdown
- Exports user messages and assistant text responses
- Saves to `Docs/ChatTranscripts/` directory

---

## Key Files

| File | Purpose |
|------|---------|
| `RocketLander/ContentView.swift` | ContentView + MenuView (Classic/Campaign navigation) |
| `RocketLander/GameScene.swift` | Core update loop, physics, collision, campaign mechanics |
| `RocketLander/GameScene+Setup.swift` | Scene setup: starfield, terrain, 3 platforms, rocket |
| `RocketLander/GameScene+Effects.swift` | Flames, explosions, success particles, level effects |
| `RocketLander/GameScene+Sound.swift` | All sound methods |
| `RocketLander/GameScene+Scoring.swift` | Scoring with platform multiplier |
| `RocketLander/Models/GameState.swift` | Game state ObservableObject |
| `RocketLander/Models/HighScoreManager.swift` | High score persistence |
| `RocketLander/Models/LandingPlatform.swift` | Platform A/B/C definitions |
| `RocketLander/Models/LandingMessages.swift` | Landing/crash messages |
| `RocketLander/Models/LevelDefinition.swift` | 10 campaign level definitions |
| `RocketLander/Models/CampaignState.swift` | Campaign persistence |
| `RocketLander/Views/ShapeViews.swift` | Rocket illustration + shapes |
| `RocketLander/Views/HUDViews.swift` | Top HUD + velocity display |
| `RocketLander/Views/ControlViews.swift` | Bottom controls + buttons |
| `RocketLander/Views/GameContainerView.swift` | Game container + SpriteKit bridge |
| `RocketLander/Views/GameOverView.swift` | Game over screen with stars/campaign |
| `RocketLander/Views/LevelSelectView.swift` | Campaign level select grid |
| `RocketLander/Haptics/HapticManager.swift` | Haptic feedback manager |
| `RocketLander/BannerAdView.swift` | AdMob banner integration |
| `RocketLander/RocketLanderApp.swift` | App entry point, SDK init |
| `RocketLander/Info.plist` | App configuration |
| `Scripts/export_chat_transcripts.py` | Chat transcript exporter |

---

## Git Information

- **Repository:** Local git repo
- **Current Branch:** main
- **Latest Tag:** v1.1.0

---

## Known Issues / Future Work

1. **dSYM Warnings:** Upload shows warnings for GoogleMobileAds.framework - harmless

2. **v2.0.0 Testing Needed:**
   - Test all 3 platforms on physical device
   - Test haptics on physical device
   - Test all 10 campaign levels with per-level thrust
   - Verify campaign persistence across app restarts
   - Test level unlock progression
   - Verify visual effects on device (wind, haze, ice, eruptions)

3. **Campaign Gravity + Thrust:** **RESOLVED (Sessions 17-18)**
   - Gravity: monotonically increasing -1.6 → -4.8
   - Thrust: per-level scaling 8.0 → 18.5 (ratio 5.0x → 3.8x)
   - All levels landable with distinct feel per planet

4. **Phase 3 Planned (v2.1):**
   - Game Center leaderboards (1 classic + 10 level)
   - "Support Development" IAP (remove ads)
   - Share Score card
   - Achievements ("Fuel Master", "Zero Drift", "Elite Pilot")

5. **Phase 4 Planned (v2.2):**
   - Weekly Challenge (deterministic from week number, no server)
   - Social link in settings
   - Easter eggs (land with 0% fuel, score 1969, perfect rotation on C)

---

## Troubleshooting Notes

### Thrust Sound Not Playing
- **Problem:** SKAudioNode with `fileNamed:` initializer didn't work
- **Solution:** Use URL-based initializer and explicit `SKAction.play()`

### CocoaPods Installation Failed
- **Problem:** System Ruby 2.6 too old for latest CocoaPods
- **Solution:** Used Swift Package Manager instead for Google Mobile Ads

### Xcode Signing "Communication with Apple failed"
- **Problem:** No registered devices
- **Solution:** Connect iPhone, trust computer, register device UDID

### Google Mobile Ads API Changes
- **Problem:** `GADBannerView` renamed to `BannerView`
- **Solution:** Update class names: `BannerView`, `Request`, `AdSizeBanner`, `MobileAds.shared`

---

### Session 12 (2026-01-30) - Campaign UX Improvements

**Per-level high scores, level name HUD, and level details on menu.**

#### Changes Made:
1. **Per-level high scores in campaign mode**: High scores are now separate per level/planet in campaign mode. Classic mode retains its own global leaderboard. `CampaignState.isHighScore()` checks against per-level top-3 scores. `GameOverView.saveScore()` routes to the correct storage based on game mode.

2. **Level name on HUD during campaign**: When playing in campaign mode, the planet/level name (e.g., "MOON", "MARS") is displayed at top center of the screen in `TopHUDView`.

3. **Gravity and mechanics on level select**: Each level card in `LevelSelectView` now shows gravity value (e.g., "1.6 m/s²") and special mechanic name (e.g., "Light Wind") for unlocked levels. Added `displayName` computed property to `SpecialMechanic` enum.

4. **Button wrapping fix**: Fixed game over action buttons (Menu/Next/Retry) wrapping text in campaign mode by reducing padding and adding `lineLimit(1)`.

#### Files Modified:
- `RocketLander/Models/LevelDefinition.swift` — Added `SpecialMechanic.displayName`
- `RocketLander/Models/CampaignState.swift` — Added `isHighScore(for:score:)`
- `RocketLander/Views/HUDViews.swift` — Added level name display in campaign
- `RocketLander/Views/LevelSelectView.swift` — Added gravity + mechanic to level cards
- `RocketLander/Views/GameOverView.swift` — Per-mode high score check and save, button fix

### Session 13 (2026-01-30) - Visual Polish

**Planet name centering, celestial body detail, and Starship redesign.**

#### Changes Made:
1. **Planet name truly centered**: Switched TopHUDView from HStack with Spacers to ZStack overlay so the level name is always screen-centered regardless of back button/fuel gauge widths.

2. **Detailed celestial bodies**: All background planets now have surface features:
   - **Earth**: Green continents (5 blobs), white polar ice caps, cloud wisps
   - **Mars**: Dark maria regions, polar cap, Olympus Mons hint
   - **Jupiter**: Horizontal cloud bands (5 layers), Great Red Spot
   - **Venus**: Thick cloud bands
   - **Saturn**: Subtle bands, multi-layer rings (back + front + inner)
   - **Europa**: Ice crack lines (8 random fractures)
   - **Io**: Volcanic spots (yellow/orange/red)
   - **All planets**: Terminator shadow (dark crescent for 3D), atmospheric glow for planets with atmosphere, improved crater depth with inner shadows

3. **Improved Starship design** (SpriteKit + SwiftUI menu):
   - Wider body (24→26pt), taller (65→70pt)
   - Darker metallic color palette with visible body highlight strip
   - Panel seam lines (3 horizontal + 1 vertical) for industrial look
   - Larger forward flaps (14→16pt outer) and aft flaps (16→18pt outer)
   - Hinge detail lines at flap attachment points
   - Wider engine skirt with tapered nozzles (bell shape)
   - Inner nozzle glow details
   - Sturdier landing legs with foot pads
   - Menu illustration updated to match with Trapezoid shape

#### Files Modified:
- `RocketLander/Views/HUDViews.swift` — ZStack centering for level name
- `RocketLander/GameScene+Setup.swift` — Celestial body features, improved rocket
- `RocketLander/Views/ShapeViews.swift` — Updated menu rocket, added Trapezoid shape

### Session 14 (2026-01-30) - Gameplay Balance & Platform Movement

**Fixed unplayable Earth gravity and added per-platform movement.**

#### Changes Made:
1. **Scaled thrust to gravity**: Campaign levels now scale thrust power to `abs(gravity) × 4.5`. This ensures consistent difficulty feel across all levels (classic mode keeps thrust=12.0 with gravity=-2.0, giving 6x ratio; campaign gives 4.5x ratio — harder but playable). Earth at -9.8 now has thrust=44.1 instead of 12.0.

2. **Per-platform movement on Earth**: All three platforms now move on the Earth (moving platform) level:
   - **Platform A** (Training Zone): Slow vertical bob, ±20px at 15px/s
   - **Platform B** (Precision Target): Horizontal sway, ±80px at 40px/s (main barge)
   - **Platform C** (Elite Landing): Horizontal ±50px at 55px/s + sine-wave vertical bob — hardest to land on

#### Revision (same session):
Reverted thrust scaling (not needed). Instead rebalanced all gravity values to game-friendly range:
- Moon: -1.6, Mars: -3.7, Titan: -1.4, Europa: -1.3
- **Earth: -9.8 → -4.5 → -3.5** (Session 15), **Venus: -8.9 → -4.2**, Mercury: -3.7
- Ganymede: -1.4, Io: -1.8, **Jupiter: -24.8 → -6.0**

Fixed platform movement bounds — each platform now stays within its own zone (left/center/right) with smaller, controlled displacements (±15-50px) instead of wandering across the screen.

#### Files Modified:
- `RocketLander/GameScene.swift` — Reverted thrust scaling, per-platform movement with zone bounds
- `RocketLander/Models/LevelDefinition.swift` — Rebalanced gravity values for Earth, Venus, Jupiter

### Session 15 (2026-01-30) - Dynamic Island Fix, Menu Layout, Platform Overlap & Gravity Tuning

**Bug fixes and UI improvements from simulator testing on iPhone 16 Pro.**

#### Issues Reported:
1. Game title "STARSHIP" cut off by Dynamic Island on iPhone 16+
2. Earth level gravity too strong — continuous thrust could not decelerate the lander
3. Earth level moving platforms overlapping each other
4. "HOW TO PLAY" section cut off at bottom of main menu

#### Changes Made:

**1. Dynamic Island / Menu Layout Fix (`ContentView.swift`):**
- Wrapped `MenuView` body in a `ScrollView` so content respects the safe area and scrolls below the Dynamic Island
- Removed flexible `Spacer()` elements (incompatible with ScrollView) and reduced VStack spacing from 20 to 16
- Reduced rocket illustration from 70×100pt to 60×85pt
- Reduced Classic button height from 55pt to 50pt
- Removed extra padding on banner ad and version text
- Result: All content (title, leaderboard, buttons, controls, HOW TO PLAY, banner ad, version) now visible on one screen without clipping

**2. Earth Level Gravity (`LevelDefinition.swift`):**
- Reduced Earth gravity from -4.5 to -3.5 (was -9.8 before Session 14, then -4.5, now -3.5)
- With thrust power at 12.0, this gives a 3.4x thrust-to-gravity ratio — challenging but landable
- **Outstanding issue:** Jupiter at -6.0 is still reported as impossible even at full thrust. Needs further balancing — either reduce gravity further or implement per-level thrust scaling

**3. Platform Overlap Fix (`GameScene.swift`):**
- Reduced horizontal movement ranges from `[15, 50, 30]` to `[0, 30, 20]`:
  - Platform A (Training Zone): Now vertical bob only, no horizontal movement
  - Platform B (Precision Target): Horizontal sway reduced from ±50px to ±30px
  - Platform C (Elite Landing): Horizontal movement reduced from ±30px to ±20px
- Reduced platform speeds from `[12, 30, 40]` to `[12, 25, 30]`
- Added clamping logic to prevent overlap:
  - Platform B clamped between A's right edge and C's left edge (10pt gap minimum)
  - Platform C clamped to stay right of B's right edge (10pt gap minimum)
- Platforms now stay strictly within their own zones (left/center/right)

**4. HOW TO PLAY Visibility:**
- Fixed by the ScrollView + spacing reduction changes above — no longer cut off

#### Files Modified:
- `RocketLander/ContentView.swift` — ScrollView wrapper, spacing/size reductions
- `RocketLander/Models/LevelDefinition.swift` — Earth gravity -4.5 → -3.5
- `RocketLander/GameScene.swift` — Platform movement ranges + clamping logic

#### Simulator Testing (iPhone 16 Pro, iOS 26.2):
- Main menu: Title fully visible below Dynamic Island ✓
- Main menu: HOW TO PLAY section fully visible ✓
- Main menu: All content fits on screen ✓
- Earth level: Platforms visually separated ✓ (verified in screenshot)
- Earth level: Gravity still needs further testing for landability
- **Jupiter level: Reported as impossible — needs balancing (TODO)**

#### Outstanding Work:
- Balance gravity across ALL campaign levels so difficulty increases progressively
- Current gravity values: Moon -1.6, Mars -3.7, Titan -1.4, Europa -1.3, Earth -3.5, Venus -4.2, Mercury -3.7, Ganymede -1.4, Io -1.8, Jupiter -6.0
- Thrust power is fixed at 12.0 for all levels — higher gravity levels may need thrust scaling or gravity caps
- Test all levels end-to-end on device

#### Chat Transcript Summary:
- User reported 3 bugs from testing on real iPhone 16
- Fixed Dynamic Island cutoff by wrapping menu in ScrollView
- Fixed Earth gravity from -4.5 to -3.5
- Fixed platform overlap with reduced ranges and edge clamping
- Attempted automated simulator testing via AppleScript/CGEvent but Simulator doesn't respond to macOS click events as touch input
- Installed and launched on iPhone 16 Pro simulator for manual testing
- Screenshots confirmed title and HOW TO PLAY fixes
- User reported Jupiter still impossible — deferred to next session for full gravity balancing pass

### Session 16 (2026-01-30) - Ganymede Deep Craters Terrain Overhaul

**Made Ganymede "deep craters" mechanic visible and functional.**

#### Problem:
User played Ganymede level and saw no craters. The previous implementation added random +30-60px height bumps at 25% of terrain segments, which were smoothed away by the averaging pass. No visual or gameplay distinction from other levels.

#### Changes Made:

**1. Terrain Ridge Generation (`GameScene+Setup.swift`):**
- Replaced random bumps with deliberate elevated ridges between platform zones
- Ridge height: up to +200px above base terrain (~380px total vs platforms at 220px)
- Ridges ramp up smoothly over 60px from platform edge, creating visible valleys
- Platforms sit in clear valleys with tall ridges on all sides
- Left and right screen edges also elevated (no safe terrain outside platform zones)
- Small random variation (±10px) on ridges for natural look

**2. Terrain Physics for Ganymede (`GameScene+Setup.swift`):**
- Added `addTerrainPhysics()` method — creates edge-chain physics body along terrain surface
- Uses `groundCategory` so rocket crashes on contact with ridges
- Only active on Ganymede (level 8); other levels keep terrain as visual-only
- Ridges are now actual obstacles, not just visual decoration

#### Files Modified:
- `RocketLander/GameScene+Setup.swift` — Ridge terrain generation + terrain physics body

#### Definition of Done:
- [x] Ganymede terrain has visible elevated ridges between platforms
- [x] Ridges have physics (crash on contact via groundCategory)
- [x] Platforms remain in valleys, accessible from above
- [x] Build succeeds (0 errors)
- [x] Docs updated

### Session 17 (2026-01-30) - Campaign Gravity Rebalance (Progressive Difficulty)

**Rebalanced all 10 campaign level gravity values for smooth progressive difficulty.**

#### Problem:
Gravity values did not increase with level number. Low-gravity levels (Titan -1.4, Europa -1.3, Ganymede -1.4, Io -1.8) appeared late in the campaign but were easier than early levels (Mars -3.7, Earth -3.5). Jupiter at -6.0 was impossible.

#### Design Principle:
Gravity increases monotonically with level number. Thrust is fixed at 12.0. Target thrust-to-gravity ratio: 7.5x (level 1) down to 2.5x (level 10). Special mechanics layer additional difficulty on top of gravity.

#### New Gravity Curve:

| Level | Name | Old Gravity | New Gravity | Thrust Ratio | Mechanic |
|-------|------|------------|------------|-------------|----------|
| 1 | Moon | -1.6 | -1.6 | 7.5x | None |
| 2 | Mars | -3.7 | -2.0 | 6.0x | Light wind |
| 3 | Titan | -1.4 | -2.2 | 5.5x | Dense atmosphere |
| 4 | Europa | -1.3 | -2.5 | 4.8x | Ice surface |
| 5 | Earth | -3.5 | -2.8 | 4.3x | Moving platforms |
| 6 | Venus | -4.2 | -3.2 | 3.8x | Heavy turbulence |
| 7 | Mercury | -3.7 | -3.5 | 3.4x | Heat shimmer |
| 8 | Ganymede | -1.4 | -3.8 | 3.2x | Deep craters |
| 9 | Io | -1.8 | -4.2 | 2.9x | Volcanic eruptions |
| 10 | Jupiter | -6.0 | -4.8 | 2.5x | Extreme wind |

#### Files Modified:
- `RocketLander/Models/LevelDefinition.swift` — All 10 gravity values updated

#### Definition of Done:
- [x] Gravity increases with each level
- [x] All thrust ratios ≥ 2.5x (landable with skill)
- [x] Build succeeds
- [x] Docs updated

### Session 18 (2026-01-30) - Per-Level Thrust, Visual Effects, Ganymede Fix, Easter Eggs, v2.0.0

**Major session: completed campaign gameplay polish and bumped to v2.0.0.**

#### Per-Level Thrust Scaling:
- Added `thrustPower` property to `LevelDefinition`
- Each planet has unique thrust: 8.0 (Moon, floaty) → 18.5 (Jupiter, powerful but tight)
- Thrust-to-gravity ratio decreases: 5.0x → 3.8x for progressive difficulty
- Classic mode unchanged at 12.0
- **Files:** `LevelDefinition.swift`, `GameScene.swift`

#### Visual Effects for All Mechanics:
- Wind streak particles at 3 intensities (Mars/Venus/Jupiter)
- Atmosphere haze with drifting clouds (Titan)
- Ice shimmer sparkles near platforms (Europa)
- Europa ice surface friction (0.01)
- **Files:** `GameScene+Effects.swift`, `GameScene.swift`

#### Ganymede Deep Craters (3rd Attempt — Success):
- Prior terrain ridge approaches failed: platforms cover 320 of 393pt (81% screen width), no room for terrain ridges between them
- New approach: standalone rock pillar obstacles (`SKShapeNode` with polygon physics bodies)
  - 3 pillars: left edge (height 200), between B-C (height 180), right edge (height 190)
  - Raised terrain at screen edges (up to 350px) for crater bowl effect
  - All have `groundCategory` — hitting them = crash
- **Files:** `GameScene+Setup.swift`

#### Astronaut Easter Egg High Scores:
- Prepopulated leaderboards with 1000-point entries using space figure names
- Classic: "Elon" | Moon: "Armstrong" | Mars: "Aldrin" | Titan: "Huygens"
- Europa: "Galileo" | Earth: "Gagarin" | Venus: "Shepard" | Mercury: "Glenn"
- Ganymede: "Marius" | Io: "Collins" | Jupiter: "Shoemaker"
- Seeded on first launch only (won't overwrite player scores)
- **Files:** `HighScoreManager.swift`, `CampaignState.swift`

#### Version Bump to v2.0.0:
- Campaign mode fundamentally changes the product — merits major version bump
- Updated: `Info.plist` (2.0.0, build 12), `README.md`, `CHANGELOG.md`, `RELEASE_NOTES.md`, `PROJECT_LOG.md`

#### Definition of Done:
- [x] Per-level thrust implemented and tested
- [x] All visual effects visible in simulator
- [x] Ganymede rock pillars visible and deadly
- [x] Easter egg scores seeded on fresh install
- [x] Version 2.0.0 across all files
- [x] All 10 levels playtested on simulator
- [x] All docs updated (DECISIONS.md, CHANGELOG.md, session summary, PROJECT_LOG.md)

### Session 19 (2026-01-30) - App Store Screenshots, Submission, Project Guidelines

**Phase: Release + Project Management. Screenshots, App Store submission, and CLAUDE.md guidelines.**

#### App Store Screenshots:
- Captured 10 screenshots from iPhone 16 Pro simulator using `xcrun simctl io screenshot`
- Clean status bar override (9:41, full battery/signal)
- Covers: main menu, classic gameplay, campaign level select, 5 campaign levels (Titan, Ganymede, Venus crash, Earth, Jupiter, Io), and successful landing with high score entry
- Initially captured at 1206×2622 (iPhone 16 Pro native) — rejected by App Store Connect
- Resized to 1284×2778 (iPhone 6.7" Pro Max) using `sips -z 2778 1284`
- **Location:** `Screenshots/v2.0.0/`

#### Detailed Release Notes:
- Expanded RELEASE_NOTES.md v2.0.0 from ~30 lines to ~170 lines
- Added comprehensive sections: campaign table, platform table, visual effects, scoring formula, astronaut easter eggs table, architecture
- Updated status from "IN DEVELOPMENT" to "SUBMITTED TO APP STORE CONNECT"

#### App Store Copy:
- Promotional text (166 chars) for anytime updates
- Description (897 chars) — structured with Campaign Mode, Three Platforms, Features sections
- "What's New" text with bullet points for all new features

#### App Store Submission:
- v2.0.0 (Build 12) submitted for App Store review
- Screenshots uploaded at correct 1284×2778 dimensions
- All text fields populated (promotional, description, what's new)

#### Technical Issues Resolved:
- Git HTTP/2 broken pipe on large pushes — fixed with `git config http.version HTTP/1.1`
- AppleScript clicks don't translate to SpriteKit UITouch hold events — used manual navigation + timed capture
- App Store Connect rejected 1206×2622 screenshots — requires exactly 1284×2778 for iPhone 6.7"

#### Project Management Guidelines:
- Created `CLAUDE.md` — persistent instructions for Claude Code session continuity
  - Start of session checklist, phase discipline, definition of done
  - Mandatory documentation updates, code standards, testing expectations
  - Privacy guardrails, change summary format, hard "do not" list
- Created `.github/pull_request_template.md` — PR checklist (scope, build, regression, docs, privacy, testing, risk)
- Added dedicated "Chat Session Logging (mandatory)" section to CLAUDE.md with 7 enforcement rules
- Inspired by jessfraz/dotfiles AGENTS.md, adapted for iOS project and session continuity
- **Files:** `CLAUDE.md`, `.github/pull_request_template.md`, `DECISIONS.md`

#### Research / Ideas Logged:
- Campaign per-level high scores display — top-3 stored but only #1 visible on level cards. Options: expand cards, tap-to-expand, or dedicated screen. Added to backlog.

#### Definition of Done:
- [x] 10 screenshots captured and resized
- [x] Screenshots uploaded to App Store Connect
- [x] Release notes expanded with full feature documentation
- [x] App Store description and "What's New" drafted
- [x] v2.0.0 submitted for review
- [x] CLAUDE.md created with full project guidelines
- [x] PR template created
- [x] Chat session logging enforced in CLAUDE.md
- [x] Campaign high scores display idea logged in backlog
- [x] Session summary finalized and committed

---

### Session 20 (2026-01-31) — STATUS.md Reconciliation

**Goal:** Create `STATUS.md` as the authoritative project snapshot and update `CLAUDE.md` to reference it as the single source of truth.

**Context:** User requested a compressed, reconciled project snapshot that takes precedence over chat logs and other documentation. This ensures new sessions can quickly understand the project state without reading all historical chat summaries.

**Sources consulted for reconciliation:**
- `CLAUDE.md` — project guidelines, file structure, build commands
- `PROJECT_LOG.md` — version history table, session entries, backlog
- `DECISIONS.md` — all 12 architectural/design decisions
- `CHANGELOG.md` — version-level change tracking
- `RELEASE_NOTES.md` — v2.0.0 feature list, App Store copy
- `README.md` — high-level project description
- `Info.plist` — current version/build numbers
- `Docs/chats/` — 5 session summaries (sessions 15-19)
- `.github/pull_request_template.md` — PR checklist

**Discrepancies found:** None — all documentation was consistent regarding v2.0.0 Build 12 submitted for review, feature set, and current status.

**Assumptions documented in STATUS.md:**
- v1.1.5 (Build 11) status is unclear — PROJECT_LOG says "Submitted for review" but no confirmation of publication. May have been superseded by v2.0.0.
- v2.0.0 not yet approved — Apple may reject for ad compliance, screenshot accuracy, or privacy declarations.
- No device testing performed for v2.0.0 — haptics, accelerometer, and ads are simulator-only verified.

**Files changed:**
- `STATUS.md` (new) — authoritative project snapshot with 9 sections: Project Snapshot, What Is Done, What Is NOT Done, Current Phase, Immediate Next Tasks, Non-Negotiable Principles, How to Resume Work, Known Risks, Ownership
- `CLAUDE.md` (updated) — added STATUS.md as authoritative truth in intro, session checklist (step 2), session continuity table (first entry with precedence rule), and documentation requirements (section G)

### Session 26 (2026-01-31) - TestFlight Setup + Device Testing + Accelerometer Fix

**Set up TestFlight for device testing. Found and fixed accelerometer toggle bug.**

#### Changes Made:

1. **TestFlight setup**:
   - Archived and uploaded v2.0.1 (Build 13) to App Store Connect
   - Created internal testing group "Developer Testing"
   - Added personal Apple ID as team member (Developer role) for TestFlight access
   - Successfully installed and tested on physical iPhone

2. **Device testing results**:
   - Haptics: all 4 types working (thrust, rotation, landing, crash)
   - Ads: banner ads loading correctly, ATT prompt appearing
   - Sound effects: working
   - Layout: no issues, version number visible top-right
   - Accelerometer: **BUG FOUND** — toggle had no effect on gameplay
   - Campaign: testing in progress (deferred to next session)

3. **Accelerometer bug fix (`ContentView.swift`)**:
   - Root cause: MenuView used `@AppStorage("useAccelerometer")` which updated UserDefaults but not `GameState.useAccelerometer` (read once at init)
   - Fix: removed `@AppStorage`, bound toggle directly to `gameState.useAccelerometer`
   - Fix committed locally, needs new TestFlight build to verify on device

4. **Environment setup**:
   - Installed Homebrew and `gh` CLI (session 25)
   - Fixed `xcode-select` path after Homebrew install switched it to Command Line Tools

#### Files Modified:
- `RocketLander/ContentView.swift` — removed `@AppStorage`, bound to `gameState.useAccelerometer`

#### Pending:
- Campaign mode device testing (user testing async)
- New TestFlight build with accelerometer fix
- Accelerometer verification on device

---

### Session 25 (2026-01-31) - v2.1.0 Planning Session

**Planned v2.1.0 scope: Game Center, Achievements, Remove Ads IAP, Share Score Card.**

#### Research Completed:

1. **GameKit / Game Center (iOS 15+)**:
   - Authentication: `GKLocalPlayer.local.authenticateHandler` — automatic, graceful fallback
   - Score submission: `GKLeaderboard.submitScore()` — built-in offline queue, best-score-only
   - Achievements: `GKAchievement.report()` — idempotent, percentComplete 0-100
   - Access Point: `GKAccessPoint.shared` — 3 lines for native dashboard overlay
   - Leaderboard IDs: reverse-domain, must register in App Store Connect first
   - Privacy: No ATT needed; add "Gameplay Content" to App Privacy declarations
   - Entitlement: "Game Center" capability in Xcode

2. **StoreKit 2 (iOS 15+)**:
   - Purchase: `Product.purchase()` async/await with JWS on-device verification
   - Restore: `AppStore.sync()` + `Transaction.currentEntitlements`
   - Persistence: `currentEntitlements` as truth, UserDefaults as fast cache
   - Testing: Local StoreKit Configuration file (no App Store Connect needed)
   - Privacy: No additional declarations
   - Entitlement: "In-App Purchase" capability in Xcode

3. **Achievement hook points identified**:
   - `saveScore()` in GameOverView for landing-based achievements
   - `CampaignState.completedLevel()` for progression achievements
   - `GameState` properties for condition checks (fuel, rotation, stars, platform)

4. **Ad removal integration point**:
   - `BannerAdContainer` in ContentView + GameContainerView — conditionally hide based on UserDefaults flag

#### Decisions Made:
- Game Center auth: automatic with graceful fallback (no forced popups)
- 10 achievements, all binary (0% or 100%), no grind-based
- StoreKit 2 with on-device JWS verification, no server needed
- Privacy: "Gameplay Content" declaration for Game Center, no other changes

#### v2.1.0 Scope — Community (locked):
- 11 Game Center leaderboards (classic + 10 campaign)
- 10 achievements
- Share Score Card with native share sheet
- No gameplay, physics, or campaign balance changes

#### v2.2.0 Scope — Monetization (locked):
- 1 non-consumable IAP ("Support Development" — remove ads)
- No gameplay, physics, or campaign balance changes

#### Files Changed:
- `CHANGELOG.md` — added v2.1.0 Unreleased section
- `DECISIONS.md` — 4 new decision entries (Game Center, achievements, IAP, privacy)
- `STATUS.md` — updated phase, next tasks, not-done status
- `PROJECT_LOG.md` — this entry
- `Docs/chats/2026-01-31_session25_v21_planning.md` — session summary

---

### Session 24 (2026-01-31) - Dedicated Leaderboard Screen (v2.0.1)

**Added a dedicated leaderboard screen and fixed version label visibility.**

#### Changes Made:

1. **Dedicated Leaderboard Screen (`LeaderboardView.swift` — new file)**:
   - Accessible by tapping "TOP PILOTS" section on main menu
   - Classic Mode section with top-3 scores
   - Campaign section with all 10 levels, each showing per-level top-3 scores
   - Locked levels shown grayed out with lock icon, no scores
   - Gold/silver/bronze rank colors for positions 1-3
   - Header with back navigation and trophy icon
   - Scrollable layout matching existing app design patterns

2. **Menu "TOP PILOTS" made tappable (`ContentView.swift`)**:
   - Wrapped existing leaderboard VStack in a Button with `.buttonStyle(.plain)`
   - Added "View All >" hint text at bottom of section
   - Added `showingLeaderboard` state for navigation

3. **Version label relocated (`ContentView.swift`)**:
   - Moved from bottom of ScrollView content to fixed `.overlay(alignment: .topTrailing)`
   - Always visible regardless of scroll position

4. **Version bump to 2.0.1 (Build 13)**:
   - Updated `Info.plist` CFBundleShortVersionString and CFBundleVersion

#### Files Created:
- `RocketLander/Views/LeaderboardView.swift`

#### Files Modified:
- `RocketLander/ContentView.swift` — navigation state, conditional branch, tappable TOP PILOTS, version label overlay
- `RocketLander.xcodeproj/project.pbxproj` — added LeaderboardView.swift to project
- `RocketLander/Info.plist` — version 2.0.1, build 13

#### Definition of Done:
- [x] Leaderboard screen opens from menu TOP PILOTS tap
- [x] Classic top-3 and campaign per-level top-3 displayed
- [x] Locked levels grayed out with lock icon
- [x] Back button returns to menu
- [x] Version label visible on menu at all times
- [x] Build succeeds
- [x] Docs updated

---

### Session 27 (2026-01-31) - Campaign Mode Device Testing Feedback

**Goal:** Receive and document campaign mode device testing feedback from TestFlight playtesting.

**Apple Review:** v2.0.0 still pending review (submitted 2026-01-30).

**Campaign Feedback (aspirational direction, no code changes):**
- Campaign feels balanced but homogeneous — planets differ by scalar tuning, not distinct mechanics
- Platform difficulty ladder (A=easy, B=hard, C=elite) is correct and should be preserved
- Core issue is recoverability, not difficulty — small lateral mistakes are unrecoverable
- Recommended hybrid model: Classic stays strict, Campaign becomes "accessible mastery"
- Planets should each teach one clear mechanic that changes how you fly
- Scoring expressiveness gap — center-of-platform precision needs to matter more
- Leaderboard should show star rating metadata for score context

**Key decision:** No implementation yet. Design discussion must precede any campaign changes.

#### Files Modified:
- None (feedback-only session)

---

### Session 28 (2026-01-31) - v2.0.2 Campaign Polish Patch

**Goal:** Implement campaign gameplay tuning based on device testing feedback: scoring rebalance, proportional thrust vectoring, differentiated planet mechanics, leaderboard star metadata.

#### Changes Made:

1. **Scoring Rebalance (`GameScene+Scoring.swift`)**:
   - Soft Landing: 700 → 500, Center: 350 → 600, Approach: 200 → 150 (subtotal stays 2000)
   - Fuel multiplier cap: 2.5x → 2.0x. New max: 20,000 (was 25,000)
   - Center precision now the highest-weighted component

2. **Proportional Thrust Vectoring (`GameScene.swift`)**:
   - Removed binary RCS lateral assist (2.0 units when tilted >5°)
   - Added proportional: `sin(rotation) × thrustPower × 0.15` — only while thrusting
   - Smooth, physics-based correction that scales with tilt angle

3. **Venus — Vertical Updrafts (`GameScene.swift`, `GameScene+Effects.swift`)**:
   - Wind force now vertical (dy) instead of horizontal (dx)
   - Wind particles move bottom-to-top instead of right-to-left
   - Description: "Vertical updrafts disrupt your descent."

4. **Jupiter — Sudden Gusts (`GameScene.swift`)**:
   - Replaced smooth sine-wave wind with calm/gust cycle
   - 2.5-4s calm → 1.5-2.5s sharp gust with random direction
   - Description: "Sudden gusts between calm windows."

5. **Mercury — Heat Interference (`GameScene.swift`)**:
   - Random velocity perturbation when thrusting (±1.5 dx, ±0.8 dy)
   - Visual shimmer effect unchanged
   - Description: "Heat shimmer disrupts thrust control."

6. **Io — Deadly Volcanic Debris (`GameScene+Effects.swift`)**:
   - Eruption particles get physics bodies (groundCategory → crash on contact)
   - Physics removed before fade-out (safe to touch fading particles)
   - Description: "Volcanic debris is deadly — time it."

7. **Leaderboard Star Metadata (`HighScoreManager.swift`, `CampaignState.swift`, `LeaderboardView.swift`)**:
   - HighScoreEntry gains `stars` field with backward-compatible Codable
   - Stars passed through from CampaignState.completedLevel
   - Small star icons shown in campaign leaderboard rows

8. **Level Description Updates (`LevelDefinition.swift`)**:
   - Venus, Mercury, Io, Jupiter descriptions updated to match new mechanics
   - `.heavyTurbulence` display name: "Vertical Updrafts"

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift`
- `RocketLander/GameScene.swift`
- `RocketLander/GameScene+Effects.swift`
- `RocketLander/Models/HighScoreManager.swift`
- `RocketLander/Models/CampaignState.swift`
- `RocketLander/Views/LeaderboardView.swift`
- `RocketLander/Models/LevelDefinition.swift`

#### Definition of Done:
- [x] Scoring rebalance: center 600pts, fuel cap 2.0x, max 20,000
- [x] Thrust vectoring: proportional, thrust-only
- [x] Venus: vertical updrafts + vertical particles
- [x] Jupiter: calm/gust cycle
- [x] Mercury: thrust perturbation
- [x] Io: deadly volcanic particles
- [x] Leaderboard star metadata: backward-compatible, displayed
- [x] Level descriptions updated
- [x] Build succeeds
- [x] All docs updated (CHANGELOG, DECISIONS, STATUS, PROJECT_LOG, README)
- [x] Version bumped to 2.0.2 (Build 14→15)
- [x] Archived and uploaded to App Store Connect / TestFlight
- [x] Fixed classic mode star rating not saved in high scores
- [x] Fixed classic mode star rating not displayed in leaderboard and menu

#### Commits:
- `35de6a9` — Campaign polish: scoring rebalance, thrust vectoring, planet differentiation
- `1c754f8` — Bump version to 2.0.2 (Build 14), upload to TestFlight
- `4216f7e` — Update session 28 summary: commits, version bump, TestFlight upload
- `cf1afd8` — End session 28: update PROJECT_LOG with commits and status
- `e3ccdce` — Fix classic mode star rating not saved in high scores (Build 15)
- `2a4ecb8` — Fix classic mode star display in leaderboard and menu (Build 16)

---

### Session 29 (2026-02-01) - Replace v2.0.0 Submission with v2.0.2

**Goal:** v2.0.0 (Build 12) had been "Waiting for Review" for 2 days with no response. Decision: replace with v2.0.2 (Build 16) to avoid shipping outdated gameplay. Update all App Store copy and submit.

#### Changes Made:

1. **Decision: Replace v2.0.0 with v2.0.2**
   - v2.0.0 had binary RCS, 25k max score, cosmetic-only planet mechanics, no star metadata
   - v2.0.2 has proportional thrust vectoring, 20k max, differentiated mechanics, star display
   - Better to reset review clock than ship inferior version

2. **App Store Copy Updated**
   - Description: 25,000 → 20,000 points (only change needed)
   - What's New: removed "V2.0.0", 25k→20k, "RCS thruster assist" → "Proportional thrust vectoring"
   - Review Notes: explains v2.0.2 replaces v2.0.0, lists all campaign mechanics
   - Promotional Text: new — "A skill-based landing game where precision beats luck..."
   - Keywords: lander, physics, precision, skill, thrust, flight, descent, control, challenge, hardcore, starship, simulator

3. **RELEASE_NOTES.md Overhauled**
   - v2.0.0 section replaced with v2.0.2
   - All outdated references fixed (RCS, 25k score, planet mechanics descriptions)
   - Added App Store copy blocks (Description, What's New, Review Notes)
   - Added v2.0.2 bug fixes section

4. **Documentation Updated**
   - STATUS.md: submission status, phase, next tasks, risks
   - PROJECT_LOG.md: current status table, next steps
   - DECISIONS.md: new entry documenting the replacement decision
   - RELEASE_NOTES.md: full v2.0.2 overhaul

#### Submission Details:
- Version: 2.0.2 (Build 16)
- Submitted: 2026-02-01 at 07:52
- Submission ID: 7ff9c921-0349-49c2-98b9-bfe9d1ca092f
- Status: Waiting for Review
- Build already uploaded from session 28 — no new archive needed

#### Definition of Done:
- [x] Decision made: replace v2.0.0 with v2.0.2
- [x] App Store description updated (20k score)
- [x] What's New updated (thrust vectoring, 20k)
- [x] Review Team Notes updated (explains replacement, lists mechanics)
- [x] Promotional text set
- [x] Keywords set
- [x] RELEASE_NOTES.md overhauled for v2.0.2
- [x] STATUS.md updated
- [x] PROJECT_LOG.md updated
- [x] DECISIONS.md entry added
- [x] v2.0.2 (Build 16) submitted for App Store review
- [x] Session summary created
- [x] All docs committed and pushed

#### Commits:
- `4fe3a43` — Replace v2.0.0 submission with v2.0.2: update App Store copy and docs
- `f7cf43a` — Update session 29 summary with commit hash and housekeeping
- `85689f9` — Add submission status to CHANGELOG v2.0.2 header
- `7ce6bc4` — Update README project structure: add caption_screenshots.py and metadata
- `786d081` — Fix stale references in docs: submission status, device testing, decisions

---

### Session 30 (2026-02-01) - Automated Unit Tests (XCTest)

**Goal:** Add unit tests for core game logic to provide regression protection.

#### Changes Made:

1. **Extracted scoring to static method (`GameScene+Scoring.swift`)**:
   - Added `GameScene.calculateScore()` static function with all inputs as parameters
   - Instance method becomes a thin wrapper — zero behavior change

2. **Created test target**:
   - Added `RocketLanderTests` directory with 7 test files (51 tests total)
   - Updated `project.pbxproj` with test target, build phases, configurations
   - Updated scheme to include test target in TestAction

3. **Test coverage**:
   - ScoringTests (11): formula verification + realistic scenarios
   - HighScoreManagerTests (9): persistence, sorting, backward-compat
   - CampaignStateTests (10): unlock, stars, scores, persistence
   - LevelDefinitionTests (8): data integrity, progression
   - LandingMessagesTests (5): message selection logic
   - GameStateTests (3): initial values, reset, settings persistence
   - LandingPlatformTests (5): multipliers, stars, widths, positions

#### Files Created:
- `RocketLanderTests/ScoringTests.swift`
- `RocketLanderTests/HighScoreManagerTests.swift`
- `RocketLanderTests/CampaignStateTests.swift`
- `RocketLanderTests/LevelDefinitionTests.swift`
- `RocketLanderTests/LandingMessagesTests.swift`
- `RocketLanderTests/GameStateTests.swift`
- `RocketLanderTests/LandingPlatformTests.swift`

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift` — static scoring method
- `RocketLander.xcodeproj/project.pbxproj` — test target
- `RocketLander.xcodeproj/xcshareddata/xcschemes/RocketLander.xcscheme` — test action

#### Definition of Done:
- [x] 51 tests pass, main app builds
- [x] No behavior changes
- [x] All docs updated

### Session 31 (2026-02-01) - Perfect Landing Score Analysis

**Goal:** Calculate maximum achievable scores for all 33 level/platform combinations using frame-by-frame physics simulation.

#### Changes Made:

1. **Created `Scripts/calculate_perfect_scores.py`**: Frame-by-frame physics simulation matching SpriteKit behavior (gravity×150 pts/m conversion, binary thrust, approach speed crash gate, screen wrapping). Reactive controller optimizes over descent speed, tilt angle, direction, and landing position.

2. **Key discoveries**:
   - Approach speed (avg of last 30 velocity samples) is a CRASH GATE, not just a scoring penalty
   - Screen wrapping makes going left the optimal strategy for Platform C (170 pts vs 263 pts)
   - Center landing always maximizes score — the 600 center bonus × multiplier always outweighs fuel savings from off-center landing
   - Best possible: Classic C = 12,132 (30% fuel, via left wrap). Worst: Moon A = 2,684 (48% fuel).

#### Files Created:
- `Scripts/calculate_perfect_scores.py`

#### No app code modified.

#### Interpretation & Intent
- These results reinforce the current design goals: the scoring system rewards skill (precision, fuel management, platform choice) over luck. No action or balance changes are required.
- The data exists to inform future achievement thresholds, sanity-check scoring changes, and guard against regressions that would erode skill expression.
- Platform C screen wrapping is considered emergent mastery, not an exploit. Center precision dominance is intentional and desirable.

#### Definition of Done:
- [x] All 33/33 landings computed
- [x] Validated against real gameplay (sim 2,980 vs real 2,965 for Classic A)
- [x] All docs updated

---

### Session 32 (2026-02-01) - Campaign Mode Engagement Upgrade (v2.0.3)

**Goal:** Implement four coordinated changes to improve Campaign mode engagement and gameplay feedback.

#### Changes Made:

1. **Fixed Reentry Start State (Campaign Only) (`GameScene.swift`)**:
   - `CampaignReentryState` struct: 0.12 rad (~6.9°) left tilt + 15 pts/s rightward drift
   - Applied via `applyCampaignReentryState()` when rocket becomes dynamic
   - Prevents trivial "hold thrust" strategy for Platform A
   - Classic mode unchanged (upright start)

2. **HUD Tilt Angle Display (`HUDViews.swift`)**:
   - New tilt row in VelocityHUDView with real-time degree readout
   - Directional color: cyan (left), orange (right), green (safe)
   - Direction letter (L/R) shown when tilt exceeds safe threshold
   - Safe threshold added to bottom line: "V<50 H<30 T<3°"

3. **Final Stats Panel (`GameOverView.swift`, `GameScene.swift`, `GameState.swift`)**:
   - `snapshotFinalStats()` freezes flight data at moment of landing/crash
   - `FinalStatsView` component displays tilt, speeds, fuel, center distance
   - Shown on both landing and crash game-over screens
   - Color-coded: green (safe) / red (exceeded threshold)

4. **Deterministic Crash Messages (`LandingMessages.swift`, `GameScene.swift`)**:
   - `CrashCause` enum with precedence ordering
   - `diagnosticCrashMessage()` produces cause-based feedback with actual values
   - Priority: tilt > vertical > horizontal > approach > terrain > out-of-bounds
   - Secondary hint for multiple failures
   - Same inputs always produce same output (no randomness)

5. **GameState Properties (`GameState.swift`)**:
   - Added: `tiltAngle` (signed), `finalTiltAngle`, `finalVerticalSpeed`, `finalHorizontalSpeed`, `finalFuel`, `finalDistanceFromCenter`, `crashDiagnosticPrimary`, `crashDiagnosticSecondary`
   - All cleared in `reset()`

6. **Unit Tests (`CrashDiagnosticTests.swift`)**:
   - 14 new tests: single-cause, precedence, secondary hints, determinism (100x), edge cases, value display
   - Total test count: 65 across 8 files

7. **Version Bump**: 2.0.3 (Build 17)

8. **TestFlight Upload**: Archived and uploaded Build 17 to App Store Connect for device testing.

9. **Perfect Score Simulation Update (`Scripts/calculate_perfect_scores.py`)**:
   - Updated to model campaign reentry state (initial tilt + drift)
   - Adds tilt correction phase: 3 rotation frames costing ~0.24% fuel
   - Initial rightward drift of 15 pts/s affects trajectory optimization
   - Impact: <1% score change on all 30 campaign level/platform combinations
   - Classic mode unchanged. Best: Classic C = 12,132. All 33/33 landings computed.
   - Center landing still always optimal (0/33 off-center)

#### Files Created:
- `RocketLanderTests/CrashDiagnosticTests.swift`

#### Files Modified:
- `RocketLander/GameScene.swift` — CampaignReentryState, applyCampaignReentryState(), snapshotFinalStats(), crash diagnostic wiring, tiltAngle tracking
- `RocketLander/Models/GameState.swift` — tiltAngle, final* properties, crashDiagnostic* properties, reset
- `RocketLander/Models/LandingMessages.swift` — CrashCause, CrashDiagnostic, diagnosticCrashMessage()
- `RocketLander/Views/HUDViews.swift` — tilt angle row, tilt color/direction properties
- `RocketLander/Views/GameOverView.swift` — FinalStatsView, crash diagnostic display
- `RocketLander/Info.plist` — version 2.0.3, build 17
- `Scripts/calculate_perfect_scores.py` — campaign reentry state modeling

#### Commits:
- `fede844` — Campaign engagement upgrade v2.0.3
- `8aa9c00` — Update session 32 summary with commit hash
- `31b8070` — Repo housekeeping: update README structure
- `afc6883` — Add housekeeping commit to session 32 summary
- `9cb1ffe` — Update perfect score simulation for campaign reentry state
- `fbdccbf` — Update session 32 summary with simulation commit

#### Definition of Done:
- [x] Campaign ships spawn with tilt + drift
- [x] Classic mode unchanged (upright start)
- [x] HUD shows real-time tilt in degrees with direction
- [x] Final stats frozen and displayed on game-over
- [x] Crash messages are deterministic and cause-based
- [x] 14 crash diagnostic tests pass
- [x] All 65 tests pass
- [x] Build succeeds
- [x] Version bumped to 2.0.3 (Build 17)
- [x] Build 17 uploaded to TestFlight
- [x] Perfect score simulation updated for campaign reentry (33/33, <1% impact)
- [x] All docs updated
- [x] Repo housekeeping complete

---

## Contact / Accounts

- **Apple Developer Account:** Thiago Borges de Oliveira
- **AdMob Account:** Associated with Google account
- **App Store Connect:** https://appstoreconnect.apple.com

---

### Session 33 (2026-02-01) - v2.0.3 Device Testing Bug Fixes (Build 18)

**Goal:** Fix 4 bugs found during on-device testing of v2.0.3 Build 17 on TestFlight, then upload Build 18 for continued testing.

#### Bugs Found (from device screenshots):
1. **HUD Tilt Truncation**: Tilt value showed "12...L" instead of "12.8° L" due to `minimumScaleFactor` shrinking text
2. **Post-Collision Zeroed Velocities**: Crash diagnostics showed "approach too high (87)" but V.Speed=0 — SpriteKit zeroes velocities in collision resolution
3. **HUD vs Flight Data Mismatch**: HUD showed live values, Flight Data showed frozen snapshot — different numbers for same metric on game-over screen
4. **Visual Start State**: Campaign ships appeared upright at spawn despite having reentry tilt applied on first input

#### Changes Made:

1. **Pre-Contact Velocity Tracking (`GameScene.swift`)**:
   - Added `lastTrackedVerticalSpeed`, `lastTrackedHorizontalSpeed`, `lastTrackedTilt` — updated synchronously in update loop
   - `snapshotFinalStats()` uses tracked values instead of reading physics body at collision time
   - Ensures accurate touchdown speeds and tilt in all end-of-run displays

2. **HUD Display Consistency (`HUDViews.swift`)**:
   - Added `displayVertical`, `displayHorizontal`, `displayTiltAngle` computed properties
   - Switch between live values (gameplay) and `final*` values (game-over)
   - Fixed tilt truncation: replaced `minimumScaleFactor(0.7)` with `fixedSize()`, widened HUD 150→170pt
   - Fixed fuel rounding: `Int()` → `"%.0f"` for consistency with Flight Data

3. **Visual Start State (`GameScene.swift` — `setupScene()`)**:
   - Applied `rocket.zRotation = CampaignReentryState.initialTilt` after `createRocket()` for campaign mode
   - Ship now visually tilted at spawn, matching the physics state applied on first input

4. **Signed Tilt Preservation (`GameOverView.swift`)**:
   - `finalTiltAngle` changed from absolute to signed (preserves L/R direction for HUD)
   - Added `abs()` where needed for FinalStatsView display

5. **Bug Evidence Screenshots**: Saved to `Screenshots/v2.0.3-bugs/` with descriptive names

6. **Landing Threshold Consistency (`GameScene.swift`)**:
   - Device testing of Build 18 revealed successful landings at V.Speed=71 (threshold is 50)
   - Root cause: `checkLanding()` read velocity from physics body after collision resolution absorbed impact
   - Fix: `checkLanding()` now uses `lastTrackedVerticalSpeed`/`lastTrackedHorizontalSpeed`/`lastTrackedTilt` (pre-contact values) for threshold checks
   - Same fix applies to both Classic and Campaign modes (no mode-specific branching)

7. **Build Bumps**: Build 17 → 18 → 19 for TestFlight uploads

#### Files Modified:
- `RocketLander/GameScene.swift` — pre-contact tracking, visual start state, signed tilt, landing threshold fix
- `RocketLander/Views/HUDViews.swift` — display properties, fixedSize, fuel rounding, widened HUD
- `RocketLander/Views/GameOverView.swift` — abs() on finalTiltAngle for FinalStatsView
- `RocketLander/Info.plist` — build 17 → 19

#### Commits:
- `e6db4b5` — Fix v2.0.3 telemetry bugs: HUD truncation, snapshot timing, visual start state
- `d6befb5` — Bump to Build 18 + update all docs for v2.0.3 bug fixes
- `a177219` — End session 33: finalize docs with commit hashes and TestFlight status
- `361bf4f` — Fix landing threshold using post-collision velocity instead of pre-contact

#### Definition of Done:
- [x] All 4 original bugs fixed
- [x] Landing threshold consistency bug fixed (Build 19)
- [x] 65/65 tests pass
- [x] Build succeeds
- [x] Bug evidence screenshots saved (5 total)
- [x] User confirmed Build 17 fixes work on device
- [x] Build number bumped to 19
- [x] All docs updated (CHANGELOG, STATUS, PROJECT_LOG, DECISIONS, session summary)
- [x] Build 19 archived and uploaded to TestFlight

---

### Session 34 (2026-02-01) - CRITICAL: Velocity Thresholds Never Enforced

**Goal:** Investigate and document Build 19 device testing failure — impossible to land on TestFlight.

#### Critical Discoveries:

1. **Velocity thresholds were dead code since initial commit (`e8e9656`)**:
   - `checkLanding()` reads from `rocket.physicsBody?.velocity` in `didBegin(contact:)`
   - SpriteKit zeros velocities during collision resolution before callback fires
   - V<40 and H<25 checks always saw V≈0 → always passed → speed never mattered
   - The only functional landing constraint was rotation (< 0.05 rad)

2. **Build 19 was first-ever speed enforcement, but too strict**:
   - Changed `checkLanding()` to use `lastTrackedVerticalSpeed` (pre-contact tracked)
   - But tracking happens at line 272 of `update()`, BEFORE thrust at line 286
   - Pre-thrust values are ~10-15 units higher than post-thrust when player is decelerating
   - Result: impossible to land even with careful approach

3. **HUD threshold mismatch since creation (commit `fede844`)**:
   - HUD uses V<50, H<30; actual GameScene thresholds are V<40, H<25
   - Never caught because both display and threshold were wrong in compatible ways

4. **Scoring was inflated in all prior builds**:
   - Scoring formula received near-zero post-collision velocities → max speed scores
   - All existing high scores achieved under "speed doesn't matter" regime

5. **Tests didn't catch it because**:
   - 65 unit tests all test isolated pure functions
   - No integration test simulates a physics collision and verifies pass/fail
   - Scoring simulation assumes thresholds work; has no knowledge of SpriteKit collision behavior
   - Device testing never tested boundary velocities specifically

#### Actions Taken:
- Reverted unauthorized Build 20 commit (`git revert 4a676cc` → `f500a2b`)
- Created comprehensive diagnostic: `Docs/DIAGNOSTIC_velocity_thresholds.md`
- Updated all project management docs (STATUS, DECISIONS, CHANGELOG, PROJECT_LOG)
- **No code fix implemented** — requires game design decision first

#### Files Created:
- `Docs/DIAGNOSTIC_velocity_thresholds.md` — full diagnostic report for developer review

#### Files Modified:
- `STATUS.md` — updated with critical bug status
- `DECISIONS.md` — added pending threshold design decision entry
- `CHANGELOG.md` — added known issues section for Build 19
- `PROJECT_LOG.md` — this entry

#### Pending Decision:
Should speed affect landing success? Options:
- (A) Revert to pre-Build 19 behavior (speed thresholds remain dead code)
- (B) Post-thrust tracking + current thresholds V<40/H<25 (new, harder game)
- (C) Post-thrust tracking + raised thresholds (new enforcement, generous)
- (D) Split sources (display vs enforcement different)

See `Docs/DIAGNOSTIC_velocity_thresholds.md` for full analysis.

#### Definition of Done:
- [x] Root cause fully analyzed (3 iterations of deepening analysis)
- [x] Unauthorized Build 20 reverted
- [x] Diagnostic document created
- [x] All project management docs updated
- [ ] Bug evidence screenshots saved (waiting for user to re-share)
- [ ] Session summary created
- [ ] Design decision made
- [ ] Fix implemented and tested

---

### Session 35 (2026-02-01) - Scoring Overhaul: Per-Platform Speed Bands + HARD Penalty Removal

**Goal:** Remove the overly harsh 0.4× HARD landing penalty, commit per-platform speed bands system, upload Build 21 to TestFlight, and run updated perfect score simulation.

#### Changes Made:

1. **Per-Platform Speed Bands (`LandingThresholds.swift` — new file)**:
   - `SpeedBand` enum: `.safe`, `.hard`, `.fail` with Comparable conformance
   - `PlatformBands` struct: per-platform safe/hard thresholds for V and H speeds
   - Platform A: V≤80/H≤60 (safe), V≤120/H≤100 (hard), above = fail
   - Platform B: V≤55/H≤45 (safe), V≤85/H≤75 (hard), above = fail
   - Platform C: V≤35/H≤30 (safe), V≤55/H≤50 (hard), above = fail
   - Pure `evaluate()` function for landing classification
   - `LandingEvaluationTests.swift`: 20 tests covering all platforms, boundaries, composites

2. **Removed explicit HARD landing penalty (`GameScene+Scoring.swift`, `ScoringHelper.swift`)**:
   - Removed `if speedBand == .hard { subtotal *= 0.4 }` from both production and test scoring
   - HARD landings are now penalized naturally: velocity components (500 soft + 400 horizontal = 900 pts) score zero because speeds exceed the safe threshold (the scoring denominator)
   - Consistent ~55% reduction (HARD gets ~1100/2000 subtotal vs SAFE's 2000/2000)
   - No scoring discontinuity at the SAFE/HARD boundary
   - Satisfies constraint: HARD-C > SAFE-B > SAFE-A at all fuel levels

3. **Updated scoring tests (`ScoringTests.swift`)**:
   - Renamed `testHardLandingPenalty` → `testHardLandingNaturalPenalty`
   - Added `testHardCBeatsSafeB`: verifies constraint at multiple fuel levels
   - Added `testHardCBeatsSafeA`: verifies constraint
   - Added `testNoPenaltyDiscontinuity`: V=34 (SAFE-C) ≈ V=36 (HARD-C) within 100 pts
   - Added `testApproachSpeedImpact`: approach component contributes ~150 pts
   - Total: 16 scoring tests (was 11)

4. **Updated Python scoring script (`Scripts/calculate_perfect_scores.py`)**:
   - Removed 0.4× HARD penalty from `calc_score()` and `score_detail()`
   - All 33/33 optimal landings are in SAFE band (no HARD landings in optimal play)
   - Best: Classic C = 12,077 (via left screen wrap, 30% fuel)
   - Worst: Europa A = 2,663 (43% fuel)
   - Score range: 2,663 – 12,077

5. **Build 21 uploaded to TestFlight**:
   - Bumped build from 19 → 21 (skipping 20 which was reverted)
   - Archive + export succeeded. dSYM warnings for GoogleMobileAds are harmless.

6. **Documented in DECISIONS.md**: Full entry for the removal decision with context, options, and consequences.

#### Perfect Score Simulation Results (Build 21):

| Level | Platform A | Platform B | Platform C | C Direction |
|-------|-----------|-----------|-----------|-------------|
| Classic | 3,023 (60% fuel) | 5,135 (39%) | 12,077 (30%) | ← wrap |
| Moon | 2,776 (53%) | 4,423 (25%) | 10,110 (16%) | ← wrap |
| Mars | 2,766 (55%) | 4,311 (23%) | 10,494 (16%) | ← wrap |
| Titan | 2,687 (50%) | 4,489 (22%) | 10,126 (14%) | ← wrap |
| Europa | 2,663 (43%) | 4,340 (24%) | 9,975 (12%) | ← wrap |
| Earth | 2,750 (48%) | 4,504 (31%) | 10,574 (17%) | ← wrap |
| Venus | 2,757 (50%) | 4,658 (29%) | 10,610 (18%) | ← wrap |
| Mercury | 2,738 (51%) | 4,700 (32%) | 11,047 (23%) | ← wrap |
| Ganymede | 2,781 (53%) | 4,738 (30%) | 10,977 (16%) | ← wrap |
| Io | 2,794 (51%) | 4,454 (21%) | 11,289 (22%) | ← wrap |
| Jupiter | 2,715 (57%) | 4,856 (32%) | 11,244 (25%) | ← wrap |

**Achievement planning (% of ceiling)**: Expert=70%, Good=45%, Average=25%

Key findings:
- All 33/33 landings in SAFE band — optimal play never enters HARD
- 11/33 use left screen wrap (all Platform C)
- 0/33 off-center — center landing always optimal
- Fuel range: 12%–60% remaining

#### Files Created:
- `RocketLander/Models/LandingThresholds.swift`
- `RocketLanderTests/LandingEvaluationTests.swift`

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift` — removed HARD penalty
- `RocketLanderTests/ScoringHelper.swift` — removed HARD penalty
- `RocketLanderTests/ScoringTests.swift` — updated + 5 new tests
- `Scripts/calculate_perfect_scores.py` — removed HARD penalty
- `DECISIONS.md` — new entry for HARD penalty removal
- `RocketLander/Info.plist` — build 19 → 21
- `RocketLander.xcodeproj/project.pbxproj` — added new files to project

#### Definition of Done:
- [x] HARD penalty removed from all 3 scoring implementations (app, test helper, Python)
- [x] Per-platform speed bands committed (LandingThresholds.swift)
- [x] 90/90 tests pass (25 new tests: 20 landing evaluation + 5 scoring)
- [x] Build succeeds
- [x] Build 21 archived and uploaded to TestFlight
- [x] Perfect score simulation updated (33/33 computed, all SAFE band)
- [x] DECISIONS.md entry added
- [x] All docs updated (CHANGELOG, STATUS, PROJECT_LOG, README)
- [x] Session summary created

---

### Session 36 (2026-02-01) - Fix Menu Ad Banner Clipping + Build 22 Upload

**Goal:** Fix the banner ad on the menu screen being clipped by the home indicator safe area. Correct stale documentation. Upload Build 22 to TestFlight with all v2.0.3 changes including menu ad fix.

**What Changed:**
- Added `.padding(.bottom, 16)` to `BannerAdContainer()` in `MenuView` (`ContentView.swift` line 260)
- The ad was the last item in the ScrollView's VStack with no bottom padding, causing it to be clipped by the home indicator on iPhones without a home button
- `GameContainerView.swift` already had `.padding(.bottom, 5)` on its banner ad; menu needed more clearance due to ScrollView behavior
- Corrected stale documentation that incorrectly described velocity threshold enforcement as "pending" (it was implemented in Build 21, commit `1698220`)
- Bumped build number 21 → 22 in Info.plist
- Archived, exported, and uploaded Build 22 to TestFlight (includes menu ad fix + all Build 21 changes)

**Files Modified:**
- `RocketLander/ContentView.swift` — added bottom padding to BannerAdContainer
- `RocketLander/Info.plist` — build number 21 → 22
- `DECISIONS.md` — changed velocity threshold entry from PENDING to RESOLVED
- `STATUS.md`, `PROJECT_LOG.md`, `CHANGELOG.md` — corrected stale references, updated build info

**Key Decisions:**
- Used 16pt padding (vs 5pt in gameplay) because the menu ScrollView needs more clearance when scrolled to the bottom

#### Definition of Done:
- [x] Banner ad fully visible when scrolled to bottom on iPhone 16 Pro
- [x] Build succeeds
- [x] 90/90 tests pass
- [x] Build 22 archived, exported, and uploaded to TestFlight
- [x] All stale "pending" references corrected
- [x] All docs updated with accurate build info
- [x] Session summary created

---

### Session 37 (2026-02-01) - Code Housekeeping Pass

**Goal:** Remove dead code, fix imports, delete stale files. No behavior changes, no refactors, no features, no version bump.

#### Changes Made:

1. **Removed dead code (6 items)**:
   - `leftFlame`/`rightFlame` unused properties from `GameScene.swift` (always nil)
   - `crashMessage()`, `crashMessages`, `crashNudges` from `LandingMessages.swift` (legacy, replaced by `diagnosticCrashMessage()`)
   - `crashNudge` property from `GameState.swift` and its assignments in `GameScene.swift`
   - `getTopScore()` from `HighScoreManager.swift` (zero callers)
   - `Triangle` shape from `ShapeViews.swift` (zero references)
   - Unused `CrashCause` enum cases `terrainCollision` and `outOfBounds` + `CaseIterable` conformance

2. **Fixed imports (3 files)**:
   - `GameScene.swift`: `import SwiftUI` → `import Combine`
   - `GameState.swift`: `import SwiftUI` → `import Foundation` + `import Combine`
   - `HighScoreManager.swift`: `import SwiftUI` → `import Foundation` + `import Combine`
   - `ContentView.swift`: removed unused `import SpriteKit`

3. **Deleted stale file**: `SETUP.txt` (referenced nonexistent scripts/tools from initial scaffolding)

4. **Updated tests**:
   - Removed `testCrashMessageStructure` from `LandingMessagesTests.swift` (tested deleted function)
   - Removed checks for deleted arrays from `testAllMessageArraysNonEmpty`
   - Removed `crashNudge` references from `GameStateTests.swift`
   - Test count: 90 → 89 (1 test removed for deleted function)

#### Files Modified:
- `RocketLander/GameScene.swift` — removed leftFlame/rightFlame, crashNudge assignments, fixed import
- `RocketLander/Models/LandingMessages.swift` — removed crashMessage(), crashMessages, crashNudges, unused enum cases
- `RocketLander/Models/GameState.swift` — removed crashNudge, fixed import
- `RocketLander/Models/HighScoreManager.swift` — removed getTopScore(), fixed import
- `RocketLander/Views/ShapeViews.swift` — removed Triangle
- `RocketLander/ContentView.swift` — removed unused import SpriteKit
- `RocketLanderTests/LandingMessagesTests.swift` — removed test for deleted function, updated array checks
- `RocketLanderTests/GameStateTests.swift` — removed crashNudge references

#### Files Deleted:
- `SETUP.txt`

#### Build Status:
- Build succeeds, 89/89 tests pass
- 9 files changed, 284 deletions total

#### Commits:
- `75169bf` — Code housekeeping: remove dead code, fix imports, delete stale file

#### Definition of Done:
- [x] All dead code identified and removed
- [x] Unused imports fixed
- [x] Stale files deleted
- [x] Tests updated to match removals
- [x] Build succeeds, all 89 tests pass
- [x] No behavior changes
- [x] All 7 documentation files verified and updated
- [x] Session summary created
- [x] Repo housekeeping checklist completed

---

### Session 38 (2026-02-02) - Build 22 Device Testing Bug Fixes

**Goal:** Fix two bugs found during Build 22 device testing on iPhone 16: (1) landing/crash messages truncated, (2) menu ad banner still clipped despite Session 36 padding fix.

#### Changes Made:

1. **GameOverView Text Truncation Fix (`GameOverView.swift`)**:
   - Landing success message: added `.multilineTextAlignment(.center)` + `.fixedSize(horizontal: false, vertical: true)` so long messages wrap instead of truncating
   - Crash primary diagnostic: added `.fixedSize(horizontal: false, vertical: true)` (already had `.multilineTextAlignment(.center)`)
   - Crash secondary diagnostic: added `.fixedSize(horizontal: false, vertical: true)` (already had `.multilineTextAlignment(.center)`)
   - Wrapped body VStack in ScrollView for vertical overflow protection when content is tall (landing + new high score scenario)

2. **Menu Ad Banner Clipping Fix (Improved) (`ContentView.swift`)**:
   - Previous fix (16pt bottom padding, Session 36) was insufficient — banner still clipped on device
   - Restructured MenuView: moved `BannerAdContainer()` outside ScrollView into a `VStack(spacing: 0)` wrapper
   - Ad now pinned at bottom of screen where SwiftUI safe area layout naturally keeps it above the home indicator
   - Verified on iPhone 16 Pro simulator — ad fully visible

#### Files Modified:
- `RocketLander/Views/GameOverView.swift` — text wrapping fixes + ScrollView wrapper
- `RocketLander/ContentView.swift` — menu ad moved outside ScrollView

#### Build Status:
- Build succeeds, 89/89 tests pass
- Fix B verified on simulator (screenshot saved to `Screenshots/v2.0.3-bugs/fix_b_menu_ad_verified.png`)
- Fix A requires device testing (user will test on TestFlight)

#### Definition of Done:
- [x] Fix A: text wrapping modifiers applied to 3 text elements
- [x] Fix A: GameOverView body wrapped in ScrollView for overflow protection
- [x] Fix B: BannerAdContainer moved outside ScrollView
- [x] Fix B: verified on iPhone 16 Pro simulator — ad fully visible
- [x] Build succeeds
- [x] 89/89 tests pass
- [ ] Fix A: verified on device (pending TestFlight Build 23)
- [ ] Build 23 uploaded to TestFlight
- [x] All docs updated

---

### Session 39 (2026-02-02) - Build 23 Upload to TestFlight

**Goal:** Archive and upload Build 23 to TestFlight for device testing of Session 38 bug fixes. Previous session's archive/export failed due to Keychain access issues in Tailscale SSH session.

#### Changes Made:

1. **CLI Authentication Setup**:
   - Configured CLI authentication for headless uploads
   - Enables `xcodebuild -exportArchive` over SSH/Tailscale without Keychain access

2. **Build 23 Archived and Uploaded**:
   - Archive succeeded: v2.0.3 Build 23 (already bumped in Session 38)
   - Export + upload via CLI authentication — bypasses Keychain entirely
   - Build 23 confirmed processing and visible on TestFlight
   - dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless, same as always)

3. **Screenshot Housekeeping**: Moved 4 JPEG screenshots from `Screenshots/` root to `Screenshots/v2.0.3-bugs/` with descriptive names (bug9–bug12). These were uploaded via GitHub web UI for Session 38 bug analysis.

4. **Credentials Rotated**: Credentials rotated after upload.

#### No app code changes. Screenshot renames only.

#### Definition of Done:
- [x] Build 23 archived (v2.0.3)
- [x] Build 23 exported and uploaded to App Store Connect
- [x] Build 23 visible on TestFlight
- [x] Credentials rotated after use
- [x] Bug screenshots organized into v2.0.3-bugs with descriptive names
- [x] All docs updated
- [x] Session summary created

---

### Session 40 (2026-02-02) - Menu Layout Fix + How To Play Info Sheet

**Goal:** Fix menu overflow issue where content (~700pt) exceeded most iPhone screens and the banner ad covered the bottom section. Replace the inline HOW TO PLAY section with a rich info sheet.

#### Changes Made:

1. **Menu Layout Fix (`ContentView.swift`)**:
   - Removed the inline "HOW TO PLAY" section (VStack with 3 Label items, ~85pt)
   - Replaced with a "How to Play >" text button (~22pt) — saves ~79pt of vertical space
   - Added `@State private var showingHowToPlay` state variable
   - Added `.sheet(isPresented:)` modifier presenting `HowToPlayView`
   - Added `.padding(.bottom, 60)` to ScrollView content to clear the banner ad on devices that still need scrolling
   - Menu now fits without scrolling on iPhone 12 mini (731pt) and larger

2. **How to Play Info Sheet (`Views/HowToPlayView.swift` — new file)**:
   - Scrollable SwiftUI sheet with dark theme matching the app
   - 5 sections with orange accent headers:
     - **Controls**: Thrust, Rotate (adapts to button/accelerometer setting), Land
     - **Landing Platforms**: Table showing A/B/C with names, widths, multipliers, stars, colors
     - **Speed Bands**: SAFE/HARD/FAIL explanation + per-platform threshold table (V and H)
     - **Scoring**: All 6 components with max points, fuel multiplier (1.0-2.0x), platform multiplier (1x/2x/5x), formula, max 20,000
     - **Campaign**: All 10 levels with gravity and special mechanic (reads from `LevelDefinition.levels`)
   - Dismiss button (X) at top right

3. **Project File (`project.pbxproj`)**:
   - Added `HowToPlayView.swift` file reference, build file, Views group entry, and Sources build phase entry

#### Files Created:
- `RocketLander/Views/HowToPlayView.swift`

#### Files Modified:
- `RocketLander/ContentView.swift` — removed HOW TO PLAY, added button + sheet + padding
- `RocketLander.xcodeproj/project.pbxproj` — added new file to project

#### Build Status:
- Build succeeds on iPhone 16 Pro simulator
- 89/89 tests pass (no logic changes)
- Menu layout verified on simulator — fits without scrolling

#### Commits:
- `edf13e1` — Session 40: Replace inline HOW TO PLAY with rich info sheet
- `37a0fa8` — Bump build number to 24 for TestFlight upload
- `4c03154` — Remove API key from repo — moved to ~/.appstoreconnect/private_keys/

---

### Session 41 (2026-02-02) - Build 24 TestFlight Upload

**Goal:** Commit Session 40 changes, archive Build 24, and upload to TestFlight for device testing.

#### Changes Made:

1. **Committed Session 40 work**: Menu layout fix (How to Play info sheet replacing inline section), HowToPlayView.swift, screenshot housekeeping, all documentation updates.

2. **Build 24 archived and uploaded to TestFlight**: Bumped build number 23 → 24. Archived and uploaded via CLI authentication. dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless).

#### No app code changes (build bump only).

#### Commits:
- `edf13e1` — Session 40: Replace inline HOW TO PLAY with rich info sheet
- `37a0fa8` — Bump build number to 24 for TestFlight upload
- `4c03154` — Update CLI authentication setup

---

### Session 42 (2026-02-02) - Code Quality & Build Hygiene

**Goal:** Review codebase for build hygiene improvements. Harden .gitignore, clean up debug output and legacy files.

#### Changes Made:

1. **`.gitignore` hardened**: Added missing patterns for build artifacts and credential file types (`*.p8`, `*.key`, `*.pem`, `*.secret`, `.env`, `.env.*`, `.apple_id`, `*.ipa`, `*.dSYM`, `*.dSYM.zip`).

2. **Print statements wrapped in `#if DEBUG`**: 5 occurrences across `RocketLanderApp.swift` (ATT status) and `BannerAdView.swift` (4 ad lifecycle events). No output in release builds.

3. **Player name length limit**: Added `.onChange` modifier to TextField in `GameOverView.swift` to cap at 20 characters.

4. **ATT request optimized**: `requestTrackingPermission()` now checks `ATTrackingManager.trackingAuthorizationStatus == .notDetermined` before calling `requestTrackingAuthorization`. Eliminates wasted SDK calls on every foreground.

5. **Legacy Podfile deleted**: Project uses SPM exclusively. Podfile was confusing artifact.

#### No version bump. Build 24 unchanged (code-only changes, no behavioral impact in release builds).

#### Commits:
- `15a059e` — Code quality improvements — harden .gitignore, wrap prints in DEBUG, optimize ATT, cap player name

---

### Session 43 (2026-02-02) - Documentation Cleanup & Credential Protection Guardrails

**Goal:** Clean up documentation across all project files. Add credential protection guardrails to CLAUDE.md. Clean git history of narrative references.

#### Changes Made:

1. **Documentation cleanup (10 files)**: Reviewed and cleaned all session summaries and project documentation. Simplified authentication workflow descriptions, neutralized verbose narratives, and ensured consistent language.

2. **Credential & Secret Protection (CLAUDE.md)**: Added mandatory section with 6 hard rules: refuse credentials, never write to files, pre-commit scans, safe authentication patterns, and accidental share handling.

3. **Git history cleanup**: 7 passes of `git-filter-repo` (4 `--replace-text` + 3 `--message-callback`) to neutralize ~30 narrative phrases across all historical commits.

#### No app code changes. Documentation only.

#### Commits:
- `523f00b` — Documentation cleanup and add credential protection guardrails

---

### Session 44 (2026-02-02) - Build 25 TestFlight Upload

**Goal:** Bump build number to 25 and upload to TestFlight so the TestFlight build matches the current source (which includes Session 42 build hygiene changes and Session 43 documentation cleanup).

#### Changes Made:

1. **Build number bumped 24 → 25** (`Info.plist`): Aligns TestFlight build with current source code.

2. **Build 25 archived and uploaded to TestFlight**: Uploaded via Xcode Organizer GUI. dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless, same as always).

#### No app code changes (build bump only).

#### Commits:
- `31c371a` — Bump build number to 25 for TestFlight upload

---

### Session 45 (2026-02-03) - Flight Data Panel Redesign & Crash Messages

**Goal:** Redesign Flight Data panel to match HUD design language. Add randomized crash headline easter eggs.

#### Changes Made:

1. **FinalStatsView HUD-style redesign** (`GameOverView.swift`): Complete rewrite with SF Symbol icons, OK/HARD/FAIL badge pills, 3-color value system, gray dividers, centered header. Band logic per metric (tilt safe/fail, speeds via LandingThresholds, fuel >20%/>0%/0%, center <20pt/<30pt/>=30pt). "HARD LANDING" / "RAPID UNSCHEDULED DISASSEMBLY" badges at bottom. Applied to both landing and crash game-over screens.

2. **Randomized crash headlines** (`GameOverView.swift`): Pool of 20 messages replacing static "CRASH!" text. SpaceX references, space mission quotes, Kerbal vibes, dry humor. Randomized each game over via `@State` property.

3. **High score sheet fix** (`GameOverView.swift`): Added `onChange` listeners for `gameState.score` and `gameState.landed` to handle race condition where `onAppear` fired before state propagated.

4. **GameContainerView overlay restructure** (`GameContainerView.swift`): Moved `GameOverView` from HUD VStack to ZStack root for proper full-screen layering.

5. **Build 26 uploaded to TestFlight** (`Info.plist`): Build number 25 → 26. Archived and uploaded via CLI.

6. **PROJECT_LOG archiving** (`PROJECT_LOG.md`, `PROJECT_LOG_ARCHIVE.md`, `CLAUDE.md`, `STATUS.md`, `README.md`): Moved sessions 1-35 to archive (1,768 → 410 lines). Archive includes project history summary. Archiving rules embedded in CLAUDE.md. Session start checklist updated.

#### Commits:
- `3b5934c` — Redesign Flight Data panel with HUD-style layout and randomized crash messages
- `21ac776` — Bump build number to 26 for TestFlight upload
- `a5a95be` — Add session 45 documentation — Flight Data redesign and crash messages
- `d850a26` — Archive PROJECT_LOG sessions 1-35 and establish archiving workflow
- `67d1ee6` — Finalize session 45 documentation — add archiving work to summaries
- `fc21e40` — Add bug screenshots for game-over overlay scroll issue (Build 25)

---

---

### Session 46 (2026-02-05) - v2.0.3 Gameplay Feedback Fixes

**Goal:** Process 10 user feedback items on v2.0.3 Build 26, implement all fixes for gameplay issues, celestial bodies, level mechanics, and UI.

#### Changes Made:

1. **Menu Button Truncation Fix** (`GameOverView.swift`): Reduced horizontal padding, added `.fixedSize()`.

2. **CENTER Badge Removal** (`GameOverView.swift`): CENTER row now shows value only without OK/HARD/FAIL badge.

3. **Speed Threshold Tightening** (`LandingThresholds.swift`): Tightened all thresholds ~15% for A/B, ~5% for C. Updated all 18 `LandingEvaluationTests` to match new values.

4. **Jupiter Wind Overhaul** (`GameScene.swift`, `GameScene+Effects.swift`, `LevelDefinition.swift`): Wind always pushes left→right with stronger force (base 20.0), ambient wind during calm, gravity increased from -4.8 to -5.2, particles reversed direction.

5. **Europa Ice Effect** (`GameScene.swift`): H.Speed > 20 causes crash ("Slid off the ice!").

6. **Titan Thrust Reduction** (`GameScene.swift`): Thrust reduced to 75% efficiency (replaces drag damping which made it easier).

7. **Earth Platform Collision Fix** (`GameScene.swift`): Zone-based movement — B stays in 5%-50%, C stays in 55%-95%, eliminates startup collision.

8. **Mercury Heat Shimmer** (`GameScene.swift`, `GameScene+Effects.swift`, `LevelDefinition.swift`): Increased perturbation wobble, added rising heat particles, fixed celestial body to sunLarge.

9. **Celestial Body Corrections** (`LevelDefinition.swift`, `GameScene+Setup.swift`): All 10 levels now show astronomically-correct celestial bodies (Earth from Moon, Saturn with rings from Titan, Jupiter with bands from moons, Sun with glow from inner planets, etc.). Added `addSunFeatures()` for Sun rendering.

10. **Partial Platform Landing Detection** (`GameScene.swift`): Both legs (47pt span) must be within platform bounds to land successfully.

#### Files Modified:
- `RocketLander/Views/GameOverView.swift` — Menu button, CENTER badge
- `RocketLander/Models/LandingThresholds.swift` — Tightened thresholds
- `RocketLander/Models/LevelDefinition.swift` — Celestial bodies, Jupiter gravity, Titan description
- `RocketLander/GameScene.swift` — Europa ice, Titan thrust, Earth platforms, Mercury shimmer, partial landing
- `RocketLander/GameScene+Effects.swift` — Jupiter particles, Mercury particles
- `RocketLander/GameScene+Setup.swift` — Sun features, celestial body rendering
- `RocketLanderTests/LandingEvaluationTests.swift` — Updated 18 tests for new thresholds

#### Build Status:
- Build succeeds, 89/89 tests pass (18 LandingEvaluationTests updated for new thresholds)

---

### Session 47 (2026-02-05) - Europa Cryogeysers + Build 28 TestFlight

**Goal:** Replace Europa's punishing ice slide crash (H.Speed > 20 = instant death) with cryogeyser eruptions — disruptive but survivable force-based plumes. Upload Build 28 to TestFlight.

#### Changes Made:

1. **Europa cryogeysers** (`LevelDefinition.swift`, `GameScene.swift`, `GameScene+Effects.swift`): Renamed `.iceSurface` → `.cryogeysers`. 3 fixed geyser positions with staggered active/calm cycling. Upward push force (base 18.0, tapering with height) when rocket is in plume zone. Blue/white/cyan particle columns. Vent markers on surface. Ice shimmer + low friction preserved.

2. **Ice slide crash removed** (`GameScene.swift`): Deleted the H.Speed > 20 crash check in `checkLanding()`.

3. **Test updated** (`LevelDefinitionTests.swift`): `.iceSurface` → `.cryogeysers` in expected mechanics map.

4. **Build 28 uploaded to TestFlight** (`Info.plist`): Build number 27 → 28.

#### Files Modified:
- `RocketLander/Models/LevelDefinition.swift` — enum rename, description update
- `RocketLander/GameScene.swift` — geyser state, setup, mechanics, ice crash removal, reset cleanup
- `RocketLander/GameScene+Effects.swift` — `createCryogeyserEffect()` particle system
- `RocketLanderTests/LevelDefinitionTests.swift` — mechanic name update
- `RocketLander/Info.plist` — Build 27 → 28

#### Commits:
- `42d953f` — Replace Europa ice slide with cryogeyser eruptions
- `167a024` — Bump build number to 28 for TestFlight upload

#### Build Status:
- Build succeeds, 89/89 tests pass

---

### Session 48 (2026-02-05) - Scoring Rebalance + Tilt Bands

**Goal:** Address low score feedback (rarely >5,000) with comprehensive scoring improvements. Add tilt bands (SAFE/HARD/FAIL) matching speed band philosophy.

#### Root Cause Analysis (Scoring):
- Quadratic penalty curve zeroed velocity components in HARD band (0 pts instead of partial credit)
- Session 46 tightened thresholds ~15% compressed the scoring range
- Fuel multiplier range 1.0-2.0x too narrow; fuel consumption too high

#### Changes Made:

1. **Scoring formula overhaul** (`GameScene+Scoring.swift`, `ScoringHelper.swift`):
   - Velocity scoring denominator changed from safe to hard threshold — single smooth curve, HARD landings get partial credit
   - Soft Landing: 500→550 pts, Horizontal Precision: 400→450 pts (subtotal max 2000→2100)
   - Fuel multiplier: 1.0-2.0x → 1.0-2.2x (factor 1.0→1.2)
   - Theoretical max: 23,100 (was 20,000)

2. **Fuel consumption reduction** (`GameScene.swift`):
   - Thrust: 0.30→0.27%/frame
   - Rotation: 0.08→0.07%/frame
   - Accelerometer: 0.04→0.035×tilt

3. **Tilt bands** (`LandingThresholds.swift`, `GameScene+Scoring.swift`, `ScoringHelper.swift`, `GameOverView.swift`, `HUDViews.swift`, `LandingMessages.swift`, `HowToPlayView.swift`):
   - SAFE ≤0.05 rad (~2.9°), HARD ≤0.10 rad (~5.7°), FAIL >0.10 rad
   - Tilt band participates in overall landing band (worst of V/H/tilt wins)
   - Rotation scoring uses hardTilt (0.10) as denominator
   - HUD tilt color: green/yellow/red for safe/hard/fail
   - Crash message: "Land under 6°" (was 3°)
   - GameOverView tilt band uses `LandingThresholds.tiltBand()`

4. **HowToPlayView updated** (`HowToPlayView.swift`): New component values, subtotal, fuel range, max. Updated speed band thresholds to v2.0.3 values. Added tilt band explanation.

5. **Perfect score script updated** (`Scripts/calculate_perfect_scores.py`): New formula, fuel rates, tilt thresholds. Best: Classic C = 14,504.

6. **Tests updated** (`ScoringTests.swift`, `LandingEvaluationTests.swift`, `CrashDiagnosticTests.swift`):
   - ScoringTests: New theoretical max 23,100, new component values, HARD partial credit tests, discontinuity test
   - LandingEvaluationTests: 2 binary rotation tests → 4 tilt band tests + 1 classification test
   - CrashDiagnosticTests: Updated rotation value in determinism test (0.08→0.12, since 0.08 is now HARD not crash)

7. **Build 29 uploaded to TestFlight** (`Info.plist`): Build number 28→29.

8. **Build 30 bumped and uploaded to TestFlight** (`Info.plist`): Build number 29→30. Tilt band changes included.

9. **v2.0.3 Build 30 submitted for App Store review** (2026-02-06): What's New text, review notes, and promotional text finalized. Submitted via App Store Connect.

#### Files Modified:
- `RocketLander/GameScene+Scoring.swift` — scoring formula, rotation denominator
- `RocketLander/GameScene.swift` — fuel consumption rates
- `RocketLander/Models/LandingThresholds.swift` — tilt bands (safeTilt, hardTilt, tiltBand(), evaluate())
- `RocketLander/Models/LandingMessages.swift` — crash threshold hardTilt, "Land under 6°"
- `RocketLander/Views/GameOverView.swift` — tiltBand uses LandingThresholds.tiltBand()
- `RocketLander/Views/HUDViews.swift` — hardTiltDegrees, 3-color tiltColor
- `RocketLander/Views/HowToPlayView.swift` — scoring values, speed band thresholds, tilt band explanation
- `RocketLanderTests/ScoringHelper.swift` — test scoring replica
- `RocketLanderTests/ScoringTests.swift` — test assertions
- `RocketLanderTests/LandingEvaluationTests.swift` — tilt band tests
- `RocketLanderTests/CrashDiagnosticTests.swift` — determinism test rotation value
- `Scripts/calculate_perfect_scores.py` — scoring formula, fuel rates, tilt thresholds
- `RocketLander/Info.plist` — Build 28→29

#### Build Status:
- Build succeeds, 91/91 tests pass (was 89 — net +2 from tilt band tests)

#### Commits:
- `e1b2d61` — Rebalance scoring: HARD partial credit, component boost, fuel tuning
- `25cecde` — Bump build number to 29 for TestFlight upload
- `254bb30` — Add tilt bands (SAFE/HARD/FAIL) matching speed band philosophy
- `a906b72` — Bump build number to 30 for TestFlight upload
- `30ab29d` — Update docs for v2.0.3 Build 30 App Store submission
- `540de65` — Simplify v2.0.3 review notes
- `b70cdda` — Note v2.0.3 Build 30 submitted for review

---

### Session 49 (2026-02-06) - v2.0.3 Build 30 Approved

**Goal:** Note approval of v2.0.3 Build 30.

#### Changes Made:
- Updated documentation to note Build 30 approved and live on App Store (2026-02-06).

#### Commits:
- `2d70294` — Note v2.0.3 Build 30 approved and live on App Store

---

### Session 50 (2026-02-06) - v2.1.0 Community Phase Implementation

**Goal:** Implement v2.1.0 Community phase: Game Center integration (auth, 12 leaderboards, 10 achievements, Galaxy Rank) and Share Score Card.

#### Changes Made:

1. **GameCenterManager.swift (NEW)** — 283 lines. ObservableObject + singleton. Auth, 12 leaderboard IDs, score submission (fire-and-forget), Galaxy Rank fetch/display, 10 achievement checks, persistent tracking state (safePlatformCLevels, attemptsByLevel via UserDefaults).

2. **RocketLander.entitlements (NEW)** — Game Center capability.

3. **ShareScoreCardView.swift (NEW)** — 148 lines. SwiftUI card rendering (320pt, dark gradient, orange border). ShareHelper with ImageRenderer (iOS 16+) / UIHostingController snapshot (iOS 15). Native share sheet.

4. **ContentView.swift** — Added gameCenterManager StateObject, `.onAppear { authenticate() }`, passed to all child views. MenuView: Galaxy Rank badge, GKAccessPoint show/hide, fetchGalaxyRank on appear.

5. **GameContainerView.swift** — Added campaignState and gameCenterManager params, passed campaignState through to GameScene.

6. **GameScene.swift** — Added campaignState property, updated init. recordAttempt() in startGame(). GC score submission + achievement check in successfulLanding().

7. **LeaderboardView.swift** — Added gameCenterManager param, Galaxy Rank header, "View Global Rankings" button (GKGameCenterViewController), GKDismissHandler class.

8. **LevelSelectView.swift** — Added gameCenterManager param, Galaxy Rank explanation section after level grid.

9. **GameOverView.swift** — Share button (landing only), shareScoreCard() method building ShareScoreCardView from gameState.

10. **project.pbxproj** — Added GameCenterManager.swift, ShareScoreCardView.swift, RocketLander.entitlements, CODE_SIGN_ENTITLEMENTS.

#### Files Created:
- `RocketLander/Models/GameCenterManager.swift`
- `RocketLander/Views/ShareScoreCardView.swift`
- `RocketLander/RocketLander.entitlements`

#### Files Modified:
- `RocketLander/ContentView.swift`
- `RocketLander/GameScene.swift`
- `RocketLander/Views/GameContainerView.swift`
- `RocketLander/Views/LeaderboardView.swift`
- `RocketLander/Views/LevelSelectView.swift`
- `RocketLander/Views/GameOverView.swift`
- `RocketLander.xcodeproj/project.pbxproj`

#### Build Status:
- Build succeeds, 91/91 tests pass

#### Key Decisions:
- Galaxy Rank uses 12th leaderboard (galaxy_rank) = sum of best scores across 10 campaign levels
- Achievement checks use composite landing band (worst of V/H/tilt) not speedBand alone
- Tilt checks use radians internally (e.g., 2.0° = 2.0 × π/180)
- First Try Perfection is campaign-only, tracked via attemptsByLevel
- GC auth is non-intrusive — features hidden when not signed in
- Singleton pattern on GameCenterManager needed for fire-and-forget calls from GameScene

#### Definition of Done:
- [x] GameCenterManager with auth, leaderboards, achievements
- [x] 12 leaderboard IDs defined
- [x] 10 achievement IDs and check logic
- [x] Galaxy Rank on 3 UI layers (menu, campaign, leaderboard)
- [x] GKAccessPoint on menu
- [x] Share Score Card rendering + native share sheet
- [x] Share button on game-over (landing only)
- [x] Build succeeds
- [x] 91/91 tests pass
- [x] All documentation updated
- [x] Session summary created
- [ ] Version bump (pending user approval)
- [ ] App Store Connect configuration (manual)
- [ ] Device testing

---

### Session 51 (2026-02-06) - v2.1.0 TestFlight + ASC Setup + GC Auth Fix

**Goal:** Version bump to 2.1.0, upload to TestFlight, create GC resources in ASC via API, fix GC auth bug found during device testing.

#### Changes Made:

1. **Version bump** (`Info.plist`): v2.0.3 Build 30 → v2.1.0 Build 31. Archived and uploaded to TestFlight.

2. **setup_game_center.py (NEW)** (`Scripts/setup_game_center.py`): Python script to create Game Center leaderboards and achievements via App Store Connect REST API.
   - JWT authentication with ES256 signing
   - Reads credentials from env vars (ASC_ISSUER_ID, ASC_KEY_ID, ASC_PRIVATE_KEY) or local .p8 files
   - Creates 12 leaderboards with en-US localizations
   - Creates 10 achievements with en-US localizations
   - Idempotent — skips existing resources

3. **App Store Connect configured**: All 12 leaderboards and 10 achievements created successfully via API.
   - 12 leaderboards: classic, campaign_1-10, galaxy_rank (INTEGER format, BEST_SCORE, DESC sort)
   - 10 achievements: eagle_has_landed through master_lander (200 total points)
   - All with en-US localizations

4. **Game Center auth fix** (`GameCenterManager.swift`, `LeaderboardView.swift`): Device testing of Build 31 revealed "View Global Rankings" showed "Sign in to Game Center" despite being signed in.
   - **Root cause**: `authenticateHandler`'s `viewController` parameter was silently dropped. When non-nil, this VC must be presented to complete per-app GC authentication.
   - **Fix 1**: Present auth `viewController` on topmost VC when provided
   - **Fix 2**: Added `topViewController()` helper (walks presentation chain from root)
   - **Fix 3**: `GKGameCenterViewController` now presented from topmost VC (not root) and anchored to `galaxy_rank` leaderboard
   - Build 32 uploaded to TestFlight with fix

#### Bug Fixed in Script:
- `defaultFormatter` attribute requires string enum (`"INTEGER"`) not nested object. Fixed format and improved error reporting.

#### Files Created:
- `Scripts/setup_game_center.py`

#### Files Modified:
- `RocketLander/Info.plist` — v2.1.0, Build 31→32
- `RocketLander/Models/GameCenterManager.swift` — auth VC presentation, topViewController() helper, UIKit import
- `RocketLander/Views/LeaderboardView.swift` — topmost VC presenter, galaxy_rank anchor

#### Build Status:
- Build succeeds, 91/91 tests pass

#### Commits:
- `3c91c96` — Bump version to 2.1.0 Build 31 for TestFlight
- `87125b4` — Add ASC Game Center setup script + session 51 documentation
- `b7580aa` — Fix Game Center auth: present sign-in VC + topmost presenter (Build 32)

#### Definition of Done:
- [x] Version bumped to 2.1.0 Build 31, then Build 32
- [x] Build 31 + 32 uploaded to TestFlight
- [x] setup_game_center.py script created
- [x] 12 leaderboards created in ASC (verified)
- [x] 10 achievements created in ASC (verified)
- [x] All localizations (en-US) added
- [x] Script defaultFormatter bug fixed
- [x] GC auth bug fixed (present authenticateHandler VC)
- [x] GC dashboard presented from topmost VC
- [x] Dashboard anchored to galaxy_rank leaderboard
- [x] All documentation updated
- [ ] Device testing (GC auth, score submission, achievements, Galaxy Rank, share card)

---

### Session 52 (2026-02-06) - v2.1.0 Device Testing + VPN Root Cause + App Store Submission

**Goal:** Investigate and resolve "Sign in to Game Center" issue on device. Verify all GC features. Document findings, reset leaderboard scores, and submit v2.1.0 for App Store review.

#### Investigation & Root Cause:

1. **Initial investigation** (5 parallel agents): Analyzed auth state, GKAccessPoint, leaderboard ID matching, ASC version enablement, score submission flow. All IDs matched. GKAccessPoint bubble showed (confirming auth works). ASC resources in "Ready to Submit" state.

2. **Diagnostic build**: Added `[GC-DIAG]` logging throughout — auth handler, leaderboard probe (`GKLeaderboard.loadLeaderboards`), default leaderboard identifier, 3 dashboard buttons (generic, classic, galaxy_rank).

3. **ROOT CAUSE: VPN blocking GC network traffic**. Console showed `interface: utun4` (VPN tunnel) in network errors. Auth succeeded (cached) but all data fetching failed with "hostname could not be found."

4. **User disabled VPN → everything works**: All 12 leaderboards visible, scores submitted (Moon 3,323 pts, Galaxy Rank 12,323 pts, rank #1), 10 achievements visible, GKAccessPoint showing.

#### Changes Made:

1. **Diagnostic code removed** (`GameCenterManager.swift`, `LeaderboardView.swift`): All `[GC-DIAG]` logging and diagnostic buttons removed. Code restored to clean state.

2. **Defensive guard added** (`LeaderboardView.swift`): `openGameCenterDashboard()` now checks `GKLocalPlayer.local.isAuthenticated` before presenting GKGameCenterViewController.

3. **Setup script enhanced** (`Scripts/setup_game_center.py`): Added `gameCenterAppVersions` support — `get_current_app_store_version()` and `enable_gc_for_app_version()` functions. Needed for App Store submission (not TestFlight).

4. **v2.1.0 release notes prepared** (`RELEASE_NOTES.md`): App Store "What's New" copy and review team notes for v2.1.0.

#### Files Modified:
- `RocketLander/Views/LeaderboardView.swift` — defensive auth guard on dashboard
- `Scripts/setup_game_center.py` — gameCenterAppVersions support
- All 7 documentation files updated

#### Build Status:
- Build succeeds, 91/91 tests pass

5. **Leaderboard scores reset**: Ran `setup_game_center.py --reset` to delete all 12 leaderboards and recreate them fresh, clearing test scores (12,323 pts galaxy_rank) before App Store submission.

6. **App Store screenshot**: Created captioned screenshot `Screenshots/v2.1.0/11_galaxy_rank_captioned.png` (1284x2778) with caption "COMPETE GLOBALLY. CLIMB THE GALAXY RANK."

7. **v2.1.0 submitted for App Store review**: Build 32 submitted with comprehensive What's New (covering v2.1.0 + v2.0.3 + v2.0.2), updated review notes, new screenshot, and updated promotional text.

#### Files Modified:
- `Scripts/setup_game_center.py` — --reset flag, delete_all_leaderboards(), gameCenterAppVersions support
- `RocketLander/Views/LeaderboardView.swift` — defensive auth guard on dashboard
- `RELEASE_NOTES.md` — v2.1.0 What's New and review notes
- `Screenshots/v2.1.0/11_galaxy_rank_captioned.png` — new App Store screenshot
- All 7 documentation files updated

#### Definition of Done:
- [x] Root cause identified (VPN blocks GC network)
- [x] All diagnostic code removed
- [x] Defensive auth guard added to dashboard presentation
- [x] Setup script enhanced with gameCenterAppVersions and --reset
- [x] GC features verified on device (12 leaderboards, scores, rank, achievements)
- [x] Leaderboard scores reset before submission
- [x] App Store screenshot created (Galaxy Rank caption)
- [x] v2.1.0 release notes finalized (What's New + review notes)
- [x] v2.1.0 Build 32 submitted for App Store review
- [x] All 7 documentation files updated
- [x] Build succeeds
- [x] Session summary created

---

### Session 53 (2026-02-06) - GitHub GC Follow-Up: Fix Stale Tags + Reply to Support

**Goal:** Respond to GitHub Support request for sensitive commit SHAs. Audit and fix all stale references on GitHub blocking garbage collection.

#### Changes Made:

1. **Identified sensitive commit SHAs**: Used `.git/filter-repo/commit-map` to find the two old commits containing sensitive data: `17aebc66...` (introduced) and `4c031548...` (removed). Both fully deleted by filter-repo.

2. **Fixed 6 stale remote tags**: All tags (v1.0.0–v1.1.5) on GitHub still pointed to pre-rewrite SHA `67c5802a...`. Deleted and re-pushed all 6 tags. `git push --force` only updates branches, not tags — this was missed in Session 43.

3. **Full reference audit**: Verified no other stale references exist (no PRs, no extra branches, spam issue #1 has no commit refs, 6 releases reference updated tags).

4. **Prepared and sent reply email** to GitHub Support (Collins) with both SHAs, cleanup details, and request to run GC.

#### No code changes. Tag operations only.

#### Definition of Done:
- [x] Sensitive commit SHAs identified
- [x] Stale remote tags fixed (6 tags deleted and re-pushed)
- [x] Full GitHub reference audit completed
- [x] Reply email sent to GitHub Support
- [x] All docs updated
- [x] Session summary created

---

### Session 54 (2026-02-06) - Organic Growth Plan

**Goal:** Save the organic growth plan as a project document and integrate it into session continuity workflow.

#### Changes Made:

1. **Growth plan created** (`Docs/GROWTH_PLAN.md`): Comprehensive organic growth strategy for post-v2.1.0 approval. Covers ASO (top priority), screenshot strategy (5 screenshots, no custom art), event-driven share triggers (new personal best, achievement, Galaxy Rank improvement), Reddit-only social (r/iosgaming, r/IndieGames), and AI division of labor (Claude Code = growth hooks + stability, ChatGPT = ASO copy + drafts, Human = builds + approvals). Weekly challenges deferred until ~200+ DAU.

2. **CLAUDE.md updated**: Added `Docs/GROWTH_PLAN.md` to Session Continuity table, Quick Obligations table, and File Structure section. Future sessions will know to consult it when implementing growth-related features.

3. **README.md updated**: Added `Docs/GROWTH_PLAN.md` to project structure tree.

4. **STATUS.md updated**: Added growth plan to Current Phase description and Immediate Next Tasks (share triggers + screenshots as post-approval tasks).

#### Files Created:
- `Docs/GROWTH_PLAN.md`

#### Files Modified:
- `CLAUDE.md` — Session Continuity table, Quick Obligations, File Structure
- `README.md` — Project Structure tree
- `STATUS.md` — Current Phase description, Immediate Next Tasks, reconciliation date
- `PROJECT_LOG.md` — Session 54 entry

#### No code changes. Documentation only.

#### Key Decisions:
- Growth plan saved as project documentation (not external-only) for session continuity
- Canonical promotional text: "A skill-based landing game where precision beats luck. Master thrust, gravity, and control across the solar system."
- Share triggers are the primary code work item (implement after v2.1.0 approval)
- Weekly challenges deferred until DAU reaches ~200+

#### Definition of Done:
- [x] Growth plan saved as `Docs/GROWTH_PLAN.md`
- [x] CLAUDE.md references growth plan in 3 places
- [x] README.md project structure updated
- [x] STATUS.md updated with growth plan tasks
- [x] PROJECT_LOG.md session entry added
- [x] Session summary created
- [x] All 7 documentation files verified

---

### Session 55 (2026-02-06) - Share Score Card Redesign: Crash Sharing + Compact Stats

**Goal:** Redesign the Share Score Card per growth plan: add crash card variant, replace 5-row stats dump with compact colored stats row, add App Store link, enable sharing on crashes.

#### Changes Made:

1. **LandingMessages.swift** — Added `shortCrashCause()` static function (~20 lines). Returns compact cause strings: "Tilt (18.4°)", "V.Speed (547 m/s)", "H.Speed (89 m/s)", "Missed Platform", or "Ship Lost". Same priority logic as `diagnosticCrashMessage()`.

2. **ShareScoreCardView.swift** — Complete redesign with two variants via `isLanded` conditional:
   - **Landing card**: "STARSHIP LANDER" header → score hero (large mono) → stars → mode/level → platform+band badge → divider → compact stats row (V/H/Fuel with green/yellow/red band colors) → App Store footer
   - **Crash card**: "STARSHIP LANDER" header → crash headline hero (red) → mode/level → CRASH badge (red) → divider → "Cause: ..." diagnostic → App Store footer
   - Crash card border is red instead of orange
   - Removed old 5-row stats dump, `tiltDegrees`, `distanceFromCenter` parameters
   - Added `platform` parameter for band-aware stat coloring
   - `ShareHelper.shareImage()` now accepts text payload with App Store URL
   - `ShareHelper.appStoreURL` constant added
   - Footer legibility improved (semibold + higher opacity)

3. **GameOverView.swift** — Two changes:
   - Share button now visible on both landing AND crash game-over screens
   - `shareScoreCard()` rewritten to build either variant, passing crash headline and compact cause
   - Share text: "I scored X in Starship Lander! <URL>" or "<CRASH HEADLINE> <URL>"

#### Files Modified:
- `RocketLander/Models/LandingMessages.swift` — `shortCrashCause()` added
- `RocketLander/Views/ShareScoreCardView.swift` — complete redesign
- `RocketLander/Views/GameOverView.swift` — crash sharing enabled, data flow updated

#### Build Status:
- Build succeeds, 91/91 tests pass
- Tested on iPhone 16 Pro simulator — both landing and crash cards verified

#### Key Decisions:
- Single `ShareScoreCardView` with `isLanded` conditional (two variants share ~70% layout)
- Compact stats row: V, H, Fuel only — no tilt or center (poster, not telemetry)
- Crash diagnostic uses units: "V.Speed (547 m/s)"
- Stats values colored by band (green/yellow/red) matching HUD design language
- `hitTerrain` inferred from `crashDiagnosticPrimary` text — avoids GameState model changes
- App Store URL: https://apps.apple.com/us/app/starship-lander/id6757563869

#### Definition of Done:
- [x] Crash share card implemented with headline hero + cause diagnostic
- [x] Landing share card redesigned with compact colored stats
- [x] Share button enabled on both landing and crash
- [x] App Store link on card image + URL in share text payload
- [x] Crash diagnostic values include units (m/s)
- [x] Stats values colored by speed/fuel band
- [x] Footer legibility improved
- [x] Build succeeds, 91/91 tests pass
- [x] Simulator tested (landing + crash cards)
- [x] All 7 documentation files verified

---

### Session 56 (2026-02-06) - v2.1.1 Build 33 Version Bump + Upload

**Goal:** Bump version to v2.1.1 Build 33 (share card redesign), archive, and upload to App Store Connect. v2.1.0 approved by Apple.

#### Changes Made:

1. **v2.1.0 approved**: Apple approved v2.1.0 Build 32 for distribution (2026-02-06). Game Center + Share Score Card now live on App Store.

2. **Version bump** (`Info.plist`): v2.1.0 Build 32 → v2.1.1 Build 33.

3. **Build 33 archived and uploaded**: Archive succeeded, exported via `ExportOptions.plist` (app-store-connect method), uploaded to App Store Connect. dSYM warnings for GoogleMobileAds/UserMessagingPlatform (harmless, expected).

4. **Documentation updated**: STATUS.md, CHANGELOG.md, RELEASE_NOTES.md, README.md, PROJECT_LOG.md all updated to reflect v2.1.0 approval and v2.1.1 upload.

#### Files Modified:
- `RocketLander/Info.plist` — v2.1.1 Build 33
- `STATUS.md` — version status, phase, next tasks
- `CHANGELOG.md` — v2.1.1 entry, v2.1.0 marked published
- `RELEASE_NOTES.md` — v2.1.1 section, v2.1.0 marked published
- `README.md` — version, history table
- `PROJECT_LOG.md` — current status table, session entry

#### Build Status:
- Build succeeds, 91/91 tests pass
- Archive succeeded
- Upload succeeded (App Store Connect processing)

#### Commits:
- `2c43aac` — Bump to v2.1.1 Build 33: share card redesign

#### Definition of Done:
- [x] v2.1.0 approval noted in all docs
- [x] Version bumped to v2.1.1 Build 33
- [x] Build 33 archived and uploaded to App Store Connect
- [x] All documentation updated (7-file sweep)
- [x] Session summary created

---

### Session 57 (2026-02-06) - Game Center Achievement Images + ASC Upload

**Goal:** Diagnose why Game Center is not working on live v2.1.0, create achievement icons, upload images to ASC.

#### Root Cause Analysis:
Game Center resources were created via API but never included in an App Store version submission. TestFlight can access "Ready to Submit" resources, but App Store builds cannot. Additionally, achievements were missing required images for their localizations.

#### Changes Made:

1. **Achievement icon generation script** (`Scripts/generate_achievement_icons.py` — NEW): Generates 10 1024x1024 PNG achievement icons using Python Pillow. Badge/emblem style with metallic ring, colored gradients, geometric symbols. Two design iterations (contrast fixes, Solar System Elite redesign with 3 stars + "30").

2. **Achievement images** (`Screenshots/achievements/` — NEW, 10 files): eagle_has_landed, precision_landing, elite_landing, fuel_master, precision_pilot, triple_elite, planet_conquered, first_try_perfection, solar_system_elite, master_lander.

3. **Setup script enhanced** (`Scripts/setup_game_center.py`):
   - Added `--upload-images` flag with `get_achievement_localizations()` and `upload_achievement_image()` (3-step ASC API: reserve, upload binary, commit)
   - PEM key reformatting for single-line keys (extract base64, re-wrap at 64 chars)
   - 401 error handling with diagnostic output
   - All 10/10 images uploaded successfully

#### Files Created:
- `Scripts/generate_achievement_icons.py`
- `Screenshots/achievements/*.png` (10 files)

#### Files Modified:
- `Scripts/setup_game_center.py` — image upload, PEM fix, 401 handling

#### Build Status:
- No app code changes — script and asset changes only

#### Key Decisions:
- Programmatic icon generation (Python Pillow) over design tools for reproducibility
- API upload over manual for efficiency (10 images)

#### Additional Work (after context restore):

5. **GC release resources created** (`Scripts/setup_game_center.py`):
   - Added `--create-releases` flag with `create_leaderboard_release()` and `create_achievement_release()`
   - Root cause: setup script was missing the "release" step — without releases, resources can't be submitted
   - 12/12 leaderboard releases + 10/10 achievement releases created
   - Learned: deleting a draft submission in ASC also deletes all releases — must re-create after deletion
   - `get_existing_achievements()` changed from set to dict (vendorIdentifier -> resource ID)

6. **App Store copy updated**:
   - Description: added COMPETE GLOBALLY section, corrected max score 20,000→23,100
   - What's New: v2.1.1 share card + GC fix, v2.1.0 GC, v2.0.3 gameplay, v2.0.2 campaign
   - Review notes verified

#### Definition of Done:
- [x] Root cause analysis complete (4 root causes)
- [x] 10 achievement icons generated
- [x] 10/10 images uploaded to ASC via API
- [x] 12/12 leaderboard releases created
- [x] 10/10 achievement releases created
- [x] All 22 GC resources visible on v2.1.1 version page
- [x] App Store description updated
- [x] What's New updated
- [x] All documentation updated
- [x] Session summary created
- [ ] Submit v2.1.1 for App Store review (pending user action in ASC)

---
