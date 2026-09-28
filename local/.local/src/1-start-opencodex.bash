set -euo pipefail

PORT=101$(printf '%02d' "${HOSTNAME##*-}")
OPENCODEX_HOME=$(realpath ~/.config/opencodex) nohup ocx start --port "${PORT}" >/tmp/opencodex.log 2>&1 &
