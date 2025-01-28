set -eu${DEBUG+x}o pipefail

TEMP_DIR=$(mktemp --directory)
git clone --depth=1 https://github.com/roy2220/paleta.git "${TEMP_DIR}"
make --directory="${TEMP_DIR}"
cp --target-directory="${HOME}/.local/bin" "${TEMP_DIR}/paleta"
cp --recursive --target-directory="${HOME}/.local/share" "${TEMP_DIR}/palettes"
sed --regexp-extended --in-place '12s/^.+$/657b83/' "${HOME}/.local/share/palettes/solarized-dark"
rm --force --recursive "${TEMP_DIR}"
