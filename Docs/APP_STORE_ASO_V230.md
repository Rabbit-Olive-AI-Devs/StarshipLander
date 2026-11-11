# App Store ASO — v2.3.0 "Mission Control"

Status: listing prepared in the repo (2026-11-11). **Not yet applied in App Store Connect and not yet submitted.** Apply with `Scripts/update_app_store_v230.py` on the Mac that holds the App Store Connect API key.

Source of truth for the copy is `Scripts/update_app_store_v230.py`. This file explains the choices.

## Goal

More search impressions and a higher page-view-to-install rate. The live 2.2.1 listing had 2 ratings, the subtitle "Precision piloting. No margin." (no search terms in it) and a description that opened with a hotfix notice.

## What changed and why

| Field | 2.2.1 (live) | 2.3.0 | Why |
|-------|--------------|-------|-----|
| Name | Starship Lander | Starship Lander: Rocket Sim | The name is the strongest search field. Adds "rocket" and "sim" without changing the brand. |
| Subtitle | Precision piloting. No margin. | Moon & Mars landing simulator | Second strongest field. Adds moon, mars, landing, simulator. |
| Keywords | rocket,lander,space,landing,physics,flight,moon,mars,daily,challenge,leaderboard,arcade | space,spaceship,physics,flight,lunar,gravity,pilot,arcade,daily,challenge,skill,planet,jupiter,orbit | No word repeats the name or subtitle (repeats are wasted). Uses all 100 characters. |
| Promotional text | Hotfix notice | New features plus "Precision beats luck" | Editable without review; keeps the canonical positioning from `GROWTH_PLAN.md`. |
| Description | Opened with the hotfix line | Opens with a challenge ("Can you land a rocket?") | The first three lines are all most people read. |
| Screenshots | 5 captioned raw captures | 6 framed captures with headline and kicker | First three show flight, a scored landing and the campaign; ad banner cropped out. |

No third-party trademarks (SpaceX, NASA) appear in any field.

## Screenshot pack

Directory: `Screenshots/appstore-v2.3.0/` (1284x2778 PNG, 6.5" set, which App Store Connect scales to other sizes).

1. `01_land_the_starship.png` — LAND THE / STARSHIP
2. `02_perfect_landing.png` — STICK IT. / SCORE IT.
3. `03_ten_worlds.png` — 10 WORLDS / 10 GRAVITIES
4. `04_pilot_rank.png` — CADET TO / LEGEND
5. `05_hangar.png` — BUILD YOUR / FLEET
6. `06_daily_challenge.png` — NEW MISSION / EVERY DAY

How they are made:

1. CI runs `Scripts/ci_screenshots.sh` on every `claude/**` push and publishes raw captures to the `ci-screenshots` branch. The script seeds saved state through launch arguments and uses the DEBUG autopilot (`-autopilot -pad a|b|c`) to fly a scripted landing.
2. `python3 Scripts/generate_store_screenshots.py <captures-dir>` composes the final set.

## Applying the listing

On the Mac that holds the API key (the key is read locally by the script; never paste it into a chat or a file):

```bash
ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v230.py            # dry run
ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v230.py --apply --submit
```

The script first checks that Build 39 is `VALID` and the screenshot files are present (dry run included) and changes nothing if either fails. It then creates version 2.3.0, sets name, subtitle, copy, keywords and review notes, attaches Build 39, replaces the screenshots, and with `--submit` sends it for review. Any failed call stops the script; nothing is retried. An approved version is held for manual release unless `--auto-release` is passed.

## Virality notes (not in this release)

The listing can raise visibility and conversion. Sharing has to come from inside the game. Candidates for a later build, in line with `GROWTH_PLAN.md` section 4:

- Prompt the share card on a new personal best, a rank promotion and a 3-star landing.
- Put the ship skin and pilot rank on the share card.
- A "beat my score" link that opens the same Daily Challenge.
- Ask for an App Store rating after the third successful landing in a session (`SKStoreReviewController`). Ratings are the biggest missing conversion signal: the app has 2.
