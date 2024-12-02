#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd -P)
IMAGE_FILE=${IMAGE_FILE:-"vcuda:latest"}

function cleanup() {
  rm -rf ${ROOT}/build
}

trap cleanup EXIT SIGTERM SIGINT


function build_img() {
    readonly local commit=$(git log --oneline | wc -l | sed -e 's,^[ \t]*,,')
    readonly local version=$(<"${ROOT}/VERSION")

    rm -rf ${ROOT}/build
    mkdir ${ROOT}/build
    cp -r `ls ./ | grep -v build | xargs` build
    (
      cd ${ROOT}/build
      docker build ${BUILD_FLAGS:-} --build-arg version=${version} --build-arg commit=${commit} -t ${IMAGE_FILE} .
    )
}

build_img
