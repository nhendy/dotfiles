#!/usr/bin/env bash
# install.sh — reproducible macOS (Apple Silicon) dev environment for an ML engineer.
# Stack: Homebrew, zsh + starship, neovim (lazy.nvim), tmux, git, jj, uv (JAX/PyTorch).
# Idempotent: safe to re-run. Usage:  ~/dotfiles/install.sh
set -euo pipefail

# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREW_BIN="/opt/homebrew/bin/brew"

c_blue=$'\033[1;34m'; c_green=$'\033[1;32m'; c_yellow=$'\033[1;33m'; c_red=$'\033[1;31m'; c_reset=$'\033[0m'
log()  { printf '\n%s==>%s %s\n' "$c_blue"   "$c_reset" "$*"; }
ok()   { printf '%s  ok%s %s\n'  "$c_green"  "$c_reset" "$*"; }
warn() { printf '%swarn%s %s\n'  "$c_yellow" "$c_reset" "$*"; }
die()  { printf '%s err%s %s\n'  "$c_red"    "$c_reset" "$*" >&2; exit 1; }

# Run a command with a hard timeout (macOS lacks `timeout`; use perl's alarm).
run_with_timeout() { local secs="$1"; shift; perl -e 'alarm shift; exec @ARGV' "$secs" "$@"; }

# Symlink $1 -> $2, backing up an existing *real* (non-symlink) target first.
link() {
  local src="$1" dest="$2"
  [ -e "$src" ] || die "missing source: $src"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    rm -f "$dest"
  elif [ -e "$dest" ]; then
    local bak="$dest.pre-dotfiles.bak"
    warn "backing up existing $dest -> $bak"
    mv "$dest" "$bak"
  fi
  ln -sfn "$src" "$dest"
  ok "linked $dest -> $src"
}

# --------------------------------------------------------------------------- #
phase0_preflight() {
  log "Phase 0 — preflight"
  [ "$(uname -s)" = "Darwin" ] || die "this setup is macOS-only"
  [ "$(uname -m)" = "arm64" ]  || warn "expected Apple Silicon (arm64); continuing anyway"
  if ! xcode-select -p >/dev/null 2>&1; then
    log "installing Xcode Command Line Tools (a GUI dialog may appear)…"
    xcode-select --install || true
    die "rerun install.sh once the Command Line Tools have finished installing"
  fi
  ok "macOS $(sw_vers -productVersion) on $(uname -m); Xcode CLT present"
}

phase1_homebrew() {
  log "Phase 1 — Homebrew"
  if [ ! -x "$BREW_BIN" ] && ! command -v brew >/dev/null 2>&1; then
    log "installing Homebrew — you will be prompted for your login password…"
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$("$BREW_BIN" shellenv)"
  ok "$(brew --version | head -1)"
}

phase2_brew_bundle() {
  log "Phase 2 — brew bundle (this can take several minutes)"
  brew bundle --file="$DOTFILES/Brewfile"
  ok "Brewfile installed"
}

phase3_shell() {
  log "Phase 3 — shell (zsh + starship)"
  link "$DOTFILES/zsh/zshrc"               "$HOME/.zshrc"
  link "$DOTFILES/starship/starship.toml"  "$HOME/.config/starship.toml"
  # aliases.zsh and fzf.zsh are sourced directly from the repo by .zshrc (no symlink needed)
  case "${SHELL:-}" in
    */zsh) ok "login shell is already zsh" ;;
    *)     warn "login shell is ${SHELL:-unknown}; switch with: chsh -s /bin/zsh" ;;
  esac
}

phase4_neovim() {
  log "Phase 4 — neovim (reusing nhendy/myvimrc lua config)"
  local repo="$DOTFILES/external/myvimrc"
  if [ -d "$repo/.git" ]; then
    git -C "$repo" pull --ff-only >/dev/null 2>&1 || warn "could not fast-forward myvimrc clone"
  else
    mkdir -p "$DOTFILES/external"
    git clone https://github.com/nhendy/myvimrc.git "$repo"
  fi
  link "$repo/nvim" "$HOME/.config/nvim"

  log "installing nvim plugins headlessly (best-effort; finishes on first launch)…"
  run_with_timeout 240 nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 \
    || warn "Lazy restore was partial/timed out — open nvim once to finish"
  run_with_timeout 240 nvim --headless "+TSUpdate" +qa >/dev/null 2>&1 \
    || warn "TSUpdate was partial/timed out — :TSUpdate on first launch"
  ok "neovim config linked (Mason LSPs + Avante build complete on first interactive launch)"
}

phase5_tmux() {
  log "Phase 5 — tmux"
  link "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"
  if [ ! -d "$HOME/.tmux/plugins/tpm/.git" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 \
    || warn "tpm install_plugins reported an issue (run prefix + I inside tmux)"
  ok "tmux configured (prefix = Ctrl-s)"
}

phase6_git_jj() {
  log "Phase 6 — git + jj"
  link "$DOTFILES/git/gitconfig"        "$HOME/.gitconfig"
  link "$DOTFILES/git/gitignore_global" "$HOME/.config/git/ignore"
  link "$DOTFILES/jj/config.toml"       "$HOME/.config/jj/config.toml"
  ok "git + jj configured ($(git config --global user.email))"
}

phase7_python_uv() {
  log "Phase 7 — python / uv (local CPU JAX + PyTorch MPS for prototyping)"
  uv python install 3.12 || warn "uv python install 3.12 failed (rerun later)"
  mkdir -p "$HOME/dev"
  local tmpl="$HOME/dev/ml-template"
  if [ ! -d "$tmpl" ]; then
    log "creating example uv ML project at $tmpl …"
    (
      cd "$HOME/dev"
      uv init ml-template >/dev/null 2>&1
      cd ml-template
      uv add numpy torch jax >/dev/null 2>&1
      uv add --dev pytest ruff ipython >/dev/null 2>&1
    ) || warn "ml-template bootstrap was partial — see README (network/wheels)"
  fi
  ok "uv ready (managed Python 3.12). Example project: ~/dev/ml-template"
}

phase8_fonts() {
  log "Phase 8 — fonts"
  if brew list --cask 2>/dev/null | grep -q nerd-font; then
    ok "Nerd Font installed — set your terminal font to 'JetBrainsMono Nerd Font'"
  else
    warn "Nerd Font cask not found; rerun: brew bundle --file=$DOTFILES/Brewfile"
  fi
}

summary() {
  cat <<EOF

${c_green}=================  SETUP COMPLETE  =================${c_reset}

Open a NEW terminal (or run: exec zsh), then finish these one-time steps:

  1. Terminal font  : set iTerm2/Terminal font to "JetBrainsMono Nerd Font"
  2. nvim Copilot   : open nvim, run  :Copilot auth
  3. nvim Avante    : store your OpenAI key in the macOS Keychain once —
       security add-generic-password -a "\$USER" -s AVANTE_OPENAI_API_KEY -w 'sk-...'
     then open nvim and run  :AvanteBuild   (compiles a Rust helper; restart after)
  4. (optional)     : gh auth login ; create a private GitHub repo and push ~/dotfiles

Validate everything:  ${c_blue}$DOTFILES/validate.sh${c_reset}
EOF
}

main() {
  phase0_preflight
  phase1_homebrew
  phase2_brew_bundle
  phase3_shell
  phase4_neovim
  phase5_tmux
  phase6_git_jj
  phase7_python_uv
  phase8_fonts
  summary
}
main "$@"
