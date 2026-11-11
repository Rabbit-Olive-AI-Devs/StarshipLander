# STATUS.md — Starship Lander

> **This file is the authoritative, compressed snapshot of the project.**
> Chat logs are historical input. This file defines current truth.
> Last reconciled: 2026-11-10 (Session 69)

---

## Project Snapshot

| Field | Value |
|-------|-------|
| App | Starship Lander |
| Bundle ID | com.tboliveira.StarshipLander |
| Platform | iOS (iPhone), iOS 15.0+ |
| Tech | SwiftUI + SpriteKit + CoreMotion |
| Current Version | **v2.3.0 (Build 39) "Mission Control"** — Pilot Rank XP, Hangar skins, cinematic landing camera, flight guidance, RCS hold, visual overhaul, sound/haptics + frame-rate fixes. |
| Version Status | **v2.3.0 Build 39 uploaded to App Store Connect** on 2026-11-10 14:00 CT from the home Mac (`Scripts/release_testflight.sh`, Xcode 26.6 / 17F113, commit `3f72dee`). Archive, export and upload acceptance verified; Apple processing, TestFlight visibility and device gameplay **not yet verified**. PR #4 open. **App Store listing for 2.3.0 prepared in the repo on 2026-11-11** (new name suffix, subtitle, keywords, description, 6 screenshots; see `Docs/APP_STORE_ASO_V230.md`) but **not yet applied in App Store Connect and not submitted for review**. |
| Last Published | v2.2.1 (Build 38) — live on the App Store (public listing checked 2026-11-11: version 2.2.1, 2 ratings) |
| Developer | Thiago Borges de Oliveira / Rabbit Olive Studios |
| Team ID | 6XK6BNVURL |
| Repo | github.com/rabbitolivestudios/StarshipLander |

---

## What Is Done

**v2.3.0 — Mission Control (code complete, CI-verified):**

- **Pilot Rank**: `PilotProgress.swift` — XP per flight, 10 ranks, landing streaks, 5 Blue Stars per promotion; menu rank card, game-over XP panel.
- **Hangar**: `ShipSkin.swift` + `HangarView.swift` — 7 cosmetic paint schemes (Blue Stars 10–150 or rank unlocks), live SpriteKit previews, equipped skin used in game/menu.
- **Landing camera + guidance**: `GameScene+Juice.swift` — approach zoom (0.84×), shake, descent guide line, ↓speed/ALT readout, ground dust, gust warning.
- **Feel fixes**: RCS attitude hold, frame-rate independent thrust/rotation/fuel, solid terrain on all worlds, collision box includes legs.
- **Visuals**: per-planet skies, horizon glow, distant ridge, sprite starfield + shooting stars, particle plume/explosions/touchdown (`StarshipArt.swift`, `GameScene+Effects.swift`).
- **Settings fix**: Sound and Haptics toggles now honored.
- **CI**: screenshot job with DEBUG launch args/autopilot; TestFlight workflow + local upload script.

These features are fully implemented, build-verified, and included in the current codebase:

**(Everything from v2.1.0 and prior — see previous STATUS.md entries)**

**v2.2.0 — New Features (code complete, local fixes simulator-verified):**

- **Daily Challenge System**: 75 rotating challenge templates with rich constraint types (target platform, max tilt, max V/H speed, min fuel, time limit). Deterministic `dayOfYear % 75` cycling in UTC so the same challenge is active worldwide. Auto-computed difficulty 1-5 stars based on planet gravity/hazards, constraint count/tightness, time pressure. Pre-challenge briefing screen (`DailyChallengeBriefingView`) showing objectives, planet info, difficulty, global today's best (from Game Center), local best, streak info, and blue star reward preview. Challenge evaluation with per-constraint pass/fail breakdown on game-over. Distinct challenge failure UX (orange warning icon, "LANDED — BUT CHALLENGE FAILED" message, sad trombone sound) when landing but missing challenge criteria. Countdown timer with time bonus scoring for timed challenges. Daily Challenge leaderboard on Game Center.
- **Blue Star Currency**: `BlueStarManager.swift` — singleton with UserDefaults persistence. Earn blue stars through: daily challenge completion (+1), 5-day streak bonus (+3), campaign star milestones (10→+10, 20→+50, 30→+150). Idempotent reward claiming. Displayed on menu and game-over screens.
- **Global Rank on Game-Over Screen**: Per-leaderboard rank displayed after each landing (`lastLeaderboardRank` in GameCenterManager). Fetches rank ~1s after score submission. Works for classic, campaign, and daily challenge modes.
- **Interstitial Ads**: `InterstitialAdManager.swift` — shows ad every 7th Retry/Next Level tap. Never blocks gameplay on ad failure. Test ID in DEBUG, production ID (`ca-app-pub-3801339388353505/8269147180`) in RELEASE. Video ads disabled in AdMob console (text/image only). Uses existing `topViewController()` for presentation.
- **Modernized Menu and Starship Art**: Sci-fi title typography (monospaced, wide tracking, gradient). Settings gear and How to Play icons in top-right bar (next to version label). Banner ad pinned via `.safeAreaInset(edge: .bottom)`. Settings moved to gear sheet. Blue star count on menu. Streak display. Default Starship art refreshed with stylized stainless body shading, black heat-shield tiles, flaps, engines, and landing legs while preserving gameplay collision dimensions.
- **How To Play Expanded**: Added Daily Challenge section (6 constraint types explained) and Blue Stars section (5 earning methods documented).
- **Elapsed Time Tracking**: `gameStartTime` in GameScene, `elapsedTime` in GameState. Used for time-limited daily challenges.

---

## What Is NOT Done

These are **not implemented**. Do not assume otherwise:

