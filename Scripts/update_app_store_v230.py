#!/usr/bin/env python3
"""
Prepare the App Store Connect v2.3.0 listing: name, subtitle, copy, keywords,
screenshots, Build 39, and (with --submit) the review submission.

  ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v230.py            # dry run
  ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v230.py --apply
  ASC_ISSUER_ID=<issuer-id> python3 Scripts/update_app_store_v230.py --apply --submit

Build 39 and the screenshot files are checked before anything is changed, in the
dry run too. Any failed call stops the script; nothing is retried. Approved
versions are held for manual release unless --auto-release is passed.

It does not store credentials. It reads the .p8 key from
~/.appstoreconnect/private_keys/AuthKey_*.p8 or ASC_KEY_ID/ASC_PRIVATE_KEY.
"""

import argparse
import glob
import os
import sys
from pathlib import Path

import requests

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Scripts"))

from setup_game_center import BASE_URL, generate_token, get_app_id, make_headers  # noqa: E402

VERSION = "2.3.0"
BUILD_NUMBER = "39"
LOCALE = "en-US"
SCREENSHOT_DISPLAY_TYPE = "APP_IPHONE_65"
SCREENSHOT_DIR = ROOT / "Screenshots" / "appstore-v2.3.0"

APP_NAME = "Starship Lander: Rocket Sim"
SUBTITLE = "Moon & Mars landing simulator"

PROMOTIONAL_TEXT = (
    "New: Pilot Ranks, a Hangar with 7 Starship paint schemes, and cinematic landings. "
    "Precision beats luck. Can you stick the landing on all 10 worlds?"
)

DESCRIPTION = """Can you land a rocket? Most pilots crash on their first try.

Starship Lander is a rocket landing game where precision beats luck. Fire the engines, fight gravity, keep the ship upright and touch down on the pad before the fuel runs out. One flight takes 30 seconds. Getting it perfect takes a lot longer.

EASY TO START, HARD TO MASTER
• Three buttons: thrust, rotate left, rotate right. Or tilt your phone to steer.
• A guide line turns green when you are lined up with the pad.
• Three landing pads on every flight. The small one pays 5x.
• Every landing is scored on speed, tilt, accuracy and fuel left. The perfect landing is 20,000 points.

10 WORLDS, 10 DIFFERENT FLIGHTS
Fly the campaign from the Moon to Jupiter. Mars has dust storms. Titan has thick air. Europa is ice. Earth has moving platforms. Io throws volcanic rock at you. Every world has its own gravity and its own way to ruin a good approach.

A NEW MISSION EVERY DAY
The Daily Challenge gives every pilot the same mission. Complete it to earn Blue Stars and keep your streak alive.

RANK UP AND BUILD YOUR FLEET
• Earn XP on every flight and climb 10 pilot ranks, from Cadet to Starship Legend.
• Spend Blue Stars in the Hangar on 7 Starship paint schemes, each with its own engine glow.
• Beat your friends on the Game Center leaderboards and unlock achievements.
• Share your score card and dare someone to beat it.

BUILT FOR ONE MORE TRY
• Cinematic camera on final approach, with dust, sparks and big explosions
• Instant retry, short flights, no waiting
• Retro sound and haptic feedback
• No account needed. No purchases. Everything is earned by flying.

Landing is easy. Landing well is not. How high can you score?"""

WHATS_NEW = """MISSION CONTROL UPDATE

• Pilot Rank: earn XP on every flight and climb 10 ranks from Cadet to Starship Legend
• Hangar: spend Blue Stars on 7 Starship paint schemes, each with its own engine glow
• Cinematic landings: the camera zooms in on final approach, with dust, sparks and bigger explosions
• Flight guidance: a guide line turns green when you're lined up with the pad, plus a live descent readout by your ship
• Every world redesigned with its own sky, horizon glow and atmosphere
• Fixes: Sound and Haptics settings now work, smoother thrust on every device"""

