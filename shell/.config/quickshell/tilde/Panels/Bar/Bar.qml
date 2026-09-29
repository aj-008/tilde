import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "root:/"
import "root:/Panels/Bar/SystemTray"

PanelWindow {
    id: root
    implicitHeight: 30
    WlrLayershell.layer: WlrLayer.Top
    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 4
        left: 9
        right: 9
        bottom: 4
    }

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.colBg, 0.3)
        radius: Theme.radiusMd

        Clock {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        Workspaces {
            anchors.centerIn: parent
        }

        SystemTray {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
