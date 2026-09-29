import QtQuick
import Quickshell
import QtQuick.Layouts
import "root:/"

RowLayout {
    spacing: 9

    SystemClock {
      id: clock
      precision: SystemClock.Seconds
    }

    Text {
        text: Qt.formatDateTime(clock.date, "hh:mm ap")
        color: Theme.colFg
        font {
            family: Theme.fontFamily
            pointSize: Theme.fontSize
            weight: 600
        }
    }

    Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 15
        color: Theme.colMuted
        opacity: 0.6
    }

    Text {
        text: Qt.formatDateTime(clock.date, "ddd, MM/dd")
        color: Theme.colFg
        font {
            family: Theme.fontFamily
            pointSize: Theme.fontSize
        }
    }
}
