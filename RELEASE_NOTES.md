# Release Notes

## Version 3.0.0 (Build 40) — "Starship Program"
**Status:** In development on `claude/v300-starship-program` (stacked on v2.3.0). Not uploaded.

### App Store — What's New (Copy this)
```
STARSHIP PROGRAM

• Chapter 2: five new missions. Get caught by the launch tower, belly flop into a flip-and-burn, land on Phobos with almost no fuel, dodge a meteor shower on Ceres, and land at night on Mars
• Real atmosphere: falling sideways slows you down, just like the real Starship
• Race your ghost: your best landing on every level flies beside you
• All-new realistic look: lit steel hull, folding landing legs, shock diamonds, textured terrain and shaded planets
```

---

## Version 2.3.0 (Build 39) — "Mission Control"
**Status:** Release candidate for TestFlight. CI build + full test suite green on GitHub Actions; simulator screenshots verified.

### Overview
The biggest update since Campaign: a reason to come back every day (Pilot Rank + Hangar), a landing that feels cinematic, flight aids that make the game learnable, and a visual overhaul of every world. Also fixes the Sound/Haptics toggles and a frame-rate bug that could make the engine feel weak.

### App Store — What's New (Copy this)
```
MISSION CONTROL UPDATE

• Pilot Rank: earn XP on every flight and climb 10 ranks from Cadet to Starship Legend
• Hangar: spend Blue Stars on 7 Starship paint schemes, each with its own engine glow
• Cinematic landings: the camera zooms in on final approach, with dust, sparks and bigger explosions
• Flight guidance: a guide line turns green when you're lined up with the pad, plus a live descent readout by your ship
• Every world redesigned with its own sky, horizon glow and atmosphere
• Fixes: Sound and Haptics settings now work, smoother thrust on every device
```

### App Store — Review Team Notes (Copy this)
```
Starship Lander is a skill-based physics rocket landing game. No account, login or in-app purchase is required.

New in 2.3.0: Pilot Rank (XP earned in-game) and a Hangar of cosmetic ship paint schemes bought with Blue Stars, an in-game currency earned only by playing (no real-money purchase exists). No new SDKs, no new data collection; ads unchanged from 2.2.x (banner + interstitial every 7th retry, text/image only).
```

---

## Version 2.2.1 (Build 38)
**Status:** Submitted for App Store review. App Store Connect state `WAITING_FOR_REVIEW` at `2026-05-04T01:20:53Z`.

### Overview
Version 2.2.1 is an emergency stability hotfix for v2.2.0. It keeps the Daily Challenge, Blue Star, interstitial ad, refreshed Starship art, and global rank features from v2.2.0, while fixing the crash reported when starting Campaign gameplay after selecting a planet such as Earth or Venus.

### Fixed
- Campaign startup crash: campaign Game Center attempt tracking now saves property-list-safe string-keyed data into `UserDefaults`.
- Fresh run reset handling: new Classic/Campaign/Daily scenes clear stale reset state during setup so the first input cannot immediately reset the scene or double-count a Campaign attempt.
- Daily Challenge hazard parity: Mercury heat shimmer and Io volcanic eruption effects now run in Daily Challenge as well as Campaign.
- Heat particle cleanup: reset removes the secondary `heatParticles` action alongside the main heat shimmer action.

### Verification
- GitHub Actions iOS CI passed for the hotfix branch: 96 tests, 0 failures.
- Local SSD Xcode 26.4.1 test suite passed: 96 tests, 0 failures.
- Release archive succeeded and Build 38 uploaded through Xcode Organizer.
- App Store Connect processed Build 38 as `VALID`, attached it to v2.2.1, and accepted the review submission.

