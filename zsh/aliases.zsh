# aliases.zsh — sourced by ~/.zshrc

# editor
alias vim='nvim'
alias vi='nvim'

# modern unix replacements (guarded so a missing tool won't break the shell)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --git --group-directories-first'
  alias la='eza -a'
  alias lt='eza --tree --level=2'
fi
command -v bat     >/dev/null 2>&1 && alias cat='bat --style=plain --paging=never'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

# git
alias g='git'
alias gst='git status -sb'
alias gco='git checkout'
alias gd='git diff'
alias gp='git push'
alias gl='git pull'
alias glg='git lg'

# tmux
alias tn='tmux new -s'
alias ta='tmux attach -t'
alias tl='tmux ls'

# uv / python (local CPU JAX + PyTorch MPS lives per-project)
alias uvr='uv run'
alias uvs='uv sync'
alias uva='uv add'
alias py='uv run python'

# navigation / housekeeping
alias dev='cd ~/dev'
alias dotfiles='cd ~/dotfiles'
alias zshconfig='$EDITOR ~/dotfiles/zsh/zshrc'
alias reload='exec zsh'
