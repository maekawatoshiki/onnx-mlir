#!/bin/bash -eux

if [ ! -d llvm-project/build ]; then
    (
    mkdir -p llvm-project/build
    cd llvm-project/build
    cmake -G Ninja ../llvm \
       -DLLVM_ENABLE_PROJECTS=mlir \
       -DLLVM_TARGETS_TO_BUILD="host" \
       -DCMAKE_BUILD_TYPE=Release \
       -DLLVM_ENABLE_ASSERTIONS=ON \
       -DLLVM_ENABLE_RTTI=ON \
       -DLLVM_ENABLE_LIBEDIT=OFF \
       -DLLVM_CCACHE_BUILD=ON
    ninja
    ninja check-mlir
    )
fi

export pythonLocation=$(which python3)
if [ ! -d env ]; then python3 -m venv env; fi
source env/bin/activate

PROTOBUF_VERSION=21.12
if [ ! -d protobuf ]; then
    (
    git clone -b v${PROTOBUF_VERSION} --recursive https://github.com/protocolbuffers/protobuf.git \
        && cd protobuf && ./autogen.sh \
        && CC='ccache gcc' CXX='ccache g++' ./configure --enable-static=no --prefix=$PWD/target \
        && make -j install \
        && cd python && python3 setup.py install --cpp_implementation
    )
fi

MLIR_DIR=$(pwd)/llvm-project/build/lib/cmake/mlir
export LD_LIBRARY_PATH=$(pwd)/protobuf/target/lib:$LD_LIBRARY_PATH
(
mkdir -p build
cd build
cmake -G Ninja .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$PWD/../protobuf/target;$PWD/../protobuf/cmake" \
    -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ \
    -DPython3_ROOT_DIR=$pythonLocation \
    -DMLIR_DIR=${MLIR_DIR} \
    -DCMAKE_CXX_FLAGS=-march=native
cmake --build .

# Run lit tests:
export LIT_OPTS=-v
cmake --build . --target check-onnx-lit
)

