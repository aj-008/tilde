import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "root:/" as Root
import "root:/Services" as Services

Rectangle {
    id: root
    property var entry

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 18
    radius: Root.Theme.radiusMd

    color: mouseArea.containsMouse
        ? Root.Theme.colOverlayHover
        : Root.Theme.colOverlayIdle
    border.width: 1
    border.color: Root.Theme.colOverlayIdle

    Behavior on color { ColorAnimation { duration: 120 } }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Root.Theme.spacingSm
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            Layout.alignment: Qt.AlignTop
            radius: Root.Theme.radius
            color: Root.Theme.colOverlayIdle

            IconImage {
                id: iconImg
                anchors.centerIn: parent
                implicitSize: 16
                source: root.entry && root.entry.icon
                    ? Quickshell.iconPath(root.entry.icon, "")
                    : ""
            }

            Text {
                anchors.centerIn: parent
                visible: iconImg.status !== Image.Ready
                text: Root.Theme.icons.bell
                font.pixelSize: Root.Theme.fontMd
                font.family: Root.Theme.fontIcon
                color: Root.Theme.colAccent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                text: root.entry ? (root.entry.summary ?? "Notification") : ""
                font.pixelSize: Root.Theme.fontMd
                font.weight: Font.DemiBold
                font.family: Root.Theme.fontFamily
                color: Root.Theme.colFg
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: !!(root.entry && root.entry.body)
                text: root.entry ? (root.entry.body ?? "") : ""
                font.pixelSize: Root.Theme.fontSm
                font.family: Root.Theme.fontFamily
                color: Root.Theme.colFg
                opacity: 0.55
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: Root.Theme.radius
            color: closeMouseArea.containsMouse ? Root.Theme.colOverlayHover : "transparent"

            Text {
                anchors.centerIn: parent
                text: Root.Theme.icons.close
                font.pixelSize: Root.Theme.fontXs
                font.family: Root.Theme.fontIcon
                color: Root.Theme.colFg
                opacity: 0.6
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.entry && root.entry.id !== undefined) {
                        Services.Notifications.removeFromHistory(root.entry.id)
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
