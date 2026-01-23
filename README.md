# dotfiles

This repo is designed to bootstrap a new **Ubuntu** machine (and optionally macOS later) with your preferred:

- `zsh` configuration
- `tmux` configuration + `tpm` (tmux plugin manager)
- `neovim` configuration (lazy.nvim bootstrap + plugin install)
- common CLI dependencies used by the above

It follows a **backup + symlink** model:

- existing config files are moved into a timestamped backup directory
- this repo’s files are symlinked into the expected locations in `$HOME`

---

## Repo layout

- `config/zsh/zshrc` → symlinked to `~/.zshrc`
- `config/tmux/tmux.conf` → symlinked to `~/.tmux.conf`
- `config/nvim/init.lua` → symlinked to `~/.config/nvim/init.lua`

Bootstrap / install helpers:

---

## Starship prompt config + themes (symlink strategy)

Your setup uses:

- A **single active config** at `~/.config/starship.toml`
- A **themes directory** at `~/.config/starship/` containing variants (e.g. `starship-nightowl.toml`, `starship-catpuccin.toml`, etc.)
- A **symlink** so you can switch themes by repointing `~/.config/starship.toml` to one of the theme files.

### Recommended layout

On the machine:

- `~/.config/starship/` (directory with theme files)
- `~/.config/starship.toml` → symlink to one of the theme files

Example:

```/dev/null/starship-symlink.sh#L1-12
mkdir -p ~/.config/starship
ln -sfn ~/.config/starship/starship-nightowl.toml ~/.config/starship.toml
```

### Switching themes

Repoint the symlink:

```/dev/null/starship-switch.sh#L1-12
ln -sfn ~/.config/starship/starship-catpuccin.toml ~/.config/starship.toml
# or:
ln -sfn ~/.config/starship/starship-pastel.toml ~/.config/starship.toml
```

### How this repo fits in

This repo should:

- Track the theme files under `config/starship/` (or similar) and link them into `~/.config/starship/`
- Optionally link a default theme to `~/.config/starship.toml`

If you want the repo to manage the symlink automatically, add that logic to `scripts/link_configs.sh` (recommended), so a fresh machine gets a working prompt immediately.

- `apt/ubuntu-packages.txt` → apt packages to install
- `scripts/ubuntu_bootstrap.sh` → installs packages + tools (tmux TPM, starship, zoxide, neovim, etc.)
- `scripts/link_configs.sh` → backs up existing configs and symlinks repo configs into place
- `install.sh` → runs bootstrap + linking in the correct sequence

---

## Notes (terminal-first, git-friendly)

Goal:
- Take notes entirely in the terminal (no desktop note apps)
- Sync notes between machines (rsync/scp)
- Export to Markdown for publishing/sharing via GitHub repos (images + Mermaid)

### Authoring format: Org (Neovim orgmode)

Author notes as `.org` files for the richest terminal UX (agenda/capture/tasks):

Suggested layout:
- `~/notes/org/`   (authoring / source-of-truth)
- `~/notes/md/`    (exported Markdown for GitHub)

### Export Org → Markdown (faithful GitHub output)

Recommended exporter: `pandoc`

Single file:
```/dev/null/notes-export-single.sh#L1-3
pandoc -f org -t gfm -o out.md in.org
```

Export a whole tree (mirrors directory structure):
```/dev/null/notes-export-tree.sh#L1-12
mkdir -p ~/notes/md
find ~/notes/org -name '*.org' -print0 \
  | xargs -0 -I{} sh -lc '
      in="{}"
      out="$HOME/notes/md/${in#$HOME/notes/org/}"
      out="${out%.org}.md"
      mkdir -p "$(dirname "$out")"
      pandoc -f org -t gfm -o "$out" "$in"
    '
```

Notes:
- Images: store assets alongside notes (e.g. `~/notes/org/assets/...`) and use relative links in Org/Markdown so they work in GitHub.
- Mermaid (GitHub): use fenced blocks in the exported Markdown:
```/dev/null/mermaid-example.md#L1-4
~~~mermaid
graph TD
  A --> B
~~~
```

### Sync notes to a remote machine

Rsync Org notes (local → remote):
```/dev/null/notes-rsync-org.sh#L1-3
rsync -av --delete ~/notes/org/ user@host:~/notes/org/
```

(Optional) also sync exported Markdown:
```/dev/null/notes-rsync-md.sh#L1-3
rsync -av --delete ~/notes/md/ user@host:~/notes/md/
```

