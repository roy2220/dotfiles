set -eu${DEBUG+x}o pipefail

DOWNLOAD_URL=$(curl -SsLf https://api.github.com/repos/universal-ctags/ctags/tags | python3 -c '
import json
import re
import sys

tags = json.loads(sys.stdin.read())
download_url = None
for tag in tags:
    if tag["name"].startswith("p"):
        download_url = tag["tarball_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')
CACHE_FILE=/gdrive/build-cache/f$(grep --perl-regexp --only-matching '(?<=Fedora release )\d+' /etc/fedora-release).$(arch)/universal-ctags-$(grep --perl-regexp --only-matching '[^/]+$' <<<"${DOWNLOAD_URL}").tar.gz
if [[ -f ${CACHE_FILE} ]]; then
	download() { cat "${CACHE_FILE}"; }
	USE_CACHE=1
else
	download() { curl -SsLf "${DOWNLOAD_URL}"; }
	USE_CACHE=0
fi
TEMP_DIR=$(mktemp --directory)
download | tar xz --directory "${TEMP_DIR}"
cd "${TEMP_DIR}/universal-ctags-"*
[[ ${USE_CACHE} -eq 0 ]] && ./autogen.sh && ./configure
make --silent && make install
cd -
if [[ ${USE_CACHE} -eq 0 ]]; then
	mkdir --parents "$(dirname "${CACHE_FILE}")"
	tar czf "${CACHE_FILE}.tmp" -C "${TEMP_DIR}" .
	mv "${CACHE_FILE}.tmp" "${CACHE_FILE}"
fi
rm --force --recursive "${TEMP_DIR}"
