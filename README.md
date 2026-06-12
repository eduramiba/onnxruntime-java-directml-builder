# ONNX Runtime Java DirectML Builder

This repository builds a Windows x64 ONNX Runtime Java jar with DirectML and OpenVINO enabled.

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
- `onnxruntime_providers_shared.dll`

DirectML and OpenVINO support are enabled through the ONNX Runtime build flags:

```cmd
build.bat --config Release --build_java --use_dml --use_openvino CPU --parallel --skip_tests
```

OpenVINO is a shared execution provider. The jar bundles `onnxruntime_providers_openvino.dll`, but the OpenVINO runtime DLLs must also be available at runtime. Use Intel's `setupvars.bat`, put the OpenVINO DLL directory on `PATH`, or run with `-Donnxruntime.native.path=<directory-with-all-native-dlls>`.
