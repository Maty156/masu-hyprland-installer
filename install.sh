#!/usr/bin/env bash
# ███╗   ███╗ █████╗ ███████╗██╗   ██╗
# ████╗ ████║██╔══██╗██╔════╝██║   ██║
# ██╔████╔██║███████║███████╗██║   ██║
# ██║╚██╔╝██║██╔══██║╚════██║██║   ██║
# ██║ ╚═╝ ██║██║  ██║███████║╚██████╔╝
# ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝
#
# MASU Hyprland Installer v2.3
# by Matyas Abraham (Maty156)
# https://github.com/Maty156/masu-hyprland-installer

set -e

# ─── Cleanup Trap ──────────────────────────────────────────
cleanup() {
    local exit_code=$?
    [[ $exit_code -ne 0 ]] && echo -e "\n${RED}[ERROR]${RESET} Installation interrupted!"
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
echo -e "${BOLD}  MASU Hyprland Installer v2.3${RESET}"
echo -e "  ${CYAN}Glassmorphism + Pywal Dynamic Theme${RESET}"
echo -e "  by Matyas Abraham\n"
echo -e "  ${CYAN}Features:${RESET}"
echo -e "  ✦ Glassmorphism Waybar with pywal dynamic colors"
echo -e "  ✦ Matuwall panel wallpaper picker (SUPER+W)"
echo -e "  ✦ Full pywal pipeline — everything follows your wallpaper"
echo -e "  ✦ awww wallpaper daemon with smooth transitions"
echo -e "  ✦ Wofi launcher with dynamic colors"
echo -e "  ✦ Hyprlock + SDDM sync with current wallpaper"
echo -e "  ✦ Volume & brightness OSD with wob"
echo -e "  ✦ Smooth fluid animations"
echo -e "  ✦ Wallpaper persistence across reboots\n"
echo -e "${YELLOW}  This will install a full Hyprland desktop environment.${RESET}\n"

read -p "  Continue? [y/N] " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && echo "Aborted." && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────
# DETECT DISTRO
# ─────────────────────────────────────────
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
        hyprland hyprlock kitty waybar wofi dunst \
        grim slurp thunar brightnessctl playerctl \
        network-manager-applet pavucontrol \
        rofi-wayland imagemagick jq bc \
        ttf-jetbrains-mono-nerd noto-fonts-extra \
        python-pywal wob xdg-desktop-portal-hyprland \
        fastfetch gtk4 libadwaita gtk-layer-shell \
        python python-pip python-virtualenv python-gobject

    if ! command -v yay &>/dev/null; then
        info "Installing yay..."
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay-install
        cd /tmp/yay-install && makepkg -si --noconfirm && cd -
        rm -rf /tmp/yay-install
    fi

    yay -S --needed --noconfirm awww-bin bibata-cursor-theme

    # Install Matuwall
    if ! command -v matuwall &>/dev/null; then
        info "Installing Matuwall wallpaper picker..."
        git clone https://github.com/naurissteins/Matuwall.git ~/Matuwall
        cd ~/Matuwall
        /usr/bin/python -m venv --system-site-packages .venv
        source .venv/bin/activate
        pip install --upgrade pip
        pip install .
        mkdir -p ~/.local/bin
        ln -sf "$PWD/.venv/bin/matuwall" ~/.local/bin/matuwall
        cd -
        success "Matuwall installed!"
    fi
}

install_debian() {
    info "Using apt..."
    sudo apt update
    sudo apt install -y \
        kitty waybar wofi dunst grim slurp thunar \
        brightnessctl playerctl network-manager-gnome \
        pavucontrol rofi imagemagick jq bc \
        fonts-jetbrains-mono python3-pywal \
        python3 python3-pip python3-venv python3-gi \
        libgtk-4-dev libadwaita-1-dev
    warn "Hyprland and awww must be installed manually on Debian/Ubuntu."
}

install_fedora() {
    info "Using dnf..."
    sudo dnf install -y \
        hyprland kitty waybar wofi dunst grim slurp thunar \
        brightnessctl playerctl network-manager-applet \
        pavucontrol rofi-wayland ImageMagick jq bc \
        jetbrains-mono-fonts python3-pywal \
        gtk4-devel libadwaita-devel
}

