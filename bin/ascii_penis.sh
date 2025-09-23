#!/bin/bash

INPUT_DIR="${1:-frames}"    # папка с кадрами (по умолчанию frames)
PREFIX="${2:-frame}"        # префикс имени (по умолчанию frame)

# Смотрим, есть ли файлы
if [ ! -d "$INPUT_DIR" ]; then
  echo "Directory '$INPUT_DIR' not found!"
  exit 1
fi

# Пробегаем по файлам, отсортированным по имени (а значит по номеру кадра)
for img in $(ls "$INPUT_DIR"/${PREFIX}_*.png | sort); do
  ascii-image-converter $img .
done
