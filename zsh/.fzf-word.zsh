fzf-word() {
    local words
    words=$(tmux capture-pane -p | python2 -c '\
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
')
    local word
    word=$(fzf-tmux -d 10 <<< ${words})
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${word} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${word}
    else
        echo ${word}
    fi
}
zle -N fzf-word
bindkey '^fw' fzf-word
