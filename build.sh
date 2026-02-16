#!/bin/bash
set -e -x

docker image load -i ./lyasper-sshd-centos7.tar.gz
docker build . -t lyasper/gphost
