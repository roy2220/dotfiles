e() {
    local db_file=${HOME}/.zsh/e.db
    local get_pwd_sql='SELECT dir.abs_path FROM dir INNER JOIN pwd ON dir.id = pwd.id'
    local delete_dirs_sql1='DELETE FROM dir WHERE id > (SELECT id FROM pwd)'
    local delete_dirs_sql2='DELETE FROM dir WHERE id <= (SELECT id FROM dir ORDER BY id DESC LIMIT 1 OFFSET 100)'
    local update_pwd_sql='REPLACE INTO pwd(dummy, id) SELECT 0, id FROM dir ORDER BY id DESC LIMIT 1'
    local show_pwd_script='
echo "Current Directory: ${PWD}\nCTRL-]: move into directory, CTRL-O: move back, CTRL-I: move forward"
ls --all --dereference --group-directories-first --indicator-style=slash -1
'
    if [[ ! -e ${db_file} ]]; then
        sqlite3 ${db_file} "
CREATE TABLE dir(id INTEGER PRIMARY KEY, abs_path INTEGER);
CREATE TABLE pwd(dummy INTEGER PRIMARY KEY, id INTEGER);
"
    fi
    local pwd
    pwd=$(sqlite3 ${db_file} ${get_pwd_sql})
    if [[ ${PWD} != ${pwd} ]]; then
        sqlite3 ${db_file} "
${delete_dirs_sql1};
INSERT INTO dir(id, abs_path) VALUES(NULL, \"${PWD}\");
${delete_dirs_sql2};
${update_pwd_sql};
"
    fi
    export PREVIEW_FILE_SCRIPT="
cd \$(sqlite3 ${db_file:q} ${get_pwd_sql:q})
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
    export MOVE_INTO_DIR_SCRIPT="
cd \$(sqlite3 ${db_file:q} ${get_pwd_sql:q})
if [[ \${FILE} != ./ && \${FILE[-1]} == / ]]; then
    cd \${FILE}
    sqlite3 ${db_file:q} \"
${delete_dirs_sql1};
INSERT INTO dir(id, abs_path) VALUES(NULL, \\\"\${PWD}\\\");
${delete_dirs_sql2};
${update_pwd_sql};
\"
fi
${show_pwd_script}
"
    export MOVE_INTO_PREV_DIR_SCRIPT="
DIR=\$(sqlite3 ${db_file:q} '
REPLACE INTO pwd(dummy, id) SELECT 0, dir.id FROM dir INNER JOIN pwd ON dir.id < pwd.id ORDER BY dir.id DESC LIMIT 1;
${get_pwd_sql};
')
cd \${DIR}
${show_pwd_script};
"
    export MOVE_INTO_NEXT_DIR_SCRIPT="
DIR=\$(sqlite3 ${db_file:q} '
REPLACE INTO pwd(dummy, id) SELECT 0, dir.id FROM dir INNER JOIN pwd ON dir.id > pwd.id ORDER BY dir.id ASC LIMIT 1;
${get_pwd_sql};
')
cd \${DIR}
${show_pwd_script}
"
    local file
    file=$(eval ${show_pwd_script} |
        SHELL=${ZSH_ARGZERO} fzf --height=100% --reverse \
        --header-lines=2 \
        --preview='FILE={}; eval ${PREVIEW_FILE_SCRIPT}' \
        --bind='ctrl-]:reload(FILE={}; eval ${MOVE_INTO_DIR_SCRIPT})+clear-query+first' \
        --bind='ctrl-o:reload(eval ${MOVE_INTO_PREV_DIR_SCRIPT})+clear-query+first' \
        --bind='ctrl-i:reload(eval ${MOVE_INTO_NEXT_DIR_SCRIPT})+clear-query+first')
    pwd=$(sqlite3 ${db_file} ${get_pwd_sql})
    if [[ -z ${file} ]]; then
        if [[ ${PWD} != ${pwd} ]]; then
            cd ${pwd}
        fi
        return
    fi
    if [[ ${file[-1]} == / ]]; then
        local dir
        dir=$(realpath ${pwd}/${file})
        if [[ ${PWD} != ${dir} ]]; then
            cd ${dir}
        fi
    else
        if [[ ${PWD} != ${pwd} ]]; then
            cd ${pwd}
        fi
        ${EDITOR:-vi} ${file}
    fi
}
