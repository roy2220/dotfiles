[[ -f /tmp/zprofile ]] && source /tmp/zprofile

if [[ ${DOCKER_HOST_OS} == mac ]]; then
    DOCKER_HOST_IP=$(dig +short host.docker.internal)
    echo "${DOCKER_HOST_IP} host.docker.internal" >>/etc/hosts
    RULE="OUTPUT -t nat -p udp -d 1.1.1.1 --dport 53 -j DNAT --to ${DOCKER_HOST_IP}:1053"
    iptables -C ${=RULE} || iptables -A ${=RULE}
    echo 'nameserver 1.1.1.1' >/etc/resolv.conf
fi

if [[ ! -d ~/.secrets ]]; then
    git -C ~/.files pull --ff-only
    git -C ~/.files remote set-url origin git@github.com:roy2220/dotfiles.git

    stow --dir ~/.files $(ls ~/.files)
    find ~ -type l -exec test ! -e {} \; -delete

    mkdir ~/.secrets
fi

while true; do
    read -rs 'PASSWORD?Password: '
    echo
    PASSWORD=$(~/.local/bin/_rclone obscure - <<<${PASSWORD})
    echo 'mounting secrets...'
    ~/.local/bin/_rclone --config=/dev/null mount --daemon \
        --dir-perms=0700 \
        --file-perms=0600 \
        :crypt: \
        --devname=crypt: \
        --crypt-remote=/root/.local/share/secrets \
        --crypt-filename-encryption=standard \
        --crypt-directory-name-encryption=true \
        --crypt-password=${PASSWORD} \
        --crypt-strict-names \
        ~/.secrets
    unset PASSWORD

    if ls -1 ~/.secrets >/dev/null 2>&1; then
        break
    fi

    fusermount3 -u ~/.secrets
done
source ~/.secrets/envrc

export TERM=xterm-256color
export SHELL=${0}
export EDITOR=$(which nvim)
export PATH=~/.local/bin:~/go/bin:~/.cargo/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=~/.local/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# for zsh
export KEYTIMEOUT=100
# for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--history='\'${HOME}'/.fzf_history'\'' --height=38% --reverse --info=inline --bind '\''ctrl-y:execute-silent(echo -n {} | pbcopy; tmux set-buffer {})+abort'\'
# for ossutil
export OSSUTIL_CONFIG_FILE=~/.secrets/ossutil/config
# for rclone
export RCLONE_CONFIG_FILE=~/.secrets/rclone/rclone.conf
export HISTFILE=/workspace/.zsh_history
export ZSHZ_DATA=/workspace/.z
# for chatgpt-cli
export OPENAI_CONFIG_HOME=~/.secrets/chatgpt-cli
export OPENAI_DATA_HOME=~/.local/share/chatgpt-cli

find -H ~/.local/src -mindepth 1 -maxdepth 1 -type f -name '*-start-*.bash' -print0 | sort --zero-terminated | xargs --null --max-lines=1 -- bash

source ~/.zsh/paleta.zsh
source ~/.zplug/repos/fnune/base16-fzf/bash/base16-gruvbox-dark-soft.config

exec tmux new-session -A -s $(id --user --name)
