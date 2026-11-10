# Starship Lander — Decisions

This file records key technical and design decisions, including context, alternatives, and consequences.

---

## [2026-05-03] UserDefaults Dictionaries Use String Keys Only
**Context:** v2.2.0 Build 37 was approved/distributed, then live testing found campaign gameplay could close/crash after selecting a planet and starting a run. The campaign auto-start path records Game Center achievement attempts and persists them to `UserDefaults`.
**Decision:** Any dictionary saved directly to `UserDefaults` must be property-list-safe, including string keys for nested dictionaries. `GameCenterManager.savePersistentState()` converts `attemptsByLevel` from `[Int: Int]` to `[String: Int]` before saving; loading continues to accept string-keyed data.
**Why:** Property-list dictionaries do not support numeric keys. Saving a nested `[Int: Int]` can raise a runtime exception even though the code compiles.
**Consequences:** Game Center attempt tracking remains compatible with existing string-keyed payloads, and campaign startup no longer writes crash-prone `UserDefaults` data.

---

## [2026-05-03] Level-Based Modes Share Level Hazards
**Context:** Daily Challenge uses `LevelDefinition` just like Campaign, but Mercury heat shimmer and Io volcanic eruption effects were guarded with `currentMode == .campaign`. That meant Daily Challenge could show the same planet/mechanic in briefing but omit some effects.
**Decision:** Level hazard setup should use `gameState.currentMode.usesLevelDefinition` unless a mechanic is explicitly campaign-only.
**Why:** Daily Challenge promises the same planets and hazards; branching on campaign only creates inconsistent gameplay and test coverage blind spots.
**Consequences:** Mercury and Io effects now run in both Campaign and Daily Challenge. Future level-based modes inherit level mechanics by default.

---

## [2026-01-07] Game Engine Choice
**Context:** Needed a 2D physics engine for iOS rocket landing game.
**Options considered:** (1) SpriteKit + SwiftUI, (2) Unity, (3) pure SwiftUI with custom physics.
**Decision:** SpriteKit for physics/rendering, SwiftUI for menus/HUD.
**Why:** Native iOS, no third-party dependency, excellent physics integration, small binary size.
**Consequences:** Locked to Apple platforms. SpriteKit<>SwiftUI bridging requires UIViewRepresentable wrapper.

---

## [2026-01-08] Scoring System — Continuous with Dual Multipliers
**Context:** Original tier-based scoring gave identical scores for different skill levels.
**Options considered:** (1) Tier jumps, (2) Linear continuous, (3) Continuous + multipliers.
**Decision:** Continuous scoring with fuel multiplier (1.0–2.5x) and platform multiplier (1x/2x/5x). Max ~25,000.
**Why:** Every improvement in landing quality produces a visible score change. Fuel incentivizes efficiency. Platform choice adds risk/reward.
**Consequences:** Wide score range (100–25,000) makes leaderboard more meaningful. Harder to compare scores across platforms.
**Superseded by:** [2026-01-31] Scoring Rebalance — fuel cap reduced to 2.0x, max now 20,000. See that entry for current values.

---

## [2026-01-10] AdMob + App Tracking Transparency
**Context:** Apple rejected v1.0 for Guideline 5.1.2 — Device ID tracking without ATT prompt.
**Options considered:** (1) Remove tracking entirely, (2) Add ATT prompt.
**Decision:** Added ATT prompt at launch. Ads work with or without tracking consent.
**Why:** Required for App Store compliance. Non-intrusive — one-time prompt.
**Consequences:** Some users deny tracking → lower ad revenue. Privacy-compliant.

---

## [2026-01-12] Dual Control Modes (Buttons + Accelerometer)
**Context:** User reported button rotation too sensitive.
**Options considered:** (1) Reduce sensitivity only, (2) Add accelerometer option, (3) Both.
**Decision:** Both — reduced button power (0.05→0.025→0.04) and added accelerometer toggle.
**Why:** Different players prefer different inputs. Accelerometer feels more immersive.
**Consequences:** Must maintain two code paths. Accelerometer unavailable on iPad without gyroscope. Settings persisted via UserDefaults.

---

## [2026-01-30] Campaign Gravity — Game-Balanced vs Real-World
**Context:** Original campaign used real-world gravity values (Earth 9.8, Jupiter 24.8). These were unplayable because thrust power (12.0) is fixed.
**Options considered:** (1) Scale thrust per level, (2) Reduce gravity to playable range, (3) Both.
**Decision:** Reduced gravity values to game-friendly range. ~~Thrust stays fixed at 12.0 for all levels.~~ (Superseded — per-level thrust added, see [2026-01-30] Per-Level Thrust Scaling.)
**Why:** Simpler than per-level thrust scaling. Players shouldn't need to relearn thrust feel per level. Gravity differences still create distinct difficulty.
**Consequences:** Gravity values are NOT real-world accurate (labeled "m/s²" in UI but values are game-tuned). Earth went from -9.8→-4.5→-3.5. Jupiter from -24.8→-6.0 (still possibly too hard — needs testing).

**Session 17 update:** Fully rebalanced to monotonically increasing gravity by level number:

| Level | Name | Game Gravity | Thrust Ratio |
|-------|------|-------------|-------------|
| 1 | Moon | 1.6 | 7.5x |
| 2 | Mars | 2.0 | 6.0x |
| 3 | Titan | 2.2 | 5.5x |
| 4 | Europa | 2.5 | 4.8x |
| 5 | Earth | 2.8 | 4.3x |
| 6 | Venus | 3.2 | 3.8x |
| 7 | Mercury | 3.5 | 3.4x |
| 8 | Ganymede | 3.8 | 3.2x |
| 9 | Io | 4.2 | 2.9x |
| 10 | Jupiter | 4.8 | 2.5x |

---

## [2026-01-30] Earth Moving Platforms — Zone Clamping
**Context:** All three platforms moved on Earth level but overlapped due to unconstrained horizontal ranges.
**Options considered:** (1) Only move one platform, (2) Reduce ranges, (3) Reduce ranges + add clamping.
**Decision:** Option 3 — reduced ranges AND added runtime clamping to enforce 10pt minimum gap.
**Why:** Clamping is a safety net even if ranges are conservative. Prevents physics glitches from platform overlap.
**Consequences:** Platform A no longer moves horizontally (vertical bob only). B and C have smaller, bounded movement. Feels less chaotic but more fair.

---

## [2026-01-30] Menu ScrollView for Dynamic Island
**Context:** iPhone 16+ Dynamic Island clips the game title "STARSHIP" at top of menu.
**Options considered:** (1) Add top padding, (2) Wrap in ScrollView, (3) Reduce title font size.
**Decision:** Wrapped menu in ScrollView + reduced spacing/element sizes to fit all content.
**Why:** ScrollView automatically respects safe area. Also solves "HOW TO PLAY" cutoff at bottom on smaller screens. Content still fits on one screen on iPhone 16 Pro without scrolling.
**Consequences:** Flexible `Spacer()` replaced with fixed spacing. Content is slightly more compact. Works on all screen sizes.

**Session 38 update (2026-02-02):** BannerAdContainer moved OUTSIDE the ScrollView into a `VStack(spacing: 0)` wrapper. Previous approach (ad inside ScrollView with bottom padding) left the ad clipped by the home indicator on device. The ad is now pinned at the bottom of the screen where SwiftUI's safe area layout naturally handles clearance.

---

## [2026-01-30] Ganymede Craters — Ridge Terrain with Physics
**Context:** Ganymede's "deep craters" special mechanic had no visible effect. Previous implementation added random height bumps that were smoothed away. User couldn't distinguish Ganymede terrain from any other level.
**Options considered:** (1) More aggressive random bumps, (2) Deliberate ridges between platforms, (3) Overlay crater sprites on terrain.
**Decision:** Option 2 — generate tall ridges (+200px) between platform zones with physics bodies.
**Why:** Ridges create clear valleys where platforms sit. This is both visually distinctive and mechanically meaningful — the rocket must descend vertically into a valley rather than approaching from the side. Adding physics bodies makes ridges actually dangerous.
**Consequences:** Ganymede plays fundamentally differently from other levels. Terrain physics body only added for level 8 (edge-chain along terrain surface). Other levels keep visual-only terrain. The ridge height (200px above base ≈380px total) is well above platforms (220px), so the rocket must navigate down into valleys carefully.

---

