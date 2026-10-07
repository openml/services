#!/bin/bash
# Waits until a task has associated split files.
# Usage: wait_for_task.sh TASK_ID [TIMEOUT]
set -euo pipefail

TASK_ID="${1:?Usage: wait_for_task.sh TASK_ID [TIMEOUT]}"
TIMEOUT="${2:-120}"
INTERVAL=5
ELAPSED=0

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  RESPONSE=$(curl -s "http://localhost:8000/api/v1/xml/task/${TASK_ID}")
  SPLITS_URL=$(echo "$RESPONSE" | sed -n 's/.*<oml:data_splits_url>\(.*\)<\/oml:data_splits_url>.*/\1/p')

  if [ -n "$SPLITS_URL" ]; then
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SPLITS_URL")
    if [ "$STATUS_CODE" = "200" ]; then
      echo "Task $TASK_ID has split files available."
      exit 0
    fi
    echo "Splits URL exists but returned HTTP $STATUS_CODE after ${ELAPSED}s"
  else
    echo "No splits URL yet after ${ELAPSED}s"
  fi

  sleep "$INTERVAL"
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "ERROR: Task $TASK_ID did not get split files within ${TIMEOUT} seconds."
exit 1
