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

DOWNLOAD_URL=https://github.com/kardolus/chatgpt-cli/releases/latest/download/chatgpt-linux-${ARCH}
curl -SsLf "${DOWNLOAD_URL}" |
	install -D /dev/stdin "${HOME}/.local/bin/chatgpt"
