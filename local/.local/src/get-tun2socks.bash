set -o errexit -o nounset -o pipefail # -o xtrace

DOWNLOAD_URL=$(curl --silent --show-error --fail --request GET --location https://api.github.com/repos/xjasonlyu/tun2socks/releases/latest | python3 -c '
import json
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if asset["name"] == "tun2socks-linux-amd64.zip":
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
TEMP_FILE=$(mktemp)
curl --silent --show-error --fail --request GET --location "${DOWNLOAD_URL}" --output "${TEMP_FILE}"
unzip -p "${TEMP_FILE}" | install /dev/stdin tun2socks
rm --force "${TEMP_FILE}"