KEYWORDS = "space,spaceship,physics,flight,lunar,gravity,pilot,arcade,daily,challenge,skill,planet,jupiter,orbit"
SUPPORT_URL = "https://rabbitolivestudios.github.io"
MARKETING_URL = "https://rabbitolivestudios.github.io"
REVIEW_NOTES = """Starship Lander is a skill-based rocket landing game.

No login is required. Game Center is optional and used for leaderboards and achievements. If the reviewer is not signed into Game Center, the game remains playable and leaderboard UI may show local/fallback states.

New in 2.3.0: Pilot Rank (XP earned by flying), a Hangar with 7 ship paint schemes, and visual upgrades. Blue Stars are earned only by playing (Daily Challenge, campaign milestones, rank promotions). There are no in-app purchases, no new SDKs and no new data collection in this build.

The app name and subtitle were updated in this version to describe the game more clearly.

Ads are unchanged: banner ads with conservative pacing. The ATT prompt may appear on first launch. Button controls are enabled by default; tilt controls can be selected from the settings menu."""

LIMITS = {
    "name": (APP_NAME, 30),
    "subtitle": (SUBTITLE, 30),
    "promotional text": (PROMOTIONAL_TEXT, 170),
    "keywords": (KEYWORDS, 100),
    "description": (DESCRIPTION, 4000),
    "what's new": (WHATS_NEW, 4000),
}


def check_limits():
    for field, (text, limit) in LIMITS.items():
        if len(text) > limit:
            raise SystemExit(f"{field} is {len(text)} characters; the App Store limit is {limit}")


def find_api_key():
    key_id = os.environ.get("ASC_KEY_ID")
    private_key = os.environ.get("ASC_PRIVATE_KEY")
    if key_id and private_key:
        if "\\n" in private_key and "\n" not in private_key:
            private_key = private_key.replace("\\n", "\n")
        return key_id, private_key

    pattern = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_*.p8")
    keys = sorted(glob.glob(pattern), key=lambda p: os.path.getmtime(p), reverse=True)
    if not keys:
        raise SystemExit("No ASC API key found in ~/.appstoreconnect/private_keys/")

    path = keys[0]
    key_id = os.path.basename(path).replace("AuthKey_", "").replace(".p8", "")
    with open(path, "r") as handle:
        private_key = handle.read()
    return key_id, private_key


def request_json(headers, method, path, *, expected=(200, 201, 204), **kwargs):
    url = f"{BASE_URL}{path}"
    response = requests.request(method, url, headers=headers, timeout=60, **kwargs)
    if response.status_code not in expected:
        raise RuntimeError(f"{method} {path} failed: {response.status_code}\n{response.text[:1200]}")
    if response.status_code == 204 or not response.content:
        return None
    return response.json()


def list_versions(headers, app_id):
    data = request_json(
        headers,
        "GET",
        f"/v1/apps/{app_id}/appStoreVersions",
        params={
            "filter[platform]": "IOS",
            "fields[appStoreVersions]": "versionString,appStoreState,platform",
            "limit": 20,
        },
    )
    return data.get("data", [])


def get_or_create_version(headers, app_id, apply):
    for version in list_versions(headers, app_id):
        attrs = version["attributes"]
        if attrs.get("versionString") == VERSION:
            print(f"Using existing App Store version {VERSION} ({attrs.get('appStoreState')}) id={version['id']}")
            return version["id"]

    print(f"App Store version {VERSION} does not exist.")
    if not apply:
        return None

    body = {
        "data": {
            "type": "appStoreVersions",
            "attributes": {"platform": "IOS", "versionString": VERSION},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
        }
    }
    data = request_json(headers, "POST", "/v1/appStoreVersions", json=body)
    version_id = data["data"]["id"]
    print(f"Created App Store version {VERSION} id={version_id}")
    return version_id


def patch_version(headers, version_id, apply, release_type):
    body = {
        "data": {
            "type": "appStoreVersions",
            "id": version_id,
            "attributes": {
                "copyright": "2026 Rabbit & Olive Studios",
                "releaseType": release_type,
            },
        }
    }
    print(f"Updating version-level copyright; releaseType={release_type}")
    if apply:
        request_json(headers, "PATCH", f"/v1/appStoreVersions/{version_id}", json=body)


