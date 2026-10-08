#!/bin/bash
# Waits for a dataset to become active.
# Usage: wait_for_dataset.sh DATASET_ID [TIMEOUT]
set -euo pipefail

DATASET_ID="${1:?Usage: wait_for_dataset.sh DATASET_ID [TIMEOUT]}"
TIMEOUT="${2:-120}"
INTERVAL=5
ELAPSED=0

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  STATUS_RESPONSE=$(curl -s "http://localhost:8000/api/v1/xml/data/${DATASET_ID}")
  STATUS=$(echo "$STATUS_RESPONSE" | sed -n 's/.*<oml:status>\([a-zA-Z_]*\)<\/oml:status>.*/\1/p')

  echo "Status after ${ELAPSED}s: ${STATUS:-unknown}"

  if [ "$STATUS" = "active" ]; then
    echo "Dataset $DATASET_ID is active."
    exit 0
  fi

  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "ERROR: Dataset $DATASET_ID did not become active within ${TIMEOUT} seconds."
exit 1
