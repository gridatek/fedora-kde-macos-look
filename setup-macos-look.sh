#!/bin/bash
: '
========================================================
Fedora KDE macOS Look Setup Script
========================================================

Description:
This script transforms your Fedora KDE Plasma desktop
into a macOS-like look by installing themes, icons,
cursors, fonts, Latte Dock, and applying a macOS wallpaper.

Disclaimer:
- Only for Fedora KDE Plasma.
- Backup your settings before running.
- Some Latte Dock configurations (position, zoom) may
  require manual adjustment.

Features:
- McMojave Plasma theme
- McMojave-circle icons
- macOS-style cursor
- SF Pro fonts
- Latte Dock installed for macOS dock
- macOS wallpaper applied

Usage:
1. Download this file: setup-macos-look.sh
2. Make executable:
   chmod +x setup-macos-look.sh
3. Run the script:
   ./setup-macos-look.sh
4. Open Latte Dock and move it to bottom panel.
5. Log out and log back in to apply all changes.

Credits:
- Vinceliuice/McMojave-kde (Plasma theme)
- Vinceliuice/McMojave-circle (Icon theme)
- Wallpaper source: WallpaperAccess
========================================================
'

set -e

# -----------------------------
# Check for Fedora
# -----------------------------
if ! grep -q "Fedora" /etc/os-release; then
    echo "This script is only for Fedora. Exiting."
    exit 1
fi

# -----------------------------
# Check for KDE Plasma
# -----------------------------
if [ "$XDG_CURRENT_DESKTOP" != "KDE" ]; then
    echo "This script must be run in KDE Plasma session. Exiting."
    exit 1
fi

echo "✅ Fedora KDE detected. Proceeding with macOS look setup..."

# -----------------------------
# Update system and install packages
# -----------------------------
echo "Updating system..."
sudo dnf update -y

echo "Installing required packages..."
sudo dnf install -y latte-dock git wget unzip plasma-workspace kde-gtk-config

# -----------------------------
# Set directories for themes/icons/cursors/wallpapers
# -----------------------------
THEMES_DIR="$HOME/.local/share/plasma/desktoptheme"
ICONS_DIR="$HOME/.local/share/icons"
CURSORS_DIR="$HOME/.icons"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

mkdir -p "$THEMES_DIR" "$ICONS_DIR" "$CURSORS_DIR" "$WALLPAPER_DIR"

# -----------------------------
# Download themes and icons
# -----------------------------
echo "Downloading McMojave Plasma theme..."
wget -O /tmp/McMojave.zip https://github.com/vinceliuice/McMojave-kde/archive/refs/heads/master.zip
unzip /tmp/McMojave.zip -d /tmp/
mv /tmp/McMojave-kde-master "$THEMES_DIR/McMojave"

echo "Downloading McMojave-circle icon theme..."
wget -O /tmp/McMojave-circle.zip https://github.com/vinceliuice/McMojave-circle/archive/refs/heads/master.zip
unzip /tmp/McMojave-circle.zip -d /tmp/
mv /tmp/McMojave-circle-master "$ICONS_DIR/McMojave-circle"

echo "Downloading macOS cursor theme..."
wget -O /tmp/cursors.zip https://www.gnome-look.org/p/1195147/startdownload?file_id=1555954011&file_name=macOS.zip
unzip /tmp/cursors.zip -d "$CURSORS_DIR"

# -----------------------------
# Apply themes, icons, and cursors
# -----------------------------
echo "Applying themes and icons..."
kwriteconfig5 --file kdeglobals --group Icons --key Theme "McMojave-circle"
kwriteconfig5 --file kdeglobals --group KDE --key widgetStyle "Breeze"
kwriteconfig5 --file kdeglobals --group KdeGeneral --key LookAndFeelPackage "McMojave"
kwriteconfig5 --file kdeglobals --group KGlobalStyle --key GTKTheme "McMojave"

# -----------------------------
# Configure fonts
# -----------------------------
echo "Setting macOS-style fonts..."
kwriteconfig5 --file kdeglobals --group General --key font "SF Pro 10,-1,5,50,0,0,0,0,0,0"
kwriteconfig5 --file kdeglobals --group General --key fixed "SF Pro 10,-1,5,50,0,0,0,0,0,0"

# -----------------------------
# Download macOS wallpaper
# -----------------------------
echo "Downloading macOS wallpaper..."
wget -O "$WALLPAPER_DIR/macos-wallpaper.jpg" https://wallpaperaccess.com/full/317501.jpg
plasmashell --replace &  # reload plasma shell
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
d = allDesktops[i];
d.wallpaperPlugin = 'org.kde.image';
d.currentConfigGroup = Array('Wallpaper','org.kde.image','General');
d.writeConfig('Image', 'file://$WALLPAPER_DIR/macos-wallpaper.jpg');
}
"

# -----------------------------
# Launch Latte Dock
# -----------------------------
echo "Launching Latte Dock..."
latte-dock &
sleep 5
echo "✅ Latte Dock opened. Move it to the bottom panel and enable Zoom + Auto-hide if desired."

echo "🎉 macOS look setup complete! Log out and log back in to fully apply all changes."
