#!/bin/bash

set -euxo pipefail
pwd
ls -la
mkdir /accelerator
cp -rT /accelerator "$(pwd)"
cd /accelerator
pwd
bash ./cicd/_accelerator_docker_build_internal.sh
