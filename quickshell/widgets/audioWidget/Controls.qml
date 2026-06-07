// ============================================================================
// Controls.qml — информация о текущем треке и кнопки управления
// ============================================================================
//
// ЧТО ЭТО:
//   Нижняя панель виджета, содержащая:
//     1. Название трека и имя исполнителя
//     2. Кнопки управления: предыдущий трек, play/pause, следующий трек
//
// КАК ИСПОЛЬЗОВАТЬ:
//   Controls {
//       songTitle: mediaReader.title
//       artist: mediaReader.artist
//       isPlaying: mediaReader.playing
//       primaryColor: colors.primaryColor
//       accentColor: colors.accentColor
//       mutedColor: colors.mutedColor
//       onCommand: cmd => playerCtl.run(cmd)
//       width: parent.width
//       height: 160
//   }
//
// ЧТО МОЖНО МЕНЯТЬ:
//   - Размер и стиль текста (font.pixelSize, font.weight)
//   - Иконки кнопок (сейчас emoji: ⏮ ⏸ ▶ ⏭)
//   - Размеры кнопок (size в модели)
//   - Цвета и анимации
//   - Spacing между элементами
//   - Отступы (margins)
// ============================================================================

import QtQuick

Rectangle {
    id: root

    // ─── Входные свойства (устанавливаются из AudioWidget.qml) ──────────────
    property string songTitle: ""
    property string artist: ""
    property bool isPlaying: false
    property string primaryColor: "#80d4d5"
    property string accentColor: "#002020"
    property string mutedColor: "#0e1415"

    // ─── Сигнал для отправки команд плееру ──────────────────────────────────
    // Соединяется с PlayerCtl.run() в AudioWidget.qml
    signal command(string cmd)

    color: "transparent"

    // ─── Содержимое панели ──────────────────────────────────────────────────
    Column {
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        spacing: 20

        // ── Информация о треке ─────────────────────────────────────────────
        Column {
            width: parent.width
            spacing: 6

            // Название трека (жирный, крупный, accentColor)
            Text {
                text: root.songTitle
                font.pixelSize: 20
                font.weight: Font.Bold
                color: root.accentColor
                width: parent.width
                elide: Text.ElideRight       // Обрезается, если не влезает

                Behavior on color {
                    ColorAnimation { duration: 300 }  // Плавная смена цвета
                }
            }

            // Исполнитель (мелкий, mutedColor, полупрозрачный)
            Text {
                text: root.artist || "Unknown Artist"
                font.pixelSize: 14
                color: root.mutedColor
                width: parent.width
                elide: Text.ElideRight
                opacity: 0.7
                visible: root.artist !== ""  // Скрыт, если исполнитель неизвестен
            }
        }

        // ── Кнопки управления ──────────────────────────────────────────────
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            // Три кнопки: предыдущий, play/pause, следующий
            Repeater {
                // Модель с описанием каждой кнопки
                // Иконки: Nerd Font (Font Awesome codepoints)
                //   \uf04a — step-backward, \uf04b — play
                //   \uf04c — pause,        \uf04e — step-forward
                model: [
                    { icon: "\uf04a", cmd: "previous", size: 48 },
                    { icon: "\uf04b", cmd: "play-pause", size: 64 },
                    { icon: "\uf04e", cmd: "next", size: 48 }
                ]

                // Одна кнопка
                // Оборачиваем в Item одинаковой высоты (64px = размер самой большой кнопки),
                // чтобы все кнопки были выровнены по центру друг относительно друга
                Item {
                    width: modelData.size
                    height: 64

                    Rectangle {
                        width: modelData.size
                        height: width
                        anchors.centerIn: parent

                        // ── Цвет фона ──────────────────────────────────────
                        // Меняется при наведении/нажатии
                        color: mouseArea.pressed
                            ? Qt.darker(root.primaryColor, 1.1)
                            : mouseArea.containsMouse
                                ? root.primaryColor
                                : "transparent"
                        radius: width / 2        // Круглая кнопка

                        // Прозрачность: центральная кнопка (index===1) чуть виднее
                        opacity: mouseArea.containsMouse || mouseArea.pressed
                            ? 1.0
                            : (index === 1 ? 0.2 : 0.12)

                        // ── Анимации ───────────────────────────────────────
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }

                        // ── Пульсирующая рамка у play/pause ────────────────
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            radius: parent.radius
                            border.color: root.primaryColor
                            border.width: index === 1 ? 2 : 0
                            opacity: index === 1 ? 0.5 : 0

                            // Анимация: рамка пульсирует при воспроизведении
                            SequentialAnimation on opacity {
                                running: root.isPlaying && index === 1
                                loops: Animation.Infinite
                                NumberAnimation {
                                    to: 0.3
                                    duration: 1500
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    to: 0.5
                                    duration: 1500
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        // ── Иконка (Nerd Font) ──────────────────────────────
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: index === 1 ? 30 : 22    // play/pause крупнее
                            text: index === 1
                                ? (root.isPlaying ? "\uf04c" : "\uf04b")  // pause / play
                                : modelData.icon
                            color: mouseArea.containsMouse || mouseArea.pressed
                                ? "#0a0a0a"                          // Тёмная при наведении
                                : root.primaryColor

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                        }

                        // ── Область клика ─────────────────────────────────
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.command(modelData.cmd)   // Отправляем команду
                            }
                        }

                        // ── Анимация нажатия ───────────────────────────────
                        // Кнопка слегка уменьшается при нажатии
                        scale: mouseArea.pressed ? 0.95 : 1.0
                        Behavior on scale {
                            NumberAnimation { duration: 100 }
                        }
                    }
                }
            }
        }
    }
}
