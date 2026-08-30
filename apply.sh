#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

GAME_DIR="/home/diablo/.local/share/Steam/steamapps/common/Gawr Gura Quest for Bread"

PCK="${1:-}"
if [ -z "$PCK" ]; then
    PCK="$GAME_DIR/ggqfb_win.pck"
fi
[ -f "$PCK" ] || { echo "pck not found: $PCK"; echo "usage: $0 [/path/to/ggqfb_win.pck]"; exit 1; }

GPCT=godotpcktool
if [ -x "$PWD/tools/godotpcktool" ]; then
    GPCT="$PWD/tools/godotpcktool"
else
    command -v godotpcktool >/dev/null || { echo "godotpcktool is required in PATH or tools/"; exit 1; }
fi

WORK="$PWD/work"

echo "== 1/4 unpack base pck"
rm -rf "$WORK"
mkdir -p "$WORK"
"$GPCT" "$PCK" -a e -o "$WORK/extracted" >/dev/null
cp -a "$WORK/extracted" "$WORK/pristine"

echo "== 2/4 overlay translation resources"
cp -a resources/. "$WORK/extracted/"

echo "== 3/4 build pck (V4, 4.7.2)"
rm -f "$WORK/new.pck"
"$GPCT" "$WORK/new.pck" -a a "$WORK/extracted" --remove-prefix "$WORK/extracted" --set-godot-version 4.7.2 >/dev/null
echo "  pck built: $(stat -c%s "$WORK/new.pck") bytes"

echo "== 4/4 install"
if [ ! -f "$PCK.orig" ]; then
    cp "$PCK" "$PCK.orig"
    echo "  original pck saved: $PCK.orig"
fi
cp "$WORK/new.pck" "$PCK"
echo "DONE: $PCK"
