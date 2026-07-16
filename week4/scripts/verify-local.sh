#!/usr/bin/env bash
set -euo pipefail

FILE="$1"
SIG="${FILE}.sig"

if [[ ! -f "$FILE" ]]; then
  echo "Evidence file not found: $FILE"
  exit 1
fi

if [[ ! -f "$SIG" ]]; then
  echo "Signature file not found: $SIG"
  exit 1
fi

openssl dgst -sha256 -verify key.pem -signature "$SIG" "$FILE"
echo "Verified OK"
