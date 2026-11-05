#!/bin/bash
# Reinstalls every theme in themes.lst (downloads ~1 GB), puts your own wallpapers
# back, rebuilds HyDE's wallpaper cache and re-selects your theme.
# Needs HyDE cloned at ~/HyDE.   Usage: ./install-themes.sh [--dry-run]
set -e
REPO="$(dirname "$(readlink -f "$0")")"
HYDE_SCRIPTS="${HYDE_SCRIPTS:-$HOME/HyDE/Scripts}"
HYDE_LIB="$HOME/.local/lib/hyde"
THEMES="$HOME/.config/hyde/themes"
DRY=0; [ "$1" = "--dry-run" ] && DRY=1
run() { if [ $DRY -eq 1 ]; then echo "   [dry-run] $*"; else "$@"; fi; }

[ -x "$HYDE_SCRIPTS/restore_thm.sh" ] || { echo "HyDE not found at ~/HyDE. Clone it first."; exit 1; }

echo ">> Installing $(grep -c . "$REPO/themes.lst") themes with HyDE's theme installer..."
flg_DryRun=$DRY "$HYDE_SCRIPTS/restore_thm.sh" "$REPO/themes.lst"

echo ">> Restoring your own wallpapers..."
for d in "$REPO"/wallpapers/*/; do
  [ -d "$d" ] || continue
  t=$(basename "$d")
  echo "   $t: $(ls "$d" | wc -l) wallpapers"
  run mkdir -p "$THEMES/$t/wallpapers"
  run cp -rp "$d." "$THEMES/$t/wallpapers/"
done

echo ">> Building wallpaper cache (thumbnails + colors), this takes a while..."
while IFS='"' read -r _ t _; do
  [ -n "$t" ] && run "$HYDE_LIB/swwwallcache.sh" -t "$t"
done < "$REPO/themes.lst"

# shellcheck disable=SC1091
source "$REPO/state/current-theme"
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && [ -n "$THEME" ]; then
  echo ">> Switching to $THEME${WALLPAPER:+ / $WALLPAPER}..."
  run "$HYDE_LIB/theme.switch.sh" -s "$THEME"
  [ -n "$WALLPAPER" ] && [ -f "$THEMES/$THEME/wallpapers/$WALLPAPER" ] && \
    run "$HYDE_LIB/wallpaper.sh" -s "$THEMES/$THEME/wallpapers/$WALLPAPER" --global
else
  echo ">> Log into Hyprland and pick \"$THEME\" with Super+Shift+T."
fi
echo ">> Done."
