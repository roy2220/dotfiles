() {

# Enable csi-u mode 1
printf '\033[>4;1m'

test -f ~/.cache/p10k-instant-prompt-${(%):-%n}.zsh && source ~/.cache/p10k-instant-prompt-${(%):-%n}.zsh
source ~/.p10k.zsh

##### BEGIN PLUGINS #####
source ~/.zplug/init.zsh
{
    zplug "romkatv/powerlevel10k", as:"theme", hook-build:"./gitstatus/install", depth:1

    zplug "tinted-theming/tinted-shell", depth:1, use:"./scripts/base16-everforest-dark-medium.sh"
    zplug "tinted-theming/tinted-fzf", depth:1
    zplug "junegunn/fzf", use:"bin/fzf-tmux", as:"command", depth:1
    zplug "lib/completion.zsh", from:"oh-my-zsh", depth:1
    zplug "lib/history", from:"oh-my-zsh", depth:1
    zplug "plugins/vi-mode", from:"oh-my-zsh", depth:1
    zplug "plugins/z", from:"oh-my-zsh", depth:1
    zplug "zsh-users/zsh-completions", depth:1
    zplug "zsh-users/zsh-syntax-highlighting", depth:1

    zplug "zsh-users/zsh-autosuggestions", depth:1, defer:2
    zplug "zsh-users/zsh-history-substring-search", depth:1, defer:2
}
zplug load
##### END PLUGINS #####

eval "$(direnv hook zsh)"

local file
for file in ~/.zsh/*.zsh; do
    source ${file}
done

}
