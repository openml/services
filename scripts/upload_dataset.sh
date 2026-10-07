#!/bin/bash
# Uploads a dataset to the REST API and prints the dataset ID to stdout.
set -euo pipefail

XML_DESCRIPTION='<oml:data_set_description xmlns:oml="http://openml.org/openml">
	<oml:name>test_dataset</oml:name>
	<oml:description>test</oml:description>
	<oml:format>arff</oml:format>
	<oml:creator>I</oml:creator>
	<oml:collection_date>now</oml:collection_date>
	<oml:language>en</oml:language>
	<oml:licence>BSD (from scikit-learn)</oml:licence>
	<oml:default_target_attribute>class</oml:default_target_attribute>
	<oml:version_label>test</oml:version_label>
	<oml:citation>citation</oml:citation>
	<oml:original_data_url>https://www4.stat.ncsu.edu/~boos/var.select/diabetes.html</oml:original_data_url>
	<oml:paper_url>url</oml:paper_url>
</oml:data_set_description>'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RESPONSE=$(curl -s -X POST "http://localhost:8000/api/v1/xml/data?api_key=normaluser" \
  -F "description=<-;type=text/xml" <<< "${XML_DESCRIPTION}" \
  -F "dataset=@${SCRIPT_DIR}/data/test.arff")

DATASET_ID=$(echo "$RESPONSE" | sed -n 's/.*<oml:id>\([0-9]*\)<\/oml:id>.*/\1/p')

if [ -z "$DATASET_ID" ]; then
  echo "ERROR: Failed to parse dataset ID from response:" >&2
  echo "$RESPONSE" >&2
  exit 1
fi

echo "$DATASET_ID"
