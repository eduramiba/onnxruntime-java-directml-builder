# ONNX Runtime Java DirectML Builder

This repository builds a Windows x64 ONNX Runtime Java jar with DirectML enabled.

## Build

Go to:

Actions → Build ONNX Runtime Java DirectML → Run workflow

Default inputs:

- `ort_ref`: `v1.26.0`
- `build_config`: `Release`

The workflow uploads an artifact containing:

- `onnxruntime-*.jar`
- any collected native DLLs
- `SHA256SUMS.txt`

## Expected jar contents

The built jar should contain at least:

- `onnxruntime.dll`
- `onnxruntime4j_jni.dll`

DirectML support is enabled through the ONNX Runtime build flag:

```cmd
build.bat --config Release --build_java --use_dml --parallel --skip_tests
```