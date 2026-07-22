function fish_prompt
    # Oxocarbon prompt (shape K):  refr4g ~/path branch »
    # The » arrow is blue on success, pink when the last command failed.
    set -l last_status $status

    set -l handle  be95ff   # username / handle (purple)
    set -l accent  be95ff   # success arrow (purple, same as handle)
    set -l path_c  3ddbd9   # cwd (teal)
    set -l dim     8d8d8d   # branch (gray)
    set -l dirty_c ee5396   # dirty marker (pink)
    set -l fail    fa4d56   # failure arrow (red)

    # handle
    set_color -o $handle
    printf 'refr4g'
    set_color normal

    # cwd (HOME collapsed to ~)
    set_color $path_c
    printf ' %s' (pwd | sed -E "s-^$HOME(\$|(/.*))-~\2-")

    # git branch + dirty dot (only inside a repo)
    set -l branch (command git symbolic-ref --short HEAD 2>/dev/null)
    if test -n "$branch"
        set_color $dim
        printf ' %s' $branch
        set -l dirty (command git status --porcelain 2>/dev/null)
        if test -n "$dirty"
            set_color $dirty_c
            printf ' ●'
        end
    end

    # double-arrow — color reflects last exit status
    if test $last_status -eq 0
        set_color -o $accent
    else
        set_color -o $fail
    end
    printf ' » '
    set_color normal
end
