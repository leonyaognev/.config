#!/usr/bin/env bash
set -euo pipefail

# Настройки — при необходимости поменяй
IMG=".win11.img"
IMG_SIZE="60G"
ISO="/mnt/хуйня/Win11_24H2_English_x64.iso"
TPM_DIR="/tmp/swtpm-$$"
SWTPM_LOG="/tmp/swtpm-$$.log"
CPU_SMP="6"
MEM="8G"

# Создать образ, если его нет
if [ ! -f "$IMG" ]; then
  echo "Создаю qcow2 образ $IMG (size $IMG_SIZE)..."
  qemu-img create -f qcow2 "$IMG" "$IMG_SIZE"
fi

# Поднять swtpm с TPM 2.0
mkdir -p "$TPM_DIR"
echo "Запускаю swtpm в $TPM_DIR (TPM 2.0)..."
swtpm socket \
  --tpmstate dir="$TPM_DIR" \
  --ctrl type=unixio,path="$TPM_DIR/swtpm-sock" \
  --log level=1 \
  --tpm2 &> "$SWTPM_LOG" &
SWTPM_PID=$!

# Ждём пока сокет реально появится
for i in {1..50}; do
    if [ -S "$TPM_DIR/swtpm-sock" ]; then
        break
    fi
    sleep 0.1
done

if [ ! -S "$TPM_DIR/swtpm-sock" ]; then
    echo "Ошибка: сокет TPM не создался!"
    kill $SWTPM_PID 2>/dev/null || true
    exit 1
fi

# Проверка OVMF
OVMF_CODE="/usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd"
OVMF_VARS="/home/ognev/OVMF_VARS.4m.fd" # Secure Boot-enabled

# Запуск QEMU
echo "Запускаю QEMU..."
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host,+nx,+sse4.1,+sse4.2,kvm=on \
  -smp ${CPU_SMP},sockets=1,cores=${CPU_SMP},threads=1 \
  -m ${MEM} \
  -boot d \
  -drive file="${IMG}",format=qcow2,if=virtio \
  -cdrom "${ISO}" \
  -vga qxl \
  -display sdl \
  -device virtio-keyboard-pci \
  -device virtio-mouse-pci \
  -chardev socket,id=chrtpm,path="${TPM_DIR}/swtpm-sock" \
  -tpmdev emulator,id=tpm0,chardev=chrtpm \
  -netdev user,id=net0 -device virtio-net-pci,netdev=net0 \
  -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}" \
  -drive if=pflash,format=raw,file="${OVMF_VARS}" \
  -device tpm-tis,tpmdev=tpm0

# После выхода убираем swtpm
echo "Останавливаю swtpm (pid $SWTPM_PID) и чистю $TPM_DIR..."
kill $SWTPM_PID 2>/dev/null || true
sleep 0.2
rm -rf "$TPM_DIR" || true
echo "Готово."
