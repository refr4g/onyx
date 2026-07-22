if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ── PATH ──────────────────────────────────────────────────────
set -x PATH /usr/local/bin $PATH
set PATH $PATH $HOME/.local/bin

# ── machine-local secrets (git-ignored — see secrets.fish.example) ──
test -f ~/.config/fish/secrets.fish; and source ~/.config/fish/secrets.fish

# ── personal aliases / functions ──────────────────────────────
alias generate-jmbg="/opt/jmbg-generator/generate.php"

# SSH to the kali box. The password is kept OUT of this repo: put it in
# ~/.config/fish/secrets.fish (copied from secrets.fish.example) as
#   set -gx KALI_SSH_PASS "yourpassword"
function kali
    if test -z "$KALI_SSH_PASS"
        echo "KALI_SSH_PASS not set — see ~/.config/fish/secrets.fish"
        return 1
    end
    sshpass -p "$KALI_SSH_PASS" ssh luka@192.168.31.38
end

# ── eza as ls (colors themed via EZA_COLORS in conf.d/output-colors.fish) ──
# Icons are off. To re-enable, add --icons=auto and select a Nerd Font.
alias ls 'eza --group-directories-first --color=auto'
alias ll 'eza -lh  --group-directories-first --git --color=auto'
alias la 'eza -lah --group-directories-first --git --color=auto'
alias lt 'eza --tree --level=2 --group-directories-first --color=auto'

# ── bat as cat (oxocarbon-themed) ─────────────────────────────
# bat auto-falls back to plain output when piped, so pipelines behave like cat.
# Raw cat: `command cat`.  (On Debian/Ubuntu the installer symlinks batcat→bat.)
alias cat 'bat'
