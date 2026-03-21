# MASU Hyprland Installer v2.0

```
███╗   ███╗ █████╗ ███████╗██╗   ██╗
████╗ ████║██╔══██╗██╔════╝██║   ██║
██╔████╔██║███████║███████╗██║   ██║
██║╚██╔╝██║██╔══██║╚════██║██║   ██║
██║ ╚═╝ ██║██║  ██║███████║╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝
```

> A full Hyprland desktop rice installer with a **Glassmorphism UI** and **Pywal dynamic color pipeline** — your entire desktop theme follows your wallpaper automatically.

**by [Matyas Abraham (Maty156)](https://github.com/Maty156)**

---

## Screenshots

| Desktop | Wofi Launcher |
|---------|--------------|
| ![Desktop](/assets/preview-desktop.png.png) | ![Wofi](/assets/preview-wofi.png.png) |

| Fastfetch | Wallpaper Picker |
|-----------|-----------------|
| ![Fastfetch](/assets/preview-fastfetch.png.png) | ![Picker](/assets/preview-picker.png.png) |

---

## What's in v2.0

- **Glassmorphism Waybar** — frosted glass bar with colored module pills (CPU, RAM, battery, network, volume, media)
- **Pywal color pipeline** — change wallpaper and your entire desktop theme updates automatically (waybar, wofi, dunst, hyprland borders, hyprlock)
- **Rofi wallpaper picker** — thumbnail grid, open with `SUPER+W`
- **Wofi launcher** — dynamic colors matching your current wallpaper
- **Hyprlock** — lock screen always syncs with your current wallpaper
- **Smooth animations** — fluid window animations with custom bezier curves
- **Wallpaper persistence** — your last wallpaper restores on every reboot
- **Volume & brightness OSD** — wob overlay bar for media keys
- **wob OSD** — clean volume/brightness overlay

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `hyprland` | Window manager |
| `hyprlock` | Lock screen |
| `waybar` | Status bar |
| `wofi` | App launcher |
| `rofi-wayland` | Wallpaper picker |
| `swww` | Wallpaper daemon |
| `dunst` | Notifications |
| `kitty` | Terminal |
| `python-pywal` | Dynamic color scheme generator |
| `wob` | Volume/brightness OSD |
| `imagemagick` | Thumbnail generation |
| `jq` | JSON parsing for monitor detection |
| `bc` | Math for icon size calculation |
| `grim` + `slurp` | Screenshots |
| `brightnessctl` | Brightness control |
| `playerctl` | Media control |
| `thunar` | File manager |
| `pavucontrol` | Audio control |
| `ttf-jetbrains-mono-nerd` | Font |

---

## Installation

```bash
# Clone the repo
git clone https://github.com/Maty156/masu-hyprland-installer.git
cd masu-hyprland-installer

# Run the installer
bash install.sh
```

The installer will:
1. Detect your distro and install all dependencies
2. Back up your existing configs
3. Install all MASU configs
4. Run pywal on the default wallpaper to generate initial colors
5. Enable SDDM and NetworkManager

> Supports: **Arch**, **Manjaro**, **Ubuntu**, **Debian**, **Fedora**, **openSUSE**

After install, reboot and select Hyprland from your login screen.

---

## Keybindings

| Key | Action |
|-----|--------|
| `SUPER + Q` | Open terminal (kitty) |
| `SUPER + R` / `SUPER + SPACE` | App launcher (wofi) |
| `SUPER + W` | Wallpaper picker |
| `SUPER + E` | File manager (thunar) |
| `SUPER + C` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + L` | Lock screen |
| `SUPER + Delete` | Sleep |
| `SUPER + SHIFT + Delete` | Lock + sleep |
| `SUPER + M` | Exit Hyprland |
| `SUPER + S` | Scratchpad |
| `SUPER + 1-0` | Switch workspace |
| `SUPER + SHIFT + 1-0` | Move window to workspace |
| `SUPER + arrows` | Move focus |
| `SUPER + SHIFT + arrows` | Move window |
| `SUPER + ALT + arrows` | Resize window |
| `Print` | Screenshot (fullscreen) |
| `SUPER + Print` | Screenshot (area select) |
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Mute |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

---

## Pywal Color Pipeline

When you change wallpaper with `SUPER+W`, the following update automatically:

```
Wallpaper selected
      │
      ▼
   pywal runs
      │
      ├──▶ Waybar colors
      ├──▶ Wofi launcher colors
      ├──▶ Dunst notification colors
      ├──▶ Hyprland border color
      ├──▶ Hyprlock wallpaper
      └──▶ Wob OSD colors
```

---

## Structure

```
masu-hyprland-installer/
├── install.sh
├── wallpapers/
│   └── wallpaper.jpg          # Default wallpaper
└── configs/
    ├── hypr/
    │   ├── hyprland.conf       # Main config
    │   ├── animations.conf     # Animations & decorations
    │   ├── hyprland-colors.conf # Border colors (pywal generated)
    │   ├── hyprlock.conf       # Lock screen
    │   └── scripts/
    │       ├── wallpaper.sh        # Wallpaper + pywal pipeline
    │       ├── wall-picker.sh      # Rofi thumbnail picker
    │       ├── restore-wallpaper.sh # Startup restore
    │       ├── hyprlock_wall.sh    # Hyprlock sync
    │       ├── volume-up.sh
    │       ├── volume-down.sh
    │       └── volume-mute.sh
    ├── waybar/
    │   ├── config              # Modules config
    │   └── style.css           # Glassmorphism style
    ├── wofi/
    │   ├── config
    │   └── style.css           # Dynamic pywal colors
    ├── rofi/
    │   ├── selector2.rasi      # Wallpaper picker theme
    │   ├── theme.rasi          # Base theme
    │   └── config.rasi
    ├── dunst/
    │   └── dunstrc
    ├── wob/
    │   └── wob.ini             # OSD config
    ├── fastfetch/
    │   └── config.jsonc
    └── wal/
        └── templates/
            ├── hyprland-colors.conf  # Border color template
            └── colors-wofi.css       # Wofi color template
```

---

## Adding Wallpapers

Drop any `.jpg`, `.png`, `.webp` images into `~/wallpapers/` and press `SUPER+W` to open the picker. Thumbnails are generated automatically on first launch.

---

## Credits

- Wallpaper picker adapted from [JaKooLit/Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots)
- Color pipeline powered by [pywal](https://github.com/eylles/pywal16)
- Wallpaper daemon by [swww](https://github.com/LGFae/swww)

---

## License

MIT — feel free to use, modify and share.
