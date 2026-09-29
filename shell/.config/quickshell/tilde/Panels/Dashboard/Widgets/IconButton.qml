import QtQuick
import "root:/"

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: 24
    signal clicked()

    implicitWidth: 32
    implicitHeight: 32
    radius: width / 2
    color: mouseArea.pressed ? Theme.colPressed
         : mouseArea.containsMouse ? Theme.colHover
         : "transparent"

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.fontIcon
        font.pixelSize: root.iconSize
        color: Theme.colFg
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
