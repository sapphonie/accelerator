#!/bin/sh
set -ex

cd third_party/breakpad
git reset --hard
git apply ../../patches/*.patch

cd src/third_party
ln -sf ../../../protobuf protobuf
ln -sf ../../../lss lss