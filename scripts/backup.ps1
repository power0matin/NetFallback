[CmdletBinding()]
param(
    [ValidateSet('All', 'Android', 'Windows', 'Source', 'Configs')]
    [string]$Category = 'All',

    [switch]$IncludeAlternateArchitectures,

    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ManifestPath = Join-Path $Root 'sources.json'
if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Missing source manifest: $ManifestPath"
}

$Manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding utf8 | ConvertFrom-Json
if ($Manifest.schemaVersion -ne 1) { throw "Unsupported sources.json schemaVersion: $($Manifest.schemaVersion)" }

$Directories = @('01-Android', '02-Windows', '03-Source-Code', '04-Configs', '05-Metadata')
foreach ($Directory in $Directories) {
    New-Item -ItemType Directory -Force -Path (Join-Path $Root $Directory) | Out-Null
}

$Headers = @{
    'Accept' = 'application/vnd.github+json'
    'User-Agent' = 'NetFallback/1.0 (offline-connectivity-backup)'
    'X-GitHub-Api-Version' = '2022-11-28'
}
$script:LogLines = [System.Collections.Generic.List[string]]::new()
$script:Results = [System.Collections.Generic.List[object]]::new()
$script:FailedCount = 0
$script:ReleaseCache = @{}
$script:SuccessCount = 0
$script:SkippedCount = 0
$script:WhatIfMode = [bool]$DryRun
$Curl = Get-Command curl.exe -ErrorAction SilentlyContinue

function Write-Log {
    param([ValidateSet('INFO', 'OK', 'SKIP', 'WARN', 'FAIL', 'DRYRUN')][string]$Level, [string]$Message)
    $Line = '{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    $script:LogLines.Add($Line)
    $Colour = switch ($Level) {
        'OK' { 'Green' }
        'SKIP' { 'DarkGray' }
        'WARN' { 'Yellow' }
        'FAIL' { 'Red' }
        'DRYRUN' { 'Cyan' }
        default { 'Gray' }
    }
    Write-Host $Line -ForegroundColor $Colour
}

function Invoke-GitHubApi {
    param([Parameter(Mandatory)][string]$Uri)
    for ($Attempt = 1; $Attempt -le 3; $Attempt++) {
        try {
            return Invoke-RestMethod -Uri $Uri -Headers $Headers -TimeoutSec 45 -ErrorAction Stop
        }
        catch {
            if ($Attempt -eq 3) { throw }
            Start-Sleep -Seconds ([Math]::Min(2 * $Attempt, 6))
        }
    }
}

