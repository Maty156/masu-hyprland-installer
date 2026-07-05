#!/usr/bin/env bash
# ███╗   ███╗ █████╗ ███████╗██╗   ██╗
# ████╗ ████║██╔══██╗██╔════╝██║   ██║
# ██╔████╔██║███████║███████╗██║   ██║
# ██║╚██╔╝██║██╔══██║╚════██║██║   ██║
# ██║ ╚═╝ ██║██║  ██║███████║╚██████╔╝
# ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝
#
# MASU Hyprland Installer v3.0
# by Matyas Abraham (Maty156)
# https://github.com/Maty156/masu-hyprland-installer

set -e

# ─── Cleanup Trap ──────────────────────────────────────────
cleanup() {
    local exit_code=$?
    [[ $exit_code -ne 0 ]] && echo -e "\n${RED}[ERROR]${RESET} Installation interrupted!"
    # Clean up temp config clone if it exists
    [[ -d "$CONFIG_TMP" ]] && rm -rf "$CONFIG_TMP"
    # Stop sudo keep-alive loop if it's still running
    [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
    exit $exit_code
}
trap cleanup EXIT INT TERM

# ─── Spinner ───────────────────────────────────────────────
spinner() {
    local pid=$1
    local delay=0.1
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    while kill -0 "$pid" 2>/dev/null; do
        for frame in "${frames[@]}"; do
            printf "\r  ${CYAN}%s${RESET} %s" "$frame" "$2"
            sleep "$delay"
        done
    done
    printf "\r"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET} $1"; }
error()   { echo -e "${RED}[ERROR]${RESET} $1"; exit 1; }
step()    { echo -e "\n${BOLD}${BLUE}==>${RESET}${BOLD} $1${RESET}"; }

# ─── Config Repo ───────────────────────────────────────────
CONFIG_REPO="https://github.com/Maty156/dotfile.git"
CONFIG_TMP="/tmp/masu-config-$$"

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
echo -e "${BOLD}  MASU Hyprland Installer v3.0${RESET}"
echo -e "  ${CYAN}Matugen Dynamic Theme + awww${RESET}"
echo -e "  by Matyas Abraham\n"
echo -e "  ${CYAN}Features:${RESET}"
echo -e "  ✦ Rofi launcher with matugen dynamic colors\n"
echo -e "  ✦ Rofi-based wallpaper picker with cached backgrounds${RESET}\n"
echo -e "  ✦ Full matugen pipeline — everything follows your wallpaper"
echo -e "  ✦ awww wallpaper daemon with smooth transitions"
echo -e "  ✦ Hyprlock + SDDM sync with current wallpaper"
echo -e "  ✦ Swaync notifications with matugen colors"
echo -e "  ✦ Volume & brightness OSD with SwayOSD"
echo -e "  ✦ Smooth fluid animations"
echo -e "  ✦ Wallpaper persistence across reboots\n"
echo -e "${YELLOW}  This will install a full Hyprland desktop environment.${RESET}\n"

read -p "  Continue? [y/N] " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && echo "Aborted." && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────
# DETECT DISTRO
# ─────────────────────────────────────────
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO="$ID"
    PRETTY_NAME="${PRETTY_NAME:-$DISTRO}"
else
    DISTRO="unknown"
    PRETTY_NAME="Unknown Linux"
fi
info "Detected: $PRETTY_NAME"

# ─── NVIDIA Detection ──────────────────────────────────────
IS_NVIDIA=false
if lspci | grep -qi "nvidia"; then
    IS_NVIDIA=true
    warn "NVIDIA GPU Detected! Applying NVIDIA-specific patches..."
fi

# ─────────────────────────────────────────
# INSTALL PACKAGES
# ─────────────────────────────────────────
step "Installing packages..."

install_arch() {
    info "Using pacman..."
    sudo pacman -S --needed --noconfirm \
        hyprland hyprlock kitty waybar \
        grim slurp thunar brightnessctl playerctl \
        network-manager-applet pavucontrol \
        rofi-wayland swaync swayosd imagemagick jq bc \
        ttf-jetbrains-mono-nerd noto-fonts-extra \
        xdg-desktop-portal-hyprland \
        gtk4 libadwaita gtk-layer-shell \
        python python-pip python-virtualenv python-gobject uwsm \
        awww xxhash wl-clipboard cliphist cava htop matugen

    if ! command -v yay &>/dev/null; then
        info "Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay-install
        cd /tmp/yay-install && makepkg -si --noconfirm && cd -
        rm -rf /tmp/yay-install
    fi

    # bibata cursors + wlogout aren't in the official repos, still need AUR
    yay -S --needed --noconfirm bibata-cursor-theme wlogout
}

# ─── Rust/cargo fallback for awww + matugen (non-Arch distros) ─────
# Neither is in Debian/Fedora/openSUSE's official repos yet (Fedora only
# has an unofficial COPR). Building via cargo works identically everywhere.
install_awww_matugen_via_cargo() {
    if ! command -v cargo &>/dev/null; then
        info "Installing Rust toolchain (needed to build awww + matugen)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y -q
        # shellcheck disable=SC1090
        source "$HOME/.cargo/env"
    fi

    if ! command -v matugen &>/dev/null; then
        info "Building matugen via cargo (this can take a few minutes)..."
        cargo install matugen && success "matugen built!" || warn "matugen build failed — install manually: cargo install matugen"
    fi

    if ! command -v awww &>/dev/null; then
        info "Building awww via cargo (this can take a few minutes)..."
        cargo install --git https://codeberg.org/LGFae/awww awww && success "awww built!" || warn "awww build failed — see https://codeberg.org/LGFae/awww"
    fi
}

install_debian() {
    info "Using apt..."
    sudo apt update
    sudo apt install -y \
        kitty waybar grim slurp thunar \
        brightnessctl playerctl network-manager-gnome \
        pavucontrol rofi imagemagick jq bc curl \
        fonts-jetbrains-mono \
        python3 python3-pip python3-venv python3-gi \
        libgtk-4-dev libadwaita-1-dev swaync \
        xxhash wl-clipboard cliphist cava htop
    warn "Hyprland must still be installed manually on Debian/Ubuntu."
    install_awww_matugen_via_cargo
}

install_fedora() {
    info "Using dnf..."
    sudo dnf install -y \
        hyprland kitty waybar grim slurp thunar \
        brightnessctl playerctl network-manager-applet \
        pavucontrol rofi-wayland swaync ImageMagick jq bc curl \
        jetbrains-mono-fonts \
        gtk4-devel libadwaita-devel \
        xxhash wl-clipboard cliphist cava htop
    install_awww_matugen_via_cargo
}

install_opensuse() {
    info "Using zypper..."
    sudo zypper install -y \
        hyprland kitty waybar grim slurp thunar \
        brightnessctl playerctl NetworkManager-applet \
        pavucontrol rofi swaync ImageMagick jq bc curl \
        xxhash wl-clipboard cliphist cava htop
    install_awww_matugen_via_cargo
}

install_pkgs() {
    case "$DISTRO" in
        arch|blackarch)    install_arch ;;
        manjaro)           install_arch ;;
        ubuntu|debian|pop) install_debian ;;
        fedora)            install_fedora ;;
        opensuse*)         install_opensuse ;;
        *)                 warn "Unknown distro: $DISTRO. Trying pacman..." && install_arch ;;
    esac
}

