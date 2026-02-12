set -eu${DEBUG+x}o pipefail

case $(arch) in
x86_64)
	ARCH=x86_64
	;;
aarch64)
	ARCH=aarch64
	;;
*)
	echo 'unknown architecture' 1>&2
	exit 1
	;;
esac

DOWNLOAD_URL=$(curl --retry 3 -SsLf https://api.github.com/repos/dandavison/delta/releases/latest | python3 -c '
import json
import re
import sys

release = json.loads(sys.stdin.read())
download_url = None
for asset in release["assets"]:
    if re.match(r"delta-[^-]+-'${ARCH}'-unknown-linux-gnu\.tar\.gz$", asset["name"]) is not None:
        download_url = asset["browser_download_url"]
        break
if download_url is None:
    print("download url not found", file=sys.stderr)
    sys.exit(1)
print(download_url)
')

curl --retry 3 -SsLf "${DOWNLOAD_URL}" |
	tar xz --wildcards "delta-*-${ARCH}-unknown-linux-gnu/delta" --to-stdout |
	install -D /dev/stdin "${HOME}/.local/bin/delta"
