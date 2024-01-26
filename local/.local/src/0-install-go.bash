set -eu${DEBUG+x}o pipefail

case $(arch) in
x86_64)
	ARCH=amd64
	;;
aarch64)
	ARCH=arm64
	;;
*)
	echo 'unknown architecture' 1>&2
	exit 1
	;;
esac

curl -SsLf "https://dl.google.com/go/go1.20.linux-${ARCH}.tar.gz" |
	tar xz --directory /usr/local

mkdir --parents "${HOME}/sdk"
ln --symbolic --no-target-directory /usr/local/go "${HOME}/sdk/$(/usr/local/go/bin/go env GOVERSION)"
/usr/local/go/bin/go install golang.org/dl/go1.19@latest
"${HOME}/go/bin/go1.19" download
rm "${HOME}/go/bin/go1.19"
rm "${HOME}/sdk/go1.19/go"*'.tar.gz'
/usr/local/go/bin/go install golang.org/dl/go1.17@latest
"${HOME}/go/bin/go1.17" download
rm "${HOME}/go/bin/go1.17"
rm "${HOME}/sdk/go1.17/go"*'.tar.gz'

install /dev/stdin "${HOME}/go/bin/go" <<'EOF'
#!/usr/bin/env sh
if [ -z "${GOVERSION}" ]; then
    exec /usr/local/go/bin/go "${@}"
else
    exec "${HOME}/sdk/${GOVERSION}/bin/go" "${@}"
fi
EOF

install /dev/stdin "${HOME}/go/bin/gofmt" <<'EOF'
#!/usr/bin/env sh
if [ -z "${GOVERSION}" ]; then
    exec /usr/local/go/bin/gofmt "${@}"
else
    exec "${HOME}/sdk/${GOVERSION}/bin/gofmt" "${@}"
fi
EOF
