import QtQuick 2.15
import Qt.labs.folderlistmodel 2.15
import Quickshell
import Quickshell.Io
import "root:/"

FocusScope {
    id: root

    focus: true
    Keys.onEscapePressed: closeRequested()

    signal closeRequested()

    property string wallpaperRoot: "/home/ajrom/Pictures/wallpapers"
    property string currentCategory: ""
    property int coverflowItemCount: 5
    property int matugenDebounceMs: 200

    anchors.fill: parent

    onVisibleChanged: {
        if (visible) {
            root.forceActiveFocus()
        }
    }

    Component.onCompleted: root.forceActiveFocus()

    function closeSelf() {
        root.closeRequested()
    }

    function toFileUrl(path) {
        if (!path) return ""
        let clean = "/" + path.replace(/^\/+|\/+$/g, "")
        return Qt.resolvedUrl("file://" + clean)
    }

    function cycleCategory(forward) {
        if (categoryModel.count <= 1) return
        
        let currentIndex = -1
        for (let i = 0; i < categoryModel.count; i++) {
            if (categoryModel.get(i, "fileName") === root.currentCategory) {
                currentIndex = i
                break
            }
        }

        if (currentIndex === -1) {
            root.currentCategory = categoryModel.get(0, "fileName")
            return
        }

        let nextIndex = forward
            ? (currentIndex + 1) % categoryModel.count
            : (currentIndex - 1 + categoryModel.count) % categoryModel.count

        root.currentCategory = categoryModel.get(nextIndex, "fileName")
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_M) {
            coverflow.decrementCurrentIndex()
            event.accepted = true
        } else if (event.key === Qt.Key_I) {
            coverflow.incrementCurrentIndex()
            event.accepted = true
        } else if (event.key === Qt.Key_Tab) {
            cycleCategory(!(event.modifiers & Qt.ShiftModifier))
            event.accepted = true
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            applyTimer.stop()
            root.applyCurrentWallpaper()
            root.closeSelf()
            event.accepted = true
        } else if (event.key === Qt.Key_Escape) {
            root.closeSelf()
            event.accepted = true
        }
    }

    function applyCurrentWallpaper() {
        if (wallpaperModel.count === 0) return
        const path = wallpaperModel.get(coverflow.currentIndex, "filePath")

        wallpaperProcess.command = [
            "awww", "img", path,
            "--transition-type", "fade",
            "--transition-pos", "0.5,0.5",
            "--transition-duration", "1.6"
        ]
        wallpaperProcess.running = true

        matugenProcess.command = ["matugen", "image", path]
        matugenProcess.running = true

        wallpaperCacheProcess.command = [
            "cp", path, "/etc/greetd/wallpaper.jpg"
        ]
        wallpaperCacheProcess.running = true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.forceActiveFocus()
    }

    // ---------------------------------------------------------------
    // Category Discovery
    // ---------------------------------------------------------------
    FolderListModel {
        id: categoryModel
        folder: root.toFileUrl(root.wallpaperRoot)
        rootFolder: root.toFileUrl(root.wallpaperRoot)

        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        showOnlyReadable: true
        sortField: FolderListModel.Name

        onCountChanged: {
            if (root.currentCategory === "" && count > 0) {
                root.currentCategory = get(0, "fileName")
            }
        }
    }

    // ---------------------------------------------------------------
    // Tab Header (Segmented Control Pill Snapped Above Carousel)
    // ---------------------------------------------------------------
    Item {
        id: header
        anchors.bottom: coverflow.top
        anchors.bottomMargin: Theme.spacingLg
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 40, segmentedContainer.width)
        height: 44
        z: 20

        // Glass background encapsulating all tabs
        Rectangle {
            id: segmentedContainer
            anchors.centerIn: parent
            width: tabRow.width + 12
            height: 44
            radius: Theme.radiusLg
            color: Qt.alpha(Theme.colBg, 0.45)
            border.width: 1
            border.color: Theme.colOverlayIdle

            Flickable {
                anchors.fill: parent
                contentWidth: tabRow.width + 12
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Row {
                    id: tabRow
                    anchors.verticalCenter: parent.verticalCenter
                    x: 6
                    spacing: 4

                    Repeater {
                        model: categoryModel
                        delegate: Item {
                            required property string fileName
                            property bool active: fileName === root.currentCategory

                            width: label.implicitWidth + 24
                            height: 32

                            // Inner active item pill highlight
                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.radiusLg
                                color: active ? Theme.colOverlayHover : "transparent"
                                border.width: active ? 1 : 0
                                border.color: Theme.colOverlayHover

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: fileName
                                color: active ? Theme.colAccent : Qt.alpha(Theme.colFg, 0.5)
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontMd
                                font.weight: active ? Font.DemiBold : Font.Normal

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.currentCategory = fileName
                                    root.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------------------------------------------------------
    // Wallpapers within selected category
    // ---------------------------------------------------------------
    FolderListModel {
        id: wallpaperModel
        folder: root.currentCategory !== "" 
            ? root.toFileUrl(root.wallpaperRoot + "/" + root.currentCategory)
            : ""
        rootFolder: root.toFileUrl(root.wallpaperRoot)

        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
        showDirs: false
        showFiles: true
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    // ---------------------------------------------------------------
    // Coverflow View
    // ---------------------------------------------------------------
    PathView {
        id: coverflow
        anchors.centerIn: parent
        width: parent.width
        height: 420

        model: wallpaperModel
        pathItemCount: root.coverflowItemCount
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightRangeMode: PathView.StrictlyEnforceRange
        snapMode: PathView.SnapOneItem
        interactive: true

        Connections {
            target: root
            function onCurrentCategoryChanged() { coverflow.currentIndex = 0 }
        }

        path: Path {
            startX: -150; startY: coverflow.height / 2
            PathAttribute { name: "itemScale"; value: 0.65 }
            PathAttribute { name: "itemOpacity"; value: 0.3 }
            PathAttribute { name: "itemRotation"; value: 25 }
            PathAttribute { name: "itemZ"; value: 0 }

            PathLine { x: coverflow.width / 2; y: coverflow.height / 2 }
            PathAttribute { name: "itemScale"; value: 1.0 }
            PathAttribute { name: "itemOpacity"; value: 1.0 }
            PathAttribute { name: "itemRotation"; value: 0 }
            PathAttribute { name: "itemZ"; value: 10 }

            PathLine { x: coverflow.width + 150; y: coverflow.height / 2 }
            PathAttribute { name: "itemScale"; value: 0.65 }
            PathAttribute { name: "itemOpacity"; value: 0.3 }
            PathAttribute { name: "itemRotation"; value: -25 }
            PathAttribute { name: "itemZ"; value: 0 }
        }

        delegate: Item {
            id: delegateRoot
            required property string fileName
            required property string filePath
            required property url fileUrl
            required property int index

            width: 640
            height: 360
            scale: PathView.itemScale ?? 1.0
            opacity: PathView.itemOpacity ?? 1.0
            z: PathView.itemZ ?? 0

            transform: Rotation {
                origin.x: delegateRoot.width / 2
                origin.y: delegateRoot.height / 2
                axis { x: 0; y: 1; z: 0 }
                angle: delegateRoot.PathView.itemRotation ?? 0
            }

            Rectangle {
                anchors.fill: parent
                radius: Theme.radius + 6
                color: Theme.colSurface
                border.width: PathView.isCurrentItem ? 2 : 1
                border.color: PathView.isCurrentItem ? Theme.colAccent : Theme.colBorder

                Behavior on border.color { ColorAnimation { duration: 150 } }

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: fileUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    layer.enabled: true
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.forceActiveFocus()
                    coverflow.currentIndex = index
                }
                onDoubleClicked: {
                    coverflow.currentIndex = index
                    applyTimer.stop()
                    root.applyCurrentWallpaper()
                    root.closeSelf()
                }
            }
        }

        onCurrentIndexChanged: applyTimer.restart()
    }

    Timer {
        id: applyTimer
        interval: root.matugenDebounceMs
        repeat: false
        onTriggered: root.applyCurrentWallpaper()
    }

    Process { id: wallpaperProcess }
    Process { id: wallpaperCacheProcess }
    Process {
        id: matugenProcess
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && typeof Theme.loadColors === "function") {
                Theme.loadColors()
            }
        }
    }
}
