import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "root:/"

RowLayout {
    id: root
    spacing: 4
    property real usedPercent: 0

    FileView { id: memFile; path: "/proc/meminfo" }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memFile.reload()
    }

    Connections {
        target: memFile
        function onLoaded() {
            const lines = memFile.text().split("\n")
            const total = parseInt(lines[0].match(/\d+/)[0])
            const avail = parseInt(lines.find(l => l.startsWith("MemAvailable")).match(/\d+/)[0])
            root.usedPercent = ((total - avail) / total) * 100
        }
    }


    Text {
        text: "󰍛"
        font.family: Theme.fontIcon
        font.pointSize: Theme.trayIconSize
        color: root.usedPercent > 85 ? Theme.colError : Theme.colSysIcon
    }
    Text {
        text: Math.round(root.usedPercent) + "%"
        color: Theme.colSysText
        font { family: Theme.fontFamily; pointSize: Theme.trayFontSize }
    }
}
