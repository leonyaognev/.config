import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "wallpaper-picker" as Picker

PanelWindow {
    id: root
    color: "transparent"

    WlrLayershell.namespace: "wallpaper-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore
    focusable: true

    implicitWidth: Screen.width
    implicitHeight: Screen.height

    visible: isVisible

    property bool isVisible: false
    property string selectedFile: ""

    IpcHandler {
        target: "wallpaper-picker"

        function toggle() { root.isVisible = !root.isVisible }
        function showPicker() { root.isVisible = true }
        function hidePicker() { root.isVisible = false }
    }

    Picker.WallpaperPicker {
        anchors.fill: parent
        onWallpaperSelected: (path) => {
            root.selectedFile = path
            if (path !== "") {
                Quickshell.execDetached(["bash", "-c",
                    "echo '" + path + "' > " + root.selectedPath()
                ])
            }
            root.isVisible = false
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.isVisible = false
    }

    function selectedPath(): string {
        let runDir = Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
        return runDir + "/wallpaper-picker/selected"
    }

    Component.onCompleted: {
        Quickshell.execDetached(["bash", "-c", "mkdir -p '" + root.selectedPath().replace("/selected", "") + "'"])
    }
}
