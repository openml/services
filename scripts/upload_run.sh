#!/bin/bash
# Uploads a run to the REST API and prints the run ID to stdout.
# The predictions and description files are fixed in scripts/data/run/.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RESPONSE=$(curl -s -X POST "http://localhost:8000/api/v1/xml/run?api_key=normaluser" \
  -F "description=@${SCRIPT_DIR}/data/run/description.xml;type=text/xml" \
  -F "predictions=@${SCRIPT_DIR}/data/run/predictions.arff")

RUN_ID=$(echo "$RESPONSE" | sed -n 's/.*<oml:id>\([0-9]*\)<\/oml:id>.*/\1/p')

if [ -z "$RUN_ID" ]; then
  echo "Server response:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$RUN_ID"