### App Store — What's New (Copy this)
```
HOTFIX IN v2.2.1

• Fixes a crash that could close the app when starting Campaign mode after selecting a planet
• Improves fresh-run reset handling so a new run cannot immediately reset on first input
• Restores Mercury heat shimmer and Io volcanic effects in Daily Challenge

Also includes the v2.2 Daily Challenge update: 75 rotating challenges, Blue Star rewards, global rank display, refreshed Starship artwork, and improved campaign/daily scoring persistence.
```

### App Store — Review Team Notes (Copy this)
```
Starship Lander is a skill-based physics rocket landing game. Players control thrust and rotation using on-screen buttons and must land safely on a platform. No account, login, or in-app purchases are required.

This v2.2.1 hotfix resolves a live v2.2.0 Campaign startup crash. Repro in the affected build: open Campaign, select a planet such as Earth or Venus, then start gameplay. The fix makes campaign Game Center attempt tracking persist with property-list-safe keys and also clears stale fresh-run reset state.

Daily Challenge is available from the main menu. Blue Stars are earned in-game through Daily Challenge completions and campaign milestones; there is no in-app purchase in this build.

Interstitial ads appear every 7th Retry/Next Level tap (text/image only, no video). They use the existing Google Mobile Ads SDK already declared in the app. No new SDKs were added. The app does not collect any new data.

Game Center authentication occurs automatically on launch. If the player is not signed in, all Game Center features are hidden and the game works normally with local scores only.

An App Tracking Transparency prompt appears on first launch before showing personalized ads.
```

---

## Version 2.2.0 (Build 37)
**Status:** Approved and distributed by Apple on 2026-05-03. Live testing found a campaign-start crash in Build 37; Session 67 has a local hotfix pending Xcode/simulator verification and replacement build upload.

### Overview
Version 2.2.0 is a retention and monetization update. Daily Challenge gives players a new reason to open the app every day — 75 unique challenges rotating across all 10 planets with rich constraints (target platform, speed limits, tilt precision, fuel efficiency, time limits). Blue Star currency rewards consistency and skill. Interstitial ads every 7th replay diversify revenue beyond banners. Global rank on the game-over screen surfaces competition after every landing.

### Build 37 Fixes
- Campaign stars, unlocks, and personal bests persist even if the high-score name sheet is skipped
- Daily Challenge failed landings no longer save into Classic scores
- Daily Challenge rotation now uses UTC day boundaries for worldwide consistency
- Earth moving-platform landings use the live platform position for bounds and scoring
- Default Starship art refreshed with a more recognizable game-styled stainless body, heat-shield strip, flaps, engines, and legs
- `daily_challenge` added to the Game Center setup script for App Store Connect creation/release

### Pending Hotfix
- Campaign attempt tracking now saves Game Center attempt counts with string keys in `UserDefaults`. Build 37 can crash when starting a campaign run because the auto-start path saves a nested `[Int: Int]` dictionary, which is not a valid property-list dictionary.
- New game scene setup now clears stale reset state so the first input does not immediately reset the scene or double-count campaign attempts.
- Daily Challenge now runs Mercury heat shimmer and Io volcanic eruption effects just like Campaign mode.

### Release Prep Status
- Full simulator test suite passed: 94 tests, 0 failures
- Simulator smoke screenshots captured for menu, Daily Challenge, and campaign gameplay
- Archive succeeded: `build/RocketLander-Build37.xcarchive`
- Local App Store IPA export succeeded: `build/export-build37-local/RocketLander.ipa`
- Build 37 uploaded through Xcode Organizer and is VALID in App Store Connect
- `daily_challenge` leaderboard created, localized, and released in App Store Connect
- Free Apps and Paid Apps agreements verified active through January 7, 2027
- v2.2.0 App Store version created, Build 37 attached, ASO copy/review notes updated
- Five App Store screenshots uploaded to the iPhone 6.5/6.7 screenshot set
- App Store review submission approved and distributed on 2026-05-03

### Build 36 Fixes
- Menu layout: settings and help icons moved to top-right bar (no longer hidden behind ad)
- Banner ad uses safeAreaInset for proper space reservation — Campaign button fully visible

