# dotfiles

Cross-machine dotfiles for macOS, Ubuntu/Debian, and WSL. Split into two
profiles so a machine only gets what it should:

- **base** — essentials for **any** machine (dev tooling, CLI, editors,
  professional apps). The work/office-laptop set.
- **full** — base **+** personal (games/hobby packages, macOS GUI configs,
  personal project aliases). The personal-laptop set.

## Setup

**The intended way is to drive setup with Claude Code**, which reads
[`SETUP.md`](SETUP.md), detects the OS, picks the profile, and — crucially — on a
machine that's already partly configured, **reconciles** existing files instead
of overwriting them.

```zsh
# prerequisites: git (+ Xcode CLT on macOS: xcode-select --install)
git clone git@github.com-bcklup:bcklup/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
# then, in Claude Code:  "set up this machine using SETUP.md"
```

For a **fresh** machine you can also run the deterministic helper directly:

```zsh
./bootstrap.sh --profile base   # essentials only (work/office machine)
./bootstrap.sh --profile full   # + personal (personal machine)
```

## Layout

```
bootstrap.sh            # deterministic fresh-machine setup (packages + links)
SETUP.md                # Claude-driven setup: OS detect, profile, fresh-vs-merge
profiles/
  base.conf.yaml        # links applied on every machine
  personal.conf.yaml    # links applied only with --profile full
  macos.conf.yaml       # macOS-only personal links (karabiner, iTerm2)
packages/
  Brewfile.base         Brewfile.personal      # macOS
  apt-base.txt          apt-personal.txt        # Ubuntu / WSL
dotbot/                 # symlink engine (submodule)
.zshrc .zprofile .p10k.zsh .gitconfig           # base configs
.zshrc.personal .gitconfig-personal ssh/config herdr/  # personal configs
karabiner.json com.googlecode.iterm2.plist      # macOS personal configs
```

## Machine-local (never committed)

- `~/.zshrc.local` — secrets / per-machine env (sourced by `.zshrc`).
- `~/.gitconfig.local` — per-machine git identity override (e.g. a work email);
  included last so it wins.
- SSH keys — generated per machine and registered against the host aliases in
  `ssh/config`; never stored in this repo.
