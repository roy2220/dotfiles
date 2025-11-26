set -eu${DEBUG+x}o pipefail

case $(arch) in
x86_64)
	ARCH=amd64
	;;
aarch64)
	ARCH=arm64
	;;
*)
	echo 'unknown architecture' 1>&2
	exit 1
	;;
esac

DOWNLOAD_URL=$(curl -SsLf 'https://help.aliyun.com/zh/oss/developer-reference/install-ossutil' | grep --perl-regexp --only-matching "https://gosspublic.alicdn.com/ossutil/[^/]+/ossutil-v[^-]+-linux-${ARCH}.zip" | head -1)
TEMP_FILE=$(mktemp)
curl -SsLf --output "${TEMP_FILE}" "${DOWNLOAD_URL}"
unzip -p "${TEMP_FILE}" "$(basename "${DOWNLOAD_URL}" .zip)/ossutil" | install /dev/stdin "${HOME}/.local/bin/_ossutil"
rm --force "${TEMP_FILE}"

install /dev/stdin "${HOME}/.local/bin/ossutil" <<'EOF'
#!/usr/bin/env bash
exec "$(dirname "$0")/_ossutil" ${OSSUTIL_CONFIG_FILE:+--config-file="${OSSUTIL_CONFIG_FILE}"} "${@}"
EOF
