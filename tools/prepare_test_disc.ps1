param(
    [string] $RomRoot = "C:\Users\allen\Downloads\Roms",

    [ValidateSet("release", "debug", "profile", "compat", "accuracy")]
    [string] $Profile = "accuracy",

    [switch] $Clean,
    [switch] $LaunchFlycast,
    [string] $FlycastPath = "C:\Users\allen\Downloads\flycast-win64-2.6\flycast.exe"
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$romDest = Join-Path $repoRoot "src\cd\roms"

if (!(Test-Path $RomRoot)) {
    throw "ROM root was not found: $RomRoot"
}

if (!(Test-Path $romDest)) {
    New-Item -ItemType Directory -Path $romDest | Out-Null
}

$roms = Get-ChildItem -LiteralPath $RomRoot -Recurse -File |
    Where-Object { $_.Extension -in @(".sfc", ".smc") }

if (!$roms) {
    throw "No .sfc or .smc files were found under $RomRoot"
}

foreach ($rom in $roms) {
    Copy-Item -LiteralPath $rom.FullName -Destination (Join-Path $romDest $rom.Name) -Force
    Write-Host "Copied $($rom.Name) to src\cd\roms"
}

$buildArgs = @{
    Profile = $Profile
    CdImage = $true
}
if ($Clean) {
    $buildArgs.Clean = $true
}

& (Join-Path $PSScriptRoot "build.ps1") @buildArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

$iso = Join-Path $repoRoot "src\data.iso"
Write-Host "Prepared test disc: $iso"

if ($LaunchFlycast) {
    if (!(Test-Path $FlycastPath)) {
        throw "Flycast was not found at $FlycastPath"
    }
    Start-Process -FilePath $FlycastPath -ArgumentList "`"$iso`""
}
