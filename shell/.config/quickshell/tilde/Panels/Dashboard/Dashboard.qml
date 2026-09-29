import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "./Widgets" as Widgets
import "root:/"

PanelWindow {
    id: root
    visible: false
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell:dashboard"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    focusable: true

    anchors { top: true; bottom: true; left: true; right: true }

    Item {
        id: overlayLayer
        anchors.fill: parent
        z: 999
    }

    IpcHandler {
        target: "dashboard"
        function toggle(): void { root.visible = !root.visible }
        function open(): void { root.visible = true }
        function hide(): void { root.visible = false }
    }

    property int _tick: 0
    property var activePlayer: {
        _tick
        var list = Mpris.players.values
        for (var i = 0; i < list.length; i++) if (list[i].isPlaying) return list[i]
        return list.length > 0 ? list[0] : null
    }
    Instantiator {
        model: Mpris.players.values
        delegate: Connections {
            target: modelData
            function onIsPlayingChanged() { root._tick++ }
        }
    }

    onVisibleChanged: {
        if (visible) focusGrabber.forceActiveFocus()
        else FocusState.fullscreenItem = null 
    }

    Item {
        id: focusGrabber
        anchors.fill: parent
        focus: true

        readonly property int widgetSpacing: 80

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Space) {
                var p = activePlayer
                if (p) p.isPlaying = !p.isPlaying
                event.accepted = true
            } else if (event.key === Qt.Key_F && !event.isAutoRepeat) {
                if (FocusState.active) {
                    FocusState.fullscreenItem = null
                    event.accepted = true
                } else if (mediaWidget.hovered) {
                    mediaWidget.toggleFullscreen()
                    event.accepted = true
                }
            } else if (event.key === Qt.Key_Escape && FocusState.active) {
                FocusState.fullscreenItem = null
                event.accepted = true
            }
        }

        Image {
            id: bg
            anchors.fill: parent
            source: Theme.wallpaperPath ? "file://" + Theme.wallpaperPath : ""
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
            sourceSize: Qt.size(root.width, root.height)
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.35
        }

        Widgets.Clock {
            id: clockWidget
            anchors.centerIn: parent
            width: 800
            height: 150
 
            opacity: FocusState.active ? 0 : 1
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 220 } }
        }

        Row {
            id: bottomRow
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 24
            }
            spacing: 250

            Widgets.Media {
                id: mediaWidget
                radius: Theme.radius
                player: root.activePlayer
                overlayLayer: overlayLayer
                normalWidth: 360
                normalHeight: 150

                opacity: FocusState.active && !isFullscreen ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 220 } }
            }

            Widgets.WeatherCard {
                id: weatherWidget
                width: 360
                height: 150

                opacity: FocusState.active ? 0 : 1
            }

            Widgets.QuoteWidget {
                id: quoteWidget
                width: 400
                height: 150

                opacity: FocusState.active ? 0 : 1
            }
        }
    }
}
