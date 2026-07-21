----- КЛАВИША МОДИФИКАТОР ------------------------------------------------------
local mainMod = "SUPER"

----- ЗАПУСК ПРИЛОЖЕНИЙ --------------------------------------------------------
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("hyprpicker --autocopy"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/bin/wallpaper"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("wallpaper --pick"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/bin/wifimenu"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("Telegram"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd("zen-browser"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd("steam"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("kitty spotify_player"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("discord"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("blueman-manager"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("sh ~/bin/wifi"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("catgirldownloader"))

----- ХОТКЕИ -------------------------------------------------------------------
hl.bind("CTRL + SHIFT + Q", hl.dsp.exit())
hl.bind("CTRL + SHIFT + Q", hl.dsp.exec_cmd("killall hyprland-loop"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + G", hl.dsp.layout("swapsplit"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.window.resize({ x = 1100, y = 800 }))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("hyprctl keyword general:layout dwindle"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprctl keyword general:layout master"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("hyprctl keyword general:layout scrolling"))

hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("poweroff"))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("reboot"))

----- ПЕРЕКЛЮЧЕНИЕ ФОКУСА ------------------------------------------------------
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

----- ПЕРЕКЛЮЧЕНИЕ ВОРКСПЕЙСОВ -------------------------------------------------
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

----- ПЕРЕМЕЩЕНИЕ ОКОН НА ДРУГОЙ ВОРКСПЕЙС -------------------------------------
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

----- ПЕРЕХОД ПО ВОРКСПЕЙСАМ КОЛЕСОМ МЫШИ --------------------------------------
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

----- ПЕРЕМЕЩЕНИЕ И РЕСАЙЗ ОКОН МЫШЬЮ ------------------------------------------
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

----- РЕСАЙЗ -------------------------------------------------------------------
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ x = -50, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ x = 50, y = 0, relative = true }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ x = 0, y = -50, relative = true }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ x = 0, y = 50, relative = true }))

hl.bind("SUPER + SHIFT + H", hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.swap({ direction = "d" }))
