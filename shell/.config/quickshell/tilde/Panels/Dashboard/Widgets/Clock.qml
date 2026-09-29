// Clock.qml
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import "root:/"

Item {
    id: clockWidget

    readonly property string fontFamily: "Geist"

    readonly property int contentMargins: 14
    readonly property int sectionSpacing: 16
    readonly property int timeSize: 150
    readonly property int ampmSize: 40
    readonly property int dateSize: 40
    readonly property int dividerWidth: 200
    readonly property int dividerHeight: 3

    readonly property real timeLetterSpacing: 1
    readonly property real colonOpacity: 0.55
    readonly property real ampmOpacity: 0.85
    readonly property real dateOpacity: 0.85
    readonly property real dateLetterSpacing: 3

    readonly property color shadowColor: Qt.alpha(Theme.colBg, 0.4)
    readonly property real shadowRadius: 6
    readonly property real shadowSamples: 16
    readonly property point shadowOffset: Qt.point(0, 1)

    implicitWidth: 360
    implicitHeight: 200

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: clockWidget.sectionSpacing
        visible: false

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                text: Qt.formatDateTime(clock.date, "h")
                color: Theme.colFg
                font.family: clockWidget.fontFamily
                font.pixelSize: clockWidget.timeSize
                font.bold: true
                font.letterSpacing: clockWidget.timeLetterSpacing
            }

            Text {
                text: ":"
                color: Theme.colFg
                opacity: clockWidget.colonOpacity
                font.family: clockWidget.fontFamily
                font.pixelSize: clockWidget.timeSize
                font.bold: true
            }

            Text {
                text: Qt.formatDateTime(clock.date, "mm")
                color: Theme.colFg
                font.family: clockWidget.fontFamily
                font.pixelSize: clockWidget.timeSize
                font.bold: true
                font.letterSpacing: clockWidget.timeLetterSpacing
            }

            Text {
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: clockWidget.timeSize * 0.16
                Layout.leftMargin: Theme.spacingSm
                text: Qt.formatDateTime(clock.date, "AP")
                color: Theme.colAccent
                opacity: clockWidget.ampmOpacity
                font.family: clockWidget.fontFamily
                font.pixelSize: clockWidget.ampmSize
                font.bold: true
                font.letterSpacing: 1
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: clockWidget.dividerWidth
            Layout.preferredHeight: clockWidget.dividerHeight
            radius: height / 2
            color: Theme.colAccent
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "dddd, MMMM d").toUpperCase()
            color: Theme.colFg
            opacity: clockWidget.dateOpacity
            font.family: clockWidget.fontFamily
            font.pixelSize: clockWidget.dateSize
            font.weight: Font.DemiBold
            font.letterSpacing: clockWidget.dateLetterSpacing
        }
    }

    DropShadow {
        anchors.fill: content
        source: content
        horizontalOffset: clockWidget.shadowOffset.x
        verticalOffset: clockWidget.shadowOffset.y
        radius: clockWidget.shadowRadius
        samples: clockWidget.shadowSamples
        color: clockWidget.shadowColor
        transparentBorder: true
    }
}
