# NetFallback

**Connectivity backup toolkit — release downloads, source snapshots, and offline preparation.**

NetFallback helps you prepare before an internet disruption by collecting official releases and source snapshots of selected connectivity tools, preserving useful configuration snapshots locally, and recording provenance and SHA-256 hashes. It is a downloader and archive tool; it does not promise that any tunnel or protocol will work on every ISP or during a complete international-link shutdown.

[نسخه فارسی](README.fa.md) · [Sources](sources.json) · [Security](SECURITY.md) · [Protocol notes](docs/protocols.md)

## What it does

- Uses a maintained JSON manifest instead of hard-coded download URLs for release assets.
- Queries the GitHub Releases API for current published versions.
- Downloads selected Windows and Android assets from official project releases, including published checksum/signature companions where available.
- Archives source code by immutable commit SHA so a source snapshot can be tied to a specific revision.
- Saves metadata and local SHA-256 hashes alongside download reports.
- Keeps downloaded binaries, snapshots, and live configuration files out of Git by default.
- Provides a source-health check workflow and unit tests for the manifest.

## Quick start (Windows)

Requirements:

- Windows 10/11 or Windows Server with PowerShell 7+
- `curl.exe` (included in current Windows builds) for resumable downloads
- GitHub connectivity for the initial download; GitHub API rate limits apply to anonymous requests
- Optional for publishing: Git and GitHub CLI (`gh`), authenticated with `gh auth login`

From a clone or extracted project directory:

```powershell
pwsh -NoProfile -File .\scripts\backup.ps1
```

This downloads the default Windows and Android assets, source archives, and selected config snapshots. Expect several hundred megabytes; `-IncludeAlternateArchitectures` can increase the total substantially. Expect several hundred megabytes; `-IncludeAlternateArchitectures` can increase the total substantially. It does **not** execute downloaded programs.

### Choose what to download

```powershell
# Only Windows packages
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Windows

# Only Android packages (default picks common architectures)
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Android

# All source archives, pinned to current commit SHAs
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Source

# Refresh configuration snapshots
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Configs

# Include alternate Android and Windows architectures (larger download)
pwsh -NoProfile -File .\scripts\backup.ps1 -IncludeAlternateArchitectures

# Preview planned operations without downloading
pwsh -NoProfile -File .\scripts\backup.ps1 -DryRun
```

If the network drops, run the same command again. Large release downloads use `.part` files and attempt to resume with `curl.exe` when the URL and expected digest have not changed.

## Output layout

The download script stores data in the current project directory:

| Path | Contents |
| --- | --- |
| `01-Android/` | Android APKs and Android-specific packages |
| `02-Windows/` | Windows packages |
| `03-Source-Code/` | Source ZIPs named with the pinned commit SHA |
| `04-Configs/` | Mutable configuration snapshots, not safe to trust blindly |
| `05-Metadata/` | Release metadata, repository metadata, keys, and local download records |
| `DOWNLOAD-REPORT.txt` | Per-run result and errors |
| `SHA256SUMS-local.txt` | Local hashes for files in the archive folders |

These are local backup artifacts and are deliberately ignored by Git. Do not force-add them to the public repository.

## Current source set

The exact selection rules live in [`sources.json`](sources.json); current versions are resolved at runtime and are not pinned in README text.

| Tool/project | Purpose in this archive | Official source |
| --- | --- | --- |
| PattNG | Android client and Aether-related workflows | [patterniha/PattNG](https://github.com/patterniha/PattNG) |
| PattN | Windows client and related platforms | [patterniha/PattN](https://github.com/patterniha/PattN) |
| MHRV Rust | Android and Windows builds; relay-based connectivity | [therealaleph/MasterHttpRelayVPN-RUST](https://github.com/therealaleph/MasterHttpRelayVPN-RUST) |
| Aether | User-space proxy client / platform builds | [CluvexStudio/Aether](https://github.com/CluvexStudio/Aether) |
| SNI-Spoofing | Original project release | [patterniha/SNI-Spoofing](https://github.com/patterniha/SNI-Spoofing) |
| SNI Spoofing Rust | Native CLI/UI releases where published | [therealaleph/sni-spoofing-rust](https://github.com/therealaleph/sni-spoofing-rust) |
| Serverless-for-Iran | Project source and selected config snapshots | [patterniha/Serverless-for-Iran](https://github.com/patterniha/Serverless-for-Iran) |
| Free-Configs | Project source and selected config snapshots | [patterniha/Free-Configs](https://github.com/patterniha/Free-Configs) |

This is a curated starting set, not a claim that these are the only or currently working methods. Add or remove entries through a reviewed change to `sources.json`.

## Integrity and trust

- The script checks the SHA-256 `digest` supplied by the GitHub Releases API when one is published. That helps detect corruption, but the digest comes from the same source as the release and is not independent proof that a binary is benign.
- Signature files are downloaded when matching release rules select them. Signature verification is not automatic because trusted keys and project-specific signature formats differ. Follow the publisher's official verification instructions.
- Local `SHA256SUMS-local.txt` records hashes calculated after download; these are integrity records, not publisher signatures.
- Downloads are never executed by NetFallback.
- Config snapshots can contain endpoints or short-lived public proxy entries. Treat them as untrusted input, review before use, and never commit them to this repository.
- Release availability and network reachability vary. A successful download only shows that the source was reachable at that time; it does not prove a connection method works on your ISP.

## Tests and maintenance

Run unit tests:

```powershell
python -m unittest discover -s tests -v
```

Check public source availability manually:

```powershell
python scripts/check_sources.py
```

GitHub Actions runs unit tests on pushes and pull requests, and checks source availability on a schedule or on manual dispatch. Network checks can fail temporarily due to rate limits or upstream outages.

## Publish the repository

To create `power0matin/NetFallback` from this project folder, install Git and GitHub CLI, sign in with `gh auth login`, then run:

```powershell
pwsh -NoProfile -File .\scripts\publish.ps1 -Owner power0matin -Visibility public
```

The publishing script refuses to repoint an existing `origin` remote to a different repository. Review `git status` before publishing. It never adds ignored downloads unless you explicitly force-add them yourself.

## Scope and disclaimer

NetFallback is an independent community toolkit and is not affiliated with the listed projects, GitHub, Cloudflare, Google, or mobile operators. Circumvention tools depend on reachable infrastructure and can stop working without notice. Observe applicable laws, local risks, organizational policies, and each project's license. This repository provides downloads and preparation guidance, not a guarantee of availability or anonymity.

## License

The original NetFallback scripts and documentation are licensed under MIT; see [`LICENSE`](LICENSE). Third-party software and their trademarks remain under their respective owners' terms. See [`NOTICE.md`](NOTICE.md).

## Download a backup through GitHub Actions

Open the Actions tab and run **Build offline backup bundle**.
Choose a category and download the resulting artifact when the run finishes.

The GitHub-hosted runner downloads upstream files directly, avoiding the need
to upload large local files. Artifacts are temporary; download them for
long-term offline storage. Never include personal credentials or private
configurations in a public-repository artifact.
