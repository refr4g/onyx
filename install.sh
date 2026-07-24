#!/usr/bin/env bash
# ============================================================================
#  onyx installer — oxocarbon terminal & neovim (fish · tmux · bat · eza · neovim · burp)
#  Works on macOS and Linux (brew / apt / dnf / pacman / zypper).
#
#  Usage:
#     ./install.sh [--no-deps] [--font] [--shell] [--no-nvim] [-h]
#       --no-deps   skip package installation, only link configs
#       --font      also install JetBrainsMono Nerd Font (icons are off by default)
#       --shell     set fish as your default login shell
#       --no-nvim   skip the neovim plugin bootstrap
# ============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
STAMP="$(date +%Y%m%d%H%M%S)"

# ---- flags ----------------------------------------------------------------
DO_DEPS=1; DO_FONT=0; DO_SHELL=0; DO_NVIM=1
for a in "$@"; do case "$a" in
  --no-deps) DO_DEPS=0 ;;
  --font)    DO_FONT=1 ;;
  --shell)   DO_SHELL=1 ;;
  --no-nvim) DO_NVIM=0 ;;
  -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
  *) echo "unknown flag: $a"; exit 1 ;;
esac; done

# ---- logging (oxocarbon-ish) ----------------------------------------------
b='\033[38;2;120;169;255m'; g='\033[38;2;66;190;101m'; p='\033[38;2;255;126;182m'; d='\033[38;2;141;141;141m'; x='\033[0m'
info(){ printf "${b}==>${x} %s\n" "$*"; }
ok(){   printf "${g} ok ${x} %s\n" "$*"; }
warn(){ printf "${p} !! ${x} %s\n" "$*"; }
step(){ printf "\n${d}%s${x}\n" "── $* ──────────────────────────────"; }

# ---- platform / package-manager detection ---------------------------------
OS="$(uname -s)"; ARCH="$(uname -m)"; PM=""
if command -v brew >/dev/null 2>&1; then PM=brew
elif command -v apt-get >/dev/null 2>&1; then PM=apt
elif command -v dnf >/dev/null 2>&1;     then PM=dnf
elif command -v pacman >/dev/null 2>&1;  then PM=pacman
elif command -v zypper >/dev/null 2>&1;  then PM=zypper
fi
info "OS=$OS  arch=$ARCH  package-manager=${PM:-none}"

SUDO=""; [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1 && SUDO=sudo

pm_install(){ # pm_install <pkg...>
  case "$PM" in
    brew)   brew install "$@" ;;
    apt)    $SUDO apt-get update -qq && $SUDO apt-get install -y "$@" ;;
    dnf)    $SUDO dnf install -y "$@" ;;
    pacman) $SUDO pacman -S --needed --noconfirm "$@" ;;
    zypper) $SUDO zypper install -y "$@" ;;
    *) warn "no supported package manager; install manually: $*"; return 1 ;;
  esac
}

# eza is missing from some older repos → download a release binary as fallback
install_eza_fallback(){
  command -v eza >/dev/null 2>&1 && return 0
  local a; case "$ARCH" in x86_64|amd64) a=x86_64 ;; aarch64|arm64) a=aarch64 ;; *) warn "eza: unknown arch $ARCH"; return 1 ;; esac
  info "eza not packaged here — fetching release binary"
  mkdir -p "$HOME/.local/bin"
  local url="https://github.com/eza-community/eza/releases/latest/download/eza_${a}-unknown-linux-gnu.tar.gz"
  curl -fsSL "$url" | tar -xz -C "$HOME/.local/bin" ./eza 2>/dev/null && chmod +x "$HOME/.local/bin/eza" \
    && ok "eza → ~/.local/bin/eza" || warn "eza fallback failed — install manually"
}

# neovim must be >= 0.11 (native LSP API). Distro pkgs are often older.
nvim_recent(){
  command -v nvim >/dev/null 2>&1 || return 1
  local v maj min; v="$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)"
  maj="${v%%.*}"; min="${v##*.}"
  [ "${maj:-0}" -gt 0 ] || [ "${min:-0}" -ge 11 ]
}
install_nvim_fallback(){
  nvim_recent && return 0
  [ "$OS" = "Linux" ] || { warn "neovim too old and no fallback for $OS"; return 1; }
  local a; case "$ARCH" in x86_64|amd64) a=x86_64 ;; aarch64|arm64) a=arm64 ;; *) warn "nvim: unknown arch $ARCH"; return 1 ;; esac
  info "neovim missing/old — installing latest AppImage"
  mkdir -p "$HOME/.local/bin"
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${a}.appimage"
  curl -fsSL -o "$HOME/.local/bin/nvim" "$url" && chmod +x "$HOME/.local/bin/nvim"
  if ! "$HOME/.local/bin/nvim" --version >/dev/null 2>&1; then
    warn "AppImage needs FUSE — extracting instead"
    ( cd "$HOME/.local/bin" && ./nvim --appimage-extract >/dev/null 2>&1 \
      && rm -f nvim && ln -sf "$PWD/squashfs-root/usr/bin/nvim" nvim )
  fi
  nvim_recent && ok "neovim → ~/.local/bin/nvim" || warn "neovim fallback failed"
}

