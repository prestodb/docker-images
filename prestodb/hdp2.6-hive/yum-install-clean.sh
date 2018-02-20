#!/usr/bin/env bash

set -euo pipefail

yum install -y "$@" && yum -y clean all && rm -rf /tmp/* /var/tmp/*
