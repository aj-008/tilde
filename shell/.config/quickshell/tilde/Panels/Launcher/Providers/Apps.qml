import QtQuick
import Quickshell.Io
import "./Fuzzy.js" as Fuzzy

QtObject {
    id: apps

    property var cache: []
    property bool loaded: false
    signal ready()

    property Process _proc: Process {
        command: ["python3", Qt.resolvedUrl("../scripts/apps.py").toString().replace("file://", "")]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    apps.cache = JSON.parse(text)
                } catch (e) {
                    console.warn("launcher: bad apps.py output", e)
                    apps.cache = []
                }
                apps.loaded = true
                apps.ready()
            }
        }
    }

    function load() {
        _proc.running = true
    }

    function filter(query) {
        return Fuzzy.filterSort(cache, query, a => a.name).slice(0, 8)
    }

    Component.onCompleted: load()
}
