set -o errexit -o nounset -o pipefail # -o xtrace

DOWNLOAD_URL=$(curl --silent --show-error --fail --request GET --location 'https://api.github.com/repos/helm/helm/tags' | python2 -c '
import json
import re
import sys

tags = json.loads(sys.stdin.read())
download_url = None
for tag in tags:
    if re.match(r"v\d+\.\d+\.\d+$", tag["name"]) is not None:
        download_url = "https://get.helm.sh/helm-{}-linux-amd64.tar.gz".format(tag["name"])
        break
if download_url is None:
    print >> sys.stderr, "download url not found"
    sys.exit(1)
print download_url
')
TEMP_DIR=$(mktemp --directory)
curl --silent --show-error --fail --request GET --location "${DOWNLOAD_URL}" | tar xz --directory "${TEMP_DIR}"
install -D "${TEMP_DIR}/linux-amd64/helm" helm
rm --force --recursive "${TEMP_DIR}"
