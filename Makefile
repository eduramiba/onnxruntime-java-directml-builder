GROUP_ID := io.github.eduramiba
ARTIFACT_ID := onnxruntime-directml
VERSION ?= 1.26.0
PACKAGING := jar

DIST_DIR := dist/$(VERSION)
JAR ?= $(DIST_DIR)/onnxruntime.jar
POM := $(DIST_DIR)/generated-pom.xml

PWRSH := pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -Command

.PHONY: install deploy pom clean check list

install: check pom
	pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -File install-jar.ps1 -DistDir "$(DIST_DIR)" -GroupId "$(GROUP_ID)" -ArtifactId "$(ARTIFACT_ID)" -Version "$(VERSION)"

deploy: check pom
	$(PWRSH) "if ([string]::IsNullOrWhiteSpace('$(REPOSITORY_ID)')) { throw 'Missing REPOSITORY_ID' }"
	$(PWRSH) "if ([string]::IsNullOrWhiteSpace('$(REPOSITORY_URL)')) { throw 'Missing REPOSITORY_URL' }"
	pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -File deploy-jar.ps1 -DistDir "$(DIST_DIR)" -GroupId "$(GROUP_ID)" -ArtifactId "$(ARTIFACT_ID)" -Version "$(VERSION)" -RepositoryId "$(REPOSITORY_ID)" -RepositoryUrl "$(REPOSITORY_URL)"

pom:
	pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -File generate-pom.ps1 -PomPath "$(POM)" -GroupId "$(GROUP_ID)" -ArtifactId "$(ARTIFACT_ID)" -Version "$(VERSION)"

check:
	$(PWRSH) "if (-not (Test-Path '$(DIST_DIR)' -PathType Container)) { throw 'Directory not found: $(DIST_DIR)' }"
	$(PWRSH) "if (-not (Test-Path '$(JAR)' -PathType Leaf)) { throw 'Jar not found: $(JAR)' }"
	$(PWRSH) "jar tf '$(JAR)' | Out-Null"
	$(PWRSH) "Write-Host 'Using dist dir: $(DIST_DIR)'"
	$(PWRSH) "Write-Host 'Using jar: $(JAR)'"
	$(PWRSH) "Write-Host 'Coordinates: $(GROUP_ID):$(ARTIFACT_ID):$(VERSION)'"

list:
	pwsh -NoProfile -NoLogo -ExecutionPolicy Bypass -Command "Get-ChildItem -Recurse dist | Select-Object FullName, Length"

clean:
	$(PWRSH) "if (Test-Path '$(POM)') { Remove-Item -Force '$(POM)' }"