### Quick dump (scp)

Copy a file quickly:
```/dev/null/notes-scp.sh#L1-3
scp ~/notes/org/inbox.org user@host:~/notes/org/inbox.org
```

---

## Before you run anything

### 1) Secrets are not committed
Your real environment variables and secrets should live at:

- `~/.config/secrets/env.zsh`

That file is expected to be **untracked** and is sourced by `~/.zshrc` if present.

Create it on the new machine:

```/dev/null/commands.sh#L1-10
mkdir -p ~/.config/secrets
$EDITOR ~/.config/secrets/env.zsh
```

Example content:

```/dev/null/env.zsh#L1-20
# Example only — put real values here, do not commit.
export GITHUB_PAT="..."
export DD_API_KEY="..."
```

---

## Ubuntu setup (fresh machine)

### 0) Get git (if needed)
```/dev/null/commands.sh#L1-5
sudo apt-get update
sudo apt-get install -y git
```

### 1) Clone the repo
Pick a location (recommended: `~/.config/dotfiles`):

```/dev/null/commands.sh#L1-10
# Root-based install (as root user)
git clone https://github.com/<you>/<repo>.git /root/dotfiles
cd /root/dotfiles
```

### 2) Run the installer
This performs, in order:

1. installs apt packages (from `apt/ubuntu-packages.txt`)
2. installs/sets up `tpm` for tmux
3. installs `starship` and `zoxide` (if missing)
4. installs a recent `nvim` (if missing)
5. backs up existing configs
6. symlinks the repo configs into place

Run:

```/dev/null/commands.sh#L1-5
chmod +x install.sh scripts/*.sh
./install.sh
```

### 3) Make `zsh` your default shell (if not already)
The bootstrap script attempts to set this, but you may need to log out/in.

Verify:

```/dev/null/commands.sh#L1-5
echo "$SHELL"
zsh --version
```

If needed:

```/dev/null/commands.sh#L1-5
chsh -s "$(command -v zsh)"
```

Log out and back in.

---

## Post-install steps (important)

### tmux plugins (TPM)
Start tmux:

```/dev/null/commands.sh#L1-5
tmux
```

Then install plugins:

- Press `prefix` + `I`

In your tmux config, `prefix` is `Ctrl+s`.

So: `Ctrl+s` then `Shift+i`

### Neovim plugins (lazy.nvim)
Launch Neovim:

```/dev/null/commands.sh#L1-5
nvim
```

On first run:

- `lazy.nvim` is bootstrapped automatically (git clone)
- plugins are installed automatically

If you want to review status:

- `:Lazy`
- `:Mason` (for LSP/tools)

---

## What gets backed up and where

When you run `scripts/link_configs.sh`, existing files are moved to something like:

- `~/.dotfiles-backup/YYYYmmdd-HHMMSS/...`

Typical backups include:

- `~/.zshrc`
- `~/.tmux.conf`
- `~/.config/nvim/init.lua`

---

## Common tasks

### Re-link configs after pulling updates
```/dev/null/commands.sh#L1-10
cd ~/.config/dotfiles
git pull
./scripts/link_configs.sh
```

### Reload tmux config
Inside tmux:

- `prefix` + `r`

With your prefix: `Ctrl+s` then `r`

### Update tmux plugins
Inside tmux:

- `prefix` + `U` (update plugins)
- `prefix` + `I` (install plugins)

### Update Neovim plugins
In Neovim:

- `:Lazy sync`

---

## Notes / assumptions

- This repo targets Ubuntu Linux. Some macOS-specific lines are kept commented out in config files for reference.
- Neovim is installed via a “recent build” approach (not Ubuntu’s often-outdated `apt` package). See `scripts/ubuntu_bootstrap.sh`.
- Some tools in your Neovim config (formatters/linters) may be installed via `mason` inside Neovim; system-level toolchains (Go/Rust) are still your responsibility if you want `gofmt`/`rustfmt` available globally.

---

## Troubleshooting

### `fd` command not found on Ubuntu
Ubuntu installs `fd` as `fdfind`. The bootstrap script attempts to create a shim at:

- `~/.local/bin/fd` → pointing to `fdfind`

Ensure `~/.local/bin` is on your `PATH` (this repo’s `zshrc` adds it).

### zsh-syntax-highlighting not loading
Ubuntu package locations vary. This repo tries:

- `/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`

If your distro uses a different path, install the package and update `config/zsh/zshrc` accordingly.

---