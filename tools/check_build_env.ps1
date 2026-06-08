param(
    [string] $SourceDir = "src",
    [string] $DreamSdkHome = $env:DREAMSDK_HOME
)

$ErrorActionPreference = "Stop"

function Show-Check {
    param(
        [string] $Name,
        [bool] $Ok,
        [string] $Detail = ""
    )

    $status = if ($Ok) { "OK" } else { "MISSING" }
    if ($Detail) {
        "{0,-18} {1,-8} {2}" -f $Name, $status, $Detail
    } else {
        "{0,-18} {1}" -f $Name, $status
    }
}

function Find-Command {
    param([string] $Name)
    Get-Command $Name -ErrorAction SilentlyContinue
}

function Convert-MsysPath {
    param(
        [string] $Path,
        [string] $DreamSdkHome = "C:\DreamSDK"
    )

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

function Read-DreamSdkEnvironment {
    param([string] $DreamSdkHome)

if ([string]::IsNullOrWhiteSpace($DreamSdkHome)) {
    $DreamSdkHome = "C:\DreamSDK"
}

    $bash = Join-Path $DreamSdkHome "usr\bin\bash.exe"
    if (!(Test-Path $bash)) {
        return $null
    }

    $probe = @'
source /opt/dreamsdk/environ.sh >/dev/null
printf 'KOS_BASE=%s\n' "$KOS_BASE"
printf 'KOS_CC=%s\n' "$KOS_CC"
printf 'KOS_GENROMFS=%s\n' "$KOS_GENROMFS"
for tool in make sh-elf-gcc sh-elf-as scramble mkisofs; do
    tool_path=$(command -v "$tool" 2>/dev/null)
    printf '%s=%s\n' "$tool" "$tool_path"
done
'@

    $lines = & $bash -lc $probe 2>$null
    $values = @{}
    foreach ($line in $lines) {
        $parts = $line -split "=", 2
        if ($parts.Length -eq 2) {
            $values[$parts[0]] = $parts[1]
        }
    }

    return @{
        Bash = $bash
        Values = $values
    }
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$srcPath = Join-Path $repoRoot $SourceDir
$dreamSdk = Read-DreamSdkEnvironment $DreamSdkHome

Write-Host "Super Famicast build environment check"
Write-Host "Repo: $repoRoot"
Write-Host "Source: $srcPath"
if ($dreamSdk) {
    Write-Host "DreamSDK bash: $($dreamSdk.Bash)"
}
Write-Host ""

$kosBase = [Environment]::GetEnvironmentVariable("KOS_BASE")
if ([string]::IsNullOrWhiteSpace($kosBase) -and $dreamSdk) {
    $kosBase = $dreamSdk.Values["KOS_BASE"]
}
$nativeKosBase = Convert-MsysPath $kosBase $DreamSdkHome
Show-Check "KOS_BASE" (![string]::IsNullOrWhiteSpace($kosBase)) $nativeKosBase

$kosCc = [Environment]::GetEnvironmentVariable("KOS_CC")
if ([string]::IsNullOrWhiteSpace($kosCc) -and $dreamSdk) {
    $kosCc = $dreamSdk.Values["KOS_CC"]
}
Show-Check "KOS_CC" (![string]::IsNullOrWhiteSpace($kosCc)) $(Convert-MsysPath $kosCc $DreamSdkHome)

$kosGenromfs = [Environment]::GetEnvironmentVariable("KOS_GENROMFS")
if ([string]::IsNullOrWhiteSpace($kosGenromfs) -and $dreamSdk) {
    $kosGenromfs = $dreamSdk.Values["KOS_GENROMFS"]
}
Show-Check "KOS_GENROMFS" (![string]::IsNullOrWhiteSpace($kosGenromfs)) $(Convert-MsysPath $kosGenromfs $DreamSdkHome)

$tools = @("make", "sh-elf-gcc", "sh-elf-as", "scramble", "mkisofs")
foreach ($tool in $tools) {
    $cmd = Find-Command $tool
    $detail = if ($cmd) { $cmd.Source } elseif ($dreamSdk) { Convert-MsysPath $dreamSdk.Values[$tool] $DreamSdkHome } else { "" }
    Show-Check $tool (![string]::IsNullOrWhiteSpace($detail)) $detail
}

if ($nativeKosBase) {
    $rules = Join-Path $nativeKosBase "Makefile.rules"
    Show-Check "Makefile.rules" (Test-Path $rules) $rules

    $bin2o = Join-Path $nativeKosBase "utils\bin2o\bin2o"
    Show-Check "bin2o" (Test-Path $bin2o) $bin2o
}

Write-Host ""
Write-Host "Suggested first build commands:"
Write-Host "  . .\tools\Import-DreamSdkEnv.ps1"
Write-Host "  .\tools\build.ps1 -Profile debug -Clean"
Write-Host "  .\tools\build.ps1 -Profile accuracy -Clean"
Write-Host "  .\tools\build.ps1 -Profile release -Clean -CdImage"
