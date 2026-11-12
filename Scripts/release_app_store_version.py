#!/usr/bin/env python3
"""
Publish an approved App Store version, or report why it cannot be published yet.

  ASC_ISSUER_ID=<issuer-id> python3 Scripts/release_app_store_version.py            # report state only
  ASC_ISSUER_ID=<issuer-id> python3 Scripts/release_app_store_version.py --release  # publish if approved

With --release the version is published only when App Store Connect reports
PENDING_DEVELOPER_RELEASE (approved, held for manual release). In any other
state nothing is changed.

Exit codes: 0 = released, or already live; 3 = not approved yet (run again
later); 1 = error or a state that needs a person (for example REJECTED).

It reads the API key the same way as update_app_store_v230.py and stores nothing.
"""

import argparse
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "Scripts"))

from setup_game_center import generate_token, get_app_id, make_headers  # noqa: E402
from update_app_store_v230 import VERSION, find_api_key, list_versions, request_json  # noqa: E402

LIVE_STATES = {"READY_FOR_SALE", "READY_FOR_DISTRIBUTION", "PROCESSING_FOR_DISTRIBUTION"}
IN_REVIEW_STATES = {"WAITING_FOR_REVIEW", "IN_REVIEW", "READY_FOR_REVIEW", "PREPARE_FOR_SUBMISSION"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", default=VERSION)
    parser.add_argument("--release", action="store_true", help="Publish the version if Apple has approved it")
    args = parser.parse_args()

    issuer_id = os.environ.get("ASC_ISSUER_ID")
    if not issuer_id:
        raise SystemExit("Set ASC_ISSUER_ID in the environment")
    key_id, private_key = find_api_key()
    headers = make_headers(generate_token(issuer_id, key_id, private_key))
    app_id = get_app_id(headers)

    version = next(
        (v for v in list_versions(headers, app_id) if v["attributes"].get("versionString") == args.version),
        None,
    )
    if not version:
        raise SystemExit(f"App Store version {args.version} not found")
    state = version["attributes"].get("appStoreState")
    print(f"Version {args.version}: {state}")

    if state in LIVE_STATES:
        print("Already released")
        return 0
    if state in IN_REVIEW_STATES:
        print("Not approved yet; nothing changed")
        return 3
    if state != "PENDING_DEVELOPER_RELEASE":
        print("This state needs a person to look at it; nothing changed")
        return 1
    if not args.release:
        print("Approved and held for release. Run again with --release to publish.")
        return 3

    body = {
        "data": {
            "type": "appStoreVersionReleaseRequests",
            "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": version["id"]}}},
        }
    }
    request_json(headers, "POST", "/v1/appStoreVersionReleaseRequests", expected=(201,), json=body)
    print(f"Release requested for {args.version}; it becomes available on the App Store within hours")
    return 0


if __name__ == "__main__":
    sys.exit(main())