## [2026-01-30] Per-Level Thrust Scaling
**Context:** Fixed thrust (12.0) across all campaign levels meant higher gravity levels either felt impossible or indistinguishable. User wanted each planet to feel different as a core skill challenge.
**Options considered:** (1) Scale thrust proportionally to gravity (constant ratio), (2) Scale with decreasing ratio (progressive difficulty), (3) Keep fixed thrust and only adjust gravity.
**Decision:** Option 2 — each level gets a custom `thrustPower` that scales with gravity but at a decreasing ratio (6.0x on Moon → 3.8x on Jupiter).
**Why:** Players must adapt to different thrust feels per planet. Early levels feel floaty and forgiving; later levels feel heavy with tighter margins. This creates the skill-based learning curve the game needs.
**Consequences:** Classic mode unchanged (thrust 12.0). Campaign thrust ranges from 8.0 (Moon) to 18.5 (Jupiter). Thrust ratio never drops below 3.8x, ensuring all levels are landable. Players experience distinct "engine feel" per planet.

---

## [2026-01-30] Visual Effects for All Campaign Mechanics
**Context:** Most campaign special mechanics had no visual indicator. Only Mercury (heat shimmer) and Io (volcanic eruptions) had effects. Players couldn't see wind, ice, or atmosphere.
**Options considered:** (1) Add particle effects only, (2) Add particles + gameplay effects, (3) Minimal HUD indicators.
**Decision:** Option 2 — every mechanic gets both a visual indicator and gameplay effect.
**Why:** Visual feedback is essential for players to understand why their rocket behaves differently. Effects must be visible AND felt.
**Consequences:** Added wind streak particles (Mars/Venus/Jupiter at 3 intensities), atmosphere haze clouds (Titan), ice shimmer sparkles (Europa). Each visual matches the mechanic: wind streaks blow horizontally, haze drifts slowly, ice sparkles near platforms.

---

## [2026-01-30] Ganymede Craters — Rock Pillars (3rd Approach)
**Context:** Two prior attempts to create terrain ridges between platforms failed. First attempt: random height bumps smoothed away. Second attempt: per-segment nearest-platform valley logic — platform valleys overlapped (320pt of platform on a 393pt screen, leaving no room for ridges). Third attempt needed.
**Options considered:** (1) Override platform positions for Ganymede, (2) Accept no ridges, (3) Standalone rock pillar obstacles + raised terrain at screen edges.
**Decision:** Option 3 — independent rock pillar nodes with physics bodies, plus raised terrain walls at screen edges.
**Why:** Platforms cover 81% of screen width, making terrain-based ridges between them geometrically impossible. Standalone rock nodes can be placed precisely in the 30pt gap between B and C, plus at screen edges, without conflicting with platform geometry.
**Consequences:** Three jagged rock pillars placed (left edge, between B-C, right edge) at y=150 with heights 180-200px. Each has a polygon physics body with `groundCategory` — hitting them crashes the rocket. Terrain also raised at screen edges (up to 350px) for visual crater bowl effect. Ganymede now has clear visual and mechanical distinction.

---

## [2026-01-30] Prepopulated High Scores — Astronaut Easter Eggs
**Context:** Empty high score boards on first launch feel lifeless. User wanted easter egg default scores to give new players something to beat.
**Options considered:** (1) Random names, (2) Developer names, (3) Astronaut/scientist names relevant to each planet.
**Decision:** Option 3 — each campaign level gets a 1000-point default score under the last name of a space figure connected to that celestial body. Classic mode gets "Elon" (SpaceX reference).
**Why:** Creates a discovery moment when players notice the names. Each name teaches a bit of space history. The 1000-point score is beatable but not trivial.
**Consequences:** Seeded on first launch only (if no scores exist for a level). Names: Armstrong (Moon), Aldrin (Mars), Huygens (Titan), Galileo (Europa), Gagarin (Earth), Shepard (Venus), Glenn (Mercury), Marius (Ganymede), Collins (Io), Shoemaker (Jupiter), Elon (Classic).

---

## [2026-01-31] Phase Split — v2.1 (Community) and v2.2 (Monetization)
**Context:** Original plan bundled Game Center, achievements, share card, and Remove Ads IAP into a single v2.1.0. Per CLAUDE.md phase discipline, unrelated phases should not be mixed in one commit or version.
**Options considered:** (1) Keep everything in v2.1.0 with separate commits, (2) Split into two versions by phase.
**Decision:** Option 2 — v2.1.0 is Community phase (Game Center leaderboards, achievements, share score card). v2.2.0 is Monetization phase (Remove Ads IAP via StoreKit 2).
**Why:** Strict adherence to phase discipline. Each version has a single theme, reducing review risk and keeping App Store submissions focused. If one feature has issues during review, it doesn't block the other.
**Consequences:** Two separate App Store submissions instead of one. v2.2.0 depends on v2.1.0 being shipped first (no hard dependency, but logical ordering). IAP capability added in v2.2.0, not v2.1.0.

---

## [2026-01-31] Game Center Integration Strategy
**Context:** v2.1 adds Game Center leaderboards and achievements. Need to decide authentication approach, leaderboard structure, and achievement philosophy.
**Options considered:** (1) Force Game Center sign-in, (2) Opt-in with manual button, (3) Automatic authentication with graceful fallback.
**Decision:** Option 3 — set `GKLocalPlayer.local.authenticateHandler` at launch. If signed in, enable Game Center features. If not, hide GC UI elements and continue with local-only scores.
**Why:** Non-intrusive. Players who don't use Game Center are unaffected. No forced popups. Score submission is fire-and-forget with GameKit's built-in offline queue.
**Consequences:** Must maintain dual paths (local leaderboard always works; Game Center is additive). LeaderboardView gets a Local/Game Center toggle. Achievements are Game Center-only (no local fallback needed). 11 leaderboards must be configured in App Store Connect before submission.

---

## [2026-01-31] Achievement Design Philosophy
**Context:** Need to define which achievements to include and how they unlock. Risk of too many trivial achievements or too few meaningful ones.
**Options considered:** (1) Many granular achievements (land 10 times, land 50 times, etc.), (2) Milestone-only achievements, (3) Mix of skill-based and progression achievements.
**Decision:** Option 3 — 10 achievements covering first experiences, skill milestones, and mastery goals. No grind-based achievements (no "land 100 times"). All are one-shot (100% complete when triggered), no incremental progress.
**Why:** Keeps achievement list clean and meaningful. Each achievement represents a distinct skill or milestone. Players can see them all in the Game Center dashboard without clutter.
**Consequences:** All achievements are binary (0% or 100%). Hook points: `saveScore()` in GameOverView for landing-based achievements, `CampaignState` for progression achievements. `GKAchievement.report()` is idempotent so safe to call repeatedly.

---

## [2026-01-31] Remove Ads IAP — StoreKit 2 Approach
**Context:** Adding a one-time "Support Development" IAP to remove all banner ads. Need to choose between StoreKit 1 (legacy) and StoreKit 2 (modern).
**Options considered:** (1) StoreKit 1 with receipt validation, (2) StoreKit 2 with on-device JWS verification, (3) Third-party SDK (RevenueCat).
**Decision:** Option 2 — StoreKit 2 with async/await. On-device JWS verification (no server needed). UserDefaults cache for synchronous ad-hiding checks, `Transaction.currentEntitlements` as source of truth on launch.
**Why:** StoreKit 2 is simpler, modern Swift, no receipt parsing. No server infrastructure needed for a single non-consumable. UserDefaults cache ensures `BannerAdContainer` can synchronously decide whether to show ads.
**Consequences:** Requires iOS 15+ (already our minimum). Must add "In-App Purchase" capability in Xcode. Need StoreKit Configuration file for local testing. Must provide "Restore Purchases" button per App Review guidelines. Product ID: `com.tboliveira.StarshipLander.removeAds`.

---

## [2026-01-31] Privacy Impact — Game Center + StoreKit
**Context:** Adding Game Center and StoreKit to v2.1. Must assess privacy declarations per CLAUDE.md guardrails.
**Decision:** Game Center requires adding "Gameplay Content" under "Usage Data" in App Privacy declarations (purpose: App Functionality). StoreKit requires no additional declarations. Neither involves tracking. No ATT changes needed.
**Why:** Game Center sends gameplay data (scores, achievements) to Apple's servers — this is first-party data handled by Apple, not tracking. StoreKit transaction data stays within Apple's infrastructure.
**Consequences:** Update App Store Connect privacy declarations to add "Gameplay Content" when submitting v2.1. No code changes for ATT. Existing AdMob ATT prompt unchanged.

---

