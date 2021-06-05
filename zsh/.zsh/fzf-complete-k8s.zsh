fzf-complete-k8s-resource() {
    local resource_locator=$( \
        ETCDCTL_ENDPOINTS=127.0.0.1:2379 \
        ETCDCTL_CACERT=~/.config/pki/etcd/ca.crt \
        ETCDCTL_CERT=~/.config/pki/etcd/client.crt \
        ETCDCTL_KEY=~/.config/pki/etcd/client.key \
        ETCDCTL_API=3 \
        etcdctl get /registry/ --prefix --keys-only \
        | python3 -c '\
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
' | fzf --prompt='K8s-Resource> ')
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
    send-command "kubectl get ${@:+${@:q} }${resource_locator}"
}
Kdr() {
    local resource_locator=$(fzf-complete-k8s-resource)
    if [[ -z ${resource_locator} ]]; then
        return
    fi
    send-command "kubectl describe ${@:+${@:q} }${resource_locator} | ${EDITOR:q} -"
}
Ker() {
    local resource_locator=$(fzf-complete-k8s-resource)
    if [[ -z ${resource_locator} ]]; then
        return
    fi
    send-command "kubectl edit ${@:+${@:q} }${resource_locator}"
}
Krr() {
    local resource_locator=$(fzf-complete-k8s-resource)
    if [[ -z ${resource_locator} ]]; then
        return
    fi
    if [[ $(basename ${EDITOR}) == vim ]]; then
        send-command "kubectl get --output=yaml ${@:+${@:q} }${resource_locator} | ${EDITOR:q} +'set buftype=nofile filetype=yaml' -"
    else
        send-command "kubectl get --output=yaml ${@:+${@:q} }${resource_locator} | ${EDITOR:q} -"
    fi
}
fzf-complete-k8s-container() {
    local container_locator=$(kubectl get pods --all-namespaces --output=jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{range .spec.containers[*]}{" "}{.name}{end}{"\n"}{end}' | python3 -c '\
import sys

lines = sys.stdin.read().rstrip().split("\n")
for line in lines:
    parts = line.split(" ")
    namespace = parts[0]
    pod_name = parts[1]
    for container_name in parts[2:]:
        print("-n {} {} -c {}".format(namespace, pod_name, container_name))
' | fzf --prompt='K8s-Container> ')
    [[ -v LBUFFER ]] && zle reset-prompt
    if [[ -z ${container_locator} ]]; then
        return
    fi
    if [[ -v LBUFFER ]]; then
        LBUFFER=${LBUFFER}${container_locator}
    else
        echo ${container_locator}
    fi
}
zle -N fzf-complete-k8s-container
bindkey '^xkc' fzf-complete-k8s-container
Klc() {
    local container_locator=$(fzf-complete-k8s-container)
    if [[ -z ${container_locator} ]]; then
        return
    fi
    send-command "kubectl logs ${@:+${@:q} }${container_locator} | ${EDITOR:q} -"
}
Kec() {
    local container_locator=$(fzf-complete-k8s-container)
    if [[ -z ${container_locator} ]]; then
        return
    fi
    send-command "kubectl exec -it ${container_locator} -- ${@:-sh}"
}
