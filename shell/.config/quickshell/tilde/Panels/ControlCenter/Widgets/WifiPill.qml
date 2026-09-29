import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/" as Root
import "root:/Services" as Services

ColumnLayout {
    id: root
    property bool expanded: false
    signal toggled()
    readonly property var current: Services.Network.networks.find(n => n.active)

    spacing: Root.Theme.spacingSm

    Component.onCompleted: Services.Network.refresh()

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
                color: root.current
                    ? Qt.alpha(Root.Theme.colAccent, 0.2)
                    : Root.Theme.colOverlayIdle

                Text {
                    anchors.centerIn: parent
                    text: Root.Theme.icons.wifi
                    font.pixelSize: Root.Theme.fontLg
                    font.family: Root.Theme.fontIcon
                    color: root.current ? Root.Theme.colAccent : Root.Theme.colFg
                }
            }

            ColumnLayout {
                spacing: 1
                Layout.fillWidth: true

                Text {
                    text: "Wi-Fi"
                    font.family: Root.Theme.fontFamily
                    font.pixelSize: Root.Theme.fontSm
                    color: Root.Theme.colFg
                    opacity: 0.6
                }

                Text {
                    text: !Services.Network.radioEnabled
                        ? "Off"
                        : (root.current ? root.current.ssid : "Not connected")
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

    // ---- Expanded Network List ----
    ColumnLayout {
        Layout.fillWidth: true
        visible: root.expanded
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Root.Theme.spacingXs
            Layout.rightMargin: Root.Theme.spacingXs

            Text {
                text: Services.Network.scanning ? "Scanning..." : "Available Networks"
                font.family: Root.Theme.fontFamily
                font.pixelSize: Root.Theme.fontSm
                color: Root.Theme.colFg
                opacity: 0.6
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: rescanText.implicitWidth + 12
                implicitHeight: 22
                radius: Root.Theme.radius
                color: rescanMouse.containsMouse ? Root.Theme.colOverlayHover : "transparent"

                Text {
                    id: rescanText
                    anchors.centerIn: parent
                    text: "Rescan"
                    font.family: Root.Theme.fontFamily
                    font.pixelSize: Root.Theme.fontSm
                    font.weight: Font.Medium
                    color: Root.Theme.colAccent
                }

                MouseArea {
                    id: rescanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Network.rescan()
                }
            }
        }

        Repeater {
            model: Services.Network.networks
            delegate: Rectangle {
                id: netItem
                Layout.fillWidth: true
                height: 40
                radius: Root.Theme.radius
                color: modelData.active
                    ? Qt.alpha(Root.Theme.colAccent, 0.18)
                    : (itemMouse.containsMouse ? Root.Theme.colOverlayIdle : "transparent")
                border.color: modelData.active
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
                        text: modelData.ssid
                        font.family: Root.Theme.fontFamily
                        font.pixelSize: Root.Theme.fontMd
                        font.weight: modelData.active ? Font.Bold : Font.Normal
                        color: modelData.active ? Root.Theme.colAccent : Root.Theme.colFg
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: modelData.security && modelData.security !== "--" && modelData.security.length > 0
                        text: Root.Theme.icons.lock
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
                        if (modelData.active) return
                        
                        const isSecured = modelData.security && modelData.security !== "--" && modelData.security.length > 0

                        // If unencrypted or previously saved, attempt immediate connection
                        if (!isSecured || modelData.known) {
                            passwordPrompt.visible = false
                            Services.Network.connect(modelData.ssid, null)
                        } else {
                            // Otherwise show password input field
                            passwordPrompt.targetSsid = modelData.ssid
                            passwordPrompt.visible = true
                            pwField.text = ""
                            pwField.forceActiveFocus()
                        }
                    }
                }
            }
        }

        // ---- Inline Password Input Prompt ----
        Rectangle {
            id: passwordPrompt
            property string targetSsid: ""
            visible: false
            Layout.fillWidth: true
            height: 40
            radius: Root.Theme.radius
            color: Qt.alpha(Root.Theme.colBg, 0.95)
            border.color: Qt.alpha(Root.Theme.colAccent, 0.5)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: Root.Theme.spacingXs
                spacing: 6

                TextField {
                    id: pwField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    echoMode: TextInput.Password
                    placeholderText: "Password for " + passwordPrompt.targetSsid
                    placeholderTextColor: Qt.alpha(Root.Theme.colFg, 0.4)
                    color: Root.Theme.colFg
                    font.family: Root.Theme.fontFamily
                    font.pixelSize: Root.Theme.fontMd
                    background: null
                    onAccepted: goMouse.submitPassword()
                }

                Rectangle {
                    implicitWidth: goText.implicitWidth + 14
                    Layout.fillHeight: true
                    radius: Root.Theme.radius
                    color: goMouse.containsPress
                        ? Qt.alpha(Root.Theme.colAccent, 0.7)
                        : Root.Theme.colAccent

                    Text {
                        id: goText
                        anchors.centerIn: parent
                        text: "Connect"
                        font.family: Root.Theme.fontFamily
                        font.pixelSize: Root.Theme.fontSm
                        font.bold: true
                        color: "black"
                    }

                    MouseArea {
                        id: goMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        function submitPassword() {
                            if (pwField.text.length > 0) {
                                Services.Network.connect(passwordPrompt.targetSsid, pwField.text)
                                passwordPrompt.visible = false
                                pwField.text = ""
                            }
                        }

                        onClicked: submitPassword()
                    }
                }
            }
        }
    }
}
