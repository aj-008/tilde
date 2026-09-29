// WeatherCard.qml
import QtQuick
import QtQuick.Layouts
import "root:/"
import "root:/Services"

Item {
    id: weatherWidget
    implicitHeight: 140

    readonly property int contentMargins: 12
    readonly property int iconSize: 100
    readonly property int sectionSpacing: 12
    readonly property int textMaxWidth: 220

    RowLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - weatherWidget.contentMargins * 2, implicitWidth)
        spacing: weatherWidget.sectionSpacing

        Text {
            text: Weather.icon
            font.family: Theme.fontIcon
            font.pixelSize: weatherWidget.iconSize
            color: Theme.colAccent
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: Weather.ready ? Math.round(Weather.tempF) + "°" : "--°"
                color: Theme.colSecondary
                font.bold: true
                font.pixelSize: 40
            }

            RowLayout {
                spacing: Theme.spacingSm

                Text {
                    text: Weather.condition
                    color: Theme.colFg
                    font.pixelSize: Theme.fontXl
                    elide: Text.ElideRight
                    Layout.maximumWidth: weatherWidget.textMaxWidth
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 20
                    color: Theme.colMuted
                    opacity: 0.6
                }

                Text {
                    text: Weather.locationName
                    color: Theme.colFg
                    opacity: 0.7
                    font.pixelSize: Theme.fontLg
                    elide: Text.ElideRight
                    Layout.maximumWidth: weatherWidget.textMaxWidth
                }
            }
        }
    }
}
