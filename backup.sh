#!/bin/bash
# Copies the tracked configs from your system into this repo, then commits.
# Usage: ./backup.sh            -> sync + commit
#        ./backup.sh && git push
set -e
REPO="$(dirname "$(readlink -f "$0")")"
cd "$HOME"

# Paths relative to $HOME
PATHS=(
  .zshenv
  .gitconfig
  .config/zsh
  .config/hypr
  .config/hyde/config.toml
  .config/hyde/wallbash
  .config/waybar
  .config/kitty
  .config/rofi
  .config/dunst
  .config/wlogout
  .config/fastfetch
  .config/starship
  .config/Code/User/settings.json
  .config/Code/User/keybindings.json
  .config/Code/User/snippets
  .local/lib/hyde/theme.select.sh
  .local/lib/hyde/wallpaper.sh
  .local/lib/hyde/rofiselect.sh
  .local/lib/hyde/logoutlaunch.sh
  .local/share/sddm-candy-sync
)
EXCLUDES=(
  --exclude='.zsh_history*' --exclude='.zcompdump*' --exclude='*.zwc'
  --exclude='*.bak' --exclude='*secret*' --exclude='.env*'
)

existing=()
for p in "${PATHS[@]}"; do [ -e "$p" ] && existing+=("$p"); done

echo ">> Syncing configs..."
rm -rf "$REPO/home"; mkdir -p "$REPO/home"
rsync -aR "${EXCLUDES[@]}" "${existing[@]}" "$REPO/home/"

echo ">> Saving package lists and system files..."
pacman -Qqen > "$REPO/packages/pacman.txt"
pacman -Qqem > "$REPO/packages/aur.txt"
cp /etc/pacman.conf "$REPO/system/pacman.conf"

echo ">> Scanning for secrets..."
"$REPO/scan-secrets.sh" home system

cd "$REPO"
git add -A
if git diff --cached --quiet; then
  echo ">> Nothing changed."
else
  git commit -qm "backup: $(date '+%Y-%m-%d %H:%M')"
  echo ">> Committed. Run 'git push' to upload."
fi
