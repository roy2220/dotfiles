fzf-complete-k8s-resource() {
    # local etcdctl_cmd="
    #     kubectl exec --namespace=kube-system pod/etcd-docker-desktop -- sh -c '
    #         ETCDCTL_CACERT=/run/config/pki/etcd/ca.crt
    #         ETCDCTL_CERT=/run/config/pki/etcd/server.crt
    #         ETCDCTL_KEY=/run/config/pki/etcd/server.key
    #         ETCDCTL_API=3
    #         etcdctl get /registry/ --prefix --keys-only
    #     '
    # "
    local etcdctl_cmd='
        ETCDCTL_ENDPOINTS=192.168.134.133:2379
        ETCDCTL_CACERT=~/.config/pki/etcd/ca.crt
        ETCDCTL_CERT=~/.config/pki/etcd/client.crt
        ETCDCTL_KEY=~/.config/pki/etcd/client.key
        ETCDCTL_API=3
        etcdctl get /registry/ --prefix --keys-only
    '
    local resource_locator=$(eval ${=etcdctl_cmd} | python2 -c '\
import re
import sys

lines = sys.stdin.read().split("\n")
bad_resource_types = {"minions", "ranges", "masterleases"}
last_dir_resource = None
for line in lines:
    line = line.strip()
    if line == "":
        continue
    line = line[len("/registry/") :]
    line = re.sub(r"^services/endpoints/(.+)", r"endpoints/\g<1>", line)
    line = re.sub(r"^services/specs/(.+)", r"services/\g<1>", line)
    parts = line.split("/")
    if parts[0].find(".") >= 0:
        parts = parts[1:]
    resource_type = parts[0]
    if resource_type in bad_resource_types:
        continue
    if len(parts) not in (2, 3):
        continue
    if len(parts) == 2:
        dir_resource = parts[0]
    elif len(parts) == 3:
        dir_resource = "-n {} {}".format(parts[1], parts[0])
    else:
        assert(False)
    if dir_resource != last_dir_resource:
        print(dir_resource)
        last_dir_resource = dir_resource
    print("{}/{}".format(dir_resource, parts[-1]))
' | fzf)
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${resource_locator} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${resource_locator}
    else
        echo ${resource_locator}
    fi
}
zle -N fzf-complete-k8s-resource
bindkey '^xkr' fzf-complete-k8s-resource
Kgr() {
    local resource_locator=$(fzf-complete-k8s-resource)
    if [[ -z ${resource_locator} ]]; then
        return
    fi
    local cmd="kubectl get ${@:+${@:q} }${resource_locator}"
    print -rs ${cmd}
    ${=cmd}
}
Kdr() {
    local resource_locator=$(fzf-complete-k8s-resource)
    if [[ -z ${resource_locator} ]]; then
        return
    fi
    local cmd="kubectl describe ${@:+${@:q} }${resource_locator}"
    print -rs ${cmd}
    ${=cmd}
}
Ker() {
    local resource_locator=$(fzf-complete-k8s-resource)
    if [[ -z ${resource_locator} ]]; then
        return
    fi
    local cmd="kubectl edit ${@:+${@:q} }${resource_locator}"
    print -rs ${cmd}
    ${=cmd}
}
