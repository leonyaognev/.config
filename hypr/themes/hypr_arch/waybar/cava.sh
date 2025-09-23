#!/bin/bash

[[ -p /tmp/cava_fifo ]] || mkfifo /tmp/cava_fifo
pgrep cava >/dev/null || cava -p ~/.config/cava/config &

while read -r line; do
    bars=$(echo "$line" | tr ' ' '\n' | awk '{for(i=0;i<$1/4;i++) printf "█"; printf " "}')
    bars=$(printf "%-25s" "$bars")  # Выравнивание до 25 символов
    echo "{\"text\":\"$bars\",\"tooltip\":\"Cava Visualizer\"}"
done < /tmp/cava_fifo
