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

`backup.sh` and a git pre-commit hook scan for API keys / tokens / private keys and refuse to commit if anything is found.
After cloning on a new machine, enable the hook with: `git config core.hooksPath .githooks`

## Notes for future me

- **Hyprland is pinned at 0.56.2** (`IgnorePkg` in `/etc/pacman.conf`). Hyprland 0.57 dropped the `.conf` format
  (Lua only) and HyDE's config is all `.conf`. Remove the hold once HyDE supports Lua configs.
- **HyDE scale fix**: HyDE's pickers compute the monitor scale with `sed "s/\.//"` (1.5 → 15 instead of 150),
  which blanks the theme/wallpaper picker previews at 1.5× scale. Patched to `(.scale * 100 | round)` in
  `theme.select.sh`, `wallpaper.sh`, `rofiselect.sh`, `logoutlaunch.sh`. A HyDE update may overwrite them.
- **Login screen**: SDDM uses HyDE's *Candy* theme. `~/.config/hyde/wallbash/always/sddm-candy.dcol` runs
  `sddm-candy-sync/sync.sh` on every wallpaper/theme change to copy the wallpaper + colors into Candy.
- Theme picker preview size: `[rofi.theme] scale = 4` in `config.toml`.
- Secrets live in untracked files only, never in tracked configs.
