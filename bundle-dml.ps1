param(
    [Parameter(Mandatory=$true)][string]$JarPath,
    [Parameter(Mandatory=$true)][string]$DmlDllPath,
    [string]$NativeDllDirectory
)

$ErrorActionPreference = 'Stop'

# Resolve to absolute paths before changing directory
$JarPath = Resolve-Path $JarPath
$DmlDllPath = Resolve-Path $DmlDllPath
if ([string]::IsNullOrWhiteSpace($NativeDllDirectory)) {
    $NativeDllDirectory = Split-Path $DmlDllPath -Parent
}
$NativeDllDirectory = Resolve-Path $NativeDllDirectory

$dlls = Get-ChildItem -Path $NativeDllDirectory -Filter '*.dll' -File |
    Where-Object {
        $_.Name -eq 'DirectML.dll' -or
        $_.Name -like 'onnxruntime*.dll'
    }
if (-not $dlls) {
    throw "No ONNX Runtime native DLLs found in $NativeDllDirectory"
}

if (-not ($dlls | Where-Object { $_.Name -eq 'DirectML.dll' })) {
    throw "DirectML.dll not found in $NativeDllDirectory"
}

$temp = Join-Path $env:TEMP 'ort-dml-bundle'
Remove-Item -Recurse -Force $temp -ErrorAction SilentlyContinue
$nativeDir = "$temp\ai\onnxruntime\native\win-x64"
New-Item -ItemType Directory -Force $nativeDir | Out-Null

$jarEntries = & jar tf $JarPath 2>&1
$dllsToBundle = @()
foreach ($dll in $dlls) {
    $entry = "ai/onnxruntime/native/win-x64/$($dll.Name)"
    if ($jarEntries -notcontains $entry) {
        Copy-Item $dll.FullName $nativeDir
        $dllsToBundle += $dll.Name
    }
}

if (-not $dllsToBundle) {
    Write-Host "All ONNX Runtime native DLLs from $NativeDllDirectory already bundled in $JarPath"
    exit 0
}

Push-Location $temp
try {
    foreach ($dllName in $dllsToBundle) {
        & jar uf $JarPath "ai/onnxruntime/native/win-x64/$dllName"
        Write-Host "Added $dllName to $JarPath"
    }
} finally {
    Pop-Location
    Remove-Item -Recurse -Force $temp -ErrorAction SilentlyContinue
}
