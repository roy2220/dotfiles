#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail # -o xtrace

(
	cd ~/.config/trojan-go
	trojan-go -config client.json >/dev/null 2>&1 &
)
tun2socks -loglevel silent -device tun://tun0 -proxy 'socks5://127.0.0.1:1080' >/dev/null 2>&1 &
for N in {1..3}; do
	if [[ ${N} -ge 2 ]]; then
		sleep 1
	fi
	if ip link set tun0 up; then
		ip addr add 1.2.3.4/32 dev tun0
		ip route add 10.42.0.0/16 via 1.2.3.4
		ip route add 10.43.0.0/16 via 1.2.3.4
		# ip route add x.x.x.0/24 via 1.2.3.4
		# socat tcp-listen:80,fork,reuseaddr tcp4-connect:10.43.x.x:80 >/dev/null 2>&1 &
		# socat tcp-listen:443,fork,reuseaddr tcp4-connect:10.43.x.x:443 >/dev/null 2>&1 &
		break
	fi
done
