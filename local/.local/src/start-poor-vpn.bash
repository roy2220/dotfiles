#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail # -o xtrace

PROXY_HOST=TODO
PROXY_PORT=TODO
PROXY_AUTH=TODO

tun2socks -loglevel silent -device tun://tun0 -proxy "socks5://${PROXY_AUTH:+${PROXY_AUTH}@}${PROXY_HOST}${PROXY_PORT:+:${PROXY_PORT}}" >/dev/null 2>&1 &
while ! ip link set tun0 up; do
    sleep 1
done
ip addr add 1.2.3.4/32 dev tun0
ip route add 10.42.0.0/16 via 1.2.3.4
ip route add 10.43.0.0/16 via 1.2.3.4
