set -eu${DEBUG+x}o pipefail

crontab - <<'EOF'
30 * * * * gzip --stdout "${HISTFILE}" > "/s3/${HOSTNAME}/.zsh_history.gz"
EOF

crond
