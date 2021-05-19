if [[ -o login ]]; then
    if [[ -f ~/.ssh/keys.tar.gpg ]]; then
        git -C ~/.files pull --ff-only
        stow --dir ~/.files $(ls ~/.files)
        find ~ -type l -exec test ! -e {} \; -delete
        until gpg -o- ~/.ssh/keys.tar.gpg | tar x -C ~/.ssh; do done
        rm ~/.ssh/keys.tar.gpg
        git -C ~/.files remote set-url origin git@github.com:roy2220/dotfiles.git
    fi

    export TERM=xterm-256color
    export SHELL=${0}
    export EDITOR=$(which vim)
    export PATH=${PATH:+${PATH}:}$(go env GOPATH)/bin:${HOME}/.local/bin
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${HOME}/.local/lib
    exec tmux new-session -A -s $(id --user --name)
fi

setopt histreduceblanks
setopt histignorespace
setopt histignorealldups
setopt autocd

alias k=kubectl
alias pc=proxychains
alias ydiff='ydiff --side-by-side --width=0 --wrap'

bindkey -v
bindkey -M vicmd ':' vi-rev-repeat-find
bindkey -M vicmd ',' execute-named-cmd

eval "$(direnv hook zsh)"

export FZF_DEFAULT_OPTS='--height=40% --reverse --bind '\''ctrl-y:execute-silent(echo -n {} | pbcopy; tmux set-buffer {})+abort'\'

test -f ${HOME}/.cache/p10k-instant-prompt-${(%):-%n}.zsh && source ${HOME}/.cache/p10k-instant-prompt-${(%):-%n}.zsh
source ~/.zplug/init.zsh
{
    zplug "romkatv/powerlevel10k", as:"theme", depth:1

    zplug "fnune/base16-fzf", use:"bash/base16-gruvbox-dark-medium.config", depth:1
    zplug "junegunn/fzf", use:"bin/fzf-tmux", as:"command", depth:1
    zplug "lib/completion.zsh", from:"oh-my-zsh", depth:1
    zplug "lib/history", from:"oh-my-zsh", depth:1
    zplug "plugins/vi-mode", from:"oh-my-zsh", depth:1
    zplug "plugins/z", from:"oh-my-zsh", depth:1, hook-load:"unalias z"
    zplug "zsh-users/zsh-completions", depth:1
    zplug "zsh-users/zsh-syntax-highlighting", depth:1

    zplug "junegunn/fzf", use:"shell/completion.zsh", depth:1, defer:2
    zplug "zsh-users/zsh-autosuggestions", depth:1, defer:2
    zplug "zsh-users/zsh-history-substring-search", depth:1, defer:2
}
zplug load
source ~/.p10k.zsh
for file in ~/.zsh/*.zsh; do
    source ${file}
done
unset file
