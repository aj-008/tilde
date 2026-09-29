import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "root:/" as Root
import "./Widgets" as Widgets
import "root:/Services" as Services

PanelWindow {
    id: window
    visible: Services.ControlCenter.open
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: Services.ControlCenter.open
        ? WlrLayershell.Exclusive
        : WlrLayershell.None
    color: "transparent"

    property string expandedSection: ""

    Item {
        id: container
        anchors.fill: parent
        focus: window.visible
        Keys.onEscapePressed: Services.ControlCenter.close()

        // Dimmed backdrop behind the floating panel
        Rectangle {
            id: overlay
            anchors.fill: parent
            color: Root.Theme.colBg
            opacity: window.visible ? 0.35 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Services.ControlCenter.close()
            }
        }

        // Full-Height Control Center Card
        Rectangle {
            id: card
            width: 380

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: 12
            }

            radius: Root.Theme.radiusLg
            color: Qt.alpha(Root.Theme.colBg, 0.85)
            border.width: 1
            border.color: Qt.alpha(Root.Theme.colAccent, 0.3)

            Flickable {
                anchors.fill: parent
                anchors.margins: 16
                contentWidth: width
                contentHeight: content.implicitHeight
                clip: true

                ColumnLayout {
                    id: content
                    width: parent.width
                    spacing: 12

                    // ---- Header ----
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Root.Theme.radius
                            color: Root.Theme.colHighlight

                            Text {
                                anchors.centerIn: parent
                                text: Root.Theme.icons.settings
                                font.pixelSize: Root.Theme.fontLg
                                font.family: Root.Theme.fontIcon
                                color: Root.Theme.colAccent
                            }
                        }

                        Text {
                            text: "Control Center"
                            font.family: Root.Theme.fontFamily
                            font.pixelSize: Root.Theme.fontXl
                            font.weight: Font.Bold
                            color: Root.Theme.colFg
                            Layout.fillWidth: true
                        }
                    }

                    // ---- Fully Expanded 2x2 Grid ----
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10

                        Widgets.GridButton {
                            label: "Caffeine"
                            icon: Root.Theme.icons.caffeine
                            active: Services.Caffeine.active
                            toggleOnClick: false 
                            onClicked: Services.Caffeine.toggle()
                        }
                        Widgets.GridButton {
                            label: "Night Mode"
                            icon: Root.Theme.icons.nightMode
                            active: Services.NightMode.active
                            toggleOnClick: false 
                            onClicked: Services.NightMode.toggle()
                        }
                        Widgets.GridButton {
                            label: "Power"
                            icon: Root.Theme.icons.power
                            toggleOnClick: false
                            onClicked: {
                                powerMenu.toggle()
                                Services.ControlCenter.close()
                            }
                        }
                        Widgets.BrightnessSquare {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }

                    // ---- System Pills ----
                    Widgets.WifiPill {
                        Layout.fillWidth: true
                        expanded: window.expandedSection === "wifi"
                        onToggled: {
                            window.expandedSection = (window.expandedSection === "wifi") ? "" : "wifi"
                        }
                    }

                    Widgets.BluetoothPill {
                        Layout.fillWidth: true
                        expanded: window.expandedSection === "bluetooth"
                        onToggled: {
                            window.expandedSection = (window.expandedSection === "bluetooth") ? "" : "bluetooth"
                        }
                    }

                    Widgets.VolumePill {
                        Layout.fillWidth: true
                    }

                    // ---- Notifications History Header ----
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Root.Theme.spacingSm

                        Text {
                            text: "Notifications History"
                            font.family: Root.Theme.fontFamily
                            font.pixelSize: Root.Theme.fontMd
                            font.weight: Font.Bold
                            color: Root.Theme.colFg
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 68
                            Layout.preferredHeight: 26
                            radius: Root.Theme.radius
                            visible: Services.Notifications.history.length > 0
                            color: clearMouse.containsMouse ? Root.Theme.colOverlayHover : Root.Theme.colOverlayIdle

                            Text {
                                anchors.centerIn: parent
                                text: "Clear all"
                                font.family: Root.Theme.fontFamily
                                font.pixelSize: Root.Theme.fontSm
                                color: Root.Theme.colFg
                            }

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Services.Notifications.clearAll()
                            }
                        }
                    }

                    // ---- Notifications Dynamic List ----
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            visible: Services.Notifications.history.length === 0
                            text: "No notifications"
                            font.family: Root.Theme.fontFamily
                            font.pixelSize: Root.Theme.fontMd
                            color: Root.Theme.colFg
                            opacity: 0.4
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 12
                            Layout.bottomMargin: 12
                        }

                        Repeater {
                            model: Services.Notifications.history

                            Widgets.NotificationRow {
                                entry: modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
