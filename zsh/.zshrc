() {

paleta <~/.local/share/palettes/gruvbox-dark

test -f ~/.cache/p10k-instant-prompt-${(%):-%n}.zsh && source ~/.cache/p10k-instant-prompt-${(%):-%n}.zsh
source ~/.p10k.zsh

source ~/.zplug/init.zsh
{
    zplug "romkatv/powerlevel10k", as:"theme", depth:1

    zplug "fnune/base16-fzf", depth:1
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

eval "$(direnv hook zsh)"

local file
for file in ~/.zsh/*.zsh; do
    source ${file}
done

}
