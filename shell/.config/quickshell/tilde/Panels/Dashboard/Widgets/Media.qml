// Media.qml
import Quickshell.Services.Mpris
import QtQml
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "root:/"
Rectangle {
    id: mediaWidget
    property var player
    property Item overlayLayer: null
    readonly property alias hovered: hoverHandler.hovered

    property real normalWidth: 400
    property real normalHeight: 150

    readonly property int artSize: 100
    readonly property int artRadius: 20
    readonly property int contentMargins: 14
    readonly property int sectionSpacing: 10
    readonly property int textSpacing: 2
    readonly property int titleSize: 18
    readonly property int artistSize: 13
    readonly property int progressHeight: 4
    readonly property int progressRadius: 2
    readonly property int controlSpacing: 22
    readonly property int controlIconSize: 18
    readonly property real artPlaceholderOpacity: 0.5
    readonly property real cavaOpacity: 0.16
    readonly property int cavaFadeDuration: 300
    readonly property int positionTickMs: 250

    readonly property int fullscreenWidth: 900
    readonly property int fullscreenHeight: 400
    readonly property int fullscreenArtSize: 300
    readonly property int fullscreenContentMargins: 40
    readonly property int fullscreenSectionSpacing: 24
    readonly property int fullscreenTextSpacing: 8
    readonly property int fullscreenTitleSize: 40
    readonly property int fullscreenArtistSize: 22
    readonly property int fullscreenProgressHeight: 8
    readonly property int fullscreenProgressRadius: 4
    readonly property int fullscreenControlSpacing: 40
    readonly property int fullscreenControlIconSize: 30
    readonly property real fullscreenCavaHeightScale: 0.75
    readonly property int fullscreenCavaBarCount: 36
    readonly property real fullscreenCavaStrokeWidthScale: 2.0
    readonly property int transitionDuration: 260

    property real displayPosition: player?.position ?? 0
    readonly property bool isFullscreen: FocusState.fullscreenItem === mediaWidget

    width: isFullscreen ? fullscreenWidth : normalWidth
    height: isFullscreen ? fullscreenHeight : normalHeight

    radius: Theme.radius
    color: Qt.alpha(Theme.colBg, 0.3)
    border.color: Theme.colOverlayIdle
    border.width: 1
    clip: true

    Behavior on width { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
    Behavior on height { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
    Behavior on x { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }

    HoverHandler {
        id: hoverHandler
    }

    function toggleFullscreen() {
        if (!overlayLayer) {
            console.warn("Media.qml: overlayLayer not set, can't fullscreen")
            return
        }
        FocusState.fullscreenItem = mediaWidget.isFullscreen ? null : mediaWidget
    }

    function exitFullscreen() {
        if (mediaWidget.isFullscreen) FocusState.fullscreenItem = null
    }

    states: [
        State {
            name: "fullscreen"
            when: mediaWidget.isFullscreen
            ParentChange {
                target: mediaWidget
                parent: mediaWidget.overlayLayer
            }
            AnchorChanges {
                target: mediaWidget
                anchors.top: undefined
                anchors.bottom: undefined
                anchors.left: undefined
                anchors.right: undefined
                anchors.horizontalCenter: mediaWidget.overlayLayer ? mediaWidget.overlayLayer.horizontalCenter : undefined
                anchors.verticalCenter: mediaWidget.overlayLayer ? mediaWidget.overlayLayer.verticalCenter : undefined
            }
            PropertyChanges {
                target: mediaWidget
                z: 1000
            }
        }
    ]

    Rectangle {
        visible: mediaWidget.isFullscreen
        parent: mediaWidget.overlayLayer ?? mediaWidget
        anchors.fill: parent
        color: Qt.alpha(Theme.colBg, 0.55)
        z: 999
    }

    Connections {
        target: mediaWidget.player
        function onPositionChanged() {
            mediaWidget.displayPosition = mediaWidget.player.position
        }
    }
    onPlayerChanged: displayPosition = player?.position ?? 0

    Timer {
        interval: mediaWidget.positionTickMs
        running: mediaWidget.player?.isPlaying ?? false
        repeat: true
        onTriggered: {
            if (mediaWidget.player && mediaWidget.player.length > 0) {
                mediaWidget.displayPosition = Math.min(
                    mediaWidget.displayPosition + interval / 1000,
                    mediaWidget.player.length
                )
            }
        }
    }

    Cava {
        anchors.fill: parent
        opacity: mediaWidget.player?.isPlaying ? mediaWidget.cavaOpacity : 0
        barCount: mediaWidget.isFullscreen ? mediaWidget.fullscreenCavaBarCount : 18
        strokeWidthScale: mediaWidget.isFullscreen ? mediaWidget.fullscreenCavaStrokeWidthScale : 1.0
        glowEnabled: mediaWidget.isFullscreen
        leftInset: 0
        rightInset: -20
        cornerRadius: mediaWidget.radius
        heightScale: mediaWidget.isFullscreen ? mediaWidget.fullscreenCavaHeightScale : 1.0

        Behavior on leftInset { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
        Behavior on rightInset { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
        Behavior on heightScale { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
        Behavior on strokeWidthScale { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
        Behavior on opacity {
            NumberAnimation { duration: mediaWidget.cavaFadeDuration; easing.type: Easing.OutQuad }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: mediaWidget.isFullscreen ? mediaWidget.fullscreenContentMargins : mediaWidget.contentMargins
        spacing: mediaWidget.isFullscreen ? mediaWidget.fullscreenSectionSpacing : mediaWidget.sectionSpacing

        Behavior on anchors.margins { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }

        Rectangle {
            readonly property int size: mediaWidget.isFullscreen ? mediaWidget.fullscreenArtSize : mediaWidget.artSize
            Layout.preferredWidth: size
            Layout.preferredHeight: size
            Layout.alignment: Qt.AlignVCenter
            radius: mediaWidget.artRadius
            color: mediaArt.status === Image.Ready ? "transparent" : Theme.colMuted
            clip: true

            Behavior on Layout.preferredWidth { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
            Behavior on Layout.preferredHeight { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }

            Image {
                id: mediaArt
                anchors.fill: parent
                source: mediaWidget.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                opacity: source != "" ? 0.6 : mediaWidget.artPlaceholderOpacity

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: mediaArt.width
                        height: mediaArt.height
                        radius: mediaWidget.artRadius
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: mediaWidget.isFullscreen ? mediaWidget.fullscreenSectionSpacing : mediaWidget.sectionSpacing

            ColumnLayout {
                Layout.fillWidth: true
                spacing: mediaWidget.isFullscreen ? mediaWidget.fullscreenTextSpacing : mediaWidget.textSpacing

                Text {
                    Layout.fillWidth: true
                    text: mediaWidget.player?.trackTitle || "No media playing"
                    color: Theme.colFg
                    font.bold: true
                    font.pixelSize: mediaWidget.isFullscreen ? mediaWidget.fullscreenTitleSize : mediaWidget.titleSize
                    elide: Text.ElideRight

                    Behavior on font.pixelSize { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
                }
                Text {
                    Layout.fillWidth: true
                    text: mediaWidget.player?.trackArtist || ""
                    color: Theme.colMuted
                    font.pixelSize: mediaWidget.isFullscreen ? mediaWidget.fullscreenArtistSize : mediaWidget.artistSize
                    elide: Text.ElideRight
                    visible: text.length > 0

                    Behavior on font.pixelSize { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: mediaWidget.isFullscreen ? mediaWidget.fullscreenSectionSpacing * 0.5 : 0
                height: mediaWidget.isFullscreen ? mediaWidget.fullscreenProgressHeight : mediaWidget.progressHeight
                radius: mediaWidget.isFullscreen ? mediaWidget.fullscreenProgressRadius : mediaWidget.progressRadius
                color: Theme.colMuted

                Behavior on height { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }
                Behavior on radius { NumberAnimation { duration: mediaWidget.transitionDuration; easing.type: Easing.OutCubic } }

                Rectangle {
                    height: parent.height
                    radius: parent.radius
                    color: Theme.colAccent
                    width: mediaWidget.player && mediaWidget.player.length > 0
                        ? parent.width * (mediaWidget.displayPosition / mediaWidget.player.length)
                        : 0

                    Behavior on width {
                        NumberAnimation { duration: mediaWidget.positionTickMs; easing.type: Easing.Linear }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: mediaWidget.isFullscreen ? mediaWidget.fullscreenSectionSpacing * 0.5 : 0
                spacing: mediaWidget.isFullscreen ? mediaWidget.fullscreenControlSpacing : mediaWidget.controlSpacing

                IconButton {
                    icon: "⏮"
                    iconSize: mediaWidget.isFullscreen ? mediaWidget.fullscreenControlIconSize : mediaWidget.controlIconSize
                    onClicked: mediaWidget.player?.previous()
                }
                IconButton {
                    icon: mediaWidget.player?.isPlaying ? "⏸" : "▶"
                    iconSize: mediaWidget.isFullscreen ? mediaWidget.fullscreenControlIconSize : mediaWidget.controlIconSize
                    onClicked: mediaWidget.player && (mediaWidget.player.isPlaying = !mediaWidget.player.isPlaying)
                }
                IconButton {
                    icon: "⏭"
                    iconSize: mediaWidget.isFullscreen ? mediaWidget.fullscreenControlIconSize : mediaWidget.controlIconSize
                    onClicked: mediaWidget.player?.next()
                }
            }
        }
    }
}
