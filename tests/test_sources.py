"""Offline tests for the NetFallback source manifest and downloader assumptions."""
from __future__ import annotations

import json
import re
import unittest
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = json.loads((ROOT / "sources.json").read_text(encoding="utf-8"))


class SourceManifestTests(unittest.TestCase):
    def test_schema_version_supported(self):
        self.assertEqual(MANIFEST.get("schemaVersion"), 1)

    def test_source_ids_are_unique(self):
        ids = [item.get("id") for item in MANIFEST.get("sources", [])]
        self.assertTrue(ids)
        self.assertEqual(len(ids), len(set(ids)))

    def test_repositories_are_well_formed(self):
        for source in MANIFEST.get("sources", []):
            with self.subTest(source=source.get("id")):
                repo = source.get("repository", "")
                self.assertRegex(repo, r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
                self.assertIsInstance(source.get("release"), bool)
                self.assertIsInstance(source.get("sourceArchive"), bool)

    def test_asset_patterns_compile(self):
        for source in MANIFEST.get("sources", []):
            for rule in source.get("assets", []):
                self.assertIn(rule.get("category"), {"Android", "Windows"})
                self.assertTrue(rule.get("directory"))
                patterns = rule.get("include", []) + rule.get("alternateInclude", [])
                self.assertTrue(patterns)
                for pattern in patterns:
                    with self.subTest(source=source.get("id"), pattern=pattern):
                        re.compile(pattern)

    def test_asset_directories_stay_inside_expected_archive_roots(self):
        for source in MANIFEST.get("sources", []):
            for rule in source.get("assets", []):
                directory = rule["directory"].replace("\\", "/")
                self.assertFalse(".." in directory.split("/"))
                self.assertTrue(directory.startswith(("01-Android/", "02-Windows/", "05-Metadata/")))

    def test_config_snapshots_use_https_and_local_config_folder(self):
        snapshot_ids = [item.get("id") for item in MANIFEST.get("configSnapshots", [])]
        self.assertEqual(len(snapshot_ids), len(set(snapshot_ids)))
        for snapshot in MANIFEST.get("configSnapshots", []):
            with self.subTest(snapshot=snapshot.get("id")):
                self.assertEqual(urlparse(snapshot["url"]).scheme, "https")
                self.assertTrue(snapshot["url"].startswith("https://raw.githubusercontent.com/"))
                self.assertTrue(snapshot["directory"].startswith("04-Configs/"))
                self.assertTrue(snapshot.get("securityNote"))

    def test_known_release_asset_names_match_default_rules(self):
        samples = {
            "pattng": ["PattNG_2.3.12-P67_arm64-v8a.apk", "PattNG_2.3.12-P67_universal.apk", "PattNG-public-key.asc"],
            "pattn": ["PattN-windows-64-desktop.zip", "PattN-windows-64.zip", "PattN-public-key.asc"],
            "mhrv-rust": ["mhrv-rs-android-arm64-v8a-v1.9.38.apk", "mhrv-rs-android-universal-v1.9.38.apk", "mhrv-rs-windows-amd64.zip"],
            "aether": ["aether-android-arm64.tar.gz", "aether-android-arm64.tar.gz.sha256", "aether-windows-x86_64.zip", "SHA256SUMS.txt"],
            "sni-spoofing": ["SNI-Spoofing_by_patterniha_v1.rar"],
            "sni-spoofing-rust": ["sni-spoof-rs-windows-amd64.zip"],
        }
        by_id = {item["id"]: item for item in MANIFEST["sources"]}
        for source_id, filenames in samples.items():
            source = by_id[source_id]
            for filename in filenames:
                matched = any(
                    re.search(pattern, filename)
                    for rule in source.get("assets", [])
                    for pattern in rule.get("include", [])
                )
                with self.subTest(source=source_id, filename=filename):
                    self.assertTrue(matched, f"No default asset rule matches {filename}")

    def test_essential_projects_are_present(self):
        repos = {item["repository"] for item in MANIFEST["sources"]}
        required = {
            "patterniha/PattNG",
            "patterniha/PattN",
            "therealaleph/MasterHttpRelayVPN-RUST",
            "CluvexStudio/Aether",
            "patterniha/SNI-Spoofing",
            "therealaleph/sni-spoofing-rust",
            "patterniha/Serverless-for-Iran",
            "patterniha/Free-Configs",
        }
        self.assertTrue(required.issubset(repos))


if __name__ == "__main__":
    unittest.main(verbosity=2)
