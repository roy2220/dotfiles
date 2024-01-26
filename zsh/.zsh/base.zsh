() {

setopt histreduceblanks
setopt histignorespace
setopt histignorealldups
setopt autocd
setopt interactivecomments

alias k=kubectl
alias kg='kubectl get'
alias kd='kubectl describe'
alias ke='kubectl exec'
alias kl='kubectl logs'
alias ydiff='ydiff --side-by-side --width=0 --wrap --'

bindkey -v
bindkey -M vicmd ':' vi-rev-repeat-find
bindkey -M vicmd ',' execute-named-cmd
bindkey -M vicmd 'Y' vi-yank-eol

}
