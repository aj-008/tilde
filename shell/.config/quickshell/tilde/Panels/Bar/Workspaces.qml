import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "root:/"

RowLayout {
    Repeater {
        model: 8
        Rectangle {
            property var ws: Hyprland.workspaces.values.find(w => w.id == index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            Layout.preferredWidth: isActive ? 14 : 10
            Layout.preferredHeight: isActive ? 14 : 10
            radius: width / 2

            border.color: Theme.colMuted
            border.width: 1
            color: isActive ? Theme.colAccent : (ws ? Theme.colMuted : "transparent")

            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
            }
            Behavior on Layout.preferredHeight {
                NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
