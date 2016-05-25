#!/bin/bash

set -e

for PYTHON in ${PYTHON_VERSIONS}; do
    PIP="$(cpython_path $PYTHON)/bin/pip"
    for CESIUM in ${CESIUM_VERSIONS}; do
        echo "Building cesium $CESIUM for Python $PYTHON"

        $PIP install -f tmp "numpy==$NUMPY_VERSION"

        $PIP wheel -f tmp -w unfixed_wheels \
            --no-binary cesium \
            "numpy==$NUMPY_VERSION" \
            "cesium==$CESIUM"
    done
done
