# Русская локализация Gawr Gura Quest for Bread

Набор для патчинга ресурсов игры Gawr Gura Quest for Bread (Godot 4.7.2, ресурсы игры в отдельном `ggqfb_win.pck`).

## Требования

- [python3](https://www.python.org/downloads/) - только для `sync_resources.py`
- `godotpcktool` - входит в состав набора: `tools/godotpcktool` (Linux) и `tools/godotpcktool.exe` (Windows)
- [godot](https://godotengine.org/) 4.7.x - *только для пересборки шрифтов (`tools/make_fontdata.gd`)*

## Применение патча

Скрипт найдёт `ggqfb_win.pck` игры автоматически в директории Steam:

#### Linux:
```shell
./apply.sh
```

#### Windows:
```bat
apply.bat
```

Или путь к pck можно указать вручную:

#### Linux:
```shell
./apply.sh [/путь/к/ggqfb_win.pck]
```

#### Windows:
```bat
apply.bat "C:\путь\к\ggqfb_win.pck"
```

Скрипт собирает полный pck с переводом и кладёт его на место `ggqfb_win.pck` (оригинал один раз сохраняется как `ggqfb_win.pck.orig`).

## Что делает скрипт
1. Распаковывает базовый `ggqfb_win.pck` в `work/extracted` (нетронутая копия будет находится в `work/pristine`),
2. Копирует поверх распаковки всё из `resources/` (переведённые файлы + шрифты),
3. Пересобирает полный pck (формат V4, версия движка 4.7.2),
4. Заменяет файл `ggqfb_win.pck` модифицированной копией.

## Структура

```
resources/                 - переведённые файлы (источник истины)
  dialogue_database/       - диалоги (.gdf / .txt)
  ui/                      - интерфейс (.tscn)
  mechanics_and_systems/   - UI диалогов, шляпный магазин
  globals/                 - спидран-менеджер
  .godot/imported/         - 4 заменённых шрифта (.fontdata)
assets/fonts/sources/      - исходные .ttf и лицензии OFL
tools/                     - make_fontdata.gd, godotpcktool (Linux) и godotpcktool.exe (Windows)
apply.sh                   - сборка pck одной командой (Linux/macOS)
apply.bat                  - сборка pck одной командой (Windows)
sync_resources.py          - перенос правок из work/extracted обратно в resources/
```

## Правка перевода
1. Запустите `./apply.sh` - базовый pck будет распакован в `work/extracted/`.
2. Правьте файлы:
   - диалоги: `work/extracted/dialogue_database/areas/*.gdf` (и `*.txt`)
   - интерфейс: `work/extracted/ui/**/*.tscn`, `mechanics_and_systems/**/*.tscn`, `globals/*.tscn`
   - имена/цвета персонажей: `dialogue_database/Characters.txt`, `Keywords.txt`
3. Синхронизируйте правки: 
    ```shell
    python3 sync_resources.py
    ```
    (Windows: `python sync_resources.py`)
4. Повторно соберите pck: 
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

## Troubleshooting

- Steam при проверке/обновлении файлов может вернуть оригинальный `ggqfb_win.pck` - просто запустите `./apply.sh` ещё раз (оригинал лежит в `ggqfb_win.pck.orig`).
- Если игра обновится и разработчик изменил файлы, которые мы правим - правки к ним нужно наносить заново (сверить `work/pristine` со старой версией).
