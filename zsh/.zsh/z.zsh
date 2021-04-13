z() {
    local dir=$(_z 2>&1 | cut --characters=12- | fzf --tac --no-sort)
    if [[ -z ${dir} ]]; then
        return
    fi
    cd ${dir}
}
