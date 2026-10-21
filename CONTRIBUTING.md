# Contributing

Contributions that improve reliability, clarity, and verification are welcome.

## Source additions/changes

1. Update `sources.json` with an official upstream repository and a short purpose statement.
2. Use release assets or source archives directly from the upstream project. Avoid link shorteners and third-party mirrors unless the upstream explicitly designates them.
3. Match asset names narrowly enough not to download unrelated builds. Keep `-IncludeAlternateArchitectures` behavior documented.
4. Add tests for new manifest properties or selection rules.
5. Explain any mutable config snapshot and its security implications. Do not commit live config contents or credentials.
6. Run `python -m unittest discover -s tests -v` and `python scripts/check_sources.py` before submitting when your network allows it.

## General rules

- Do not claim a method currently works on a specific ISP without dated, reproducible evidence.
- Keep download execution separate from installation/execution of third-party binaries.
- Avoid pushing binaries into this repository; use local ignored output directories.
- Keep documentation factual, concise, and clear about limitations.
