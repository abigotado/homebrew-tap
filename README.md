# homebrew-tap

Homebrew tap for [abigotado](https://github.com/abigotado)'s tools.

```bash
brew install abigotado/tap/jira-agent-cli
```

`abigotado/tap` is shorthand for this repository — Homebrew expands it to
`github.com/abigotado/homebrew-tap`, which is the only reason the repository
carries the `homebrew-` prefix.

## Contents

| Package | Type | Source | What it is |
| --- | --- | --- | --- |
| `jira-agent-cli` | Formula | [abigotado/jira-cli](https://github.com/abigotado/jira-cli) | Agent-first Jira Cloud CLI for Codex and Claude Code |

The `jira-agent-cli` Formula builds locally from a checksummed source release
and installs the `jira-cli` executable. It is macOS-only because credentials
use the native Security.framework Keychain backend.

## Trello CLI migration

The old `trello-cli` Cask was retired because its downloaded macOS executable
was unsigned and its install hook removed `com.apple.quarantine`. Existing
installs are not removed automatically; uninstall one with:

```bash
brew uninstall --cask trello-cli
```

A macOS Formula will return after the native Security.framework backend is in a
stable `trello-cli` tag. It will pin that tag's source archive by SHA-256 and
compile locally instead of installing a downloaded executable. Until that tag
exists, `go install github.com/abigotado/trello-cli/cmd/trello-cli@latest`
still resolves to the previous stable release. To use the unreleased native
backend after it merges, build the source project's `main` branch as documented
in its README. Linux and Windows users can continue to use release archives.

Formulae under `Formula/` are maintained and tested in this repository.

## Reporting a problem

Open the issue against the corresponding source project. This repository holds
only Homebrew package definitions.