def get_or_create_localization(headers, version_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appStoreVersions/{version_id}/appStoreVersionLocalizations",
        params={"fields[appStoreVersionLocalizations]": "locale", "limit": 50},
    )
    for loc in data.get("data", []):
        if loc["attributes"].get("locale") == LOCALE:
            print(f"Using localization {LOCALE} id={loc['id']}")
            return loc["id"]

    print(f"Localization {LOCALE} does not exist.")
    if not apply:
        return None

    body = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {"locale": LOCALE},
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}
            },
        }
    }
    data = request_json(headers, "POST", "/v1/appStoreVersionLocalizations", json=body)
    loc_id = data["data"]["id"]
    print(f"Created localization {LOCALE} id={loc_id}")
    return loc_id


def patch_localization(headers, loc_id, apply):
    body = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": loc_id,
            "attributes": {
                "description": DESCRIPTION,
                "keywords": KEYWORDS,
                "marketingUrl": MARKETING_URL,
                "promotionalText": PROMOTIONAL_TEXT,
                "supportUrl": SUPPORT_URL,
                "whatsNew": WHATS_NEW,
            },
        }
    }
    print("Updating ASO localization copy")
    if apply:
        request_json(headers, "PATCH", f"/v1/appStoreVersionLocalizations/{loc_id}", json=body)


def patch_app_info(headers, app_id, apply):
    """Set name and subtitle on the editable app info (exists once the new version does)."""
    infos = request_json(headers, "GET", f"/v1/apps/{app_id}/appInfos").get("data", [])
    live_states = {"READY_FOR_SALE", "READY_FOR_DISTRIBUTION"}
    editable = [
        info for info in infos
        if (info["attributes"].get("state") or info["attributes"].get("appStoreState")) not in live_states
    ]
    if not editable:
        print("No editable app info yet (it appears after the new version is created); name/subtitle not changed")
        return
    info_id = editable[0]["id"]
    locs = request_json(
        headers, "GET", f"/v1/appInfos/{info_id}/appInfoLocalizations", params={"limit": 50}
    ).get("data", [])
    loc = next((item for item in locs if item["attributes"].get("locale") == LOCALE), None)
    if not loc:
        raise RuntimeError(f"No {LOCALE} app info localization found")
    attrs = loc["attributes"]
    print(f"Name: {attrs.get('name')!r} -> {APP_NAME!r}; subtitle: {attrs.get('subtitle')!r} -> {SUBTITLE!r}")
    if apply:
        body = {
            "data": {
                "type": "appInfoLocalizations",
                "id": loc["id"],
                "attributes": {"name": APP_NAME, "subtitle": SUBTITLE},
            }
        }
        request_json(headers, "PATCH", f"/v1/appInfoLocalizations/{loc['id']}", json=body)


def patch_review_notes(headers, version_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appStoreVersions/{version_id}/appStoreReviewDetail",
        params={"fields[appStoreReviewDetails]": "notes"},
    )
    detail = data["data"]
    body = {
        "data": {
            "type": "appStoreReviewDetails",
            "id": detail["id"],
            "attributes": {"notes": REVIEW_NOTES},
        }
    }
    print("Updating review notes")
    if apply:
        request_json(headers, "PATCH", f"/v1/appStoreReviewDetails/{detail['id']}", json=body)


def find_build(headers, app_id):
    data = request_json(
        headers,
        "GET",
        "/v1/builds",
        params={
            "filter[app]": app_id,
            "filter[version]": BUILD_NUMBER,
            "fields[builds]": "version,processingState,uploadedDate,expired",
            "sort": "-uploadedDate",
            "limit": 10,
        },
    )
    builds = data.get("data", [])
    if not builds:
        raise RuntimeError(f"Build {BUILD_NUMBER} not found in App Store Connect")
    build = builds[0]
    attrs = build["attributes"]
    print(
        f"Using Build {attrs.get('version')} id={build['id']} "
        f"state={attrs.get('processingState')} uploaded={attrs.get('uploadedDate')} expired={attrs.get('expired')}"
    )
    if attrs.get("processingState") != "VALID" or attrs.get("expired"):
        raise RuntimeError(f"Build {BUILD_NUMBER} is not ready (state={attrs.get('processingState')})")
    return build["id"]


