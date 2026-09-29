import QtQuick
import Quickshell.Io

QtObject {
    id: calc

    signal result(string value)

    property Process _proc: Process {
        stdout: StdioCollector {
            onStreamFinished: calc.result(text.trim())
        }
    }

    function evaluate(expr, callback) {
        if (!expr.trim()) {
            callback(null)
            return
        }
        if (_proc.running) _proc.running = false

        _proc.command = ["qalc", "-t", expr]

        const handler = (value) => {
            calc.result.disconnect(handler)
            callback(value || null)
        }
        calc.result.connect(handler)
        _proc.running = true
    }
}
