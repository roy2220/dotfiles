() {

alias z=_z

_z() {
    local dir=$(zshz | cut --characters=12- | fzf-popup --tac --no-sort --prompt='Directory> ')
    if [[ -z ${dir} ]]; then
        return
    fi
    cd ${dir}
}

}
