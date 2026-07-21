//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    Connections {
        target: Quickshell
        function onReloadCompleted() { Quickshell.inhibitReloadPopup() }
        function onReloadFailed(errorString) { Quickshell.inhibitReloadPopup() }
    }

    PanelWindow {
        id: root
        color: "transparent"

        WlrLayershell.namespace: "wallpaper-picker"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        focusable: true

        implicitWidth: screen.width
        implicitHeight: screen.height

        visible: isVisible

        property bool isVisible: false
        property string selectedFile: ""

        IpcHandler {
            target: "wallpaper-picker"

            function toggle() {
                root.isVisible = !root.isVisible;
            }

            function showPicker() {
                root.isVisible = true;
            }

            function hidePicker() {
                root.isVisible = false;
            }
        }

        WallpaperPicker {
            anchors.fill: parent
            onWallpaperSelected: (path) => {
                root.selectedFile = path;
                if (path !== "") {
                    Quickshell.execDetached(["bash", "-c",
                        "echo '" + path + "' > " + root.selectedPath()
                    ]);
                }
                root.isVisible = false;
            }
        }

        Shortcut {
            sequence: "Escape"
            onActivated: root.isVisible = false
        }

        Shortcut {
            sequence: "Super+W"
            onActivated: root.isVisible = !root.isVisible
        }

        function selectedPath(): string {
            let runDir = Quickshell.env("XDG_RUNTIME_DIR") || "/tmp";
            return runDir + "/wallpaper-picker/selected";
        }

        Component.onCompleted: {
            let dir = Qt.resolvedUrl(".").toString().replace("file://", "");
            Quickshell.execDetached(["bash", "-c", "mkdir -p '" + root.selectedPath().replace("/selected", "") + "'"]);
        }
    }
}
