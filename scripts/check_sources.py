#!/usr/bin/env python3
"""Check that NetFallback's declared upstream repositories, releases, and snapshots exist."""
from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "sources.json"
USER_AGENT = "NetFallback-source-check/1.0 (+https://github.com/power0matin/NetFallback)"


def fetch_json(url: str) -> Any:
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": USER_AGENT,
        "X-GitHub-Api-Version": "2022-11-28",
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    request = urllib.request.Request(url, headers=headers)
    last_error: Exception | None = None
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=25) as response:
                if response.status != 200:
                    raise RuntimeError(f"HTTP {response.status}")
                raw = response.read()
            return json.loads(raw.decode("utf-8"))
        except Exception as exc:  # network and API errors should be visible in CI
            last_error = exc
            if attempt < 2:
                time.sleep(2 * (attempt + 1))
    raise RuntimeError(f"GET {url} failed: {last_error}")


def fetch_url(url: str) -> tuple[int, int]:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT}, method="GET")
    with urllib.request.urlopen(request, timeout=25) as response:
        sample = response.read(256)
        if response.status != 200:
            raise RuntimeError(f"HTTP {response.status}")
        return response.status, len(sample)


def main() -> int:
    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"FAIL manifest: {exc}")
        return 2

    errors: list[str] = []
    sources = manifest.get("sources", [])
    for source in sources:
        repo = source.get("repository", "")
        label = source.get("name", source.get("id", repo))
        if not repo or "/" not in repo:
            errors.append(f"{label}: invalid repository value {repo!r}")
            continue
        try:
            repo_data = fetch_json(f"https://api.github.com/repos/{repo}")
            print(f"OK repository: {repo} (default branch: {repo_data.get('default_branch', '?')})")
        except Exception as exc:
            errors.append(f"{label}: repository check failed: {exc}")
            continue
        if source.get("release"):
            try:
                release = fetch_json(f"https://api.github.com/repos/{repo}/releases/latest")
                assets = release.get("assets", [])
                if not release.get("tag_name"):
                    raise RuntimeError("latest release has no tag_name")
                print(f"OK latest release: {repo}@{release['tag_name']} ({len(assets)} assets)")
            except Exception as exc:
                errors.append(f"{label}: latest release check failed: {exc}")

    for snapshot in manifest.get("configSnapshots", []):
        url = snapshot.get("url", "")
        label = snapshot.get("id", url)
        try:
            status, sample_size = fetch_url(url)
            if sample_size <= 0:
                raise RuntimeError("empty response body")
            print(f"OK snapshot: {label} (HTTP {status})")
        except Exception as exc:
            errors.append(f"{label}: snapshot check failed: {exc}")

    if errors:
        print("\nSource checks failed:")
        for error in errors:
            print(f"- {error}")
        print("\nSome failures can be temporary (rate limits, upstream downtime, or blocking).")
        return 1
    print(f"\nAll {len(sources)} repositories and {len(manifest.get('configSnapshots', []))} snapshots passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
