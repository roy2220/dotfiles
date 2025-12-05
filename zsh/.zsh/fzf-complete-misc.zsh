() {

_fzf-complete-command() {
    local command=$(python3 -c '
import os
import re
import sys

with open(os.getenv("HISTFILE"), "r", errors="ignore") as f:
    text = "\n" + f.read()

commands = re.split(r"\n: \d+:\d+;", text[:-1])[1:]
command_set = {}
for command in reversed(commands):
    command_set[command] = True
i = 0
for command in command_set:
    commands[i] = command.replace("\\\n", "\n")
    i += 1
commands = commands[:i]
sys.stdout.write("\0".join(commands))
' | (fzf-popup --read0 --no-sort --prompt='Command> ' && echo '#'))
    if [[ ${#command} -ge 2 ]]; then
        command=${command:0:-2}
    fi
    zle reset-prompt
    if [[ -z ${command} ]]; then
        return
    fi
    LBUFFER=${LBUFFER}${command}
}

zle -N _fzf-complete-command
bindkey '^r' _fzf-complete-command

_fzf-complete-file() {
    local input=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    if [[ -z ${input} ]]; then
        local prefix=
        local query=
    else
        if [[ ${input[-1]} == / ]]; then
            local prefix=${input}
            local query=
        else
            local prefix=$(dirname ${input})
            [[ ${prefix} != / ]] && prefix+=/
            local query=$(basename ${input})
        fi
    fi
    eval "local expanded_prefix=${prefix}"
    eval "local expanded_query=${query}"
    local file=$(find ${expanded_prefix} -mindepth 1 \( -type d -name .git -prune \) -o -type f -printf '%P\n' |
        fzf-popup --prompt="${expanded_prefix}> " --query=${expanded_query})
    zle reset-prompt
    if [[ -z ${file} ]]; then
        return
    fi
    LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${file}
}

zle -N _fzf-complete-file
bindkey '\e_KB=A-F\e\\' _fzf-complete-file

_fzf-complete-dir() {
    local input=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    if [[ -z ${input} ]]; then
        local prefix=
        local query=
    else
        if [[ ${input[-1]} == / ]]; then
            local prefix=${input}
            local query=
        else
            local prefix=$(dirname ${input})
            [[ ${prefix} != / ]] && prefix+=/
            local query=$(basename ${input})
        fi
    fi
    eval "local expanded_prefix=${prefix}"
    eval "local expanded_query=${query}"
    local dir=$(find ${expanded_prefix} -mindepth 1 \( -type d -name .git -prune \) -o -type d -printf '%P/\n' |
        fzf-popup --prompt="${expanded_prefix}> " --query=${expanded_query})
    zle reset-prompt
    if [[ -z ${dir} ]]; then
        return
    fi
    LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${dir}
}

zle -N _fzf-complete-dir
bindkey '\e_KB=A-D\e\\' _fzf-complete-dir

_fzf-complete-option1() {
    local command=$(BUFFER=${BUFFER} CURSOR=${CURSOR} python3 /dev/stdin <<'EOF'
import os
import re

import bashlex

buffer = os.environ["BUFFER"]
cursor = int(os.environ["CURSOR"])

nearest_command = None


def walk(node):
    global nearest_command
    if node.kind == "command":
        nodes = getattr(node, "parts", [])
        if len(nodes) >= 1 and nodes[0].kind == "word" and cursor > nodes[0].pos[1]:
            if nearest_command is None or node.pos[0] > nearest_command.pos[0]:
                nearest_command = node
    nodes = getattr(node, "parts", [])
    for node in nodes:
        walk(node)
    nodes = getattr(node, "list", [])
    for node in nodes:
        walk(node)


if buffer != "":
    for node in bashlex.parse(buffer):
        walk(node)

if nearest_command is not None:
    parts = [nearest_command.parts[0].word]
    for node in nearest_command.parts[1:]:
        if not re.fullmatch(r"[a-zA-Z][-_a-zA-Z]*", node.word):
            break
        parts.append(node.word)
    parts.append("--help")
    print(" ".join(parts))
EOF
)
    if [[ -z ${command} ]]; then
        return
    fi
    local option=$(${=command} 2>&1 |
        grep --perl-regexp --only-matching '(?<=^|\s|\[)-+[-_a-zA-Z0-9]+' |
        fzf-popup --prompt="${command} > ")
    LBUFFER=${LBUFFER}${option}
}

zle -N _fzf-complete-option1
bindkey '\e_KB=A-H\e\\' _fzf-complete-option1

_fzf-complete-option2() {
    local command=$(BUFFER=${BUFFER} CURSOR=${CURSOR} python3 /dev/stdin <<'EOF'
import os
import re

import bashlex

buffer = os.environ["BUFFER"]
cursor = int(os.environ["CURSOR"])

nearest_command = None


def walk(node):
    global nearest_command
    if node.kind == "command":
        nodes = getattr(node, "parts", [])
        if len(nodes) >= 1 and nodes[0].kind == "word" and cursor > nodes[0].pos[1]:
            if nearest_command is None or node.pos[0] > nearest_command.pos[0]:
                nearest_command = node
    nodes = getattr(node, "parts", [])
    for node in nodes:
        walk(node)
    nodes = getattr(node, "list", [])
    for node in nodes:
        walk(node)


if buffer != "":
    for node in bashlex.parse(buffer):
        walk(node)

if nearest_command is not None:
    parts = [nearest_command.parts[0].word]
    for node in nearest_command.parts[1:]:
        if not re.fullmatch(r"[a-zA-Z][-_a-zA-Z]*", node.word):
            break
        parts.append(node.word)
    parts[1:1] = ["help"]
    print(" ".join(parts))
EOF
)
    if [[ -z ${command} ]]; then
        return
    fi
    local option=$(${=command} 2>&1 |
        grep --perl-regexp --only-matching '(?<=^|\s|\[)-+[-_a-zA-Z0-9]+' |
        fzf-popup --prompt="${command} > ")
    LBUFFER=${LBUFFER}${option}
}

zle -N _fzf-complete-option2
bindkey '\e_KB=A-S-H\e\\' _fzf-complete-option2

}
