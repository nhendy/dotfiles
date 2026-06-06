#!/usr/bin/env bash
# validate.sh — non-destructive health checks for the dev environment.
# Exits non-zero if any HARD check fails. Usage: ~/dotfiles/validate.sh
set -uo pipefail
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

pass=0; fail=0; warn=0
PASS(){ printf '  \033[1;32mPASS\033[0m  %s\n' "$*"; pass=$((pass+1)); }
FAIL(){ printf '  \033[1;31mFAIL\033[0m  %s\n' "$*"; fail=$((fail+1)); }
WARN(){ printf '  \033[1;33mWARN\033[0m  %s\n' "$*"; warn=$((warn+1)); }
hdr(){ printf '\n\033[1;34m== %s ==\033[0m\n' "$*"; }

# check_cmd <name> [version-flag]
check_cmd() {
  local name="$1" flag="${2:---version}"
  if command -v "$name" >/dev/null 2>&1; then
    PASS "$name — $("$name" $flag 2>&1 | head -1)"
  else
    FAIL "$name not found"
  fi
}

hdr "CLI tooling"
check_cmd brew
check_cmd nvim
check_cmd tmux -V
check_cmd fzf
check_cmd rg
check_cmd fd
check_cmd bat
check_cmd eza
check_cmd zoxide
check_cmd starship
check_cmd delta
check_cmd lazygit --version
check_cmd gh
check_cmd jj
check_cmd uv
check_cmd node
check_cmd git
check_cmd clang-format
check_cmd shfmt

hdr "Shell wiring"
[ "$(basename "${SHELL:-}")" = "zsh" ] && PASS "login shell is zsh ($SHELL)" || WARN "login shell is ${SHELL:-unknown}"
zrc="$HOME/.zshrc"
if [ -L "$zrc" ] && readlink "$zrc" | grep -q dotfiles; then
  PASS ".zshrc -> $(readlink "$zrc")"
else
  WARN ".zshrc is not linked into ~/dotfiles"
fi
for needle in 'starship init' 'zoxide init' 'fzf --zsh' 'fzf-tab' 'zsh-autosuggestions' 'zsh-syntax-highlighting'; do
  grep -q "$needle" "$zrc" 2>/dev/null && PASS "zshrc wires: $needle" || FAIL "zshrc missing: $needle"
done
grep -q '.local/bin' "$zrc" 2>/dev/null && PASS '~/.local/bin kept on PATH' || WARN '~/.local/bin not in zshrc'

hdr "Neovim"
nv="$HOME/.config/nvim"
if [ -L "$nv" ] && [ -d "$nv" ]; then PASS "~/.config/nvim -> $(readlink "$nv")"; else FAIL "~/.config/nvim not linked"; fi
if command -v nvim >/dev/null 2>&1; then
  if perl -e 'alarm shift; exec @ARGV' 60 nvim --headless +qa >/dev/null 2>&1; then
    PASS "nvim starts headlessly without fatal error"
  else
    WARN "nvim headless returned nonzero (plugin/Avante build may be pending)"
  fi
fi
lazydir="$HOME/.local/share/nvim/lazy"
if [ -d "$lazydir" ]; then
  n=$(find "$lazydir" -maxdepth 1 -mindepth 1 -type d | wc -l | tr -d ' ')
  [ "$n" -ge 30 ] && PASS "$n nvim plugins installed" || WARN "only $n nvim plugins installed — launch nvim once to finish"
else
  WARN "no nvim plugins yet — launch nvim once (lazy will install them)"
fi

hdr "tmux"
if command -v tmux >/dev/null 2>&1; then
  if tmux -f "$HOME/.tmux.conf" new-session -d -s _vtest 2>/dev/null; then
    tmux kill-session -t _vtest 2>/dev/null
    PASS "tmux.conf loads; session create/destroy OK"
  else
    WARN "tmux session test failed (check ~/.tmux.conf)"
  fi
fi
[ -d "$HOME/.tmux/plugins/tpm" ] && PASS "TPM installed" || WARN "TPM missing (prefix + I inside tmux)"

hdr "git + jj"
ge="$(git config --global user.email 2>/dev/null || true)"
[ -n "$ge" ] && PASS "git user.email = $ge" || FAIL "git user.email is unset"
if command -v jj >/dev/null 2>&1; then
  jj config list >/dev/null 2>&1 && PASS "jj config is valid" || WARN "jj config has an issue"
fi

hdr "uv / ML smoke test (CPU JAX + PyTorch MPS)"
if command -v uv >/dev/null 2>&1; then
  tmp="$(mktemp -d)"
  if (
        cd "$tmp"
        uv venv -q >/dev/null 2>&1
        uv pip install -q numpy torch jax >/dev/null 2>&1
        ./.venv/bin/python - <<'PY'
import torch, jax
print("    torch", torch.__version__, "| mps available:", torch.backends.mps.is_available())
print("    jax  ", jax.__version__, "| devices:", jax.devices())
PY
     ); then
    PASS "uv venv + torch/jax import OK (see versions above)"
  else
    WARN "uv ML smoke test failed (network/wheels) — retry: uv pip install torch jax"
  fi
  rm -rf "$tmp"
fi

hdr "fonts"
brew list --cask 2>/dev/null | grep -q nerd-font && PASS "Nerd Font cask installed" || WARN "Nerd Font cask not found"

hdr "Summary"
printf 'PASS=%d  WARN=%d  FAIL=%d\n' "$pass" "$warn" "$fail"
if [ "$fail" -eq 0 ]; then
  echo "All hard checks passed. ✅  (warnings are usually 'launch nvim once' items)"
  exit 0
else
  echo "Some hard checks failed ❌ — see FAIL lines above."
  exit 1
fi
