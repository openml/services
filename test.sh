#!/bin/bash
# This test assumes services are running locally:
# `docker compose --profile all up -d`
# 
# It tests some of the most important services, but is by no means comprehensive.
# In particular, also at least check the frontpage in a browser (http://localhost:8000).

set -e

assert_contains() {
  if echo "$1" | grep --ignore-case -q "$2"; then
    echo "PASS: output contains '$2'"
  else
    echo "FAIL: output does not contain '$2'"
    echo "Full output:"
    echo "$1"
    exit 1
  fi
}

assert_url_exists() {
  if curl --output /dev/null --silent --head --fail --location "$1"; then
    echo "PASS: $1 exists"
  else
    echo "FAIL: $1 does not exist"
    exit 1
  fi
}

# nginx redirects request to the home page
HOME_PAGE=$(curl -s http://localhost:8000)
assert_contains "$HOME_PAGE" "OpenML is an open platform for sharing datasets"

DATASET_URL=http://localhost:8000/minio/datasets/0000/0020/dataset_37_diabetes.arff
DESCRIPTION_URL=http://localhost:8000/api/v1/json/data/20

# The JSON response may contain escaped slashes (e.g. http:\/\/), so strip them
DESCRIPTION=$(curl -s "$DESCRIPTION_URL" | sed 's/\\//g')
assert_contains "$DESCRIPTION" "diabetes"

wget "$DATASET_URL" -O dataset.arff
assert_contains "$(cat dataset.arff)" "@data"
rm dataset.arff

if [ -d .venv ]; then
  echo "Using existing virtual environment for dataset upload."
else
  echo "Creating virtual environment for dataset upload."
  python -m venv .venv
  source .venv/bin/activate
  python -m pip install uv
  uv pip install openml numpy
fi

echo "Attempting dataset upload"

DATA_ID=$(.venv/bin/python -c "
import numpy as np
import openml
from openml.datasets import create_dataset

openml.config.server = 'http://localhost:8000/api/v1/xml'
openml.config.apikey = 'normaluser'

data = np.array([[1, 2, 3], [1.2, 2.5, 3.8], [2, 5, 8], [0, 1, 0]]).T
attributes = [('col_' + str(i), 'REAL') for i in range(data.shape[1])]

dataset = create_dataset(
    name='test-data',
    description='Synthetic dataset created from a NumPy array',
    creator='OpenML tester',
    contributor=None,
    collection_date='01-01-2018',
    language='English',
    licence='MIT',
    default_target_attribute='col_' + str(data.shape[1] - 1),
    row_id_attribute=None,
    ignore_attribute=None,
    citation='None',
    attributes=attributes,
    data=data,
    version_label='test',
    original_data_url='http://openml.github.io/openml-python',
    paper_url='http://openml.github.io/openml-python',
)
dataset.publish()
print(dataset.id)
")

# Make sure DATA_ID is an integer, and not some Python error output
if ! echo "$DATA_ID" | grep -q '^[0-9]\+$'; then
  echo "FAIL: DATA_ID is not an integer: '$DATA_ID'"
  exit 1
fi

NEW_DATASET_URL=$(curl -s http://localhost:8000/api/v1/json/data/169 | jq -r ".data_set_description.url")
assert_url_exists "$NEW_DATASET_URL"
wget "$NEW_DATASET_URL" -O new_dataset.arff
assert_contains "$(cat new_dataset.arff)" "@data"
rm new_dataset.arff

# Wait for the dataset to become active, polling every 10 seconds for up to 2 minutes
WAITED=0
while [ "$WAITED" -lt 120 ]; do
  DATASET_STATUS=$(curl -s "http://localhost:8000/api/v1/json/data/${DATA_ID}")
  if echo "$DATASET_STATUS" | grep -q "active"; then
    echo "PASS: dataset $DATA_ID is active (after ${WAITED}s)"
    break
  fi
  echo "Waiting for dataset $DATA_ID to become active... (${WAITED}s elapsed)"
  sleep 10
  WAITED=$((WAITED + 10))
done

if [ "$WAITED" -ge 120 ]; then
  echo "FAIL: dataset $DATA_ID did not become active within 120s"
  echo "Full output:"
  echo "$DATASET_STATUS"
  exit 1
fi

echo "Checking parquet conversion"
PADDED_ID=$(printf "%04d" "$DATA_ID")
NEW_PARQUET_URL="http://localhost:8000/minio/datasets/0000/${PADDED_ID}/dataset_${DATA_ID}.pq"
wget "$NEW_PARQUET_URL" 
DATA_SHAPE=$(.venv/bin/python -c "import pandas as pd; df = pd.read_parquet(\"dataset_${DATA_ID}.pq\"); print(df.shape)")
assert_contains "${DATA_SHAPE}" "(3, 4)"
rm "dataset_${DATA_ID}.pq"

CROISSANT_URL="http://localhost:8000/croissant/dataset/${DATA_ID}"
CROISSANT_STATUS=$(curl --silent --output /dev/null --write-out "%{http_code}" "$CROISSANT_URL")
if [ "$CROISSANT_STATUS" = "200" ]; then
  echo "PASS: $CROISSANT_URL exists (HTTP $CROISSANT_STATUS)"
else
  echo "FAIL: $CROISSANT_URL returned HTTP $CROISSANT_STATUS"
  exit 1
fi

ES_RESPONSE=$(curl -s "http://localhost:8000/es/data/_doc/${DATA_ID}")
assert_contains "$ES_RESPONSE" "test-data"
