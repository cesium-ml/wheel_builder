#!/bin/bash

set -e

source /io/manylinux-builds/common_vars.sh

git clone --depth=1 https://github.com/MacPython/terryfy.git
source terryfy/travis_tools.sh

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
