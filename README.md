# dotfiles — ML-engineer dev environment (macOS / Apple Silicon)

A reproducible, idempotent setup for a freshly-wiped Mac. Brings up the full
workflow: **zsh + Starship**, **Neovim** (reusing the existing
[`nhendy/myvimrc`](https://github.com/nhendy/myvimrc) lazy.nvim config),
**tmux**, **git** + **jj**, **uv** for Python/ML (JAX + PyTorch), and a set of
modern CLI tools (fzf, ripgrep, fd, bat, eza, zoxide, delta, lazygit, gh).

> Target: Apple Silicon Mac, macOS 14+. zsh is already the macOS default shell.
> Scope is **macOS-only**; heavy model training is expected on **remote GPU boxes**,
> so JAX is installed CPU-only locally and PyTorch uses the Apple **MPS** backend
> for quick local iteration.

---

## Quick start

```bash
git clone <your-dotfiles-repo-url> ~/dotfiles   # or you already have ~/dotfiles
cd ~/dotfiles
chmod +x install.sh validate.sh
./install.sh          # prompts ONCE for your password (Homebrew install)
exec zsh              # or open a new terminal
./validate.sh         # confirm everything is green
```

`install.sh` is safe to re-run; it backs up any pre-existing real dotfile to
`<file>.pre-dotfiles.bak` before symlinking.

---

## What gets installed

| Area | Tools |
|------|-------|
| Package manager | Homebrew (`/opt/homebrew`) |
| Shell | zsh + **Starship** prompt; plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf-tab` |
| Fuzzy / unix | `fzf`, `ripgrep` (rg), `fd`, `bat`, `eza`, `zoxide`, `git-delta`, `jq`, `tree`, `wget` |
| Editor | Neovim + the `nhendy/myvimrc` lua config (lazy.nvim, Mason LSPs, Copilot, Avante) |
| Multiplexer | tmux + TPM plugins (sensible, prefix-highlight, pain-control, sidebar, better-mouse) |
| VCS | git (delta pager), `jj` (Jujutsu), `lazygit`, `gh` |
| Python / ML | `uv` (Python 3.12 managed), `node` (LSPs/Copilot), `rust` (Avante build) |
| Formatters | `clang-format`, `shfmt` (used by nvim) |
| Font | JetBrainsMono Nerd Font |

## Repo layout & symlink map

```
~/dotfiles/
├── install.sh                         orchestrator (idempotent)
├── validate.sh                        health checks (PASS/WARN/FAIL)
├── Brewfile                           all brew formulae + casks
├── zsh/zshrc        ->  ~/.zshrc
├── zsh/aliases.zsh                    (sourced by zshrc from the repo)
├── zsh/fzf.zsh                        (sourced by zshrc from the repo)
├── starship/starship.toml  ->  ~/.config/starship.toml
├── tmux/tmux.conf   ->  ~/.tmux.conf
├── git/gitconfig    ->  ~/.gitconfig
├── git/gitignore_global  ->  ~/.config/git/ignore
├── jj/config.toml   ->  ~/.config/jj/config.toml
└── external/myvimrc                   git clone; nvim/ -> ~/.config/nvim
```

---

## One-time manual steps (after `install.sh`)

1. **Terminal font** — set iTerm2 / Terminal font to **“JetBrainsMono Nerd Font”**
   (Settings → Profiles → Text → Font) so devicons and Starship glyphs render.
2. **Copilot** — open `nvim`, run `:Copilot auth` (needs a Copilot subscription).
   Accept inline suggestions with `Alt-l`.
3. **Avante (OpenAI)** — store the key in the macOS Keychain once:
   ```bash
   security add-generic-password -a "$USER" -s AVANTE_OPENAI_API_KEY -w 'sk-...'
   ```
   Then open `nvim` and run `:AvanteBuild` (compiles a small Rust helper; restart
   nvim afterward). Toggle the Avante panel with `,ae`. If you skip this, the rest
   of nvim still works — Avante just stays off.
4. **(optional) push your dotfiles** — `gh auth login`, create a private repo,
   then `cd ~/dotfiles && git init && git add -A && git commit -m "init" && \
   git branch -M main && git remote add origin <url> && git push -u origin main`.

---

## Cheat sheets

### Neovim  (leader = `,`)
| Key | Action |
|-----|--------|
| `Ctrl-f` | FZF files in cwd |
| `,f` | recent files (MRU) |
| `,a` | ripgrep the word under cursor |
| `,nn` / `,nf` | NERDTree toggle / reveal file |
| `,t` | Tagbar toggle |
| `,z` | Goyo focus mode |
| `,r` / `,R` | QuickRun buffer / with args |
| `,T` | run `pytest` in a vertical split |
| `,c` | format current file (vim-codefmt) |
| `gd` `gr` `gi` `K` `qf` | LSP: definition / refs / impl / hover / code-action |
| `[g` `]g` | prev / next diagnostic |
| `jk` / `kj` | escape insert mode |
| `Ctrl-h/j/k/l` | move between windows |
| `,ae` | toggle Avante (AI) |
| `Alt-l` | accept Copilot suggestion |

Completion (nvim-cmp): `Tab`/`Shift-Tab` cycle, `Enter` confirm, `Ctrl-Space` trigger.
LSP servers are auto-installed by **Mason** on first launch (pyright, ts_ls, clangd, gopls).

### tmux  (prefix = `Ctrl-s`)
- `Ctrl-s c` new window · `Ctrl-s ,` rename · `Ctrl-s |` / `-` split (pain-control)
- `Ctrl-s h/j/k/l` move panes · mouse is on · `Ctrl-s I` install plugins · `Ctrl-s r` reload config
- Shortcuts: `tn <name>` new session · `ta <name>` attach · `tl` list

### fzf
- `Ctrl-T` insert file path · `Ctrl-R` history search · `Alt-C` cd into dir
- In any picker: `Ctrl-/` toggle preview · `Ctrl-Y` copy selection to clipboard
- `fcd` fuzzy-cd · `fkill` fuzzy-kill a process · `z <dir>` zoxide jump

### git / jj
- git aliases: `git st`, `git lg`, `git amend`, `git unstage`, `git wip`; `lg` → lazygit
- jj (colocated with an existing git repo so both share the working copy):
  ```bash
  cd my-git-repo
  jj git init --colocate      # adopt the existing git repo
  jj st                       # status   (default command is `log`)
  jj new                      # start a new change
  jj describe -m "msg"        # set the change description
  jj git push                 # push to the git remote
  ```

### uv / ML workflow
`uv` manages Python versions **and** per-project virtualenvs + lockfiles — no
global pip pollution. A ready example lives at `~/dev/ml-template`.

```bash
cd ~/dev && uv init myproj && cd myproj
uv add numpy torch jax                 # torch → MPS wheels; jax → CPU build (macOS arm64)
uv add --dev pytest ruff ipython
uv run python -c "import torch, jax; \
  print('mps', torch.backends.mps.is_available()); print('jax', jax.devices())"
uv run pytest          # run tests inside the project env
```

- **PyTorch**: use `torch.device('mps')` to run on the M2 Pro GPU locally.
- **JAX**: CPU-only here on purpose — `jax-metal` is experimental and effectively
  unmaintained (last release Oct 2024). Run GPU/TPU JAX on your remote boxes; the
  same `pyproject.toml` / `uv.lock` reproduces the env there.
- Loop: `uv add <pkg>` → `uv sync` (reproduce lock) → `uv run <cmd>`.

---

## Troubleshooting

- **`brew: command not found` in a new shell** → ensure the first lines of
  `~/.zshrc` ran; `eval "$(/opt/homebrew/bin/brew shellenv)"`.
- **Icons look like boxes** → terminal font isn’t a Nerd Font (step 1 above).
- **No colors in nvim inside tmux** → confirm `tmux-256color` + the `RGB`
  overrides in `~/.tmux.conf` and a true-color terminal (iTerm2 ✔).
- **nvim LSP not attaching** → run `:Mason` to confirm servers installed,
  `:checkhealth` for diagnostics; `node` must be on PATH for pyright/ts_ls.
- **Avante errors on launch** → run `:AvanteBuild`; needs `rust`/cargo (installed)
  and the Keychain key (step 3). Without the key it disables gracefully.
- **Re-run anything** → `./install.sh` is idempotent; `./validate.sh` reports state.
