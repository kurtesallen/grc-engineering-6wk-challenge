#!/usr/bin/env bash

# Usage: ./sign-evidence.sh <file>
FILE="$1"

if [ -z "$FILE" ]; then
  echo "Error: No file provided."
  echo "Usage: ./sign-evidence.sh <file>"
  exit 1
fi

openssl dgst -sha256 -sign key.pem -out "${FILE}.sig" "$FILE"

echo "Signed: ${FILE}.sig"
