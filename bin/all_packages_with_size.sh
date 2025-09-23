#!/bin/bash

for pkg in $(yay -Q | awk '{print $1}'); do
    size=$(yay -Qi "$pkg" | awk -F: '/Installed Size/ {print $2}' | xargs)
    echo -e "$size\t$pkg"
done | sort -h
