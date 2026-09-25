set -euo pipefail

crontab - >/dev/null <<'EOF'
30 * * * * mkdir -p "/oss/${HOSTNAME}" && gzip --stdout "${HISTFILE}" > "/oss/${HOSTNAME}/zsh_history.$(date +\%H).gz"
EOF

nohup crond -n >/tmp/crond.log 2>&1 &
