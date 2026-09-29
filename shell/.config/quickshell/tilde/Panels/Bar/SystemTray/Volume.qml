import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "root:/"
import "root:/Services"

RowLayout {
    id: root
    spacing: 6

    property var sink: Pipewire.defaultAudioSink
    property real level: sink ? sink.audio.volume : 0
    property bool muted: sink ? sink.audio.muted : false

    property string iconName: {
        if (root.muted || root.level === 0) return "audio-volume-muted-symbolic"
        if (root.level < 0.33) return "audio-volume-low-symbolic"
        if (root.level < 0.66) return "audio-volume-medium-symbolic"
        return "audio-volume-high-symbolic"
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    SystemTrayIcon { 
        iconName: root.iconName
        color: root.muted ? Theme.colError : Theme.colSysIcon
        onClicked: ControlCenter.openPage("volume")
    }
}
