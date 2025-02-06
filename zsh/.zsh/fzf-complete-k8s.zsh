() {

_fzf-complete-k8s() {
    local lbuffer resource
    local resource_kind pod_of_containers workload_of_containers query

    eval $(sed --regexp-extended --silent 's|^.* ([^ /]+)( +\|/)([^ /]*)$|\1\n\3|p' <<<${LBUFFER} |
        xargs --no-run-if-empty -- printf 'resource_kind=%q query=%q')
    if [[ ! -z ${resource_kind} && ${resource_kind} != -* ]]; then
        lbuffer=${LBUFFER[0,-${#query}-1]}
        resource=$(kubectl get ${resource_kind} --output=custom-columns=':.metadata.name' --no-headers |
            fzf-popup --prompt="K8s:${resource_kind}... " --bind="load:change-prompt:K8s:${resource_kind}> " --query=${query})
    else
        eval $(sed --regexp-extended --silent 's|^.* pod[s]?( +\|/)([^ /]+) +-c +([^ /]*)$|\2\n\3|p' <<<${LBUFFER} |
            xargs --no-run-if-empty -- printf 'pod_of_containers=%q query=%q')
        if [[ ! -z ${pod_of_containers} && ${pod_of_containers} != -* ]]; then
            lbuffer=${LBUFFER[0,-${#query}-1]}
            resource=$(kubectl get pod/${pod_of_containers} --output=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' |
                fzf-popup --prompt='K8s:container... ' --bind='load:change-prompt:K8s:container> ' --query=${query})
        else
            eval $(sed --regexp-extended --silent 's|^.* ((deployment[s]?\|deploy\|statefulset[s]?\|sts\|daemonset[s]?\|ds\|cronjob[s]?\|cj\|job[s]?)( +\|/)[^ /]+) +-c +([^ /]*)$|\1\n\4|p' <<<${LBUFFER} |
                xargs --no-run-if-empty -- printf 'workload_of_containers=%q query=%q')
            if [[ ! -z ${workload_of_containers} && ${workload_of_containers} != -* ]]; then
                lbuffer=${LBUFFER[0,-${#query}-1]}
                resource=$(kubectl get ${workload_of_containers} --output=jsonpath='{range .spec.template.spec.containers[*]}{.name}{"\n"}{end}' |
                        fzf-popup --prompt='K8s:container... ' --bind='load:change-prompt:K8s:container> ' --query=${query})
            fi
        fi
    fi
    zle reset-prompt
    if [[ -z ${resource} ]]; then
        return
    fi
    LBUFFER=${lbuffer}${resource}
}

zle -N _fzf-complete-k8s
bindkey '\e_#KB#A-K\a' _fzf-complete-k8s

Kcn() {
    local current_namespace=$(kubectl config get-contexts | grep --max-count=1 --perl-regexp '^\*' | awk '{ print $5 == "" ? "default" : $5 }')
    local namespace=$(kubectl get namespace --output=custom-columns=':.metadata.name' --no-headers |
        grep --invert-match --fixed-strings ${current_namespace} |
        fzf-popup --prompt="K8s:namespace(${current_namespace})... " --bind="load:change-prompt:K8s:namespace(${current_namespace})> ")
    if [[ -z ${namespace} ]]; then
        return
    fi
    kubectl config set-context --current --namespace=${namespace}
}

}
