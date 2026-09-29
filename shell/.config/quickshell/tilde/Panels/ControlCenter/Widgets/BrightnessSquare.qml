import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "root:/" as Root

Rectangle {
    id: root

    property alias brightness: root.level
    property real level: 0.5
    property bool dragging: false

    readonly property string iconName: {
        if (root.level < 0.33) return Root.Theme.icons.brightnessLow
        if (root.level < 0.66) return Root.Theme.icons.brightnessMedium
        return Root.Theme.icons.brightnessHigh
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitHeight: 120
    radius: Root.Theme.radiusLg
    color: dragArea.containsMouse
        ? Root.Theme.colOverlayHover
        : Root.Theme.colOverlayIdle
    border.color: root.dragging
        ? Qt.alpha(Root.Theme.colAccent, 0.5)
        : (dragArea.containsMouse ? Root.Theme.colOverlayHover : Root.Theme.colOverlayIdle)
    border.width: 1
    clip: true

    scale: root.dragging ? 0.99 : 1.0

    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on border.color { ColorAnimation { duration: 140 } }
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

    // ---- Process to Read Current Brightness ----
    Process {
        id: getBrightnessProc
        command: ["brightnessctl", "g"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const current = parseInt(this.text.trim()) || 0
                if (getMaxProc.maxVal > 0) {
                    root.level = Math.max(0.01, current / getMaxProc.maxVal)
                }
            }
        }
    }

    Process {
        id: getMaxProc
        property int maxVal: 255
        command: ["brightnessctl", "m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                getMaxProc.maxVal = parseInt(this.text.trim()) || 255
                getBrightnessProc.running = true
            }
        }
    }

    Process {
        id: setBrightnessProc
    }

    function applyBrightness(pct) {
        root.level = Math.max(0.01, Math.min(1.0, pct))
        const percentString = Math.round(root.level * 100) + "%"
        setBrightnessProc.command = ["brightnessctl", "set", percentString]
        setBrightnessProc.running = true
    }

    // ---- Vertical Fill Indicator (Bottom-Up) ----
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * root.level
        radius: root.radius
        color: Root.Theme.colHighlight

        Behavior on height {
            enabled: !root.dragging
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    // Centered Vertical Content
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Root.Theme.spacingSm

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 36
            implicitHeight: 36
            radius: Root.Theme.radius
            color: Root.Theme.colOverlayIdle

            Text {
                anchors.centerIn: parent
                text: root.iconName
                font.pixelSize: Root.Theme.fontXl
                font.family: Root.Theme.fontIcon
                color: Root.Theme.colAccent
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Brightness " + Math.round(root.level * 100) + "%"
            font.family: Root.Theme.fontFamily
            font.pixelSize: Root.Theme.fontMd
            font.weight: Font.DemiBold
            color: Root.Theme.colFg
        }
    }

    // ---- Vertical Drag Area ----
    Item { id: dummyDragTarget }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        z: 1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        drag.target: dummyDragTarget
        drag.axis: Drag.YAxis
        drag.minimumY: 0
        drag.maximumY: root.height

        function updateBrightnessFromY(mouseY) {
            // Y starts at 0 at the top, so we invert it for bottom-to-top fill
            const pct = 1.0 - (mouseY / root.height)
            root.applyBrightness(pct)
        }

        onPressed: (mouse) => { root.dragging = true; updateBrightnessFromXOrY(mouse.y) }
        onPositionChanged: (mouse) => { if (pressed) updateBrightnessFromXOrY(mouse.y) }
        onReleased: root.dragging = false
        onCanceled: root.dragging = false

        function updateBrightnessFromXOrY(mouseY) {
            updateBrightnessFromY(mouseY)
        }
    }
}
