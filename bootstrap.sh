#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
packages_file="$root/system/packages.apt"

usage() {
  cat <<'USAGE'
Usage:
  ./bootstrap.sh --check
  ./bootstrap.sh --install

Installs the base Ubuntu packages used by these dotfiles. The default mode is
--check so reading or running the script without intent does not change the
machine.
USAGE
}

mode="${1:---check}"
case "$mode" in
  --check|--install) ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot detect OS: /etc/os-release is missing" >&2
  exit 1
fi

# shellcheck source=/dev/null
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" && "${ID_LIKE:-}" != *"debian"* ]]; then
  echo "This bootstrap currently supports Ubuntu/Debian-like systems only." >&2
  exit 1
fi

mapfile -t packages < <(sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$packages_file")

if [[ "$mode" == "--check" ]]; then
  echo "Packages that would be installed:"
  printf '  %s\n' "${packages[@]}"
  echo
  echo "Run ./bootstrap.sh --install to install them."
  exit 0
fi

sudo apt-get update
sudo apt-get install -y "${packages[@]}"

if ! command -v mise >/dev/null 2>&1; then
  cat <<'NOTE'

mise is not installed by Ubuntu apt. Install it separately if you want one
tool-version manager for Node, Go, Rust, Python, and project tasks:
  https://mise.jdx.dev/
NOTE
fi
