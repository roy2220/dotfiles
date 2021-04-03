fzf-word() {
    local words
    words=$(tmux capture-pane -p | python2 -c '\
import re
import sys

screen = sys.stdin.read()
words1 = set(screen.split("\n"))
words2 = set()
for word in words1:
    words2.update(re.split(r"\s+", screen))
words3 = set()
for word in words2:
    words3.update(re.findall(r"[a-zA-Z0-9_\-\.]+", word))
words4 = set()
for word in words3:
    words4.update(re.findall(r"[a-zA-Z0-9_]+", word))
words5 = set()
for word in words4:
    words5.update(re.findall(r"[a-zA-Z]+", word))
words6 = set()
for word in words4:
    words6.update(re.findall(r"[0-9]+", word))
for word in sorted(words1.union(words2).union(words3).union(words4).union(words5).union(words6)):
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
