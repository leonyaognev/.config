// ============================================================================
// CavaReader.qml — чтение данных из Cava (аудио-визуализатор)
// ============================================================================
//
// ЧТО ЭТО:
//   Cava анализирует звук с системы (микрофон/выход) и выводит амплитуды
//   частот в виде чисел от 0 до 255. Мы запускаем cava в raw-режиме,
//   читаем его stdout, парсим числа и превращаем в массив bars[].
//
//   Визуализатор (Visualizer.qml) подписывается на свойство bars и рисует
//   столбики соответствующей высоты.
//
// КАК ИСПОЛЬЗОВАТЬ:
//   CavaReader {
//       id: reader
//   }
//   // Массив из 50 чисел (0.05 .. 1.0) доступен в reader.bars
//
// ЧТО МОЖНО МЕНЯТЬ:
//   - Количество полосок (цифра 50 в Component.onCompleted и в onRead)
//   - Конфиг cava (путь в command)
//   - Интервал перезапуска (restartTimer.interval)
//   - Формулу нормализации (val / 100 — сейчас)
// ============================================================================

import QtQuick
import Quickshell.Io

Item {
    id: root

    // ─── Свойства ───────────────────────────────────────────────────────────
    // Массив из 50 значений (0.05 .. 1.0) — относительная высота каждой полоски.
    // Внешние компоненты читают это свойство для отрисовки.
    property var bars: []

    // ─── Инициализация ──────────────────────────────────────────────────────
    Component.onCompleted: {
        let initial = []
        for (let i = 0; i < 50; i++) {
            initial.push(0.05)       // минимальная высота, чтобы полоски были видны
        }
        root.bars = initial
    }

    // ─── Процесс Cava ───────────────────────────────────────────────────────
    // Запускает cava в raw-режиме и построчно читает его вывод.
    Process {
        id: cavaProcess

        // Команда: cava -p <конфиг> 2>/dev/null
        // Пайп через while read нужен, чтобы гарантировать построчный вывод
        command: [
            "sh", "-c",
            "cava -p ~/.config/cava/config_widget 2>/dev/null | while IFS= read -r line; do echo \"$line\"; done"
        ]
        running: true                 // запускается автоматически

        // Счётчик обработанных строк — для отладки в логах
        property int lineCount: 0

        // ── Парсинг stdout ──────────────────────────────────────────────
        // Cava выдаёт строки вида: "12;45;78;0;...;120"
        // Числа разделены ';', строки разделены '\n'
        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                cavaProcess.lineCount++

                // Разделяем строку по ';' и получаем массив строк-чисел
                const values = data.trim().split(';')

                if (values.length > 0) {
                    let newBars = []

                    // Преобразуем каждое значение в число 0.05..1.0
                    for (let i = 0; i < 50; i++) {
                        if (i < values.length && values[i] !== '') {
                            const val = parseInt(values[i])
                            if (!isNaN(val)) {
                                // Cava выдаёт 0-255, нормализуем до 0.05-1.0
                                const normalized = Math.min(Math.max(val / 100, 0.05), 1.0)
                                newBars.push(normalized)
                            } else {
                                newBars.push(0.05)    // Если число не спарсилось
                            }
                        } else {
                            newBars.push(0.05)        // Если cava не выдала значение
                        }
                    }

                    // Обновляем массив — Visualizer подхватит изменения автоматически
                    root.bars = newBars
                }
            }
        }

        // ── stderr ───────────────────────────────────────────────────────
        // Логируем ошибки cava для отладки
        stderr: SplitParser {
            onRead: data => {
                console.log("CavaReader stderr:", data)
            }
        }

        // ── Обработка остановки cava ─────────────────────────────────────
        // Если cava упала (нет звукового выхода, ошибка), перезапускаем
        onRunningChanged: {
            if (!running) {
                console.log("CavaReader: Cava stopped (" + lineCount + " lines processed), restarting in 3s...")
                lineCount = 0
                restartTimer.start()
            }
        }
    }

    // ─── Таймер перезапуска ─────────────────────────────────────────────────
    // Если cava упала — ждём 3 секунды и запускаем снова
    Timer {
        id: restartTimer
        interval: 3000
        running: false
        repeat: false

        onTriggered: {
            console.log("CavaReader: Restarting cava...")
            cavaProcess.running = true
        }
    }
}
