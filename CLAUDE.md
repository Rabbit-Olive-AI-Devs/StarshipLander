# Claude Code — Starship Lander Project Guidelines

**Purpose**: Persistent instructions for Claude Code sessions on Starship Lander. Read this file end-to-end at the start of every session before doing any work.

**Default behavior**: Prefer small, reviewable changes and strong documentation over large refactors.

**Critical**: Chat logs (`Docs/chats/`) may be consulted as historical input, but `STATUS.md` defines current truth. When chat logs conflict with `STATUS.md` or repo documentation, prefer `STATUS.md` first, then repo docs, then chat logs.

---

## Start of Session Checklist (mandatory)

Every session must begin with these steps:

1. Read this file (`CLAUDE.md`) end-to-end
2. Read `STATUS.md` — this is the **authoritative snapshot** of what is done, not done, and next
3. Read `PROJECT_LOG.md` — check Current Status table, next steps, and latest session entry
4. Read the **project history summary** at the top of `PROJECT_LOG_ARCHIVE.md` — compressed overview of older sessions (do NOT read the full archive unless investigating a specific past decision)
5. Read `CHANGELOG.md` — understand what version is current and what's been done
6. Read `RELEASE_NOTES.md` — understand release status
7. Read `DECISIONS.md` — understand standing decisions and policies
8. Read the latest file in `Docs/chats/` — restore detailed context from last session (historical input, not authoritative)
9. Summarize the current project state in 5-10 bullets before proceeding
10. Ask the user what they want to work on
11. Confirm target phase and scope
12. Define a "done checklist" before writing any code

If any of these documentation files are missing, create them before implementing major new features.

---

## Quick Obligations

| Situation | Required action |
|-----------|----------------|
| Starting a session | Run the full Start of Session Checklist above. |
| Before writing code | Read the files you plan to modify. Never propose changes to code you haven't read. |
| After completing a feature or fix | Update all documentation in the same commit (see Documentation section). |
| Before committing | Run `xcodebuild` to verify the build succeeds. Do not commit broken code. |
| Ending a session | Create a chat session summary in `Docs/chats/` (mandatory, no exceptions), update `PROJECT_LOG.md`, run repo housekeeping (see section below), commit and push. |
| Ideas or features discussed but not implemented | Log them in the session summary under "Research / Ideas Discussed" and add to PROJECT_LOG backlog. |
| Implementing share triggers, ASO copy, or growth hooks | Consult `Docs/GROWTH_PLAN.md` for strategy, positioning, and constraints. |
| Context lost or new session | Run the full Start of Session Checklist. |
| Adding any SDK or data flow | Document privacy impact before implementation (see Privacy section). |

---

## Project Overview

- **App**: Starship Lander (iOS, iPhone)
- **Tech**: SwiftUI + SpriteKit
- **Bundle ID**: com.tboliveira.StarshipLander
- **Team ID**: 6XK6BNVURL
- **Language**: Swift
- **Build**: `xcodebuild -project RocketLander.xcodeproj -scheme RocketLander -destination 'platform=iOS Simulator,name=iPhone 16 Pro'`
- **Simulator**: `xcrun simctl boot "iPhone 16 Pro"` / `xcrun simctl install` / `xcrun simctl launch`

---

## Phase Discipline

This project uses development phases (e.g., core gameplay, campaign, monetization, Game Center, community).

When implementing anything:
1. **Identify** which phase the change belongs to.
2. **Do not mix** unrelated phases in one commit.
3. If a request spans phases, **split it** into separate steps/commits.
4. Name the phase in your commit message or session summary.

---

## Definition of Done

Before coding any task, write a short checklist:
- What must work
- What must be tested (simulator + device if applicable)
- What docs must be updated
- How success is verified
- Edge cases to consider

At the end, explicitly confirm each item. Do not mark a task as done if any item fails.

---

## Session Continuity

Sessions may expire or lose context at any time. These files ensure the project can always continue:

| File | Purpose | Source of truth for |
|------|---------|---------------------|
| `STATUS.md` | **Authoritative project snapshot** | What is done, not done, current phase, next tasks. Overrides chat logs. |
| `PROJECT_LOG.md` | Project state, session history | Current status, what happened, next steps. Last 10 sessions. |
| `PROJECT_LOG_ARCHIVE.md` | Archived session history | Older sessions (1-35+). Has a project history summary at the top. |
| `Docs/chats/YYYY-MM-DD_sessionNN_*.md` | Historical session summaries | Technical details, decisions, file changes (input, not authoritative) |
| `CHANGELOG.md` | Version-level change tracking | What changed in each version (Keep a Changelog) |
| `RELEASE_NOTES.md` | User-facing release descriptions | App Store copy, marketing text |
| `DECISIONS.md` | Architectural/design decisions | Why things are the way they are |
| `README.md` | High-level project truth | Features, structure, how to build |
| `Docs/GROWTH_PLAN.md` | Organic growth strategy | ASO, screenshots, share triggers, social media, AI division of labor |

