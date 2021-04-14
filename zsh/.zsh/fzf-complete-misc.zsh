fzf-complete-command() {
    local command=$(fc -nrl 1 | fzf --no-sort --query=${LBUFFER})
    zle reset-prompt
    if [[ -z ${command} ]]; then
        return
    fi
    LBUFFER=$(echo -e ${command})
}
zle -N fzf-complete-command
bindkey '^r' fzf-complete-command

fzf-complete-file() {
    local dir_or_query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    if [[ ${dir_or_query[-1]} == / ]]; then
        eval "local expanded_dir=${dir_or_query}"
        local file=$(find ${expanded_dir} -mindepth 1 \( -type f -printf '%P\n' \) -or \( -type d -printf '%P/\n' \) | fzf --prompt=${expanded_dir})
        local query=
    else
        eval "local expanded_query=${dir_or_query}"
        local file=$(find . -mindepth 1 \( -type f -printf '%P\n' \) -or \( -type d -printf '%P/\n' \) | fzf --query=${expanded_query})
        local query=${dir_or_query}
    fi
    zle reset-prompt
    if [[ -z ${file} ]]; then
        return
    fi
    LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${file}
}
zle -N fzf-complete-file
bindkey '^x^f' fzf-complete-file

fzf-complete-word() {
    local query=$(grep --perl-regexp --only-matching '[^\s]+$' <<< ${LBUFFER})
    eval "local expanded_query=${query}"
    local word=$(tmux capture-pane -p | python2 -c '\
import itertools
import re
import sys

screen = sys.stdin.read()
words1 = set(screen.split("\n"))

pattern = re.compile(r"\s+")
words2 = set()
for word in words1:
    words2.update(pattern.split(word))

delimiters = (r"\-", r"\.", r"@", r":", r"/")
words3 = set()
for n in range(0, len(delimiters) + 1):
    for sub_delimiters in itertools.combinations(delimiters, n):
        pattern = re.compile(r"[_a-zA-Z0-9{}]+".format("".join(sub_delimiters)))
        for word in words2:
            words3.update(pattern.findall(word))

pattern = re.compile(r"[a-zA-Z]+|[0-9]+")
words4 = set()
for word in words3:
    words4.update(pattern.findall(word))

words = words1.union(words2).union(words3).union(words4)
words.remove("")
for word in sorted(words):
    print(word)
' | fzf-tmux -d 10 -- --query=${expanded_query})
    zle reset-prompt
    if [[ -z ${word} ]]; then
        return
    fi
    LBUFFER=${LBUFFER:0:${#LBUFFER}-${#query}}${word}
}
zle -N fzf-complete-word
bindkey '^x^w' fzf-complete-word
