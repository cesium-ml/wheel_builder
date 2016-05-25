#!/bin/bash

set -ex

export IO_PATH=$PWD  # Used by common_vars to determine wheelhouse
source common_vars.sh

curl -OL https://raw.githubusercontent.com/MacPython/terryfy/master/travis_tools.sh
source travis_tools.sh

function cpython_path {
    echo "/venv-$1"
}

rm_mkdir unfixed_wheels

for PYTHON in ${PYTHON_VERSIONS}; do
    get_python_environment macpython $PYTHON "$(cpython_path $PYTHON)"
    pip install delocate numpy==$NUMPY_VERSION cython
}

source pip_build_wheels.sh

delocate-listdeps unfixed_wheels/*
delocate-wheel unfixed_wheels/*.whl
delocate-addplat --rm-orig -x 10_9 -x 10_10 dist/*.whl
mv unfixed_wheels/*.whl $WHEELHOUSE
