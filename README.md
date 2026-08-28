# Русская локализация Gawr Gura Quest for Bread

Набор для патчинга ресурсов игры Gawr Gura Quest for Bread (Godot 4.7.2, вшитый pck в `ggqfb_win.exe`).

## Требования

- [python3](https://www.python.org/downloads/)
- [godotpcktool](https://github.com/hhyyrylainen/GodotPckTool) - входит в состав набора: `tools/godotpcktool` (Linux) и `tools/godotpcktool.exe` (Windows)
- [godot](https://godotengine.org/) 4.7.x - *только для пересборки шрифтов (`tools/make_fontdata.gd`)*

## Применение патча

### Найти экзешник игры автоматически в директории стима:

#### Linux:
```shell
./apply.sh
```

#### Windows:
```shell
apply.bat
```

### Или можно можно указать путь к бинарнику вручую:**

#### Linux:
```shell
./apply.sh [/путь/к/ggqfb_win.exe]
```

#### Windows:
```bat
apply.bat "[\путь\к\ggqfb_win.exe]"
```

Требуется только установленный Python 3 (с галочкой "Add python.exe to PATH" при установке).
`godotpcktool.exe` входит в состав набора, ничего дополнительно ставить не нужно.
Если игра стоит не в `%ProgramFiles(x86)%` - передайте путь аргументом.
Скрипт создаст `ggqfb_win_patched.exe` рядом с оригиналом, не трогая его.

## Запуск через Steam
Так как файлы ресурсов вшиты в сам бинарник игры, необходимо после его патчинга указать чтобы стим запускал патченную версию, а не оригинальную.
Если этого не сделать, а просто переименовать бинарник, то любое обновление автоматически перезапишет патченную версию с переводом и вам придется постоянно патчить игру заново.

Необходимо перейти в "Свойства игры" -> "Параметры запуска" и вставить:

Windows:
```
"C:\Program Files (x86)\Steam\steamapps\common\Gawr Gura Quest for Bread\ggqfb_win_patched.exe" %command%
```

Linux:
```
bash -c 'exec "${@/ggqfb_win.exe/ggqfb_win_patched.exe}"' -- %command%
```

> ВНИМАНИЕ! После установки этого параметра запуска, версия игры при запуске у вас будет заморожена и любые обновления игры никак не будут влиять на версию, в которую вы играете.
> Для обновления просто примените патч заново.

## Что делает скрипт
1. Вытаскивает вшитый pck из exe (`tools/extract_pck.py`) и распаковывает в `work/extracted` (нетронутая копия будет находится в `work/pristine`),
2. Копирует поверх распаковки всё из `resources/` (переведённые файлы + шрифты),
3. Пересобирает pck (формат V4, версия движка 4.7.2),
4. Вшивает pck в новую копию exe (`tools/splice_pck.py`) и кладёт её рядом как `ggqfb_win_patched.exe`.

## Структура

```
resources/                 - переведённые файлы (источник истины)
  dialogue_database/       - диалоги (.gdf / .txt)
  ui/                      - интерфейс (.tscn)
  mechanics_and_systems/   - UI диалогов, шляпный магазин
  globals/                 - спидран-менеджер
  .godot/imported/         - 4 заменённых шрифта (.fontdata)
assets/fonts/sources/      - исходные .ttf и лицензии OFL
tools/                     - extract_pck.py, splice_pck.py, make_fontdata.gd, godotpcktool.exe (Windows)
apply.sh                   - патчинг exe одной командой (Linux/macOS)
apply.bat                  - патчинг exe одной командой (Windows)
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
    (Windows: `python sync_resources.py`)
4. Повторно пропатчите игру: 
    ```shell
    ./apply.sh
    ```
    (Windows: `apply.bat`)

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