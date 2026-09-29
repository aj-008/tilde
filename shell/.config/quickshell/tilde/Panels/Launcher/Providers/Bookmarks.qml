import QtQuick
import Quickshell.Io
import "./Fuzzy.js" as Fuzzy

QtObject {
    id: bookmarks

    property var cache: []
    property bool loaded: false
    signal ready()

    property Process _proc: Process {
        command: ["python3", Qt.resolvedUrl("../scripts/bookmarks.py").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    bookmarks.cache = JSON.parse(text)
                } catch (e) {
                    console.warn("launcher: bad bookmarks.py output", e)
                    bookmarks.cache = []
                }
                bookmarks.loaded = true
                bookmarks.ready()
            }
        }
    }

    function load() {
        _proc.running = true
    }

    function filter(query) {
        return Fuzzy.filterSort(cache, query, b => `${b.title} ${b.url}`).slice(0, 6)
    }

    Component.onCompleted: load()
}
