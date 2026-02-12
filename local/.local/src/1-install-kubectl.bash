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

K8S_VERSION=$(curl --retry 3 -SsLf https://dl.k8s.io/release/stable.txt)
curl --retry 3 -SsLf "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/${ARCH}/kubectl" |
	install -D /dev/stdin "${HOME}/.local/bin/kubectl"
