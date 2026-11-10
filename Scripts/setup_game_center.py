#!/usr/bin/env python3
"""
Create Game Center leaderboards and achievements via App Store Connect API.

Usage:
    ASC_ISSUER_ID=<issuer-id> python3 Scripts/setup_game_center.py
    ASC_ISSUER_ID=<issuer-id> python3 Scripts/setup_game_center.py --reset
    ASC_ISSUER_ID=<issuer-id> python3 Scripts/setup_game_center.py --upload-images
    ASC_ISSUER_ID=<issuer-id> python3 Scripts/setup_game_center.py --create-releases

Flags:
    --reset            Delete all existing leaderboards and recreate them (clears scores)
    --upload-images    Upload achievement images from Screenshots/achievements/
    --create-releases  Create release resources to attach leaderboards + achievements to app version

Reads API key from ~/.appstoreconnect/private_keys/AuthKey_*.p8
"""

import os
import sys
import glob
import time
import json
import jwt
import requests

# ── Configuration ─────────────────────────────────────────────────────────

BUNDLE_ID = "com.tboliveira.StarshipLander"
BASE_URL = "https://api.appstoreconnect.apple.com"

LEADERBOARDS = [
    {"ref": "classic", "name": "Classic Mode"},
    {"ref": "campaign_1", "name": "Moon"},
    {"ref": "campaign_2", "name": "Mars"},
    {"ref": "campaign_3", "name": "Titan"},
    {"ref": "campaign_4", "name": "Europa"},
    {"ref": "campaign_5", "name": "Earth"},
    {"ref": "campaign_6", "name": "Venus"},
    {"ref": "campaign_7", "name": "Mercury"},
    {"ref": "campaign_8", "name": "Ganymede"},
    {"ref": "campaign_9", "name": "Io"},
    {"ref": "campaign_10", "name": "Jupiter"},
    {"ref": "campaign_11", "name": "Starbase"},
    {"ref": "campaign_12", "name": "Belly Flop"},
    {"ref": "campaign_13", "name": "Phobos"},
    {"ref": "campaign_14", "name": "Ceres"},
    {"ref": "campaign_15", "name": "Mars Night"},
    {"ref": "galaxy_rank", "name": "Galaxy Rank"},
    {"ref": "daily_challenge", "name": "Daily Challenge"},
]

ACHIEVEMENTS = [
    {
        "ref": "eagle_has_landed",
        "name": "The Eagle Has Landed",
        "desc": "Complete a SAFE landing on any platform.",
        "points": 10,
    },
    {
        "ref": "precision_landing",
        "name": "Precision Landing",
        "desc": "Complete a SAFE landing on Platform B (Precision Target).",
        "points": 10,
    },
    {
        "ref": "elite_landing",
        "name": "Elite Landing",
        "desc": "Complete a SAFE landing on Platform C (Elite Landing).",
        "points": 15,
    },
    {
        "ref": "fuel_master",
        "name": "Fuel Master",
        "desc": "Land with 65% or more fuel remaining.",
        "points": 10,
    },
    {
        "ref": "precision_pilot",
        "name": "Precision Pilot",
        "desc": "SAFE landing on Platform C with tilt under 2 degrees in Campaign mode.",
        "points": 20,
    },
    {
        "ref": "triple_elite",
        "name": "Triple Elite",
        "desc": "SAFE landing on Platform C on 3 different campaign planets.",
        "points": 20,
    },
    {
        "ref": "planet_conquered",
        "name": "Planet Conquered",
        "desc": "Earn 3 stars on any campaign level.",
        "points": 15,
    },
    {
        "ref": "first_try_perfection",
        "name": "First Try Perfection",
        "desc": "SAFE Platform C landing on your very first attempt at a campaign level.",
        "points": 25,
    },
    {
        "ref": "solar_system_elite",
        "name": "Solar System Elite",
        "desc": "Earn all 30 campaign stars across every planet.",
        "points": 25,
    },
    {
        "ref": "master_lander",
        "name": "Master Lander",
        "desc": "SAFE Platform C landing on all 10 campaign planets.",
        "points": 50,
    },
]

