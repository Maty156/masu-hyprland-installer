#!/usr/bin/env bash
# ███╗   ███╗ █████╗ ███████╗██╗   ██╗
# ████╗ ████║██╔══██╗██╔════╝██║   ██║
# ██╔████╔██║███████║███████╗██║   ██║
# ██║╚██╔╝██║██╔══██║╚════██║██║   ██║
# ██║ ╚═╝ ██║██║  ██║███████║╚██████╔╝
# ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝
#
# MASU Hyprland Installer v2.0
# by Matyas Abraham (Maty156)
# https://github.com/Maty156/masu-hyprland-installer
#
# Full Hyprland rice with:
#   - Glassmorphism Waybar
#   - Pywal dynamic color pipeline
#   - Rofi wallpaper picker with thumbnails
#   - Wofi launcher with wallpaper-matched colors
#   - Hyprlock with auto wallpaper sync
#   - Smooth animations
#   - Wallpaper persistence across reboots

set -e

# ─────────────────────────────────────────
# COLORS
# ─────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# ─────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────
info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error()   { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }
step()    { echo -e "\n${BOLD}${BLUE}==>${RESET}${BOLD} $1${RESET}"; }

# ─────────────────────────────────────────
# BANNER
# ─────────────────────────────────────────
clear
echo -e "${CYAN}"
cat << 'EOF'
███╗   ███╗ █████╗ ███████╗██╗   ██╗
████╗ ████║██╔══██╗██╔════╝██║   ██║
██╔████╔██║███████║███████╗██║   ██║
██║╚██╔╝██║██╔══██║╚════██║██║   ██║
██║ ╚═╝ ██║██║  ██║███████║╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝
EOF
echo -e "${RESET}"
echo -e "${BOLD}  MASU Hyprland Installer v2.0${RESET}"
echo -e "  ${CYAN}Glassmorphism + Pywal Dynamic Theme${RESET}"
echo -e "  by Matyas Abraham\n"
echo -e "  ${CYAN}What's new in v2.0:${RESET}"
echo -e "  ✦ Glassmorphism Waybar with colored module pills"
echo -e "  ✦ Pywal color pipeline — desktop theme follows wallpaper"
echo -e "  ✦ Rofi thumbnail wallpaper picker (SUPER+W)"
echo -e "  ✦ Wofi launcher with dynamic colors"
echo -e "  ✦ Hyprlock auto-syncs with current wallpaper"
echo -e "  ✦ Smooth fluid animations"
echo -e "  ✦ Wallpaper persistence across reboots\n"
echo -e "${YELLOW}  This will install a full Hyprland desktop environment.${RESET}\n"

read -p "  Continue? [y/N] " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && echo "Aborted." && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────
# DETECT DISTRO
# ─────────────────────────────────────────
step "Detecting distribution..."

[ -f /etc/os-release ] && source /etc/os-release || error "Cannot detect distribution!"
DISTRO=$ID
info "Detected: $PRETTY_NAME"

# ─────────────────────────────────────────
# INSTALL PACKAGES
# ─────────────────────────────────────────
step "Installing packages..."

install_arch() {
    info "Using pacman..."
    sudo pacman -S --needed --noconfirm \
        hyprland hyprlock kitty waybar wofi dunst swww \
        grim slurp thunar brightnessctl playerctl \
        network-manager-applet pavucontrol \
        rofi-wayland imagemagick jq bc \
        ttf-jetbrains-mono-nerd noto-fonts-extra \
        python-pywal wob xdg-desktop-portal-hyprland \
        fastfetch

    if ! command -v yay &>/dev/null; then
        info "Installing yay (AUR helper)..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay-install
        cd /tmp/yay-install && makepkg -si --noconfirm && cd -
        rm -rf /tmp/yay-install
    fi

    yay -S --needed --noconfirm bibata-cursor-theme
}

install_debian() {
    info "Using apt..."
    sudo apt update
    sudo apt install -y \
        kitty waybar wofi dunst grim slurp thunar \
        brightnessctl playerctl network-manager-gnome \
        pavucontrol rofi imagemagick jq bc \
        fonts-jetbrains-mono python3-pywal
    warn "Hyprland and swww must be installed manually on Debian/Ubuntu."
    warn "Visit: https://wiki.hypr.land/Getting-Started/Installation/"
}

install_fedora() {
    info "Using dnf..."
    sudo dnf install -y \
        hyprland kitty waybar wofi dunst grim slurp thunar \
        brightnessctl playerctl network-manager-applet \
        pavucontrol rofi-wayland ImageMagick jq bc \
        jetbrains-mono-fonts python3-pywal
}

install_opensuse() {
    info "Using zypper..."
    sudo zypper install -y \
        hyprland kitty waybar wofi dunst grim slurp thunar \
        brightnessctl playerctl NetworkManager-applet \
        pavucontrol rofi ImageMagick jq bc
}

case "$DISTRO" in
    arch|blackarch)    install_arch ;;
    manjaro)           install_arch ;;
    ubuntu|debian|pop) install_debian ;;
    fedora)            install_fedora ;;
    opensuse*)         install_opensuse ;;
    *)                 warn "Unknown distro: $DISTRO. Trying pacman..." && install_arch ;;
esac

success "Packages installed!"

# ─────────────────────────────────────────
# BACKUP
# ─────────────────────────────────────────
step "Backing up existing configs..."

BACKUP_DIR="$HOME/.config/masu-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for dir in hypr waybar wofi dunst rofi fastfetch; do
    [ -d "$HOME/.config/$dir" ] && cp -r "$HOME/.config/$dir" "$BACKUP_DIR/" && info "Backed up $dir"
done

success "Backup saved to $BACKUP_DIR"

