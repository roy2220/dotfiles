_enter() {
    if [[ ! -z ${BUFFER} ]]; then
        zle accept-line
        return
    fi
    local file_or_dir=$(find -mindepth 1 \( -type d -name .git -prune \) -o -type f -printf '%P\n' -o -type d -printf '%P/\n' | fzf-popup --prompt='Open> ')
    if [[ -z ${file_or_dir} ]]; then
        zle accept-line
        return
    fi
    if [[ ${file_or_dir[-1]} == / ]]; then
        BUFFER="cd ${file_or_dir:q}"
    else
        BUFFER="vim ${file_or_dir:q}"
    fi
    zle accept-line
}

zle -N _enter
bindkey '^M' _enter
