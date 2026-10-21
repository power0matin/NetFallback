# Security policy

## Scope

Please report security issues in NetFallback's own scripts, tests, workflow, or documentation. This project downloads third-party binaries and mutable config snapshots; it does not audit those upstream projects or guarantee their safety.

## Safe handling

- Downloaded files are never executed by the script.
- A SHA-256 digest from the GitHub Releases API is checked if the publisher exposes one.
- A local hash or upstream digest is not a substitute for a trusted digital signature.
- Treat all downloaded executables, archives, configs, domains, and endpoints as untrusted until reviewed.
- Do not place credentials, private relay URLs, personally identifying data, or secret configs in a public issue or commit.
- Do not force-add contents of `01-Android/`, `02-Windows/`, `03-Source-Code/`, `04-Configs/`, or `05-Metadata/` to Git without understanding exactly what they contain.

## Reporting

Open a private security advisory on GitHub if the repository supports it. If not, contact the repository owner through a private channel listed on their GitHub profile. Include reproduction steps and the affected commit, but do not publish exploit details before coordinating a fix.
