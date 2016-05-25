#!/bin/bash

set -e

for PYTHON in ${PYTHON_VERSIONS}; do
    PIP="$(cpython_path $PYTHON)/bin/pip"
    for CESIUM in ${CESIUM_VERSIONS}; do
        echo "Building cesium $CESIUM for Python $PYTHON"

        pip install -w tmp "numpy==$NUMPY_VERSION"

        pip wheel -f tmp -w unfixed_wheels \
            --no-binary cesium \
            "numpy==$NUMPY_VERSION" \
            "cesium==$CESIUM_VERSION"
    done
done
