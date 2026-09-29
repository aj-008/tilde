// Cava.qml
import QtQuick
import Quickshell
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import "root:/"
Item {
    id: root
    property int barCount: 18 // must be divis by 6
    property int maxRange: 100
    property real smoothing: 0.35 // 0 = instant, 1 = frozen
    property color barColor: Theme.colAccent
    property var rawValues: []
    property var displayValues: []

    property real leftInset: 0
    property real rightInset: -15

    property real cornerRadius: 0
    property real heightScale: 0.75
    property real strokeWidthScale: 1.0

    property bool glowEnabled: false
    readonly property real glowRadius: 28
    readonly property real glowSamples: 24
    readonly property real glowStrength: 0.9

    readonly property real strokeWidth: 2
    readonly property real fillOpacityBottom: 0.75
    readonly property real fillOpacityTop: 0.0

    readonly property string configPath: Quickshell.stateDir + "/cava-dashboard.conf"

    property bool pendingRestart: false

    function restart() {
        if (cava.running) {
            pendingRestart = true
            cava.running = false
        } else {
            configWriter.running = true
        }
    }
    onBarCountChanged: restart()

    Connections {
        target: cava
        function onRunningChanged() {
            if (!cava.running && root.pendingRestart) {
                root.pendingRestart = false
                configWriter.running = true
            }
        }
    }

    Process {
        id: configWriter
        command: ["sh", "-c",
            "mkdir -p \"$(dirname '" + root.configPath + "')\" && cat > '" + root.configPath + "' <<'EOF'\n" +
            "[general]\n" +
            "bars = " + root.barCount + "\n" +
            "framerate = 60\n" +
            "[input]\n" +
            "method = pulse\n" +
            "source = auto\n" +
            "[output]\n" +
            "method = raw\n" +
            "raw_target = /dev/stdout\n" +
            "data_format = ascii\n" +
            "ascii_max_range = " + root.maxRange + "\n" +
            "bar_delimiter = 59\n" +
            "frame_delimiter = 10\n" +
            "[smoothing]\n" +
            "noise_reduction = 44\n" +
            "EOF"
        ]
        running: true
        onExited: cava.running = true
    }
    Process {
        id: cava
        command: ["cava", "-p", root.configPath]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                if (!line || line.trim().length === 0) return
                root.rawValues = line.trim().split(";").map(v => parseInt(v) || 0)
            }
        }
    }
    onRawValuesChanged: {
        if (displayValues.length !== rawValues.length) {
            displayValues = rawValues.slice()
        } else {
            for (let i = 0; i < rawValues.length; i++) {
                displayValues[i] = displayValues[i] * smoothing + rawValues[i] * (1 - smoothing)
            }
        }
        canvas.requestPaint()
    }
    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        layer.enabled: root.glowEnabled
        layer.effect: Glow {
            radius: root.glowRadius
            samples: root.glowSamples
            color: root.barColor
            transparentBorder: true
            spread: 0.25 * root.glowStrength
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        function barPoints() {
            const n = root.displayValues.length
            const pts = []
            const usableWidth = Math.max(0, width - root.leftInset - root.rightInset)
            const maxBarHeight = height * root.heightScale
            for (let i = 0; i < n; i++) {
                const v = Math.max(0, Math.min(root.displayValues[i], root.maxRange))
                const h = (v / root.maxRange) * maxBarHeight
                const x = n > 1 ? root.leftInset + (i / (n - 1)) * usableWidth : width / 2
                const y = height - h
                pts.push({ x: x, y: y })
            }
            return pts
        }

        function tracePath(ctx, pts) {
            const n = pts.length
            ctx.moveTo(pts[0].x, pts[0].y)
            for (let i = 0; i < n - 1; i++) {
                const p0 = i === 0 ? pts[0] : pts[i - 1]
                const p1 = pts[i]
                const p2 = pts[i + 1]
                const p3 = (i + 2 < n) ? pts[i + 2] : pts[n - 1]

                const cp1x = p1.x + (p2.x - p0.x) / 6
                const cp1y = p1.y + (p2.y - p0.y) / 6
                const cp2x = p2.x - (p3.x - p1.x) / 6
                const cp2y = p2.y - (p3.y - p1.y) / 6

                ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y)
            }
        }

        function closeRoundedBottom(ctx, pts) {
            const r = Math.max(0, Math.min(root.cornerRadius, height / 2, width / 2))
            const last = pts[pts.length - 1]

            ctx.lineTo(width, last.y)
            ctx.lineTo(width, height - r)
            ctx.quadraticCurveTo(width, height, width - r, height)
            ctx.lineTo(r, height)
            ctx.quadraticCurveTo(0, height, 0, height - r)
            ctx.lineTo(0, pts[0].y)
            ctx.closePath()
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            const pts = barPoints()
            if (pts.length < 2) return

            const gradient = ctx.createLinearGradient(0, height * (1 - root.heightScale), 0, height)
            gradient.addColorStop(0, Qt.rgba(root.barColor.r, root.barColor.g, root.barColor.b, root.fillOpacityTop))
            gradient.addColorStop(1, Qt.rgba(root.barColor.r, root.barColor.g, root.barColor.b, root.fillOpacityBottom))

            ctx.beginPath()
            tracePath(ctx, pts)
            closeRoundedBottom(ctx, pts)
            ctx.fillStyle = gradient
            ctx.fill()

            ctx.beginPath()
            tracePath(ctx, pts)
            ctx.strokeStyle = root.barColor
            ctx.lineWidth = root.strokeWidth * root.strokeWidthScale
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            ctx.stroke()
        }
    }
    Component.onDestruction: cava.running = false
}