## [2026-01-31] CLAUDE.md for Session Continuity and Project Guidelines
**Context:** Claude Code sessions can expire or lose context at any time. Without persistent instructions, each new session starts from scratch with no understanding of project conventions, documentation requirements, or development workflow. Previous sessions sometimes missed documentation updates or introduced inconsistent practices.
**Options considered:** (1) Verbal reminders each session, (2) A README section with guidelines, (3) A dedicated `CLAUDE.md` file (automatically read by Claude Code at session start), (4) `.codex/AGENTS.md` (Codex CLI format, per jessfraz reference).
**Decision:** Option 3 — `CLAUDE.md` in project root. Also added `.github/pull_request_template.md` for PR checks.
**Why:** `CLAUDE.md` is natively supported by Claude Code — it's read automatically at the start of every session without any manual steps. It's the most reliable way to enforce guidelines across sessions. The PR template adds a structured safety net for code changes even as a solo developer.
**Consequences:** Every session now has a mandatory 10-step startup checklist, phase discipline, definition of done, documentation requirements, code standards, testing expectations, privacy guardrails, and a hard "do not" list. Documentation updates are non-negotiable. Change summaries are mandatory output. PRs auto-fill with regression safety, scope, and compliance checks.

---

## [2026-01-31] Scoring Rebalance — Center Precision Over Fuel Hoarding
**Context:** Device testing feedback: scoring didn't reward precision enough. Fuel multiplier (up to 2.5x) dominated scores, making fuel hoarding more important than skillful landing. Center-of-platform bonus was only 350 of 2000 base points.
**Options considered:** (1) Increase center bonus only, (2) Redistribute across all components, (3) Remove fuel multiplier entirely.
**Decision:** Option 2 — redistribute: soft landing 700→500, center 350→600, approach 200→150 (subtotal stays 2000). Fuel multiplier cap reduced from 2.5x to 2.0x. Max score: 20,000 (was 25,000).
**Why:** Center precision is the core skill expression. Fuel efficiency should matter but not dominate. Approach control provides less differentiation than center accuracy, so reduced slightly.
**Consequences:** Existing high scores may be higher than achievable under new formula. Score ceiling drops 20%. Leaderboard competition shifts toward precision landing.

---

## [2026-01-31] Proportional Thrust Vectoring (Replacing Binary RCS)
**Context:** Device testing: lateral mistakes were unrecoverable. Binary RCS assist (2.0 units when tilted >5°) was either on or off — too coarse for fine corrections, and worked even without thrusting (free lateral movement).
**Options considered:** (1) Increase binary assist magnitude, (2) Add separate lateral thrusters with fuel cost, (3) Proportional vectoring tied to main thrust.
**Decision:** Option 3 — lateral force = sin(rotation) × thrustPower × 0.15. Only active while thrusting. Replaces binary assist entirely.
**Why:** Physics-based (thrust vectoring is how real rockets work). Naturally proportional — small tilts give small corrections, large tilts give larger ones. Tying to thrust means players must spend fuel to correct, preventing free lateral drifting.
**Consequences:** No lateral assist when not thrusting (intentional — makes coasting more committed). At 30° tilt, ~7.5% of thrust goes lateral. Classic mode also affected (uses same update loop).

---

## [2026-01-31] Planet Mechanic Differentiation
**Context:** Campaign feedback: planets felt homogeneous, differing mainly by gravity/thrust scalars. Venus and Jupiter both applied sine-wave horizontal wind (different magnitudes). Mercury had visual-only shimmer. Io eruptions were cosmetic.
**Options considered:** (1) Keep as-is and differentiate via gravity alone, (2) Make each planet's mechanic feel fundamentally different.
**Decision:** Option 2 — Venus: vertical updrafts (not horizontal wind). Jupiter: sudden gusts with calm windows (not smooth sine). Mercury: thrust perturbation (not just visual). Io: deadly volcanic debris (not cosmetic particles).
**Why:** Each planet should teach one clear mechanic that changes how you fly. Same-axis wind at different magnitudes is not differentiation.
**Consequences:** Venus requires managing vertical forces (new axis of challenge). Jupiter requires timing descents during calm windows. Mercury penalizes imprecise thrust control. Io requires timing around eruption cycles. All descriptions updated to communicate the new mechanics.

---

## [2026-02-01] Replace v2.0.0 Submission with v2.0.2
**Context:** v2.0.0 (Build 12) submitted for App Store review on 2026-01-30, still "Waiting for Review" after 2 days with no response. Meanwhile, v2.0.2 (Build 16) was developed with significant gameplay improvements: scoring rebalance, proportional thrust vectoring, differentiated planet mechanics, leaderboard star metadata, and bug fixes (classic mode star rating save/display).
**Options considered:** (1) Keep waiting for v2.0.0 review, (2) Replace submission with v2.0.2, (3) Check status first then decide.
**Decision:** Option 2 — cancel v2.0.0 submission, submit v2.0.2 (Build 16) with updated App Store copy. Resets the review clock but ensures the first version users experience has the polished gameplay.
**Why:** v2.0.0 had outdated gameplay (binary RCS, 25k max score, cosmetic-only planet mechanics, no star metadata in leaderboards). Shipping it would mean users get an inferior version, requiring an immediate follow-up update. Better to wait slightly longer and ship the right version first.
**Consequences:** Review clock reset. App Store description, What's New, review notes, promotional text, and keywords all updated to match v2.0.2 behavior. Version number on App Store listing is 2.0.2 (skipping 2.0.0 and 2.0.1 publicly).

---

## [2026-02-01] Scoring Formula Testing — Test-Only Helper (No App Code Changes)
**Context:** Adding unit tests for the scoring formula. The `calculateScore()` method on GameScene reads instance properties (`gameState.fuel`, `rocket.position.x`, `size.width`), requiring a full SpriteKit scene to test. v2.0.2 (Build 16) was submitted for App Store review — app source code must not be modified while awaiting review.
**Options considered:** (1) Instantiate a real GameScene in tests, (2) Extract scoring math to a static method on GameScene (modifies app code), (3) Replicate the scoring formula in a test-only helper in the test target.
**Decision:** Option 3 — `ScoringHelper.calculateScore()` in `RocketLanderTests/ScoringHelper.swift`. A pure function that replicates the exact formula from `GameScene+Scoring.swift` with hardcoded constants matching `GameScene.maxSafeVerticalSpeed` etc. App code is completely untouched.
**Why:** The submitted Build 16 binary must remain unchanged. Option 2 was initially implemented but reverted because it modified `GameScene+Scoring.swift`. Option 3 keeps all test infrastructure in the test target only.
**Consequences:** Formula is duplicated between app and test target. If the scoring formula changes in a future version, `ScoringHelper` must be updated to match. This is acceptable because: (a) scoring formula changes are infrequent and always documented in DECISIONS.md, (b) test failures from formula drift would be caught immediately, (c) no risk of shipping modified app code during review.

---

## [2026-02-01] Perfect Landing Scores — Screen Wrapping is Optimal for Platform C
**Context:** Computing maximum achievable scores for all 33 level/platform combinations required modeling the optimal horizontal trajectory. Platform C (x=322.3) is 263.3 pts to the right of the rocket start position (x=58.95). The game has screen wrapping (x < -20 → x = screenW+20).
**Options considered:** (1) Go right to Platform C (263.3 pts), (2) Go left via screen wrap to Platform C (169.7 pts).
**Decision:** Left screen wrap is optimal for all 11 Platform C landings. The 36% shorter horizontal distance saves significant fuel, boosting the fuel multiplier.
**Why:** Going left: 58.95 pts to left edge (-20) + 90.7 pts from right edge (413) to platform center (322.3) = 169.7 pts total. Saves ~94 pts of horizontal travel. On Classic mode this increases the Platform C score from 11,261 (going right) to 12,132 (going left) — an 8% improvement.
**Consequences:** Players who discover the wrap shortcut have a significant scoring advantage on Platform C. This is an intentional emergent strategy from the screen wrapping design decision. Achievement thresholds for Platform C should assume the wrap strategy is known.

---

## [2026-02-01] Perfect Landing Scores — Center Landing Always Maximizes Score
**Context:** The scoring formula has a center precision component (0-600 pts in subtotal) and a fuel multiplier (1.0-2.0x on entire subtotal). Landing off-center could save fuel (less horizontal travel) at the cost of center points. Needed to determine whether off-center landing ever produces a higher total score.
**Options considered:** (1) Always aim for center, (2) Search landing positions across platform width and let the optimizer decide.
**Decision:** Center landing always wins. The optimizer searched positions from -0.8 to +0.8 across each platform; 0/33 optimal landings were off-center.
**Why:** The center bonus (600 pts) is amplified by the platform multiplier (especially 5x for Platform C: 600 × 5 = 3,000 pts). Fuel savings from off-center landing (typically 5-10% → 500-1,000 pts via multiplier) cannot compensate. Even on the most fuel-starved landings (Moon C at 17% fuel), center remains optimal.
**Consequences:** Achievement guidance and scoring tips can confidently recommend center landing as always optimal. No trade-off exists between precision and fuel efficiency for score maximization.

