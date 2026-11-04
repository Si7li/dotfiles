#!/bin/bash
# Makes the SDDM "Candy" login screen use the current HyDE wallpaper (+ wallbash colors).
# Runs automatically on every HyDE wallpaper/theme change via
#   ~/.config/hyde/wallbash/always/sddm-candy.dcol
# Usage: sync.sh [wallbash-generated colors file]
# Undo: cp /usr/share/sddm/themes/Candy/theme.conf.orig /usr/share/sddm/themes/Candy/theme.conf
set -e
CANDY=/usr/share/sddm/themes/Candy
CONF="$CANDY/theme.conf"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/hyde"
[ -w "$CONF" ] || { echo "sddm-candy-sync: $CONF not writable" >&2; exit 0; }

# --- wallpaper (only re-encode when it changed) ---
WALL=$(readlink -f "$CACHE/wall.set" 2>/dev/null || true)
[ -f "$WALL" ] || WALL="$CACHE/wall.set.png"
STAMP="$WALL|$(stat -c %Y "$WALL" 2>/dev/null)"
if [ "$(cat "$CANDY/backgrounds/.hyde-stamp" 2>/dev/null)" != "$STAMP" ] || [ ! -f "$CANDY/backgrounds/hyde-current.jpg" ]; then
  TMP=$(mktemp --suffix=.jpg)
  magick "${WALL}[0]" -resize '2560x1440>' -quality 92 "$TMP"
  install -m 644 "$TMP" "$CANDY/backgrounds/hyde-current.jpg"; rm -f "$TMP"
  echo "$STAMP" > "$CANDY/backgrounds/.hyde-stamp"
fi
sed -i 's|^Background=.*|Background="backgrounds/hyde-current.jpg"|; s|^BackgroundS=.*|BackgroundS="backgrounds/hyde-current.jpg"|' "$CONF"

# --- colors (from wallbash, if the generated file was passed) ---
if [ -n "$1" ] && [ -f "$1" ]; then
  accent=$(sed -n 's/^accent=\([0-9A-Fa-f]\{6\}\)$/#\1/p' "$1")
  bg=$(sed -n 's/^bg=\([0-9A-Fa-f]\{6\}\)$/#\1/p' "$1")
  main=$(sed -n 's/^main=\([0-9A-Fa-f]\{6\}\)$/#\1/p' "$1")
  [ -n "$accent" ] && sed -i "s|^AccentColor=.*|AccentColor=\"$accent\"|" "$CONF"
  [ -n "$bg" ]     && sed -i "s|^BackgroundColor=.*|BackgroundColor=\"$bg\"|" "$CONF"
  [ -n "$main" ]   && sed -i "s|^MainColor=.*|MainColor=\"$main\"|" "$CONF"
fi
echo "sddm-candy-sync: $(basename "$WALL")"
