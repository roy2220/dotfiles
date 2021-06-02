send-command() {
    print -rz ${1}
    tmux send-keys Enter
}
