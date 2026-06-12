param(
    [Parameter(Mandatory=$true)][string]$DistDir,
    [Parameter(Mandatory=$true)][string]$GroupId,
    [Parameter(Mandatory=$true)][string]$ArtifactId,
    [Parameter(Mandatory=$true)][string]$Version,
    [Parameter(Mandatory=$true)][string]$RepositoryId,
    [Parameter(Mandatory=$true)][string]$RepositoryUrl
)

Set-Location $DistDir

mvn -f generated-pom.xml deploy:deploy-file `
    "-Dfile=onnxruntime.jar" `
    "-DgroupId=$GroupId" `
    "-DartifactId=$ArtifactId" `
    "-Dversion=$Version" `
    -Dpackaging=jar `
    "-DpomFile=generated-pom.xml" `
    "-DrepositoryId=$RepositoryId" `
    "-Durl=$RepositoryUrl"
