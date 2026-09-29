// Panels/Dashboard/QuoteWidget.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import QtQml
import Qt5Compat.GraphicalEffects
import "root:/"

Item {
    id: root

    readonly property int imageSize: 80
    readonly property int imageRadius: Theme.radiusMd
    readonly property int cardPadding: Theme.spacingLg
    readonly property int cacheMaxAgeMs: 24 * 60 * 60 * 1000
    readonly property string cachePath: Quickshell.stateDir + "/quote-cache.json"

    property string quoteText: ""
    property string quoteAuthor: ""
    property string quoteImage: ""
    property bool loading: true
    property bool imageFailed: false

    Component.onCompleted: readCache.running = true

    function slugify(name) {
        return name.toLowerCase()
            .replace(/\./g, "")
            .replace(/[^a-z0-9]+/g, "-")
            .replace(/(^-+|-+$)/g, "")
    }

    function applyQuote(q, a) {
        quoteText = q
        quoteAuthor = a
        quoteImage = "https://zenquotes.io/img/" + slugify(a) + ".jpg"
        imageFailed = false
        loading = false
    }

    function writeCache(q, a) {
        const payload = JSON.stringify({ q: q, a: a, fetchedAt: Date.now() })
        const b64 = Qt.btoa(payload)
        writeCacheProc.command = ["sh", "-c", "echo " + b64 + " | base64 -d > '" + root.cachePath + "'"]
        writeCacheProc.running = true
    }

    Process {
        id: readCache
        command: ["cat", root.cachePath]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0) {
                    fetchProc.running = true
                    return
                }
                try {
                    const cached = JSON.parse(text)
                    const isExpired = (Date.now() - (cached.fetchedAt || 0)) > root.cacheMaxAgeMs

                    if (isExpired) {
                        // Expired: fetch fresh quote directly
                        fetchProc.running = true
                    } else {
                        // Valid cache: apply immediately
                        root.applyQuote(cached.q, cached.a)
                    }
                } catch (e) {
                    fetchProc.running = true
                }
            }
        }
    }

    Process {
        id: fetchProc
        command: ["curl", "-s", "--max-time", "8", "https://zenquotes.io/api/random"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text)[0]
                    root.applyQuote(data.q, data.a)
                    root.writeCache(data.q, data.a)
                } catch (e) {
                    root.loading = false
                    console.warn("QuoteWidget: fetch failed", e)
                }
            }
        }
    }

    Process { id: writeCacheProc }

    implicitHeight: layout.implicitHeight + cardPadding * 2
    implicitWidth: 360

    RowLayout {
        id: layout
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: cardPadding
        }
        spacing: 14

        Rectangle {
            visible: !root.imageFailed && root.quoteImage.length > 0
            Layout.preferredWidth: imageSize
            Layout.preferredHeight: imageSize
            Layout.alignment: Qt.AlignTop
            color: Theme.colMuted
            radius: imageRadius
            clip: true

            Image {
                id: quoteArt
                anchors.fill: parent
                source: root.quoteImage
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: quoteArt.width
                        height: quoteArt.height
                        radius: imageRadius
                    }
                }
                onStatusChanged: if (status === Image.Error) root.imageFailed = true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: root.loading ? "Loading quote…" : "\u201C" + root.quoteText + "\u201D"
                wrapMode: Text.WordWrap
                color: Theme.colText
                font.family: Theme.fontFamily
                font.pointSize: Theme.fontSize + 2
            }

            Text {
                visible: !root.loading
                text: "— " + root.quoteAuthor
                color: Theme.colSecondary
                font.family: Theme.fontFamily
                font.pointSize: Theme.fontSize - 1
            }
        }
    }
}
