# Starship Lander - Project Log

This file documents the development history and decisions for the Starship Lander project. Use this to continue work in future sessions.

---

## Project Overview

- **App Name:** Starship Lander
- **Bundle ID:** com.tboliveira.StarshipLander
- **Platform:** iOS (iPhone)
- **Framework:** SwiftUI + SpriteKit
- **Developer:** Thiago Borges de Oliveira
- **Team ID:** 6XK6BNVURL

---

## Current Status (2026-11-10, Session 70)

| Version | Build | Status |
|---------|-------|--------|
| 1.0 | 2 | Rejected (Guideline 5.1.2 - tracking without ATT) |
| 1.1.0 | 4 | Published on App Store |
| 1.1.2 | 6 | Published - Accelerometer controls |
| 1.1.3 | 7 | Published - Partial bug fix + URL update |
| 1.1.4 | 10 | Published - Bug fix + new icon |
| 1.1.5 | 11 | Published on App Store - New scoring system + HUD fixes |
| 2.0.2 | 16 | Published (approved 2026-02-03) — Campaign Mode |
| 2.0.3 | 30 | Published (approved 2026-02-06) — scoring rebalance + tilt bands + Europa cryogeysers |
| 2.1.0 | 32 | **PUBLISHED** (approved 2026-02-06) — Game Center + Share Score Card. **Live on App Store.** |
| 2.1.1 | 33 | **SUBMITTED FOR REVIEW** (2026-02-06) — Share card redesign + GC fix |
| 2.2.0 | 34 | Build 34 on TestFlight — initial v2.2.0 upload |
| 2.2.0 | 35 | On TestFlight — bug fixes (ad frequency, thrust multi-touch) |
| 2.2.0 | 36 | **ON TESTFLIGHT** — menu layout redesign (icons to top-right, safeAreaInset for ad) |
| 2.2.0 | 37 | **PUBLISHED / LIVE** — Approved and distributed by Apple on 2026-05-03. Live campaign startup crash reported; local hotfix pending Xcode verification/replacement build. |
| 2.2.1 | 38 | **SUBMITTED FOR REVIEW** — Campaign startup crash hotfix; uploaded, metadata updated, Build 38 attached, review submission waiting. |
| 3.0.0 | 40 | **CODE COMPLETE, CI GREEN** — "Starship Program": Chapter 2 (5 missions), atmospheric drag, ghost replay, folding legs, realistic rendering. Stacked on 2.3.0. |
| 2.3.0 | 39 | **UPLOADED TO APP STORE CONNECT** (2026-11-10) — "Mission Control": Pilot Rank, Hangar, landing camera, flight guidance, RCS hold, visual overhaul, settings + frame-rate fixes. Processing/TestFlight not yet confirmed. |

**NEXT STEPS:**
0. v2.3.0 Build 39 uploaded (2026-11-10). Confirm TestFlight processing, device-test, merge PR #4, submit.
1. Monitor v2.2.1 Build 38 App Store review status.
2. Verify replacement build on device/App Store/TestFlight after approval/distribution.
3. Confirm Campaign startup on Earth, Venus, and an early unlocked planet in the replacement build.
4. Resume growth/v2.3 work only after live crash is resolved.

**v2.2.0 — Phase: Retention + Monetization (Build 37 local release candidate):**
- [done] Daily Challenge System (75 templates, 6 constraint types, auto-computed difficulty, deterministic cycling)
- [done] Daily Challenge Briefing Screen (planet info, objectives, difficulty, GC top score, streak)
- [done] Blue Star Currency (daily challenge +1, streak bonus +3, campaign milestones)
- [done] Interstitial Ads (every 7th Retry/Next Level, never blocking, text/image only)
- [done] Global Rank on game-over screen (per-leaderboard rank ~1s after score submission)
- [done] Modernized Menu (sci-fi typography, top-right utility icons, safeAreaInset banner spacing, blue star count, streak display)
- [done] How To Play expanded (Daily Challenge + Blue Stars sections)
- [done] Elapsed time tracking (for time-limited daily challenges)
- [done] Production interstitial ad unit ID (ca-app-pub-3801339388353505/8269147180)
- [done] 75 templates with auto-computed difficulty (expanded from 20)
- [done] Challenge failure UX (orange warning, sad trombone)
- [done] Menu layout redesign (icons moved to top-right, safeAreaInset for ad) — Build 36
- [done] Multi-touch thrust stuck fix (onLongPressGesture replacing DragGesture)
- [done] Local progression/reward fixes (campaign progress independent of score sheet, Daily Challenge score isolation, UTC daily dates, moving-platform live center scoring)
- [done] Default Starship visual refresh (stylized stainless body, heat-shield strip, flaps, legs, engine detail; physics body unchanged)
- [done] Simulator build/test verification of local fixes (94 tests, 0 failures on iPhone 17 Pro simulator / iOS 26.4)
- [done] Simulator release smoke screenshots for menu, Daily Challenge, and campaign gameplay
- [done] Build 37 archive, local App Store IPA export, Xcode Organizer upload, and ASC VALID processing
- [done] `daily_challenge` leaderboard created and released in App Store Connect
- [done] v2.2.0 App Store version created in ASC
- [done] Build 37 attached to v2.2.0
- [done] ASO metadata, review notes, and five App Store screenshots uploaded
- [done] v2.2.0 submitted for App Store review on 2026-05-01 (later approved/distributed 2026-05-03)
- [done] v2.2.0 Build 37 approved/distributed by Apple (2026-05-03)
- [hotfix] Campaign startup crash fix: Game Center attempt tracking now saves string-keyed dictionaries to UserDefaults
- [hotfix] Fresh scene setup clears stale `shouldReset` to avoid first-input reset/double attempt tracking
- [hotfix] v2.2.1 Build 38 approved as the replacement version/build
- [hotfix] Local Xcode restored on SamsungSSD; local `xcodebuild test` passed with 96 tests, 0 failures
- [hotfix] Daily Challenge Mercury/Io hazards now run under `usesLevelDefinition`
- [hotfix] v2.2.1 Build 38 archived, uploaded through Xcode Organizer, processed as VALID, attached in App Store Connect, and submitted for review
- [blocked] Physical device install/test (iPhone 16 TBO offline on this machine)