### Build 35 Fixes
- Interstitial ads: reduced frequency (every 7th vs 3rd), disabled video ads (text/image only)
- Thrust button: multi-touch no longer causes stuck thrust

### App Store — What's New (Copy this)
```
NEW IN v2.2.0

DAILY CHALLENGE
  • A new challenge every day — same worldwide, compete globally
  • 75 unique challenges across all 10 planets with 1-5★ difficulty
  • 6 constraint types: target platform, tilt precision, speed limits, fuel efficiency, time limits
  • Countdown timer for timed challenges with time bonus scoring
  • Pre-challenge briefing with objectives, planet info, and global leaderboard
  • Track your streak and earn Blue Stars

BLUE STARS
  • New reward currency earned through daily challenges
  • Complete a challenge: +1 Blue Star
  • 5-day streak bonus: +3 Blue Stars
  • Campaign milestones: earn up to 210 Blue Stars

COMPETITION
  • Global rank shown after every landing — see where you stand
  • Daily Challenge leaderboard on Game Center

PREVIOUS UPDATES
  • Game Center: 12 leaderboards, 10 achievements, Galaxy Rank
  • Share your landings and crashes as score cards
  • 10 solar system levels with unique physics and hazards
  • Score up to 23,100 points

As always, thank you for your continued support.
```

### App Store — Review Team Notes (Copy this)
```
Starship Lander is a skill-based physics rocket landing game. Players control thrust and rotation using on-screen buttons and must land safely on a platform. No account, login, or in-app purchases are required.

This build (v2.2.0, Build 37) adds a Daily Challenge feature, Blue Star currency, interstitial ads, and global rank display. The Daily Challenge presents a new challenge each day with specific objectives (land on a particular platform, maintain low tilt, finish within a time limit, etc.). Blue Stars are earned through daily challenge completion, streaks, and campaign milestones — they are displayed but have no spending mechanism yet.

Interstitial ads appear every 7th Retry/Next Level tap (text/image only, no video). They use the existing Google Mobile Ads SDK already declared in the app. No new SDKs were added. The app does not collect any new data.

Game Center authentication occurs automatically on launch. If the player is not signed in, all Game Center features are hidden and the game works normally with local scores only.

An App Tracking Transparency prompt appears on first launch before showing personalized ads.
```

---

## Version 2.1.1 (Build 33)
**Status:** SUBMITTED FOR REVIEW (2026-02-06) — Share card redesign + Game Center fix

### Overview
Version 2.1.1 redesigns the Share Score Card with crash sharing, compact colored stats, and App Store branding. Fixes Game Center leaderboard and achievement integration (resources now properly released and bundled with app version). Crash game-over screens now have a share button, and the card uses a poster-style layout instead of a telemetry dump.

### App Store — What's New (Copy this)
```
NEW IN v2.1.1
  • Share your crashes too — "RAPID UNSCHEDULED DISASSEMBLY" cards are now shareable
  • Redesigned score cards — clean poster layout with colored stats
  • Stats colored by landing band — green (safe), yellow (hard), red (fail)
  • Fixed Game Center leaderboard and achievement integration

GAME CENTER (v2.1.0)
  • Global leaderboards — compete worldwide in Classic Mode, all 10 campaign levels, and Galaxy Rank
  • 10 achievements — from your first safe landing to mastering every planet
  • Galaxy Rank — your total campaign mastery score, ranked globally
  • Share your best landings with score cards

GAMEPLAY UPDATES (v2.0.3)
  • Scoring rebalance — higher, more rewarding scores
  • Tilt thresholds — three bands like speed: Safe (≤3°), Hard (≤6°), Crash (>6°)
  • Europa cryogeysers — erupting ice plumes that push your rocket upward
  • Jupiter overhaul — stronger gusts and higher gravity
  • HUD-style Flight Data with OK / HARD / FAIL badges per metric
  • Tighter speed thresholds for a more skill-driven challenge

CAMPAIGN MODE (v2.0.2)
  • 10 solar system levels — Moon to Jupiter, each with unique gravity and challenges
  • Three landing platforms per level (1×, 2×, 5× multipliers)
  • Environmental hazards: dust storms, dense atmospheres, cryogeysers, moving platforms, vertical updrafts, heat interference, rock pillars, volcanic debris, sudden gusts
  • Star rating system — earn up to 30 stars across the campaign
  • Haptic feedback, proportional thrust vectoring, and per-level high scores

As always, thank you for your continued support.
```

