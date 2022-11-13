#!/bin/bash

# start PostgreSQL container
echo "**************************"
echo "***     PostgreSQL     ***"
echo "**************************"

echo "Start container..."
docker pull postgres:alpine
docker run --name postgres --env-file .pgenv -p 5432:5432 -d postgres:alpine

# wait until for the postgres server to be available
until docker exec -u postgres postgres psql -U "postgres" -c '\q'; do
  echo "Postgres is unavailable - sleeping..."
  sleep 1
done

echo "Postgres is up - executing command"

# initialize database and user
echo "Setup database and user..."
docker cp ./init_pg.sql postgres:/docker-entrypoint-initdb.d/init_pg.sql
docker exec -u postgres postgres psql -U "postgres" -f /docker-entrypoint-initdb.d/init_pg.sql

# start MongoDB container
echo "**************************"
echo "***      MongoDB       ***"
echo "**************************"

echo "Start container..."
docker pull mongo:latest
docker run --name mongodb -p 27017:27017 --env-file .mongoenv -d mongo

# initialize database and user
echo "Setup database and user..."
docker cp ./init_mongo.sh mongodb:/docker-entrypoint-initdb.d/init_mongo.sh
docker exec -u mongodb mongodb sh /docker-entrypoint-initdb.d/init_mongo.sh

# setup python environment
echo "**************************"
echo "***       Python       ***"
echo "**************************"

echo "Setup python conda environment..."
conda env create -f pyenv.yml  || conda env update -f pyenv.yml
export CONDA_BASE=$(conda info --base)
