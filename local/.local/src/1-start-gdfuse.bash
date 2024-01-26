set -eu${DEBUG+x}o pipefail

export HTTPS_PROXY=socks5h://host.docker.internal:7891
mkdir --parents /gdrive
exec google-drive-ocamlfuse -serviceaccountpath "${HOME}/.secrets/gdfuse/service_account.json" /gdrive
