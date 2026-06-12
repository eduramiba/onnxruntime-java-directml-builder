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

OpenVINO is a shared execution provider. OpenVINO, DirectML, and TBB DLLs are kept as sidecar files in `dist/<version>` and in the uploaded workflow artifact; they are not bundled into `onnxruntime.jar` because ONNX Runtime Java only extracts its own known native libraries from the jar.
