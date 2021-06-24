set -o errexit -o nounset -o pipefail # -o xtrace

DOWNLOAD_URL=$(curl --silent --show-error --fail --location https://api.github.com/repos/direnv/direnv/releases/latest | python3 -c '
import json
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if asset["name"] == "direnv.linux-amd64":
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
TEMP_FILE=$(mktemp)
curl --silent --show-error --fail --location --output "${TEMP_FILE}" "${DOWNLOAD_URL}"
chmod +x "${TEMP_FILE}"
install "${TEMP_FILE}" direnv
rm --force "${TEMP_FILE}"