---

## [2026-02-01] Deterministic Campaign Reentry State + Feedback Upgrade
**Context:** Campaign mode allowed a trivial "hold thrust" strategy to land on Platform A every time. Crash messages were random and unhelpful — same crash could produce different messages. No flight data was preserved at game-end for player review.
**Options considered:** (1) Random reentry state per attempt, (2) Fixed deterministic reentry state, (3) Per-level unique reentry states.
**Decision:** Option 2 — fixed 6.9° left tilt + 15 pts/s rightward drift applied when rocket becomes dynamic in Campaign mode only. Combined with three feedback improvements: HUD tilt angle display, frozen final stats panel on game-over, and deterministic cause-based crash messages.
**Why:** Deterministic start means same level = same challenge every time (fairness, replayability). The tilt is above the safe landing threshold (2.9°) so players must correct before touchdown, but small enough that one rotation input fixes it. Random would violate the "physics credibility" design goal. Classic mode stays unchanged (upright start) to preserve the existing experience.
**Consequences:** Campaign Platform A is no longer trivially achievable with thrust-only. Players must demonstrate basic rotation control. Crash messages now show exact failure values (e.g., "Tilt too high (18.4°). Land under 3°.") making the feedback loop actionable. Final stats panel gives players data to improve on. All feedback features work in both Classic and Campaign modes. Reentry constants are compile-time values — easy to tune if needed.

---

## [2026-02-01] Single Authoritative Telemetry Snapshot (Pre-Contact Tracking)
**Context:** Device testing of v2.0.3 (Build 17) revealed that final stats showed V.Speed=0 on crashes and HUD values mismatched Flight Data values. Root cause: SpriteKit's `didBegin(contact:)` fires after collision resolution, which zeroes velocities. Additionally, the HUD read live `gameState` values while Flight Data read frozen `final*` values — two different sources on the same screen.
**Options considered:** (1) Read velocities in the collision callback (unreliable — already zeroed), (2) Track velocities synchronously in the update loop and snapshot those on game-end, (3) Cache velocities at fixed intervals.
**Decision:** Option 2 — three tracking variables (`lastTrackedVerticalSpeed`, `lastTrackedHorizontalSpeed`, `lastTrackedTilt`) updated synchronously in the `update()` loop before the async `DispatchQueue.main.async` block. `snapshotFinalStats()` reads from these tracked values, not from the physics body. HUD computed properties (`displayVertical`, `displayHorizontal`, `displayTiltAngle`) switch between live and `final*` values based on `gameOver` state.
**Why:** The update loop runs every frame before collision resolution, guaranteeing pre-contact values. A single snapshot used by HUD, Flight Data, and crash diagnostics ensures all displays agree. Signed `finalTiltAngle` preserves L/R direction for HUD while `abs()` is applied where needed (diagnostics, Flight Data).
**Consequences:** All end-of-run displays (HUD, Flight Data panel, crash diagnostic messages) and the landing pass/fail threshold check read from the same pre-contact tracked values. No more mismatches between what's displayed and what's used for the decision. Pre-contact tracking adds three CGFloat assignments per frame — negligible overhead.

**Build 19 addendum:** Device testing of Build 18 revealed that `checkLanding()` still read velocity from the physics body (post-collision), allowing landings at V.Speed=71 to pass the V<50 threshold while the HUD correctly showed 71. Fixed by making `checkLanding()` use `lastTrackedVerticalSpeed`/`lastTrackedHorizontalSpeed`/`lastTrackedTilt` for all threshold checks. The scoring function also receives these same values. Works identically in Classic and Campaign modes.

**⚠️ Build 19 CRITICAL BUG (Session 34):** Device testing revealed Build 19 makes it impossible to land. The pre-contact tracked values are captured BEFORE thrust is applied in the same frame, making them systematically higher than the player's actual post-thrust velocity. Furthermore, deeper analysis revealed that the V<40 and H<25 speed thresholds have been **dead code since the initial commit** — SpriteKit's collision resolution zeros velocities before `didBegin(contact:)` fires, meaning the threshold check always saw V≈0 and auto-passed. Build 19 was the first time speed thresholds were ever enforced. Additionally, the HUD has always shown wrong thresholds (V<50/H<30 vs actual V<40/H<25) since its creation in commit `fede844`. Full diagnostic: `Docs/DIAGNOSTIC_velocity_thresholds.md`. **Decision pending — requires game design input: should speed affect landing success?**

---

## [2026-02-01] Removed Explicit HARD Landing Penalty — Natural Velocity Loss Is the Penalty
**Context:** The HARD landing penalty (0.4× subtotal) was too severe. A HARD landing on Platform C scored worse than a SAFE landing on Platform B, violating the design intent that platform choice (risk/reward) should dominate speed band penalties. Analysis showed HARD landings already lose 45% of their subtotal naturally: velocity components (500 soft landing + 400 horizontal precision = 900 pts) score zero because speeds exceed the safe threshold (which IS the scoring denominator). The 0.4× penalty on top created a combined 78% loss and a scoring discontinuity (valley) at the SAFE/HARD boundary.
**Options considered:** (1) Reduce penalty to 0.85×–0.95× (smaller valley), (2) Remove penalty entirely (1.0× — continuous curve), (3) Replace with per-component scaling.
**Decision:** Option 2 — remove the explicit penalty entirely. HARD landings receive no multiplier reduction.
**Why:** (a) Natural 45% subtotal loss IS the penalty — no additional multiplier needed. (b) No scoring valley — V=34.9 and V=35.1 on Platform C produce nearly identical scores (they ARE nearly identical landings). (c) Satisfies the constraint: HARD-C (1100×5.0=5500 at 0% fuel) > perfect SAFE-B (2000×2.0=4000) > perfect SAFE-A (2000×1.0=2000). (d) Within the HARD band, differentiation comes from center precision, rotation, approach control, and fuel — rewarding precision over speed. (e) The UI already signals HARD landings via labels, messages, and colors.
**Consequences:** HARD landings score ~55% of the equivalent SAFE score (consistent ratio across all fuel levels). Score hierarchy: SAFE-C >> HARD-C ≈ borderline-SAFE-C > SAFE-B > SAFE-A. Existing HARD landing scores will increase under this formula. Tests verify the HARD-C > SAFE-B constraint at multiple fuel levels and the absence of scoring discontinuity.

---

## [2026-02-01] RESOLVED — Velocity Threshold Enforcement with Per-Platform Speed Bands
**Context:** Session 34 discovered that landing speed thresholds (V<40, H<25) had been dead code since the initial commit. SpriteKit zeros velocities during collision resolution before the `didBegin(contact:)` callback fires. Every build through Build 18 accepted landings at any speed as long as rotation was under 0.05 rad. Build 19 was the first to enforce speed thresholds (using pre-contact tracking), but the tracked values were captured pre-thrust, making them too strict. The HUD also displayed wrong threshold values (V<50, H<30) since its creation.
**Options considered:** (A) Revert to Build 18 behavior — speed thresholds remain dead code. (B) Move tracking to post-thrust position and keep V<40/H<25. (C) Move tracking to post-thrust and use new per-platform thresholds — enforcement but generous. (D) Split sources — inconsistency between display and enforcement.
**Decision:** Option C — per-platform speed bands with post-thrust tracking. Implemented in Build 21 (commit `1698220`). `checkLanding()` rewritten to use `LandingThresholds.evaluate()` with per-platform SAFE/HARD/FAIL bands. Velocity tracking moved to post-thrust position. Old hardcoded constants removed. HUD updated to use `LandingThresholds.platformC` values.
**Why:** Speed should affect landing success — it's a core pillar of a lander game. Per-platform thresholds (generous on A, strict on C) create progressive difficulty. Post-thrust tracking gives accurate values reflecting the player's actual deceleration effort.
**Consequences:** Speed now matters for landing success for the first time. Platform A allows V≤120/H≤100 before FAIL, Platform C allows only V≤55/H≤50. HUD shows Platform C safe values (V<35, H<30). Existing high scores from prior builds were achieved under "speed doesn't matter" — they may not be reproducible under the new system.

---

