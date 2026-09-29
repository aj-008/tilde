import QtQuick
import Quickshell.Io
import "./Providers"
import "./Launch.js" as Launch

QtObject {
    id: model

    property var items: []
    signal launched()

    property Apps _apps: Apps {}
    property Bookmarks _bookmarks: Bookmarks {}
    property Files _files: Files {}
    property Calc _calc: Calc {}

    property Timer _fileDebounce: Timer {
        interval: 120
        repeat: false
        onTriggered: model._files.search(model._pendingQuery, files => {
            model._mergeFileResults(files)
        })
    }
    property string _pendingQuery: ""
    property var _fileResults: []

    function rebuild(query) {
        query = query.trim()

        if (query.startsWith("=")) {
            _buildCalcOnly(query.slice(1))
            return
        }

        _fileResults = []
        _pendingQuery = query
        if (query.length >= 2) {
            _fileDebounce.restart()
        }

        _buildStandard(query)
    }

    function _buildCalcOnly(expr) {
        if (!expr.trim()) {
            items = []
            return
        }
        _calc.evaluate(expr, result => {
            items = result ? [{
                type: "calc",
                label: result,
                subtitle: expr,
                icon: "=",
                iconName: Launch.iconNameFor({ type: "calc" }),
                payload: result
            }] : []
        })
    }

    function _buildStandard(query) {
        const results = []

        if (query.length > 0) {
            const apps = _apps.filter(query)
            for (const a of apps) {
                results.push({
                    type: "app", label: a.name, subtitle: a.exec,
                    icon: "󰀻", payload: a
                })
            }

            const bookmarks = _bookmarks.filter(query)
            for (const b of bookmarks) {
                results.push({
                    type: "bookmark", label: b.title || b.url, subtitle: b.url,
                    icon: "󰃀", payload: b
                })
            }

            for (const f of _fileResults) {
                results.push({
                    type: "file", label: f.split("/").pop(), subtitle: f,
                    icon: "󰈔", payload: f
                })
            }

            // Always-available fallback at the bottom.
            results.push({
                type: "websearch", label: `Search qutebrowser for "${query}"`,
                subtitle: "", icon: "󰖟", payload: query
            })
        }

        for (const r of results) {
            r.iconName = Launch.iconNameFor(r)
        }

        items = results
    }

    function _mergeFileResults(files) {
        _fileResults = files
        _buildStandard(_pendingQuery)
    }

    function activate(index) {
        const item = items[index]
        if (!item) return

        const resolved = Launch.resolve(item)
        if (!resolved) return

        if (resolved.clipboard !== undefined) {
            _run(["wl-copy", resolved.clipboard])
        } else if (resolved.argv) {
            _run(resolved.argv)
        }

        model.launched()
    }

    property Process _spawnProc: Process {}

    function _run(argv) {
        if (_spawnProc.running) _spawnProc.running = false
        _spawnProc.command = argv
        _spawnProc.running = true
    }
}
