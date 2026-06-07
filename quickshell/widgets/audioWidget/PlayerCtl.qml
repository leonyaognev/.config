// ============================================================================
// PlayerCtl.qml — отправка команд плееру через playerctl
// ============================================================================
//
// ЧТО ЭТО:
//   Простая обёртка над playerctl для выполнения команд:
//     - play-pause
//     - next
//     - previous
//     (и любых других, которые поддерживает playerctl)
//
// КАК ИСПОЛЬЗОВАТЬ:
//   PlayerCtl {
//       id: ctl
//   }
//   ctl.run("play-pause")    // поставить на паузу / продолжить
//   ctl.run("next")          // следующий трек
//   ctl.run("previous")      // предыдущий трек
//
// ЧТО МОЖНО МЕНЯТЬ:
//   - Ничего, это просто обёртка. Всё настраивается через команды playerctl.
// ============================================================================

import QtQuick
import Quickshell.Io

Item {
    id: root

    // ─── Процесс для выполнения команд playerctl ────────────────────────────
    Process {
        id: playerctlProcess
        running: false                      // Запускается только по запросу
    }

    // ─── Публичный метод ────────────────────────────────────────────────────
    // Выполняет команду playerctl (например, "play-pause", "next", "previous")
    function run(command) {
        console.log("PlayerCtl: executing 'playerctl " + command + "'")
        playerctlProcess.command = ["playerctl", command]
        playerctlProcess.running = true
    }
}
