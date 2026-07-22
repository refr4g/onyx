# ══════════════════════════════════════════════════════════════
#  Output colors for external tools — SEPARATE from fish's own
#  syntax colors (those live in conf.d/oxocarbon.fish).
# ══════════════════════════════════════════════════════════════

# ── eza (default `ls`, aliased in config.fish) — TRUE oxocarbon hex ──
# EZA_COLORS = colon-separated key=SGR pairs. Keys: di dir, ex exec, ln link,
#   fi file, pi pipe, so socket, bd/cd device, or orphan-link; permission bits
#   ur/uw/ux (user) gr/gw/gx (group) tr/tw/tx (other); sn size-num sb size-unit;
#   uu owner un other-owner; da date; ga/gm/gd git added/modified/deleted;
#   xx punctuation; hd header; lp symlink-target.
set -gx EZA_COLORS "di=1;38;2;51;177;255:ex=1;38;2;66;190;101:ln=38;2;61;219;217:fi=38;2;242;244;248:pi=38;2;190;149;255:so=38;2;255;126;182:bd=38;2;190;149;255:cd=38;2;190;149;255:or=38;2;238;83;150:ur=38;2;120;169;255:uw=38;2;238;83;150:ux=38;2;66;190;101:ue=38;2;66;190;101:gr=38;2;82;82;82:gw=38;2;82;82;82:gx=38;2;82;82;82:tr=38;2;82;82;82:tw=38;2;82;82;82:tx=38;2;82;82;82:sn=38;2;120;169;255:sb=38;2;82;82;82:uu=38;2;141;141;141:un=38;2;82;82;82:da=38;2;141;141;141:ga=38;2;66;190;101:gm=38;2;61;219;217:gd=38;2;238;83;150:xx=38;2;82;82;82:hd=1;38;2;141;141;141:lp=38;2;61;219;217"

# ── ls (BSD fallback for `command ls`) ────────────────────────
# LSCOLORS = 11 fg/bg letter-pairs: dir link socket pipe exec block char
#   setuid setgid sticky-ow ow.  a=blk b=red c=grn d=yel e=blu f=mag g=cyn
#   h=gry (UPPER=bold, x=default). BSD ls is limited to these 16 colors, so
#   this only matters when you call `command ls` — day-to-day `ls` is eza.
set -gx CLICOLOR 1
set -gx LSCOLORS ExGxFxdxCxGxGxabagacad
#                 │ │ │ │ │ └ dir(blue) link(cyan) sock(mag) pipe(yel) exec(green)…

# ── grep match highlight (truecolor OK here) ──────────────────
set -gx GREP_COLORS 'mt=1;38;2;238;83;150'   # oxocarbon pink for matches
alias grep='grep --color=auto'

# ── colored man pages, via less (truecolor OK here) ───────────
set -gx LESS_TERMCAP_md (printf '\e[1;38;2;120;169;255m')            # bold / headings → blue
set -gx LESS_TERMCAP_us (printf '\e[3;38;2;61;219;217m')             # underline       → teal
set -gx LESS_TERMCAP_so (printf '\e[1;38;2;22;22;22;48;2;238;83;150m') # search/prompt → dark-on-pink
set -gx LESS_TERMCAP_me (printf '\e[0m')
set -gx LESS_TERMCAP_ue (printf '\e[0m')
set -gx LESS_TERMCAP_se (printf '\e[0m')
