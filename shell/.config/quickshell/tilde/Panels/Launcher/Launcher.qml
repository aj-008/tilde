import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "./Providers" as Providers
import "root:/" as Root

PanelWindow {
    id: root

    property bool launcherOpen: false
    visible: launcherOpen

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.keyboardFocus: WlrLayershell.OnDemand

    implicitWidth: 640
    implicitHeight: 440

    color: "transparent"

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.launcherOpen = !root.launcherOpen
            if (root.launcherOpen) {
                searchInput.text = ""
                searchInput.forceActiveFocus()
                resultModel.rebuild("")
            }
        }

        function close(): void {
            root.launcherOpen = false
        }
    }

    ResultModel {
        id: resultModel
        onLaunched: root.launcherOpen = false
    }

    // Glass Panel Body
    Rectangle {
        anchors.fill: parent
        radius: Root.Theme.radiusLg
        color: Qt.alpha(Root.Theme.colBg, 0.8)
        border.width: 1
        border.color: Root.Theme.colAccent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Root.Theme.spacingLg
            spacing: 0

            // Search Header Box
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: Root.Theme.radiusMd
                color: Root.Theme.colOverlayIdle
                border.width: 1
                border.color: searchInput.activeFocus ? Qt.alpha(Root.Theme.colAccent, 0.4) : Root.Theme.colOverlayIdle

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Root.Theme.spacingLg
                    anchors.rightMargin: Root.Theme.spacingLg
                    spacing: Root.Theme.spacingMd

                    Text {
                        text: "󰍉"
                        font.pixelSize: Root.Theme.fontXl
                        font.family: Root.Theme.fontIcon
                        color: searchInput.activeFocus ? Root.Theme.colAccent : Root.Theme.colMuted

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: searchInput.text.length === 0
                            text: "Search apps, files, bookmarks... (= for calc)"
                            font.pixelSize: Root.Theme.fontLg
                            font.family: Root.Theme.fontFamily
                            color: Root.Theme.colFg
                            opacity: 0.35
                        }

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: Root.Theme.fontLg
                            font.family: Root.Theme.fontFamily
                            color: Root.Theme.colFg
                            clip: true

                            onTextChanged: resultModel.rebuild(text)

                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Escape) {
                                    root.launcherOpen = false
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Down) {
                                    resultList.moveSelection(1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Up) {
                                    resultList.moveSelection(-1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Tab) {
                                    resultList.moveSelection(event.modifiers & Qt.ShiftModifier ? -1 : 1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Backtab) {
                                    resultList.moveSelection(-1)
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    resultModel.activate(resultList.currentIndex)
                                    event.accepted = true
                                }
                            }
                        }
                    }
                }
            }

            // Separator Line
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: Root.Theme.spacingMd
                Layout.bottomMargin: Root.Theme.spacingSm
                height: 1
                color: Root.Theme.colOverlayIdle
            }

            // Results Area
            ListView {
                id: resultList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: resultModel.items
                currentIndex: 0

                function moveSelection(delta) {
                    if (count === 0) return
                    currentIndex = (currentIndex + delta + count) % count
                }

                // Animated Selection Pill (Slides continuously between items)
                highlight: Rectangle {
                    width: resultList.width
                    height: 50
                    radius: Root.Theme.radiusMd
                    color: Qt.alpha(Root.Theme.colAccent, 0.18)
                    border.width: 1
                    border.color: Qt.alpha(Root.Theme.colAccent, 0.3)
                    z: 1
                }
                highlightMoveDuration: 140
                highlightResizeDuration: 0

                delegate: Item {
                    id: delegateItem
                    width: resultList.width
                    height: 50

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Root.Theme.spacingMd
                        anchors.rightMargin: Root.Theme.spacingMd
                        spacing: Root.Theme.spacingMd
                        z: 2

                        // Icon Container
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: Root.Theme.radius
                            color: index === resultList.currentIndex
                                ? Root.Theme.colAccent
                                : Root.Theme.colOverlayIdle

                                Behavior on color { ColorAnimation { duration: 120 } }

                            IconImage {
                                id: iconImg
                                anchors.centerIn: parent
                                implicitSize: 20
                                source: modelData.iconName
                                    ? Quickshell.iconPath(modelData.iconName, "")
                                    : ""
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: iconImg.status !== Image.Ready
                                text: modelData.icon ?? "•"
                                font.pixelSize: Root.Theme.fontLg
                                font.family: Root.Theme.fontIcon
                                color: index === resultList.currentIndex
                                    ? Root.Theme.colBg
                                    : Root.Theme.colFg
                            }
                        }

                        // Labels
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.label
                                font.pixelSize: Root.Theme.fontMd
                                font.weight: Font.Medium
                                font.family: Root.Theme.fontFamily
                                color: Root.Theme.colFg
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: !!modelData.subtitle
                                text: modelData.subtitle ?? ""
                                font.pixelSize: Root.Theme.fontSm
                                font.family: Root.Theme.fontFamily
                                color: Root.Theme.colFg
                                opacity: 0.5
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        // Optional Category Badge
                        Rectangle {
                            visible: !!modelData.badge
                            Layout.preferredHeight: 18
                            implicitWidth: badgeText.implicitWidth + 12
                            radius: Root.Theme.radius
                            color: Root.Theme.colOverlayIdle

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: modelData.badge ?? ""
                                font.pixelSize: Root.Theme.fontXs
                                font.family: Root.Theme.fontFamily
                                color: Root.Theme.colFg
                                opacity: 0.6
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: resultList.currentIndex = index
                        onClicked: resultModel.activate(index)
                    }
                }
            }

            // Footer / Keybindings Bar
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Root.Theme.spacingSm
                Layout.preferredHeight: 20
                spacing: Root.Theme.spacingMd

                // Keycap Helper Component
                component KeyHint: RowLayout {
                    property string keyText: ""
                    property string labelText: ""
                    spacing: 5

                    Rectangle {
                        implicitWidth: keyLabel.implicitWidth + 8
                        implicitHeight: 16
                        radius: Root.Theme.radiusXs
                        color: Root.Theme.colOverlayIdle
                        border.width: 1
                        border.color: Root.Theme.colOverlayHover

                        Text {
                            id: keyLabel
                            anchors.centerIn: parent
                            text: keyText
                            font.pixelSize: Root.Theme.fontXs
                            font.weight: Font.Bold
                            font.family: Root.Theme.fontFamily
                            color: Root.Theme.colFg
                            opacity: 0.8
                        }
                    }

                    Text {
                        text: labelText
                        font.pixelSize: Root.Theme.fontSm
                        font.family: Root.Theme.fontFamily
                        color: Root.Theme.colFg
                        opacity: 0.45
                    }
                }

                KeyHint { keyText: "↑↓ / Tab"; labelText: "navigate" }
                KeyHint { keyText: "↵"; labelText: "open" }
                KeyHint { keyText: "ESC"; labelText: "close" }

                Item { Layout.fillWidth: true }

                Text {
                    text: resultList.count > 0 ? resultList.count + " results" : ""
                    font.pixelSize: Root.Theme.fontSm
                    font.family: Root.Theme.fontFamily
                    color: Root.Theme.colFg
                    opacity: 0.45
                }
            }
        }
    }
}
