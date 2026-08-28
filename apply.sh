#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

GAME_DIR="/home/diablo/.local/share/Steam/steamapps/common/Gawr Gura Quest for Bread"

EXE="${1:-}"
if [ -z "$EXE" ]; then
    EXE="$GAME_DIR/ggqfb_win.exe"
fi
[ -f "$EXE" ] || { echo "не найден exe: $EXE"; echo "использование: $0 [путь/к/ggqfb_win.exe]"; exit 1; }

command -v python3 >/dev/null || { echo "нужен python3 в PATH"; exit 1; }

GPCT=godotpcktool
if [ -x "$PWD/tools/godotpcktool" ]; then
    GPCT="$PWD/tools/godotpcktool"
else
    command -v godotpcktool >/dev/null || { echo "нужен godotpcktool в PATH или tools/"; exit 1; }
fi

DIR="$(dirname "$EXE")"
BASE="$(basename "$EXE")"
WORK="$PWD/work"

echo "== 1/5 распаковка вшитого pck из exe"
rm -rf "$WORK"
mkdir -p "$WORK"
python3 tools/extract_pck.py "$EXE" "$WORK/embedded.pck"
"$GPCT" "$WORK/embedded.pck" -a e -o "$WORK/extracted" >/dev/null
cp -a "$WORK/extracted" "$WORK/pristine"

echo "== 2/5 наложение ресурсов перевода"
cp -a resources/. "$WORK/extracted/"

echo "== 3/5 сборка pck (V4, 4.7.2)"
rm -f "$WORK/new.pck"
"$GPCT" "$WORK/new.pck" -a a "$WORK/extracted" --remove-prefix "$WORK/extracted" --set-godot-version 4.7.2 >/dev/null
echo "  pck собран: $(stat -c%s "$WORK/new.pck") байт"

echo "== 4/5 вшивание в exe"
python3 tools/splice_pck.py "$EXE" "$WORK/new.pck" "$WORK/patched.exe"

echo "== 5/5 установка"
if [ ! -f "$DIR/$BASE.orig" ]; then
    cp "$EXE" "$DIR/$BASE.orig"
    echo "оригинал сохранён: $DIR/$BASE.orig"
fi
mv "$WORK/patched.exe" "$EXE"
echo "ГОТОВО: $EXE обновлён"
