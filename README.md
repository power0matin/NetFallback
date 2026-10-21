# NetFallback

**An offline connectivity-preparation toolkit** for collecting official releases, source snapshots, selected configuration snapshots, and integrity metadata before an outage.

<p align="center">
  <a href="https://github.com/power0matin/NetFallback/releases/latest/download/NetFallback-All.zip"><img src="https://img.shields.io/github/downloads/power0matin/NetFallback/NetFallback-All.zip?style=flat-square&amp;label=ZIP%20Downloads&amp;labelColor=18181B&amp;color=0EA5E9&amp;logo=github&amp;logoColor=white" alt="Full Bundle Downloads"/></a>
  <a href="https://github.com/power0matin/NetFallback/releases/latest"><img src="https://img.shields.io/github/v/release/power0matin/NetFallback?style=flat-square&amp;label=Latest%20Release&amp;labelColor=18181B&amp;color=22C55E&amp;logo=github&amp;logoColor=white" alt="Latest Release"/></a>
  <a href="https://github.com/power0matin/NetFallback/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/power0matin/NetFallback/ci.yml?branch=main&amp;style=flat-square&amp;label=CI&amp;labelColor=18181B&amp;color=22C55E&amp;logo=github&amp;logoColor=white" alt="CI Status"/></a>
  <a href="https://hits.sh/github.com/power0matin/NetFallback/"><img src="https://hits.sh/github.com/power0matin/NetFallback.svg?style=flat-square&amp;label=Views&amp;labelColor=18181B&amp;color=0EA5E9&amp;logo=github" alt="Repository Views"/></a>
  <a href="https://github.com/power0matin/NetFallback/stargazers"><img src="https://img.shields.io/github/stars/power0matin/NetFallback?style=flat-square&amp;label=Stars&amp;labelColor=18181B&amp;color=F59E0B&amp;logo=github&amp;logoColor=white" alt="GitHub Stars"/></a>
  <a href="https://github.com/power0matin/NetFallback/forks"><img src="https://img.shields.io/github/forks/power0matin/NetFallback?style=flat-square&amp;label=Forks&amp;labelColor=18181B&amp;color=6366F1&amp;logo=github&amp;logoColor=white" alt="GitHub Forks"/></a>
  <a href="https://github.com/power0matin/NetFallback/issues"><img src="https://img.shields.io/github/issues/power0matin/NetFallback?style=flat-square&amp;label=Issues&amp;labelColor=18181B&amp;color=22C55E&amp;logo=github&amp;logoColor=white" alt="GitHub Issues"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/power0matin/NetFallback?style=flat-square&amp;label=License&amp;labelColor=18181B&amp;color=EF4444&amp;logo=github&amp;logoColor=white" alt="GitHub License"/></a>
</p>

**فارسی:** [README فارسی](README.fa.md) · [راهنمای فارسی](GUIDE.fa.md)

## One-click full download

**[Download the complete NetFallback bundle (one ZIP)](https://github.com/power0matin/NetFallback/releases/latest/download/NetFallback-All.zip)**

This stable URL points to the main asset in the latest GitHub Release. The bundle contains selected Windows and Android packages, source archives, selected configuration snapshots, download reports, a SHA-256 inventory, and documentation. The size changes as upstream projects publish new files; allow approximately 1.2 GB for the first release.

See the [latest Release page](https://github.com/power0matin/NetFallback/releases/latest) for the package checksum and standalone Persian guide.

## Quick start

1. Download the ZIP above and extract it to a folder with enough free space.
2. Open **GUIDE.fa.md** for the step-by-step guide; it is also included in the full bundle.
3. Find files under the directory for the relevant operating system or data type. NetFallback does not install or execute downloaded files.
4. Before using any executable or configuration, check its integrity and consult the upstream project's own instructions.

## What's included

| Path | Contents |
| --- | --- |
| **01-Android/** | Selected Android packages and published signature companions where available |
| **02-Windows/** | Selected Windows packages and published signature companions where available |
| **03-Source-Code/** | Source ZIP snapshots tied to specific commit SHAs |
| **04-Configs/** | Selected, mutable public configuration snapshots |
| **05-Metadata/** | Release/repository metadata, public keys, and download records |
| **DOWNLOAD-REPORT.txt** | Download results and any reported errors |
| **SHA256SUMS-local.txt** | Local SHA-256 inventory |
| **NetFallback-download-manifest.json** | Machine-readable result manifest |
| Documentation | READMEs, Persian guide, and protocol notes |

The exact filenames and upstream versions change over time. Selection rules are maintained in [sources.json](sources.json).

## Download only what you need

To download selected categories yourself, clone or extract the source repository and use PowerShell 7 or later. GitHub and upstream sites must be reachable; curl.exe is recommended for resumable downloads.

~~~powershell
# Preview planned operations without downloading
pwsh -NoProfile -File .\scripts\backup.ps1 -DryRun

# Windows packages only
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Windows

# Android packages only
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Android

# Source archives only
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Source

# Selected configuration snapshots only
pwsh -NoProfile -File .\scripts\backup.ps1 -Category Configs

# Include additional architectures (larger download)
pwsh -NoProfile -File .\scripts\backup.ps1 -IncludeAlternateArchitectures
~~~

If a download is interrupted, rerun the same command. The script attempts to resume large partial downloads with curl.exe and writes a report and local hashes. To let GitHub's runner download the files without uploading them from your own connection, open [Actions](https://github.com/power0matin/NetFallback/actions) and run **Build offline backup bundle**.

## Scope and limitations

NetFallback is a downloader and archive tool, not a VPN service or live ISP measurement system. A successful download does not prove that a method works on your ISP, destination, or device at the time you need it. Client software cannot create a new route by itself if every required network path is unavailable.

## Integrity and safe handling

- When GitHub Releases publishes a SHA-256 digest, the downloader compares the downloaded file's SHA-256 with that value.
- SHA256SUMS-local.txt contains locally calculated hashes; it is not independent publisher authentication or proof that a file is benign.
- Signature companions are collected where selected and available, but signatures are not automatically verified. Follow the upstream publisher's verification procedure.
- Treat public configuration snapshots and endpoints as untrusted input. Review them before use.
- Never commit private keys, credentials, private relay endpoints, or confidential configs to this public repository or its Releases.
- Downloaded files are not automatically executed or installed.

## Documentation and maintenance

- [Persian step-by-step guide](GUIDE.fa.md)
- [Protocol notes — Persian](docs/protocols.fa.md)
- [Protocol notes — English](docs/protocols.md)
- [Source manifest](sources.json)
- [Security policy](SECURITY.md)
- [Initial release notes](RELEASE-NOTES-v0.1.0.md)

Run offline tests:

~~~powershell
python -m unittest discover -s tests -v
python -m json.tool sources.json
~~~

The original NetFallback scripts and documentation are licensed under MIT. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md) for third-party software and licensing context.

---

NetFallback is an independent community project and is not officially affiliated with the listed upstream projects, GitHub, Cloudflare, or network operators. Consider applicable laws, upstream licenses, and the risks of third-party software.
