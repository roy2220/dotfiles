set -o errexit -o nounset -o pipefail # -o xtrace

DOWNLOAD_URL=$(curl --silent --show-error --fail --location https://api.github.com/repos/junegunn/fzf/releases/latest | python3 -c '
import json
import re
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if re.match(r"fzf-[^-]+-linux_amd64\.tar\.gz$", asset["name"]) is not None:
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
TEMP_DIR=$(mktemp --directory)
curl --silent --show-error --fail --location "${DOWNLOAD_URL}" | tar xz --directory "${TEMP_DIR}"
install "${TEMP_DIR}/fzf" fzf
rm --force --recursive "${TEMP_DIR}"
