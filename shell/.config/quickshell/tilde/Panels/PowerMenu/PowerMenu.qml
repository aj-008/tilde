import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../" // Resolves root Theme.qml

Scope {
    id: root

    property bool isOpen: false

    function open() {
        isOpen = true;
        selectedIndex = 0;
        window.requestActivate();
    }

    function close() {
        isOpen = false;
    }

    function toggle() {
        if (isOpen) close();
        else open();
    }

    IpcHandler {
        target: "power_menu"

        function open() { root.open(); }
        function close() { root.close(); }
        function toggle() { root.toggle(); }
    }

    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }
    Process { id: rebootProc;   command: ["systemctl", "reboot"] }
    Process { id: suspendProc;  command: ["systemctl", "suspend"] }

    property int selectedIndex: 0

    readonly property var actions: [
        {
            "id": "shutdown",
            "label": "Power Off",
            "icon": Theme.icons.power,
            "color": Theme.colError,
            "exec": () => shutdownProc.running = true
        },
        {
            "id": "reboot",
            "label": "Reboot",
            "icon": Theme.icons.reboot,
            "color": Theme.colAccent,
            "exec": () => rebootProc.running = true
        },
        {
            "id": "suspend",
            "label": "Sleep",
            "icon": Theme.icons.sleep,
            "color": Theme.colTertiary,
            "exec": () => suspendProc.running = true
        }
    ]

    function triggerSelected() {
        const action = actions[selectedIndex];
        close();
        action.exec();
    }

    PanelWindow {
        id: window
        visible: root.isOpen

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // Darkened overlay background
        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(Theme.colBg, 0.8)

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }
        }

        // Keyboard navigation handler
        Item {
            anchors.fill: parent
            focus: window.visible

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_M) {
                    root.selectedIndex = (root.selectedIndex - 1 + root.actions.length) % root.actions.length;
                    event.accepted = true;
                } else if (event.key === Qt.Key_I) {
                    root.selectedIndex = (root.selectedIndex + 1) % root.actions.length;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.triggerSelected();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Escape) {
                    root.close();
                    event.accepted = true;
                }
            }
        }

        // Scaled Floating Center Card
        Rectangle {
            anchors.centerIn: parent
            width: contentLayout.implicitWidth + 60
            height: contentLayout.implicitHeight + 60
            radius: Theme.radius * 2.5
            color: Theme.colBg
            border.color: Theme.colBorder
            border.width: 1

            // Prevent closing when clicking card background
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => mouse.accepted = true
            }

            RowLayout {
                id: contentLayout
                anchors.centerIn: parent
                spacing: 24

                Repeater {
                    model: root.actions

                    PowerButton {
                        required property var modelData
                        required property int index

                        icon: modelData.icon
                        label: modelData.label
                        activeColor: modelData.color
                        selected: root.selectedIndex === index

                        onClicked: {
                            root.selectedIndex = index;
                            root.triggerSelected();
                        }
                    }
                }
            }
        }
    }
}
