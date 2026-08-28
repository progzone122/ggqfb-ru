# Русская локализация Gawr Gura Quest for Bread

Набор для патчинга ресурсов игры Gawr Gura Quest for Bread (Godot 4.7.2, вшитый pck в `ggqfb_win.exe`).

## Требования

- [python3](https://www.python.org/downloads/)
- [godotpcktool](https://github.com/hhyyrylainen/GodotPckTool)
- [godot](https://godotengine.org/) 4.7.x - *только для пересборки шрифтов (`tools/make_fontdata.gd`)*

## Применение патча

Найти экзешник игры автоматически в директории стима:
```shell
./apply.sh
```

Или можно можно указать путь к бинарнику вручую:
```shell
./apply.sh [/путь/к/ggqfb_win.exe]
```

## Что делает скрипт
1. Вытаскивает вшитый pck из exe (`tools/extract_pck.py`) и распаковывает в `work/extracted` (нетронутая копия будет находится в `work/pristine`),
2. Копирует поверх распаковки всё из `resources/` (переведённые файлы + шрифты),
3. Пересобирает pck (формат V4, версия 4.7.2 — обязательный флаг для godotpcktool),
4. Вшивает pck в exe (`tools/splice_pck.py`) и подменяет файл.

Оригинальный exe сохраняется один раз как `ggqfb_win.exe.orig` рядом с игрой.

## Структура

```
resources/                 - переведённые файлы (источник истины)
  dialogue_database/       - диалоги (.gdf / .txt)
  ui/                      - интерфейс (.tscn)
  mechanics_and_systems/   - UI диалогов, шляпный магазин
  globals/                 - спидран-менеджер
  .godot/imported/         - 4 заменённых шрифта (.fontdata)
assets/fonts/sources/      - исходные .ttf и лицензии OFL
tools/                     - extract_pck.py, splice_pck.py, make_fontdata.gd
apply.sh                   - патчинг exe одной командой
sync_resources.py          - перенос правок из work/extracted обратно в resources/
```

## Правка перевода
1. Запустите `./apply.sh`. Из экзешника будет вырезан pck и распакован в `work/extracted/`.
2. Правьте файлы:
   - диалоги: `work/extracted/dialogue_database/areas/*.gdf` (и `*.txt`)
   - интерфейс: `work/extracted/ui/**/*.tscn`, `mechanics_and_systems/**/*.tscn`, `globals/*.tscn`
   - имена/цвета персонажей: `dialogue_database/Characters.txt`, `Keywords.txt`
3. Синхронизируйте правки: 
    ```shell
        python3 sync_resources.py
    ```
4. Повторно пропатчите игру: 
    ```shell
        ./apply.sh
    ```

### Что нужно знать
- Ключи персонажей (`Gura:`, `Ame:` и т.д.) не трогать
- Теги `<...>`, `[color=...]` и строки `?`, `$`, `>`, `@END_OF_FILE` не трогать
- Строки `# ...` служебные. Внутри диалоговых секций комментарии не работают *(движок их не пропускает)*

## Шрифты

Заменены 4 шрифта (все - с кириллицей, лицензия OFL):

- `Jua-Regular...fontdata` → **Nunito Bold** (тема UI: меню, титры, катсцена)
- `KGRedHands...fontdata` → **Neucha** (диалоги)
- `Montserrat-Bold...fontdata` → **Nunito Bold** (Game Over, кнопка фидбека)
- `LexendDeca-Medium...fontdata` → **Nunito Medium** (загрузка, сплэш)

### Пересборка .fontdata из .ttf (нужен godot 4.7.x):

```shell
godot --headless --path . --script tools/make_fontdata.gd -- шрифт.ttf выход.fontdata
```

Результат класть в `resources/.godot/imported/` под тем же именем файла, что в игре.
Для переменных шрифтов сначала сделайте статичный инстанс: 

```shell
python3 -m fontTools.varLib.instancer шрифт.ttf wght=700 -o шрифт-bold.ttf
```

## Исправление неполадок

- Если игра обновится, изменённые разработчиком файлы перезапишутся оригиналом: правки к ним нужно наносить заново (сверить `work/pristine` со старой версией).
- Steam при проверке файлов может вернуть оригинальный exe — просто запустите `./apply.sh` ещё раз.
- Внешний `ggqfb_win.pck` рядом с exe игрой игнорируется, Godot сначала грузит вшитый pck, внешний - только если вшитый не найден.
    *(и вообще разраб оставил старую директорию с ресурсами 2024 года, лол)*
