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

echo ">> Saving theme list, your own wallpapers and current theme..."
THEMES="$HOME/.config/hyde/themes"
# themes.lst: "Name" "download link" for every installed theme (HyDE themepatcher format)
python3 - "$THEMES" "$REPO/themes.lst" <<'PY'
import json, os, re, sys
themes, out = sys.argv[1], sys.argv[2]
pat = re.compile(r'\s*"([^"]+)"\s+"([^"]+)"')
def read_lst(path):
    return dict(m.groups() for l in open(path) if (m := pat.match(l))) if os.path.exists(path) else {}
links = {}
gallery = os.path.expanduser('~/.cache/hyde/gallery-database/hyde-themes.json')
if os.path.exists(gallery):
    links.update({x['THEME']: x['LINK'] for x in json.load(open(gallery))})
links.update(read_lst(os.path.expanduser('~/HyDE/Scripts/themepatcher.lst')))
links.update(read_lst(out))  # links already in the repo win
rows, missing = [], []
for t in sorted(os.listdir(themes)):
    if os.path.isdir(os.path.join(themes, t)):
        (rows.append(f'"{t}" "{links[t]}"') if t in links else missing.append(t))
open(out, 'w').write('\n'.join(rows) + '\n')
for t in missing:
    print(f'   !! no download link known for theme "{t}" - it will NOT be restorable')
PY

# wallpapers/: only wallpapers you added yourself (added >1 day after the theme was
# installed), plus any already saved in the repo. Theme wallpapers are re-downloaded.
WREPO="$REPO/wallpapers"; mkdir -p "$WREPO"
for tdir in "$THEMES"/*/; do
  t=$(basename "$tdir"); [ -f "$tdir/hypr.theme" ] || continue
  base=$(stat -c %Y "$tdir/hypr.theme")
  while IFS= read -r -d '' f; do
    name=$(basename "$f")
    if [ "$(stat -c %Y "$f")" -gt $((base + 86400)) ] || [ -e "$WREPO/$t/$name" ]; then
      if [ "$(stat -c %s "$f")" -gt 95000000 ]; then
        echo "   !! skipping $t/$name (over GitHub's 100 MB limit)"; continue
      fi
      mkdir -p "$WREPO/$t"; cp -p "$f" "$WREPO/$t/$name"
    fi
  done < <(find "$tdir/wallpapers" -maxdepth 1 -type f -print0 2>/dev/null)
done
# forget wallpapers you deleted from your system
find "$WREPO" -mindepth 2 -type f -print0 | while IFS= read -r -d '' f; do
  [ -e "$THEMES/$(basename "$(dirname "$f")")/wallpapers/$(basename "$f")" ] || rm -f "$f"
done
find "$WREPO" -mindepth 1 -type d -empty -delete

# state/current-theme: the theme + wallpaper you're using now
mkdir -p "$REPO/state"
theme=$(sed -n 's/^HYDE_THEME="\(.*\)"$/\1/p' "$HOME/.local/state/hyde/staterc")
wall=$(basename "$(readlink "$THEMES/$theme/wall.set" 2>/dev/null)")
printf 'THEME="%s"\nWALLPAPER="%s"\n' "$theme" "$wall" > "$REPO/state/current-theme"

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