## [2026-02-02] Build Hygiene Improvements
**Context:** Reviewed codebase for build hygiene and .gitignore completeness.
**Decision:** Hardened .gitignore, wrapped print statements in DEBUG guards, capped player name input, optimized ATT request, deleted legacy Podfile.
**Why:** Production builds should not emit debug output. .gitignore should cover all common build artifact and credential file types. Player name input should have reasonable length limits.
**Consequences:** No functional behavior changes in release builds. Print statements only appear in DEBUG. ATT prompt still shows once on first launch (unchanged UX). Player names capped at 20 chars (no existing names affected — new input only).

---

## [2026-02-03] Flight Data Panel Redesign — HUD-Style with Badge System
**Context:** The Flight Data panel on the game-over screen was plain text with binary green/red coloring. It didn't match the HUD visual language and provided no nuance between safe, hard, and fail metrics.
**Options considered:** (1) Add colors only (minimal change), (2) Full HUD-style redesign with icons, badges, and 3-color system, (3) Collapsible panel with expandable details.
**Decision:** Option 2 — full redesign with SF Symbol icons, OK/HARD/FAIL badge pills, 3-color values (green/yellow/red), dividers, and centered header.
**Why:** Matches the in-game HUD design language. Badge pills provide instant visual feedback on each metric. 3-color system adds the "hard" intermediate state that was missing from the binary display.
**Consequences:** Slightly taller panel (~130-140pt vs ~100-110pt). Band logic for fuel and center is display-only (not used for landing success/failure). Tilt has no "hard" band (binary safe/fail matching game logic). Uses `sparkle` SF Symbol which may require iOS 17+ (needs verification).

---

## [2026-02-03] Randomized Crash Headlines — SpaceX Easter Egg
**Context:** Static "CRASH!" text was repetitive and missed an opportunity for personality. SpaceX commonly refers to explosions as "Rapid Unscheduled Disassembly" (RUD).
**Options considered:** (1) Keep "CRASH!" and add RUD badge only, (2) Replace "CRASH!" with rotating pool of crash messages, (3) Context-sensitive crash messages based on failure type.
**Decision:** Option 2 — pool of 20 randomized messages spanning SpaceX culture, space mission references, Kerbal gaming vibes, and dry humor. "RAPID UNSCHEDULED DISASSEMBLY" also appears as a permanent red badge in the Flight Data panel on all crashes.
**Why:** Adds replayability and discovery. Each crash feels slightly different. The messages are educational (real space mission references) and entertaining. Consistent badge in Flight Data panel maintains the diagnostic/technical feel.
**Consequences:** 20 static strings in the view — negligible memory impact. Messages stored in `@State` to prevent re-randomization on SwiftUI redraws. Re-randomized in `onAppear` for each new game over. Font size adapts for longer messages (16pt vs 22pt).

---

