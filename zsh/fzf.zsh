# fzf.zsh — fzf options + helpers, sourced by ~/.zshrc.
# Cleaned/modernized rewrite of the old .fzf_config.sh (ag/forgit/cd-override removed).

# Use fd for the default file/dir sources (respects .gitignore, hidden, fast).
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

export FZF_DEFAULT_OPTS="
  --height=60% --layout=reverse --border --info=inline
  --bind 'ctrl-y:execute-silent(echo -n {+} | pbcopy)'
  --bind 'ctrl-/:toggle-preview'
  --preview-window 'right:55%:border-left'
"

# Ctrl-T preview: file contents via bat
if command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || tree -C {} 2>/dev/null'"
fi
# Alt-C preview: directory tree via eza
if command -v eza >/dev/null 2>&1; then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {} 2>/dev/null'"
fi

# fcd — fuzzy-pick a directory and cd into it
fcd() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git . "${1:-.}" 2>/dev/null | fzf +m) && cd "$dir"
}

# fkill — fuzzy-pick a process and kill it (default SIGTERM; pass a signal number to override)
fkill() {
  local pids
  pids=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  [ -n "$pids" ] && echo "$pids" | xargs kill "-${1:-15}"
}
