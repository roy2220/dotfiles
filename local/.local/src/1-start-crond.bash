set -eu${DEBUG+x}o pipefail

crontab - <<'EOF'
30 * * * * mkdir -p "/oss/${HOSTNAME}" && gzip --stdout "${HISTFILE}" > "/oss/${HOSTNAME}/zsh_history.$(date +\%H).gz"
EOF

crond
