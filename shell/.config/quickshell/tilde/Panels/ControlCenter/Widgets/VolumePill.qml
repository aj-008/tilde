import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "root:/" as Root

Rectangle {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property real level: sink && sink.audio ? sink.audio.volume : 0
    property bool muted: sink && sink.audio ? sink.audio.muted : false
    property bool dragging: false

    readonly property string iconName: {
        if (root.muted || root.level === 0) return Root.Theme.icons.volumeMute
        if (root.level < 0.33) return Root.Theme.icons.volumeLow
        if (root.level < 0.66) return Root.Theme.icons.volumeMedium
        return Root.Theme.icons.volumeHigh
    }

    Layout.fillWidth: true
    height: 52
    radius: Root.Theme.radiusMd
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

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    // ---- Fill indicator behind content ----
    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: parent.width * (root.muted ? 0 : Math.min(1.0, root.level))
        radius: root.radius
        color: root.muted
            ? Root.Theme.colOverlayHover
            : Root.Theme.colHighlight

        Behavior on width {
            enabled: !root.dragging
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
        Behavior on color { ColorAnimation { duration: 140 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Root.Theme.spacingMd
        spacing: Root.Theme.spacingMd

        // Icon area with click-to-mute
        Rectangle {
            z: 2
            implicitWidth: 32
            implicitHeight: 32
            radius: Root.Theme.radius
            color: iconMouse.containsMouse ? Root.Theme.colOverlayHover : "transparent"

            Text {
                anchors.centerIn: parent
                text: root.iconName
                font.pixelSize: Root.Theme.fontLg
                font.family: Root.Theme.fontIcon
                color: root.muted ? Root.Theme.colFg : Root.Theme.colAccent
                opacity: root.muted ? 0.5 : 1.0
            }

            MouseArea {
                id: iconMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.sink && root.sink.audio) {
                        root.sink.audio.muted = !root.sink.audio.muted
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft

            Text {
                text: "Volume"
                font.family: Root.Theme.fontFamily
                font.pixelSize: Root.Theme.fontSm
                color: Root.Theme.colFg
                opacity: 0.6
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }

            Text {
                text: root.muted ? "Muted" : Math.round(root.level * 100) + "%"
                font.family: Root.Theme.fontFamily
                font.pixelSize: Root.Theme.fontMd
                font.weight: Font.Bold
                color: root.muted ? Root.Theme.colFg : Root.Theme.colAccent
                opacity: root.muted ? 0.5 : 1.0
                horizontalAlignment: Text.AlignLeft
                Layout.fillWidth: true
            }
        }
    }

    // ---- Horizontal-Only Drag Area ----
    Item {
        id: dummyDragTarget
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        z: 1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        drag.target: dummyDragTarget
        drag.axis: Drag.XAxis
        drag.minimumX: 0
        drag.maximumX: root.width

        function setVolumeFromMouseX(mouseX) {
            if (!root.sink || !root.sink.audio) return
            const pct = Math.max(0.0, Math.min(1.0, mouseX / root.width))
            root.sink.audio.volume = pct
            if (pct > 0 && root.sink.audio.muted) {
                root.sink.audio.muted = false
            }
        }

        onPressed: (mouse) => {
            root.dragging = true
            setVolumeFromMouseX(mouse.x)
        }

        onPositionChanged: (mouse) => {
            if (pressed) {
                setVolumeFromMouseX(mouse.x)
            }
        }

        onReleased: {
            root.dragging = false
        }

        onCanceled: {
            root.dragging = false
        }
    }
}
