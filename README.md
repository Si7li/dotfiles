# dotfiles

My Arch Linux + [HyDE](https://github.com/HyDE-Project/HyDE) (Hyprland) setup.

![wm](https://img.shields.io/badge/WM-Hyprland-58E1FF) ![distro](https://img.shields.io/badge/OS-Arch_Linux-1793D1) ![keyboard](https://img.shields.io/badge/layout-AZERTY_(fr)-lightgrey)

## What's inside

| Path | What |
|---|---|
| `home/.config/hypr/` | Hyprland: keybinds, monitors, window rules, hyprlock, `kb_layout = fr` |
| `home/.config/hyde/` | HyDE `config.toml` + wallbash hooks |
| `home/.config/{waybar,kitty,rofi,dunst,wlogout,fastfetch,starship}/` | bar, terminal, menus, notifications, logout menu |
| `home/.config/zsh/`, `home/.zshenv` | shell |
| `home/.config/Code/User/` | VS Code settings + snippets |
| `home/.local/lib/hyde/` | HyDE scripts with my scale fix (see below) |
| `home/.local/share/sddm-candy-sync/` | makes the SDDM login screen follow the current wallpaper |
| `packages/` | `pacman.txt` (repo packages), `aur.txt` (AUR packages) |
| `system/pacman.conf` | includes the Hyprland `IgnorePkg` hold |

Wallpapers/themes are **not** included (they come with HyDE).

## Usage

```bash
./backup.sh && git push     # save current configs
./restore.sh                # put them back (keeps *.pre-restore copies)
```
