#!/bin/bash -eux

source env/bin/activate

./build/Release/bin/onnx-mlir -O3 --parallel --EmitLib ~/work/altius/models/mobilenetv3.onnx
OMP_NUM_THREADS=8 LD_LIBRARY_PATH=$PWD/build/Release/lib/ PYTHONPATH=$PWD/build/Release/lib python3 run.py

