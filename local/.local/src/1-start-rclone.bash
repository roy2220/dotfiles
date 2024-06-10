set -eu${DEBUG+x}o pipefail

mkdir --parents /gdrive
rclone mount --daemon gdrive: /gdrive

mkdir --parents /s3
rclone mount --daemon s3:/oyy1993 /s3
