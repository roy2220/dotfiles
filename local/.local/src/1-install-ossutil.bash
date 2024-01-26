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

DOWNLOAD_URL=$(curl -SsLf https://api.github.com/repos/aliyun/ossutil/releases/latest | python3 -c '
import json
import re
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if re.match(r"ossutil-[^-]+-linux-'${ARCH}'\.zip$", asset["name"]) is not None:
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
TEMP_FILE=$(mktemp)
curl -SsLf --output "${TEMP_FILE}" "${DOWNLOAD_URL}"
unzip -p "${TEMP_FILE}" "$(basename "${DOWNLOAD_URL}" .zip)/ossutil" | install /dev/stdin "${HOME}/.local/bin/_ossutil"
rm --force "${TEMP_FILE}"

install /dev/stdin "${HOME}/.local/bin/ossutil" <<'EOF'
#!/usr/bin/env bash
exec "$(dirname "$0")/_ossutil" ${OSSUTIL_CONFIG_FILE:+--config-file="${OSSUTIL_CONFIG_FILE}"} "${@}"
EOF
