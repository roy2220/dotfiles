fzf-complete-helm-release() {
    local release_locator=$(helm list --all-namespaces --output=json | python2 -c '\
import json
import sys

releases = json.loads(sys.stdin.read())
for release in releases:
    print("-n {} {}".format(release["namespace"], release["name"]))
' | fzf --prompt='Helm-Release> ')
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${release_locator} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${release_locator}
    else
        echo ${release_locator}
    fi
}
zle -N fzf-complete-helm-release
bindkey '^xhr' fzf-complete-helm-release
Hgr() {
    local release_locator=$(fzf-complete-helm-release)
    if [[ -z ${release_locator} ]]; then
        return
    fi
    send-command "helm get all ${@:+${@:q} }${release_locator} | ${EDITOR:q} -"
}
