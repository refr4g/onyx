function fish_right_prompt
    # clock — bold + brighter so it reads more prominently
    set_color -o 8d8d8d
    printf '%s' (date '+%H:%M')
    set_color normal
end
