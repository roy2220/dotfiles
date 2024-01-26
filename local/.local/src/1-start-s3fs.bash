set -eu${DEBUG+x}o pipefail

mkdir --parents /s3
source "${HOME}/.secrets/s3fs/config"
exec s3fs "${BUCKET}" /s3 -o passwd_file=/dev/stdin "${OPTIONS[@]}" <<<"${ACCESS_KEY_ID}:${SECRET_ACCESS_KEY}"
