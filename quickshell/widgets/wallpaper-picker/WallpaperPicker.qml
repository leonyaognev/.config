import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtCore
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Item {
    id: window
    width: Screen.width

    Caching { id: paths }

    Scaler {
        id: scaler
        currentWidth: Screen.width
    }

    function s(val) { return scaler.s(val); }

    MatugenColors { id: _theme }

    signal wallpaperSelected(string path)

    property string currentFilter: "All"
    property int visibleItemCount: -1
    property int scrollAccum: 0
    property real scrollThreshold: window.s(300)
    property var colorMap: ({})
    property int cacheVersion: 0

    readonly property string srcDir: {
        const dir = Quickshell.env("WALLPAPER_DIR")
        return (dir && dir !== "") ? dir : Quickshell.env("HOME") + "/Images/wallpaper"
    }

    readonly property string thumbDir: "file://" + paths.getCacheDir("wallpaper_picker") + "/thumbs"

    readonly property var filterData: [
        { name: "All", hex: "", label: "All" },
        { name: "Video", hex: "", label: "Vid" },
        { name: "Red", hex: "#FF4500", label: "" },
        { name: "Orange", hex: "#FFA500", label: "" },
        { name: "Yellow", hex: "#FFD700", label: "" },
        { name: "Green", hex: "#32CD32", label: "" },
        { name: "Blue", hex: "#1E90FF", label: "" },
        { name: "Purple", hex: "#8A2BE2", label: "" },
        { name: "Pink", hex: "#FF69B4", label: "" },
        { name: "Monochrome", hex: "#A9A9A9", label: "" }
    ]

    readonly property real itemWidth: window.s(400)
    readonly property real itemHeight: window.s(420)
    readonly property real borderWidth: window.s(3)
    readonly property real spacing: window.s(10)
    readonly property real skewFactor: -0.35

    property bool isStartup: localFolderModel.status === FolderListModel.Loading
    property bool isReady: visible && localFolderModel.status === FolderListModel.Ready

    property string currentNotification: {
        if (isLoading) return "Generating thumbnails...";
        if (window.visibleItemCount === 0) return "No wallpapers found";
        if (window.currentFilter === "All") return "";
        if (window.currentFilter === "Video") return "Videos";
        return window.currentFilter;
    }
    property bool showNotification: currentNotification !== ""
    property bool isLoading: localFolderModel.status === FolderListModel.Loading

    Timer { id: scrollThrottle; interval: 150 }

    function getHexBucket(hexStr) {
        if (!hexStr) return "Monochrome";
        hexStr = String(hexStr).trim().replace(/#/g, '');
        if (hexStr.length > 6) hexStr = hexStr.substring(0, 6);
        if (hexStr.length !== 6) return "Monochrome";
        let r = parseInt(hexStr.substring(0,2), 16) / 255;
        let g = parseInt(hexStr.substring(2,4), 16) / 255;
        let b = parseInt(hexStr.substring(4,6), 16) / 255;
        if (isNaN(r) || isNaN(g) || isNaN(b)) return "Monochrome";
        let max = Math.max(r, g, b), min = Math.min(r, g, b);
        let d = max - min;
        let h = 0;
        if (max !== min) {
            if (max === r) h = (g - b) / d + (g < b ? 6 : 0);
            else if (max === g) h = (b - r) / d + 2;
            else h = (r - g) / d + 4;
            h /= 6;
        }
        h = h * 360;
        let s = max === 0 ? 0 : d / max;
        let v = max;
        if (s < 0.05 || v < 0.08) return "Monochrome";
        if (h >= 345 || h < 15) return "Red";
        if (h >= 15 && h < 45) return "Orange";
        if (h >= 45 && h < 75) return "Yellow";
        if (h >= 75 && h < 165) return "Green";
        if (h >= 165 && h < 260) return "Blue";
        if (h >= 260 && h < 315) return "Purple";
        if (h >= 315 && h < 345) return "Pink";
        return "Monochrome";
    }

    function checkItemMatchesFilter(fileName, isVid, filter) {
        if (filter === "All") return true;
        if (filter === "Video") return isVid;
        let hexColor = window.colorMap[String(fileName)];
        if (!hexColor) return filter === "Monochrome";
        return window.getHexBucket(hexColor) === filter;
    }

    FolderListModel {
        id: markerModel
        folder: "file://" + paths.getCacheDir("wallpaper_picker") + "/colors_markers"
        showDirs: false
        nameFilters: ["*_HEX_*"]
        onCountChanged: window.processMarkers()
        onStatusChanged: { if (status === FolderListModel.Ready) window.processMarkers() }
    }

    function processMarkers() {
        let newMap = {};
        for (let i = 0; i < markerModel.count; i++) {
            let markerName = markerModel.get(i, "fileName") || "";
            if (!markerName) continue;
            let splitIdx = markerName.lastIndexOf("_HEX_");
            if (splitIdx !== -1) {
                let fName = markerName.substring(0, splitIdx);
                let hexCode = markerName.substring(splitIdx + 5);
                newMap[fName] = "#" + hexCode;
            }
        }
        window.colorMap = newMap;
        window.cacheVersion++;
        window.updateVisibleCount();
    }

    function triggerColorExtraction() {
        const extractScript = `
            COLOR_DIR="${paths.getCacheDir('wallpaper_picker')}/colors_markers"
            THUMBS="${paths.getCacheDir('wallpaper_picker')}/thumbs"
            mkdir -p "$COLOR_DIR"
            if command -v magick &> /dev/null; then CMD="magick"; else CMD="convert"; fi
            for file in "$THUMBS"/*; do
                [ -f "$file" ] || continue
                filename=$(basename "$file")
                found=0
                for marker in "$COLOR_DIR/$filename"_HEX_*; do [ -e "$marker" ] && found=1 && break; done
                [ $found -eq 1 ] && continue
                hex=$($CMD "$file" -modulate 100,200 -resize "1x1^" -gravity center -extent 1x1 -depth 8 -format "%[hex:p{0,0}]" info:- 2>/dev/null | grep -oE '[0-9A-Fa-f]{6}' | head -n 1)
                [ -n "$hex" ] && touch "$COLOR_DIR/$filename""_HEX_$hex"
            done
        `;
        Quickshell.execDetached(["bash", "-c", extractScript]);
    }

    ListModel { id: localProxyModel }

    FolderListModel {
        id: localFolderModel
        folder: window.thumbDir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.mp4", "*.mkv", "*.mov", "*.webm"]
        showDirs: false
        sortField: FolderListModel.Name
        onCountChanged: window.syncLocalModel()
        onStatusChanged: { if (status === FolderListModel.Ready) window.syncLocalModel() }
    }

    property int _localSyncedCount: 0

    function syncLocalModel() {
        let folderCount = localFolderModel.count;
        if (folderCount < window._localSyncedCount) {
            localProxyModel.clear();
            window._localSyncedCount = 0;
        }
        if (folderCount > window._localSyncedCount) {
            let batch = [];
            for (let i = window._localSyncedCount; i < folderCount; i++) {
                let fn = localFolderModel.get(i, "fileName");
                let fu = localFolderModel.get(i, "fileUrl");
                if (fn !== undefined) batch.push({ "fileName": fn, "fileUrl": String(fu) });
            }
            if (batch.length > 0) localProxyModel.append(batch);
            window._localSyncedCount = folderCount;
        }
        window.updateVisibleCount();
        if (localProxyModel.count > 0 && view.currentIndex < 0) {
            view.currentIndex = 0;
        }
    }

    function updateVisibleCount() {
        if (!localProxyModel || localProxyModel.count === 0) { window.visibleItemCount = 0; return; }
        let count = 0;
        for (let i = 0; i < localProxyModel.count; i++) {
            let fname = localProxyModel.get(i).fileName || "";
            let isVid = fname.startsWith("000_");
            if (checkItemMatchesFilter(fname, isVid, window.currentFilter)) count++;
        }
        window.visibleItemCount = count;
    }

    function stepToNextValidIndex(direction) {
        if (localProxyModel.count === 0) return;
        let start = view.currentIndex;
        for (let i = start + direction; i >= 0 && i < localProxyModel.count; i += direction) {
            let fname = localProxyModel.get(i).fileName || "";
            let isVid = fname.startsWith("000_");
            if (checkItemMatchesFilter(fname, isVid, window.currentFilter)) {
                view.currentIndex = i;
                return;
            }
        }
    }

    function cycleFilter(direction) {
        let currentIdx = -1;
        for (let i = 0; i < window.filterData.length; i++) {
            if (window.filterData[i].name === window.currentFilter) { currentIdx = i; break; }
        }
        if (currentIdx !== -1) {
            let nextIdx = (currentIdx + direction + window.filterData.length) % window.filterData.length;
            window.currentFilter = window.filterData[nextIdx].name;
        }
    }

    function getCleanName(name) {
        if (!name) return "";
        return String(name).startsWith("000_") ? String(name).substring(4) : String(name);
    }

    function selectWallpaper(safeFileName) {
        let cleanName = getCleanName(safeFileName);
        let fullPath = window.srcDir + "/" + cleanName;
        window.wallpaperSelected(fullPath);
    }

    Shortcut { sequence: "Left";  onActivated: window.stepToNextValidIndex(-1) }
    Shortcut { sequence: "Right"; onActivated: window.stepToNextValidIndex(1) }
    Shortcut {
        sequence: "Return"
        onActivated: {
            if (view.currentIndex >= 0 && view.currentIndex < localProxyModel.count) {
                let fname = localProxyModel.get(view.currentIndex).fileName;
                if (fname) window.selectWallpaper(String(fname));
            }
        }
    }
    Shortcut { sequence: "Escape"; onActivated: window.wallpaperSelected("") }
    Shortcut { sequence: "Tab"; onActivated: window.cycleFilter(1) }
    Shortcut { sequence: "Backtab"; onActivated: window.cycleFilter(-1) }

    ListView {
        id: view
        anchors.fill: parent
        opacity: window.isReady ? 1.0 : 0.0
        anchors.margins: window.isReady ? 0 : window.s(40)
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutQuart } }
        Behavior on anchors.margins { NumberAnimation { duration: 700; easing.type: Easing.OutExpo } }
        spacing: 0
        orientation: ListView.Horizontal
        clip: false
        interactive: true
        cacheBuffer: 2000
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width / 2) - ((window.itemWidth * 1.5 + window.spacing) / 2)
        preferredHighlightEnd: (width / 2) + ((window.itemWidth * 1.5 + window.spacing) / 2)
        highlightMoveDuration: 500
        focus: true
        model: localProxyModel

        header: Item { width: Math.max(0, (view.width / 2) - ((window.itemWidth * 1.5) / 2)) }
        footer: Item { width: Math.max(0, (view.width / 2) - ((window.itemWidth * 1.5) / 2)) }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: (wheel) => {
                if (scrollThrottle.running) { wheel.accepted = true; return; }
                let dx = wheel.angleDelta.x, dy = wheel.angleDelta.y;
                let delta = Math.abs(dx) > Math.abs(dy) ? dx : dy;
                scrollAccum += delta;
                if (Math.abs(scrollAccum) >= scrollThreshold) {
                    window.stepToNextValidIndex(scrollAccum > 0 ? -1 : 1);
                    scrollAccum = 0;
                    scrollThrottle.start();
                }
                wheel.accepted = true;
            }
        }

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
                NumberAnimation { property: "scale"; from: 0.5; to: 1; duration: 400; easing.type: Easing.OutBack }
            }
        }
        addDisplaced: Transition {
            NumberAnimation { property: "x"; duration: 400; easing.type: Easing.OutCubic }
        }

        delegate: Item {
            id: delegateRoot
            readonly property string safeFileName: fileName !== undefined ? String(fileName) : ""
            readonly property bool isCurrent: ListView.isCurrentItem
            readonly property bool isVideo: safeFileName.startsWith("000_")
            readonly property bool matchesFilter: window.checkItemMatchesFilter(safeFileName, isVideo, window.currentFilter)
            readonly property real targetWidth: isCurrent ? (window.itemWidth * 1.5) : (window.itemWidth * 0.5)
            readonly property real targetHeight: isCurrent ? (window.itemHeight + window.s(30)) : window.itemHeight

            width: matchesFilter ? (targetWidth + window.spacing) : 0
            visible: width > 0.1 || opacity > 0.01
            opacity: matchesFilter ? (isCurrent ? 1.0 : 0.6) : 0.0
            scale: matchesFilter ? 1.0 : 0.5
            height: matchesFilter ? targetHeight : 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: window.s(15)
            z: isCurrent ? 10 : 1

            Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
            Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
            Behavior on height { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
            Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }

            Item {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: ((window.itemHeight - height) / 2) * window.skewFactor
                width: parent.width > 0 ? parent.width * (targetWidth / (targetWidth + window.spacing)) : 0
                height: parent.height

                transform: Matrix4x4 {
                    property real s: window.skewFactor
                    matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: delegateRoot.matchesFilter
                    onClicked: {
                        view.currentIndex = index;
                        window.selectWallpaper(delegateRoot.safeFileName);
                    }
                }

                Item {
                    anchors.fill: parent
                    anchors.margins: window.borderWidth
                    Rectangle { anchors.fill: parent; color: _theme.base }
                    clip: true

                    Image {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: window.s(-50)
                        width: (window.itemWidth * 1.5) + ((window.itemHeight + window.s(30)) * Math.abs(window.skewFactor)) + window.s(50)
                        height: window.itemHeight + window.s(30)
                        fillMode: Image.PreserveAspectCrop
                        source: fileUrl !== undefined ? fileUrl : ""
                        asynchronous: true

                        transform: Matrix4x4 {
                            property real s: -window.skewFactor
                            matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }
                    }

                    Rectangle {
                        visible: delegateRoot.isVideo
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: window.s(10)
                        width: window.s(32)
                        height: window.s(32)
                        radius: window.s(6)
                        color: Qt.rgba(_theme.base.r, _theme.base.g, _theme.base.b, 0.6)
                        transform: Matrix4x4 {
                            property real s: -window.skewFactor
                            matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }

                        Canvas {
                            anchors.fill: parent
                            anchors.margins: window.s(8)
                            onPaint: {
                                var ctx = getContext("2d");
                                var s = window.s;
                                ctx.reset();
                                ctx.fillStyle = Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.93);
                                ctx.beginPath();
                                ctx.moveTo(s(4), 0);
                                ctx.lineTo(s(14), s(8));
                                ctx.lineTo(s(4), s(16));
                                ctx.closePath();
                                ctx.fill();
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: filterBarBackground
        anchors.top: parent.top
        anchors.topMargin: window.isReady ? window.s(40) : window.s(-100)
        opacity: window.isReady ? 1.0 : 0.0
        Behavior on anchors.topMargin { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        anchors.horizontalCenter: parent.horizontalCenter
        z: 20
        height: window.s(56)
        width: filterRow.width + window.s(24)
        radius: window.s(14)
        color: Qt.rgba(_theme.mantle.r, _theme.mantle.g, _theme.mantle.b, 0.90)
        border.color: _theme.surface2
        border.width: 1

        Row {
            id: filterRow
            anchors.centerIn: parent
            spacing: window.s(12)

            Rectangle {
                id: notifDrawer
                height: window.s(44)
                property real paddingLeft: window.s(16)
                property real targetWidth: window.showNotification ? Math.min(notifTextDrawer.implicitWidth + paddingLeft + window.s(20), window.s(300)) : 0
                width: targetWidth
                visible: width > 0.1
                radius: window.s(10)
                clip: true
                anchors.verticalCenter: parent.verticalCenter
                color: window.showNotification ? _theme.surface2 : "transparent"
                border.color: window.showNotification ? _theme.surface1 : "transparent"
                border.width: 1
                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                Behavior on color { ColorAnimation { duration: 400 } }

                Text {
                    id: notifTextDrawer
                    anchors.left: parent.left
                    anchors.leftMargin: window.s(16)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth, window.s(300) - anchors.leftMargin - window.s(16))
                    text: window.currentNotification
                    color: _theme.text
                    font.family: "JetBrains Mono"
                    font.pixelSize: window.s(14)
                    font.bold: true
                    elide: Text.ElideRight
                    opacity: window.showNotification ? 0.9 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                }
            }

            Repeater {
                model: window.filterData

                delegate: Item {
                    width: !visible ? 0 : ((modelData.name === "Video" || modelData.name === "All") ? window.s(44) : (modelData.hex === "" ? filterText.contentWidth + window.s(24) : window.s(36)))
                    height: !visible ? 0 : window.s(36)
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: window.s(10)
                        color: modelData.hex === ""
                                ? (window.currentFilter === modelData.name ? _theme.surface2 : "transparent")
                                : modelData.hex
                        border.color: window.currentFilter === modelData.name ? _theme.text : _theme.surface1
                        border.width: window.currentFilter === modelData.name ? window.s(2) : 1
                        scale: window.currentFilter === modelData.name ? 1.15 : (filterMouse.containsMouse ? 1.08 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
                        Behavior on border.color { ColorAnimation { duration: 300 } }

                        Text {
                            id: filterText
                            visible: modelData.hex === "" && modelData.name !== "Video" && modelData.name !== "All"
                            text: modelData.label
                            anchors.centerIn: parent
                            color: window.currentFilter === modelData.name ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7)
                            font.family: "JetBrains Mono"
                            font.pixelSize: window.s(14)
                            font.bold: window.currentFilter === modelData.name
                            Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.OutQuart } }
                        }

                        Canvas {
                            visible: modelData.name === "Video"
                            width: window.s(14); height: window.s(16)
                            anchors.centerIn: parent
                            anchors.horizontalCenterOffset: window.s(2)
                            onPaint: {
                                var ctx = getContext("2d");
                                var s = window.s;
                                ctx.reset();
                                ctx.fillStyle = window.currentFilter === modelData.name ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7);
                                ctx.beginPath();
                                ctx.moveTo(0, 0);
                                ctx.lineTo(s(14), s(8));
                                ctx.lineTo(0, s(16));
                                ctx.closePath();
                                ctx.fill();
                            }
                        }

                        Canvas {
                            visible: modelData.name === "All"
                            width: window.s(14); height: window.s(14)
                            anchors.centerIn: parent
                            onPaint: {
                                var ctx = getContext("2d");
                                var s = window.s;
                                ctx.reset();
                                ctx.fillStyle = window.currentFilter === modelData.name ? _theme.text : Qt.rgba(_theme.text.r, _theme.text.g, _theme.text.b, 0.7);
                                ctx.fillRect(0, 0, s(6), s(6));
                                ctx.fillRect(s(8), 0, s(6), s(6));
                                ctx.fillRect(0, s(8), s(6), s(6));
                                ctx.fillRect(s(8), s(8), s(6), s(6));
                            }
                        }
                    }

                    MouseArea {
                        id: filterMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: window.currentFilter = modelData.name
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        window.triggerColorExtraction();
        view.forceActiveFocus();
    }
}
