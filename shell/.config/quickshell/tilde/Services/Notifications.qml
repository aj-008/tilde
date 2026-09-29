pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    // ---- config ----
    readonly property int historyLimit: 50
    readonly property int historyMaxAgeMs: 24 * 60 * 60 * 1000
    readonly property int defaultTimeoutMs: 3000
    readonly property int criticalTimeoutMs: 0 // 0 = don't auto-expire

    // ---- state ----
    property var active: []   // currently-shown popups
    property var history: []  // retained log

    NotificationServer {
        id: server
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: (notification) => {
            notification.tracked = true // keeps it alive past its own auto-close

            const entry = {
                id: notification.id,
                appName: notification.appName,
                summary: notification.summary,
                body: notification.body,
                icon: notification.appIcon,
                urgency: notification.urgency, 
                time: Date.now(),
                actions: notification.actions,
                notifObj: notification
            }

            root.active = [entry, ...root.active]
            root.history = [entry, ...root.history].slice(0, root.historyLimit)

            const timeout = notification.expireTimeout > 0
                ? notification.expireTimeout
                : (entry.urgency === 2 ? root.criticalTimeoutMs : root.defaultTimeoutMs)

            if (timeout > 0) {
                const t = timerComponent.createObject(root, { interval: timeout })
                t.triggered.connect(() => {
                    root.dismiss(entry.id)
                    t.destroy()
                })
                t.start()
            }
        }
    }

    Component {
        id: timerComponent
        Timer { running: false; repeat: false }
    }

    function dismiss(id) {
        active = active.filter(n => n.id !== id)
    }

    function clearAll() {
        active = []
        history = []
    }

    function pruneHistory() {
        const cutoff = Date.now() - historyMaxAgeMs
        history = history.filter(n => n.time > cutoff)
    }

    function removeFromHistory(id) {
        history = history.filter(n => n.id !== id)
        dismiss(id)
    }

    Timer {
        interval: 5 * 60 * 1000
        running: true
        repeat: true
        onTriggered: root.pruneHistory()
    }
}
