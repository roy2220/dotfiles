#!/usr/bin/env bash

set -eu${DEBUG+x}o pipefail

MODULE=$(go list -m)
{
	go list "${MODULE}/..." | xargs -- printf '"%s"\n'
	go fmt -n "${MODULE}/..." |
		cut --delimiter=' ' -f4- |
		tr ' ' '\n' |
		xargs -- sed --silent --regexp-extended --null-data 's/.*\nimport ("[^"]+"|\([^\)]+\)).*/\1/p' |
		tr '\0' '\n' |
		sed --regexp-extended --expression='/^(|\(|\)|[[:space:]]+)$/d' --expression='s/^[[:space:]]+(.+)$/\1/'
} | sort --unique
