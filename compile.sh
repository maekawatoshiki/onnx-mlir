#!/bin/bash -eux

source env/bin/activate

# MLIR_DIR must be set with cmake option now
MLIR_DIR=$(pwd)/third_party/llvm-project/build/lib/cmake/mlir

mkdir -p build && cd build

export pythonLocation=$(which python)

cmake -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH="/home/uint/work/protobuf-3.20.3/protobuf;/home/uint/work/protobuf-3.20.3/cmake" \
      -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ \
      -DPython3_ROOT_DIR=$pythonLocation \
      -DMLIR_DIR=${MLIR_DIR} \
      ..

cmake --build .
