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

TEMP_FILE=$(mktemp)
curl -SsLf --output "${TEMP_FILE}" "https://downloads.rclone.org/rclone-current-linux-${ARCH}.zip"
unzip -p "${TEMP_FILE}" "rclone-*-linux-${ARCH}/rclone" |
	install -D /dev/stdin "${HOME}/.local/bin/_rclone"
rm --force "${TEMP_FILE}"

install -D /dev/stdin "${HOME}/.local/bin/rclone" <<'EOF'
#!/usr/bin/env bash

exec "$(dirname "$0")/_rclone" ${RCLONE_CONFIG_FILE:+--config="${RCLONE_CONFIG_FILE}"} "${@}"
EOF
