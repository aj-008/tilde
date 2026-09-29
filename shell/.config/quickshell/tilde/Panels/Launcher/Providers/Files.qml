import QtQuick
import Quickshell.Io

QtObject {
    id: files

    // Folders to search, in priority order. Edit to taste.
    property var searchDirs: [
        "/home/ajrom/projects",
        "/home/ajrom/pdf"
    ]

    signal results(var files)

    property Process _proc: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").filter(l => l.length > 0)
                files.results(lines.slice(0, 20))
            }
        }
    }

    function search(query, callback) {
        if (!query || query.length < 2) {
            callback([])
            return
        }
        if (_proc.running) _proc.running = false 

        _proc.command = [
            "fd", "--type", "f", "--ignore-case", "--max-results", "20",
            query, ...searchDirs
        ]

        const handler = (list) => {
            files.results.disconnect(handler)
            callback(list)
        }
        files.results.connect(handler)
        _proc.running = true
    }
}
