() {

_fzf-complete-git-branch() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
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
    local branch=$(head --bytes=-1 <<< ${branches} | awk '!visited[$0]++' | fzf-popup --prompt='Git-Branch> ')
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

zle -N _fzf-complete-git-branch
bindkey '\e_KB=A-G\e\\b' _fzf-complete-git-branch

Gcb() {
    local branch=$(_fzf-complete-git-branch)
    if [[ -z ${branch} ]]; then
        return
    fi
    send-command "git checkout ${@:+${@:q} }${branch:q}"
}

_fzf-complete-git-tag() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
    local tag=$(git tag --list --sort=-version:refname | fzf-popup --prompt='Git-Tag> ')
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

zle -N _fzf-complete-git-tag
bindkey '^\e_KB=A-G\e\\t' _fzf-complete-git-tag

Gct() {
    local tag=$(_fzf-complete-git-tag)
    if [[ -z ${tag} ]]; then
        return
    fi
    send-command "git checkout ${@:+${@:q} }${tag:q}"
}

_fzf-complete-git-commit() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
    local commit_and_message=$(git log --format='%h %s' | fzf-popup --prompt='Git-Commit> ')
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

zle -N _fzf-complete-git-commit
bindkey '\e_KB=A-G\e\\c' _fzf-complete-git-commit

Gcc() {
    local commit=$(_fzf-complete-git-commit)
    if [[ -z ${commit} ]]; then
        return
    fi
    send-command "git checkout ${@:+${@:q} }${commit:q}"
}

_fzf-complete-git-file() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
    local file=$(git ls-files | fzf-popup --prompt='Git-File> ')
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

zle -N _fzf-complete-git-file
bindkey '\e_KB=A-G\e\\f' _fzf-complete-git-file

Gcf() {
    local file=$(_fzf-complete-git-file)
    if [[ -z ${file} ]]; then
        return
    fi
    send-command "git checkout ${@:+${@:q} }${file:q}"
}

}
