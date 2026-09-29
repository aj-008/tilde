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
        inhibitorProc.running = true;
        active = true;
    }

    function disable() {
        inhibitorProc.running = false;
        active = false;
    }

    property var inhibitorProc: Process {
        command: ["systemd-inhibit", "--what=idle", "--who=Quickshell", "--why=Caffeine active", "sleep", "infinity"]
    }
}