**BACKLOG (v2.3+):**
- ~~Blue star spending mechanism~~ — done in v2.3.0 (Hangar)
- Missions/contracts (multi-flight goals) building on Pilot Rank
- ~~Ghost replay of personal best per level~~ — done in v3.0.0
- Chapter 2 achievements (tower catch, belly flop) — need ASC achievement records
- Throttle control (analog thrust) — revisit gesture approach (earlier DragGesture multi-touch bug)
- Premium/unlockable realistic Starship skin based on generated concept art
- iPad support
- Localization
- UI tests (XCUITest)

---

## AdMob Configuration

| Setting | Value |
|---------|-------|
| Publisher ID | pub-3801339388353505 |
| App ID | ca-app-pub-3801339388353505~8476936917 |
| Banner Ad Unit ID | ca-app-pub-3801339388353505/4009394081 |

**Implementation:**
- Test ads shown in DEBUG builds
- Production ads in RELEASE builds
- Banner ads on menu screen and during gameplay
- SDK: Google Mobile Ads via Swift Package Manager (v12.14.0)

---

## Development History

> **Sessions 1-57** (2026-01-07 through 2026-02-06) have been archived to `PROJECT_LOG_ARCHIVE.md`.
> The archive includes a project history summary at the top for quick context restoration.
> Consult the archive when investigating decisions or changes from earlier sessions.

---

### Session 58 (2026-02-20) - v2.2.0 Retention + Monetization Implementation + Menu Modernization

**Goal:** Implement v2.2.0 features (Daily Challenge, Blue Stars, Interstitial Ads, Global Rank) and modernize the main menu. Full documentation sweep.

#### Changes Made (across 2 context windows):

**v2.2.0 Feature Implementation (prior context):**

1. **Daily Challenge System** (`DailyChallenge.swift` — major rewrite):
   - `ChallengeConstraint` enum with 6 typed cases: `.landOnPlatform`, `.maxTilt`, `.maxVerticalSpeed`, `.maxHorizontalSpeed`, `.minFuel`, `.maxTime`
   - `ChallengeSpec` struct with levelId, constraints, title, briefing, difficulty
   - 20 challenge templates cycling via `dayOfYear % 20`
   - Difficulties range 1-5, easy planets get harder constraints, hard planets get softer ones

