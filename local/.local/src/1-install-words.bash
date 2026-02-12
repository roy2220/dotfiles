set -eu${DEBUG+x}o pipefail

DOWNLOAD_URL=$(curl --retry 3 -SsLf https://api.github.com/repos/roy2220/words/releases/latest | python3 -c '
import json
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if asset["name"] == "words.txt.gz":
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')

curl --retry 3 -SsLf "${DOWNLOAD_URL}" |
	gzip --decompress |
	install -D -m 644 /dev/stdin "${HOME}/.local/share/words/words.txt"

sed 's/./\U&/' "${HOME}/.local/share/words/words.txt" >"${HOME}/.local/share/words/Words.txt"
