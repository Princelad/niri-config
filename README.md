# Niri Configuration

Personal Niri desktop configuration with modular KDL files, Waybar, Mako, Fuzzel, Alacritty, and pywal-driven theming.

## Overview

- Modular Niri setup with focused files for input, layout, binds, startup, and rules.
- i3-style Super-key ergonomics for common workflows.
- Wallpaper-driven colors through pywal, shared across Niri, Waybar, terminal, launcher, and notifications.
- Utility scripts for launcher, clipboard history, session actions, power profiles, and wallpaper selection.

## Workspace Layout

- Main entry:
  - config.kdl
- Niri modules:
  - general.kdl
  - input.kdl
  - output.kdl
  - layout.kdl
  - animations.kdl
  - windowRules.kdl
  - binds.kdl
  - startup.kdl
- App configs:
  - waybar/config.jsonc
  - waybar/style.css
  - alacritty/alacritty.toml
  - fuzzel/fuzzel.ini
  - mako/config
- Scripts:
  - scripts/launcher.sh
  - scripts/clipboard-menu.sh
  - scripts/lock-screen.sh
  - scripts/session-menu.sh
  - scripts/power-profile-menu.sh
  - scripts/wallpaper-selector.sh

## Requirements

- niri
- waybar
- mako
- swaybg
- fuzzel
- alacritty
- pywal (wal)
- cliphist
- wl-clipboard
- swaylock
- thunar
- playerctl
- brightnessctl
- powerprofilesctl
- swaylock
- Optional but referenced by binds:
  - firefox
  - spotify
  - bluetui
  - wlctl
  - wiremix

## Quick Start

1. Clone or copy this directory to ~/.config/niri.
2. Ensure dependencies above are installed.
3. Run bootstrap to pin default app config links (including Alacritty):
  - bash scripts/bootstrap.sh
4. Generate initial pywal files if missing:
   - wal -i /path/to/wallpaper.jpg
5. Start or reload Niri using your normal session workflow.

## Common Commands

- Validate shell scripts:
  - bash -n scripts/*.sh
- Inspect detected outputs:
  - niri msg outputs
- Test Waybar config and style manually:
  - waybar -c waybar/config.jsonc -s waybar/style.css
- Apply a new wallpaper and regenerate theme:
  - scripts/wallpaper-selector.sh

## Keybinding Notes

Core ergonomic bindings are intentionally i3-like:

- Super+Return opens terminal
- Super+P opens launcher
- Super+V opens clipboard history menu
- Super+Shift+Q closes window
- Super+1 through Super+0 focuses workspaces 1 through 10

See binds.kdl for the complete binding list.

## Script Conventions

Scripts in scripts/ follow:

- Bash shebang with env lookup
- Strict mode with set -euo pipefail
- Quoted variables and [[ ... ]] conditionals

## Known Pitfalls

- config.kdl includes /home/pixel/.cache/wal/colors-niri.kdl directly. If pywal files are missing, startup can fail.
- scripts/lock-screen.sh uses swaylock with a minimal blurred clock and no ring indicator.
- scripts/session-menu.sh uses systemctl and assumes systemd.
- scripts/wallpaper-selector.sh expects wal and a wallpaper directory via WALLPAPERDIR or ~/Wallpapers.