### App Store — Review Team Notes (Copy this)
```
Starship Lander is a skill-based physics rocket landing game. Players control thrust and rotation using on-screen buttons and must land safely on a platform. No account, login, or in-app purchases are required.

This build (v2.1.1, Build 33) fixes the Game Center leaderboards integration and improves the Share Score Card feature. Game Center provides global leaderboards and achievements. The Share Score Card generates an image of the landing result and opens the native iOS share sheet.

Game Center authentication occurs automatically on launch. If the player is not signed in, all Game Center features are hidden and the game works normally with local scores only. No additional data is collected — all Game Center data ("Gameplay Content") is handled by Apple.

An App Tracking Transparency prompt appears on first launch before showing personalized ads. Players can choose between button controls and tilt-based controls from the main menu.
```

---

## Version 2.1.0 (Build 32)
**Status:** PUBLISHED (approved 2026-02-06) — Live on App Store

### Overview
Version 2.1.0 adds Game Center integration and a Share Score Card. Compete on global leaderboards, earn 10 achievements, and share your best landings with friends. Galaxy Rank tracks your total campaign mastery across all 10 levels.

---

## Version 2.0.3 (Build 30)
**Status:** PUBLISHED (approved 2026-02-06) — Live on App Store

### Overview
Version 2.0.3 is a gameplay tuning and polish update. Scoring rebalanced for higher and more rewarding scores, tilt forgiveness doubled, Europa mechanic replaced with cryogeysers, Jupiter overhauled, speed thresholds tightened, and Flight Data panel redesigned with badges.

### App Store — What's New (Copy this)
```
GAMEPLAY UPDATE

• Scoring rebalance — scores are higher and more rewarding. HARD landings now earn partial credit instead of zeroing out.
• Tilt forgiveness — tilt now uses three bands like speed: safe (≤3°), hard (≤6°), crash (>6°). No more instant death at 3°
• Europa cryogeysers — ice slide crash replaced with erupting ice plumes that push your rocket. Time your descent between eruptions
• Jupiter overhaul — wind now with stronger gusts, gravity increased
• Tighter speed thresholds across all platforms for a better challenge
• HUD-style Flight Data panel with OK/HARD/FAIL badges on every metric
• How to Play info sheet with full game documentation
• Other bug fixes

As always, thank you for your continuous support!
```

### App Store — Review Team Notes (Copy this)
```
This is a skill-based physics rocket landing game.
Use on-screen buttons to control thrust and rotation and land safely on the platform.
No account, login, or in-app purchases required.

This build (v2.0.3, Build 30) includes gameplay tuning improvements over v2.0.2. No new SDKs were added — only balance and polish changes to the campaign mode mechanics.

Campaign mode has 10 levels with unique environmental mechanics: dust storms (Mars), dense atmosphere drag (Titan), cryogeyser eruptions (Europa), moving platforms (Earth), vertical updrafts (Venus), heat-induced thrust interference (Mercury), rock pillar obstacles (Ganymede), deadly volcanic debris (Io), and sudden wind gusts (Jupiter).

App Tracking Transparency prompt appears on first app launch to request permission before showing personalized ads. Users can toggle between traditional button controls and tilt-based accelerometer controls from the main menu.
```

---

## Version 2.0.2 (Build 16)
**Status:** PUBLISHED (approved 2026-02-03) — Campaign Mode live on App Store

