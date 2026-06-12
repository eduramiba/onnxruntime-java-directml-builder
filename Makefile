GROUP_ID := io.github.eduramiba
ARTIFACT_ID := onnxruntime-directml
VERSION ?= 1.26.0
PACKAGING := jar

DIST_DIR := dist/$(VERSION)
JAR ?= $(DIST_DIR)/onnxruntime.jar
POM := $(DIST_DIR)/generated-pom.xml

MVN := mvn

.PHONY: install deploy pom clean check list

install: check pom
	$(MVN) install:install-file \
		-Dfile="$(JAR)" \
		-DgroupId="$(GROUP_ID)" \
		-DartifactId="$(ARTIFACT_ID)" \
		-Dversion="$(VERSION)" \
		-Dpackaging="$(PACKAGING)" \
		-DpomFile="$(POM)"

deploy: check pom
	@if [ -z "$(REPOSITORY_ID)" ]; then echo "Missing REPOSITORY_ID"; exit 1; fi
	@if [ -z "$(REPOSITORY_URL)" ]; then echo "Missing REPOSITORY_URL"; exit 1; fi
	$(MVN) deploy:deploy-file \
		-Dfile="$(JAR)" \
		-DgroupId="$(GROUP_ID)" \
		-DartifactId="$(ARTIFACT_ID)" \
		-Dversion="$(VERSION)" \
		-Dpackaging="$(PACKAGING)" \
		-DpomFile="$(POM)" \
		-DrepositoryId="$(REPOSITORY_ID)" \
		-Durl="$(REPOSITORY_URL)"

pom:
	@mkdir -p "$(DIST_DIR)"
	@printf '%s\n' \
		'<project xmlns="http://maven.apache.org/POM/4.0.0"' \
		'         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' \
		'         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">' \
		'  <modelVersion>4.0.0</modelVersion>' \
		'' \
		'  <groupId>$(GROUP_ID)</groupId>' \
		'  <artifactId>$(ARTIFACT_ID)</artifactId>' \
		'  <version>$(VERSION)</version>' \
		'  <packaging>jar</packaging>' \
		'' \
		'  <name>ONNX Runtime DirectML Java</name>' \
		'  <description>Custom ONNX Runtime Java artifact built with DirectML support for Windows x64.</description>' \
		'  <url>https://github.com/eduramiba/onnxruntime-java-directml-builder</url>' \
		'' \
		'  <licenses>' \
		'    <license>' \
		'      <name>MIT License</name>' \
		'      <url>https://github.com/eduramiba/onnxruntime-java-directml-builder/blob/main/LICENSE</url>' \
		'      <distribution>repo</distribution>' \
		'    </license>' \
		'  </licenses>' \
		'</project>' \
		> "$(POM)"

check:
	@if [ ! -d "$(DIST_DIR)" ]; then echo "Directory not found: $(DIST_DIR)"; exit 1; fi
	@if [ ! -f "$(JAR)" ]; then echo "Jar not found: $(JAR)"; exit 1; fi
	@jar tf "$(JAR)" >/dev/null
	@echo "Using dist dir: $(DIST_DIR)"
	@echo "Using jar: $(JAR)"
	@echo "Coordinates: $(GROUP_ID):$(ARTIFACT_ID):$(VERSION)"

list:
	@find dist -maxdepth 2 -type f | sort

clean:
	rm -f "$(POM)"