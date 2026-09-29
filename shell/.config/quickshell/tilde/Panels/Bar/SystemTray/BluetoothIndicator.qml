import QtQuick
import Quickshell.Bluetooth
import "root:/"
import "root:/Services"

Item {
    property var adapter: Bluetooth.defaultAdapter

    implicitWidth: Theme.trayIconSize
    implicitHeight: Theme.trayIconSize

    SystemTrayIcon {
        anchors.fill: parent
        iconName: adapter && adapter.enabled ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"
        color: adapter && adapter.enabled ? Theme.colSysIcon : Theme.colError
        onClicked: ControlCenter.openPage("bluetooth")
    }
}
