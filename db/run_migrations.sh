#!/bin/bash

cat <<EOF > dbconf.yml
development:
    driver: postgres
    open: user=${DB_USERNAME} password=${DB_PASSWORD} dbname=job_postings sslmode=disable
EOF

goose up