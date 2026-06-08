param(
    [ValidateSet("release", "debug", "profile", "compat", "accuracy")]
    [string] $Profile = "release",

    [switch] $Clean,
    [switch] $CdImage,
    [switch] $UseCSa1,

    [string] $DreamSdkHome = $env:DREAMSDK_HOME
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DreamSdkHome)) {
    $DreamSdkHome = "C:\DreamSDK"
}

$bash = Join-Path $DreamSdkHome "usr\bin\bash.exe"
if (!(Test-Path $bash)) {
    throw "DreamSDK bash was not found at $bash"
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$repoPath = $repoRoot.Path -replace "\\", "/"
if ($repoPath -match "^([A-Za-z]):/(.*)$") {
    $repoPath = "/" + $Matches[1].ToLower() + "/" + $Matches[2]
}
$sa1Flag = if ($UseCSa1) { "USE_SA1_ASM=0" } else { "USE_SA1_ASM=1" }

$commands = @(
    "source /opt/dreamsdk/environ.sh",
    "cd '$repoPath/src'"
)

if ($Clean) {
    $commands += "make clean"
}

$commands += "make BUILD_PROFILE=$Profile $sa1Flag"

if ($CdImage) {
    $commands += "make cdimg"
}

& $bash -lc ($commands -join " && ")
exit $LASTEXITCODE