def attach_build(headers, version_id, build_id, apply):
    body = {"data": {"type": "builds", "id": build_id}}
    print(f"Attaching Build {BUILD_NUMBER} to App Store version {VERSION}")
    if apply:
        request_json(
            headers,
            "PATCH",
            f"/v1/appStoreVersions/{version_id}/relationships/build",
            json=body,
        )


def screenshot_paths():
    paths = sorted(SCREENSHOT_DIR.glob("0*.png"))
    if not 3 <= len(paths) <= 10:
        raise RuntimeError(f"Expected 3-10 screenshots in {SCREENSHOT_DIR}, found {len(paths)}")
    return paths


def get_or_create_screenshot_set(headers, loc_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets",
        params={
            "fields[appScreenshotSets]": "screenshotDisplayType",
            "limit": 50,
        },
    )
    for item in data.get("data", []):
        if item["attributes"].get("screenshotDisplayType") == SCREENSHOT_DISPLAY_TYPE:
            print(f"Using screenshot set {SCREENSHOT_DISPLAY_TYPE} id={item['id']}")
            return item["id"]

    print(f"Screenshot set {SCREENSHOT_DISPLAY_TYPE} does not exist.")
    if not apply:
        return None

    body = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {"screenshotDisplayType": SCREENSHOT_DISPLAY_TYPE},
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {"type": "appStoreVersionLocalizations", "id": loc_id}
                }
            },
        }
    }
    data = request_json(headers, "POST", "/v1/appScreenshotSets", json=body)
    set_id = data["data"]["id"]
    print(f"Created screenshot set {SCREENSHOT_DISPLAY_TYPE} id={set_id}")
    return set_id


def delete_existing_screenshots(headers, set_id, apply):
    data = request_json(
        headers,
        "GET",
        f"/v1/appScreenshotSets/{set_id}/appScreenshots",
        params={"fields[appScreenshots]": "fileName", "limit": 50},
    )
    screenshots = data.get("data", [])
    if not screenshots:
        print("No existing screenshots to delete")
        return
    print(f"Deleting {len(screenshots)} existing screenshots in set")
    if not apply:
        return
    for screenshot in screenshots:
        request_json(headers, "DELETE", f"/v1/appScreenshots/{screenshot['id']}", expected=(204,))


def reserve_upload(headers, set_id, path):
    file_size = path.stat().st_size
    body = {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": path.name,
                "fileSize": file_size,
            },
            "relationships": {
                "appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}
            },
        }
    }
    data = request_json(headers, "POST", "/v1/appScreenshots", json=body)
    return data["data"]


def upload_screenshot(headers, set_id, path, apply):
    print(f"Uploading {path.name} ({path.stat().st_size} bytes)")
    if not apply:
        return
    screenshot = reserve_upload(headers, set_id, path)
    screenshot_id = screenshot["id"]
    upload_ops = screenshot["attributes"].get("uploadOperations", [])
    if not upload_ops:
        raise RuntimeError(f"No upload operations returned for {path.name}")

    data = path.read_bytes()
    for op in upload_ops:
        method = op["method"]
        url = op["url"]
        op_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        offset = op.get("offset", 0)
        length = op.get("length", len(data))
        chunk = data[offset : offset + length]
        response = requests.request(method, url, headers=op_headers, data=chunk, timeout=120)
        if response.status_code >= 400:
            raise RuntimeError(
                f"Binary upload failed for {path.name}: {response.status_code}\n{response.text[:500]}"
            )

    body = {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {"uploaded": True},
        }
    }
    request_json(headers, "PATCH", f"/v1/appScreenshots/{screenshot_id}", json=body)


