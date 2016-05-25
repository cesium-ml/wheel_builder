git clone https://github.com/matthew-brett/manylinux-builds

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    source ./build_osx.sh
else
    DOCKER_IMAGE=quay.io/pypa/manylinux1_x86_64
    docker pull $DOCKER_IMAGE
    docker run --rm -e PYTHON_VERSIONS="$PYTHON_VERSIONS" -v $PWD:/io $DOCKER_IMAGE /io/build_manylinux.sh
fi
