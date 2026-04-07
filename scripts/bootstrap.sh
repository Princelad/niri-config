#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "${HOME}/.config/alacritty"

# Make plain `alacritty` always use this repo's config.
ln -sfn "${repo_root}/alacritty/alacritty.toml" "${HOME}/.config/alacritty/alacritty.toml"

echo "Bootstrap complete."
echo "Alacritty config -> ${HOME}/.config/alacritty/alacritty.toml"
