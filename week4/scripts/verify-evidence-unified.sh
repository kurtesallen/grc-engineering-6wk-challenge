#!/usr/bin/env bash
set -euo pipefail

FILE="${1:?usage: verify-evidence-unified.sh <evidence-file>}"

SIG_RSA="${FILE}.sig"
SIDE_CAR="${FILE}.sha256"
SIGSTORE_BUNDLE="evidence.sig.bundle"

# ------------------------------------------------------------
# Helper: portable SHA-256 function
# ------------------------------------------------------------
sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "ERROR: No sha256sum or shasum available" >&2
    exit 1
  fi
}

echo "Detecting evidence signature format..."

# ------------------------------------------------------------
# CASE 1 — Week 5 LOCAL RSA SIGNATURE
# ------------------------------------------------------------
if [[ -f "$SIG_RSA" ]]; then
  echo "Detected: Local RSA signature (*.sig)"
  openssl dgst -sha256 -verify key.pem -signature "$SIG_RSA" "$FILE"
  echo "CHAIN INTACT (local RSA)"
  exit 0
fi

# ------------------------------------------------------------
# CASE 2 — Week 4 CI/CD SIGSTORE SIGNATURE
# ------------------------------------------------------------
if [[ -f "$SIDE_CAR" && -f "$SIGSTORE_BUNDLE" ]]; then
  echo "Detected: Sigstore CI/CD signature (*.sha256 + bundle)"

  COMPUTED_HASH="$(sha256 "$FILE")"
  RECORDED_HASH="$(awk '{print $1}' "$SIDE_CAR")"

  if [[ "$COMPUTED_HASH" != "$RECORDED_HASH" ]]; then
    echo "INTEGRITY CHECK FAILED: hash mismatch" >&2
    exit 1
  fi

  if ! cosign verify-blob \
        --bundle "$SIGSTORE_BUNDLE" \
        --certificate-identity-regexp "https://github.com/.*" \
        --certificate-oidc-issuer-regexp "https://token.actions.githubusercontent.com.*" \
        "$FILE" >/dev/null 2>&1; then
    echo "AUTHENTICITY CHECK FAILED: cosign verification failed" >&2
    exit 1
  fi

  echo "CHAIN INTACT (Sigstore CI/CD)"
  exit 0
fi

# ------------------------------------------------------------
# CASE 3 — Unknown format
# ------------------------------------------------------------
echo "ERROR: No recognizable signature format found."
echo "Expected either:"
echo "  - Week 5: <file>.sig"
echo "  - Week 4: <file>.sha256 + evidence.sig.bundle"
exit 1