# ─────────────────────────────────────────
# WALLPAPERS
# ─────────────────────────────────────────
step "Setting up wallpapers..."

mkdir -p "$HOME/wallpapers"
mkdir -p "$HOME/Pictures"
mkdir -p "$HOME/.cache/wallpaper-thumbs"

if [ -f "$SCRIPT_DIR/wallpapers/wallpaper.jpg" ]; then
    cp "$SCRIPT_DIR/wallpapers/wallpaper.jpg" "$HOME/wallpapers/wallpaper.jpg"
    success "Default wallpaper copied!"
else
    warn "No wallpaper found in installer. Add images to ~/wallpapers/"
fi

# ─────────────────────────────────────────
# INSTALL CONFIGS
# ─────────────────────────────────────────
step "Installing configs..."

install_config() {
    local dir=$1
    mkdir -p "$HOME/.config/$dir"
    cp -r "$SCRIPT_DIR/configs/$dir/." "$HOME/.config/$dir/"
    success "Installed $dir"
}

install_config "hypr"
install_config "waybar"
install_config "wofi"
install_config "dunst"
install_config "rofi"
install_config "fastfetch"

# Install pywal templates
mkdir -p "$HOME/.config/wal/templates"
cp -r "$SCRIPT_DIR/configs/wal/templates/." "$HOME/.config/wal/templates/"
success "Installed pywal templates"

# Make scripts executable
chmod +x "$HOME/.config/hypr/scripts/"*.sh
success "Scripts made executable"

# ─────────────────────────────────────────
# PYWAL INITIAL RUN
# ─────────────────────────────────────────
step "Generating initial color scheme..."

if command -v wal &>/dev/null; then
    INITIAL_WALL="$HOME/wallpapers/wallpaper.jpg"
    if [ -f "$INITIAL_WALL" ]; then
        wal -i "$INITIAL_WALL" -n -q
        # Sync all color files
        [ -f ~/.cache/wal/colors-waybar.css ]    && cp ~/.cache/wal/colors-waybar.css  ~/.config/waybar/colors.css
        [ -f ~/.cache/wal/colors-wofi.css ]      && cp ~/.cache/wal/colors-wofi.css    ~/.config/wofi/style.css
        [ -f ~/.cache/wal/wob.ini ]              && cp ~/.cache/wal/wob.ini             ~/.config/wob/wob.ini 2>/dev/null || true
        [ -f ~/.cache/wal/dunstrc ]              && cp ~/.cache/wal/dunstrc              ~/.config/dunst/dunstrc
        [ -f ~/.cache/wal/hyprland-colors.conf ] && cp ~/.cache/wal/hyprland-colors.conf ~/.config/hypr/hyprland-colors.conf
        # Sync hyprlock
        sed -i "s|^    path = .*|    path = $INITIAL_WALL|" ~/.config/hypr/hyprlock.conf
        success "Colors generated from default wallpaper!"
    else
        warn "No wallpaper found — run SUPER+W after first boot to pick one"
    fi
else
    warn "pywal not found — install with: pip install pywal"
fi

# ─────────────────────────────────────────
# WOB SETUP
# ─────────────────────────────────────────
step "Setting up wob OSD..."
install_config "wob"

# ─────────────────────────────────────────
# SDDM
# ─────────────────────────────────────────
step "Setting up SDDM..."

if command -v sddm &>/dev/null; then
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/masu.conf > /dev/null << 'SDDMEOF'
[Theme]
Current=catppuccin

[General]
DisplayServer=wayland

[Wayland]
SessionDir=/usr/share/wayland-sessions
SDDMEOF
    success "SDDM configured!"
else
    warn "SDDM not found. Install: sudo pacman -S sddm"
fi

# ─────────────────────────────────────────
# SERVICES
# ─────────────────────────────────────────
step "Enabling services..."

sudo systemctl enable sddm        2>/dev/null && success "SDDM enabled"        || warn "Could not enable SDDM"
sudo systemctl enable NetworkManager 2>/dev/null && success "NetworkManager enabled" || warn "NetworkManager already enabled"

# ─────────────────────────────────────────
# DONE
# ─────────────────────────────────────────
echo -e "\n${GREEN}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   MASU Hyprland v2.0 Install Complete!   ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════╝${RESET}\n"
echo -e "  ${CYAN}What's installed:${RESET}"
echo -e "  ✓ Hyprland + smooth animations"
echo -e "  ✓ Glassmorphism Waybar"
echo -e "  ✓ Wofi launcher (dynamic colors)"
echo -e "  ✓ Rofi wallpaper picker (SUPER+W)"
echo -e "  ✓ Hyprlock (auto wallpaper sync)"
echo -e "  ✓ Dunst notifications"
echo -e "  ✓ Pywal color pipeline"
echo -e "  ✓ Wallpaper persistence on reboot"
echo -e "  ✓ Fastfetch"
echo -e "  ✓ SDDM\n"
echo -e "  ${BOLD}Key bindings:${RESET}"
echo -e "  SUPER+Q          → Terminal (kitty)"
echo -e "  SUPER+R / SPACE  → App launcher (wofi)"
echo -e "  SUPER+W          → Wallpaper picker"
echo -e "  SUPER+C          → Close window"
echo -e "  SUPER+F          → Fullscreen"
echo -e "  SUPER+L          → Lock screen"
echo -e "  SUPER+Delete     → Sleep"
echo -e "  Print            → Screenshot"
echo -e "  SUPER+Print      → Area screenshot\n"
echo -e "  ${YELLOW}Add wallpapers to ~/wallpapers/ then press SUPER+W${RESET}"
echo -e "  ${YELLOW}Reboot to start Hyprland!${RESET}\n"
echo -e "  ${CYAN}GitHub: https://github.com/Maty156/masu-hyprland-installer${RESET}\n"
