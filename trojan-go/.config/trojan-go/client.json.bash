set -u
DIR=$(dirname "$(realpath "${0}")")
cat <<EOF
{
  "run_type": "client",
  "log_level": 1,
  "local_addr": "127.0.0.1",
  "local_port": 1080,
  "remote_addr": "${REMOTE_ADDR}",
  "remote_port": ${REMOTE_PORT},
  "password": ["${PASSWORD}"],
  "ssl": {
    "cert": "${DIR}/whosyourdaddy.cn.pem",
    "sni": "whosyourdaddy.cn"
  },
  "mux": {
    "enabled": true
  }
}
EOF
