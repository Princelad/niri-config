#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hooks_dir="${repo_root}/hooks"

echo "This installer will run hooks in ${hooks_dir}."

if [[ ! -d "${hooks_dir}" ]]; then
    echo "Error: hooks directory not found at ${hooks_dir}" >&2
    exit 1
fi

read -p "Install packages now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    bash "${hooks_dir}/install-packages.sh"
else
    echo "Skipping package installation."
fi

read -p "Link repository into ~/.config and alacritty config? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    bash "${hooks_dir}/link-repo.sh"
    bash "${hooks_dir}/link-alacritty.sh"
else
    echo "Skipping linking hooks."
fi

echo "Done."
echo "Next steps:"
echo "- Make sure ${HOME}/.cache/wal contains a colors file (run 'wal -i /path/to/image')"
echo "- Enable and start user services as needed (systemctl --user)"
