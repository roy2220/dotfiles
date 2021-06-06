#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail # -o xtrace

PROXY_HOST=TODO
PROXY_PORT=TODO
PROXY_AUTH=TODO

tun2socks -loglevel silent -device tun://tun0 -proxy "socks5://${PROXY_AUTH:+${PROXY_AUTH}@}${PROXY_HOST}${PROXY_PORT:+:${PROXY_PORT}}" >/dev/null 2>&1 &
for N in {1..3}; do
	if [[ ${N} -ge 2 ]]; then
		sleep 1
	fi
	if ip link set tun0 up; then
		break
	fi
done
ip addr add 1.2.3.4/32 dev tun0
# ip route add 10.0.0.0/24 via 1.2.3.4
# socat tcp-listen:80,fork,reuseport tcp4-connect:10.0.0.101:80 >/dev/null 2>&1 &
# socat tcp-listen:80,fork,reuseport tcp4-connect:10.0.0.102:80 >/dev/null 2>&1 &
# socat tcp-listen:443,fork,reuseport tcp4-connect:10.0.0.101:443 >/dev/null 2>&1 &
# socat tcp-listen:443,fork,reuseport tcp4-connect:10.0.0.102:443 >/dev/null 2>&1 &
