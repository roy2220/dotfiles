set -o errexit -o nounset -o pipefail # -o xtrace

DOWNLOAD_URL=$(curl --silent --show-error --fail --request GET --location https://api.github.com/repos/sharkdp/bat/releases/latest | python2 -c '
import json
import re
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if re.match(r"bat-[^-]+-x86_64-unknown-linux-gnu\.tar\.gz$", asset["name"]) is not None:
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print >> sys.stderr, "download url not found"
    sys.exit(1)
print download_url
')
TEMP_DIR=$(mktemp --directory)
curl --silent --show-error --fail --request GET --location "${DOWNLOAD_URL}" | tar xz --directory "${TEMP_DIR}"
install -D "${TEMP_DIR}/bat-"*'-x86_64-unknown-linux-gnu/bat' bat
rm --force --recursive "${TEMP_DIR}"
