pragma Singleton
import QtQuick 
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property bool radioEnabled: true
    property bool scanning: false
    property bool polling: false
    property var networks: []   
    property string lastError: ""

    function splitTerse(line) {
        const fields = []
        let cur = ""
        for (let i = 0; i < line.length; i++) {
            if (line[i] === "\\" && line[i + 1] === ":") {
                cur += ":"
                i++
            } else if (line[i] === ":") {
                fields.push(cur)
                cur = ""
            } else {
                cur += line[i]
            }
        }
        fields.push(cur)
        return fields
    }

    Timer {
        interval: 4000
        running: root.polling
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "active,ssid,signal,security", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const knownNames = knownProc.lastNames
                root.networks = this.text.split("\n")
                    .filter(l => l.length > 0)
                    .map(l => {
                        const [active, ssid, signal, security] = root.splitTerse(l)
                        return {
                            ssid: (ssid || "").trim(),
                            signal: parseInt(signal) || 0,
                            security: security || "",
                            active: active === "yes",
                            known: knownNames.includes(ssid)
                        }
                    })
                    // Filter out empty SSIDs (hidden networks or empty output lines)
                    .filter(n => n.ssid.length > 0)
                    .reduce((acc, n) => {
                        const existing = acc.find(x => x.ssid === n.ssid)
                        if (!existing) {
                            acc.push(n)
                        } else if (n.active) {
                            Object.assign(existing, n)
                        } else if (n.signal > existing.signal && !existing.active) {
                            Object.assign(existing, n)
                        }
                        return acc
                    }, [])
            }
        }
    }

    Process {
        id: knownProc
        property var lastNames: []
        command: ["nmcli", "-t", "-f", "NAME", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: knownProc.lastNames = this.text.split("\n").filter(l => l.length > 0)
        }
    }

    function refresh() {
        knownProc.running = true
        listProc.running = true
    }

    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.scanning = false
                root.refresh()
            }
        }
    }
    function rescan() {
        root.scanning = true
        rescanProc.running = true
    }

    Process {
        id: connectProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.lastError = ""
                root.refresh()
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0) root.lastError = this.text.trim()
            }
        }
    }
    function connect(ssid, password) {
        connectProc.command = password
            ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "device", "wifi", "connect", ssid]
        connectProc.running = true
    }

    Process {
        id: radioProc
        stdout: StdioCollector { onStreamFinished: root.checkRadio() }
    }
    Process {
        id: radioCheckProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.radioEnabled = this.text.trim() === "enabled"
        }
    }
    function checkRadio() { radioCheckProc.running = true }
    function setRadio(on) {
        radioProc.command = ["nmcli", "radio", "wifi", on ? "on" : "off"]
        radioProc.running = true
    }
}
