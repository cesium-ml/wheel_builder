#!/bin/bash
set -e

source /io/common_vars.sh
rm_mkdir unfixed_wheels

source /io/pip_build_wheels.sh

repair_wheelhouse unfixed_wheels $WHEELHOUSE
