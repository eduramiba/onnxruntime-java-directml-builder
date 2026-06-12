param(
    [Parameter(Mandatory=$true)][string]$JarPath,
    [Parameter(Mandatory=$true)][string]$DmlDllPath
)

$ErrorActionPreference = 'Stop'

# Resolve to absolute paths before changing directory
$JarPath = Resolve-Path $JarPath
$DmlDllPath = Resolve-Path $DmlDllPath

# Check if already bundled
$existing = & jar tf $JarPath 2>&1 | Select-String 'DirectML.dll'
if ($existing) {
    Write-Host "DirectML.dll already bundled in $JarPath"
    exit 0
}

$temp = Join-Path $env:TEMP 'ort-dml-bundle'
Remove-Item -Recurse -Force $temp -ErrorAction SilentlyContinue
$nativeDir = "$temp\ai\onnxruntime\native\win-x64"
New-Item -ItemType Directory -Force $nativeDir | Out-Null
Copy-Item $DmlDllPath $nativeDir

Push-Location $temp
try {
    & jar uf $JarPath ai/onnxruntime/native/win-x64/DirectML.dll
    Write-Host "Added DirectML.dll to $JarPath"
} finally {
    Pop-Location
    Remove-Item -Recurse -Force $temp -ErrorAction SilentlyContinue
}
