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

DOWNLOAD_URL=$(curl -SsLf https://api.github.com/repos/xjasonlyu/tun2socks/releases/latest | python3 -c '
import json
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if asset["name"] == "tun2socks-linux-'${ARCH}'.zip":
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
TEMP_FILE=$(mktemp)
curl -SsLf --output "${TEMP_FILE}" "${DOWNLOAD_URL}"
unzip -p "${TEMP_FILE}" | install /dev/stdin "${HOME}/.local/bin/tun2socks"
rm --force "${TEMP_FILE}"