install_opensuse() {
    info "Using zypper..."
    sudo zypper install -y \
        hyprland kitty waybar wofi dunst grim slurp thunar \
        brightnessctl playerctl NetworkManager-applet \
        pavucontrol rofi ImageMagick jq bc
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
install_pkgs &
spinner $! "Downloading and installing packages..."
wait

success "Packages installed!"

# ─────────────────────────────────────────
# BACKUP
# ─────────────────────────────────────────
step "Backing up existing configs..."

BACKUP_DIR="$HOME/.config/masu-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

for dir in hypr waybar wofi dunst rofi fastfetch wob matuwall; do
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
    warn "No wallpaper found. Add images to ~/wallpapers/"
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
install_config "wob"
install_config "matuwall"

# Install pywal templates
mkdir -p "$HOME/.config/wal/templates"
cp -r "$SCRIPT_DIR/configs/wal/templates/." "$HOME/.config/wal/templates/"
success "Installed pywal templates"

# Make all scripts executable
chmod +x "$HOME/.config/hypr/scripts/"*.sh
success "Scripts made executable"

# ─── NVIDIA PATSCHES ───────────────────────────────────────
if [[ "$IS_NVIDIA" = true ]]; then
    step "Applying NVIDIA Patches..."
    # Add NVIDIA env vars to hyprland.conf if not present
    if ! grep -q "LIBVA_DRIVER_NAME = nvidia" "$HOME/.config/hypr/hyprland.conf"; then
        sed -i '1i env = LIBVA_DRIVER_NAME,nvidia\nenv = XDG_SESSION_TYPE,wayland\nenv = GBM_BACKEND,nvidia-drm\nenv = __GLX_VENDOR_LIBRARY_NAME,nvidia\nenv = WLR_NO_HARDWARE_CURSORS,1' "$HOME/.config/hypr/hyprland.conf"
        success "NVIDIA environment variables added to hyprland.conf"
    fi
fi

# ─── ECOSYSTEM SYNC ────────────────────────────────────────
step "Syncing with MASU Ecosystem..."
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "MASU Terminal detected! Syncing colors..."
    # Ensure terminal color restore is in .zshrc
    if ! grep -q 'wal/sequences' ~/.zshrc 2>/dev/null; then
        echo '(cat ~/.cache/wal/sequences &)' >> ~/.zshrc
    fi
    success "Terminal colors synced with Pywal pipeline"
fi

# ─────────────────────────────────────────
# AWWW WRAPPER
# ─────────────────────────────────────────
step "Setting up awww wrapper..."

mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/awww" << 'AWWWEOF'
#!/bin/bash
# MASU awww wrapper — runs real awww then triggers pywal pipeline
REAL_AWW=/usr/bin/awww
WALLPAPER="${@: -1}"
"$REAL_AWW" "$@"
[ -f "$WALLPAPER" ] && bash ~/.config/hypr/scripts/wallpaper-colors.sh "$WALLPAPER" &
AWWWEOF
chmod +x "$HOME/.local/bin/awww"

# Add ~/.local/bin to PATH if not already there
if ! grep -q 'local/bin' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi
if ! grep -q 'local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Add pywal terminal color restore
if ! grep -q 'wal/sequences' ~/.zshrc 2>/dev/null; then
    echo '(cat ~/.cache/wal/sequences &)' >> ~/.zshrc
fi

success "awww wrapper installed!"

# ─────────────────────────────────────────
# SUDOERS FOR SDDM
# ─────────────────────────────────────────
step "Setting up SDDM wallpaper sync..."

echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/cp, /usr/bin/sed" | sudo tee /etc/sudoers.d/masu-wallpaper > /dev/null
success "Sudoers configured for SDDM sync!"

# ─────────────────────────────────────────
# PYWAL INITIAL RUN
# ─────────────────────────────────────────
step "Generating initial color scheme..."

if command -v wal &>/dev/null; then
    INITIAL_WALL="$HOME/wallpapers/wallpaper.jpg"
    if [ -f "$INITIAL_WALL" ]; then
        wal -i "$INITIAL_WALL" -n -q
        [ -f ~/.cache/wal/colors-waybar.css ]    && cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/colors.css
        [ -f ~/.cache/wal/colors-wofi.css ]      && cp ~/.cache/wal/colors-wofi.css   ~/.config/wofi/style.css
        [ -f ~/.cache/wal/wob.ini ]              && cp ~/.cache/wal/wob.ini            ~/.config/wob/wob.ini
        [ -f ~/.cache/wal/dunstrc ]              && cp ~/.cache/wal/dunstrc             ~/.config/dunst/dunstrc
        [ -f ~/.cache/wal/hyprland-colors.conf ] && cp ~/.cache/wal/hyprland-colors.conf ~/.config/hypr/hyprland-colors.conf
        sed -i "s|^    path = .*|    path = $INITIAL_WALL|" ~/.config/hypr/hyprlock.conf
        success "Colors generated!"
    fi
else
    warn "pywal not found — run: pip install pywal"
fi

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

sudo systemctl enable sddm           2>/dev/null && success "SDDM enabled"           || warn "Could not enable SDDM"
sudo systemctl enable NetworkManager 2>/dev/null && success "NetworkManager enabled" || warn "Already enabled"

# ─────────────────────────────────────────
# DONE
# ─────────────────────────────────────────
echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║   MASU Hyprland v2.3 Install Complete! 🎉  ║${RESET}"
echo -e "${GREEN}${BOLD}╚════════════════════════════════════════════╝${RESET}\n"
echo -e "  ${CYAN}What's installed:${RESET}"
echo -e "  ✓ Hyprland + smooth animations"
echo -e "  ✓ Glassmorphism Waybar with pywal colors"
echo -e "  ✓ Matuwall panel wallpaper picker"
echo -e "  ✓ Wofi launcher (dynamic colors)"
echo -e "  ✓ Hyprlock (auto wallpaper sync)"
echo -e "  ✓ SDDM login screen (auto wallpaper + color sync)"
echo -e "  ✓ Dunst notifications (pywal colors)"
echo -e "  ✓ Volume & brightness OSD (wob)"
echo -e "  ✓ Pywal color pipeline"
echo -e "  ✓ Wallpaper persistence on reboot"
echo -e "  ✓ Fastfetch\n"
echo -e "  ${BOLD}Key bindings:${RESET}"
echo -e "  SUPER+Q          → Terminal (kitty)"
echo -e "  SUPER+R / SPACE  → App launcher (wofi)"
echo -e "  SUPER+W          → Wallpaper picker (matuwall panel)"
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
