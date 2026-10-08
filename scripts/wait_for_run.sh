#!/bin/bash
# Waits until a run has evaluations computed by the evaluation engine.
# Usage: wait_for_run.sh RUN_ID [TIMEOUT]
set -euo pipefail

RUN_ID="${1:?Usage: wait_for_run.sh RUN_ID [TIMEOUT]}"
TIMEOUT="${2:-120}"
INTERVAL=5
ELAPSED=0

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  RESPONSE=$(curl -s "http://localhost:8000/api/v1/xml/run/${RUN_ID}")

  if echo "$RESPONSE" | grep -q "area_under_roc_curve"; then
    echo "Run $RUN_ID has evaluations."
    exit 0
  fi

  echo "No evaluations yet after ${ELAPSED}s"

  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "ERROR: Run $RUN_ID did not get evaluations within ${TIMEOUT} seconds."
exit 1
