import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    implicitWidth: 400
    implicitHeight: content.implicitHeight

    color: "transparent"

    anchors {
        right: true
        bottom: true
    }

    margins {
        right: 5
        bottom: 32
    }

    Column {
        id: content

        Text {
            text: "Activate Linux"
            color: "#80ffffff"
            font.pixelSize: 24
        }

        Text {
            text: "Go to Settings to activate Linux"
            color: "#80ffffff"
            font.pixelSize: 18
        }
    }
}
