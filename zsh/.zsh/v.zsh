() {

v() {
    local file=$(
        sed --regexp-extended --silent 's|^> (.+)$|\1|p' /workspace/.viminfo |
        python3 -c '
import sys
import os
file_paths = sys.stdin.readlines()
file_path_prefix = os.getcwd()
if not file_path_prefix.endswith("/"):
    file_path_prefix += "/"
file_rel_paths = []
i = 0
for file_path in file_paths:
    file_path = os.path.expanduser(file_path)
    if file_path.startswith(file_path_prefix):
        file_rel_path = file_path[len(file_path_prefix):]
        file_rel_paths.append(file_rel_path)
        continue
    file_paths[i] = file_path
    i += 1
del file_paths[i:]
sys.stdout.write("".join(file_rel_paths + file_paths))
' |
        fzf-popup --no-sort --prompt='File> '
    )
    if [[ -z ${file} ]]; then
        return
    fi
    send-command "vim ${@:q} ${file:q}"
}

}
