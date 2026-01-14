#!/bin/bash

# Проверка аргументов
if [ $# -lt 1 ]; then
  echo "Usage: $0 <video_file> [output_dir] [filename_prefix]"
  exit 1
fi

VIDEO_FILE="$1"
OUTPUT_DIR="${2:-frames}"
FILENAME_PREFIX="${3:-frame}"

# Создаём папку, если её нет
mkdir -p "$OUTPUT_DIR"

# Разбиваем видео на кадры
echo "[*] Extracting frames from video '$VIDEO_FILE'..."
ffmpeg -loglevel error -i "$VIDEO_FILE" "$OUTPUT_DIR/${FILENAME_PREFIX}_%05d.png"

echo "[*] Frames saved to '$OUTPUT_DIR'. Now converting to ASCII..."

# Проверка, что кадры есть
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Directory '$OUTPUT_DIR' not found!"
  exit 1
fi

# Проходим по кадрам
for img in $(ls "$OUTPUT_DIR"/${FILENAME_PREFIX}_*.png | sort); do
  clear # Очищаем терминал перед каждым кадром
  ascii-image-converter "$img" . # точка означает вывод в терминал
  sleep 0.05 # Задержка между кадрами, можно подкрутить
done
