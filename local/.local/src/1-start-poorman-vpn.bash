exit 0

set -eu${DEBUG+x}o pipefail

REMOTE_ADDR=TODO \
	REMOTE_PORT=TODO \
	PASSWORD=TODO \
	bash "${HOME}/.config/trojan-go/client.json.bash" |
	trojan-go -stdin-format=json >/tmp/trojan-go.log 2>&1 &

tun2socks -loglevel info -device tun://tun0 -proxy 'socks5://127.0.0.1:1080' >/tmp/tun2socks.log 2>&1 &

for N in {1..3}; do
	if [[ ${N} -ge 2 ]]; then
		sleep 1
	fi
	if ! ip link set tun0 up; then
		continue
	fi
	ip addr add 10.10.10.10/32 dev tun0
	ip route add 10.42.0.0/16 via 10.10.10.10
	ip route add 10.43.0.0/16 via 10.10.10.10
	ip route add 10.0.0.0/24 via 10.10.10.10
	#	SHELL=${BASH} socat tcp-listen:80,fork,reuseaddr system:"$(
	#		cat <<'EOF'
	#NODE=$(shuf --echo --head-count=1 10.0.0.101 10.0.0.102)
	#exec nc "${NODE}" 80
	#EOF
	#	)" >/dev/null 2>&1 &
	break
done
