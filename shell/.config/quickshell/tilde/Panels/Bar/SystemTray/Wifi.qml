import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import Quickshell
import "root:/"
import "root:/Services"

RowLayout {
    property var wifiDevice: Networking.devices.values.find(d => d.type === 1)
    property int strength: wifiDevice?.activeAccessPoint?.strength ?? 0

    SystemTrayIcon {
        id: wifiIcon
        iconName: {
            if (!wifiDevice || !wifiDevice.connected) return "network-wireless-offline-symbolic"
            if (strength > 80) return "network-wireless-signal-excellent-symbolic"
            if (strength > 55) return "network-wireless-signal-good-symbolic"
            if (strength > 30) return "network-wireless-signal-ok-symbolic"
            return "network-wireless-signal-weak-symbolic"
        }
        color: wifiDevice && wifiDevice.connected ? Theme.colSysIcon : Theme.colMuted
        size: Theme.trayIconSize
        onClicked: ControlCenter.openPage("wifi")
    }
}
