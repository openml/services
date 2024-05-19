#!/bin/bash

/usr/local/bin/python /app/openml_croissant/scripts/generate_croissants.py \
    --latest \
    -c \
    -o /home/unprivileged-user/output


/usr/local/bin/python /app/openml_croissant/scripts/upload_datasets_to_minio.py \
    -i /home/unprivileged-user/output
