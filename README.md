# MASU Hyprland Installer v3.0

```
███╗   ███╗ █████╗ ███████╗██╗   ██╗
████╗ ████║██╔══██╗██╔════╝██║   ██║
██╔████╔██║███████║███████╗██║   ██║
██║╚██╔╝██║██╔══██║╚════██║██║   ██║
██║ ╚═╝ ██║██║  ██║███████║╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝
```

> A full Hyprland desktop rice installer with a **matugen dynamic color pipeline** — your entire desktop theme follows your wallpaper automatically.

**by [Matyas Abraham (Maty156)](https://github.com/Maty156)**

---

## What's in v3.0

- 🎨 **Matugen color pipeline** — Material You colors generated straight from your wallpaper, no pywal
- 🖼️ **Rofi wallpaper picker** — cached thumbnails, multi-monitor aware, triggers the full theming chain (`wallSelect.sh` → `matugenMagick.sh`)
- 🌊 **awww wallpaper daemon** — smooth transitions and persistence
- 🔔 **Swaync notifications** — reload automatically with matugen colors on every wallpaper change
- 🔊 **SwayOSD** — volume/brightness overlay, replacing wob
- 🔒 **Hyprlock + SDDM** — both sync with the current wallpaper
- 🕵️ **NVIDIA detection** — auto-patches env vars for NVIDIA hardware
- ⚡ **Real distro detection** — actually reads `/etc/os-release` now, so Fedora/Debian/openSUSE get correct package sets instead of silently falling back to Arch
- 🦀 **Cargo fallback** — on distros without an `awww`/`matugen` package, the installer builds both from source automatically
- Smooth fluid window animations with bezier curves
- Wallpaper persistence across reboots

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `hyprland` | Window manager |
| `hyprlock` | Lock screen |
| `waybar` | Status bar |
| `rofi-wayland` | App launcher + wallpaper picker |
| `awww` | Wallpaper daemon |
| `matugen` | Material You color generator |
| `swaync` | Notifications |
| `swayosd` | Volume/brightness OSD |
| `kitty` | Terminal |
| `cava` | Audio visualizer |
| `htop` | System monitor |
| `wlogout` | Logout/power menu |
| `grim` + `slurp` | Screenshots |
| `brightnessctl` | Brightness control |
| `playerctl` | Media control |
| `thunar` | File manager |
| `pavucontrol` | Audio control |
| `ttf-jetbrains-mono-nerd` | Font |
| `gtk4` + `libadwaita` + `gtk-layer-shell` | GTK theming support |
| `jq` | JSON parsing |
| `imagemagick` | Rofi background cache regeneration |
| `xxhash` | Fast checksums for the wallpaper cache |
| `wl-clipboard` + `cliphist` | Clipboard history |

On Arch/Manjaro/BlackArch, `awww` and `matugen` install directly from the official repos. On Debian/Fedora/openSUSE, the installer builds them via `cargo` if no packaged version is available.

---

## Installation

```bash
git clone https://github.com/Maty156/masu-hyprland-installer.git
cd masu-hyprland-installer
bash install.sh
```

The installer will:
1. Detect your distro (via `/etc/os-release`) and install all dependencies
2. Back up your existing configs to `~/.config/masu-backup-<timestamp>/`
3. Clone [`Maty156/dotfile`](https://github.com/Maty156/dotfile) and install all MASU configs and scripts
4. Set the initial wallpaper and run the matugen pipeline once
5. Configure SDDM and enable services

> Supports: **Arch**, **Manjaro**, **BlackArch**, **Ubuntu**, **Debian**, **Fedora**, **openSUSE**
> Arch-based distros get the smoothest ride — everything else falls back to building `awww`/`matugen` from source via cargo, and Hyprland itself still needs a manual install on Debian/Ubuntu.

After install, add your wallpapers to `~/wallpapers/` and reboot!

---

## Keybindings

| Key | Action |
|-----|--------|
| `SUPER + Q` | Terminal (kitty) |
| `SUPER + E` | File manager (thunar) |
| `SUPER + SPACE` | App launcher (rofi) |
| `SUPER + ALT + SPACE` | Rofi launcher style changer |
| `SUPER + W` | Wallpaper picker (`wallSelect.sh`) |
| `SUPER + B` | Waybar style picker |
| `SUPER + ALT + B` | Reload waybar |
| `SUPER + R` | Refresh desktop (`refresh.sh`) |
| `SUPER + A` | Open notification panel (swaync) |
| `SUPER + CTRL + V` | Clipboard history (cliphist) |
| `SUPER + ;` | Emoji picker |
| `SUPER + I` | Web search |
| `SUPER + C` | Close window |
| `SUPER + F` | Fullscreen |
| `SUPER + V` | Float + center + resize to 900×600 |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + SHIFT + S` | Move window to scratchpad |
| `SUPER + arrows` | Move focus |
| `SUPER + ALT + arrows` | Resize window |
| `SUPER + Tab` | Cycle windows |
| `SUPER + 1-0` | Switch workspace |
| `SUPER + SHIFT + 1-0` | Move window to workspace |
| `SUPER + L` | Lock screen |
| `SUPER + Delete` | Suspend |
| `SUPER + M` | Exit Hyprland |
| `SUPER + SHIFT + M` | Power menu (wlogout) |
| `Print` | Screenshot (fullscreen) |
| `SUPER + Print` | Screenshot (area select) |
| `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` | Volume + OSD |
| `XF86MonBrightnessUp` / `Down` | Brightness + OSD |
| `XF86AudioNext` / `Prev` / `Play` | Media control |

---

## Matugen Color Pipeline

When you pick a wallpaper with `SUPER+W`, the following happens automatically:

```
Wallpaper selected (rofi + wallSelect.sh)
        │
        ▼
   awww sets the wallpaper
        │
        ▼
   matugenMagick.sh runs
        │
        ├──▶ matugen generates the palette from the wallpaper
        ├──▶ Waybar colors (via matugen template)
        ├──▶ Rofi colors (via matugen template)
        ├──▶ Kitty colors (via matugen template)
        ├──▶ Hyprland border colors (via matugen template)
        ├──▶ Hyprlock colors (via matugen template)
        ├──▶ Rofi background cache regenerated (ImageMagick)
        └──▶ Swaync reloaded (config + CSS)
```

Everything else besides the wallpaper picker step is handled by matugen's own template system — the config points each template at its real config file, so there's no manual copying involved.

---

## Adding Wallpapers

Drop any `.jpg`, `.jpeg`, `.png`, or `.gif` into `~/wallpapers/`, then press `SUPER+W` to open the picker. Thumbnails are cached and checksum-verified, so re-opening the picker after the first run is close to instant.

---

## Structure

```
masu-hyprland-installer/
├── install.sh
└── (clones Maty156/dotfile at install time, which provides:)
    ├── hypr/
    │   ├── hyprland.conf, hyprlock.conf, hypridle.conf
    │   ├── modules/          # keybinds, monitors, animations, window/layer rules (Lua)
    │   ├── matugen/          # matugen-hyprland.conf template output
    │   ├── hyprlock/         # hyprlock matugen colors + status scripts
    │   └── scripts/
    │       ├── wallSelect.sh       # wallpaper picker + cache
    │       ├── matugenMagick.sh    # matugen + ImageMagick + swaync reload chain
    │       ├── waybarSelect.sh     # waybar style picker
    │       ├── refresh.sh          # desktop refresh
    │       ├── wlogout.sh          # power menu launcher
    │       ├── airplaneMode.sh, backlight.sh, sounds.sh, songdetail.sh
    ├── waybar/
    ├── rofi/
    │   ├── launchers/, applets/, scripts/
    ├── matugen/
    │   ├── config.toml
    │   └── templates/        # per-app color templates
    ├── swaync/
    ├── swayosd/
    ├── kitty/
    ├── cava/
    ├── htop/
    ├── wlogout/
    └── wallpapers/
```

---

## Credits

This rice builds on top of several community Hyprland projects — full credit to their original authors. See [`CREDITS.md`](https://github.com/Maty156/dotfile/blob/main/CREDITS.md) in the config repo for the complete list (JaKooLit, HyDE, ML4W, gh0stzk, and others), plus what's original MASU work on top.

- Wallpaper daemon: [awww](https://codeberg.org/LGFae/awww)
- Color engine: [matugen](https://github.com/InioX/matugen)

---

## License

MIT — feel free to use, modify and share.
