#!/usr/bin/env bash
set -euo pipefail

# Packages commonly used by the niri config. Adjust as needed.
PACKAGES=(
    niri
    xwayland-satellite
    alacritty
    fuzzel
    waybar
    mako
    swaybg
    python-pywal16
    swayidle
    swaylock-effects
    wl-clipboard
    cliphist
    thunar
    playerctl
    brightnessctl
    bluetui
    wiremix
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    pipewire
    pipewire-alsa
    pipewire-pulse
    wireplumber
    firefox
    spotify
    wlctl-bin
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Niri Setup Package Installer (hook)${NC}"
ensure_yay() {
    if command -v yay >/dev/null 2>&1; then
        echo "yay already installed."
        return 0
    fi

    echo -e "${YELLOW}yay not found. Attempting to install yay (AUR helper).${NC}"

    # Building AUR packages requires a non-root user. Handle common cases.
    if [[ ${EUID:-0} -eq 0 ]]; then
        if [[ -n "${SUDO_USER:-}" ]]; then
            user="$SUDO_USER"
            echo "Running yay installation as ${user} (invoked via sudo/root)."
            runuser -l "${user}" -c 'set -euo pipefail; sudo pacman -S --needed --noconfirm base-devel git || true; cd /tmp; rm -rf yay; git clone https://aur.archlinux.org/yay.git; cd yay; makepkg -si --noconfirm'
            return $?
        else
            echo -e "${RED}Cannot install yay as root. Please run this script as a regular user to install yay.${NC}"
            return 1
        fi
    else
        # Non-root user: ensure base-devel and git are present, then build yay
        if ! pacman -Qq base-devel >/dev/null 2>&1; then
            echo "Installing base-devel and git via pacman (requires sudo)..."
            if command -v sudo >/dev/null 2>&1; then
                sudo pacman -S --needed --noconfirm base-devel git || true
            else
                pacman -S --needed --noconfirm base-devel git || true
            fi
        fi

        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "${tmpdir}/yay"
        (cd "${tmpdir}/yay" && makepkg -si --noconfirm)
        rc=$?
        rm -rf "${tmpdir}"
        return ${rc}
    fi
}

# Try to ensure yay is available; if it succeeds, use yay, otherwise fall back to pacman
if ensure_yay >/dev/null 2>&1; then
    echo "Using yay to install packages..."
    if yay -S --noconfirm "${PACKAGES[@]}"; then
        echo -e "${GREEN}All packages installed via yay.${NC}"
        exit 0
    else
        echo -e "${RED}yay failed to install some packages.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Falling back to pacman for available packages.${NC}"
    if pacman -S --needed --noconfirm "${PACKAGES[@]}"; then
        echo -e "${GREEN}Official packages installed via pacman.${NC}"
        echo -e "${YELLOW}If some packages are AUR-only, install 'yay' and re-run this hook to get them.${NC}"
        exit 0
    else
        echo -e "${RED}pacman failed to install some packages. Install missing packages manually or install 'yay' for AUR packages.${NC}"
        exit 1
    fi
fi