# ---- 1. dependencies ------------------------------------------------------
if [ "$DO_DEPS" = 1 ]; then
  step "dependencies"
  if [ -z "$PM" ]; then
    warn "no package manager found — install fish tmux bat eza neovim git yourself, then re-run with --no-deps"
  else
    # base set (names are identical across these managers)
    pm_install git fish tmux bat || warn "some base packages failed"
    # clipboard tool for neovim's system clipboard on Linux
    if [ "$OS" = "Linux" ]; then
      case "$PM" in
        apt)    pm_install xclip || true ;;
        dnf)    pm_install xclip || true ;;
        pacman) pm_install xclip || true ;;
        zypper) pm_install xclip || true ;;
      esac
    fi
    # eza + neovim (may need fallbacks)
    pm_install eza 2>/dev/null || true;   install_eza_fallback || true
    pm_install neovim 2>/dev/null || true; install_nvim_fallback || true
    # sshpass (for the kali function) — best effort, not in all repos
    pm_install sshpass 2>/dev/null || warn "sshpass not installed (optional, used by kali)"
  fi

  # Debian/Ubuntu ship bat as 'batcat' — expose it as 'bat'
  if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    mkdir -p "$HOME/.local/bin"; ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    ok "linked batcat → ~/.local/bin/bat"
  fi
fi

# ---- 2. symlink configs (individually, so plugins/omf files survive) -------
step "linking configs"
link(){ # link <repo-relative-src> <absolute-dst>
  local src="$DOTFILES_DIR/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then mv "$dst" "$dst.bak.$STAMP"; warn "backed up $dst → $dst.bak.$STAMP"; fi
  ln -sfn "$src" "$dst"; ok "$dst"
}
link fish/config.fish                      "$CONFIG/fish/config.fish"
link fish/conf.d/oxocarbon.fish            "$CONFIG/fish/conf.d/oxocarbon.fish"
link fish/conf.d/output-colors.fish        "$CONFIG/fish/conf.d/output-colors.fish"
link fish/functions/fish_prompt.fish       "$CONFIG/fish/functions/fish_prompt.fish"
link fish/functions/fish_right_prompt.fish "$CONFIG/fish/functions/fish_right_prompt.fish"
link tmux/tmux.conf                        "$CONFIG/tmux/tmux.conf"
link bat/config                            "$CONFIG/bat/config"
link bat/themes/oxocarbon.tmTheme          "$CONFIG/bat/themes/oxocarbon.tmTheme"
link nvim/init.lua                         "$CONFIG/nvim/init.lua"
link burp/themes/oxocarbon.theme.json      "$HOME/.BurpSuite/themes/oxocarbon.theme.json"

# secrets: create a real (git-ignored) copy if absent
if [ ! -f "$CONFIG/fish/secrets.fish" ]; then
  cp "$DOTFILES_DIR/fish/secrets.fish.example" "$CONFIG/fish/secrets.fish"
  warn "created $CONFIG/fish/secrets.fish — edit it and set KALI_SSH_PASS"
fi

# ---- 3. tmux plugin -------------------------------------------------------
step "tmux plugin"
TPD="$CONFIG/tmux/tmux-better-mouse-mode"
if [ ! -d "$TPD" ]; then
  git clone --depth 1 https://github.com/NHDaly/tmux-better-mouse-mode "$TPD" && ok "cloned tmux-better-mouse-mode"
else ok "tmux-better-mouse-mode already present"; fi

# ---- 4. bat theme cache ---------------------------------------------------
step "bat cache"
BAT="$(command -v bat || command -v batcat || true)"
[ -n "$BAT" ] && "$BAT" cache --build >/dev/null && ok "bat cache built" || warn "bat not found; skipped cache"

# ---- 5. nerd font (optional) ----------------------------------------------
if [ "$DO_FONT" = 1 ]; then
  step "nerd font"
  if [ "$OS" = "Darwin" ] && [ "$PM" = brew ]; then
    brew install --cask font-jetbrains-mono-nerd-font && ok "JetBrainsMono Nerd Font"
  else
    FD="$HOME/.local/share/fonts"; mkdir -p "$FD"
    curl -fsSL -o /tmp/jbm.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
      && unzip -oq /tmp/jbm.zip -d "$FD" && command -v fc-cache >/dev/null && fc-cache -f "$FD" \
      && ok "JetBrainsMono Nerd Font → $FD" || warn "font install failed"
  fi
fi

# ---- 6. default shell (optional) ------------------------------------------
if [ "$DO_SHELL" = 1 ]; then
  step "default shell"
  FISH="$(command -v fish || true)"
  if [ -n "$FISH" ]; then
    grep -qxF "$FISH" /etc/shells 2>/dev/null || echo "$FISH" | $SUDO tee -a /etc/shells >/dev/null
    chsh -s "$FISH" && ok "login shell → $FISH (re-login to apply)" || warn "chsh failed"
  else warn "fish not found; skipped"; fi
fi

# ---- 7. neovim bootstrap --------------------------------------------------
if [ "$DO_NVIM" = 1 ] && command -v nvim >/dev/null 2>&1; then
  step "neovim bootstrap"
  info "installing plugins (first run pulls lazy.nvim, treesitter, LSP servers)…"
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  ok "plugins synced — treesitter parsers & LSP servers finish on first real launch"
fi

step "done"
ok "Open a new terminal (or 'exec fish'). Enjoy the oxocarbon setup."
