#!/usr/bin/env bash
# bootstrap.sh — deterministic setup for a FRESH machine.
#
# Usage:
#   ./bootstrap.sh [--profile base|full] [--skip-packages] [--skip-links]
#
#   --profile base   (default) essentials only — for work/office machines
#   --profile full   essentials + personal (games/hobby, macOS GUI configs)
#   --skip-packages  link dotfiles only, don't install packages
#   --skip-links     install packages only, don't link dotfiles
#
# For a machine that's ALREADY partially set up, don't run this blindly — drive
# the setup with Claude Code via SETUP.md, which reconciles existing files
# instead of overwriting them.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="base"
DO_PACKAGES=1
DO_LINKS=1

while [ $# -gt 0 ]; do
  case "$1" in
    --profile) PROFILE="${2:-base}"; shift 2 ;;
    --skip-packages) DO_PACKAGES=0; shift ;;
    --skip-links) DO_LINKS=0; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done
[ "$PROFILE" = "base" ] || [ "$PROFILE" = "full" ] || { echo "profile must be base|full" >&2; exit 1; }

# --- detect OS ---
detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      if grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then echo wsl; else echo linux; fi ;;
    *) echo unknown ;;
  esac
}
OS="$(detect_os)"
echo "==> OS: $OS   profile: $PROFILE"

# --- packages ---
install_packages_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "==> installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  echo "==> brew bundle (base)"
  brew bundle --file "$REPO/packages/Brewfile.base"
  if [ "$PROFILE" = "full" ]; then
    echo "==> brew bundle (personal)"
    brew bundle --file "$REPO/packages/Brewfile.personal"
  fi
}

install_packages_apt() {
  echo "==> apt-get update"
  sudo apt-get update -y
  local list="$REPO/packages/apt-base.txt"
  # shellcheck disable=SC2046
  sudo apt-get install -y $(grep -vE '^\s*#|^\s*$' "$list" | tr '\n' ' ')
  if [ "$PROFILE" = "full" ] && [ -s "$REPO/packages/apt-personal.txt" ]; then
    sudo apt-get install -y $(grep -vE '^\s*#|^\s*$' "$REPO/packages/apt-personal.txt" | tr '\n' ' ') || true
  fi
  echo "==> NOTE: eza, git-delta, lazygit, zoxide, tlrc may need manual install on Linux (cargo/GitHub releases)."
}

if [ "$DO_PACKAGES" -eq 1 ]; then
  case "$OS" in
    macos) install_packages_macos ;;
    linux|wsl) install_packages_apt ;;
    *) echo "==> unknown OS, skipping packages" ;;
  esac
fi

# --- links (dotbot) ---
run_dotbot() {
  git -C "$REPO/dotbot" submodule sync --quiet --recursive 2>/dev/null || true
  git -C "$REPO" submodule update --init --recursive dotbot
  local cfg="$1"
  echo "==> linking: $(basename "$cfg")"
  "$REPO/dotbot/bin/dotbot" -d "$REPO" -c "$cfg"
}

if [ "$DO_LINKS" -eq 1 ]; then
  run_dotbot "$REPO/profiles/base.conf.yaml"
  if [ "$PROFILE" = "full" ]; then
    run_dotbot "$REPO/profiles/personal.conf.yaml"
    [ "$OS" = "macos" ] && run_dotbot "$REPO/profiles/macos.conf.yaml"
  fi
fi

echo
echo "==> done ($OS, $PROFILE)."
echo "    Next: generate + register SSH keys, set machine-local secrets in ~/.zshrc.local,"
echo "    and (work machine) set your work git identity in ~/.gitconfig.local."
