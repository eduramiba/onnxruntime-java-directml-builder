GROUP_ID := io.github.eduramiba
ARTIFACT_ID := onnxruntime-directml
VERSION ?= 1.26.0

DIST_DIR := dist/$(VERSION)
JAR ?= $(DIST_DIR)/onnxruntime.jar
DML_DLL ?= $(DIST_DIR)/DirectML.dll

PWRSH := pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -Command

.PHONY: install deploy clean check list bundle-dml

install: bundle-dml check
	mvn install

deploy: bundle-dml check
	mvn deploy -Pdeployment

bundle-dml:
	pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -File bundle-dml.ps1 -JarPath "$(JAR)" -DmlDllPath "$(DML_DLL)"

check:
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)' -PathType Container)) { throw 'Directory not found: $(DIST_DIR)' }"
	$(PWRSH) "if (-not (Test-Path '$(JAR)' -PathType Leaf)) { throw 'Jar not found: $(JAR)' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/onnxruntime-sources.jar' -PathType Leaf)) { throw 'Sources jar not found' }"
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)/onnxruntime-javadoc.jar' -PathType Leaf)) { throw 'Javadoc jar not found' }"
	$(PWRSH) "jar tf '$(JAR)' | Out-Null"
	$(PWRSH) "if (-not (jar tf '$(JAR)' | Select-String 'DirectML.dll')) { throw 'DirectML.dll not bundled in jar! Run: make bundle-dml' }"
	$(PWRSH) "Write-Host 'Coordinates: $(GROUP_ID):$(ARTIFACT_ID):$(VERSION)'"
	$(PWRSH) "Write-Host 'Dist dir: $(DIST_DIR)'"

list:
	pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "Get-ChildItem -Recurse dist | Select-Object FullName, Length"

clean:
	mvn clean
	$(PWRSH) "if (Test-Path '$(DIST_DIR)/generated-pom.xml') { Remove-Item -Force '$(DIST_DIR)/generated-pom.xml' }"
