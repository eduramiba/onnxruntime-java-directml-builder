param(
    [Parameter(Mandatory=$true)][string]$DistDir,
    [Parameter(Mandatory=$true)][string]$GroupId,
    [Parameter(Mandatory=$true)][string]$ArtifactId,
    [Parameter(Mandatory=$true)][string]$Version
)

Set-Location $DistDir

mvn -f generated-pom.xml install:install-file `
    "-Dfile=onnxruntime.jar" `
    "-DgroupId=$GroupId" `
    "-DartifactId=$ArtifactId" `
    "-Dversion=$Version" `
    -Dpackaging=jar `
    "-DpomFile=generated-pom.xml"