### Overview
Version 2.0.2 is a major update that transforms Starship Lander from a single-mode arcade game into a full campaign experience across the solar system. Land on 10 different worlds, each with unique gravity, engine thrust, and environmental hazards. Choose between three landing platforms per level with increasing difficulty and score multipliers. Replaces the previously submitted v2.0.0 (Build 12) with gameplay tuning: rebalanced scoring, proportional thrust vectoring, differentiated planet mechanics, and leaderboard star metadata.

---

### Campaign Mode
A brand new 10-level campaign spanning the solar system. Levels unlock progressively — complete one to unlock the next. Each level features a unique celestial body with its own physics, visuals, and environmental challenges.

| # | Planet | Gravity | Thrust | Special Mechanic |
|---|--------|---------|--------|------------------|
| 1 | Moon | 1.6 m/s² | 8.0 | None — training level |
| 2 | Mars | 2.0 m/s² | 9.5 | Light wind (dust storms) |
| 3 | Titan | 2.2 m/s² | 10.0 | Dense atmosphere (drag + haze) |
| 4 | Europa | 2.5 m/s² | 11.0 | Ice surface (low friction landing) |
| 5 | Earth | 2.8 m/s² | 12.0 | Moving platforms |
| 6 | Venus | 3.2 m/s² | 13.0 | Vertical updrafts |
| 7 | Mercury | 3.5 m/s² | 14.0 | Heat interference (thrust disruption) |
| 8 | Ganymede | 3.8 m/s² | 15.0 | Deep craters (rock pillars + terrain walls) |
| 9 | Io | 4.2 m/s² | 16.5 | Deadly volcanic debris |
| 10 | Jupiter | 4.8 m/s² | 18.5 | Sudden gusts with calm windows |

- Gravity increases monotonically from 1.6 (Moon) to 4.8 (Jupiter) for a smooth difficulty curve
- Thrust-to-gravity ratio decreases from 5.0x (Moon, floaty and forgiving) to 3.8x (Jupiter, powerful but tight margin)
- Classic mode remains unchanged at gravity 2.0 / thrust 12.0

### Per-Planet Physics
Each planet has a unique engine thrust value, not just different gravity. This means every world has a distinct "engine feel" — Moon feels floaty and forgiving, while Jupiter gives you raw power but almost no margin for error. Players must adapt their piloting style to each destination.

### Three Landing Platforms
Every level now features three landing platforms with different sizes and score multipliers:

| Platform | Position | Width | Multiplier | Color |
|----------|----------|-------|------------|-------|
| Training Zone (A) | Left (18%) | 130pt | 1x | Green |
| Precision Target (B) | Center (50%) | 110pt | 2x | Yellow |
| Elite Landing (C) | Right (82%) | 80pt | 5x | Red |

- Platform labels and multiplier text displayed below each platform
- Terrain automatically generates valleys around each platform position
- Choose your risk/reward — easy landing or high score attempt

### Visual Effects
Each environmental mechanic now has a corresponding visual effect:

- **Wind streaks** (Mars, Jupiter): Horizontal particle streaks at varying intensity — light dust (Mars), extreme streaks (Jupiter)
- **Vertical updraft particles** (Venus): Particles rising from below, matching the vertical wind force
- **Atmosphere haze** (Titan): Semi-transparent overlay with drifting cloud particles simulating Titan's thick nitrogen atmosphere
- **Ice shimmer** (Europa): Twinkling sparkle particles near the platform surface, plus low-friction physics on landing
- **Heat shimmer** (Mercury): Visual distortion plus thrust control interference — random perturbation when thrusting
- **Volcanic eruptions** (Io): Deadly particle bursts erupting from the terrain — active debris causes crash on contact
- **Planetary bodies**: Each level displays its parent planet/moon in the sky (Earth shows the Moon, Titan shows Saturn, etc.)