## [2026-02-05] Europa Mechanic — Replace Ice Slide with Cryogeysers
**Context:** Europa (level 4) had an ice slide mechanic where landing with H.Speed > 20 caused instant crash ("Slid off the ice!"). Build 27 device testing feedback: too punishing, makes Europa very difficult with no skill-based counterplay — you either meet the threshold or you don't.
**Options considered:** (1) Raise the H.Speed threshold to be more forgiving, (2) Make ice slide reduce score instead of crash, (3) Replace with cryogeysers — intermittent ice/water plumes that push the rocket upward.
**Decision:** Option 3 — cryogeysers. 3 fixed geyser positions (8%, 34%, 66% screen width) cycle between active (2-3s) and calm (3-5s). Active geysers apply upward force (base 18.0, tapering with height) plus lateral jitter when rocket is within ±30pt horizontally and 180-480pt vertically. Blue/white/cyan particle columns during eruptions. Vent markers on surface. Ice shimmer and low friction preserved.
**Why:** Inspired by real cryogeysers detected by Hubble on Europa. Creates a timing/positioning challenge that's disruptive but survivable — the player can see where geysers are (vent markers), observe eruption patterns, and time their descent through gaps. Follows the Io volcanic eruption pattern (closest analog) but with force-based disruption instead of deadly contact. Binary speed thresholds aren't fun; environmental hazards with counterplay are.
**Consequences:** Europa difficulty shifts from "control horizontal speed precisely" to "time your descent between eruptions and avoid plume zones." The `.iceSurface` enum case renamed to `.cryogeysers` (breaking change for any saved `SpecialMechanic` data, but campaign state doesn't persist mechanic enums). Tuning values may need adjustment after device testing.

---

## [2026-02-05] Scoring Rebalance — HARD Partial Credit + Component Boost + Fuel Tuning
**Context:** After Session 46 tightened speed thresholds ~15% and Session 47 confirmed mechanics work, device testing showed scores rarely exceeded 5,000. Root cause analysis: (1) quadratic penalty curve zeroed velocity components in HARD band, (2) tighter thresholds compressed the scoring curve, (3) fuel multiplier range 1.0-2.0x was narrow.
**Options considered:** (1) Revert threshold tightening, (2) Change Platform A multiplier, (3) Hybrid: improve scoring formula, boost components, increase fuel multiplier, reduce fuel consumption.
**Decision:** Option 3 — four-part hybrid scoring improvement:
  1. Velocity scoring denominator changed from safe to hard threshold — single smooth quadratic curve eliminates the zero-out cliff at safe threshold. HARD landings get meaningful partial credit.
  2. Soft Landing 500→550, Horizontal 400→450 (subtotal max 2000→2100)
  3. Fuel multiplier range 1.0-2.0x → 1.0-2.2x (factor 1.0→1.2)
  4. Fuel consumption reduced: thrust 0.30→0.27%, rotation 0.08→0.07%, accelerometer 0.04→0.035×tilt
**Why:** User explicitly did not want to change Platform A multiplier. The old system had a cliff: at exactly safe threshold, velocity score = 0; past safe threshold, also 0. Both were punishing. Using hard threshold as denominator creates a smooth curve where safe landings score well AND hard landings still get partial credit, with no discontinuity. Fuel consumption reduction gives ~10% more fuel at landing, amplified by the wider multiplier range.
**Consequences:** New theoretical max 23,100 (was 20,000). Best achievable (Classic C): 14,504 (was 12,077). Typical gameplay scores should be 15-30% higher. All 91 tests pass. HowToPlayView updated with new values. Perfect score script updated.

---

## [2026-02-06] v2.1.0 Game Center Implementation — Singleton + Fire-and-Forget
**Context:** v2.1.0 adds Game Center auth, 12 leaderboards, 10 achievements, Galaxy Rank, and Share Score Card. GameScene (SpriteKit) has no SwiftUI environment access, so it cannot use `@EnvironmentObject` to reach the Game Center manager.
**Options considered:** (1) Pass GameCenterManager through init chain, (2) ObservableObject + singleton hybrid, (3) NotificationCenter-based decoupling.
**Decision:** Option 2 — `GameCenterManager.shared` singleton for fire-and-forget calls from GameScene. Also `@ObservedObject` in SwiftUI views for reactive UI updates (Galaxy Rank, auth state).
**Why:** GameScene needs to call `submitScore()`, `checkAchievements()`, and `recordAttempt()` from within SpriteKit callbacks. Singleton avoids threading `GameCenterManager` through UIViewRepresentable and SpriteKit scene init. SwiftUI views get the same instance via `@ObservedObject`.
**Consequences:** Global mutable state (singleton). Acceptable because GC manager is inherently global (one GKLocalPlayer per device). All published properties are MainActor-safe. Achievement tracking data (safePlatformCLevels, attemptsByLevel) persisted to UserDefaults key "gcAchievementTracking".

---

## [2026-02-06] Galaxy Rank — 12th Aggregate Leaderboard
**Context:** Players want a single competitive ranking across all campaign levels. Individual per-level leaderboards don't capture total campaign mastery.
**Options considered:** (1) Client-side only display (sum of local bests), (2) Dedicated aggregate leaderboard on Game Center, (3) Derived ranking from per-level leaderboards.
**Decision:** Option 2 — dedicated `galaxy_rank` leaderboard. Score = sum of best scores across all 10 campaign levels. Recalculated and submitted after each campaign landing.
**Why:** Game Center has no built-in aggregate leaderboard feature. A dedicated leaderboard enables global ranking that persists even if local data is lost. Recalculating on each landing ensures it stays current.
**Consequences:** 12 total leaderboards (not 11). Galaxy Rank displayed in 3 layers: campaign screen (understanding), menu badge (motivation), leaderboard header (competition). Only meaningful for players who complete multiple campaign levels.

---

## [2026-02-06] Achievement Composite Band — Worst of V/H/Tilt
**Context:** Achievements requiring "SAFE landing" need a clear definition. `speedBand` in GameState only reflects the vertical speed band. A landing could have SAFE vertical but HARD horizontal.
**Options considered:** (1) Use speedBand alone, (2) Use composite band (worst of V/H/tilt), (3) Check each component individually per achievement.
**Decision:** Option 2 — composite band from `LandingThresholds.evaluate()` (worst of vertical, horizontal, and tilt bands). All "SAFE landing" achievements use this.
**Why:** Consistency with the landing outcome displayed to the player. The composite band is what determines SAFE/HARD/FAIL in the Flight Data panel. Using a different definition for achievements would be confusing.
**Consequences:** Harder to earn SAFE achievements (must be safe on ALL three axes). Tilt ≤2.9°, vertical and horizontal within platform-specific safe thresholds. This is intentional — achievements should reflect genuine mastery.

---

## [2026-02-06] Game Center Auth — Must Present authenticateHandler ViewController
**Context:** Device testing of Build 31 revealed that tapping "View Global Rankings" showed "Sign in to Game Center" despite the player being signed in. The `GKGameCenterViewController` dashboard couldn't complete its auth handshake.
**Options considered:** (1) Ignore viewController and rely on system-level GC auth, (2) Present the viewController when non-nil, (3) Use GKAccessPoint for all GC interactions.
**Decision:** Option 2 — when `authenticateHandler` provides a non-nil `viewController`, present it on the topmost VC. Also present `GKGameCenterViewController` from the topmost VC (not root), and anchor it to `galaxy_rank` leaderboard.
**Why:** The `authenticateHandler`'s `viewController` is Apple's mechanism for completing per-app GC authentication. Dropping it silently prevents the GC handshake even when the device has a Game Center account in Settings. In SwiftUI apps, presenting from `rootViewController` can fail because the root may already have a presented controller.
**Consequences:** Added `topViewController()` static helper to `GameCenterManager` (walks presentation chain). Auth flow now shows Apple's sign-in dialog when needed. Dashboard opens anchored to Galaxy Rank. Build 32 uploaded to TestFlight with fix.

---

## [2026-02-06] VPN Blocks Game Center Network Traffic — Root Cause of "Sign in" Issue

**Context:** After fixing the authenticateHandler VC presentation (Build 32), device testing still showed "Sign in to Game Center" when opening GKGameCenterViewController. Diagnostic build (3 dashboard buttons + leaderboard probe + console logging) revealed the issue.

**Root cause:** VPN (visible as `utun4` interface in network error logs) blocked DNS resolution for Game Center data servers. GC auth succeeded (cached/local) and GKAccessPoint bubble appeared, but all data-fetching calls failed with "A server with the specified hostname could not be found."

**Key indicator:** `[GC-DIAG] PROBE ERROR: A server with the specified hostname could not be found.` with `interface: utun4` in NSError details. Meanwhile `[GC-DIAG] DEFAULT LB: classic` succeeded (cached/local data).

**Resolution:** Disable VPN during testing. All 12 leaderboards visible, scores submitted, Galaxy Rank working, 10 achievements visible.

**Lesson:** GKGameCenterViewController shows "Sign in to Game Center" as a misleading fallback when it can't load any GC data — this is NOT necessarily an auth issue. Always check network/VPN first when GC data appears missing despite successful auth.

**Consequences:** Added defensive `GKLocalPlayer.local.isAuthenticated` guard on dashboard presentation. Documented VPN gotcha in MEMORY.md and STATUS.md Known Risks.

---

## [2026-02-06] Game Center ASC Submission — Full Pipeline (Releases Required)

**Context:** v2.1.0 was approved and live on App Store, but Game Center leaderboards and achievements showed as empty on the device. All 12 leaderboards and 10 achievements were created via ASC API and showed "Ready to Submit" status in ASC.

**Root Causes (4):**
1. GC resources created via API but never included in an App Store version submission. TestFlight masks this — it can access draft resources, App Store builds cannot.
2. Achievements missing required images for their localizations.
3. Setup script had no image upload capability.
4. **Setup script was missing the critical "release" step** — `gameCenterLeaderboardReleases` and `gameCenterAchievementReleases` are required to attach resources to the `gameCenterDetail` for an app version. Without releases, resources exist but cannot be submitted.

**Full ASC Game Center Pipeline (6 steps):**
1. Create `gameCenterDetail` (bridge between app and GC)
2. Create leaderboards + achievements with localizations + images
3. Test on TestFlight (draft resources accessible)
4. **Create releases** (`gameCenterLeaderboardReleases` + `gameCenterAchievementReleases`)
5. Enable `gameCenterAppVersions` (GC checkbox on version page)
6. Submit for review bundled with an app version (first time: MUST bundle with app version)

**Decision:** Scripted approach for all steps. `setup_game_center.py` now supports `--upload-images` and `--create-releases` flags. Achievement icons generated programmatically via `generate_achievement_icons.py`.

**Critical Gotchas:**
- Deleting a draft submission in ASC **also deletes all associated releases**. Must re-run `--create-releases` after deleting a draft.
- First-time GC submissions cannot be standalone — they must ride along with an app version submission.
- Version page only shows GC resources (Placares/Conquistas sections) after releases are created.

**Consequences:** Future GC resource additions must follow the full 6-step pipeline. The `--create-releases` flag must always be run before submission. If a draft is deleted, releases must be recreated.

---

## [2026-02-20] Daily Challenge — Rich Constraint System Over Simple Level/Platform Cycling

**Context:** Initial daily challenge design was `dayOfYear % 10` for level + `dayOfYear % 3` for platform — just cycling through level+platform combos. User feedback: "make daily challenges complex and more difficult (but not impossible). Add tilt/h. speed/v. speed/fuel challenges, different planet/platform landings, timed challenges, combination of some of those."
**Options considered:** (1) Keep simple cycling with minor variations, (2) Hand-crafted templates with typed constraints, (3) Procedurally generated challenges from constraint pool.
**Decision:** Option 2 — 20 hand-crafted `ChallengeSpec` templates. `ChallengeConstraint` enum with 6 typed cases: `.landOnPlatform`, `.maxTilt`, `.maxVerticalSpeed`, `.maxHorizontalSpeed`, `.minFuel`, `.maxTime`. Each template combines 1-3 constraints at difficulty 1-5 across all 10 planets. Cycling via `dayOfYear % 20`.
**Why:** Hand-crafted templates ensure balanced difficulty curves — easy planets can get harder constraints while hard planets get simpler ones. Typed constraints enable: per-constraint evaluation, per-constraint display in briefing and results, and future extensibility. Procedural generation would need guardrails against impossible combos.
**Consequences:** 20 challenges means a 20-day repeat cycle. Constraints have `isMet()`, `label`, `icon`, and `actualValue()` for display. `DailyChallenge.evaluate()` checks all constraints; `evaluateDetailed()` returns per-constraint pass/fail with actual values. Elapsed time tracking required in GameScene for `.maxTime` constraint.

---

## [2026-02-20] Blue Star Currency — Earn-Only With Future Spending TBD

**Context:** User's son suggested adding "blue stars" as a reward currency for daily challenge completion. Campaign star milestones (10/20/30) also award blue stars as one-time bonuses.
**Options considered:** (1) Blue stars as cosmetic reward only, (2) Blue stars as spendable currency (unlock skins, modes), (3) Blue stars as earn-only with spending deferred.
**Decision:** Option 3 — earn-only for v2.2.0. `BlueStarManager` tracks blue stars, streak, and claimed milestones. Spending mechanism deferred to future version.
**Why:** Earning mechanics (daily challenge + streaks + milestones) create daily engagement loops now. Spending can be designed later when there's enough content to spend on (skins, custom challenges, etc.). Implementing both at once would delay the retention features.
**Consequences:** Players accumulate blue stars with no spending outlet. The count is displayed on menu and game-over. Future version must add spending to avoid "what are these for?" frustration. Reward values: daily +1, 5-day streak +3 bonus, milestones 10→10, 20→50, 30→150 (total possible one-time: 210 + daily earnings).

---

## [2026-02-20] Interstitial Ads — Attempt-Gated, Never Blocking

**Context:** Banner-only ad revenue is $0.49 total over 90 days. Need higher-value ad format without destroying gameplay experience.
**Options considered:** (1) Rewarded video ads (opt-in for blue stars), (2) Interstitial ads on every game over, (3) Interstitial ads every N attempts on Retry/Next Level only.
**Decision:** Option 3 — interstitials on Retry/Next Level taps only. Menu button never triggers an ad. If ad fails to load, silently skip and proceed. Preload next ad after dismissal. Initial frequency was every 3rd attempt; superseded by [2026-02-21] Interstitial Frequency — Every 7th Attempt.
**Why:** Every-game interstitials would be too aggressive for a game with short sessions. Tying to Retry/Next Level (not Menu) means players who stop playing aren't punished. Silent skip on failure ensures gameplay is never blocked by ad infrastructure.
**Consequences:** Ad revenue should be significantly higher than banners alone while preserving player flow. Production ad unit was later created and configured.

---

## [2026-02-20] Daily Challenge Briefing Screen — Dedicated Pre-Challenge View

**Context:** User noted: "Maybe we need a second screen after Daily Challenge is selected that clearly explains what the Daily Challenge success is, and on that screen we can show Global Today's best."
**Options considered:** (1) Show challenge info in an alert/popup, (2) Show info inline on menu, (3) Dedicated briefing screen between menu and game.
**Decision:** Option 3 — `DailyChallengeBriefingView` as a dedicated full-screen view. Shows challenge title, difficulty stars, planet info, briefing text, objectives list with icons, global today's best from Game Center, local best, streak info, and blue star reward preview. "Launch" button starts the challenge.
**Why:** Daily challenges have complex multi-constraint objectives that need clear presentation. A briefing screen builds anticipation and ensures players understand what they're trying to achieve. The global "today's best" adds competitive motivation before the attempt.
**Consequences:** One extra tap to start daily challenge (Menu → Briefing → Game). `fetchDailyTopEntry()` added to GameCenterManager for global top player. The briefing screen is the daily challenge's "storefront" — it should make players excited to attempt.

---

## [2026-02-21] Auto-Computed Difficulty — Replace Manual Difficulty Assignments

**Context:** Initial 20 templates had manual `difficulty: Int` in each `ChallengeSpec`. When expanding to 75 templates, manual difficulty was error-prone — "Speed Run" (Moon, 25s, Platform A) was rated 2 stars but was trivially easy. Needed consistent, reproducible difficulty ratings.
**Options considered:** (1) Manually review and fix all 75 ratings, (2) Auto-compute difficulty from constraint properties.
**Decision:** Option 2 — computed `difficulty` property on `ChallengeSpec`. Scoring factors: planet gravity/hazards (0.0-4.0), number of constraints (0.8 per extra), constraint tightness per type, platform requirement, time pressure with planet-aware scoring (Moon/Mars time × 0.5, Titan × 0.7).
**Why:** Reproducible, consistent, self-updating. Adding a new template automatically gets the right difficulty. Planet-aware time scoring recognizes that 15 seconds on Moon is easier than 15 seconds on Jupiter.
**Consequences:** Removed `difficulty:` parameter from all 75 templates. Distribution: 7/10/23/22/13 across 1-5 stars. "Speed Run" reduced from 25s to 15s and now rates 2 stars correctly. Thresholds: <1.0=1★, <2.2=2★, <3.8=3★, <5.5=4★, ≥5.5=5★.

---

## [2026-02-21] Challenge Failure UX — Distinct from Crash and Success

**Context:** When landing on the wrong platform in a daily challenge, the game showed green checkmark, success music, "you made it" text alongside "CHALLENGE FAILED" — contradictory signals.
**Options considered:** (1) Treat challenge failure as a crash, (2) Treat as success with small "failed" note, (3) Create distinct "partial success" state.
**Decision:** Option 3 — distinct challenge failure UX: orange warning triangle icon (not green checkmark), "LANDED — BUT CHALLENGE FAILED" message in orange, orange border (not green), and sad trombone sound (`challenge_fail.wav`) instead of success fanfare. Score is NOT saved to daily best and NOT submitted to Game Center leaderboard.
**Why:** The landing itself succeeded (physics-wise) but the challenge objective wasn't met. Neither crash visuals (too negative — they did land) nor success visuals (too positive — they didn't meet the challenge) are appropriate. Orange = warning/partial is the right semantic.
**Consequences:** New sound file (`challenge_fail.wav`) generated via `generate_sounds.py`. `isDCFailed` computed property in GameOverView gates all visual changes. Score gating ensures only genuine challenge completions appear on leaderboards and local bests.

