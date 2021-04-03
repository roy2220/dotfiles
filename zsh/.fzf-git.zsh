fzf-git-branch() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ -z ${current_branch} ]]; then
        return
    fi
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
    branch=$(awk '!visited[$0]++' <<< ${branches} | fzf)
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
zle -N fzf-git-branch
bindkey '^fgb' fzf-git-branch
Gcb () {
    local branch
    branch=$(fzf-git-branch)
    if [[ -z ${branch} ]]; then
        return
    fi
    git checkout ${branch}
}

fzf-git-tag() {
    if ! git rev-parse --is-inside-work-tree >/dev/null; then
        return
    fi
    local tags
    tags=$(git tag --list --sort=-version:refname)
    if [[ -z ${tags} ]]; then
        return
    fi
    local tag
    tag=$(fzf <<< ${tags})
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
zle -N fzf-git-tag
bindkey '^fgt' fzf-git-tag
Gct () {
    local tag
    tag=$(fzf-git-tag)
    if [[ -z ${tag} ]]; then
        return
    fi
    git checkout ${tag}
}

fzf-git-commit() {
    if ! git rev-parse --is-inside-work-tree >/dev/null; then
        return
    fi
    local commits_and_messages
    commits_and_messages=$(git log --format='%h %s')
    if [[ -z ${commits_and_messages} ]]; then
        return
    fi
    local commit_and_message
    commit_and_message=$(fzf <<< ${commits_and_messages})
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
        LBUFFER=${LBUFFER}${commit}
    else
        echo ${commit}
    fi
}
zle -N fzf-git-commit
bindkey '^fgc' fzf-git-commit
Gcc () {
    local commit
    commit=$(fzf-git-commit)
    if [[ -z ${commit} ]]; then
        return
    fi
    git checkout ${commit}
}

fzf-git-file() {
    if ! git rev-parse --is-inside-work-tree >/dev/null; then
        return
    fi
    local files
    files=$(git ls-files)
    if [[ -z ${files} ]]; then
        return
    fi
    local file
    file=$(fzf <<< ${files})
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
zle -N fzf-git-file
bindkey '^fgf' fzf-git-file
Gcf () {
    local file
    file=$(fzf-git-file)
    if [[ -z ${file} ]]; then
        return
    fi
    git checkout ${file}
}
