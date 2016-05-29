#!/bin/bash

set -ex

mkdir -p wheelhouse tmp
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

    function fake_pip {
        # 'get_python_environment' tries to do
        #   sudo pip uninstall -y pip
        #
        # So, after it has done that once, pip is gone.  This is a workaround to
        # make a fake pip available.

        sudo mkdir -p /usr/local/bin
        echo "echo system pip called with: \$@" | sudo tee /usr/local/bin/pip
        sudo chmod +x /usr/local/bin/pip
        export PATH=/usr/local/bin:$PATH
    }

    for PYTHON in ${PYTHON_VERSIONS}; do
	fake_pip
        get_python_environment macpython $PYTHON "$(cpython_path $PYTHON)"
        source "$(cpython_path $PYTHON)/bin/activate"
        pip install delocate numpy==$NUMPY_VERSION cython virtualenv
        deactivate
    done

    source pip_build_wheels.sh

    read PYTHON _ <<< $PYTHON_VERSIONS
    source "$(cpython_path $PYTHON)/bin/activate"
    delocate-listdeps unfixed_wheels/*
    delocate-wheel unfixed_wheels/*.whl
    delocate-addplat -c --rm-orig -x 10_9 -x 10_10 -x 10_11 unfixed_wheels/*.whl
    mv unfixed_wheels/*.whl wheelhouse

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

# Remove non-cesium wheels
find ./wheelhouse -type f ! -name "cesium*.whl" -delete
