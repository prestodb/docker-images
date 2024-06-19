#!/bin/bash

set -e

VERSION=3.5.1

docker build -t spark-base:$VERSION ./spark-base
docker build -t spark-master:$VERSION ./spark-master
docker build -t spark-worker$VERSION ./spark-worker
docker build -t spark-submit:$VERSION ./spark-submit
