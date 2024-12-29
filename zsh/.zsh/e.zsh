() {

export E_DB_FILE=~/.cache/e.db

e() { ee . }

ee() {
    local get_cur_dir_sql='SELECT dir.abs_path FROM dir INNER JOIN cur_dir ON dir.id = cur_dir.id'
    local update_cur_dir_script="
if [[ \${dir} != \${cur_dir} ]]; then
    sqlite3 \${E_DB_FILE} '
DELETE FROM dir WHERE id > (SELECT id FROM cur_dir);
INSERT INTO dir(id, abs_path) VALUES(NULL, '\\'\${dir}\\'');
DELETE FROM dir WHERE id <= (SELECT id FROM dir ORDER BY id DESC LIMIT 1 OFFSET 100);
REPLACE INTO cur_dir(dummy, id) SELECT 0, id FROM dir ORDER BY id DESC LIMIT 1;
'
    cur_dir=\${dir}
fi
"
    local show_cur_dir_script='
echo "Current Directory: ${cur_dir}\n<CTRL-]>: move into directory    <ENTER>: change directory / edit file \n<CTRL-O>: move back              <CTRL-I>: move forward"
ls --all --dereference --group-directories-first --indicator-style=slash -1 ${cur_dir} 2>/dev/null |
    sed --regexp-extended '\''s/(.+)\/$/📁 \1/'\'' || true
'
    if [[ ! -e ${E_DB_FILE} ]]; then
        mkdir --parents "$(dirname ${E_DB_FILE})"
        sqlite3 ${E_DB_FILE} '
CREATE TABLE dir(id INTEGER PRIMARY KEY, abs_path INTEGER);
INSERT INTO dir(id, abs_path) VALUES(1, '\''/'\'');
CREATE TABLE cur_dir(dummy INTEGER PRIMARY KEY, id INTEGER);
INSERT INTO cur_dir(dummy, id) VALUES(0, 1);
'
    fi
    local cur_dir=$(sqlite3 ${E_DB_FILE} ${get_cur_dir_sql})
    if [[ ! -z ${1} ]]; then
        local dir=$(realpath ${1})
        eval ${update_cur_dir_script}
    fi
    if which bat >/dev/null 2>&1; then
        local cat_cmd='bat --color=always --style=numbers'
    else
        local cat_cmd='cat'
    fi
    export E_PREVIEW_FILE_SCRIPT="
local cur_dir=\$(sqlite3 \${E_DB_FILE} ${get_cur_dir_sql:q})
if [[ \${name[1]} == 📁 ]]; then
    local dir=\${cur_dir}/\${name:2}
    ls --all --format=long --group-directories-first --human-readable --indicator-style=classify \${dir} --color
else
    local file=\${cur_dir}/\${name}
    if [[ -f \${file} ]]; then
        ${cat_cmd} \${file}
    else
        echo 'not a regular file'
    fi
fi
"
    export E_MOVE_INTO_DIR_SCRIPT="
local cur_dir=\$(sqlite3 \${E_DB_FILE} ${get_cur_dir_sql:q})
if [[ \${name[1]} == 📁 ]]; then
    local dir=\$(realpath \${cur_dir}/\${name:2})
    ${update_cur_dir_script}
fi
${show_cur_dir_script}
"
    export E_MOVE_INTO_PREV_DIR_SCRIPT="
local cur_dir=\$(sqlite3 \${E_DB_FILE} '
REPLACE INTO cur_dir(dummy, id) SELECT 0, dir.id FROM dir INNER JOIN cur_dir ON dir.id < cur_dir.id ORDER BY dir.id DESC LIMIT 1;
${get_cur_dir_sql};
')
${show_cur_dir_script};
"
    export E_MOVE_INTO_NEXT_DIR_SCRIPT="
local cur_dir=\$(sqlite3 \${E_DB_FILE} '
REPLACE INTO cur_dir(dummy, id) SELECT 0, dir.id FROM dir INNER JOIN cur_dir ON dir.id > cur_dir.id ORDER BY dir.id ASC LIMIT 1;
${get_cur_dir_sql};
')
${show_cur_dir_script}
"
    local name=$(eval ${show_cur_dir_script} |
        SHELL=${ZSH_ARGZERO} fzf --bind=ctrl-z:ignore --height=100% --reverse \
        --header-lines=3 \
        --preview='name={}; eval ${E_PREVIEW_FILE_SCRIPT}' \
        --bind='ctrl-]:reload(name={}; eval ${E_MOVE_INTO_DIR_SCRIPT})+clear-query+first' \
        --bind='ctrl-o:reload(eval ${E_MOVE_INTO_PREV_DIR_SCRIPT})+clear-query+first' \
        --bind='ctrl-i:reload(eval ${E_MOVE_INTO_NEXT_DIR_SCRIPT})+clear-query+first')
    if [[ -z ${name} ]]; then
        return
    fi
    cur_dir=$(sqlite3 ${E_DB_FILE} ${get_cur_dir_sql})
    if [[ ${name[1]} == 📁 ]]; then
        local dir=$(realpath ${cur_dir}/${name:2})
        if [[ ${dir} != ${PWD} ]]; then
            cd ${dir}
        fi
    else
        (cd ${cur_dir}; ${EDITOR:-$(which nvim vi nano | head -1)} ${name})
    fi
}

}
