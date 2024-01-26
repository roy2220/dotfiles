set -eu${DEBUG+x}o pipefail

case $(arch) in
x86_64)
	ARCH=amd64
	;;
aarch64)
	ARCH=armv8
	;;
*)
	echo 'unknown architecture' 1>&2
	exit 1
	;;
esac

DOWNLOAD_URL=$(curl -SsLf https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest | python3 -c '
import json
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if asset["name"] == "trojan-go-linux-'${ARCH}'.zip":
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
TEMP_FILE=$(mktemp)
curl -SsLf --output "${TEMP_FILE}" "${DOWNLOAD_URL}"
unzip -p "${TEMP_FILE}" trojan-go | install /dev/stdin "${HOME}/.local/bin/trojan-go"
rm --force "${TEMP_FILE}"
