fzf-complete-command() {
    local command=$(fc -nrl 1 | fzf --no-sort --prompt='Command> ')
    zle reset-prompt
    if [[ -z ${command} ]]; then
        return
    fi
    LBUFFER=${LBUFFER}$(echo -e ${command})
}
zle -N fzf-complete-command
bindkey '^r' fzf-complete-command

fzf-complete-file() {
    local file=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    if [[ -z ${file} ]]; then
        local dir=
        local query=
    else
        if [[ ${file[-1]} == / ]]; then
            local dir=${file}
            local query=
        else
            local dir=$(dirname ${file})
            [[ ${dir} != / ]] && dir+=/
            local query=$(basename ${file})
        fi
    fi
    eval "local expanded_dir=${dir}"
    eval "local expanded_query=${query}"
    local file=$(find ${expanded_dir} -mindepth 1 \( -type f -printf '%P\n' \) -or \( -type d -printf '%P/\n' \) | fzf --prompt="${expanded_dir}> " --query=${expanded_query})
    zle reset-prompt
    if [[ -z ${file} ]]; then
        return
    fi
    LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${file}
}
zle -N fzf-complete-file
bindkey '^x^f' fzf-complete-file