### Star Rating System
Earn 1 to 3 stars per landing based on which platform you land on:
- Platform A (Training Zone) = 1 star
- Platform B (Precision Target) = 2 stars
- Platform C (Elite Landing) = 3 stars

Total: 30 stars possible across all 10 campaign levels. Star count displayed on the main menu and level select screen.

### Scoring System
Platform multiplier stacks with the fuel multiplier:
- Formula: `base subtotal × fuel multiplier × platform multiplier`
- Max theoretical score: 2,000 × 2.0 × 5 = **20,000 points**
- Score components: Soft landing (500), Horizontal precision (400), Platform center (600), Rotation (250), Approach control (150)
- Center precision is the highest-weighted single component — rewarding accurate targeting

### Per-Level High Scores
Campaign mode tracks top-3 scores **per level** separately from classic mode's global leaderboard. Each planet has its own leaderboard with its own high score entries.

### Landing Messages
Contextual feedback on every landing and crash:
- **Success messages** rotate: "Landing confirmed.", "Precision achieved.", "Controlled descent.", etc.
- **Elite messages** for 3-star landings: "Elite landing.", "Near-perfect execution."
- **Crash messages** with teaching tips: "Try a slower approach.", "Keep the rocket upright on final approach.", etc.
- **Rare easter egg** (1 in 50 chance, score > 4,500): "This was exceptional."

### Haptic Feedback
Tactile feedback for all key game actions (iPhone only):
- **Thrust**: Light continuous pulse every 100ms while engine is firing
- **Rotation**: Medium impact haptic on rotation start
- **Successful landing**: Success notification haptic
- **Crash**: Heavy double-tap impact

### Improved Controls
- **Proportional thrust vectoring**: Lateral force scales smoothly with tilt angle via `sin(rotation) × 0.15` — only active while thrusting, requiring fuel to correct
- **Increased rotation power**: `rotationPower` increased from 0.025 to 0.04
- **Reduced angular damping**: From 1.0 to 0.7 for snappier rotation response

### Astronaut Easter Eggs
High score leaderboards come pre-populated with 1,000-point default entries featuring names of astronauts and scientists relevant to each celestial body:

| Level | Default Name | Reference |
|-------|-------------|-----------|
| Classic | Elon | Elon Musk, SpaceX founder |
| Moon | Armstrong | Neil Armstrong, first moonwalker |
| Mars | Aldrin | Buzz Aldrin, Mars mission advocate |
| Titan | Huygens | Christiaan Huygens, discovered Titan |
| Europa | Galileo | Galileo Galilei, discovered Europa |
| Earth | Gagarin | Yuri Gagarin, first human in space |
| Venus | Shepard | Alan Shepard, first American in space |
| Mercury | Glenn | John Glenn, Project Mercury astronaut |
| Ganymede | Marius | Simon Marius, named the Galilean moons |
| Io | Collins | Michael Collins, Apollo 11 command module pilot |
| Jupiter | Shoemaker | Eugene Shoemaker, Shoemaker-Levy 9 comet |

Default scores are seeded only on first launch — they will never overwrite player scores.

### Level Select Screen
- 2-column grid showing all 10 levels
- Each card displays: level number, planet name, star count, best score
- Unlocked levels show gravity (m/s²) and special mechanic
- Locked levels appear dimmed with a lock icon
- Total star count displayed at top right

### Ganymede Deep Craters
Ganymede features a unique hazard: deep crater terrain with rock pillar obstacles.
- Three jagged rock pillars with collision physics (left edge, between platforms B-C, right edge)
- Terrain walls ramp up to 350px at screen edges, creating a crater bowl effect
- Hitting terrain or rock pillars is fatal — adds a navigation challenge unique to this level

### Menu Redesign
- Two launch buttons: "Classic" (orange) and "Campaign" (blue/purple gradient)
- TOP PILOTS leaderboard displayed on main menu
- Total campaign star count shown between the buttons
- Menu wrapped in ScrollView for Dynamic Island safe area support
- "HOW TO PLAY" and controls section fully visible on all screen sizes

