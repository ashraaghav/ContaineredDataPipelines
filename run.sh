#!/bin/bash

echo "Start containers..."
docker start postgres
docker start mongodb


echo "STEP 1: Copy data into the SQL database"
# copy file into docker
docker cp -a ./sample_data postgres:/docker-entrypoint-initdb.d/sample_data

# create schema and database
docker cp ./copyfile.sql postgres:/docker-entrypoint-initdb.d/copyfile.sql
docker exec -u postgres postgres psql -U analyst -d datastore -f /docker-entrypoint-initdb.d/copyfile.sql

echo "STEP 2: Run python script to calculate KPIs and store in NOSQL database"
# conda is not initialized for sub-shells
eval "$(conda shell.bash hook)"
conda activate conenv
cd python && python analyze.py --config ./config.json
