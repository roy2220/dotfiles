set -eu${DEBUG+x}o pipefail

mkdir --parents /gdrive
rclone mount --daemon gdrive: /gdrive

mkdir --parents /oss
rclone mount --daemon oss:/oyy1993 /oss
