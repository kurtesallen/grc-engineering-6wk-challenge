#!/usr/bin/env bash
# verify-evidence.sh <bundle.tar.gz>
# Verifies integrity, authenticity, and (optional) preservation.
set -euo pipefail

BUNDLE="${1:?usage: verify-evidence.sh <bundle.tar.gz>}"

SIDE_CAR="${BUNDLE}.sha256"
SIG_BUNDLE="evidence.sig.bundle"

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

# ------------------------------------------------------------
# 1. INTEGRITY — hash must match sidecar
# ------------------------------------------------------------
if [[ ! -f "$SIDE_CAR" ]]; then
  echo "INTEGRITY CHECK FAILED: missing sidecar $SIDE_CAR" >&2
  exit 1
fi

COMPUTED_HASH="$(sha256 "$BUNDLE")"
RECORDED_HASH="$(awk '{print $1}' "$SIDE_CAR")"

if [[ "$COMPUTED_HASH" != "$RECORDED_HASH" ]]; then
  echo "INTEGRITY CHECK FAILED: hash mismatch (tampering detected)" >&2
  exit 1
fi

# ------------------------------------------------------------
# 2. AUTHENTICITY — cosign verify-blob (GitHub keyless)
# ------------------------------------------------------------
if [[ ! -f "$SIG_BUNDLE" ]]; then
  echo "AUTHENTICITY CHECK FAILED: missing signature bundle $SIG_BUNDLE" >&2
  exit 1
fi

# Accept any GitHub repo identity + any workflow + any branch/PR
# Accept any valid GitHub OIDC issuer
if ! cosign verify-blob \
      --bundle "$SIG_BUNDLE" \
      --certificate-identity-regexp "https://github.com/.*" \
      --certificate-oidc-issuer-regexp "https://token.actions.githubusercontent.com.*" \
      "$BUNDLE" >/dev/null 2>&1; then
  echo "AUTHENTICITY CHECK FAILED: cosign verification failed" >&2
  exit 1
fi

# ------------------------------------------------------------
# 3. PRESERVATION (optional)
# Requires: VAULT_OBJECT_URL="s3://bucket/key"
# ------------------------------------------------------------
if [[ -n "${VAULT_OBJECT_URL:-}" ]]; then
  BUCKET="${VAULT_OBJECT_URL#s3://}"
  BUCKET="${BUCKET%%/*}"
  KEY="${VAULT_OBJECT_URL#s3://*/}"

  RETENTION_JSON="$(aws s3api get-object-retention --bucket "$BUCKET" --key "$KEY")"
  RETAIN_UNTIL="$(echo "$RETENTION_JSON" | jq -r '.Retention.RetainUntilDate')"

  NOW_EPOCH="$(date -u +%s)"
  RETAIN_EPOCH="$(date -u -d "$RETAIN_UNTIL" +%s)"

  if (( RETAIN_EPOCH <= NOW_EPOCH )); then
    echo "PRESERVATION CHECK FAILED: retention expired" >&2
    exit 1
  fi
fi

echo "CHAIN INTACT"
