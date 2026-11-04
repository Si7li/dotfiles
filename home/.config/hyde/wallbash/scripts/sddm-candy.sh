#!/usr/bin/env bash
# wallbash hook: give the SDDM Candy login screen the current wallpaper + colors
"$HOME/.local/share/sddm-candy-sync/sync.sh" "${cacheDir:-$HOME/.cache/hyde}/wallbash/sddm-candy.colors" >/dev/null 2>&1 &
