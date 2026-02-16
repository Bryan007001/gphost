#!/bin/bash
set -e -x

cat lyasper-sshd-centos7.tar.gz.part_* > lyasper-sshd-centos7.tar.gz
docker image load -i ./lyasper-sshd-centos7.tar.gz
rm -f lyasper-sshd-centos7.tar.gz

cat rpms.tar.gz.part_* > rpms.tar.gz
docker build . -t lyasper/gphost
rm -f rpms.tar.gz
