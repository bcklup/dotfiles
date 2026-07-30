# dotfiles — Claude context

Cross-machine dotfiles (macOS / Ubuntu-Debian / WSL). Managed by **dotbot** symlinks + package manifests.

## Setup / workflow
- Machine setup is Claude-driven via **`SETUP.md`** — read it fully before setting up or updating a machine. Fresh-machine deterministic path: `./bootstrap.sh --profile base|full` (`--skip-packages` / `--skip-links` available).

## Layout (two axes)
- **Links**: `profiles/base|personal|macos.conf.yaml` (dotbot). `base` on every machine; `personal`/`macos` only with `--profile full`.
- **Packages**: `packages/Brewfile.{base,personal}` (macOS), `packages/apt-{base,personal}.txt` (Linux/WSL).
- Config files at repo root + `git/ herdr/ ssh/ nvim/`.
- Adding a dotfile usually needs BOTH a `profiles/*.conf.yaml` link entry and (if a tool) a package-manifest entry.

## Gotchas
- **No git write commands** — the user commits/branches. Read-only git only.
- **Partial machine → reconcile, never overwrite.** Real local files with local changes get merged, not clobbered (SETUP.md Phase 4).
- **Secrets are never committed**: `~/.zshrc.local` (env/keys), `~/.gitconfig.local` (work identity, wins last), SSH keys. All untracked.
- **`base` profile must stay headless-safe** — no macOS-only/GUI deps (Linux/WSL/server run base).
- **`dotbot/` is a git submodule** (vendored) — don't edit it.
