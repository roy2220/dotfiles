set -eu${DEBUG+x}o pipefail

TEMP_DIR=$(mktemp --directory)
git clone --depth=1 https://github.com/rfjakob/gocryptfs.git "${TEMP_DIR}"
pushd "${TEMP_DIR}"
PATH=${PATH}:/usr/local/go/bin ./build-without-openssl.bash
popd
rm --force --recursive "${TEMP_DIR}"
