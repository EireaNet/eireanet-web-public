<#
.SYNOPSIS
    Verifies the expected folder structure for both EireaNet repositories (private and public)
    and detects any extra / unexpected folders.

.DESCRIPTION
    Checks folder structure in two fixed repositories located under a configurable base path.
    Reports missing expected folders, present folders, and extra top-level folders.

.PARAMETER BaseRootPath
    The parent directory containing both repositories (default: C:\ENET)

.EXAMPLE
    .\Verify-Repo-Structure.ps1 -BaseRootPath "C:\ENET"
    .\Verify-Repo-Structure.ps1   # uses default C:\ENET
#>

[CmdletBinding()]
param(
    [string]$BaseRootPath = "C:\ENET"
)

$ErrorActionPreference = "Stop"

# ──────────────────────────────────────────────
# CONFIG – FIXED PATHS
# ──────────────────────────────────────────────
$PrivateRepoName = "eireanet-web-private"
$PublicRepoName  = "eireanet-web-public"

$PrivateRoot = Join-Path -Path $BaseRootPath -ChildPath $PrivateRepoName
$PublicRoot  = Join-Path -Path $BaseRootPath -ChildPath $PublicRepoName

if (-not (Test-Path -LiteralPath $BaseRootPath)) {
    Write-Error "Base root path does not exist: $BaseRootPath"
    exit 1
}

# ──────────────────────────────────────────────
# LOG SETUP (PowerShell 5.1 SAFE)
# ──────────────────────────────────────────────
$LogRepoRoot = $PrivateRoot
$LogType     = "StructureCheck"
$LogFileName = "check.log"

$today = Get-Date
$year  = $today.ToString("yyyy")
$month = $today.ToString("MM")

# Build log path safely
$LogDir = Join-Path $LogRepoRoot "Logs"
$LogDir = Join-Path $LogDir $LogType
$LogDir = Join-Path $LogDir $year
$LogDir = Join-Path $LogDir $month

$LogPath = Join-Path $LogDir $LogFileName

if (-not (Test-Path -LiteralPath $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting structure verification (Base: $BaseRootPath)" |
    Add-Content -Path $LogPath -Encoding utf8

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    "$((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) [$Level] $Message" |
        Add-Content -Path $LogPath -Encoding utf8

    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "WARN"  { Write-Host $Message -ForegroundColor Yellow }
        default { Write-Host $Message -ForegroundColor Cyan }
    }
}

Write-Log "Private repo path: $PrivateRoot"
Write-Log "Public repo path:  $PublicRoot"
Write-Log "Log file: $LogPath"

# ──────────────────────────────────────────────
# EXPECTED FOLDERS
# ──────────────────────────────────────────────
$privateExpected = @(
    "EireaNet.Web",
    "EireaNet.Web\Pages",
    "EireaNet.Web\Pages\Shared",
    "EireaNet.Web\wwwroot",
    "EireaNet.Web\wwwroot\css",
    "EireaNet.Web\wwwroot\js",
    "EireaNet.Web\wwwroot\images",
    "PSscripts",
    "Logs",
    "Rules",
    "Variables",
    "Pendings"
)

$publicExpected = @(
    "images",
    "images\ICO",
    "images\JPG",
    "images\PNG",
    "images\SVG",
    "images\webp",
    "images\jfif",
    "images\Gif"
)

# ──────────────────────────────────────────────
# VERIFY FUNCTION
# ──────────────────────────────────────────────
function Verify-FolderStructure {
    param(
        [Parameter(Mandatory)][string]$RepoPath,
        [Parameter(Mandatory)][string]$RepoLabel,
        [Parameter(Mandatory)][string[]]$ExpectedFolders
    )

    if (-not (Test-Path -LiteralPath $RepoPath)) {
        Write-Log "${RepoLabel} repo not found at $RepoPath" "ERROR"
        return
    }

    Write-Log "Verifying ${RepoLabel} repo ($RepoPath)"
    Write-Host "`n=== ${RepoLabel} Repository ($RepoPath) ===" -ForegroundColor Cyan

    $found   = @()
    $missing = @()

    foreach ($relPath in $ExpectedFolders) {
        $full = Join-Path -Path $RepoPath -ChildPath $relPath
        if (Test-Path -LiteralPath $full) {
            $found += $relPath
            Write-Log "Found expected: $relPath"
            Write-Host "Found    : $relPath" -ForegroundColor Green
        }
        else {
            $missing += $relPath
            Write-Log "Missing expected: $relPath" "WARN"
            Write-Host "Missing  : $relPath" -ForegroundColor Red
        }
    }

    # Extra top-level folders
    $allTopLevel = Get-ChildItem -LiteralPath $RepoPath -Directory |
                   Select-Object -ExpandProperty Name

    $expectedTopLevel = $ExpectedFolders |
        ForEach-Object { ($_ -split '\\')[0] } |
        Sort-Object -Unique

    $extraTopLevel = $allTopLevel | Where-Object {
        ($_ -notin $expectedTopLevel) -and ($_ -notmatch '^\.')
    }

    if ($extraTopLevel) {
        Write-Log "Extra top-level folders in ${RepoLabel}:" "WARN"
        foreach ($e in $extraTopLevel) {
            Write-Log "  - $e" "WARN"
            Write-Host "Extra    : $e" -ForegroundColor Yellow
        }
    }
    else {
        Write-Log "No extra top-level folders in ${RepoLabel}"
        Write-Host "No extra top-level folders" -ForegroundColor Green
    }

    Write-Host "`nSummary for ${RepoLabel}:" -ForegroundColor Cyan
    Write-Host "Found expected    : $($found.Count)" -ForegroundColor Green
    Write-Host "Missing expected  : $($missing.Count)" -ForegroundColor Red
    Write-Host "Extra top-level   : $(@($extraTopLevel).Count)" -ForegroundColor Yellow
}

# ──────────────────────────────────────────────
# RUN VERIFICATION
# ──────────────────────────────────────────────
Verify-FolderStructure -RepoPath $PrivateRoot -RepoLabel "Private" -ExpectedFolders $privateExpected
Verify-FolderStructure -RepoPath $PublicRoot  -RepoLabel "Public"  -ExpectedFolders $publicExpected

# ──────────────────────────────────────────────
# FINAL
# ──────────────────────────────────────────────
Write-Log "Verification finished for both repositories"
Write-Host "`nVerification complete for both repositories." -ForegroundColor Cyan
Write-Host "Log appended to: $LogPath" -ForegroundColor Yellow