2. **Daily Challenge Briefing Screen** (`DailyChallengeBriefingView.swift` — NEW):
   - Pre-challenge screen with planet info, objectives, difficulty stars, streak display
   - GC top player fetch (today's best score via `fetchDailyTopEntry()`)
   - Launch and Back buttons

3. **Blue Star Currency** (`BlueStarManager.swift` — NEW):
   - Singleton with UserDefaults persistence
   - Daily challenge completion: +1 blue star, 5-day streak bonus: +3
   - Campaign milestones: 10 stars=10 blue, 20 stars=50 blue, 30 stars=150 blue
   - Idempotent reward claiming (double-claim protection)

4. **Interstitial Ads** (`InterstitialAdManager.swift` — NEW):
   - Shows ad every 3rd Retry/Next Level tap
   - Never blocks first attempt, never interrupts gameplay
   - Test ad ID in DEBUG, placeholder production ID in RELEASE

5. **Elapsed Time Tracking** (`GameScene.swift`, `GameState.swift`):
   - `gameStartTime` property, set on first input
   - `elapsedTime` passed to GameState on landing/crash
   - Used by `.maxTime` daily challenge constraint

6. **Challenge Evaluation** (`GameScene.swift`):
   - Evaluates all constraints from today's ChallengeSpec in `successfulLanding()`
   - Sets `gameState.dailyChallengeSuccess` based on all constraints passing

7. **Global Rank on Game-Over** (`GameCenterManager.swift`):
   - `fetchLeaderboardRank()` method fetches per-leaderboard rank ~1s after score submission
   - Displayed on game-over screen

8. **GameOverView Updates** (`GameOverView.swift`):
   - Constraint-by-constraint breakdown (green check / red X per constraint)
   - Blue star reward display (+1, streak bonus, milestone)
   - Interstitial ad trigger on Retry/Next Level

9. **GameCenterManager Updates** (`GameCenterManager.swift`):
   - `fetchDailyTopEntry()` for briefing screen today's best
   - `submitDailyChallengeScore()` for daily_challenge leaderboard

10. **ContentView Updates** (`ContentView.swift`):
    - Daily Challenge button with briefing screen flow
    - Blue star count display
    - Streak display
    - Settings gear icon (moved controls out of menu body)

11. **Project File** (`project.pbxproj`):
    - Registered BlueStarManager.swift + DailyChallengeBriefingView.swift

**Menu Modernization (this context):**

12. **Modernized Title Typography** (`ContentView.swift`):
    - Changed from `.rounded` to `.monospaced` with `.tracking(6/10)`
    - Applied `LinearGradient` — white-to-ice-blue for "STARSHIP", orange gradient for "LANDER"
    - Size reduced 42→38 to compensate for wider tracking

13. **Footer Toolbar** (`ContentView.swift`):
    - Replaced lone gear overlay + version overlay with integrated footer row
    - Settings | How to Play | Version — all contextually grouped
    - Removed old `.overlay(alignment: .topLeading)` gear and `.overlay(alignment: .topTrailing)` version

14. **How To Play Expanded** (`HowToPlayView.swift`):
    - Added Daily Challenge section (6 constraint types explained with teal icons)
    - Added Blue Stars section (5 earning methods explained)

**Documentation Sweep (this context):**

15. **STATUS.md** — Complete rewrite for v2.2.0 (code complete, pending testing)
16. **CHANGELOG.md** — Comprehensive v2.2.0 entries (Daily Challenge, Blue Stars, Interstitial, Global Rank, Menu, How To Play, Privacy)
17. **README.md** — New features, file structure (4 new files), version history table
18. **DECISIONS.md** — 4 new entries (Daily Challenge constraints, Blue Stars earn-only, Interstitial every-3, Briefing screen)
19. **PROJECT_LOG.md** — Archived sessions 36-48, updated header, added Session 58 entry
20. **PROJECT_LOG_ARCHIVE.md** — Appended sessions 36-48, updated header to 1-48, updated project history summary

#### Files Created:
- `RocketLander/Models/BlueStarManager.swift`
- `RocketLander/Models/DailyChallenge.swift` (major rewrite)
- `RocketLander/Views/DailyChallengeBriefingView.swift`
- `RocketLander/InterstitialAdManager.swift`

#### Files Modified:
- `RocketLander/ContentView.swift` — menu modernization, daily challenge flow, blue stars, settings gear, footer toolbar
- `RocketLander/GameScene.swift` — elapsed time, challenge evaluation, blue star trigger
- `RocketLander/Models/GameState.swift` — dailyChallengeSuccess, elapsedTime
- `RocketLander/Models/GameCenterManager.swift` — fetchDailyTopEntry, submitDailyChallengeScore, fetchLeaderboardRank
- `RocketLander/Views/GameOverView.swift` — constraint breakdown, blue star rewards, interstitial trigger
- `RocketLander/Views/GameContainerView.swift` — pass BlueStarManager
- `RocketLander/Views/HowToPlayView.swift` — Daily Challenge + Blue Stars sections
- `RocketLander/BannerAdView.swift` — interstitial ad unit ID in AdConfig
- `RocketLander.xcodeproj/project.pbxproj` — registered new files

#### Build Status:
- Build succeeds, 91/91 tests pass

#### Definition of Done:
- [x] All v2.2.0 features code complete
- [x] Build succeeds
- [x] 91/91 tests pass
- [x] Menu modernized (typography, footer toolbar)
- [x] How To Play expanded
- [x] All 7 documentation files updated
- [x] PROJECT_LOG archived (sessions 36-48)
- [ ] Device testing
- [ ] daily_challenge leaderboard in ASC
- [ ] Production interstitial ad unit ID
- [ ] Version bump
- [ ] Session summary created

---

### Session 59 (2026-02-21) - v2.2.0 Deploy Preparation + Commit

**Goal:** Finalize v2.2.0 for deployment — revert TEMP test override, configure production interstitial ad ID, full documentation sweep, commit, and prepare for TestFlight upload.

#### Changes Made:

1. **TEMP override reverted** (`DailyChallenge.swift`): Removed forced `templates[8]` return, restored `dayOfYear % templates.count` production logic.

2. **Production interstitial ad unit ID** (`BannerAdView.swift`): Replaced `REPLACE_WITH_PRODUCTION_INTERSTITIAL_ID` with `ca-app-pub-3801339388353505/8269147180` (created in AdMob console as "Game Over Interstitial").

3. **Documentation sweep** (7 files):
   - STATUS.md: 75 templates, production interstitial ID, removed placeholder risk
   - CHANGELOG.md: 75 templates, auto-computed difficulty, challenge failure UX, production ID
   - README.md: Version updated to 2.2.0
   - DECISIONS.md: 3 new decisions (auto-computed difficulty, challenge failure UX, production ad unit)
   - RELEASE_NOTES.md: v2.2.0 entry with App Store copy and review notes
   - PROJECT_LOG.md: Session 59 entry, updated status table and next steps

4. **Cleanup**: Deleted stale `plan.md` from working tree.

#### Files Modified:
- `RocketLander/Models/DailyChallenge.swift` — TEMP override reverted
- `RocketLander/BannerAdView.swift` — production interstitial ID
- `STATUS.md`, `CHANGELOG.md`, `README.md`, `DECISIONS.md`, `RELEASE_NOTES.md`, `PROJECT_LOG.md`

#### Build Status:
- Build succeeds, archive succeeds, export + upload succeeds

#### Commits:
- `e6cbac8` — v2.2.0: Daily Challenge, Blue Stars, Interstitial Ads, Global Rank

#### Definition of Done:
- [x] TEMP override reverted
- [x] Production interstitial ID configured
- [x] 7-file documentation sweep complete
- [x] plan.md deleted
- [x] Build succeeds
- [x] Git commit and push (`e6cbac8`)
- [x] Archive + upload to TestFlight (Build 34)
- [x] Session summary created

---

### Session 60 (2026-02-21) - v2.2.0 Build 35 TestFlight Bug Fixes

**Goal:** Fix three bugs found during TestFlight testing of Build 34: menu layout overlap, interstitial ad frequency/duration, and multi-touch thrust stuck.

#### Changes Made:

1. **Menu layout overlap fix** (`ContentView.swift`): Footer toolbar (gear + help icons) was inside the ScrollView, hidden behind the banner ad and play buttons. Moved footer HStack outside ScrollView, pinned between scroll content and BannerAdContainer. Reduced bottom padding from 60px to 16px.

2. **Interstitial ad frequency** (`InterstitialAdManager.swift`): Reduced frequency from every 3rd to every 7th Retry/Next Level tap. Previous cadence was too aggressive for short game sessions.

3. **Interstitial ad duration** (AdMob console — manual): Disabled video ad format in AdMob console. Video interstitials (15-30s) were too long. Now text/image/rich media only.

4. **Multi-touch thrust stuck** (`ControlViews.swift`): `DragGesture(minimumDistance: 0)` on ThrustButton and ControlButton caused thrust to get stuck when a second finger tapped the same button. Second finger's `onEnded` fired and set `isPressed = false` while first finger was still down. Replaced with `onLongPressGesture(minimumDuration: .infinity, pressing:, perform:)` which correctly tracks a single touch lifecycle.

5. **Build number bump** (`Info.plist`): 34 → 35.

#### Files Modified:
- `RocketLander/ContentView.swift` — footer moved outside ScrollView
- `RocketLander/InterstitialAdManager.swift` — frequency 3 → 7
- `RocketLander/Views/ControlViews.swift` — DragGesture → onLongPressGesture on ThrustButton and ControlButton
- `RocketLander/Info.plist` — Build 34 → 35

#### Build Status:
- Build succeeds

#### Key Decisions:
- Interstitial frequency 7 (not 5 or 10) — balance between revenue and UX
- Disable video ads for now — can re-enable when user base grows
- `onLongPressGesture(minimumDuration: .infinity)` — prevents long-press completion, works as pure press-and-hold

#### Definition of Done:
- [x] Menu layout overlap fixed
- [x] Interstitial frequency changed to 7
- [x] Multi-touch thrust stuck fixed
- [x] Build number bumped to 35
- [x] Build succeeds
- [x] Git commit and push (`ca961cc`)
- [x] Archive + upload to TestFlight (Build 35)
- [x] All documentation updated (7-file sweep)
- [x] Session summary created

---

### Session 61 (2026-02-21) - Menu Layout Redesign + Build 36

**Goal:** Fix gear/help icons hidden behind banner ad (Build 35 fix was insufficient). Redesign menu layout, deploy Build 36 to TestFlight.

#### Changes Made:

1. **Menu layout redesign** (`ContentView.swift`): Previous fix (Session 60, moving footer outside ScrollView) didn't solve the overlap — bottom area too crowded. New approach:
   - Moved settings gear and help icons to top-right bar (sharing row with version label)
   - Deleted the footer HStack entirely (~44px freed)
   - Replaced `VStack(spacing: 0) { ScrollView; Footer; Ad }` with `ScrollView { ... }.safeAreaInset(edge: .bottom) { Ad }`
   - `safeAreaInset` makes SwiftUI reserve 50pt for the ad automatically — no overlap possible

2. **Build number bump** (`Info.plist`): 35 → 36.

#### Files Modified:
- `RocketLander/ContentView.swift` — menu layout restructured
- `RocketLander/Info.plist` — Build 35 → 36

#### Build Status:
- Build succeeds
- Archive + upload to TestFlight succeeded

#### Key Decisions:
- Icons at top-right (not bottom) — standard iOS pattern, avoids ad overlap entirely
- `safeAreaInset` instead of VStack sibling — system-level space reservation
- GKAccessPoint at top-left, icons at top-right — no conflict

#### Commits:
- `ebe53ab` — Redesign menu layout: move settings/help to top-right, safeAreaInset for ad (Build 36)

#### Definition of Done:
- [x] Menu icons moved to top-right
- [x] Footer deleted
- [x] safeAreaInset for banner ad
- [x] Build succeeds
- [x] Build number bumped to 36
- [x] Git commit and push
- [x] Archive + upload to TestFlight (Build 36)
- [x] All documentation updated (7-file sweep)
- [x] Session summary created
- [ ] Device testing of Build 36

---

### Session 63 (2026-04-29) - v2.2.0 Progression and Reward Bug Fixes

**Goal:** Fix code-review findings before v2.2.0 submission: campaign progress persistence, attempt tracking, Daily Challenge score isolation, blue star reward display, worldwide daily date boundaries, and Earth moving-platform scoring.

#### Changes Made:

1. **Campaign progress decoupled from high-score sheet** (`CampaignState.swift`, `GameScene.swift`, `GameOverView.swift`):
   - Added `personalBestScoresByLevel`
   - Added `recordCompletion(...)` for stars, unlocks, personal bests
   - Added `addNamedScore(...)` for optional named leaderboard entries
   - Campaign progress and milestone rewards now record immediately on landing

2. **Campaign attempt tracking fixed** (`GameScene.swift`):
   - Normal auto-start path now calls `GameCenterManager.recordAttempt(...)`
   - Restores first-attempt achievement accounting

3. **Earth moving-platform scoring fixed** (`GameScene.swift`, `GameScene+Scoring.swift`):
   - Partial landing bounds, final center distance, and center precision scoring now use the contacted platform node's live X position

4. **Daily Challenge fixes** (`GameOverView.swift`, `DailyChallenge.swift`, `BlueStarManager.swift`, `GameState.swift`):
   - Failed Daily Challenge landings no longer open the score sheet or save into Classic scores
   - Successful new Daily Challenge bests still prompt for a name and update daily best name
   - Actual daily reward result is stored on `GameState` for accurate game-over display
   - Explicit `dailyChallengeWasNewBest` state prevents immediate score recording from suppressing the new-best name prompt
   - Daily Challenge rotation/local keys and blue star streak dates use UTC day boundaries

5. **Tests updated**:
   - `CampaignStateTests`: anonymous completion unlock/progress, named scores separate from progress
   - `GameStateTests`: reward/milestone transient state resets
   - `ScoringTests`: live moving-platform center scoring

6. **Documentation sweep**:
   - Updated `STATUS.md`, `PROJECT_LOG.md`, `CHANGELOG.md`, `README.md`, `RELEASE_NOTES.md`, `DECISIONS.md`, and this session summary

#### Files Modified:
- `RocketLander/GameScene.swift`
- `RocketLander/GameScene+Scoring.swift`
- `RocketLander/Models/CampaignState.swift`
- `RocketLander/Models/GameState.swift`
- `RocketLander/Models/DailyChallenge.swift`
- `RocketLander/Models/BlueStarManager.swift`
- `RocketLander/Views/GameOverView.swift`
- `RocketLanderTests/CampaignStateTests.swift`
- `RocketLanderTests/GameStateTests.swift`
- `RocketLanderTests/ScoringHelper.swift`
- `RocketLanderTests/ScoringTests.swift`
- `STATUS.md`
- `PROJECT_LOG.md`
- `CHANGELOG.md`
- `README.md`
- `RELEASE_NOTES.md`
- `DECISIONS.md`
- `Docs/chats/2026-04-29_session63_v220_progression_reward_fixes.md`

#### Build Status:
- Installed missing iOS 26.4 simulator runtime on this machine.
- `xcodebuild test -project RocketLander.xcodeproj -scheme RocketLander -destination 'id=55C7603C-9E68-4657-8046-5EAA5733D34A'` passed: 94 tests, 0 failures.
- Simulator smoke test passed on iPhone 17 Pro / iOS 26.4: launched app, dismissed ATT prompt, captured menu, entered Classic mode, and tapped THRUST.
- Screenshots saved under `Screenshots/simulator-2026-04-29/`.

#### Key Decisions:
- Gameplay progress is recorded by gameplay events, not by optional UI sheets.
- Daily Challenge worldwide consistency uses UTC day boundaries.
- Moving-platform scoring uses the live contacted platform node position.

#### Definition of Done:
- [x] Campaign progress no longer depends on high-score save
- [x] Campaign attempt tracking wired into auto-start
- [x] Daily Challenge failed landings isolated from Classic scores
- [x] Daily Challenge reward display uses actual reward result
- [x] Daily Challenge and streak dates use UTC
- [x] Earth moving-platform center logic uses live platform position
- [x] Focused tests updated
- [x] Build/test verification (94 simulator tests passed)
- [x] Simulator launch/menu/classic smoke screenshots captured
- [x] Documentation updated
- [x] Session summary created

---

### Session 64 (2026-04-29) - Build 37 Release Prep, Simulator Smoke, and ASC Upload Blocker

**Goal:** Execute next release steps: simulator/device test the game, prepare `daily_challenge` Game Center setup, archive/export the replacement v2.2.0 build, and upload it if Apple-side gates allow it.

#### Changes Made:

1. **Build number bumped to 37** (`RocketLander/Info.plist`):
   - v2.2.0 replacement build prepared after progression/reward fixes and Starship art refresh

2. **Game Center setup script updated** (`Scripts/setup_game_center.py`):
   - Added `daily_challenge` to the leaderboard creation list
   - `python3 -m py_compile Scripts/setup_game_center.py` passed

3. **Simulator smoke test completed**:
   - Verified main menu, Daily Challenge briefing, Daily Challenge gameplay, campaign/level select, and Moon campaign gameplay on iPhone 17 Pro simulator / iOS 26.4
   - Screenshots saved under `Screenshots/simulator-2026-04-29-release-smoke/`

4. **Release archive/export attempted**:
   - Archive succeeded at `build/RocketLander-Build37.xcarchive`
   - Local App Store IPA export succeeded at `build/export-build37-local/RocketLander.ipa`
   - Upload export failed because App Store Connect reports required contracts are missing

5. **ASC script execution attempted**:
   - `Scripts/setup_game_center.py --create-releases` is blocked locally because `ASC_ISSUER_ID` is missing
   - Local `.p8` API key files exist, but no issuer ID was found in local env or secrets

#### Build Status:
- `xcodebuild test -project RocketLander.xcodeproj -scheme RocketLander -destination 'id=55C7603C-9E68-4657-8046-5EAA5733D34A'` passed: 94 tests, 0 failures.
- `xcodebuild -project RocketLander.xcodeproj -scheme RocketLander -archivePath build/RocketLander-Build37.xcarchive -allowProvisioningUpdates archive` succeeded.
- Local IPA export succeeded to `build/export-build37-local/RocketLander.ipa`.
- App Store Connect upload failed with: "You do not have required contracts to perform an operation."

#### Blockers:
- Apple account holder must clear required App Store Connect contracts/agreements before Build 37 can be uploaded.
- `ASC_ISSUER_ID` must be supplied before the script can create/release the `daily_challenge` leaderboard.
- Physical device was not available locally: `iPhone 16 TBO` showed as offline.

#### Definition of Done:
- [x] Build number bumped to 37
- [x] `daily_challenge` added to ASC setup script
- [x] Script syntax check passed
- [x] Full simulator tests passed
- [x] Simulator smoke screenshots captured
- [x] Archive succeeded
- [x] Local IPA export succeeded
- [blocked] Upload to App Store Connect
- [blocked] `daily_challenge` ASC creation/release
- [x] Documentation updated

---

### Session 65 (2026-05-01) - App Store Connect API Recovery, Daily Challenge Release, and Upload Network Blocker

**Goal:** Use browser-harness and App Store Connect to clear the remaining ASC setup blockers, create/release the `daily_challenge` leaderboard, and retry Build 37 upload through Xcode.

#### Changes Made:

1. **Browser-harness attached to Chrome/App Store Connect**:
   - Installed browser-harness in `/private/tmp/browser-harness`
   - Enabled Chrome remote debugging and attached to the existing App Store Connect browser session
   - Verified Free Apps and Paid Apps agreements are active through January 7, 2027

2. **App Store Connect API access restored**:
   - Found issuer ID in App Store Connect integrations
   - Created a new Team API key
   - Stored the private key outside the repo under `~/.appstoreconnect/private_keys/` with chmod 600

3. **Game Center resources released**:
   - Ran `Scripts/setup_game_center.py --create-releases` with the new API credentials
   - Created `daily_challenge` leaderboard with en-US localization
   - Released 13/13 leaderboards and 10/10 achievements for the app version

4. **Build 37 upload retried through Xcode and altool**:
   - Xcode export/upload now passes the prior contracts gate and starts the App Store upload flow
   - Both Xcode and altool repeatedly fail while uploading Apple analysis ZIPs to `northamerica-1.object-storage.apple.com`
   - A Tailscale-off Xcode retry produced the same failure, so the next useful network test is a different upstream connection
   - Error pattern: `Checksums do not match` plus `NSURLErrorDomain Code=-1005 "The network connection was lost."`

#### Build Status:
- Build 37 archive remains ready at `build/RocketLander-Build37.xcarchive`.
- Local App Store IPA remains ready at `build/export-build37-local/RocketLander.ipa`.
- App Store Connect API query did not show a completed Build 37 upload after the failed attempts.

#### Blockers:
- Build 37 upload is blocked by this machine/network's path to Apple object storage, not by ASC contracts or missing Game Center resources.
- A Tailscale-off retry still failed; retry from a phone hotspot or different Wi-Fi.
- Physical device was not available locally: `iPhone 16 TBO` showed as offline.

#### Definition of Done:
- [x] Browser-harness installed and attached to Chrome
- [x] App Store Connect agreements verified active
- [x] ASC issuer ID recovered
- [x] New Team API key created and stored outside repo
- [x] `daily_challenge` leaderboard created and localized
- [x] Leaderboard/achievement releases created
- [x] Xcode upload retried after contracts cleared
- [x] altool upload retried with API key
- [blocked] Build 37 upload to App Store Connect/TestFlight
- [x] Documentation updated

---

### Session 67 (2026-05-03) - Live Campaign Crash Hotfix

**Goal:** Diagnose and patch the campaign-mode crash reported immediately after v2.2.0 Build 37 was approved and distributed on the App Store.

#### Changes Made:

1. **Campaign attempt tracking persistence fixed** (`RocketLander/Models/GameCenterManager.swift`):
   - Root cause identified in the campaign auto-start path: `recordAttempt(mode:levelId:)` writes achievement tracking to `UserDefaults`.
   - Build 37 saved `attemptsByLevel` as a nested `[Int: Int]` dictionary, which is not property-list-safe because dictionary keys must be strings.
   - `savePersistentState()` now converts attempt keys to strings before saving.

2. **Regression coverage added** (`RocketLanderTests/GameStateTests.swift`):
   - Added test coverage that campaign attempt tracking persists string-keyed data.
   - Added reload coverage for existing string-keyed attempt tracking data.

3. **Full-mode sweep follow-up fixes**:
   - `GameScene.setupScene()` now clears stale `shouldReset` so fresh Classic/Campaign/Daily scenes do not reset on the first input frame.
   - Reset cleanup now removes the `heatParticles` scene action in addition to `heatShimmer`.
   - Mercury heat shimmer and Io volcanic eruption effects now guard on `currentMode.usesLevelDefinition`, so Daily Challenge gets the same planet hazards as Campaign.

4. **Cloud build path added**:
   - Added `.github/workflows/ios-ci.yml` for manual/push/PR GitHub Actions verification on a hosted macOS runner.
   - Added `Scripts/ci_xcodebuild.sh`, a reusable script that selects an available iPhone simulator and runs `xcodebuild test`.
   - Added `Docs/CLOUD_BUILD_RUNBOOK.md` with the no-local-Xcode workflow and release-build options.

#### Sweep Results:
- Checked Classic, Campaign, and Daily Challenge entry/reset paths.
- Checked all direct `UserDefaults` writes for property-list safety.
- Checked forced unwraps, forced casts, direct indexing, random ranges, and mode-specific hazard guards.
- Checked obvious secret file patterns before release prep.

#### Verification:
- `git diff --check` passed.
- Local Swift/Foundation smoke check confirmed the string-keyed payload is accepted by `UserDefaults`.
- `python3 -m py_compile` passed for release helper scripts touched in the current working tree.
- `Info.plist` and entitlements passed `plutil -lint`; asset catalog JSON passed `python3 -m json.tool`.
- `bash -n Scripts/ci_xcodebuild.sh` passed.
- Full `xcodebuild`/simulator verification could not run on this machine because the active developer directory is `/Library/Developer/CommandLineTools` and no usable Xcode/simctl is available.

#### Definition of Done:
- [x] Likely live crash path identified
- [x] Property-list-safe persistence fix applied
- [x] Other mode entry/reset paths swept
- [x] Daily Challenge hazard parity bug fixed
- [x] GitHub Actions cloud CI path added for no-local-Xcode verification
- [x] Focused regression tests added
- [x] Documentation updated
- [blocked] Xcode build/test/simulator campaign verification on this machine

#### Next Actions:
- [ ] Run full `xcodebuild test` on a Mac with Xcode selected
- [ ] Smoke campaign startup on Earth, Venus, and an early unlocked level
- [ ] Prepare/upload replacement build after explicit approval

---

### Session 68 (2026-05-03) - v2.2.1 Build 38 Hotfix Release

**Goal:** Bump the approved Campaign crash hotfix to v2.2.1 Build 38, verify with local SSD Xcode, archive/upload, and update the App Store Connect distribution page.

#### Changes Made:

1. **Version bump approved and applied**:
   - `CFBundleShortVersionString`: 2.2.0 -> 2.2.1
   - `CFBundleVersion`: 37 -> 38

2. **Local Xcode restored on external SSD**:
   - Installed Xcode 26.4.1 at `/Volumes/SamsungSSD/Developer/Xcode/Xcode-26.4.1.app`.
   - Selected the SSD Xcode with `xcode-select`.
   - Installed iOS 26.4.1 simulator runtime.

3. **App Store Connect hotfix copy submitted**:
   - Updated What's New for v2.2.1 to focus on the Campaign startup crash fix.
   - Updated review notes with affected-build repro path and fix summary.
   - Kept v2.2 Daily Challenge/Blue Star/global rank context in the distribution copy.
   - Created the v2.2.1 App Store version, attached Build 38, and submitted it for review.

#### Verification:
- GitHub Actions iOS CI passed on the hotfix branch: 96 tests, 0 failures.
- Local SSD Xcode `Scripts/ci_xcodebuild.sh` passed: 96 tests, 0 failures.
- Release archive succeeded: `build/RocketLander-Build38.xcarchive`.
- Xcode Organizer upload completed; App Store Connect reported Build 38 `VALID`.
- App Store review submission state: `WAITING_FOR_REVIEW` at `2026-05-04T01:20:53Z`.

#### Next Actions:
- [ ] Monitor App Store review.
- [ ] Verify replacement build on device/App Store/TestFlight after approval.
- [ ] Confirm Campaign startup on Earth, Venus, and an early unlocked planet in the replacement build.

---

*Last updated: 2026-05-03 (Session 68)*

---

### Session 69 (2026-11-10) - v2.3.0 "Mission Control" Engagement Update

**Goal:** Thiago gave full authority to improve every aspect of the game (design, graphics, code, fun, retention) and ship to TestFlight, plus improve the analytics dashboard.

#### Changes Made:
1. **Pilot Rank** — `Models/PilotProgress.swift`, `Views/ProgressionViews.swift`; XP per flight, 10 ranks, streaks, Blue Star promotion rewards; menu card + game-over XP panel.
2. **Hangar** — `Models/ShipSkin.swift`, `Views/HangarView.swift`, `StarshipArt.swift`; 7 paint schemes, Blue Star spending (`BlueStarManager.spend/award`).
3. **Landing camera, guidance, dust, gust callout** — `GameScene+Juice.swift`.
4. **Visual overhaul** — skies, ridge, starfield sprites, shooting stars, particle plume/explosion/touchdown (`GameScene+Setup.swift`, `GameScene+Effects.swift`).
5. **Feel fixes** — RCS hold, frame-rate independent controls, solid terrain, legs in collision box (`GameScene.swift`).
6. **Settings fix** — Sound/Haptics toggles honored (`GameScene+Sound.swift`, `HapticManager.swift`, `GameState.swift`).
7. **UX** — pre-flight hint + rookie tips, delayed/scrollable results, remembered pilot name, compact menu, How To Play sections (Flight Aids, Pilot Rank & Hangar).
8. **CI/Release** — `claude/**` CI trigger, `Scripts/ci_screenshots.sh` + DEBUG launch args/autopilot, `.github/workflows/testflight.yml`, `Scripts/release_testflight.sh`.
9. Version 2.3.0 (Build 39). Removed `Views/ShapeViews.swift`.

#### Key Decisions:
- See DECISIONS.md entries dated 2026-11-10 (retention loop, flight feel, release automation).

#### Risks / Follow-ups:
- Not device-tested yet (CI simulator only). TestFlight upload blocked on credentials (no Mac reachable from session; secrets must be added by Thiago).

#### Session 69 addendum (2026-11-10) — Build 39 upload
- Jarvis ran `Scripts/release_testflight.sh` on the home Mac at commit `3f72dee`. First attempt stopped at archive (exit 65: Developer Program License Agreement update required, then missing provisioning profile). After Thiago accepted the agreement, the second attempt succeeded 13:56–14:00 CT: ARCHIVE SUCCEEDED, Upload succeeded, EXPORT SUCCEEDED; archived metadata 2.3.0 (39); Xcode 26.6 (17F113).
- Warnings: missing dSYMs for GoogleMobileAds and UserMessagingPlatform (upload unaffected).
- Not verified: Apple processing, TestFlight visibility, device gameplay.

---

### Session 70 (2026-11-10) - v3.0.0 "Starship Program"

**Goal:** Thiago asked for a creative V3: more realistic graphics, new dynamics and levels.

#### Changes Made:
1. **Chapter 2 levels 11–15** — `Models/LevelDefinition.swift` (new fields + levels), `GameScene+Chapter2.swift` (tower catch, meteor shower, night landing), `Views/LevelSelectView.swift` (chapter sections), `Views/GameContainerView.swift` (mission briefings), `Models/CampaignState.swift` (default names 11–15), star totals → `LevelDefinition.maxStars`.
2. **Atmosphere model + plasma** — `GameScene+Chapter2.swift`, hooks in `GameScene.swift`.
3. **Ghost replay** — `Models/GhostRun.swift`, `GameScene+Chapter2.swift`.
4. **Folding legs** — `StarshipArt.swift` (`setLegs`), `GameScene+Juice.swift`.
5. **Rendering** — `StarshipArt.swift` (hull/soot/flap/sphere/boulder/terrain/pad textures, shock diamonds), `GameScene+Setup.swift` (planet shading + halos, Mars features, terrain texture, boulders, pad floodlights).
6. **Tooling/tests** — `ChapterTwoTests.swift`, level/campaign tests for 15 levels, screenshot script covers chapter 2, `Scripts/setup_game_center.py` lists `campaign_11`–`15`. Version 3.0.0 (40).

#### Key Decisions:
- DECISIONS.md 2026-11-10 entries (Chapter 2 + atmosphere, ghost replay, control catch-up window).

#### Risks / Follow-ups:
- Not device-tested; chapter 2 balance tuned analytically and on CI simulator only.
- New leaderboards must be created in ASC before chapter 2 scores post.

