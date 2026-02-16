#!/bin/bash
set -e -x

docker build . -t gpdb6

docker-compose up -d
