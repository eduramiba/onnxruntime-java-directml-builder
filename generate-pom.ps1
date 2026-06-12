param(
    [Parameter(Mandatory=$true)][string]$PomPath,
    [Parameter(Mandatory=$true)][string]$GroupId,
    [Parameter(Mandatory=$true)][string]$ArtifactId,
    [Parameter(Mandatory=$true)][string]$Version
)

$pomDir = Split-Path $PomPath -Parent
New-Item -ItemType Directory -Force -Path $pomDir | Out-Null

@'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>GROUP_ID_PLACEHOLDER</groupId>
  <artifactId>ARTIFACT_ID_PLACEHOLDER</artifactId>
  <version>VERSION_PLACEHOLDER</version>
  <packaging>jar</packaging>

  <name>ONNX Runtime DirectML + OpenVINO Java</name>
  <description>Custom ONNX Runtime Java artifact built with DirectML and OpenVINO support for Windows x64.</description>
  <url>https://github.com/eduramiba/onnxruntime-java-directml-builder</url>

  <licenses>
    <license>
      <name>MIT License</name>
      <url>https://github.com/eduramiba/onnxruntime-java-directml-builder/blob/main/LICENSE</url>
      <distribution>repo</distribution>
    </license>
  </licenses>
</project>
'@ `
    -replace 'GROUP_ID_PLACEHOLDER', $GroupId `
    -replace 'ARTIFACT_ID_PLACEHOLDER', $ArtifactId `
    -replace 'VERSION_PLACEHOLDER', $Version |
    Set-Content -Encoding UTF8 $PomPath