def upload_screenshots(headers, loc_id, apply):
    paths = screenshot_paths()
    set_id = get_or_create_screenshot_set(headers, loc_id, apply)
    if not set_id:
        print("Skipping screenshot upload in dry run")
        return
    delete_existing_screenshots(headers, set_id, apply)
    for path in paths:
        upload_screenshot(headers, set_id, path, apply)


def submit_for_review(headers, app_id, version_id, apply):
    print("Preparing App Store review submission")
    submissions = request_json(
        headers,
        "GET",
        f"/v1/apps/{app_id}/reviewSubmissions",
        params={
            "filter[platform]": "IOS",
            "fields[reviewSubmissions]": "platform,state,submittedDate",
            "limit": 20,
        },
    ).get("data", [])

    submission = next(
        (item for item in submissions if item["attributes"].get("state") == "READY_FOR_REVIEW"),
        None,
    )
    if submission:
        submission_id = submission["id"]
        print(f"Using existing review submission id={submission_id}")
    else:
        if not apply:
            print("Would create review submission")
            return
        body = {
            "data": {
                "type": "reviewSubmissions",
                "attributes": {"platform": "IOS"},
                "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
            }
        }
        submission = request_json(headers, "POST", "/v1/reviewSubmissions", expected=(201,), json=body)["data"]
        submission_id = submission["id"]
        print(f"Created review submission id={submission_id}")

    if apply:
        body = {
            "data": {
                "type": "reviewSubmissionItems",
                "relationships": {
                    "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": submission_id}},
                    "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}},
                },
            }
        }
        item = request_json(headers, "POST", "/v1/reviewSubmissionItems", expected=(201,), json=body)["data"]
        print(f"Created review submission item id={item['id']}")

        body = {
            "data": {
                "type": "reviewSubmissions",
                "id": submission_id,
                "attributes": {"submitted": True},
            }
        }
        submission = request_json(
            headers,
            "PATCH",
            f"/v1/reviewSubmissions/{submission_id}",
            expected=(200,),
            json=body,
        )["data"]
        attrs = submission["attributes"]
        print(f"Review submission state={attrs.get('state')} submittedDate={attrs.get('submittedDate')}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="Make changes in App Store Connect")
    parser.add_argument("--skip-screenshots", action="store_true")
    parser.add_argument("--submit", action="store_true", help="Submit the prepared version for App Store review")
    parser.add_argument(
        "--auto-release",
        action="store_true",
        help="Publish automatically once Apple approves. Default: hold for manual release.",
    )
    args = parser.parse_args()

    check_limits()
    issuer_id = os.environ.get("ASC_ISSUER_ID")
    if not issuer_id:
        raise SystemExit("Set ASC_ISSUER_ID in the environment")

    key_id, private_key = find_api_key()
    token = generate_token(issuer_id, key_id, private_key)
    headers = make_headers(token)
    app_id = get_app_id(headers)

    print("Mode:", "APPLY" if args.apply else "DRY RUN")
    # Read-only checks first: nothing in App Store Connect changes unless these pass.
    build_id = find_build(headers, app_id)
    if not args.skip_screenshots:
        screenshot_paths()
    release_type = "AFTER_APPROVAL" if args.auto_release else "MANUAL"
    version_id = get_or_create_version(headers, app_id, args.apply)
    if not version_id:
        print("Dry run complete before version creation")
        return
    patch_version(headers, version_id, args.apply, release_type)
    loc_id = get_or_create_localization(headers, version_id, args.apply)
    if not loc_id:
        print("Dry run complete before localization creation")
        return
    patch_localization(headers, loc_id, args.apply)
    patch_app_info(headers, app_id, args.apply)
    patch_review_notes(headers, version_id, args.apply)
    attach_build(headers, version_id, build_id, args.apply)
    if not args.skip_screenshots:
        upload_screenshots(headers, loc_id, args.apply)
    if args.submit:
        submit_for_review(headers, app_id, version_id, args.apply)
    print("Done")


if __name__ == "__main__":
    main()
