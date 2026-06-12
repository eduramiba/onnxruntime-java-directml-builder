GROUP_ID := io.github.eduramiba
ARTIFACT_ID := onnxruntime-extra-providers
VERSION ?= 1.26.0

DIST_DIR := dist/$(VERSION)
JAR ?= $(DIST_DIR)/onnxruntime.jar
PWRSH := pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -Command

.PHONY: install deploy clean check list

install: check
	mvn install

deploy: check
	mvn deploy -Pdeployment

check:
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)' -PathType Container)) { throw 'Directory not found: $(DIST_DIR)' }"
	$(PWRSH) "if (-not (Test-Path '$(JAR)' -PathType Leaf)) { throw 'Jar not found: $(JAR)' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/onnxruntime-sources.jar' -PathType Leaf)) { throw 'Sources jar not found' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/onnxruntime-javadoc.jar' -PathType Leaf)) { throw 'Javadoc jar not found' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/DirectML.dll' -PathType Leaf)) { throw 'DirectML.dll sidecar not found' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/onnxruntime_providers_openvino.dll' -PathType Leaf)) { throw 'onnxruntime_providers_openvino.dll sidecar not found' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/openvino.dll' -PathType Leaf)) { throw 'openvino.dll sidecar not found' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/openvino_intel_cpu_plugin.dll' -PathType Leaf)) { throw 'openvino_intel_cpu_plugin.dll sidecar not found' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/tbb12.dll' -PathType Leaf)) { throw 'tbb12.dll sidecar not found' }"
	$(PWRSH) "jar tf '$(JAR)' | Out-Null"
	$(PWRSH) "if (jar tf '$(JAR)' | Select-String 'ai/onnxruntime/native/win-x64/DirectML.dll') { throw 'DirectML.dll should be a sidecar DLL, not bundled in jar' }"
	$(PWRSH) "if (jar tf '$(JAR)' | Select-String 'ai/onnxruntime/native/win-x64/openvino.dll') { throw 'openvino.dll should be a sidecar DLL, not bundled in jar' }"
	$(PWRSH) "if (jar tf '$(JAR)' | Select-String 'ai/onnxruntime/native/win-x64/openvino_intel_cpu_plugin.dll') { throw 'openvino_intel_cpu_plugin.dll should be a sidecar DLL, not bundled in jar' }"
	$(PWRSH) "if (jar tf '$(JAR)' | Select-String 'ai/onnxruntime/native/win-x64/tbb12.dll') { throw 'tbb12.dll should be a sidecar DLL, not bundled in jar' }"
	$(PWRSH) "Write-Host 'Coordinates: $(GROUP_ID):$(ARTIFACT_ID):$(VERSION)'"
	$(PWRSH) "Write-Host 'Dist dir: $(DIST_DIR)'"

list:
	pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "Get-ChildItem -Recurse dist | Select-Object FullName, Length"

clean:
	mvn clean
	$(PWRSH) "if (Test-Path '$(DIST_DIR)/generated-pom.xml') { Remove-Item -Force '$(DIST_DIR)/generated-pom.xml' }"
