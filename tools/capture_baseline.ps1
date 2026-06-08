param(
    [string] $DreamSdkHome = $env:DREAMSDK_HOME
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($DreamSdkHome)) {
    $DreamSdkHome = "C:\DreamSDK"
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$bash = Join-Path $DreamSdkHome "usr\bin\bash.exe"
$artifacts = @(
    "src\superfamicast.elf",
    "src\bin\raw.bin",
    "src\bin\1ST_READ.BIN",
    "src\cd\1ST_READ.BIN",
    "src\data.iso",
    "src\romdisk.img"
)

function Write-Section {
    param([string] $Title)
    Write-Output ""
    Write-Output "## $Title"
}

Push-Location $repoRoot
try {
    Write-Output "# Super Famicast Baseline Capture"
    Write-Output ""
    Write-Output "- Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
    Write-Output "- Repo: $repoRoot"
    Write-Output "- Git HEAD: $(git rev-parse HEAD)"
    Write-Output "- Git short HEAD: $(git rev-parse --short HEAD)"

    Write-Section "DreamSDK Environment"
    if (Test-Path $bash) {
        & $bash -lc @'
source /opt/dreamsdk/environ.sh >/dev/null
printf -- '- DREAMSDK_HOME: %s\n' "$DREAMSDK_HOME"
printf -- '- KOS_BASE: %s\n' "$KOS_BASE"
printf -- '- KOS_CC: %s\n' "$KOS_CC"
printf -- '- KOS_GENROMFS: %s\n' "$KOS_GENROMFS"
printf -- '- GCC: '
sh-elf-gcc --version | head -1
printf -- '- AS: '
sh-elf-as --version | head -1
printf -- '- Make: '
make --version | head -1
printf -- '- mkisofs: '
mkisofs --version 2>&1 | head -1
'@
    } else {
        Write-Output "- DreamSDK bash missing: $bash"
    }

    Write-Section "Artifacts"
    Write-Output "| Artifact | Bytes | SHA-256 |"
    Write-Output "|---|---:|---|"
    foreach ($artifact in $artifacts) {
        if (Test-Path $artifact) {
            $item = Get-Item $artifact
            $hash = (Get-FileHash $artifact -Algorithm SHA256).Hash
            Write-Output ("| ``{0}`` | {1} | ``{2}`` |" -f $artifact, $item.Length, $hash)
        } else {
            Write-Output ("| ``{0}`` | missing | missing |" -f $artifact)
        }
    }

    Write-Section "Git Status"
    git status --short
} finally {
    Pop-Location
}