**Precedence when sources conflict:** STATUS.md > repo documentation > chat logs.

### PROJECT_LOG Archiving

`PROJECT_LOG.md` grows with every session. To keep it readable and within tool size limits:

1. **Structure**: `PROJECT_LOG.md` keeps the full header (overview, status table, AdMob config, backlog) plus the **last 10 session entries**. Older sessions live in `PROJECT_LOG_ARCHIVE.md`.

2. **Archive trigger**: When `PROJECT_LOG.md` exceeds **~800 lines**, archive the oldest sessions to bring it back under the limit while keeping the last 10 sessions.

3. **How to archive**:
   - Move the oldest session entries from `PROJECT_LOG.md` to the end of `PROJECT_LOG_ARCHIVE.md`
   - Update the archive's header to reflect the new session range
   - Update the archive notice in `PROJECT_LOG.md`'s Development History section to reflect the new range
   - Do NOT change the structure of `PROJECT_LOG.md` — keep all header sections, tables, and status blocks intact

4. **When to read the archive**:
   - **At session start**: Read the **project history summary** at the top of the archive (not the full file) for high-level context
   - **When investigating old decisions**: If a task touches something from an archived session, read the relevant session entry from the archive
   - **When DECISIONS.md doesn't have enough context**: The archive has implementation details that DECISIONS.md may not cover
   - **Do NOT read the full archive routinely** — it exists as reference, not as session startup material

5. **Archive file structure**:
   ```
   PROJECT_LOG_ARCHIVE.md
   ├── Header (title, description, session range)
   ├── Project History Summary (compressed narrative of key milestones)
   └── Archived Session Entries (verbatim, oldest first)
   ```

---

## Chat Session Logging (mandatory)

Every session MUST produce a chat session summary file. This is the most critical documentation artifact — it is the primary mechanism for restoring context when sessions expire or are lost. Skipping this is never acceptable.

### Rules

1. **One summary file per session.** Created at end of session, committed and pushed before session ends.
2. **Location:** `Docs/chats/YYYY-MM-DD_sessionNN_short_description.md`
3. **Session numbering:** Increment from the last session number found in `Docs/chats/`. Check before creating.
4. **Scope:** Capture everything that happened in the session — even research, discussions, ideas logged, and decisions made without code changes.
5. **No raw chat logs.** Summarize. The summary must be useful to a future session that has zero prior context.
6. **Include all ideas and suggestions** discussed during the session, even if not implemented. These are valuable for future planning.
7. **Include all commits** made during the session with their hashes and descriptions.

### When to Create

- At the end of every session, regardless of whether code was written
- Before the final commit of the session (include it in that commit)
- If the session is getting long, create an intermediate summary to protect against context loss

### Template

```markdown
# YYYY-MM-DD — Session NN: Short Title

## Goals
- What was planned for this session

## Changes Made

### 1. Feature/Fix Name
**What:** Description of the change
**Why:** Reason for the change
**Files:** List of modified files

(repeat for each change)

## Research / Ideas Discussed
- Any ideas explored, features discussed, or options considered but not yet implemented
- Include enough detail that a future session can pick up the thread

## Technical Notes
- Any technical details worth recording (workarounds, gotchas, environment issues)

## Decisions
1. Decision made and why

## Definition of Done
- [x] Item completed
- [ ] Item remaining

## Commits
- `abc1234` — Commit message summary
- `def5678` — Commit message summary

## Repo Housekeeping
- [ ] Working tree clean (no stale untracked files)
- [ ] .gitignore up to date
- [ ] README.md project structure matches actual files
- [ ] No secrets or credentials in tracked files

## Next Actions
- [ ] What remains to be done
```

---

## Repo Housekeeping (mandatory, every session)

Before the final commit of every session, run through this checklist. This keeps the repository clean and the GitHub page accurate.

### Checklist

1. **Working tree clean** — no untracked files that should be ignored or deleted
   - Run `git status`. If there are untracked files, either `.gitignore` them or delete them.
   - Videos (`*.mp4`, `*.mov`), local IDE settings, and build artifacts should never be committed.
