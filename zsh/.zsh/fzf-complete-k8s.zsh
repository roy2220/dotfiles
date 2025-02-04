() {

_fzf-complete-k8s() {
    local resource_kind=$(grep --perl-regexp --only-matching '[^\s]+(?=(/|\s)$)' <<<${LBUFFER})
    local resource_name
    local lbuffer
    if [[ ! -z ${resource_kind} && ${resource_kind} != -* ]]; then
        resource_name=$(kubectl get ${resource_kind} --output=custom-columns=':.metadata.name' --no-headers | fzf-popup --prompt="K8s:${resource_kind}> ")
        lbuffer=${LBUFFER[0,-2]}/
    else
        local service_of_containers=$(grep --perl-regexp --only-matching '(?<=svc(/|\s))[^\s]+(?=\s\-c\s?$)' <<<${LBUFFER})
        if [[ ! -z ${service_of_containers} && ${service_of_containers} != -* ]]; then
            local pod_of_containers=$(kubectl get endpoints/${service_of_containers} --output=jsonpath='{.subsets[0].addresses[0].targetRef.name}')
        else
            local pod_of_containers=$(grep --perl-regexp --only-matching '(?<=pod(/|\s))[^\s]+(?=\s\-c\s?$)' <<<${LBUFFER})
        fi
        if [[ ! -z ${pod_of_containers} && ${pod_of_containers} != -* ]]; then
            resource_name=$(kubectl get pod/${pod_of_containers} --output=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' | fzf-popup --prompt='K8s:container> ')
            lbuffer=${LBUFFER}
        fi
    fi
    zle reset-prompt
    if [[ -z ${resource_name} ]]; then
        return
    fi
    LBUFFER=${lbuffer}${resource_name}
}

zle -N _fzf-complete-k8s
bindkey '\e_#KB#A-K\a' _fzf-complete-k8s

Kcn() {
    local current_namespace=$(kubectl config get-contexts | grep --max-count=1 --perl-regexp '^\*' | awk '{ print $5 == "" ? "default" : $5 }')
    local namespace=$(kubectl get namespace --output=custom-columns=':.metadata.name' --no-headers |
        grep --invert-match --fixed-strings ${current_namespace} |
        fzf-popup --prompt="K8s:namespace(${current_namespace})> ")
    if [[ -z ${namespace} ]]; then
        return
    fi
    kubectl config set-context --current --namespace=${namespace}
}

}
