set -eu${DEBUG+x}o pipefail

mkdir --parents /gdrive
rclone mount --daemon gdrive: /gdrive
# mkdir --parents /gdrive.shared-with-me
# rclone mount --daemon --drive-shared-with-me gdrive: /gdrive.shared-with-me
# mkdir --parents /gdrive.trashed
# rclone mount --daemon --drive-trashed-only gdrive: /gdrive.trashed

mkdir --parents /oss
rclone mount --daemon oss:/oyy1993 /oss
