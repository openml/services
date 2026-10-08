#!/bin/bash
# Tests the dataset upload and processing of the REST API and Evaluation Engine
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DATASET_ID=$("${SCRIPT_DIR}/upload_dataset.sh")
echo "Uploaded dataset with ID: $DATASET_ID"

"${SCRIPT_DIR}/wait_for_dataset.sh" "$DATASET_ID"
