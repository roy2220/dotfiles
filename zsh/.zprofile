DOCKER_HOST_IP=$(dig +short host.docker.internal)
echo "${DOCKER_HOST_IP} host.docker.internal" >>/etc/hosts
RULE="OUTPUT -t nat -p udp -d 1.1.1.1 --dport 53 -j DNAT --to ${DOCKER_HOST_IP}:1053"
iptables -C ${=RULE} || iptables -A ${=RULE}
echo 'nameserver 1.1.1.1' >/etc/resolv.conf

if [[ ! -d ~/.secrets ]]; then
    git -C ~/.files pull --ff-only
    git -C ~/.files remote set-url origin git@github.com:roy2220/dotfiles.git

    stow --dir ~/.files $(ls ~/.files)
    find ~ -type l -exec test ! -e {} \; -delete

    mkdir ~/.secrets
fi

until ~/go/bin/gocryptfs -nosyslog ~/.files/local/.local/share/secrets ~/.secrets; do done
chmod --recursive g=,o= ~/.secrets

export TERM=xterm-256color
export SHELL=${0}
export EDITOR=$(which vim)
export PATH=~/.local/bin:~/go/bin:/usr/local/go/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=~/.local/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# for zsh
export KEYTIMEOUT=100
# for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--history='\'${HOME}'/.fzf_history'\'' --height=38% --reverse --info=inline --bind '\''ctrl-y:execute-silent(echo -n {} | pbcopy; tmux set-buffer {})+abort'\'
# for ossutil
export OSSUTIL_CONFIG_FILE=~/.secrets/ossutil/config
export HISTFILE=/workspace/.zsh_history
export ZSHZ_DATA=/workspace/.z

[[ -f /tmp/zprofile ]] && source /tmp/zprofile

paleta <~/.local/share/palettes/gruvbox-dark
source ~/.zplug/repos/fnune/base16-fzf/bash/base16-gruvbox-dark-medium.config

find ~/.local/src -mindepth 1 -maxdepth 1 -type f -name '*-start-*.bash' -print0 | sort --zero-terminated | xargs --null --max-lines=1 -- bash
exec tmux new-session -A -s $(id --user --name)