step "Installing packages..."

# Prompt for sudo up front (visibly) since install_pkgs runs backgrounded
# behind a spinner and a hidden password prompt would look like a hang.
sudo -v
( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

install_pkgs &
spinner $! "Downloading and installing packages..."
wait

kill "$SUDO_KEEPALIVE_PID" 2>/dev/null

success "Packages installed!"

# ─────────────────────────────────────────
# BACKUP
# ─────────────────────────────────────────
step "Backing up existing configs..."

BACKUP_DIR="$HOME/.config/masu-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for dir in hypr waybar rofi swaync swayosd kitty matugen cava htop wlogout; do
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

# ─────────────────────────────────────────
# CLONE CONFIG REPO
# ─────────────────────────────────────────
step "Fetching configs from Maty156/dotfile..."

if ! command -v git &>/dev/null; then
    error "git is required but not installed."
fi

info "Cloning $CONFIG_REPO..."
git clone --depth=1 "$CONFIG_REPO" "$CONFIG_TMP" &
spinner $! "Cloning config repo..."
wait
success "Config repo cloned!"

# ─────────────────────────────────────────
# INSTALL CONFIGS
# ─────────────────────────────────────────
step "Installing configs..."

install_config() {
    local dir=$1
    if [ -d "$CONFIG_TMP/$dir" ]; then
        mkdir -p "$HOME/.config/$dir"
        cp -r "$CONFIG_TMP/$dir/." "$HOME/.config/$dir/"
        success "Installed $dir"
    else
        warn "Config not found in repo: $dir — skipping"
    fi
}

install_config "hypr"
install_config "waybar"
install_config "rofi"
install_config "swaync"
install_config "swayosd"
install_config "kitty"
install_config "matugen"
install_config "cava"
install_config "htop"
install_config "wlogout"

# Copy default wallpaper if present in config repo
if [ -f "$CONFIG_TMP/wallpapers/wallpaper.jpg" ]; then
    cp "$CONFIG_TMP/wallpapers/wallpaper.jpg" "$HOME/wallpapers/wallpaper.jpg"
    success "Default wallpaper copied!"
else
    warn "No default wallpaper in config repo. Add images to ~/wallpapers/"
fi

# Make all scripts executable
[ -d "$HOME/.config/hypr/scripts" ] && \
    chmod +x "$HOME/.config/hypr/scripts/"*.sh && \
    success "Scripts made executable"

# Cleanup temp clone
rm -rf "$CONFIG_TMP"
success "Config repo cleaned up"

# ─── NVIDIA PATCHES ────────────────────────────────────────
if [[ "$IS_NVIDIA" = true ]]; then
    step "Applying NVIDIA Patches..."
    if ! grep -q "LIBVA_DRIVER_NAME = nvidia" "$HOME/.config/hypr/hyprland.conf"; then
        sed -i '1i env = LIBVA_DRIVER_NAME,nvidia\nenv = XDG_SESSION_TYPE,wayland\nenv = GBM_BACKEND,nvidia-drm\nenv = __GLX_VENDOR_LIBRARY_NAME,nvidia\nenv = WLR_NO_HARDWARE_CURSORS,1' "$HOME/.config/hypr/hyprland.conf"
        success "NVIDIA environment variables added to hyprland.conf"
    fi
fi

# ─── ECOSYSTEM SYNC ────────────────────────────────────────
step "Syncing with MASU Ecosystem..."
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "MASU Terminal detected!"
    success "Terminal ready — kitty colors are refreshed by matugenMagick.sh on each wallpaper change."
fi

# ─────────────────────────────────────────
# INITIAL COLOR SCHEME (matugen)
# ─────────────────────────────────────────
step "Generating initial color scheme..."

INITIAL_WALL="$HOME/wallpapers/wallpaper.jpg"
if [ -f "$INITIAL_WALL" ] && command -v awww &>/dev/null && command -v matugen &>/dev/null; then
    awww query &>/dev/null || awww-daemon --format xrgb &
    sleep 1
    FOCUSED_MONITOR=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .name' 2>/dev/null)
    awww img -o "$FOCUSED_MONITOR" "$INITIAL_WALL" 2>/dev/null || awww img "$INITIAL_WALL"
    sleep 0.5
    [ -x "$HOME/.config/hypr/scripts/matugenMagick.sh" ] && "$HOME/.config/hypr/scripts/matugenMagick.sh" --dark
    success "Colors generated!"
else
    warn "No default wallpaper, awww, or matugen found — run wallSelect.sh manually after reboot."
fi

# ─────────────────────────────────────────
# SDDM
# ─────────────────────────────────────────
step "Setting up SDDM..."

if command -v sddm &>/dev/null; then
    step "Installing SDDM Theme..."
    if [ ! -d "/usr/share/sddm/themes/catppuccin" ]; then
        sudo mkdir -p /usr/share/sddm/themes
        git clone https://github.com/catppuccin/sddm.git /tmp/sddm-theme
        sudo cp -r /tmp/sddm-theme/src/catppuccin-macchiato /usr/share/sddm/themes/catppuccin
        rm -rf /tmp/sddm-theme
        success "Catppuccin SDDM Theme installed!"
    fi

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

sudo systemctl enable sddm           2>/dev/null && success "SDDM enabled"           || warn "Could not enable SDDM"
sudo systemctl enable NetworkManager 2>/dev/null && success "NetworkManager enabled" || warn "Already enabled"

# ─────────────────────────────────────────
# DONE
# ─────────────────────────────────────────
echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   MASU Hyprland v3.0 Install Complete! 🎉  ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════╝${RESET}\n"
echo -e "  ${CYAN}What's installed:${RESET}"
echo -e "  ✓ Hyprland + smooth animations"
echo -e "  ✓ Waybar with matugen dynamic colors"
echo -e "  ✓ Rofi launcher + wallpaper picker (dynamic colors)"
echo -e "  ✓ Hyprlock (auto wallpaper sync)"
echo -e "  ✓ SDDM login screen (auto wallpaper + color sync)"
echo -e "  ✓ Swaync notifications (matugen colors)"
echo -e "  ✓ Volume & brightness OSD (SwayOSD)"
echo -e "  ✓ Matugen color pipeline"
echo -e "  ✓ Wallpaper persistence on reboot\n"
echo -e "  ${BOLD}Key bindings:${RESET}"
echo -e "  SUPER+Q          → Terminal (kitty)"
echo -e "  SUPER+SPACE      → App launcher (rofi)"
echo -e "  SUPER+W          → Wallpaper picker (rofi + wallSelect.sh)"
echo -e "  SUPER+Z          → Spotify scratchpad"
echo -e "  SUPER+C          → Close window"
echo -e "  SUPER+F          → Fullscreen"
echo -e "  SUPER+V          → Toggle floating"
echo -e "  SUPER+SHIFT+V    → Float + center + resize"
echo -e "  SUPER+L          → Lock screen"
echo -e "  SUPER+Delete     → Sleep"
echo -e "  Print            → Screenshot"
echo -e "  SUPER+Print      → Area screenshot\n"
echo -e "  ${YELLOW}Add wallpapers to ~/wallpapers/ then press SUPER+W${RESET}"
echo -e "  ${YELLOW}Reboot to start Hyprland!${RESET}\n"
echo -e "  ${CYAN}GitHub: https://github.com/Maty156/masu-hyprland-installer${RESET}\n"
