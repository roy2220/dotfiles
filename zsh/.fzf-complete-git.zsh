fzf-complete-git-branch() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ -z ${current_branch} ]]; then
        return
    fi
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local raw_branches
    raw_branches=$(git branch --all --sort=-committerdate | cut --characters 3- | grep --fixed-strings --invert-match HEAD)
    if [[ -z ${raw_branches} ]]; then
        return
    fi
    local branches
    branches=$(sed --silent --regexp-extended 's/^(remotes\/)?(.+)$/\2/p' <<< ${raw_branches})
    local additional_branches
    additional_branches=$(sed --silent --regexp-extended 's/^remotes\/[^\/]+\/(.+)$/\1/p' <<< ${raw_branches})
    if [[ ! -z ${additional_branches} ]]; then
        if [[ ${current_branch} == HEAD ]]; then
            branches+=$'\n'${additional_branches}
        else
            branches=${current_branch}$'\n'${branches}$'\n'${additional_branches}
        fi
    fi
    local branch
    branch=$(awk '!visited[$0]++' <<< ${branches} | fzf --query=${query})
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
bindkey '^kgb' fzf-complete-git-branch
Gcb () {
    local branch
    branch=$(fzf-complete-git-branch)
    if [[ -z ${branch} ]]; then
        return
    fi
    git checkout ${branch}
}

fzf-complete-git-tag() {
    if ! git rev-parse --is-inside-work-tree >/dev/null; then
        return
    fi
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local tags
    tags=$(git tag --list --sort=-version:refname)
    if [[ -z ${tags} ]]; then
        return
    fi
    local tag
    tag=$(fzf --query=${query} <<< ${tags})
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
bindkey '^kgt' fzf-complete-git-tag
Gct () {
    local tag
    tag=$(fzf-complete-git-tag)
    if [[ -z ${tag} ]]; then
        return
    fi
    git checkout ${tag}
}

fzf-complete-git-commit() {
    if ! git rev-parse --is-inside-work-tree >/dev/null; then
        return
    fi
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local commits_and_messages
    commits_and_messages=$(git log --format='%h %s')
    if [[ -z ${commits_and_messages} ]]; then
        return
    fi
    local commit_and_message
    commit_and_message=$(fzf --query=${query} <<< ${commits_and_messages})
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${commit_and_message} ]]; then
        return
    fi
    local commit
    commit=$(cut --delimiter=' ' --fields=1 <<< ${commit_and_message})
    if [[ -z ${commit} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${commit}
    else
        echo ${commit}
    fi
}
zle -N fzf-complete-git-commit
bindkey '^kgc' fzf-complete-git-commit
Gcc () {
    local commit
    commit=$(fzf-complete-git-commit)
    if [[ -z ${commit} ]]; then
        return
    fi
    git checkout ${commit}
}

fzf-complete-git-file() {
    if ! git rev-parse --is-inside-work-tree >/dev/null; then
        return
    fi
    local query
    [[ -v LBUFFER ]] && query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    local files
    files=$(git ls-files)
    if [[ -z ${files} ]]; then
        return
    fi
    local file
    file=$(fzf --query=${query} <<< ${files})
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
bindkey '^kgf' fzf-complete-git-file
Gcf () {
    local file
    file=$(fzf-complete-git-file)
    if [[ -z ${file} ]]; then
        return
    fi
    git checkout ${file}
}
