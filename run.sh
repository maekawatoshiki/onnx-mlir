#!/bin/bash -eux

source env/bin/activate

# ./build/Release/bin/onnx-mlir -O3 --EmitLib ~/work/altius/models/mobilenetv3.onnx
LD_LIBRARY_PATH=$PWD/build/Release/lib/ PYTHONPATH=$PWD/build/Release/lib python3 run.py

