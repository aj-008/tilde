pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool active: false

    function toggle() {
        if (active) disable();
        else enable();
    }

    function enable() {
        enableProc.running = true;
        active = true;
    }

    function disable() {
        disableProc.running = true;
        active = false;
    }

    property var enableProc: Process {
        command: ["hyprshade", "on", "blue-light-filter"] 
    }

    property var disableProc: Process {
        command: ["hyprshade", "off"]
    }
}