2. **`.gitignore` up to date** — any new file types that shouldn't be tracked are covered
3. **README.md project structure** — matches the actual file tree
   - If files or directories were added/removed/renamed during the session, update the project structure section.
4. **README.md accuracy** — version, features, build commands, and links are correct
5. **Stale files removed** — no orphaned screenshots, old exports, or leftover artifacts
6. **No secrets or credentials** — no `.env`, API keys, provisioning profiles, or certificates in tracked files
7. **GitHub repo metadata** (when `gh` CLI is available or via web UI):
   - Description is set and accurate
   - Topics/tags reflect the project (e.g., `ios`, `swift`, `spritekit`, `game`)
   - Releases are created for published App Store versions

### When to do more than the checklist

- **After file restructuring** — verify README structure, `.gitignore`, and imports
- **After adding dependencies** — verify `.gitignore` covers new build artifacts
- **After version releases** — create a GitHub Release with tag and release notes

---

## Documentation Requirements

Change logging is mandatory. Every meaningful change must update documentation **in the same commit**. This is non-negotiable.

### A) Chat Session Summary (Docs/chats/)
- **Every session, no exceptions.** See "Chat Session Logging" section above.

### B) CHANGELOG.md
- Add or update the relevant version entry
- Use Keep a Changelog style (Added / Changed / Fixed)
- Be factual and specific
- Do not claim features are shipped if they are not

### C) PROJECT_LOG.md
- Append a session entry with: date, goal, what changed (files touched), key decisions, risks/follow-ups
- Update the Current Status table
- Update Next Steps and Backlog if applicable

### D) RELEASE_NOTES.md
- Update only when a version is release-candidate or submitted
- Keep it marketing-friendly but honest
- Include App Store copy block

### E) DECISIONS.md
- Add an entry when any tradeoff, threshold, or policy changes:
  - Scoring formula changes
  - Control feel adjustments
  - Ad placement changes
  - Campaign difficulty rules
  - Game Center or IAP decisions
  - Privacy-related behavior

Format:
```markdown
## [YYYY-MM-DD] Decision Title
**Context:** ...
**Options considered:** ...
**Decision:** ...
**Why:** ...
**Consequences:** ...
```

### F) README.md
- Update when user-facing behavior changes (version, features, controls, campaign content)

### G) STATUS.md
- **Update every session** — this is the authoritative project snapshot
- Keep "What Is Done" and "What Is NOT Done" sections accurate
- Update "Current Phase / Focus" when project status changes
- Update "Immediate Next Tasks" as tasks are completed or reprioritized
- Update "Known Risks / Watchouts" as risks are resolved or new ones emerge
- Reconcile with other docs if discrepancies are found — STATUS.md wins

### Mandatory Documentation Sweep

**Every time you update documentation, you MUST sweep ALL of the following files.** Do not update some and forget others. Go through this list one by one, read each file, and verify it is accurate. This is not optional.

| # | File | Check |
|---|------|-------|
| 1 | `STATUS.md` | Version, build number, phase, next tasks, known risks — all accurate? |
| 2 | `PROJECT_LOG.md` | Current Status table, NEXT STEPS, latest session entry — all accurate? |
| 3 | `CHANGELOG.md` | Version entries reflect what is actually implemented and shipped? |
| 4 | `README.md` | Version, features, thresholds, scoring, version history table — all accurate? |
| 5 | `DECISIONS.md` | Any new or changed decisions documented? No stale "PENDING" entries? |
| 6 | `RELEASE_NOTES.md` | If a build was uploaded or submitted, does this reflect it? |
| 7 | `Docs/chats/` session summary | All commits listed? All changes described? Next actions correct? |

**Do not commit documentation updates until you have verified every file in this list.** If a file doesn't need changes, that's fine — but you must have READ it and confirmed it's correct.

### Cross-cutting rule
If you change any of the following, you MUST update README + CHANGELOG + any affected docs:
- Version number
- Ads/ATT behavior
- Control scheme
- Campaign content
- Monetization
- Privacy-related behavior

No stale docs. Ever.

---

## Code Standards

- **Think before coding.** Follow this order:
  1. Think about the architecture
  2. Research official docs if needed
  3. Review the existing codebase
  4. Compare research with codebase to choose the best fit
  5. Implement, or ask about tradeoffs
