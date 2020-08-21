#!/bin/bash

set -e

docker build -t gbieul/spark-base:2.4 ./docker/spark-base
docker build -t gbieul/spark-master:2.4 ./docker/spark-master
docker build -t gbieul/spark-worker:2.4 ./docker/spark-worker