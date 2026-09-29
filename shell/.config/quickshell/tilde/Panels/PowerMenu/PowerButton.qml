import QtQuick
import QtQuick.Layouts
import "../../" // Resolves root Theme.qml

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool selected: false
    property color activeColor: Theme.colAccent
    signal clicked()

    // Scaled up button size
    implicitWidth: 180
    implicitHeight: 180
    radius: Theme.radius * 1.5

    color: selected 
           ? Qt.alpha(activeColor, 0.25) 
           : (mouseArea.containsMouse ? Theme.colHover : Theme.colSurface)
    
    border.color: selected ? activeColor : Theme.colBorder
    border.width: selected ? 3 : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.icon
            font.family: Theme.fontIcon
            font.pixelSize: 52
            color: root.selected ? root.activeColor : Theme.colText
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 4 // Larger text for balance
            font.weight: Font.DemiBold
            color: root.selected ? Theme.colText : Theme.colMuted
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