# ── Auth helpers ──────────────────────────────────────────────────────────

def find_api_key():
    """Find API key from env vars or ~/.appstoreconnect/private_keys/"""
    # Prefer env vars (e.g., from Vercel)
    key_id = os.environ.get("ASC_KEY_ID")
    private_key = os.environ.get("ASC_PRIVATE_KEY")
    if key_id and private_key:
        # Restore newlines if escaped
        if "\\n" in private_key and "\n" not in private_key:
            private_key = private_key.replace("\\n", "\n")
        # Handle single-line PEM: extract base64, re-wrap at 64 chars
        if "-----BEGIN PRIVATE KEY-----" in private_key and private_key.count("\n") < 4:
            # Strip headers and whitespace to get raw base64
            body = private_key
            body = body.replace("-----BEGIN PRIVATE KEY-----", "")
            body = body.replace("-----END PRIVATE KEY-----", "")
            body = body.replace("\n", "").replace("\r", "").replace(" ", "")
            # Re-wrap at 64 characters per line (PEM standard)
            lines = [body[i:i+64] for i in range(0, len(body), 64)]
            private_key = "-----BEGIN PRIVATE KEY-----\n" + "\n".join(lines) + "\n-----END PRIVATE KEY-----\n"
        return key_id, private_key

    # Fall back to .p8 file on disk
    pattern = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_*.p8")
    keys = sorted(glob.glob(pattern))
    if not keys:
        print("ERROR: No API key found. Set ASC_KEY_ID + ASC_PRIVATE_KEY env vars,")
        print("       or place a .p8 key in ~/.appstoreconnect/private_keys/")
        sys.exit(1)
    path = keys[0]
    key_id = os.path.basename(path).replace("AuthKey_", "").replace(".p8", "")
    with open(path, "r") as f:
        private_key = f.read()
    return key_id, private_key


def generate_token(issuer_id, key_id, private_key):
    """Generate a JWT for App Store Connect API."""
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 1200,  # 20 min
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": key_id})


def make_headers(token):
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }


# ── API calls ─────────────────────────────────────────────────────────────

def get_app_id(headers):
    """Find the app's ASC ID from the bundle ID."""
    r = requests.get(
        f"{BASE_URL}/v1/apps",
        headers=headers,
        params={"filter[bundleId]": BUNDLE_ID, "fields[apps]": "bundleId,name"},
    )
    if r.status_code == 401:
        print(f"ERROR: 401 Unauthorized")
        print(f"  Response: {r.text[:500]}")
        print(f"  Check: Is your API key active in ASC? Is the Issuer ID correct?")
        print(f"  Manage keys at: https://appstoreconnect.apple.com/access/integrations/api")
        sys.exit(1)
    r.raise_for_status()
    data = r.json()["data"]
    if not data:
        print(f"ERROR: No app found with bundle ID {BUNDLE_ID}")
        sys.exit(1)
    app_id = data[0]["id"]
    app_name = data[0]["attributes"]["name"]
    print(f"Found app: {app_name} (ID: {app_id})")
    return app_id


