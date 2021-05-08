send-command() {
    print -rz ${1}
    add-zsh-hook precmd _send-enter
}
_send-enter() {
    add-zsh-hook -d precmd _send-enter
    tmux send-keys Enter
}
