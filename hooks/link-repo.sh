#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${HOME}/.config/niri"

mkdir -p "${HOME}/.config"

# Symlink the repository as the niri config dir
ln -sfn "${repo_root}" "${config_dir}"

echo "Repository linked -> ${config_dir}"
