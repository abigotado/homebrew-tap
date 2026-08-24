# homebrew-tap

Homebrew tap for [abigotado](https://github.com/abigotado)'s tools.

```bash
brew install abigotado/tap/jira-agent-cli
brew install --cask abigotado/tap/trello-cli
```

`abigotado/tap` is shorthand for this repository — Homebrew expands it to
`github.com/abigotado/homebrew-tap`, which is the only reason the repository
carries the `homebrew-` prefix.

## Contents

| Package | Type | Source | What it is |
| --- | --- | --- | --- |
| `jira-agent-cli` | Formula | [abigotado/jira-cli](https://github.com/abigotado/jira-cli) | Agent-first Jira Cloud CLI for Codex and Claude Code |
| `trello-cli` | Cask | [abigotado/trello-cli](https://github.com/abigotado/trello-cli) | Manage Trello from the command line, or from an AI agent shelling out to it |

The `jira-agent-cli` Formula builds locally from a checksummed source release
and installs the `jira-cli` executable. It is macOS-only because credentials
use the native Security.framework Keychain backend.

The `trello-cli` Cask installs a prebuilt binary from the source project's
GitHub release and verifies it against the SHA-256 recorded in the cask. macOS
and Linux are both covered: `binary` is a portable cask artifact, so the same
cask installs on Linuxbrew. Windows is not — use `go install` or the release
archive.

## Generated Casks

GoReleaser writes these files during the source project's release job and
commits them here. **Do not edit a cask by hand:** the next release overwrites
it, and a hand-edited SHA-256 breaks installation for everyone on that platform
until the following release.

Fix the source project's `.goreleaser.yaml` and cut a release instead.

Formulae under `Formula/` are maintained and tested in this repository.

## Reporting a problem

Open the issue against the corresponding source project. This repository holds
only Homebrew package definitions.
