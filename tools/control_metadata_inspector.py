# control_metadata_inspector.py
"""
Developer-side helper for inspecting control metadata.

This script does NOT overlap with CI, Terraform, Rego, or evidence automation.
It simply helps developers quickly view control descriptions and requirements.
"""

import sys
import re

CONTROLS = {
    "SC-28": {
        "description": "Protection of Information at Rest",
        "requirements": [
            "AES-256 server-side encryption",
            "Encryption configuration must reference the bucket"
        ]
    },
    "AC-3": {
        "description": "Access Enforcement",
        "requirements": [
            "Block public ACLs",
            "Block public bucket policies",
            "Ignore public ACLs",
            "Restrict public buckets"
        ]
    },
    "CM-6": {
        "description": "Configuration Settings",
        "requirements": [
            "Project tag",
            "Environment tag",
            "ManagedBy tag",
            "ComplianceScope tag"
        ]
    }
}

def normalize_control_id(raw: str) -> str:
    """
    Normalize user input like:
    - sc28
    - SC 28
    - sc-28
    - Sc_28
    Into the canonical form: SC-28
    """
    cleaned = raw.strip().upper()
    cleaned = re.sub(r"[^A-Z0-9]", "", cleaned)  # remove spaces, dashes, underscores
    # cleaned now looks like: SC28 or AC3 or CM6

    # Insert dash between letters and numbers
    match = re.match(r"([A-Z]+)(\d+)", cleaned)
    if match:
        return f"{match.group(1)}-{match.group(2)}"
    return raw  # fallback

def print_control(control_id: str):
    """Print metadata for a specific control."""
    control = CONTROLS.get(control_id)
    if not control:
        print(f"Control '{control_id}' not found.")
        print("Use one of: SC-28, AC-3, CM-6")
        return

    print(f"\nControl: {control_id}")
    print(f"Description: {control['description']}")
    print("Requirements:")
    for req in control["requirements"]:
        print(f" - {req}")

def list_controls():
    """List all available controls."""
    print("Available Controls:")
    for cid in CONTROLS.keys():
        print(f" - {cid}")

def main():
    # No arguments → list controls + show SC-28
    if len(sys.argv) == 1:
        list_controls()
        print_control("SC-28")
        return

    # One argument → treat as control ID
    raw_id = sys.argv[1]
    normalized = normalize_control_id(raw_id)
    print_control(normalized)

if __name__ == "__main__":
    main()
