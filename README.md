# homebrew-tap

Homebrew tap for [abigotado](https://github.com/abigotado)'s tools.

```bash
brew install abigotado/tap/jira-agent-cli
brew install abigotado/tap/trello-cli
```

`abigotado/tap` is shorthand for this repository — Homebrew expands it to
`github.com/abigotado/homebrew-tap`, which is the only reason the repository
carries the `homebrew-` prefix.

## Contents

| Package | Type | Source | What it is |
| --- | --- | --- | --- |
| `jira-agent-cli` | Formula | [abigotado/jira-cli](https://github.com/abigotado/jira-cli) | Agent-first Jira Cloud CLI for Codex and Claude Code |
| `trello-cli` | Formula | [abigotado/trello-cli](https://github.com/abigotado/trello-cli) | Agent-first Trello CLI for structured automation |

Both Formulae build locally from checksummed source releases and are macOS-only
because credentials use native Security.framework Keychain backends.

## Trello CLI migration

The old `trello-cli` Cask was retired because its downloaded macOS executable
was unsigned and its install hook removed `com.apple.quarantine`. Existing
installs are not removed automatically. Replace one with the source Formula:

```bash
brew uninstall --cask trello-cli
brew install abigotado/tap/trello-cli
```

The Formula pins the `v0.3.0` source archive by SHA-256 and compiles locally
instead of installing a downloaded executable. Existing macOS Keychain entries
keep the same service and account names, but may require a one-time ACL
migration after upgrading:

```bash
trello-cli auth migrate-keychain
trello-cli auth migrate-keychain --account NAME
```

Run the second command once for each named account. macOS may show a system
authorization prompt, but the Trello API key and token do not need to be entered
again. Linux and Windows users can continue to use release archives.

Formulae under `Formula/` are maintained and tested in this repository.

## Reporting a problem

Open the issue against the corresponding source project. This repository holds
only Homebrew package definitions.
