fzf-complete-git-branch() {
    local raw_branches=$(git branch --all --sort=-committerdate | cut --characters 3- | grep --fixed-strings --invert-match HEAD)
    local branches=$(sed --silent --regexp-extended 's/^(remotes\/)?(.+)$/\2/p' <<< ${raw_branches})
    local additional_branches=$(sed --silent --regexp-extended 's/^remotes\/[^\/]+\/(.+)$/\1/p' <<< ${raw_branches})
    if [[ ! -z ${additional_branches} ]]; then
        local current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [[ ${current_branch} == HEAD ]]; then
            branches+=$'\n'${additional_branches}
        else
            branches=${current_branch}$'\n'${branches}$'\n'${additional_branches}
        fi
    fi
    local branch=$(head --bytes=-1 <<< ${branches} | awk '!visited[$0]++' | fzf --prompt='Git-Branch> ')
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${branch} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${branch}
    else
        echo ${branch}
    fi
}
zle -N fzf-complete-git-branch
bindkey '^xgb' fzf-complete-git-branch
Gcb() {
    local branch=$(fzf-complete-git-branch)
    if [[ -z ${branch} ]]; then
        return
    fi
    local cmd="git checkout ${@:+${@:q} }${branch:q}"
    print -rs ${cmd}
    ${=cmd}
}

fzf-complete-git-tag() {
    local tag=$(git tag --list --sort=-version:refname | fzf --prompt='Git-Tag> ')
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${tag} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${tag}
    else
        echo ${tag}
    fi
}
zle -N fzf-complete-git-tag
bindkey '^xgt' fzf-complete-git-tag
Gct() {
    local tag=$(fzf-complete-git-tag)
    if [[ -z ${tag} ]]; then
        return
    fi
    local cmd="git checkout ${@:+${@:q} }${tag:q}"
    print -rs ${cmd}
    ${=cmd}
}

fzf-complete-git-commit() {
    local commit_and_message=$(git log --format='%h %s' | fzf --prompt='Git-Commit> ')
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${commit_and_message} ]]; then
        return
    fi
    local commit=$(cut --delimiter=' ' --fields=1 <<< ${commit_and_message})
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${commit}
    else
        echo ${commit}
    fi
}
zle -N fzf-complete-git-commit
bindkey '^xgc' fzf-complete-git-commit
Gcc() {
    local commit=$(fzf-complete-git-commit)
    if [[ -z ${commit} ]]; then
        return
    fi
    local cmd="git checkout ${@:+${@:q} }${commit:q}"
    print -rs ${cmd}
    ${=cmd}
}

fzf-complete-git-file() {
    local file=$(git ls-files | fzf --prompt='Git-File> ')
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${file} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${file}
    else
        echo ${file}
    fi
}
zle -N fzf-complete-git-file
bindkey '^xgf' fzf-complete-git-file
Gcf() {
    local file=$(fzf-complete-git-file)
    if [[ -z ${file} ]]; then
        return
    fi
    local cmd="git checkout ${@:+${@:q} }${file:q}"
    print -rs ${cmd}
    ${=cmd}
}
