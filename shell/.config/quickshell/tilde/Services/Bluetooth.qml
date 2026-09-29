pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth as QuickshellBluetooth

Singleton {
    id: btService

    readonly property var adapter: QuickshellBluetooth.Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool discovering: adapter ? adapter.discovering : false

    readonly property var devices: {
        const rawDevices = adapter && adapter.devices ? adapter.devices.values : []
        
        // Filter out unnamed devices and sort connected/paired to the top
        return rawDevices
            .filter(d => d && d.name && d.name.trim().length > 0)
            .sort((a, b) => {
                if (a.connected !== b.connected) return a.connected ? -1 : 1
                if (a.paired !== b.paired) return a.paired ? -1 : 1
                return a.name.localeCompare(b.name)
            })
    }

    readonly property var connectedDevice: {
        for (const d of devices) {
            if (d && d.connected) return d
        }
        return null
    }

    readonly property var pairedDevices: devices.filter(d => d && d.paired)

    function setEnabled(on) {
        if (adapter) adapter.enabled = on
    }

    function startScan() {
        if (adapter) adapter.discovering = true
    }

    function stopScan() {
        if (adapter) adapter.discovering = false
    }

    function connectDevice(device) {
        if (device && typeof device.connect === "function") {
            device.connect()
        }
    }

    function disconnectDevice(device) {
        if (device && typeof device.disconnect === "function") {
            device.disconnect()
        }
    }
}