- ~~**Game Center integration**~~ — **PUBLISHED** in v2.1.0
- ~~**v2.2.0 submission**~~ — **APPROVED AND DISTRIBUTED** on 2026-05-03 with Build 37
- ~~**`daily_challenge` leaderboard in App Store Connect**~~ — **CREATED + RELEASED** on 2026-05-01
- **In-App Purchases (IAP)** — deferred (was planned for v2.2.0 Monetization, replaced by interstitial ads + blue stars)
- **iPad support** — iPhone only
- **Landscape orientation** — portrait only
- **Localization** — English only
- **UI tests (XCUITest)** — no automated UI tests
- ~~**CI/CD pipeline**~~ — **BASIC GITHUB ACTIONS CI ADDED** in Session 67 for cloud macOS build/test verification; release upload automation still not configured

---

## Current Phase / Focus

**Phase: Retention + Monetization (v2.2.1) — emergency campaign crash hotfix**

v2.2.0 adds three pillars: (1) Daily Challenge system with 75 templates, auto-computed difficulty, countdown timer, and blue star rewards for daily retention, (2) Interstitial ads every 7 attempts for monetization, (3) Global rank on game-over for competition visibility. Build 37 was approved/distributed by Apple on 2026-05-03, but live testing found the app closes when starting campaign gameplay on selected planets. v2.2.1 Build 38 is the emergency hotfix release for that live crash.

---

## Immediate Next Tasks (ordered)

0. **v2.3.0**: ~~upload Build 39~~ (done 2026-11-10). Next: confirm processing + TestFlight availability in App Store Connect; device-test (RCS hold, landing camera, Hangar, sound/haptics toggles, campaign startup on Earth/Venus); merge PR #4. **Submit**: on the Mac that holds the App Store Connect API key run `ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v230.py --apply --submit` from branch `claude/v230-store-listing` (dry run first without flags). It applies the new listing, attaches Build 39 and submits; release type is "after approval". Do not re-upload Build 39.

1. Monitor v2.2.1 Build 38 review status until approved/distributed.
2. Verify the replacement App Store/TestFlight build on device as soon as Apple makes it available.
3. Confirm Campaign startup on Earth, Venus, and an early unlocked planet in the replacement build.
4. Resume v2.3 planning only after the live crash is resolved.

---

## Non-Negotiable Principles

- STATUS.md is the authoritative project snapshot. Chat logs are input, not truth.
- Every session must produce a chat summary in `Docs/chats/` — no exceptions.
- Documentation updates are mandatory in the same commit as code changes.
- No version bumps without explicit user approval.
- No new SDKs without documenting privacy impact first.
- Build must succeed before committing. No broken code on main.
- No mixing unrelated development phases in one commit.

---

## How to Resume Work

1. Read `CLAUDE.md` — full project guidelines and session checklist
2. Read `STATUS.md` (this file) — authoritative current state
3. Read `PROJECT_LOG.md` — latest session entry and backlog
4. Read the **project history summary** at the top of `PROJECT_LOG_ARCHIVE.md` — older session context
5. Read latest file in `Docs/chats/` — detailed context from last session
6. Run `git log --oneline -10` — verify recent commits
7. Ask the user what to work on
8. Define "done checklist" before writing code

---

## Known Risks / Watchouts

- **v2.2.0 Build 37 is the current live version** — approved/distributed 2026-05-03, but campaign startup is crashing in the live build
- **v2.2.1 Build 38 is submitted for review** — App Store Connect state `WAITING_FOR_REVIEW`, submitted 2026-05-04T01:20:53Z
- **v2.1.1 submitted for review** — share card redesign + GC fix
- **Local Xcode restored on SSD** — Xcode 26.4.1 is installed at `/Volumes/SamsungSSD/Developer/Xcode/Xcode-26.4.1.app`; local tests passed with 96 tests, 0 failures
- **Apple object-storage instability** — seen during prior build upload attempts and one screenshot upload retry; final build and screenshots succeeded
- **ASC API key refreshed locally** — new Team API key is stored under `~/.appstoreconnect/private_keys/` with chmod 600; do not commit it
- **`daily_challenge` leaderboard exists in ASC** — created and released on 2026-05-01
- **Physical iPhone unavailable for local install** — iPhone 16 TBO showed as offline during Session 64; simulator smoke passed
- **Blue star currency has no spending mechanism yet** — earn-only for now, spending TBD in future version
- **Premium skins are not implemented yet** — realistic/generated Starship art is a future store/unlock candidate, not current gameplay content
- **VPN blocks Game Center** — always disable VPN during GC testing
- **ASC draft deletion removes releases** — must re-run `--create-releases` if draft is deleted
- **TestFlight masks GC issues** — TestFlight can access draft GC resources, App Store builds cannot
- **Missing dSYMs for GoogleMobileAds / UserMessagingPlatform** — Build 39 upload warned that crash symbols for those frameworks were not included. Upload unaffected; crash reports inside those SDKs will be unsymbolicated. Separate fix for a future build.
- **GitHub TestFlight workflow** has no App Store Connect secrets configured (run 42870749853 failed at the credential check). Mac upload via `Scripts/release_testflight.sh` is the working route.
- **v2.3.0 not yet device-tested** — verified on CI simulator only (software rendering, low FPS). Check feel of RCS hold (2.6 damping) and zoom on a real iPhone before submitting.
- **Git HTTP/2 broken pipe** — large pushes require `git config http.version HTTP/1.1`

---

## Ownership

- **Developer**: Thiago Borges de Oliveira
- **Studio**: Rabbit Olive Studios
- **AI Copilot**: Claude Code (Opus 4.6)
- **Repository**: github.com/rabbitolivestudios/StarshipLander
