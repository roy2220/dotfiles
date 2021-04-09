fzf-complete-git-branch() {
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local raw_branches
    raw_branches=$(git branch --all --sort=-committerdate | cut --characters 3- | grep --fixed-strings --invert-match HEAD)
    local branches
    branches=$(sed --silent --regexp-extended 's/^(remotes\/)?(.+)$/\2/p' <<< ${raw_branches})
    local additional_branches
    additional_branches=$(sed --silent --regexp-extended 's/^remotes\/[^\/]+\/(.+)$/\1/p' <<< ${raw_branches})
    if [[ ! -z ${additional_branches} ]]; then
        local current_branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if [[ ${current_branch} == HEAD ]]; then
            branches+=$'\n'${additional_branches}
        else
            branches=${current_branch}$'\n'${branches}$'\n'${additional_branches}
        fi
    fi
    local branch
    branch=$(echo -n ${branches} | awk '!visited[$0]++' | fzf --query=${query})
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
    local branch
    branch=$(fzf-complete-git-branch)
    if [[ -z ${branch} ]]; then
        return
    fi
    git checkout ${branch}
}

fzf-complete-git-tag() {
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local tag
    tag=$(git tag --list --sort=-version:refname | fzf --query=${query})
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
    local tag
    tag=$(fzf-complete-git-tag)
    if [[ -z ${tag} ]]; then
        return
    fi
    git checkout ${tag}
}

fzf-complete-git-commit() {
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local commit_and_message
    commit_and_message=$(git log --format='%h %s' | fzf --query=${query})
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${commit_and_message} ]]; then
        return
    fi
    local commit
    commit=$(cut --delimiter=' ' --fields=1 <<< ${commit_and_message})
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${commit}
    else
        echo ${commit}
    fi
}
zle -N fzf-complete-git-commit
bindkey '^xgc' fzf-complete-git-commit
Gcc () {
    local commit
    commit=$(fzf-complete-git-commit)
    if [[ -z ${commit} ]]; then
        return
    fi
    git checkout ${commit}
}

fzf-complete-git-file() {
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local file
    file=$(git ls-files | fzf --query=${query})
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
    local file
    file=$(fzf-complete-git-file)
    if [[ -z ${file} ]]; then
        return
    fi
    git checkout ${file}
}
