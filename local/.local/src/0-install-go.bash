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

ALL_VERSIONS=$(curl -SsLf https://go.dev/doc/devel/release | grep --perl-regexp --only-matching '(?<=id="go)\d+\.\d+\.\d+(?=")')
VERSION_1=$(grep '^1\.25\.' <<<"${ALL_VERSIONS}" | tail -1)
VERSION_2=$(grep '^1\.24\.' <<<"${ALL_VERSIONS}" | tail -1)
VERSION_3=$(grep '^1\.23\.' <<<"${ALL_VERSIONS}" | tail -1)

curl -SsLf "https://dl.google.com/go/go${VERSION_1}.linux-${ARCH}.tar.gz" |
	tar xz --directory /usr/local

mkdir --parents "${HOME}/sdk"
ln --symbolic --no-target-directory /usr/local/go "${HOME}/sdk/go${VERSION_1}"
ln --symbolic --no-target-directory /usr/local/go "${HOME}/sdk/go$(cut --delimiter=. --fields=1,2 <<<"${VERSION_1}")"

CGO_ENABLED=0 /usr/local/go/bin/go install "golang.org/dl/go${VERSION_2}@latest"
"${HOME}/go/bin/go${VERSION_2}" download
rm "${HOME}/go/bin/go${VERSION_2}"
rm "${HOME}/sdk/go${VERSION_2}/go"*'.tar.gz'
ln --symbolic --no-target-directory "${HOME}/sdk/go${VERSION_2}" "${HOME}/sdk/go$(cut --delimiter=. --fields=1,2 <<<"${VERSION_2}")"

CGO_ENABLED=0 /usr/local/go/bin/go install "golang.org/dl/go${VERSION_3}@latest"
"${HOME}/go/bin/go${VERSION_3}" download
rm "${HOME}/go/bin/go${VERSION_3}"
rm "${HOME}/sdk/go${VERSION_3}/go"*'.tar.gz'
ln --symbolic --no-target-directory "${HOME}/sdk/go${VERSION_3}" "${HOME}/sdk/go$(cut --delimiter=. --fields=1,2 <<<"${VERSION_3}")"

install /dev/stdin "${HOME}/go/bin/go" <<'EOF'
#!/usr/bin/env sh

if [ -n "${GO_HTTP_PROXY}" ]; then
	export http_proxy=${GO_HTTP_PROXY}
fi
if [ -n "${GO_HTTPS_PROXY}" ]; then
	export https_proxy=${GO_HTTPS_PROXY}
fi
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
