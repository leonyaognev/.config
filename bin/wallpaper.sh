#!/bin/sh

wall_dir="$HOME/Images/walpaper/"
cache_file="$HOME/.current_wall"

# если передан аргумент — используем его, иначе выбираем рандом
if [ -n "$1" ] && [ -f "$1" ]; then
    wall="$1"
else
    files=$(find "$wall_dir" -maxdepth 1 -type f)
    [ -z "$files" ] && { echo "Файлов нет, дружище." ; exit 1; }

    files_array=()
    while IFS= read -r line; do
      files_array+=("$line")
    done <<EOF
$files
EOF

    count=${#files_array[@]}
    rand_index=$((RANDOM % count))
    wall=${files_array[$rand_index]}
fi

# сохраняем путь в файл
echo "$wall" > "$cache_file"

# копирование для разных штук
cp "$wall" ~/Images/paper/wallpaper.jpg
cp "$wall" ~/.mozilla/firefox/bgnqulea.default-release/chrome/wallpaper.jpg

# магия с обоями
matugen image ~/Images/paper/wallpaper.jpg
swww img --transition-type any --transition-duration 0.5 --transition-fps 165 "$wall"
wal -n -i "$wall"
wal-telegram "$wall"
~/bin/mako-colors

killall swaync
notify-send "Wallpaper successfully set"
