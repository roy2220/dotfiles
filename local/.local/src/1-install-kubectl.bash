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

K8S_VERSION=$(curl -SsLf https://dl.k8s.io/release/stable.txt)
TEMP_FILE=$(mktemp)
curl -SsLf --output "${TEMP_FILE}" "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/${ARCH}/kubectl"
install "${TEMP_FILE}" "${HOME}/.local/bin/kubectl"
rm --force "${TEMP_FILE}"
