# Brewfile — installed via `brew bundle`. Idempotent.

# --- Core CLI / editor / multiplexer ---
brew "git"
brew "neovim"
brew "universal-ctags"  # tags backend for the nvim Tagbar outline (<leader>t)
brew "tmux"

# --- Fuzzy finding + modern unix replacements ---
brew "fzf"          # fuzzy finder (Ctrl-T / Ctrl-R / Alt-C)
brew "ripgrep"      # rg — fast grep (used by nvim + shell)
brew "fd"           # fast find (used by fzf + nvim)
brew "bat"          # cat with syntax highlighting
brew "eza"          # modern ls
brew "zoxide"       # smart cd (`z`)
brew "git-delta"    # delta — better git diffs/pager
brew "jq"           # JSON processor
brew "tree"
brew "wget"

# --- Git / VCS UX ---
brew "lazygit"      # git TUI
brew "gh"           # GitHub CLI
brew "jujutsu"      # jj — Git-compatible VCS

# --- Shell prompt + zsh plugins (lean setup, no framework) ---
brew "starship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "fzf-tab"      # fzf-powered tab completion

# --- Python / ML tooling ---
brew "uv"           # Python version + venv + package manager
brew "node"         # required by pyright / ts_ls LSPs and Copilot
brew "rust"         # required to build avante.nvim's native helper

# --- Formatters used by nvim (vim-codefmt) ---
brew "clang-format"
brew "shfmt"

# --- Fonts (Nerd Font for nvim-web-devicons + starship glyphs) ---
cask "font-jetbrains-mono-nerd-font"
