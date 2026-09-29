import QtQuick
import QtQuick.Layouts
import "root:/" as Root

Rectangle {
    id: root
    property string label: ""
    property string icon: ""
    property bool active: false
    property bool toggleOnClick: true // Add this property
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: width
    radius: Root.Theme.radiusLg

    color: active
        ? Qt.alpha(Root.Theme.colAccent, 0.2)
        : (mouseArea.containsMouse ? Root.Theme.colOverlayHover : Root.Theme.colOverlayIdle)

    border.width: 1
    border.color: active
        ? Root.Theme.colAccent
        : (mouseArea.containsMouse ? Qt.alpha(Root.Theme.colAccent, 0.3) : Root.Theme.colOverlayIdle)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Root.Theme.spacingMd
        spacing: Root.Theme.spacingSm

        Item { Layout.fillHeight: true }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: Root.Theme.radius
            color: root.active ? Root.Theme.colAccent : Root.Theme.colOverlayIdle

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: Root.Theme.fontLg
                font.family: Root.Theme.fontIcon
                color: root.active ? Root.Theme.colBg : Root.Theme.colFg
            }
        }

        Text {
            text: root.label
            font.pixelSize: Root.Theme.fontMd
            font.weight: Font.Medium
            font.family: Root.Theme.fontFamily
            color: Root.Theme.colFg
            elide: Text.ElideRight
            Layout.alignment: Qt.AlignHCenter
        }

        Item { Layout.fillHeight: true }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.toggleOnClick) {
                root.active = !root.active
            }
            root.clicked()
        }
    }
}
