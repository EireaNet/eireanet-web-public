<#
.SYNOPSIS
    Initializes the basic folder structure for the EireaNet website project.

.DESCRIPTION
    This script prepares the required folder structure in the private GitHub repository.
    It verifies that it is being executed from the correct root directory (eireanet-web-private),
    creates the EireaNet.Web subfolder (if missing), sets up standard ASP.NET Core Razor Pages
    directories (Pages, Pages/Shared, wwwroot/css, wwwroot/js, wwwroot/images, etc.), and logs
    all actions per project rules.

    This script does NOT require or use the .NET SDK / dotnet command at this stage.
    It focuses exclusively on folder creation and organization.

    Logging follows General Variables rule:
    - Location: Logs\ProjectInit\YYYY\MM\init.log
    - Same-day executions append to the file

    Safety features:
    - Checks current directory against expected repo root name
    - Exits early with clear message if not in correct directory

.PARAMETER None
    No parameters are currently used.

.EXAMPLE
    cd C:\Path\To\eireanet-web-private
    .\PSscripts\Initialize-Project.ps1

.NOTES
    - Must be run from the ROOT of the eireanet-web-private repository
    - Follows General Rules 9 (logged actions), 11 (saved in PSscripts), 12 (detailed synopsis)
    - Does NOT install or use .NET SDK — folder structure only
    - Author: Grok (project assistant)
    - Date: February 2026
#>

[CmdletBinding()]
param ()

$ErrorActionPreference = "Stop"

# ──────────────────────────────────────────────
# AUTO-DETECT REPOSITORY ROOT
# ──────────────────────────────────────────────
$CurrentPath = Get-Location
$ExpectedRootName = "eireanet-web-private"

$RootPath = $CurrentPath
while ($RootPath -and (Split-Path $RootPath -Leaf) -ne $ExpectedRootName) {
    $RootPath = Split-Path $RootPath -Parent
}

if (-not $RootPath) {
    Write-Error "Could not locate repository root folder '$ExpectedRootName'.`nPlease run this script from inside the eireanet-web-private repository (or any of its subfolders)."
    exit 1
}

Set-Location $RootPath
Write-Host "Auto-switched to repository root: $RootPath" -ForegroundColor Green

$RepoRoot = $RootPath

# ──────────────────────────────────────────────
# CONFIG & LOG SETUP (rest remains the same)
# ──────────────────────────────────────────────
$ProjectSubfolder = "EireaNet.Web"
$LogType          = "ProjectInit"
$LogFileName      = "init.log"

$today = Get-Date
$year  = $today.ToString("yyyy")
$month = $today.ToString("MM")

$LogDir = Join-Path -Path $RepoRoot -ChildPath "Logs"
$LogDir = Join-Path -Path $LogDir -ChildPath $LogType
$LogDir = Join-Path -Path $LogDir -ChildPath $year
$LogDir = Join-Path -Path $LogDir -ChildPath $month

$LogPath = Join-Path -Path $LogDir -ChildPath $LogFileName

# Create log directory
if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

# Initial log entry (append)
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Starting folder structure initialization" | Add-Content -Path $LogPath -Encoding utf8

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp [$Level] $Message" | Add-Content -Path $LogPath -Encoding utf8
    
    if ($Level -eq "ERROR") {
        Write-Host $Message -ForegroundColor Red
    } elseif ($Level -eq "WARNING") {
        Write-Host $Message -ForegroundColor Yellow
    } else {
        Write-Host $Message -ForegroundColor Cyan
    }
}

Write-Log "Current working directory: $RepoRoot"

# ──────────────────────────────────────────────
# Safety Check: Correct directory?
# ──────────────────────────────────────────────
$currentFolderName = Split-Path $RepoRoot -Leaf

if ($currentFolderName -ne $ExpectedRepoRootName) {
    Write-Log "ERROR: Script must be run from the root of eireanet-web-private repository." "ERROR"
    Write-Log "Current folder name: '$currentFolderName'" "ERROR"
    Write-Log "Expected folder name: '$ExpectedRepoRootName'" "ERROR"
    Write-Log "Please change directory (cd) to the repository root and try again." "ERROR"
    Write-Host "`nAborting script due to incorrect working directory." -ForegroundColor Red
    exit 1
}

Write-Log "Directory check passed: Running from correct repo root ($ExpectedRepoRootName)"

# ──────────────────────────────────────────────
# 1. Create project subfolder if missing
# ──────────────────────────────────────────────
$ProjectPath = Join-Path $RepoRoot $ProjectSubfolder
if (-not (Test-Path $ProjectPath)) {
    New-Item -Path $ProjectPath -ItemType Directory | Out-Null
    Write-Log "Created project subfolder: $ProjectSubfolder"
} else {
    Write-Log "Project subfolder already exists"
}

# ──────────────────────────────────────────────
# 2. Create standard ASP.NET Core Razor Pages folders
# ──────────────────────────────────────────────
$foldersToCreate = @(
    "Pages",
    "Pages\Shared",
    "wwwroot",
    "wwwroot\css",
    "wwwroot\js",
    "wwwroot\images"
)

foreach ($relPath in $foldersToCreate) {
    $fullPath = Join-Path $ProjectPath $relPath
    if (-not (Test-Path $fullPath)) {
        New-Item -Path $fullPath -ItemType Directory | Out-Null
        Write-Log "Created folder: $relPath"
    } else {
        Write-Log "Folder already exists: $relPath"
    }
}

# ──────────────────────────────────────────────
# Final summary
# ──────────────────────────────────────────────
Write-Log "Folder structure initialization finished."
Write-Log "Project base path: $ProjectPath"
Write-Log "Next steps:"
Write-Log "  - Manually place _Layout.cshtml, _Header.cshtml, etc. into Pages\Shared\"
Write-Log "  - Place Index.cshtml (with hero section) into Pages\"
Write-Log "  - When ready for code generation, install .NET SDK and run dotnet new webapp inside EireaNet.Web"

Write-Host "`nDone." -ForegroundColor Green
Write-Host "Log appended to: $LogPath" -ForegroundColor Yellow