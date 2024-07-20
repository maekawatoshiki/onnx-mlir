import json
import os
import time

import numpy as np
from PyRuntime import OMExecutionSession as ExecutionSession


def run_inference(model_path):
    session = ExecutionSession(model_path)
    input_sig_json = json.loads(session.input_signature())
    output_sig_json = json.loads(session.output_signature())

    input_dims = input_sig_json[0]["dims"]
    input_dims = [1 if dim == -1 else dim for dim in input_dims]
    input = np.zeros(shape=input_dims, dtype=np.dtype(np.float32))

    timings = []
    for _ in range(10):
        start_time = time.time()
        _ = session.run([input])
        timings.append(time.time() - start_time)
    print(f"Average inference time: {np.mean(timings) * 1000.0:.2f} ms")


if __name__ == "__main__":
    run_inference("../altius/models/mobilenetv3.so")