function Get-PathFromRoot {
    param([Parameter(Mandatory)][string]$RelativePath)
    $Combined = Join-Path $Root $RelativePath
    $Full = [System.IO.Path]::GetFullPath($Combined)
    $RootPrefix = [System.IO.Path]::GetFullPath($Root).TrimEnd([char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)) + [IO.Path]::DirectorySeparatorChar
    if (-not $Full.StartsWith($RootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing path outside project root: $RelativePath"
    }
    return $Full
}

function Get-SafeFileName {
    param([string]$Name)
    $Invalid = [Regex]::Escape((-join [IO.Path]::GetInvalidFileNameChars()))
    $Safe = [Regex]::Replace($Name, "[$Invalid]", '_')
    if ([string]::IsNullOrWhiteSpace($Safe) -or $Safe -in @('.', '..')) { throw "Unsafe filename: $Name" }
    return $Safe
}

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Save-Download {
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$Destination,
        [string]$ExpectedDigest,
        [long]$ExpectedSize = 0,
        [string]$Label,
        [switch]$AlwaysRefresh,
        [hashtable]$Details = @{}
    )

    $Destination = [System.IO.Path]::GetFullPath($Destination)
    $DestinationDir = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null
    $PartPath = "$Destination.part"
    $PartMetaPath = "$PartPath.meta.json"
    $SidecarPath = "$Destination.download.json"
    $WantedHash = if ($ExpectedDigest -match '(?i)^sha256:([0-9a-f]{64})$') { $Matches[1].ToLowerInvariant() } else { '' }

    if ($script:WhatIfMode) {
        Write-Log DRYRUN "$Label -> $Destination"
        return
    }

    if ((Test-Path -LiteralPath $Destination) -and -not $AlwaysRefresh) {
        try {
            $CurrentHash = Get-Sha256 -Path $Destination
            $SavedMeta = if (Test-Path -LiteralPath $SidecarPath) { Get-Content -LiteralPath $SidecarPath -Raw -Encoding utf8 | ConvertFrom-Json } else { $null }
            if ($WantedHash -and $CurrentHash -eq $WantedHash) {
                $script:SkippedCount++
                Write-Log SKIP "$Label (SHA-256 already matches the published digest)"
                return
            }
            if (-not $WantedHash -and $SavedMeta -and $SavedMeta.url -eq $Url -and $SavedMeta.sha256 -eq $CurrentHash -and $SavedMeta.size -eq (Get-Item -LiteralPath $Destination).Length -and $SavedMeta.alwaysRefresh -ne $true) {
                $script:SkippedCount++
                Write-Log SKIP "$Label (same source and verified local hash)"
                return
            }
        }
        catch {
            Write-Log WARN "Could not validate existing file; will re-download: $Destination"
        }
    }

    $PartMeta = [ordered]@{ url = $Url; expectedSha256 = $WantedHash; expectedSize = $ExpectedSize; label = $Label }
    if (Test-Path -LiteralPath $PartPath) {
        $PreviousPartMeta = $null
        if (Test-Path -LiteralPath $PartMetaPath) {
            try { $PreviousPartMeta = Get-Content -LiteralPath $PartMetaPath -Raw -Encoding utf8 | ConvertFrom-Json } catch { }
        }
        if (-not $PreviousPartMeta -or $PreviousPartMeta.url -ne $Url -or $PreviousPartMeta.expectedSha256 -ne $WantedHash) {
            Remove-Item -LiteralPath $PartPath -Force -ErrorAction SilentlyContinue
        }
    }
    $PartMeta | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $PartMetaPath -Encoding utf8

    Write-Log INFO "Downloading $Label"
    try {
        if ($Curl) {
            & $Curl.Source --fail --location --silent --show-error --retry 3 --retry-delay 2 --connect-timeout 30 --max-time 0 --continue-at - --user-agent "$($Headers['User-Agent'])" --output $PartPath $Url
            if ($LASTEXITCODE -ne 0) { throw "curl.exe failed with exit code $LASTEXITCODE" }
        }
        else {
            # Invoke-WebRequest has no portable resume support; restart a stale partial.
            Remove-Item -LiteralPath $PartPath -Force -ErrorAction SilentlyContinue
            Invoke-WebRequest -Uri $Url -OutFile $PartPath -TimeoutSec 1800 -UseBasicParsing -ErrorAction Stop
        }

        if (-not (Test-Path -LiteralPath $PartPath)) { throw 'Download completed without creating a file.' }
        $DownloadedSize = (Get-Item -LiteralPath $PartPath).Length
        if ($DownloadedSize -le 0) { throw 'Downloaded file is empty.' }
        if ($ExpectedSize -gt 0 -and $DownloadedSize -ne $ExpectedSize) {
            Remove-Item -LiteralPath $PartPath -Force -ErrorAction SilentlyContinue
            throw "Size mismatch: expected $ExpectedSize, received $DownloadedSize bytes. The invalid partial was deleted."
        }

        $DownloadedHash = Get-Sha256 -Path $PartPath
        if ($WantedHash -and $DownloadedHash -ne $WantedHash) {
            Remove-Item -LiteralPath $PartPath -Force -ErrorAction SilentlyContinue
            throw "SHA-256 mismatch. Expected $WantedHash; got $DownloadedHash. The bad partial was deleted."
        }

        Move-Item -LiteralPath $PartPath -Destination $Destination -Force
        Remove-Item -LiteralPath $PartMetaPath -Force -ErrorAction SilentlyContinue
        $SidecarExpectedSize = $null
        if ($ExpectedSize -gt 0) { $SidecarExpectedSize = $ExpectedSize }
        $Sidecar = [ordered]@{
            label = $Label
            url = $Url
            downloadedAtUtc = [DateTime]::UtcNow.ToString('o')
            expectedSha256 = $WantedHash
            sha256 = $DownloadedHash
            expectedSize = $SidecarExpectedSize
            size = $DownloadedSize
            publisherDigestVerified = [bool]$WantedHash
            alwaysRefresh = [bool]$AlwaysRefresh
            details = $Details
        }
        $Sidecar | ConvertTo-Json -Depth 15 | Set-Content -LiteralPath $SidecarPath -Encoding utf8
        $script:SuccessCount++
        $script:Results.Add([pscustomobject]@{label=$Label;path=$Destination.Substring($Root.Length).TrimStart([char[]]@('\','/'));url=$Url;sha256=$DownloadedHash;publishedDigestVerified=[bool]$WantedHash;bytes=$DownloadedSize;status='downloaded'})
        Write-Log OK "$Label | SHA256 $DownloadedHash"
    }
    catch {
        $script:FailedCount++
        $script:Results.Add([pscustomobject]@{label=$Label;path=$Destination.Substring($Root.Length).TrimStart([char[]]@('\','/'));url=$Url;sha256=$null;publishedDigestVerified=$false;bytes=$null;status='failed';error=$_.Exception.Message})
        Write-Log FAIL "$Label | $($_.Exception.Message)"
    }
}

function Test-AnyPattern {
    param([string]$Name, [string[]]$Patterns)
    foreach ($Pattern in $Patterns) {
        if ($Name -match $Pattern) { return $true }
    }
    return $false
}

function Get-ReleaseAssetsForSource {
    param($Source, [string]$TargetCategory)
    if ($script:ReleaseCache.ContainsKey($Source.repository)) {
        $Release = $script:ReleaseCache[$Source.repository]
    }
    else {
        $Release = Invoke-GitHubApi -Uri "https://api.github.com/repos/$($Source.repository)/releases/latest"
        $script:ReleaseCache[$Source.repository] = $Release
    }
    $ReleaseJsonPath = Get-PathFromRoot -RelativePath "05-Metadata/$($Source.id)-latest-release.json"
    $Release | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $ReleaseJsonPath -Encoding utf8
    Write-Log INFO "$($Source.name): latest release $($Release.tag_name) published $($Release.published_at)"

    $ApplicableRules = @($Source.assets | Where-Object { $_.category -eq $TargetCategory })
    foreach ($Asset in @($Release.assets)) {
        $MatchedRule = $null
        foreach ($Rule in $ApplicableRules) {
            $Patterns = @($Rule.include)
            if ($IncludeAlternateArchitectures -and $Rule.alternateInclude) { $Patterns = @($Rule.alternateInclude) }
            if (Test-AnyPattern -Name $Asset.name -Patterns $Patterns) { $MatchedRule = $Rule; break }
        }
        if ($null -eq $MatchedRule) { continue }
        $Name = Get-SafeFileName -Name $Asset.name
        $Destination = Get-PathFromRoot -RelativePath (Join-Path $MatchedRule.directory $Name)
        Save-Download -Url $Asset.browser_download_url -Destination $Destination -ExpectedDigest $Asset.digest -ExpectedSize ([long]$Asset.size) -Label "$($Source.id) $($Release.tag_name) / $Name" -Details @{ repository=$Source.repository;releaseTag=$Release.tag_name;assetId=$Asset.id;publishedAt=$Release.published_at }
    }

    $MatchedExpected = 0
    foreach ($Rule in $ApplicableRules) {
        $Patterns = @($Rule.include)
        if ($IncludeAlternateArchitectures -and $Rule.alternateInclude) { $Patterns = @($Rule.alternateInclude) }
        if (@($Release.assets | Where-Object { Test-AnyPattern -Name $_.name -Patterns $Patterns }).Count -gt 0) { $MatchedExpected++ }
    }
    if ($ApplicableRules.Count -gt 0 -and $MatchedExpected -eq 0) {
        Write-Log WARN "$($Source.name): no current release assets matched the manifest for $TargetCategory. Review sources.json; upstream filenames may have changed."
    }
}

function Save-SourceArchive {
    param($Source)
    try {
        $RepoUri = "https://api.github.com/repos/$($Source.repository)"
        $Repo = Invoke-GitHubApi -Uri $RepoUri
        $RepoMetaPath = Get-PathFromRoot -RelativePath "05-Metadata/$($Source.id)-repository.json"
        $Repo | ConvertTo-Json -Depth 60 | Set-Content -LiteralPath $RepoMetaPath -Encoding utf8
        $Branch = [string]$Repo.default_branch
        if ([string]::IsNullOrWhiteSpace($Branch)) { throw 'GitHub API returned an empty default branch.' }
        $BranchEscaped = [Uri]::EscapeDataString($Branch)
        $Commit = Invoke-GitHubApi -Uri "https://api.github.com/repos/$($Source.repository)/commits/$BranchEscaped"
        $Sha = [string]$Commit.sha
        if ($Sha -notmatch '^[0-9a-fA-F]{40}$') { throw "Unexpected commit SHA returned for ${Branch}: $Sha" }
        $ShortSha = $Sha.Substring(0, 12).ToLowerInvariant()
        $Slug = $Source.id -replace '[^a-zA-Z0-9._-]', '-'
        $FileName = "$Slug-$ShortSha-source.zip"
        $Url = "https://codeload.github.com/$($Source.repository)/zip/$Sha"
        $Destination = Get-PathFromRoot -RelativePath "03-Source-Code/$FileName"
        Save-Download -Url $Url -Destination $Destination -Label "$($Source.repository) source @ $ShortSha" -Details @{repository=$Source.repository;defaultBranch=$Branch;commitSha=$Sha;archiveFormat='zip'}
    }
    catch {
        $script:FailedCount++
        Write-Log FAIL "Source archive $($Source.repository): $($_.Exception.Message)"
    }
}

function Save-ConfigSnapshots {
    foreach ($Snapshot in @($Manifest.configSnapshots)) {
        $DestinationDir = Get-PathFromRoot -RelativePath $Snapshot.directory
        $FileName = Get-SafeFileName -Name $Snapshot.name
        $Destination = Join-Path $DestinationDir $FileName
        Save-Download -Url $Snapshot.url -Destination $Destination -Label "config snapshot $($Snapshot.id)" -AlwaysRefresh -Details @{snapshotId=$Snapshot.id;securityNote=$Snapshot.securityNote}
    }
}

$DoAndroid = $Category -in @('All', 'Android')
$DoWindows = $Category -in @('All', 'Windows')
$DoSources = $Category -in @('All', 'Source')
$DoConfigs = $Category -in @('All', 'Configs')

Write-Host "NetFallback | category=$Category | alternate architectures=$([bool]$IncludeAlternateArchitectures) | dry run=$([bool]$DryRun)" -ForegroundColor Cyan
Write-Host "Project root: $Root`n"

if ($DoAndroid -or $DoWindows) {
    foreach ($Source in @($Manifest.sources | Where-Object { $_.release -eq $true })) {
        $Targets = @()
        if ($DoAndroid -and @($Source.assets | Where-Object category -eq 'Android').Count -gt 0) { $Targets += 'Android' }
        if ($DoWindows -and @($Source.assets | Where-Object category -eq 'Windows').Count -gt 0) { $Targets += 'Windows' }
        foreach ($Target in $Targets) {
            try { Get-ReleaseAssetsForSource -Source $Source -TargetCategory $Target }
            catch { $script:FailedCount++; Write-Log FAIL "Release lookup $($Source.repository): $($_.Exception.Message)" }
        }
    }
}

if ($DoSources) {
    foreach ($Source in @($Manifest.sources | Where-Object { $_.sourceArchive -eq $true })) {
        Save-SourceArchive -Source $Source
    }
}

if ($DoConfigs) { Save-ConfigSnapshots }

# Write a local report and checksum inventory. They are excluded by .gitignore.
$ReportPath = Join-Path $Root 'DOWNLOAD-REPORT.txt'
$Summary = @(
    'NetFallback download report',
    "Completed UTC: $([DateTime]::UtcNow.ToString('o'))",
    "Category: $Category",
    "Alternate architectures: $([bool]$IncludeAlternateArchitectures)",
    "Dry run: $([bool]$DryRun)",
    "Downloaded: $script:SuccessCount",
    "Skipped: $script:SkippedCount",
    "Failed: $script:FailedCount",
    '',
    'Detailed log:',
    ($script:LogLines -join "`n")
)
$Summary | Set-Content -LiteralPath $ReportPath -Encoding utf8

if (-not $DryRun) {
    $ChecksumPath = Join-Path $Root 'SHA256SUMS-local.txt'
    $HashLines = foreach ($File in Get-ChildItem -LiteralPath $Root -File -Recurse | Where-Object {
        $_.FullName -ne $ChecksumPath -and $_.FullName -ne $ReportPath -and
        $_.Name -notlike '*.part' -and $_.Name -notlike '*.part.meta.json' -and
        $_.Name -notlike '*.download.json' -and $_.FullName -notmatch '[\\/]\.git[\\/]'
    }) {
        try {
            $Hash = Get-Sha256 -Path $File.FullName
            $Relative = $File.FullName.Substring($Root.Length).TrimStart([char[]]@('\','/'))
            "$Hash  $Relative"
        }
        catch { "HASH_FAILED  $($File.FullName)" }
    }
    $HashLines | Set-Content -LiteralPath $ChecksumPath -Encoding utf8

    $ManifestOut = [ordered]@{
        project = 'NetFallback'
        generatedAtUtc = [DateTime]::UtcNow.ToString('o')
        category = $Category
        downloaded = $script:SuccessCount
        skipped = $script:SkippedCount
        failed = $script:FailedCount
        items = @($script:Results)
    }
    $ManifestOut | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $Root 'NetFallback-download-manifest.json') -Encoding utf8
}

Write-Host "`nFinished. Downloaded=$script:SuccessCount; skipped=$script:SkippedCount; failed=$script:FailedCount" -ForegroundColor Cyan
Write-Host "Report: $ReportPath"
if ($script:FailedCount -gt 0) {
    Write-Host 'Some items failed. Inspect DOWNLOAD-REPORT.txt; rerun the same command to retry.' -ForegroundColor Yellow
    exit 1
}
