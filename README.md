# onyx

An **oxocarbon**-themed terminal environment: `fish` · `tmux` · `bat` · `eza` · `neovim`.
One installer for **macOS and Linux**.

## What it sets up

| Tool | Config | Theme / notes |
|------|--------|---------------|
| fish | `fish/config.fish`, `conf.d/*.fish`, `functions/*.fish` | oxocarbon syntax palette, two-line prompt, eza/bat aliases |
| tmux | `tmux/tmux.conf` | oxocarbon status bar; prefix `C-a`, `o`/`k` splits, mouse on |
| bat  | `bat/config`, `bat/themes/oxocarbon.tmTheme` | custom oxocarbon theme, `cat`→bat |
| eza  | `EZA_COLORS` in `conf.d/output-colors.fish` | true-hex oxocarbon `ls` (icons off) |
| neovim | `nvim/init.lua` | lazy.nvim, oxocarbon.nvim, treesitter, native LSP |

**Neovim LSP** (auto-installed via mason on first launch):
`pyright` (Python), `intelephense` (PHP), `ts_ls` (JS/TS), `jdtls` (Java), `clangd` (C/C++).

## Install

```sh
git clone <your-repo-url> ~/Documents/onyx
cd ~/Documents/onyx
./install.sh
```

Flags:

| Flag | Effect |
|------|--------|
| `--no-deps` | only symlink configs, skip package installation |
| `--font`    | also install JetBrainsMono Nerd Font (icons are off by default) |
| `--shell`   | set fish as the default login shell |
| `--no-nvim` | skip the neovim plugin bootstrap |

The installer detects your package manager (**brew / apt / dnf / pacman / zypper**),
installs missing tools (with release-binary fallbacks for `eza` and `neovim` when a
distro ships them too old), backs up any existing config to `*.bak.<timestamp>`,
then symlinks each file individually (so plugin managers like omf keep working).

## Secrets

`config.fish` never stores credentials. Copy the template and fill it in:

```sh
cp fish/secrets.fish.example ~/.config/fish/secrets.fish
# then edit ~/.config/fish/secrets.fish  (set -gx KALI_SSH_PASS "…")
```

`secrets.fish` is git-ignored.

## Runtimes you may still need

- **Java** (jdtls): a JDK 17+ on PATH
- **Node** (pyright / ts_ls / intelephense): Node.js
- **PHP** (intelephense): the `php` CLI helps for some features

## Uninstall / revert

Every replaced file was saved as `*.bak.<timestamp>` next to the symlink —
remove the symlink and move the backup back.

## Per-OS notes

- **Debian/Ubuntu**: `bat` ships as `batcat`; the installer symlinks it to `~/.local/bin/bat`.
- **Older distros**: `eza`/`neovim` fall back to GitHub release binaries in `~/.local/bin`
  (ensure that dir is on your `PATH`).
- **Neovim** must be ≥ 0.11 (native LSP API); the installer upgrades it if needed.
