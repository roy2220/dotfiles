set -u
DIR=$(dirname "$(realpath "${0}")")
cat <<EOF
{
  "run_type": "server",
  "log_level": 1,
  "local_addr": "127.0.0.1",
  "local_port": ${LOCAL_PORT},
  "remote_addr": "www.gov.cn",
  "remote_port": 80,
  "password": ["${PASSWORD}"],
  "ssl": {
    "cert": "${DIR}/whosyourdaddy.cn.pem",
    "key": "${DIR}/whosyourdaddy.cn-key.pem",
    "sni": "whosyourdaddy.cn"
  }
}
EOF
