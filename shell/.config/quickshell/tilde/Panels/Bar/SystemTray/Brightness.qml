import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "root:/"

RowLayout {
    id: root
    spacing: 4
    property int current: 0
    property int max: 1

    FileView {
        path: "/sys/class/backlight/intel_backlight/brightness"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.current = parseInt(text())
    }
    FileView {
        path: "/sys/class/backlight/intel_backlight/max_brightness"
        onLoaded: root.max = parseInt(text())
    }

    SystemTrayIcon {
        iconName: "display-brightness-symbolic"
        color: Theme.colSysIcon
        size: Theme.trayIconSize
    }
    Text {
        text: Math.round((root.current / root.max) * 100) + "%"
        color: Theme.colSysText
        font { family: Theme.fontFamily; pointSize: Theme.fontSize }
    }
}
