set -euo pipefail

if [[ ! -f /etc/dropbear/dropbear_ed25519_host_key ]]; then
	mkdir --parents /etc/dropbear
	dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key
fi

PORT=22$(printf '%02d' "${HOSTNAME##*-}")
nohup dropbear -F -E -p "127.0.0.1:${PORT}" -B >/tmp/dropbear.log 2>&1 &
