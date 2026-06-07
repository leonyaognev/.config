// ============================================================================
// Visualizer.qml — отрисовка полосок аудио-визуализатора
// ============================================================================
//
// ЧТО ЭТО:
//   50 анимированных прямоугольников (полосок), высота которых меняется
//   в соответствии с частотным спектром звука.
//   Полоски имеют градиентную заливку и анимацию высоты.
//
// КАК ИСПОЛЬЗОВАТЬ:
//   Visualizer {
//       bars: cavaReader.bars              // массив из 50 чисел 0.05..1.0
//       primaryColor: "#80d4d5"            // основной цвет (из Colors)
//       isPlaying: mediaReader.playing     // true — анимация активна
//       width: parent.width
//       height: 260
//   }
//
// ЧТО МОЖНО МЕНЯТЬ:
//   - Количество полосок (model в Repeater, spacing, расчёт ширины)
//   - Высоту зоны визуализатора (height)
//   - Цвета градиента (GradientStop)
//   - Скорость анимации (Behavior on height — duration)
//   - Радиус скругления полосок (radius)
//   - Прозрачность (opacity)
// ============================================================================

import QtQuick

Rectangle {
    id: root

    // ─── Входные свойства (устанавливаются из AudioWidget.qml) ──────────────
    property var bars: []                  // Массив высот полосок от CavaReader
    property string primaryColor: "#80d4d5" // Основной цвет градиента
    property bool isPlaying: false         // Флаг воспроизведения

    // Настройки внешнего вида (можно менять)
    color: "transparent"

    // ─── Визуализатор ───────────────────────────────────────────────────────
    // Горизонтальный ряд полосок, выровненных по нижнему краю
    Row {
        // Отступы от краёв контейнера
        width: parent.width - 50
        height: parent.height - 50
        spacing: 3                         // Расстояние между полосками
        anchors.centerIn: parent
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 25

        // Создаём 50 полосок (по количеству элементов в bars)
        Repeater {
            model: root.bars

            // Одна полоска визуализатора
            Rectangle {
                // Ширина = (ширина ряда - все промежутки) / количество полосок
                width: (parent.width - (49 * parent.spacing)) / 50
                height: parent.height * modelData   // высота из данных cava
                anchors.bottom: parent.bottom

                // ── Градиент ────────────────────────────────────────────
                // Плавный переход от основного цвета к прозрачности
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: root.primaryColor
                    }
                    GradientStop {
                        position: 0.6
                        color: root.primaryColor

                        // Анимация цвета — пульсация от primaryColor
                        // к более светлому оттенку (только при воспроизведении)
                        ColorAnimation on color {
                            from: root.primaryColor
                            to: Qt.lighter(root.primaryColor, 1.3)
                            duration: 1000
                            running: root.isPlaying
                            loops: Animation.Infinite
                        }
                    }
                    GradientStop {
                        position: 1.0
                        color: "transparent"       // Верх полоски прозрачный
                    }
                }

                // ── Скругление ──────────────────────────────────────────
                radius: width / 2                  // Полностью скруглённые верхушки

                // ── Прозрачность ────────────────────────────────────────
                opacity: 0.95

                // ── Анимация изменения высоты ──────────────────────────
                // Когда cava присылает новые данные, высота меняется плавно
                Behavior on height {
                    NumberAnimation {
                        duration: 50                // 50 мс — быстро, но не дёргано
                        easing.type: Easing.OutCubic
                    }
                }

                // ── Анимация прозрачности ──────────────────────────────
                Behavior on opacity {
                    NumberAnimation { duration: 400 }
                }
            }
        }
    }
}
