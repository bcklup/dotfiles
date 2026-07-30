# SETUP.md — machine setup, driven by Claude Code

You (Claude) use this to set up or update a machine from this repo. Work through
the phases in order. **Never run git write commands** (the user commits). Prefer
sensible defaults; only stop when genuinely blocked.

## Concepts

- **Profiles** — `base` = essentials for any machine (dev/CLI/editors/pro apps).
  `full` = base **+** personal (games/hobby, macOS GUI configs). Base is the
  work/office-laptop set; full is the personal-laptop set.
- **Layers on disk** — `profiles/*.conf.yaml` (dotbot links), `packages/Brewfile.*`
  + `packages/apt-*.txt`, and the config files at the repo root / `config` dirs.
- **Secrets** are never in the repo: machine-local values go in untracked
  `~/.zshrc.local`; a work git identity goes in untracked `~/.gitconfig.local`.

## Phase 1 — Detect

1. **OS**: `uname -s` → Darwin = macOS; Linux with `microsoft`/`wsl` in
   `/proc/version` = WSL; else Linux.
2. **Fresh vs partial**: check whether the managed targets already exist
   (`~/.zshrc`, `~/.gitconfig`, `~/.ssh/config`, `~/.config/herdr/config.toml`, …).
   - None present / brand-new box → **fresh**.
   - Some present (especially as *real files*, not already symlinks into this
     repo) → **partial** — use the merge flow (Phase 4), do not overwrite.
3. **Profile**: ask the user `base` or `full` (default `base` for anything that
   looks like a work machine). One question, then proceed.

## Phase 2 — Packages

- **macOS**: ensure Homebrew, then `brew bundle --file packages/Brewfile.base`;
  if `full`, also `packages/Brewfile.personal`.
- **Linux/WSL**: `sudo apt-get update`, install `packages/apt-base.txt`
  (`full` → also `apt-personal.txt`). Tools not in apt (eza, git-delta, lazygit,
  zoxide, tlrc) — install best-effort via cargo/GitHub releases and tell the user
  which you skipped.
- Skip packages the user already has; don't reinstall wholesale.

## Phase 3 — Fresh machine (links)

Run the deterministic path:
```bash
./bootstrap.sh --profile <base|full>        # packages + links
# or just links:  ./bootstrap.sh --profile <base|full> --skip-packages
```
`bootstrap.sh` links `base`, then (if `full`) `personal`, then (if `full` +
macOS) `macos`. Verify every symlink resolves and `~/.zshrc` sources cleanly.

## Phase 4 — Partial machine (reconcile, don't overwrite)

Do **not** run the forced dotbot links. Instead, for each file the chosen
profile would manage:

1. Compare the existing target with the repo version (`diff` / `git diff --no-index`).
2. Decide per file, and tell the user your call:
   - **identical / already our symlink** → nothing to do.
   - **target is a real file with local changes worth keeping** → merge the
     meaningful local bits into the repo file, then link. Surface anything that
     genuinely conflicts and let the user choose.
   - **target is stale / superseded by the repo** → back it up to `*.bak`, then link.
3. Pay special attention to files this repo does **not** currently link but that
   commonly exist locally — e.g. `~/.config/nvim`, `~/.tmux.conf`,
   `~/.gitconfig-work` — flag drift; never clobber a real one silently.
4. After reconciling, create the links (dotbot per-profile, or `ln -s` for the
   individual files you resolved).

## Phase 5 — Manual steps & secrets (Claude: print this checklist, then STOP)

These are intentionally **not** in the repo and can't be automated. End the setup
by showing the user this checklist so nothing is silently missing. Only tick the
lines that apply to this machine/profile.

**Secrets & environment** (untracked, recreate from a password manager)
- [ ] `~/.zshrc.local` — machine-local secrets/env (e.g. `FONTAWESOME_TOKEN`, API keys). Sourced by `.zshrc`.
- [ ] Per-project `.env` files — never tracked; restore per repo.

**Git identity & accounts**
- [ ] `~/.gitconfig.local` — on a work/office machine, set the work identity: `[user]\n  email = you@work.com` (included last, so it wins).
- [ ] `~/.gitconfig-work` — recreate the untracked work multi-account include if this machine does work.

**SSH keys** (never in the repo)
- [ ] Generate a key per account matching the aliases in `ssh/config` (e.g. `~/.ssh/id_ed25519-personal`).
- [ ] `ssh-add` the keys; upload the public keys to GitHub (personal `github.com-bcklup`, and work).
- [ ] Test: `ssh -T git@github.com-bcklup`.

**CLI auth**
- [ ] `gh auth login`; Claude Code login; any cloud CLIs (aws / gcloud) as needed.

**Runtimes**
- [ ] `nvm install --lts` (+ any project Node versions); `corepack enable`; global npm packages.
- [ ] `rbenv install <version>` if this machine needs Ruby.

**macOS only — permissions & config load**
- [ ] Grant Accessibility / Input Monitoring to Karabiner-Elements, Raycast, Rectangle.
- [ ] Restart Karabiner-Elements and iTerm2 so the linked configs load (iTerm2: point "Load preferences from a custom folder" at the linked plist if not auto-detected).
- [ ] Sign into apps (browser, password manager, Slack, etc.).

**Not auto-managed (handle manually if wanted)**
- [ ] VS Code / Cursor settings — use their built-in Settings Sync, or copy `settings.json` / `keybindings.json`.
- [ ] Raycast config, browser profiles.

**Finally**
- [ ] Restart the shell / terminal so zsh and all config reload.

## Guardrails

- No git writes — leave staging/committing to the user.
- On a partial machine, **reconcile before you link**; overwriting is the failure mode.
- Base must stay headless-safe (no macOS-only or GUI deps), so a Linux/WSL or
  server base install works.
