#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "${HOME}/.config/alacritty"
ln -sfn "${repo_root}/alacritty/alacritty.toml" "${HOME}/.config/alacritty/alacritty.toml"

echo "Alacritty config -> ${HOME}/.config/alacritty/alacritty.toml"
