fzf-complete-git-branch() {
    if [[ -v LBUFFER ]]; then
        local query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
        eval "local expanded_query=${query}"
    else
        local query=${1}
        local expanded_query=${1}
    fi
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
    local branch=$(head --bytes=-1 <<< ${branches} | awk '!visited[$0]++' | fzf --query=${expanded_query})
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${branch} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${branch}
    else
        echo ${branch}
    fi
}
zle -N fzf-complete-git-branch
bindkey '^xgb' fzf-complete-git-branch
Gcb () {
    local branch=$(fzf-complete-git-branch ${1})
    if [[ -z ${branch} ]]; then
        return
    fi
    git checkout ${branch}
}

fzf-complete-git-tag() {
    if [[ -v LBUFFER ]]; then
        local query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
        eval "local expanded_query=${query}"
    else
        local query=${1}
        local expanded_query=${1}
    fi
    local tag=$(git tag --list --sort=-version:refname | fzf --query=${expanded_query})
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${tag} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${tag}
    else
        echo ${tag}
    fi
}
zle -N fzf-complete-git-tag
bindkey '^xgt' fzf-complete-git-tag
Gct () {
    local tag=$(fzf-complete-git-tag ${1})
    if [[ -z ${tag} ]]; then
        return
    fi
    git checkout ${tag}
}

fzf-complete-git-commit() {
    if [[ -v LBUFFER ]]; then
        local query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
        eval "local expanded_query=${query}"
    else
        local query=${1}
        local expanded_query=${1}
    fi
    local commit_and_message=$(git log --format='%h %s' | fzf --query=${expanded_query})
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${commit_and_message} ]]; then
        return
    fi
    local commit=$(cut --delimiter=' ' --fields=1 <<< ${commit_and_message})
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${commit}
    else
        echo ${commit}
    fi
}
zle -N fzf-complete-git-commit
bindkey '^xgc' fzf-complete-git-commit
Gcc () {
    local commit=$(fzf-complete-git-commit ${1})
    if [[ -z ${commit} ]]; then
        return
    fi
    git checkout ${commit}
}

fzf-complete-git-file() {
    if [[ -v LBUFFER ]]; then
        local query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
        eval "local expanded_query=${query}"
    else
        local query=${1}
        local expanded_query=${1}
    fi
    local file=$(git ls-files | fzf --query=${expanded_query})
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${file} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${file}
    else
        echo ${file}
    fi
}
zle -N fzf-complete-git-file
bindkey '^xgf' fzf-complete-git-file
Gcf () {
    local file=$(fzf-complete-git-file ${1})
    if [[ -z ${file} ]]; then
        return
    fi
    git checkout ${file}
}
