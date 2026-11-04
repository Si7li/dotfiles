#!/bin/bash
# Copies the configs from this repo back into $HOME.
# Any file it would overwrite is kept as <file>.pre-restore
set -e
REPO="$(dirname "$(readlink -f "$0")")"
echo "This will copy configs from $REPO/home into $HOME (overwritten files are kept as *.pre-restore)."
read -rp "Continue? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]] || exit 0
rsync -a --backup --suffix=.pre-restore "$REPO/home/" "$HOME/"
echo ">> Configs restored."
echo
echo "Next steps (run yourself):"
echo "  sudo pacman -S --needed - < $REPO/packages/pacman.txt"
echo "  yay -S --needed - < $REPO/packages/aur.txt"
echo "  Compare $REPO/system/pacman.conf with /etc/pacman.conf (IgnorePkg line)"
echo "  ~/.local/share/sddm-candy-sync/sync.sh     # login screen wallpaper"
