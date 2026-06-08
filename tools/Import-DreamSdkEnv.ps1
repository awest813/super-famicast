param(
    [string] $DreamSdkHome = $env:DREAMSDK_HOME
)

$ErrorActionPreference = "Stop"

function Convert-MsysPath {
    param(
        [string] $Path,
        [string] $DreamSdkHome = "C:\DreamSDK"
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return $Path
    }

    if ($Path -match "^/c/(.*)") {
        return "C:\" + ($Matches[1] -replace "/", "\")
    }

    if ($Path -match "^/opt/(.*)") {
        return Join-Path $DreamSdkHome ("opt\" + ($Matches[1] -replace "/", "\"))
    }

    if ($Path -match "^/usr/(.*)") {
        return Join-Path $DreamSdkHome ("usr\" + ($Matches[1] -replace "/", "\"))
    }

    return $Path
}

function Add-PathEntry {
    param([string] $Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or !(Test-Path $Path)) {
        return
    }

    $entries = $env:Path -split ";"
    if ($entries -notcontains $Path) {
        $env:Path = "$Path;$env:Path"
    }
}

if ([string]::IsNullOrWhiteSpace($DreamSdkHome)) {
    $DreamSdkHome = "C:\DreamSDK"
}

$bash = Join-Path $DreamSdkHome "usr\bin\bash.exe"
if (!(Test-Path $bash)) {
    throw "DreamSDK bash was not found at $bash"
}

$probe = @'
source /opt/dreamsdk/environ.sh >/dev/null
printf 'KOS_BASE=%s\n' "$KOS_BASE"
printf 'KOS_CC=%s\n' "$KOS_CC"
printf 'KOS_GENROMFS=%s\n' "$KOS_GENROMFS"
printf 'KOS_PORTS=%s\n' "$KOS_PORTS"
printf 'DREAMSDK_HOME=%s\n' "$DREAMSDK_HOME"
printf 'PATH=%s\n' "$PATH"
'@

$values = @{}
foreach ($line in (& $bash -lc $probe)) {
    $parts = $line -split "=", 2
    if ($parts.Length -eq 2) {
        $values[$parts[0]] = $parts[1]
    }
}

$env:DREAMSDK_HOME = $DreamSdkHome
$env:KOS_BASE = Convert-MsysPath $values["KOS_BASE"] $DreamSdkHome
$env:KOS_CC = Convert-MsysPath $values["KOS_CC"] $DreamSdkHome
$env:KOS_GENROMFS = Convert-MsysPath $values["KOS_GENROMFS"] $DreamSdkHome
$env:KOS_PORTS = Convert-MsysPath $values["KOS_PORTS"] $DreamSdkHome

foreach ($entry in ($values["PATH"] -split ":")) {
    Add-PathEntry (Convert-MsysPath $entry $DreamSdkHome)
}

Add-PathEntry (Join-Path $DreamSdkHome "usr\bin")
Add-PathEntry (Join-Path $DreamSdkHome "opt\toolchains\dc\sh-elf\bin")
Add-PathEntry (Join-Path $DreamSdkHome "opt\toolchains\dc\kos\utils\scramble")
Add-PathEntry (Join-Path $DreamSdkHome "opt\toolchains\dc\kos\utils\genromfs")

Write-Host "DreamSDK environment imported."
Write-Host "KOS_BASE=$env:KOS_BASE"
Write-Host "KOS_CC=$env:KOS_CC"
Write-Host "KOS_GENROMFS=$env:KOS_GENROMFS"