---

## [2026-02-21] Production Interstitial Ad Unit — AdMob Configuration

**Context:** Interstitial ad code was implemented with Google test ID in DEBUG and placeholder in RELEASE.
**Decision:** Created "Game Over Interstitial" ad unit in AdMob console. Production ID: `ca-app-pub-3801339388353505/8269147180`. Video ads disabled (text/image/rich media only). Frequency capping disabled (code handles frequency). eCPM floor: Google optimized, all prices.
**Why:** Maximize fill rate for a new ad unit with no traffic history. Video ads disabled because 15-30s interstitials were driving users away during TestFlight testing. Text/image ads are quick and dismissible.
**Consequences:** No privacy impact — uses existing Google Mobile Ads SDK already declared. Lower eCPM than video but better UX. Video can be re-enabled later.

---

## [2026-02-21] Interstitial Frequency — Every 7th Attempt (was 3rd)

**Context:** TestFlight testing of Build 34 showed interstitial ads every 3rd Retry/Next Level felt too aggressive for a game with short sessions (~10-30 second rounds).
**Options considered:** (1) Every 5th, (2) Every 7th, (3) Every 10th.
**Decision:** Every 7th attempt. Changed `frequency = 3` to `frequency = 7` in `InterstitialAdManager.swift`.
**Why:** 7 attempts gives roughly one ad per 2-4 minutes of gameplay. Balanced between revenue and user retention. Too frequent = users drop the app. Too rare = insufficient revenue.
**Consequences:** ~57% reduction in ad impressions vs frequency=3. Compensated by better retention and longer sessions.

---

## [2026-02-21] Multi-Touch Button Fix — onLongPressGesture Replacing DragGesture

**Context:** `DragGesture(minimumDistance: 0)` on thrust and rotation buttons caused a multi-touch bug: pressing with one finger then tapping with a second finger fired `onEnded` for the second finger, killing the press state while the first finger was still down.
**Options considered:** (1) UIKit touch handler via UIViewRepresentable, (2) Touch counter (increment on onChanged, decrement on onEnded), (3) `onLongPressGesture(minimumDuration: .infinity, pressing:, perform:)`.
**Decision:** Option 3 — `onLongPressGesture` with `minimumDuration: .infinity`. The `pressing` callback is `true` on touch-down and `false` on touch-up for a single gesture instance. `minimumDuration: .infinity` means the long-press never "completes" — the button acts as a pure press-and-hold.
**Why:** Pure SwiftUI solution (no UIKit bridging). Single touch lifecycle tracking. No state counters to manage. Clean and minimal code change.
**Consequences:** Thrust and rotation buttons now correctly handle multi-touch. No visual or behavioral changes for normal single-finger usage.

---

## [2026-04-29] Progress and Reward Recording — Gameplay Events, Not Sheets

**Context:** v2.2.0 code tied some persistent outcomes to UI sheets: campaign stars/unlocks were recorded when the high-score name sheet saved, and Daily Challenge reward display reconstructed reward values after the fact.
**Options considered:** (1) Keep name entry as the persistence trigger, (2) Auto-fill anonymous named scores, (3) Record gameplay progress immediately and keep named leaderboards as optional metadata.
**Decision:** Option 3 — successful campaign landings immediately record stars, unlocks, personal best scores, and milestone rewards. Name entry only updates the named top-3 board. Daily Challenge rewards are stored from the actual `BlueStarManager` result.
**Why:** Progress must survive skipped sheets and non-high-score landings. Named leaderboards are presentation metadata; they should not control unlocks, Game Center aggregate scores, or currency.
**Consequences:** `CampaignState` now has `personalBestScoresByLevel` alongside named `scoresByLevel`. Existing save data remains backward-compatible. Campaign milestone rewards and Daily Challenge rewards are stored on `GameState` for accurate game-over display.

---

## [2026-04-29] Daily Challenge Date Boundary — UTC Worldwide Day

**Context:** The feature promised the same Daily Challenge worldwide, but the original calendar/date formatter used the device's local time zone.
**Options considered:** (1) Keep local-day challenges, (2) Use UTC, (3) Use a server-provided daily seed.
**Decision:** Use UTC day boundaries for Daily Challenge rotation, local daily keys, and blue star streak dates.
**Why:** UTC is deterministic, serverless, and makes the “same worldwide” promise true without backend infrastructure.
**Consequences:** Challenge rollover may occur at a different local time for players outside UTC, but every player shares the same active challenge at the same moment.

---

## [2026-04-29] Starship Art — Stylized Default, Realistic Concept as Future Skin