def get_or_create_gc_detail(headers, app_id):
    """Get or create the Game Center detail for the app."""
    # Check if it exists
    r = requests.get(
        f"{BASE_URL}/v1/apps/{app_id}/gameCenterDetail",
        headers=headers,
    )
    if r.status_code == 200:
        data = r.json().get("data")
        if data:
            print(f"Game Center detail exists (ID: {data['id']})")
            return data["id"]

    # Create it
    body = {
        "data": {
            "type": "gameCenterDetails",
            "relationships": {
                "app": {"data": {"type": "apps", "id": app_id}}
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterDetails", headers=headers, json=body)
    if r.status_code == 409:
        # Already exists — try fetching again
        r2 = requests.get(f"{BASE_URL}/v1/apps/{app_id}/gameCenterDetail", headers=headers)
        r2.raise_for_status()
        data = r2.json()["data"]
        print(f"Game Center detail already existed (ID: {data['id']})")
        return data["id"]
    r.raise_for_status()
    gc_id = r.json()["data"]["id"]
    print(f"Created Game Center detail (ID: {gc_id})")
    return gc_id


def get_existing_leaderboards(headers, gc_detail_id):
    """Get existing leaderboard reference names. Returns dict of vendorIdentifier -> resource ID."""
    existing = {}
    url = f"{BASE_URL}/v1/gameCenterDetails/{gc_detail_id}/gameCenterLeaderboards"
    params = {"fields[gameCenterLeaderboards]": "referenceName,vendorIdentifier", "limit": 50}
    r = requests.get(url, headers=headers, params=params)
    r.raise_for_status()
    for item in r.json().get("data", []):
        vid = item["attributes"].get("vendorIdentifier", "")
        if vid:
            existing[vid] = item["id"]
    return existing


def delete_all_leaderboards(headers, gc_detail_id):
    """Delete all existing leaderboards (clears all scores)."""
    existing = get_existing_leaderboards(headers, gc_detail_id)
    if not existing:
        print("  No leaderboards to delete")
        return 0
    deleted = 0
    for vid, resource_id in existing.items():
        r = requests.delete(
            f"{BASE_URL}/v1/gameCenterLeaderboards/{resource_id}",
            headers=headers,
        )
        if r.status_code < 400:
            print(f"  Deleted leaderboard '{vid}' (ID: {resource_id})")
            deleted += 1
        else:
            print(f"  ERROR deleting '{vid}': {r.status_code} — {r.text[:200]}")
    return deleted


def create_leaderboard(headers, gc_detail_id, ref_name, display_name):
    """Create a single leaderboard with English localization."""
    body = {
        "data": {
            "type": "gameCenterLeaderboards",
            "attributes": {
                "referenceName": display_name,
                "vendorIdentifier": ref_name,
                "defaultFormatter": "INTEGER",
                "submissionType": "BEST_SCORE",
                "scoreSortType": "DESC",
                "scoreRangeStart": "0",
                "scoreRangeEnd": "100000",
            },
            "relationships": {
                "gameCenterDetail": {
                    "data": {"type": "gameCenterDetails", "id": gc_detail_id}
                }
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterLeaderboards", headers=headers, json=body)
    if r.status_code == 409:
        # 409 can mean "already exists" OR "entity error" — print details
        print(f"  Leaderboard '{ref_name}' got 409:")
        print(f"  {r.text[:500]}")
        return None
    if r.status_code >= 400:
        print(f"  ERROR creating leaderboard '{ref_name}': {r.status_code}")
        print(f"  {r.text[:500]}")
        return None
    lb_id = r.json()["data"]["id"]
    print(f"  Created leaderboard '{ref_name}' ({display_name}) — ID: {lb_id}")

    # Add English localization
    loc_body = {
        "data": {
            "type": "gameCenterLeaderboardLocalizations",
            "attributes": {
                "locale": "en-US",
                "name": display_name,
                "formatterOverride": "INTEGER",
                "formatterSuffix": " pts",
                "formatterSuffixSingular": " pt",
            },
            "relationships": {
                "gameCenterLeaderboard": {
                    "data": {"type": "gameCenterLeaderboards", "id": lb_id}
                }
            },
        }
    }
    r2 = requests.post(
        f"{BASE_URL}/v1/gameCenterLeaderboardLocalizations",
        headers=headers,
        json=loc_body,
    )
    if r2.status_code < 400:
        print(f"    + en-US localization added")
    else:
        print(f"    ! Localization warning: {r2.status_code} — {r2.text[:200]}")

    return lb_id


def get_current_app_store_version(headers, app_id):
    """Get the latest editable (or live) app store version ID."""
    r = requests.get(
        f"{BASE_URL}/v1/apps/{app_id}/appStoreVersions",
        headers=headers,
        params={
            "filter[platform]": "IOS",
            "fields[appStoreVersions]": "versionString,appStoreState",
            "limit": 5,
        },
    )
    r.raise_for_status()
    versions = r.json().get("data", [])
    if not versions:
        print("WARNING: No app store versions found")
        return None
    # Prefer editable states, fall back to any
    for v in versions:
        state = v["attributes"].get("appStoreState", "")
        version_str = v["attributes"].get("versionString", "")
        print(f"  Found version {version_str} (state: {state}, ID: {v['id']})")
    # Return the first (most recent) version
    version = versions[0]
    print(f"  Using version {version['attributes'].get('versionString', '?')} (ID: {version['id']})")
    return version["id"]


def enable_gc_for_app_version(headers, gc_detail_id, app_id):
    """Enable Game Center for the current app store version (gameCenterAppVersions)."""
    # Check if already enabled
    r = requests.get(
        f"{BASE_URL}/v1/gameCenterDetails/{gc_detail_id}/gameCenterAppVersions",
        headers=headers,
        params={"fields[gameCenterAppVersions]": "enabled", "limit": 10},
    )
    r.raise_for_status()
    existing = r.json().get("data", [])
    if existing:
        for entry in existing:
            enabled = entry["attributes"].get("enabled", False)
            print(f"  gameCenterAppVersion exists (ID: {entry['id']}, enabled: {enabled})")
            if not enabled:
                # Enable it
                patch_body = {
                    "data": {
                        "type": "gameCenterAppVersions",
                        "id": entry["id"],
                        "attributes": {"enabled": True},
                    }
                }
                r2 = requests.patch(
                    f"{BASE_URL}/v1/gameCenterAppVersions/{entry['id']}",
                    headers=headers,
                    json=patch_body,
                )
                if r2.status_code < 400:
                    print(f"  Enabled gameCenterAppVersion {entry['id']}")
                else:
                    print(f"  WARNING: Could not enable: {r2.status_code} — {r2.text[:300]}")
        return

    # No existing gameCenterAppVersion — create one
    version_id = get_current_app_store_version(headers, app_id)
    if not version_id:
        print("  WARNING: Cannot create gameCenterAppVersion — no app store version found")
        return

    body = {
        "data": {
            "type": "gameCenterAppVersions",
            "attributes": {"enabled": True},
            "relationships": {
                "appStoreVersion": {
                    "data": {"type": "appStoreVersions", "id": version_id}
                }
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterAppVersions", headers=headers, json=body)
    if r.status_code == 409:
        print(f"  gameCenterAppVersion already exists (409)")
        return
    if r.status_code >= 400:
        print(f"  ERROR creating gameCenterAppVersion: {r.status_code}")
        print(f"  {r.text[:500]}")
        return
    gcav_id = r.json()["data"]["id"]
    print(f"  Created gameCenterAppVersion (ID: {gcav_id}, enabled: true)")


def get_existing_achievements(headers, gc_detail_id):
    """Get existing achievement reference names. Returns dict of vendorIdentifier -> resource ID."""
    existing = {}
    url = f"{BASE_URL}/v1/gameCenterDetails/{gc_detail_id}/gameCenterAchievements"
    params = {"fields[gameCenterAchievements]": "referenceName,vendorIdentifier", "limit": 50}
    r = requests.get(url, headers=headers, params=params)
    r.raise_for_status()
    for item in r.json().get("data", []):
        vid = item["attributes"].get("vendorIdentifier", "")
        if vid:
            existing[vid] = item["id"]
    return existing


def get_achievement_localizations(headers, gc_detail_id):
    """Get achievement localization IDs keyed by vendorIdentifier.
    Returns dict: { vendorIdentifier: localization_id }
    """
    # First get all achievements with their IDs
    url = f"{BASE_URL}/v1/gameCenterDetails/{gc_detail_id}/gameCenterAchievements"
    params = {"fields[gameCenterAchievements]": "referenceName,vendorIdentifier", "limit": 50}
    r = requests.get(url, headers=headers, params=params)
    r.raise_for_status()

    result = {}
    for item in r.json().get("data", []):
        vid = item["attributes"].get("vendorIdentifier", "")
        ach_id = item["id"]
        if not vid:
            continue

        # Get localizations for this achievement
        loc_url = f"{BASE_URL}/v1/gameCenterAchievements/{ach_id}/localizations"
        loc_params = {"fields[gameCenterAchievementLocalizations]": "locale", "limit": 10}
        r2 = requests.get(loc_url, headers=headers, params=loc_params)
        if r2.status_code >= 400:
            print(f"  WARNING: Could not fetch localizations for '{vid}': {r2.status_code}")
            continue
        for loc in r2.json().get("data", []):
            locale = loc["attributes"].get("locale", "")
            if locale == "en-US":
                result[vid] = loc["id"]
                break

    return result


def upload_achievement_image(headers, localization_id, image_path, ref_name):
    """Upload an achievement image via ASC API (3-step: reserve, upload, commit)."""

    file_size = os.path.getsize(image_path)
    file_name = os.path.basename(image_path)

    # Step 1: Reserve the image upload
    reserve_body = {
        "data": {
            "type": "gameCenterAchievementImages",
            "attributes": {
                "fileName": file_name,
                "fileSize": file_size,
            },
            "relationships": {
                "gameCenterAchievementLocalization": {
                    "data": {
                        "type": "gameCenterAchievementLocalizations",
                        "id": localization_id,
                    }
                }
            },
        }
    }

    r = requests.post(
        f"{BASE_URL}/v1/gameCenterAchievementImages",
        headers=headers,
        json=reserve_body,
    )
    if r.status_code >= 400:
        print(f"  ERROR reserving image for '{ref_name}': {r.status_code}")
        print(f"  {r.text[:500]}")
        return False

    response_data = r.json()["data"]
    image_id = response_data["id"]
    upload_ops = response_data["attributes"].get("uploadOperations", [])

    if not upload_ops:
        print(f"  ERROR: No upload operations returned for '{ref_name}'")
        return False

    # Step 2: Upload binary data
    with open(image_path, "rb") as f:
        file_data = f.read()

    for op in upload_ops:
        method = op["method"]
        url = op["url"]
        op_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        offset = op.get("offset", 0)
        length = op.get("length", file_size)

        chunk = file_data[offset:offset + length]

        if method == "PUT":
            r2 = requests.put(url, headers=op_headers, data=chunk)
        else:
            r2 = requests.request(method, url, headers=op_headers, data=chunk)

        if r2.status_code >= 400:
            print(f"  ERROR uploading chunk for '{ref_name}': {r2.status_code}")
            print(f"  {r2.text[:300]}")
            return False

    # Step 3: Commit the upload
    commit_body = {
        "data": {
            "type": "gameCenterAchievementImages",
            "id": image_id,
            "attributes": {
                "uploaded": True,
            },
        }
    }
    r3 = requests.patch(
        f"{BASE_URL}/v1/gameCenterAchievementImages/{image_id}",
        headers=headers,
        json=commit_body,
    )
    if r3.status_code >= 400:
        print(f"  ERROR committing image for '{ref_name}': {r3.status_code}")
        print(f"  {r3.text[:300]}")
        return False

    print(f"  Uploaded image for '{ref_name}' ({file_size} bytes)")
    return True


def create_leaderboard_release(headers, gc_detail_id, leaderboard_id, ref_name):
    """Create a leaderboard release — attaches the leaderboard to the GC detail for submission."""
    body = {
        "data": {
            "type": "gameCenterLeaderboardReleases",
            "relationships": {
                "gameCenterDetail": {
                    "data": {"type": "gameCenterDetails", "id": gc_detail_id}
                },
                "gameCenterLeaderboard": {
                    "data": {"type": "gameCenterLeaderboards", "id": leaderboard_id}
                },
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterLeaderboardReleases", headers=headers, json=body)
    if r.status_code == 409:
        print(f"  Release for '{ref_name}' already exists — OK")
        return True
    if r.status_code >= 400:
        print(f"  ERROR creating release for '{ref_name}': {r.status_code}")
        print(f"  {r.text[:500]}")
        return False
    print(f"  Created release for '{ref_name}'")
    return True


def create_achievement_release(headers, gc_detail_id, achievement_id, ref_name):
    """Create an achievement release — attaches the achievement to the GC detail for submission."""
    body = {
        "data": {
            "type": "gameCenterAchievementReleases",
            "relationships": {
                "gameCenterDetail": {
                    "data": {"type": "gameCenterDetails", "id": gc_detail_id}
                },
                "gameCenterAchievement": {
                    "data": {"type": "gameCenterAchievements", "id": achievement_id}
                },
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterAchievementReleases", headers=headers, json=body)
    if r.status_code == 409:
        print(f"  Release for '{ref_name}' already exists — OK")
        return True
    if r.status_code >= 400:
        print(f"  ERROR creating release for '{ref_name}': {r.status_code}")
        print(f"  {r.text[:500]}")
        return False
    print(f"  Created release for '{ref_name}'")
    return True


def create_achievement(headers, gc_detail_id, ref_name, display_name, description, points):
    """Create a single achievement with English localization."""
    body = {
        "data": {
            "type": "gameCenterAchievements",
            "attributes": {
                "referenceName": display_name,
                "vendorIdentifier": ref_name,
                "points": points,
                "repeatable": False,
                "showBeforeEarned": True,
            },
            "relationships": {
                "gameCenterDetail": {
                    "data": {"type": "gameCenterDetails", "id": gc_detail_id}
                }
            },
        }
    }
    r = requests.post(f"{BASE_URL}/v1/gameCenterAchievements", headers=headers, json=body)
    if r.status_code == 409:
        print(f"  Achievement '{ref_name}' already exists — skipping")
        return None
    if r.status_code >= 400:
        print(f"  ERROR creating achievement '{ref_name}': {r.status_code}")
        print(f"  {r.text[:500]}")
        return None
    ach_id = r.json()["data"]["id"]
    print(f"  Created achievement '{ref_name}' ({display_name}, {points}pts) — ID: {ach_id}")

    # Add English localization
    loc_body = {
        "data": {
            "type": "gameCenterAchievementLocalizations",
            "attributes": {
                "locale": "en-US",
                "name": display_name,
                "beforeEarnedDescription": description,
                "afterEarnedDescription": description,
            },
            "relationships": {
                "gameCenterAchievement": {
                    "data": {"type": "gameCenterAchievements", "id": ach_id}
                }
            },
        }
    }
    r2 = requests.post(
        f"{BASE_URL}/v1/gameCenterAchievementLocalizations",
        headers=headers,
        json=loc_body,
    )
    if r2.status_code < 400:
        print(f"    + en-US localization added")
    else:
        print(f"    ! Localization warning: {r2.status_code} — {r2.text[:200]}")

    return ach_id


# ── Main ──────────────────────────────────────────────────────────────────

def main():
    issuer_id = os.environ.get("ASC_ISSUER_ID")
    if not issuer_id:
        print("ERROR: Set ASC_ISSUER_ID environment variable")
        print("  Find it at: https://appstoreconnect.apple.com/access/integrations/api")
        print("  Usage: ASC_ISSUER_ID=<id> python3 Scripts/setup_game_center.py")
        sys.exit(1)

    key_id, private_key = find_api_key()
    print(f"Using API key: {key_id}")

    token = generate_token(issuer_id, key_id, private_key)
    headers = make_headers(token)

    # 1. Find app
    app_id = get_app_id(headers)

    # 2. Get/create Game Center detail
    gc_detail_id = get_or_create_gc_detail(headers, app_id)

    # 3. Create leaderboards
    # 3a. If --reset, delete all leaderboards first
    if "--reset" in sys.argv:
        print(f"\n── RESETTING: Deleting all leaderboards (clears scores) ──")
        deleted = delete_all_leaderboards(headers, gc_detail_id)
        print(f"Deleted {deleted} leaderboards")

    existing_lbs = get_existing_leaderboards(headers, gc_detail_id)
    print(f"\n── Creating {len(LEADERBOARDS)} leaderboards ──")
    created_lbs = 0
    for lb in LEADERBOARDS:
        if lb["ref"] in existing_lbs:
            print(f"  Leaderboard '{lb['ref']}' already exists — skipping")
            continue
        result = create_leaderboard(headers, gc_detail_id, lb["ref"], lb["name"])
        if result:
            created_lbs += 1
    print(f"Leaderboards: {created_lbs} created, {len(existing_lbs)} already existed")

    # 4. Create achievements
    existing_achs = get_existing_achievements(headers, gc_detail_id)
    print(f"\n── Creating {len(ACHIEVEMENTS)} achievements ──")
    created_achs = 0
    for ach in ACHIEVEMENTS:
        if ach["ref"] in existing_achs:
            print(f"  Achievement '{ach['ref']}' already exists — skipping")
            continue
        result = create_achievement(
            headers, gc_detail_id, ach["ref"], ach["name"], ach["desc"], ach["points"]
        )
        if result:
            created_achs += 1
    print(f"Achievements: {created_achs} created, {len(existing_achs)} already existed")

    # 5. Upload achievement images (if --upload-images)
    if "--upload-images" in sys.argv:
        IMAGE_DIR = "Screenshots/achievements"
        print(f"\n── Uploading achievement images from {IMAGE_DIR}/ ──")
        loc_map = get_achievement_localizations(headers, gc_detail_id)
        uploaded = 0
        for ach in ACHIEVEMENTS:
            ref = ach["ref"]
            image_path = os.path.join(IMAGE_DIR, f"{ref}.png")
            if not os.path.exists(image_path):
                print(f"  SKIP '{ref}': no image at {image_path}")
                continue
            loc_id = loc_map.get(ref)
            if not loc_id:
                print(f"  SKIP '{ref}': no en-US localization found in ASC")
                continue
            if upload_achievement_image(headers, loc_id, image_path, ref):
                uploaded += 1
        print(f"Images: {uploaded}/{len(ACHIEVEMENTS)} uploaded")

    # 6. Create releases (if --create-releases)
    if "--create-releases" in sys.argv:
        # Re-fetch to get all IDs (including pre-existing ones)
        all_lbs = get_existing_leaderboards(headers, gc_detail_id)
        all_achs = get_existing_achievements(headers, gc_detail_id)

        print(f"\n── Creating leaderboard releases ({len(all_lbs)} leaderboards) ──")
        lb_releases = 0
        for ref, lb_id in all_lbs.items():
            if create_leaderboard_release(headers, gc_detail_id, lb_id, ref):
                lb_releases += 1
        print(f"Leaderboard releases: {lb_releases}/{len(all_lbs)}")

        print(f"\n── Creating achievement releases ({len(all_achs)} achievements) ──")
        ach_releases = 0
        for ref, ach_id in all_achs.items():
            if create_achievement_release(headers, gc_detail_id, ach_id, ref):
                ach_releases += 1
        print(f"Achievement releases: {ach_releases}/{len(all_achs)}")

    # 7. Enable Game Center for current app store version
    print(f"\n── Enabling Game Center for app version ──")
    enable_gc_for_app_version(headers, gc_detail_id, app_id)

    print(f"\n{'='*50}")
    print(f"DONE — {created_lbs} leaderboards + {created_achs} achievements created")
    print(f"Total: {len(LEADERBOARDS)} leaderboards, {len(ACHIEVEMENTS)} achievements")
    print(f"Verify at: https://appstoreconnect.apple.com")


if __name__ == "__main__":
    main()
