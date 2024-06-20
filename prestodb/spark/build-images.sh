#!/bin/bash

set -e

VERSION=3.5.1

docker build -t prestodb/spark-base:$VERSION ./spark-base
docker build -t prestodb/spark-master:$VERSION ./spark-master
docker build -t prestodb/spark-worker:$VERSION ./spark-worker
docker build -t prestodb/spark-submit:$VERSION ./spark-submit
