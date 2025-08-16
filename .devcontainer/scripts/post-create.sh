#!/usr/bin/env bash

set -euo pipefail

echo "creating project structure for $PROJECT"

mkdir -p spark/data
mkdir -p spark/src
mkdir -p minio/minio_data
mkdir -p minio/minio_test
mkdir -p $PROJECT

if pip3 show $PROJECT &>/dev/null; then
    echo "Installed"
else
    echo "setting up python venv and installing requirements"
    source scripts/setup-venv.sh
    echo "creating python environment and installing core packages"
    ls -la
    pip3 install -r .devcontainer/requirements.txt
fi

echo "Checking if $PROJECT directory exists"
if [ -d "$PROJECT" ]; then
    echo "Directory $PROJECT found. Skipping crewai creation"
else
    python3 scripts/setup-crewai.py $PROJECT
fi

echo "Checking if docker network $NETWORK exists"
if docker network inspect $NETWORK > /dev/null 2>&1; then
    echo "Network $NETWORK already exists"
else
    echo "Create docker network $NETWORK"
    docker network create -d bridge $NETWORK
fi

echo "Checking if minio docker container exists"
if docker container inspect minio > /dev/null 2>&1; then
    echo "Container minio already exists"
else
    echo "Creating docker container for minio and starting the container"
    docker run -d \
        -h minio \
        --mount type=bind,src=./minio/minio_data,dst=/data \
        -e MINIO_ROOT_USER=$MINIO_USER \
        -e MINIO_ROOT_PASSWORD=$MINIO_PASSWORD\
        -e MINIO_DEFAULT_BUCKETS=$DEFAULT_BUCKET \
        -p "$MINIO_PORT:9000" \
        -p "$MINIO_PORT_2:9001" \
        --network $NETWORK \
    quay.io/minio/minio server /data --console-address ":9001"
fi

echo "Checking if spark docker container exists"
if docker container inspect spark > /dev/null 2>&1; then
    echo "Container spark already exists"
else
    echo "Creating docker container and starting spark"
    docker run -d \
        -h spark-main \
        --mount type=bind,src=./spark/data,dst=/data \
        --mount type=bind,src=./spark/src,dst=/src \
        -e SPARK_MODE=master \
        -p '8095:8095' \
        -p '4041:4041' \
        -p '7074:7074' \
    docker.io/bitnami/spark:3.3

    docker run -d \
        -h spark-worker \
        --mount type=bind,src=./spark/data,dst=/data \
        --mount type=bind,src=./spark/src,dst=/src \
        -e SPARK_MODE=worker \
        -e SPARK_MASTER_URL=spark://spark:7074 \
        -e SPARK_WORKER_MEMORY=4G \
        -e SPARK_EXECUTOR_MEMORY=4G \
        -e SPARK_WORKER_CORES=4 \
    docker.io/bitnami/spark:3.3
fi