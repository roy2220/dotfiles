set -eu${DEBUG+x}o pipefail

case $(arch) in
x86_64)
	ARCH=x86_64
	;;
aarch64)
	ARCH=aarch64
	;;
*)
	echo 'unknown architecture' 1>&2
	exit 1
	;;
esac

DOWNLOAD_URL=$(curl -SsLf https://api.github.com/repos/sharkdp/bat/releases/latest | python3 -c '
import json
import re
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if re.match(r"bat-[^-]+-'${ARCH}'-unknown-linux-gnu\.tar\.gz$", asset["name"]) is not None:
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
TEMP_DIR=$(mktemp --directory)
curl -SsLf "${DOWNLOAD_URL}" | tar xz --directory "${TEMP_DIR}"
install "${TEMP_DIR}/bat-"*"-${ARCH}-unknown-linux-gnu/bat" "${HOME}/.local/bin/bat"
rm --force --recursive "${TEMP_DIR}"
