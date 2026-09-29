// Weather.qml
pragma Singleton
import QtQuick

QtObject {
    id: root

    readonly property real latitude: 42.4184
    readonly property real longitude: -71.1062
    readonly property int refreshIntervalMs: 15 * 60 * 1000

    property real tempF: 0
    property int weatherCode: 0
    property string locationName: "Medford, MA"
    property bool ready: false

    readonly property string icon: iconFor(weatherCode)
    readonly property string condition: conditionFor(weatherCode)

    function refresh() {
        const url = `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,weather_code&temperature_unit=fahrenheit`
        const xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                const data = JSON.parse(xhr.responseText)
                root.tempF = data.current.temperature_2m
                root.weatherCode = data.current.weather_code
                root.ready = true
            }
        }
        xhr.open("GET", url)
        xhr.send()
    }

    function iconFor(code) {
        if (code === 0) return "󰖙"
        if (code <= 2) return "󰖕"
        if (code === 3) return "󰖐"
        if (code === 45 || code === 48) return "󰖑"
        if (code >= 51 && code <= 57) return "󰖗"
        if (code >= 61 && code <= 67) return "󰖖"
        if (code >= 71 && code <= 77) return "󰖘"
        if (code >= 80 && code <= 82) return "󰖖"
        if (code >= 95) return "󰙾"
        return "󰋼"
    }

    function conditionFor(code) {
        if (code === 0) return "Clear"
        if (code <= 2) return "Partly Cloudy"
        if (code === 3) return "Overcast"
        if (code === 45 || code === 48) return "Fog"
        if (code >= 51 && code <= 57) return "Drizzle"
        if (code >= 61 && code <= 67) return "Rain"
        if (code >= 71 && code <= 77) return "Snow"
        if (code >= 80 && code <= 82) return "Showers"
        if (code >= 95) return "Thunderstorm"
        return "Unknown"
    }

    property var _timer: Timer {
        interval: root.refreshIntervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
