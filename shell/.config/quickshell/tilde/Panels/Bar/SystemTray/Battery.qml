import QtQuick
import Quickshell.Services.UPower
import "root:/"

Item {
    id: root
    property var battery: UPower.displayDevice
    property real pct: battery ? battery.percentage : 0 

    implicitWidth: 35
    implicitHeight: 15

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Theme.colSysIcon
        opacity: 0.5
        clip: true

        Rectangle {
            id: fill
            radius: height / 2
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * root.pct + 1
            color: battery.state == UPowerDeviceState.Charging ? Theme.colAccent : (root.pct < 0.2 ? Theme.colError : Theme.colSysIcon)

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: Math.round(root.pct * 100)
        color: Theme.colBatteryText
        styleColor: "black"
        font { family: Theme.fontFamily; pointSize: Theme.trayFontSize; weight: 650 }
    }
}
