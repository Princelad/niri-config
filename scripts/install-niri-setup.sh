#!/usr/bin/env bash
set -euo pipefail

# Install packages required for niri setup
# This script uses yay as the AUR helper; install it first if needed

PACKAGES=(
    # Core window manager and display server
    "niri"
    "xwayland-satellite"
    
    # Terminal and launchers
    "alacritty"
    "fuzzel"
    
    # Status bar and notifications
    "waybar"
    "mako"
    
    # Wallpaper and background
    "swaybg"
    "python-pywal16"
    
    # Idle and lock management
    "swayidle"
    "swaylock-effects"
    
    # Clipboard management
    "wl-clipboard"
    "cliphist"
    
    # File manager
    "thunar"
    
    # Media and brightness control
    "playerctl"
    "brightnessctl"
    
    # TUI applications
    "bluetui"
    "wiremix"
    
    # Portal and session management
    "xdg-desktop-portal"
    "xdg-desktop-portal-gtk"
    
    # Audio server stack
    "pipewire"
    "pipewire-alsa"
    "pipewire-pulse"
    "wireplumber"
    
    # Optional but commonly used with this setup
    "firefox"
    "spotify"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Niri Setup Package Installer${NC}"
echo "======================================"
echo "This script will install ${#PACKAGES[@]} packages."
echo ""

# Check if yay is installed
if ! command -v yay >/dev/null 2>&1; then
    echo -e "${RED}Error: yay is not installed.${NC}"
    echo "Please install yay first: https://github.com/Jguer/yay"
    exit 1
fi

# Display packages to be installed
echo -e "${YELLOW}Packages to install:${NC}"
for pkg in "${PACKAGES[@]}"; do
    echo "  • $pkg"
done
echo ""

read -p "Continue with installation? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Starting installation...${NC}"
echo ""

# Install packages
if yay -S --noconfirm "${PACKAGES[@]}"; then
    echo ""
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Ensure pywal is run to generate colors: wal -i <image> or wal -a"
    echo "2. Restart niri or source your config for all changes to take effect"
    echo "3. Verify all services are running with: systemctl --user status"
else
    echo -e "${RED}Installation failed!${NC}"
    exit 1
fi
