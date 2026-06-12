GROUP_ID := io.github.eduramiba
ARTIFACT_ID := onnxruntime-directml
VERSION ?= 1.26.0
PACKAGING := jar

DIST_DIR := dist/$(VERSION)
JAR ?= $(DIST_DIR)/onnxruntime.jar
POM := $(DIST_DIR)/generated-pom.xml

MVN := mvn

SHELL := pwsh
.SHELLFLAGS := -NoProfile -ExecutionPolicy Bypass -Command

.PHONY: install deploy pom clean check list

install: check pom
	$(MVN) install:install-file `
		-Dfile="$(JAR)" `
		-DgroupId="$(GROUP_ID)" `
		-DartifactId="$(ARTIFACT_ID)" `
		-Dversion="$(VERSION)" `
		-Dpackaging="$(PACKAGING)" `
		-DpomFile="$(POM)"

deploy: check pom
	if ([string]::IsNullOrWhiteSpace("$(REPOSITORY_ID)")) { throw "Missing REPOSITORY_ID" }
	if ([string]::IsNullOrWhiteSpace("$(REPOSITORY_URL)")) { throw "Missing REPOSITORY_URL" }
	$(MVN) deploy:deploy-file `
		-Dfile="$(JAR)" `
		-DgroupId="$(GROUP_ID)" `
		-DartifactId="$(ARTIFACT_ID)" `
		-Dversion="$(VERSION)" `
		-Dpackaging="$(PACKAGING)" `
		-DpomFile="$(POM)" `
		-DrepositoryId="$(REPOSITORY_ID)" `
		-Durl="$(REPOSITORY_URL)"

pom:
	New-Item -ItemType Directory -Force -Path "$(DIST_DIR)" | Out-Null
	@'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>$(GROUP_ID)</groupId>
  <artifactId>$(ARTIFACT_ID)</artifactId>
  <version>$(VERSION)</version>
  <packaging>jar</packaging>

  <name>ONNX Runtime DirectML Java</name>
  <description>Custom ONNX Runtime Java artifact built with DirectML support for Windows x64.</description>
  <url>https://github.com/microsoft/onnxruntime</url>

  <licenses>
    <license>
      <name>MIT License</name>
      <url>https://github.com/microsoft/onnxruntime/blob/main/LICENSE</url>
      <distribution>repo</distribution>
    </license>
  </licenses>
</project>
'@ | Set-Content -Encoding UTF8 "$(POM)"

check:
	if (-not (Test-Path "$(DIST_DIR)" -PathType Container)) { throw "Directory not found: $(DIST_DIR)" }
	if (-not (Test-Path "$(JAR)" -PathType Leaf)) { throw "Jar not found: $(JAR)" }
	jar tf "$(JAR)" | Out-Null
	Write-Host "Using dist dir: $(DIST_DIR)"
	Write-Host "Using jar: $(JAR)"
	Write-Host "Coordinates: $(GROUP_ID):$(ARTIFACT_ID):$(VERSION)"

list:
	Get-ChildItem -Recurse dist | Select-Object FullName, Length

clean:
	if (Test-Path "$(POM)") { Remove-Item -Force "$(POM)" }