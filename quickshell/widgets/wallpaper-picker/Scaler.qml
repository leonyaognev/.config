import QtQuick
import Quickshell
import Quickshell.Io
import "WindowRegistry.js" as LayoutMath

Item {
    id: root
    visible: false

    property real currentWidth: 1920.0
    property real currentHeight: 1080.0
    property real uiScale: 1.0

    readonly property string settingsFile: {
        let envPath = Quickshell.env("WALLPICKER_SETTINGS_JSON");
        if (envPath && envPath !== "") return envPath;
        return Quickshell.env("HOME") + "/.config/hypr/settings.json";
    }

    property real baseScale: LayoutMath.getScale(currentWidth, currentHeight, uiScale)

    function s(val) {
        return LayoutMath.s(val, baseScale);
    }

    Process {
        id: scaleReader
        command: ["bash", "-c", "cat '" + root.settingsFile + "' 2>/dev/null || echo '{}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    if (this.text && this.text.trim().length > 0 && this.text.trim() !== "{}") {
                        let parsed = JSON.parse(this.text);
                        if (parsed.uiScale !== undefined && root.uiScale !== parsed.uiScale) {
                            root.uiScale = parsed.uiScale;
                        }
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: scaleWatcher
        command: ["bash", "-c", "while [ ! -f '" + root.settingsFile + "' ]; do sleep 1; done; inotifywait -qq -e modify,close_write '" + root.settingsFile + "'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                scaleReader.running = false;
                scaleReader.running = true;
                scaleWatcher.running = false;
                scaleWatcher.running = true;
            }
        }
    }
}
