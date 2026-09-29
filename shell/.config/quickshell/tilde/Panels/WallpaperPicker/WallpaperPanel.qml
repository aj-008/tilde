pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io as Io
import Quickshell.Wayland
import "root:/"

PanelWindow {
    id: panel

    property bool panelVisible: false
    visible: panelVisible

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    WlrLayershell.keyboardFocus: panelVisible
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore

    onPanelVisibleChanged: {
        if (panelVisible) {
            picker.forceActiveFocus()
        }
    }

    // Dim backdrop
    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.colBg, 0.55)

        MouseArea {
            anchors.fill: parent
            onClicked: panel.panelVisible = false
        }
    }

    // WallpaperPicker fills full overlay for proper Coverflow scaling
    WallpaperPicker {
        id: picker
        anchors.fill: parent
        onCloseRequested: {
            panel.panelVisible = false 
        }
    }

    Io.IpcHandler {
        target: "wallpaperPicker"
        function toggle() { panel.panelVisible = !panel.panelVisible }
        function open() { panel.panelVisible = true }
        function close() { panel.panelVisible = false }
    }
}
