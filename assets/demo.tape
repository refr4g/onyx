# onyx — demo tape (charmbracelet/vhs)
# regenerate:  cd ~/Documents/onyx && vhs assets/demo.tape
Output assets/onyx.gif

Require fish
Require tmux
Require nvim

Set Shell "fish"
Set FontFamily "JetBrainsMono Nerd Font"
Set FontSize 16
Set Width 1280
Set Height 760
Set Padding 20
Set Theme { "name": "oxocarbon", "background": "#161616", "foreground": "#f2f4f8", "black": "#161616", "red": "#ee5396", "green": "#42be65", "yellow": "#ffe97b", "blue": "#78a9ff", "magenta": "#be95ff", "cyan": "#3ddbd9", "white": "#dde1e6", "brightBlack": "#525252", "brightRed": "#ff7eb6", "brightGreen": "#42be65", "brightYellow": "#ffe97b", "brightBlue": "#33b1ff", "brightMagenta": "#be95ff", "brightCyan": "#82cfff", "brightWhite": "#ffffff", "selection": "#393939", "cursor": "#f2f4f8" }

# --- hidden setup: enter tmux (default-shell=fish → full oxocarbon config) ---
Hide
Type "tmux -L onyxdemo kill-server 2>/dev/null; true" Enter Sleep 500ms
Type "tmux -L onyxdemo new -s onyx" Enter Sleep 2500ms
Type "cd ~/Documents/onyx" Enter Sleep 500ms
Type "clear" Enter Sleep 400ms
Show

# --- fish prompt + eza `ll` (oxocarbon colors, git column) ---
Sleep 1s
Type "ll" Enter Sleep 3s

# --- split (prefix C-a, then o) → bat as cat, oxocarbon-themed ---
Ctrl+a
Sleep 400ms
Type "o"
Sleep 1200ms
Type "bat --paging=never fish/config.fish" Enter Sleep 3500ms

# --- split (prefix C-a, then k) → neovim: oxocarbon + treesitter ---
Ctrl+a
Sleep 400ms
Type "k"
Sleep 1200ms
Type "nvim nvim/init.lua" Enter Sleep 4000ms
Type "40G" Sleep 2200ms
Escape
Type ":q" Enter Sleep 1s

Sleep 1500ms
