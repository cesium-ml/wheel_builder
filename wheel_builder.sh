#!/bin/bash

set -e

mkdir wheelhouse
rm -rf wheelhouse/*

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    WORK_DIR=$PWD

    curl -OL https://raw.githubusercontent.com/MacPython/terryfy/master/travis_tools.sh
    source travis_tools.sh

    function cpython_path {
        echo "$WORK_DIR/venv_$1"
    }

    mkdir -p unfixed_wheels
    rm -rf unfixed_wheels/*

    for PYTHON in ${PYTHON_VERSIONS}; do
        get_python_environment macpython $PYTHON "$(cpython_path $PYTHON)"
        pip install delocate numpy==$NUMPY_VERSION cython
    done

    source pip_build_wheels.sh

    delocate-listdeps unfixed_wheels/*
    delocate-wheel unfixed_wheels/*.whl
    delocate-addplat --rm-orig -x 10_9 -x 10_10 dist/*.whl
    mv unfixed_wheels/*.whl $WHEELHOUSE

else

    curl -OL https://raw.githubusercontent.com/matthew-brett/manylinux-builds/master/common_vars.sh

    DOCKER_IMAGE=quay.io/pypa/manylinux1_x86_64
    docker pull $DOCKER_IMAGE
    docker run --rm \
           -e PYTHON_VERSIONS="$PYTHON_VERSIONS" \
           -e NUMPY_VERSION="$NUMPY_VERSION" \
           -e CESIUM_VERSIONS="$CESIUM_VERSIONS" \
           -v $PWD:/io $DOCKER_IMAGE /io/build_manylinux.sh
fi