- **Fix from first principles.** Don't apply bandaids. Find the root cause.
- **Keep it simple.** Write idiomatic, maintainable Swift. Always ask: is this the simplest solution?
- **No dead code.** Delete unused functions, parameters, and files. Don't leave commented-out code.
- **No breadcrumbs.** If you move or delete code, just remove it. No "// moved to X" comments.
- **Avoid unnecessary changes.** Don't refactor, add comments, or "improve" code that wasn't part of the task.
- **Search before pivoting.** If stuck, research the issue (Apple docs, web search) before changing approach. Do not change direction unless asked.
- **Avoid monolith growth.** If a file exceeds ~600-800 lines and keeps growing, propose splitting into focused files. Be conservative — split minimal sections only, no sweeping reorganizations unless requested.
- **Do not mix refactors with features.** Large refactors and feature work go in separate commits.

### Swift/iOS Specific

- Use SwiftUI for UI, SpriteKit for game scene
- Use `UserDefaults` for persistence (scores, settings, campaign state)
- Use `CGFloat` for SpriteKit values
- Test on iPhone 16 Pro simulator
- App Store screenshots must be 1284x2778px (iPhone 6.7")
- Status bar override for screenshots: `xcrun simctl status_bar "iPhone 16 Pro" override --time "9:41" --batteryLevel 100 --batteryState charged`

---

## Testing Expectations

For each change, specify:
- **Simulator testing**: What to verify, exact taps/paths
- **Device testing**: What requires a physical device (haptics, accelerometer, ads)
- **Edge cases**: What could break

If changes touch Game Center / ads / ATT:
- Include exact manual test steps
- Verify ATT prompt behavior
- Verify ad loading in both debug and release

---

## Build and Test

```bash
# Build for simulator
xcodebuild -project RocketLander.xcodeproj -scheme RocketLander \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -allowProvisioningUpdates build 2>&1 | tail -5

# Archive for App Store
xcodebuild -project RocketLander.xcodeproj -scheme RocketLander \
  -archivePath build/RocketLander.xcarchive \
  -allowProvisioningUpdates archive

# Export for upload
xcodebuild -exportArchive \
  -archivePath build/RocketLander.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist build/ExportOptions.plist

# Install on simulator
xcrun simctl install "iPhone 16 Pro" build/Build/Products/Debug-iphonesimulator/RocketLander.app
xcrun simctl launch "iPhone 16 Pro" com.tboliveira.StarshipLander
```

Always build before committing. Do not commit code that doesn't compile.

---

## Versioning & Release Process

Version bumps are controlled. Only bump when:
- A set of changes is feature-complete and tested
- The user explicitly requests it

When bumping:
1. Update version in Xcode project settings (`Info.plist`)
2. Update `CHANGELOG.md`
3. Update `RELEASE_NOTES.md` (if release candidate)
4. Update `PROJECT_LOG.md`
5. Update `README.md` if version is referenced

Release notes must be "App Store ready":
- 3-5 bullets max
- User-visible changes only
- No internal refactors mentioned

---

## Privacy & Compliance Guardrails

Before adding any SDK or user data flow:
1. Describe what data is collected
2. How it maps to App Store "App Privacy" declarations
3. Whether tracking is involved
4. What ATT prompts are required
5. Document in `DECISIONS.md`

Do not add analytics or tracking silently.

Current state:
- **AdMob**: Banner ads on menu and gameplay. Test ads in DEBUG, production in RELEASE.
- **ATT**: Prompt on first launch via `ATTrackingManager`. Ads work either way.
- **App ID**: ca-app-pub-3801339388353505~8476936917
- **Banner Ad Unit**: ca-app-pub-3801339388353505/4009394081

---

## Git Practices

- **Commit messages**: Short summary line, blank line, body explaining why (not what). End with `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>`
- **Commit often**: One logical change per commit. Don't batch unrelated changes.
- **Never force push** to main.
- **Push after committing** unless told otherwise.
- **Large files**: If git push fails with broken pipe, use `git config http.version HTTP/1.1`.
- **Read-only git inspection**: When checking `git status` or `git diff`, treat as read-only context. Don't revert or assume missing changes were yours.
- **Do not delete or rewrite history** in PROJECT_LOG.md or CHANGELOG.md.

---

## Change Summary (mandatory output)

After completing any work, output a change summary:

```
## Change Summary
- **What changed**: (files and what was modified)
- **Why**: (reason for the change)
- **How to test**: (exact steps to verify)
- **Docs updated**: (list of docs updated)
- **Risks / follow-ups**: (anything that needs attention)
```

---

## Hard "Do Not" List

- Do not claim something is implemented unless it builds and works.
- Do not delete or rewrite history in PROJECT_LOG.md / CHANGELOG.md.
- Do not introduce new SDKs without explicitly documenting privacy impact.
- Do not mix large refactors with feature work in one commit.
- Do not propose changes to code you haven't read.
- Do not commit code that doesn't compile.
- Do not bump versions without explicit user approval.
- Do not skip documentation updates.
- Do not end a session without creating a chat session summary in `Docs/chats/`.
- Do not end a session without running the repo housekeeping checklist.

---

## Credential & Secret Protection (mandatory)

Credentials, secrets, and private keys must NEVER be handled through Claude Code sessions. This is non-negotiable.

### Hard rules

1. **REFUSE credentials immediately.** If the user shares or attempts to share any of the following, STOP and warn them:
   - Passwords, passphrases, or PINs
   - API keys, auth tokens, or bearer tokens
   - Private keys (`.p8`, `.pem`, `.key`, certificate files)
   - OAuth secrets, client secrets
   - Provisioning profiles or signing identities
   - Database connection strings with credentials
   - Any value that looks like a secret (high-entropy strings, base64-encoded keys)

   Response: "This looks like a credential/secret. I cannot accept, store, or use this. Please handle credentials outside of this session (e.g., via Keychain, environment variables, or secure file transfer)."

2. **NEVER write credentials to any file** — not code, not documentation, not session summaries, not commit messages. No exceptions.

3. **NEVER commit credential files.** Before every commit, verify no staged files match these patterns:
   - `*.p8`, `*.pem`, `*.key`, `*.secret`, `*.cert`, `*.pfx`, `*.p12`
   - `.env`, `.env.*`, `.apple_id`
   - `*credentials*`, `*secret*` (in filenames)
   - Any file containing private key headers (`BEGIN PRIVATE KEY`, `BEGIN EC PRIVATE KEY`, `BEGIN RSA PRIVATE KEY`)

4. **NEVER log credentials in session summaries.** Session summaries must not contain:
   - Key IDs, identifiers, or account identifiers
   - File paths to private key storage locations
   - Authentication command flags with key identifiers
   - Details about credential transfer, rotation, or revocation

5. **Pre-commit credential scan.** Before every `git add` / `git commit`, run:
   ```bash
   git diff --cached --name-only | xargs grep -l 'BEGIN.*PRIVATE KEY\|BEGIN CERTIFICATE' 2>/dev/null
   ```
   If any file matches, ABORT the commit and warn the user.

6. **Safe authentication patterns.** When CLI authentication is needed (e.g., `xcodebuild` uploads):
   - Guide the user to set up credentials OUTSIDE the session (Keychain, environment variables, `~/.appstoreconnect/`)
   - Reference credentials by mechanism ("use your stored API key"), never by value
   - Do not include key IDs, identifiers, or file paths in documentation

### If a credential is accidentally shared

1. Immediately warn the user: "A credential was shared in this session. It should be rotated/revoked immediately."
2. Do NOT record the credential in any file, summary, or commit
3. Note in the session summary: "Credential was inadvertently discussed — user handled rotation outside session"
4. Do NOT describe what type of credential, where it was stored, or what it accessed

---

## File Structure

```
RocketLander/
  Models/        — GameState, HighScoreManager, LandingPlatform, LandingMessages, LandingThresholds, LevelDefinition, CampaignState, GameCenterManager, DailyChallenge, BlueStarManager, PilotProgress, ShipSkin
  Views/         — GameContainerView, GameOverView, HUDViews, ControlViews, LeaderboardView, HowToPlayView, LevelSelectView, ShareScoreCardView, DailyChallengeBriefingView, HangarView, ProgressionViews
  Haptics/       — HapticManager
  GameScene.swift           — Core update loop, physics, collision
  GameScene+Setup.swift     — Scene setup, terrain, platforms
  GameScene+Effects.swift   — Visual effects (wind, haze, shimmer, eruptions)
  GameScene+Sound.swift     — Audio management
  GameScene+Scoring.swift   — Score calculation
  GameScene+Juice.swift     — Landing camera, flight guidance, dust, DEBUG autopilot
  StarshipArt.swift         — Starship node/plume factory, textures, preview scene
  ContentView.swift         — ContentView + MenuView
Docs/chats/      — Session summaries
Docs/GROWTH_PLAN.md — Organic growth strategy (ASO, share triggers, screenshots)
Scripts/         — Python utility scripts
Screenshots/     — App Store screenshots
build/           — Build artifacts (ExportOptions.plist)
.github/         — PR template, ios-ci.yml, testflight.yml
```

---

## App Store

- Archive + export using `build/ExportOptions.plist` (method: app-store-connect, teamID: 6XK6BNVURL)
- Screenshots: 1284x2778px, clean status bar, saved to `Screenshots/`
