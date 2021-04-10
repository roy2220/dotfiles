e() {
    local x_pwd_file
    x_pwd_file=$(mktemp)
    {
        local list_pwd_script="
pwd > ${x_pwd_file:q}
echo \"Current Directory: \${PWD}\nCTRL-I: go to directory, CTRL-O: go to parent directory\"
ls --all --dereference --group-directories-first --indicator-style=slash -1
"
        export PREVIEW_FILE_SCRIPT="
FILE=\$(< ${x_pwd_file:q})/\${X}
if [[ \${FILE[-1]} == / ]]; then
    ls --all --format=long --group-directories-first --human-readable --indicator-style=classify \${FILE} --color
else
    if [[ -f \${FILE} ]]; then
        cat \${FILE}
    else
        echo 'not a regular file'
    fi
fi
"
        export GO_TO_DIR_SCRIPT="
FILE=\$(< ${x_pwd_file:q})/\${X}
if [[ \${FILE[-1]} == / ]]; then
    cd \${FILE}
fi
${list_pwd_script}
"
        export GO_TO_PARENT_DIR_SCRIPT="
cd \$(< ${x_pwd_file:q})/..
${list_pwd_script}
"
        local file
        file=$(eval ${list_pwd_script} |
            SHELL=${ZSH_ARGZERO} fzf --height=100% --reverse \
            --header-lines=2 \
            --preview='X={}; eval ${PREVIEW_FILE_SCRIPT}' \
            --bind='ctrl-i:reload(X={}; eval ${GO_TO_DIR_SCRIPT})+clear-query+first' \
            --bind='ctrl-o:reload(eval ${GO_TO_PARENT_DIR_SCRIPT})+clear-query+first')
        local x_pwd
        x_pwd=$(< ${x_pwd_file})
        if [[ ${PWD} != ${x_pwd} ]]; then
            cd ${x_pwd}
        fi
        if [[ -z ${file} ]]; then
            return
        fi
        if [[ ${file[-1]} == / ]]; then
            cd ${file}
        else
            ${EDITOR:-vi} ${file}
        fi
    } always {
        rm ${x_pwd_file}
    }
}
