import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import "root:/"

Item {
    id: root
    property string iconName: ""
    property color color: Theme.colSysIcon
    property int size: Theme.trayIconSize

    implicitWidth: size
    implicitHeight: size

    signal clicked()

    IconImage {
        id: img
        implicitSize: root.size
        source: Quickshell.iconPath(root.iconName, true)
        opacity: 1
    }

    MultiEffect {
        anchors.fill: parent
        source: img
        colorization: 1.0
        colorizationColor: root.color
        brightness: 0.6
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
