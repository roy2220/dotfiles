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
VERSION=$(curl -SsLf https://downloads.rclone.org/version.txt)
VERSION=$(grep --perl-regexp --only-matching 'v\d+\.\d+\.\d+' <<<"${VERSION}")
unzip -p "${TEMP_FILE}" "rclone-${VERSION}-linux-${ARCH}/rclone" | install /dev/stdin "${HOME}/.local/bin/rclone"
rm --force "${TEMP_FILE}"
