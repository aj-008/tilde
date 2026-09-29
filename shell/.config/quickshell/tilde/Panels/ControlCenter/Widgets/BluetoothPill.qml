import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/" as Root
import "root:/Services" as Services

ColumnLayout {
    id: root
    property bool expanded: false
    signal toggled()

    spacing: Root.Theme.spacingSm

    // ---- Collapsed Main Pill Header ----
    Rectangle {
        id: pillHeader
        Layout.fillWidth: true
        height: 52
        radius: Root.Theme.radiusMd
        color: mousePill.containsMouse
            ? Root.Theme.colOverlayHover
            : Root.Theme.colOverlayIdle
        border.color: root.expanded
            ? Qt.alpha(Root.Theme.colAccent, 0.5)
            : (mousePill.containsMouse ? Root.Theme.colOverlayHover : Root.Theme.colOverlayIdle)
        border.width: 1

        scale: mousePill.containsPress ? 0.98 : 1.0

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Root.Theme.spacingMd
            spacing: Root.Theme.spacingMd

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: Root.Theme.radius
                color: Services.Bluetooth.connectedDevice
                    ? Qt.alpha(Root.Theme.colAccent, 0.2)
                    : Root.Theme.colOverlayIdle

                Text {
                    anchors.centerIn: parent
                    text: Root.Theme.icons.bluetooth
                    font.pixelSize: Root.Theme.fontLg
                    font.family: Root.Theme.fontIcon
                    color: Services.Bluetooth.connectedDevice ? Root.Theme.colAccent : Root.Theme.colFg
                }
            }

            ColumnLayout {
                spacing: 1
                Layout.fillWidth: true

                Text {
                    text: "Bluetooth"
                    font.family: Root.Theme.fontFamily
                    font.pixelSize: Root.Theme.fontSm
                    color: Root.Theme.colFg
                    opacity: 0.6
                }

                Text {
                    text: !Services.Bluetooth.enabled
                        ? "Off"
                        : (Services.Bluetooth.connectedDevice
                            ? (Services.Bluetooth.connectedDevice.name || "Connected")
                            : "Not connected")
                    font.family: Root.Theme.fontFamily
                    font.pixelSize: Root.Theme.fontMd
                    font.weight: Font.Bold
                    color: Root.Theme.colFg
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Text {
                text: Root.Theme.icons.chevronDown
                font.pixelSize: Root.Theme.fontMd
                font.family: Root.Theme.fontIcon
                color: root.expanded ? Root.Theme.colAccent : Root.Theme.colFg
                opacity: root.expanded ? 1.0 : 0.5
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }
                Behavior on color { ColorAnimation { duration: 140 } }
            }
        }

        MouseArea {
            id: mousePill
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.expanded = !root.expanded
                root.toggled()
            }
        }
    }

    // ---- Expanded Device List ----
    ColumnLayout {
        Layout.fillWidth: true
        visible: root.expanded
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4

            Text {
                text: Services.Bluetooth.discovering ? "Scanning..." : "Devices"
                font.family: Root.Theme.fontFamily
                font.pixelSize: Root.Theme.fontSm
                color: Root.Theme.colFg
                opacity: 0.6
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: scanText.implicitWidth + 12
                implicitHeight: 22
                radius: Root.Theme.radius
                color: scanMouse.containsMouse ? Root.Theme.colOverlayHover : "transparent"

                Text {
                    id: scanText
                    anchors.centerIn: parent
                    text: Services.Bluetooth.discovering ? "Stop" : "Scan"
                    font.family: Root.Theme.fontFamily
                    font.pixelSize: Root.Theme.fontSm
                    font.weight: Font.Medium
                    color: Services.Bluetooth.discovering ? Root.Theme.colFg : Root.Theme.colAccent
                }

                MouseArea {
                    id: scanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Bluetooth.discovering 
                        ? Services.Bluetooth.stopScan() 
                        : Services.Bluetooth.startScan()
                }
            }
        }

        Repeater {
            model: Services.Bluetooth.devices
            delegate: Rectangle {
                id: deviceItem
                Layout.fillWidth: true
                height: 40
                radius: Root.Theme.radius
                color: modelData.connected
                    ? Qt.alpha(Root.Theme.colAccent, 0.18)
                    : (itemMouse.containsMouse ? Root.Theme.colOverlayIdle : "transparent")
                border.color: modelData.connected
                    ? Qt.alpha(Root.Theme.colAccent, 0.3)
                    : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Root.Theme.spacingMd
                    anchors.rightMargin: Root.Theme.spacingMd
                    spacing: 10

                    Text {
                        text: modelData.name && modelData.name.length > 0 ? modelData.name : "Unknown Device"
                        font.family: Root.Theme.fontFamily
                        font.pixelSize: Root.Theme.fontMd
                        font.weight: modelData.connected ? Font.Bold : Font.Normal
                        color: modelData.connected ? Root.Theme.colAccent : Root.Theme.colFg
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: modelData.paired
                        text: Root.Theme.icons.link
                        font.pixelSize: Root.Theme.fontMd
                        font.family: Root.Theme.fontIcon
                        color: Root.Theme.colFg
                        opacity: 0.5
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.connected) {
                            Services.Bluetooth.disconnectDevice(modelData)
                        } else {
                            Services.Bluetooth.connectDevice(modelData)
                        }
                    }
                }
            }
        }
    }
}
