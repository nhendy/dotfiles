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
brew "forgit"       # interactive git via fzf; plugin sourced in zsh/zshrc

# --- Shell prompt + zsh plugins (lean setup, no framework) ---
tap "olets/tap"     # source for zsh-abbr (not in homebrew-core)
brew "starship"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "fzf-tab"                      # fzf-powered tab completion
brew "zsh-completions"             # extra completion defs (added to fpath pre-compinit)
brew "zsh-you-should-use"          # nags when an alias exists for a command
brew "zsh-history-substring-search" # substring history search on Up/Down
brew "olets/tap/zsh-abbr"          # fish-style inline abbreviations

# --- Python / ML tooling ---
brew "uv"           # Python version + venv + package manager
brew "node"         # required by pyright / ts_ls LSPs and Copilot
brew "rustup"       # Rust toolchain manager. Keg-only: its proxies live in
                    # $(brew --prefix rustup)/bin, added to PATH in zsh/zshrc.
                    # Do NOT add brew "rust" — it shadows the rustup proxies and
                    # breaks per-project rust-toolchain.toml pins (and rust-analyzer).

# --- C/C++ build systems (clangd needs these to emit compile_commands.json) ---
brew "cmake"
brew "ninja"
brew "bazelisk"     # bazel launcher; respects each repo's .bazelversion

# --- Formatters used by nvim (vim-codefmt) ---
brew "clang-format"
brew "shfmt"

# --- Fonts (Nerd Font for nvim-web-devicons + starship glyphs) ---
cask "font-jetbrains-mono-nerd-font"
