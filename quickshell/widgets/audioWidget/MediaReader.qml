// ============================================================================
// MediaReader.qml — чтение метаданных текущего трека через playerctl
// ============================================================================
//
// ЧТО ЭТО:
//   Каждые 500 мс запускает playerctl metadata и парсит результат:
//     - Название трека (title)
//     - Исполнитель (artist)
//     - Текущая позиция (position)
//     - Длина трека (length)
//     - Статус (playing/paused)
//
// КАК ИСПОЛЬЗОВАТЬ:
//   MediaReader {
//       id: reader
//   }
//   // Доступны: reader.title, reader.artist, reader.position,
//   //           reader.length, reader.playing
//
// ЧТО МОЖНО МЕНЯТЬ:
//   - Частоту опроса (timer.interval)
//   - Формат вывода playerctl (command)
//   - Разделитель полей (сейчас '|')
// ============================================================================

import QtQuick
import Quickshell.Io

Item {
    id: root

    // ─── Свойства (читаются из Controls.qml) ────────────────────────────────
    property string title: ""            // Название текущего трека
    property string artist: ""           // Исполнитель
    property real position: 0            // Текущая позиция в секундах
    property real length: 100            // Длина трека в секундах
    property bool playing: false         // True — воспроизводится, False — на паузе

    // ─── Процесс для получения метаданных ───────────────────────────────────
    // Запускает playerctl metadata с кастомным форматом вывода
    Process {
        id: mediaProcess

        // Формат: каждое поле разделено '|'
        // {{title}} — название трека
        // {{artist}} — исполнитель
        // {{position}} — позиция в микросекундах
        // {{mpris:length}} — длина в микросекундах
        // {{status}} — "Playing" или "Paused"
        command: [
            "playerctl", "metadata",
            "--format", "{{title}}|{{artist}}|{{position}}|{{mpris:length}}|{{status}}"
        ]
        running: false                    // Запускается по таймеру

        // Буфер для результата
        property string output: ""

        // ── Парсинг stdout ──────────────────────────────────────────────
        stdout: SplitParser {
            onRead: data => {
                mediaProcess.output = data.trim()
            }
        }

        // ── Обработка завершения ────────────────────────────────────────
        // Когда процесс завершился и output не пустой — парсим результат
        onRunningChanged: {
            if (!running && output) {
                const parts = output.split('|')

                if (parts.length >= 5) {
                    root.title = parts[0] || "Unknown"
                    root.artist = parts[1] || "Unknown Artist"
                    root.position = parseInt(parts[2]) / 1000000 || 0     // мкс → сек
                    root.length = parseInt(parts[3]) / 1000000 || 100     // мкс → сек
                    root.playing = parts[4] === "Playing"
                }

                // Очищаем буфер для следующего запуска
                output = ""
            }
        }
    }

    // ─── Таймер опроса ──────────────────────────────────────────────────────
    // Каждые 500 мс запрашивает свежие метаданные
    Timer {
        id: pollTimer
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true            // Сразу запускаем при старте

        onTriggered: {
            mediaProcess.running = true   // Запускаем playerctl metadata
        }
    }
}