### Game Over Screen
- Shows star rating for the landing
- Displays platform name and multiplier
- "Next Level" button in campaign mode to advance without returning to menu
- "Retry" button to immediately replay the same level
- High score entry appears inline when score qualifies

---

### Bug Fixes
- **Fixed**: Game title "STARSHIP" no longer hidden behind Dynamic Island on iPhone 16 and later — menu wrapped in ScrollView to respect safe area insets
- **Fixed**: "HOW TO PLAY" section and banner ad no longer cut off at bottom of menu on any screen size
- **Fixed**: Earth level moving platforms no longer overlap during movement — Platform A now bobs vertically only, Platform B/C horizontal sway reduced, edge clamping enforces minimum 10pt gaps
- **Fixed**: Campaign gravity fully rebalanced — all 10 levels use progressively increasing gravity (1.6 → 4.8) with per-level thrust scaling for a smooth difficulty curve
- **Fixed**: Ganymede terrain now features rock pillar obstacles and raised crater walls instead of failed terrain ridge approach
- **Fixed**: Classic mode star rating now saved correctly in high scores (was always 0)
- **Fixed**: Classic mode star rating now displayed in leaderboard and menu TOP PILOTS section
- **Fixed**: Accelerometer toggle not affecting gameplay (v2.0.1)

### Architecture
- Codebase split from 2 monolithic files (~900 lines each) into 21 organized files:
  - `Models/`: GameState, HighScoreManager, LandingPlatform, LandingMessages, LevelDefinition, CampaignState
  - `Views/`: GameContainerView, GameOverView, HUDViews, ControlViews, ShapeViews, LevelSelectView
  - `Haptics/`: HapticManager
  - `GameScene+Setup.swift`, `GameScene+Effects.swift`, `GameScene+Sound.swift`, `GameScene+Scoring.swift`
- ContentView.swift trimmed to ContentView + MenuView only
- GameScene.swift trimmed to core update loop, physics, and collision handling

---

### App Store — What's New (Copy this)
```
MAJOR UPDATE — Campaign Mode!

NEW:
• Campaign Mode — 10 solar system levels from Moon to Jupiter
• Per-planet physics — unique gravity and engine thrust per world
• Three landing platforms with score multipliers (1x, 2x, 5x)
• Visual effects — wind, haze, ice shimmer, heat distortion, volcanic eruptions
• Star rating system — earn up to 30 stars
• Haptic feedback for thrust, landings, and crashes
• Per-level high score leaderboards
• Score up to 20,000 points!

IMPROVEMENTS:
• Proportional thrust vectoring for smoother lateral control
• Fixed layout for iPhone 16 Dynamic Island
```

### App Store — Description (Copy this)
```
Landing is easy.
Landing well is not.

Starship Lander is a precision piloting game where every decision matters. Control thrust, rotation, and fuel as you descend onto increasingly demanding landing zones — across ten worlds with unique physics and hazards.

This is a game about restraint, timing, and judgment under pressure.

CAMPAIGN MODE — 10 WORLDS

Travel across the solar system, from the forgiving Moon to brutal Jupiter. Each level introduces new gravity, engine behavior, and environmental challenges — requiring you to adapt your piloting style every time.

No upgrades.
No shortcuts.
Only skill.

CHOOSE YOUR RISK

Every level offers three landing platforms:

Training Zone (1×) — wide, forgiving

Precision Target (2×) — tighter margins

Elite Landing (5×) — small, unforgiving, high reward

Higher scores demand higher risk. The choice is yours.

DEEP, SKILL-BASED SCORING

Your score reflects how well you fly — not just whether you survive.

Vertical & horizontal control

Rotation accuracy

Landing precision

Fuel efficiency

Platform multipliers

Perfect execution can score up to 20,000 points.

FEEL THE PHYSICS

Real-time physics simulation

Distinct thrust behavior per planet

Button or tilt controls

Haptic feedback for thrust, landings, and crashes

Every landing has weight. Every mistake is felt.

PROVE YOUR MASTERY

Earn up to 30 stars across the campaign

Per-level high score leaderboards

Hidden astronaut benchmark scores — can you beat them?

This is not a casual experience.
It's a test of control.
```

