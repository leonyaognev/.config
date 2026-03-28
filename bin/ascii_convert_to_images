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
ffmpeg -i "$VIDEO_FILE" "$OUTPUT_DIR/${FILENAME_PREFIX}_%05d.png"
