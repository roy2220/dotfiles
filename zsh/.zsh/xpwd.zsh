() {

set-xpwd() {
    if [[ ${PWD}/ == /workspace/* ]]; then
        XPWD=${XPWD_PREFIX_1}${PWD:10}
    else
        XPWD=${XPWD_PREFIX_0}${PWD}
    fi
}
export XPWD_PREFIX_0=$(docker inspect --format='{{.GraphDriver.Data.MergedDir}}' ${HOST})
export XPWD_PREFIX_1=$(docker inspect --format='{{range .Mounts}}{{if eq .Destination "/workspace"}}{{.Source}}{{end}}{{end}}' ${HOST})
export XPWD
set-xpwd
add-zsh-hook chpwd set-xpwd

}