### App Store — Review Team Notes (Copy this)
```
This is a skill-based physics rocket landing game.
Use on-screen buttons to control thrust and rotation and land safely on the platform.
No account, login, or in-app purchases required.

This build (v2.0.2, Build 16) replaces the previously submitted v2.0.0 (Build 12) with gameplay tuning improvements. No new features or SDKs were added — only balance and polish changes to the campaign mode mechanics.

Campaign mode has 10 levels with unique environmental mechanics: dust storms (Mars), dense atmosphere drag (Titan), ice surfaces (Europa), moving platforms (Earth), vertical updrafts (Venus), heat-induced thrust interference (Mercury), rock pillar obstacles (Ganymede), deadly volcanic debris (Io), and sudden wind gusts (Jupiter).

App Tracking Transparency prompt appears on first app launch to request permission before showing personalized ads. Users can toggle between traditional button controls and tilt-based accelerometer controls from the main menu.
```

---

## Version 1.1.5 (Build 11)
**Status:** SUBMITTED FOR REVIEW (2026-01-16)

### What's New
- New scoring system with better differentiation (max ~5000 points)
- Continuous scoring - every improvement counts
- Fuel efficiency now multiplies your score (save fuel for higher scores!)
- Fixed HUD text wrapping on high velocities
- Version number now displayed on menu screen

### App Store Release Notes (Copy this)
```
- New and improved scoring system (max ~5000 points)
- Save fuel to multiply your score!
- Bug fixes and improvements
```

---

## Version 1.1.4 (Build 10)
**Status:** PUBLISHED (2026-01-15)

### What's New
- Complete fix for high score name input bug
- New Starship-style app icon (cylindrical body, flaps, landing legs)

### App Store Release Notes (Copy this)
```
- New Starship-style app icon
- Fixed high score name input issue
- Bug fixes and improvements
```

---

## Version 1.1.3 (Build 7)
**Status:** PUBLISHED (2026-01-14)

### What's New
- Fixed high score name input not responding to taps
- Updated developer website URLs

### App Store Release Notes (Copy this)
```
- Fixed issue where high score name input wasn't responding
- Bug fixes and improvements
```

---

## Version 1.1.2 (Build 6)
**Status:** PUBLISHED (2026-01-12)

### What's New
- New accelerometer controls - tilt your phone to rotate the rocket
- Toggle between button and tilt controls in the menu
- Improved button sensitivity for finer rotation control

### App Store Release Notes (Copy this)
```
- New accelerometer controls! Tilt your phone to rotate the rocket
- Toggle between button and tilt controls in the menu
- Improved button sensitivity for finer rotation control
- Smoother gameplay experience
```

---

## Version 1.1.0 (Build 4)
**Status:** PUBLISHED (2026-01-12)

### What's New
- Added support for advertisements to help keep the game free

### App Store Release Notes
```
Bug fixes and performance improvements.
Added support for in-app advertisements.
```

---

## Version 1.0 (Build 2)
**Status:** REJECTED (Guideline 5.1.2 - Superseded by v1.1)

### What's New
- Initial release of Starship Lander
- Land the Starship safely on the platform
- Retro 16-bit sound effects
- High score leaderboard

### App Store Release Notes
```
Land the Starship on the landing platform!

Features:
• Realistic physics-based gameplay
• Intuitive touch controls for thrust and rotation
• Retro 16-bit sound effects
• High score leaderboard - compete for the top spot!
• Fuel management adds strategic depth

Can you master the perfect landing?
```
