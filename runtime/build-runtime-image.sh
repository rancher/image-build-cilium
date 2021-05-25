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

cp $dir/centos.repo $dir/cilium/images/runtime/ && pushd $dir/cilium/images/runtime/

git apply ../../../patches/*

docker build \
  --pull \
  --build-arg COMPILERS_IMAGE=rancher/hardened-cilium-compilers:4c18d06f1d545ed6fde810c2b97935dc8938ddc8-build20210521 \
  --build-arg CILIUM_LLVM_IMAGE=rancher/hardened-cilium-llvm:4c18d06f1d545ed6fde810c2b97935dc8938ddc8-build20210521 \
  --build-arg CILIUM_BPFTOOL_IMAGE=rancher/hardened-cilium-bpftool:4c18d06f1d545ed6fde810c2b97935dc8938ddc8-build20210521 \
  --build-arg CILIUM_IPROUTE2_IMAGE=rancher/hardened-cilium-iproute2:4c18d06f1d545ed6fde810c2b97935dc8938ddc8-build20210521 \
  --tag ${ORG}/hardened-cilium-runtime:${TAG} \
  --tag ${ORG}/hardened-cilium-runtime:${TAG}-${ARCH} \
.
