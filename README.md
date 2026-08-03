# homebrew-tap

Homebrew tap for [abigotado](https://github.com/abigotado)'s tools.

```bash
brew install --cask abigotado/tap/trello-cli
```

`abigotado/tap` is shorthand for this repository — Homebrew expands it to
`github.com/abigotado/homebrew-tap`, which is the only reason the repository
carries the `homebrew-` prefix.

## Contents

| Cask | Source | What it is |
| --- | --- | --- |
| `trello-cli` | [abigotado/trello-cli](https://github.com/abigotado/trello-cli) | Manage Trello from the command line, or from an AI agent shelling out to it |

Casks here install a prebuilt binary from the source project's GitHub release
and verify it against the SHA-256 recorded in the cask. macOS and Linux are both
covered: `binary` is a portable cask artifact, so the same cask installs on
Linuxbrew. Windows is not — use `go install` or the release archive.

## Everything under `Casks/` is generated

GoReleaser writes these files during the source project's release job and
commits them here. **Do not edit a cask by hand:** the next release overwrites
it, and a hand-edited SHA-256 breaks installation for everyone on that platform
until the following release.

Fix the source project's `.goreleaser.yaml` and cut a release instead.

## Reporting a problem

Open the issue against the source project, not here. This repository holds no
code — only the generated cask files.
