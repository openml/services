#!/bin/bash
# Creates a task for a given dataset and estimation procedure, prints the task ID to stdout.
# Usage: create_task.sh DATASET_ID ESTIMATION_PROCEDURE_ID [TARGET_FEATURE]
set -euo pipefail

DATASET_ID="${1:?Usage: create_task.sh DATASET_ID ESTIMATION_PROCEDURE_ID [TARGET_FEATURE]}"
ESTIMATION_PROCEDURE_ID="${2:?Usage: create_task.sh DATASET_ID ESTIMATION_PROCEDURE_ID [TARGET_FEATURE]}"
TARGET_FEATURE="${3:-class}"

TMPFILE=$(mktemp /tmp/task_desc.XXXXXX.xml)
trap 'rm -f "$TMPFILE"' EXIT

cat > "$TMPFILE" << EOF
<oml:task_inputs xmlns:oml="http://openml.org/openml">
  <oml:task_type_id>1</oml:task_type_id>
  <oml:input name="source_data">${DATASET_ID}</oml:input>
  <oml:input name="estimation_procedure">${ESTIMATION_PROCEDURE_ID}</oml:input>
  <oml:input name="target_feature">${TARGET_FEATURE}</oml:input>
</oml:task_inputs>
EOF

RESPONSE=$(curl -s -X POST "http://localhost:8000/api/v1/xml/task?api_key=normaluser" \
  -F "description=@${TMPFILE};type=text/xml")

TASK_ID=$(echo "$RESPONSE" | sed -n 's/.*<oml:id>\([0-9]*\)<\/oml:id>.*/\1/p')

if [ -z "$TASK_ID" ]; then
  echo "Server response:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$TASK_ID"
