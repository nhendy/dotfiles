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
# NOTE: `gd` and `gco` are deliberately NOT defined here -- forgit (sourced from
# zshrc right after this file) claims both: gd = interactive diff viewer,
# gco = interactive commit picker. gco takes NO argument, so to switch branches
# use gcb/gsw (forgit's interactive pickers) or type `git checkout <ref>` in full.
alias g='git'
alias gst='git status -sb'
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

# typst: create a new note from the template and open it in Cursor.
# usage: typnew "My Title" [filename-without-ext]   (dir via $NOTES_DIR)
typnew() {
  emulate -L zsh
  local notes_dir="${NOTES_DIR:-$HOME/dev/notes}"
  local title="${1:-Untitled}"
  local name="${2:-}"

  if [[ -z "$name" ]]; then
    name="${title:l}"                        # lowercase
    name="${name//[^a-z0-9]/-}"              # non-alnum -> dash
    while [[ "$name" == *--* ]]; do name="${name//--/-}"; done
    name="${name#-}"; name="${name%-}"       # trim leading/trailing dashes
    [[ -z "$name" ]] && name="untitled"
  fi

  local file="$notes_dir/$name.typ"
  [[ -d "$notes_dir" ]] || { print -u2 "typnew: notes dir not found: $notes_dir (set NOTES_DIR)"; return 1; }
  [[ -e "$file" ]] && { print -u2 "typnew: already exists: $file"; return 1; }

  if [[ -f "$notes_dir/template.typ" ]]; then
    cp "$notes_dir/template.typ" "$file"
    local esc="${title//\\/\\\\}"; esc="${esc//\//\\/}"; esc="${esc//&/\\&}"
    sed -i '' -E "s/(notes\.with\(title: \")[^\"]*(\"\))/\1${esc}\2/" "$file"
  else
    printf '#import "lib/notes.typ": *\n#show: notes.with(title: "%s")\n\n' "$title" > "$file"
  fi

  print "Created $file"
  local cursor_bin="cursor"
  command -v cursor >/dev/null 2>&1 || cursor_bin="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
  "$cursor_bin" "$file"
}
