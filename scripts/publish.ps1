[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9-]+$')][string]$Owner,
    [ValidateSet('public', 'private')][string]$Visibility = 'public',
    [string]$RepositoryName = 'NetFallback'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $Root

foreach ($Tool in @('git', 'gh')) {
    if (-not (Get-Command $Tool -ErrorAction SilentlyContinue)) {
        throw "Required command '$Tool' was not found. Install Git and GitHub CLI first."
    }
}
if (-not (Test-Path (Join-Path $Root 'sources.json')) -or -not (Test-Path (Join-Path $Root 'README.md'))) {
    throw 'Run this script from a complete NetFallback project tree.'
}

& gh auth status
if ($LASTEXITCODE -ne 0) { throw 'GitHub CLI is not authenticated. Run: gh auth login' }

$RepoFullName = "$Owner/$RepositoryName"
if (-not (Test-Path (Join-Path $Root '.git'))) {
    & git init -b main
    if ($LASTEXITCODE -ne 0) { throw 'git init failed.' }
}

$RemoteOutput = & git remote get-url origin 2>$null
$HasOrigin = $LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($RemoteOutput -join '').Trim())
if ($HasOrigin) {
    $OriginUrl = ($RemoteOutput -join '').Trim()
    if ($OriginUrl -notmatch ([Regex]::Escape($Owner) + '/' + [Regex]::Escape($RepositoryName) + '(\.git)?/?$')) {
        throw "Existing origin points to '$OriginUrl', not '$RepoFullName'. Refusing to change it automatically."
    }
}

# Assert that generated downloads remain ignored and do not stage pre-existing ignored files.
$IgnoreCheck = & git check-ignore '01-Android/example.apk' 2>$null
if ($LASTEXITCODE -ne 0) { throw '.gitignore does not ignore archive/download folders; refusing to publish.' }

& git add --all
if ($LASTEXITCODE -ne 0) { throw 'git add failed.' }
$Staged = @(& git diff --cached --name-only)
$Forbidden = @($Staged | Where-Object { $_ -match '^(01-Android|02-Windows|03-Source-Code|04-Configs|05-Metadata)/' -or $_ -match '^(DOWNLOAD-REPORT\.txt|SHA256SUMS-local\.txt|NetFallback-download-manifest\.json)$' })
if ($Forbidden.Count -gt 0) {
    throw "Refusing to publish generated artifacts/configs: $($Forbidden -join ', '). Remove them from the Git index before retrying."
}
if ($Staged.Count -eq 0) { Write-Host 'No staged source changes.' -ForegroundColor Yellow }
else {
    & git diff --cached --stat
    if ($LASTEXITCODE -ne 0) { throw 'Could not inspect staged files.' }
    $CommitMessage = 'chore: initialize NetFallback toolkit'
    & git commit -m $CommitMessage
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed. Configure user.name and user.email if required, then rerun.' }
}

if (-not $HasOrigin) {
    & gh repo create $RepoFullName "--$Visibility" --description 'Connectivity backup toolkit: official releases, source snapshots, and offline preparation.' --source $Root --remote origin --push
    if ($LASTEXITCODE -ne 0) { throw "Repository creation/push failed. Check whether $RepoFullName already exists and review gh auth status." }
}
else {
    & git push -u origin main
    if ($LASTEXITCODE -ne 0) { throw 'git push failed.' }
}

Write-Host "Published: https://github.com/$RepoFullName" -ForegroundColor Green