**Context:** Generated realistic Starship concept art looked strong, but introducing it directly as the default would add bitmap asset complexity and clash with the current vector/SpriteKit arcade style.
**Options considered:** (1) Use the generated bitmap as the default ship, (2) keep the existing simple rocket, (3) create a more Starship-like stylized default and reserve realistic art for a future premium/unlockable skin.
**Decision:** Option 3 — refresh the default SpriteKit and SwiftUI rocket renderers in the current game aesthetic while preserving gameplay collision dimensions.
**Why:** The default should feel more recognizable without creating new asset pipeline, licensing, or scaling risks. The realistic generated concept fits better as a future cosmetic skin/store candidate.
**Consequences:** No physics body changes. Premium skins remain unimplemented; the generated realistic concept is documented as future content.

---

## [2026-02-21] Menu Layout — Icons to Top-Right + SafeAreaInset for Ad

**Context:** Build 35's fix (moving footer outside ScrollView into VStack) didn't solve the banner ad overlap. The bottom area was too crowded: play buttons + footer + ad all competing for space in a `VStack(spacing: 0)`. Campaign button was also partially cut off.
**Options considered:** (1) Add more padding/spacing between footer and ad, (2) Move gear/help icons to the top-right of the screen, (3) Use floating overlay icons, (4) Use `safeAreaInset` for the ad.
**Decision:** Combination of options 2 + 4 — move gear/help icons to the top-right bar (sharing row with version label) and use `.safeAreaInset(edge: .bottom)` for the banner ad.
**Why:** Moving icons to the top eliminates the footer entirely (~44px freed). `safeAreaInset` is the correct SwiftUI pattern for pinned bottom content — it makes SwiftUI automatically reserve space for the ad so no content can be hidden behind it. Top-right placement for settings/info icons is a standard iOS convention. GKAccessPoint is at top-left, so no conflict.
**Consequences:** No footer at bottom. Icons are smaller (18pt vs 20pt) and more subtle. The menu can't have content hidden behind the ad. If content ever exceeds screen height, the ScrollView handles it gracefully with the ad inset.

---

## [2026-02-05] Tilt Bands — SAFE/HARD/FAIL Matching Speed Band Philosophy
**Context:** Tilt had a binary pass/fail gate at 0.05 rad (~2.9°), which was too strict and inconsistent with the 3-band system used for speed (SAFE/HARD/FAIL). Campaign ships spawn at 6.9° tilt, so players must correct before landing — a narrow 2.9° safe zone made this punishing.
**Options considered:** (1) Raise the binary threshold to ~5°, (2) Add SAFE/HARD/FAIL tilt bands matching the speed band philosophy.
**Decision:** Option 2 — three tilt bands: SAFE ≤0.05 rad (~2.9°), HARD ≤0.10 rad (~5.7°), FAIL >0.10 rad. Tilt band participates in overall landing band calculation (worst of V/H/tilt wins). Rotation scoring uses hardTilt (0.10) as denominator for smooth curve.
**Why:** Consistency with speed bands. Players now get partial credit for "good enough" tilt instead of binary crash. Doubles the survivable tilt range. The HARD tilt feedback (yellow HUD, reduced score) still signals "you should do better" without instant death.
**Consequences:** Survivable tilt range doubled (2.9° → 5.7°). Rotation scoring denominator widened (0.05 → 0.10), giving more partial credit. Best achievable score increased slightly (Classic C: 14,331 → 14,504) because rotation scoring is more generous at small angles. 91 tests pass (was 89 — net +2 from splitting 2 binary rotation tests into 4 tilt band tests + 1 classification test, minus 2 old tests). HUD tilt color now shows green/yellow/red for safe/hard/fail. Crash message updated: "Land under 6°" (was 3°). HowToPlayView updated with tilt band explanation.

---

## [2026-11-10] v2.3.0 — Pilot Rank XP + Hangar as the retention loop
**Context:** Blue Stars were earn-only (backlog: "Blue star spending mechanism"), and nothing rewarded a player for an ordinary flight, so there was little reason to return outside the Daily Challenge.
**Options considered:** (1) IAP skins; (2) Missions/contracts system; (3) Per-flight XP with ranks + cosmetic skins bought with Blue Stars or unlocked by rank.
**Decision:** Option 3. XP per flight (crash 5, landing 25 + pad/clean/streak/daily bonuses), 10 ranks to 7,500 XP, 5 Blue Stars per promotion. 7 purely cosmetic skins (10–150 Blue Stars; Night Ops/Red Planet/Lunar Gold/Legend also unlock free at ranks 3/5/7/10).
**Why:** Gives every flight visible progress and gives the existing currency a sink without touching scoring, leaderboards or monetization.
**Consequences:** No physics or score changes from skins. Progress is local (UserDefaults `pilotProgress.v1`, `hangarOwnedSkins`, `hangarSelectedSkin`); no new data leaves the device and no privacy declaration changes.

---

## [2026-11-10] v2.3.0 — Flight feel: RCS hold, frame-rate independence, solid terrain, legs on the collision box
**Context:** Device feedback themes: spin overshoot with buttons, ships passing through hills, and feet floating above/clipping the pad. CI simulator runs also showed ships falling through on heavy-gravity worlds when the frame rate dropped.
**Decision:** (a) Angular damping 2.6 while no rotation input is held (0.7 while rotating; requires fuel). (b) Thrust, rotation and fuel burn scale by `min(dt, 0.05) × 60` so the tuned 60 fps values are exact at 60 fps and correct under frame drops. (c) Terrain edge-chain physics on every world (was Ganymede only). (d) Rocket body 54×96.25 pts centered at y −6.1 so it spans the nose to the bottom of the feet.
**Why:** Fixes root causes rather than tuning numbers; landing thresholds, scoring and per-level thrust/gravity are unchanged.
**Consequences:** Missing a pad now crashes on the visible hillside instead of a hidden floor. Contact with the pad happens when the feet touch (≈11 pts earlier than before), which the existing pre-contact velocity tracking already handles.

---

## [2026-11-10] v2.3.0 — Release automation without handling credentials
**Context:** No Mac was reachable in this session; uploads previously required Xcode Organizer on Thiago's Mac.
**Decision:** Add `.github/workflows/testflight.yml` (archive + upload with App Store Connect API key stored only as GitHub encrypted secrets `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, triggered by `testflight/*` tags) and `Scripts/release_testflight.sh` (uses the Xcode-signed-in account on a Mac). Neither reads or stores keys in the repo or session.
**Consequences:** Credentials must be added by Thiago once (GitHub Settings → Secrets). The API key needs the Admin role for cloud-managed distribution signing.


---

## [2026-11-10] v3.0.0 — Chapter 2 "Starship Program" with an attitude-dependent atmosphere
**Context:** Thiago asked for a creative V3 with new dynamics, levels and more realistic graphics.
**Options considered:** (1) Retune chapter 1 with a global drag model; (2) Add drag and new mechanics only to new levels; (3) New game mode separate from campaign.
**Decision:** Option 2. Five new campaign levels (11–15, chapter 2) reuse the existing campaign flow (unlock chain, stars, Next Level, Game Center `campaign_N`). New `LevelDefinition` fields (`chapter`, `atmosphere`, `initialTilt`, `initialFuel`, `briefing`) default to chapter 1 behavior, so levels 1–10, scoring, thresholds and leaderboards are unchanged. Drag: `c = 0.0187 × density × (0.18 + 0.82·|sin tilt|)`, decel `c·v²`.
**Why:** Delivers the belly-flop/flip-and-burn dynamic and new mechanics without invalidating existing scores or balance.
**Consequences:** `campaign_11`–`campaign_15` leaderboards must be created in App Store Connect (`Scripts/setup_game_center.py` lists them); until then score submission for those levels fails silently. Galaxy Rank and achievements still count levels 1–10. Total campaign stars are 45.

---

## [2026-11-10] v3.0.0 — Ghost replay of personal bests (local only)
**Decision:** Record position/attitude at 20 Hz during each flight; on a landing that beats the stored ghost for that Classic/Campaign level, save it to UserDefaults (`ghost.classic`, `ghost.campaign.N`, ≤1800 samples). Daily Challenge has no ghost (changes daily). Replays scale x by screen width.
**Consequences:** No data leaves the device; no privacy changes.

---

## [2026-11-10] v3.0.0 — Control catch-up window raised to 0.1 s
**Context:** v2.3.0 scaled inputs by `min(dt, 0.05) × 60`. CI simulator runs below 20 fps still under-thrust because physics integrates the full frame.
**Decision:** `GameScene.maxStep = 0.1` (down to 10 fps). Longer hitches (app pauses) are still dropped.
