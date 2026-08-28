#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

GAME_DIR="/home/diablo/.local/share/Steam/steamapps/common/Gawr Gura Quest for Bread"

EXE="${1:-}"
if [ -z "$EXE" ]; then
    EXE="$GAME_DIR/ggqfb_win.exe"
fi
[ -f "$EXE" ] || { echo "exe not found: $EXE"; echo "usage: $0 [/path/to/ggqfb_win.exe] [out.pck]"; exit 1; }
OUT="${2:-$GAME_DIR/ggqfb_ru.pck}"

command -v python3 >/dev/null || { echo "python3 is required in PATH"; exit 1; }

GPCT=godotpcktool
if [ -x "$PWD/tools/godotpcktool" ]; then
    GPCT="$PWD/tools/godotpcktool"
else
    command -v godotpcktool >/dev/null || { echo "godotpcktool is required in PATH or tools/"; exit 1; }
fi

WORK="$PWD/work"

echo "== 1/4 unpack embedded pck from exe"
rm -rf "$WORK"
mkdir -p "$WORK"
python3 tools/extract_pck.py "$EXE" "$WORK/embedded.pck"
"$GPCT" "$WORK/embedded.pck" -a e -o "$WORK/extracted" >/dev/null
cp -a "$WORK/extracted" "$WORK/pristine"

echo "== 2/4 overlay translation resources"
cp -a resources/. "$WORK/extracted/"

echo "== 3/4 build pck (V4, 4.7.2)"
rm -f "$WORK/new.pck"
"$GPCT" "$WORK/new.pck" -a a "$WORK/extracted" --remove-prefix "$WORK/extracted" --set-godot-version 4.7.2 >/dev/null

echo "== 4/4 write pck"
mkdir -p "$(dirname "$OUT")"
cp "$WORK/new.pck" "$OUT"
echo "DONE: $OUT"
