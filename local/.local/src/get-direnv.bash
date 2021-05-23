set -o errexit -o nounset -o pipefail # -o xtrace

DOWNLOAD_URL=$(curl --silent --show-error --fail --request GET --location https://api.github.com/repos/direnv/direnv/releases/latest | python2 -c '
import json
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if asset["name"] == "direnv.linux-amd64":
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print >> sys.stderr, "download url not found"
    sys.exit(1)
print download_url
')
TEMP_FILE=$(mktemp)
curl --silent --show-error --fail --request GET --location "${DOWNLOAD_URL}" --output "${TEMP_FILE}"
chmod +x "${TEMP_FILE}"
install -D "${TEMP_FILE}" direnv
rm --force "${TEMP_FILE}"
