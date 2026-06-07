// ============================================================================
// AudioWidget.qml (entry point) — окно аудио-виджета
// ============================================================================
//
// ЭТОТ ФАЙЛ — ТОЛЬКО Entry Point.
// Вся логика и UI разнесены по файлам в папке audiowidget/:
//
//   audiowidget/CavaReader.qml    — чтение аудио-спектра из Cava
//   audiowidget/MediaReader.qml   — чтение метаданных трека (playerctl)
//   audiowidget/PlayerCtl.qml     — отправка команд плееру (playerctl)
//   audiowidget/Visualizer.qml    — отрисовка полосок визуализатора
//   audiowidget/Controls.qml      — информация о треке и кнопки
//
// КАК ЭТО РАБОТАЕТ:
//   1. CavaReader запускает cava и выдаёт массив bars (50 чисел 0.05..1.0)
//   2. MediaReader каждые 500ms опрашивает playerctl и выдаёт метаданные
//   3. Visualizer рисует полоски, используя bars и цвета из Colors
//   4. Controls показывает название трека и кнопки, отправляет команды
//   5. PlayerCtl выполняет команды play-pause/next/previous
//
// ЧТО МОЖНО МЕНЯТЬ:
//   - Размер окна (implicitWidth / implicitHeight)
//   - Позицию на экране (anchors / margins)
//   - Цвета (через Colors.qml в папке widgets/)
// ============================================================================

import Quickshell
import Quickshell.Wayland
import QtQuick
import "."          // Для доступа к Colors.qml
import "audioWidget" // Для доступа к декомпозированным компонентам

PanelWindow {
    id: root

    // ─── Настройки окна ─────────────────────────────────────────────────────
    implicitWidth: 1000
    implicitHeight: 420
    visible: true
    color: "transparent"
    mask: Region { item: container }     // Окно принимает форму container

    // Позиционирование через Wayland Layer Shell
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-audio"

    anchors {
        bottom: true
        left: true
    }
    margins {
        bottom: 10
        left: 10
    }

    // ─── Цветовая палитра ───────────────────────────────────────────────────
    // Цвета генерируются автоматически через matugen (Material You)
    // Файл: widgets/Colors.qml
    Colors {
        id: colors
    }

    // ─── Дочерние компоненты (невидимые, логические) ───────────────────────

    // Чтение аудио-спектра из Cava
    CavaReader {
        id: cavaReader
    }

    // Чтение метаданных текущего трека
    MediaReader {
        id: mediaReader
    }

    // Отправка команд плееру
    PlayerCtl {
        id: playerCtl
    }

    // ─── UI: контейнер для всего видимого содержимого ───────────────────────

    Rectangle {
        id: container
        anchors.fill: parent
        color: "transparent"

        Column {
            anchors.fill: parent
            spacing: 0

            // Верхняя часть: визуализатор (полоски)
            Visualizer {
                width: parent.width
                height: 260
                bars: cavaReader.bars
                primaryColor: colors.primaryColor
                isPlaying: mediaReader.playing
            }

            // Нижняя часть: информация о треке + кнопки
            Controls {
                width: parent.width
                height: 160
                songTitle: mediaReader.title
                artist: mediaReader.artist
                isPlaying: mediaReader.playing
                primaryColor: colors.primaryColor
                accentColor: colors.accentColor
                mutedColor: colors.mutedColor

                // Сигнал command привязываем к PlayerCtl.run()
                onCommand: cmd => playerCtl.run(cmd)
            }
        }
    }
}
