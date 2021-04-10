z() {
    local dir
    dir=$(_z 2>&1 | cut -c12- | fzf --tac --no-sort)
    if [[ -z ${dir} ]]; then
        return
    fi
    cd ${dir}
}
