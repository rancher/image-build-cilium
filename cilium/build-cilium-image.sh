#!/bin/bash

set -o xtrace
set -o errexit
set -o pipefail
set -o nounset

dir=$(dirname "${0}")
BUILD_META=$1
TAG=$2
ARCH=$3
ORG=$4

git clone --branch ${TAG%"${BUILD_META}"} https://github.com/cilium/cilium.git $dir/cilium

pushd $dir/cilium/

git apply ../../../patches/*

docker build \
  --pull \
  --build-arg COMPILERS_IMAGE=rancher/hardened-cilium-compilers:4c18d06f1d545ed6fde810c2b97935dc8938ddc8-build20210521 \
  --build-arg CILIUM_RUNTIME=rancher/hardened-cilium-runtime:${TAG} \
  --build-arg CILIUM_BUILDER=rancher/hardened-cilium-builder:${TAG} \
  --build-arg CILIUM_SHA=${TAG%"${BUILD_META}"} \
  --tag ${ORG}/hardened-cilium-cilium:${TAG} \
  --tag ${ORG}/hardened-cilium-cilium:${TAG}-${ARCH} \
.
