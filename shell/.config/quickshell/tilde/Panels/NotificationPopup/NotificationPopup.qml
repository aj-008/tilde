import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "root:/" as Root
import "root:/Services" as Services

PanelWindow {
    id: popupWindow

    anchors {
        top: true
        right: true
    }

    margins {
        top: 12
        right: 12
    }

    implicitWidth: 340
    implicitHeight: contentColumn.implicitHeight
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayershell.Overlay
    color: "transparent"

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 8

        Repeater {
            model: Services.Notifications.active

            delegate: Rectangle {
                id: toastCard
                required property var modelData

                Layout.fillWidth: true
                implicitHeight: cardContent.implicitHeight + 20
                radius: Root.Theme.radiusMd
                color: Qt.alpha(Root.Theme.colBg, 0.88)
                border.width: 1
                border.color: Root.Theme.colOverlayHover

                RowLayout {
                    id: cardContent
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignTop
                        radius: Root.Theme.radius
                        color: Root.Theme.colOverlayIdle

                        Text {
                            anchors.centerIn: parent
                            text: Root.Theme.icons.bell
                            font.pixelSize: Root.Theme.fontLg
                            font.family: Root.Theme.fontIcon
                            color: Root.Theme.colAccent
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: modelData.summary || "Notification"
                            font.pixelSize: Root.Theme.fontMd
                            font.weight: Font.Bold
                            font.family: Root.Theme.fontFamily
                            color: Root.Theme.colFg
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: !!modelData.body
                            text: modelData.body || ""
                            font.pixelSize: Root.Theme.fontSm
                            font.family: Root.Theme.fontFamily
                            color: Root.Theme.colFg
                            opacity: 0.7
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.Notifications.dismiss(modelData.id)
                }
            }
        }
    }
}
