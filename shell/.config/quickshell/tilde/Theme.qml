// Theme.qml
pragma Singleton
import QtQuick
import Quickshell.Io as Io

QtObject {
    id: root
    property var colorsObj: null

    function c(key, fallback) {
        return (colorsObj && colorsObj[key] !== undefined) ? colorsObj[key] : fallback
    }

    readonly property color colBg:        c("background", "#1a1b26")
    readonly property color colFg:        c("foreground", "#a9b1d6")
    readonly property color colSurface:   c("surface",    "#1a1b26")
    readonly property color colMuted:     c("muted",      "#444b6a")
    readonly property color colAccent:    c("accent",     "#7aa2f7")
    readonly property color colSecondary: c("secondary",  "#0db9d7")
    readonly property color colTertiary:  c("tertiary",   "#e0af68")
    readonly property color colError:     c("error",      "#e06c75")

    readonly property color colText:      colFg
    readonly property color colBorder:    c("outline", colMuted)
    readonly property color colHighlight: Qt.alpha(colAccent, 0.25)
    readonly property color colHover:     Qt.lighter(colSurface, 1.15)
    readonly property color colPressed:   Qt.darker(colSurface, 1.1)

    // Idle/hover tint for chips, pills and buttons whose base color is
    // "transparent" rather than colSurface (so colHover's lighten doesn't apply).
    readonly property color colOverlayIdle:  Qt.alpha(colFg, 0.06)
    readonly property color colOverlayHover: Qt.alpha(colFg, 0.12)

    // Static tray chrome — intentionally not matugen-derived: the palette has
    // no "text/icon on a colored fill" contrast color to draw from (would
    // require adding a key to matugen/templates/quickshell-colors.qml and
    // regenerating). colMemIcon used to duplicate this role with a leftover
    // Catppuccin hex; folded into colSysIcon since both mean "default tray icon tint".
    readonly property color colSysIcon:       "white"
    readonly property color colSysText:       "gray"
    readonly property color colBatteryText:   "black"

    readonly property var icons: ({
        // Quick Toggles
        caffeine: "󰅶",       // nf-md-coffee
        nightMode: "󰌵",      // nf-md-weather_night
        power: "󰐥",          // nf-md-power
        reboot: "󰜉",         // nf-md-restart
        sleep: "󰤄",          // nf-md-sleep

        // System Hardware
        wifi: "󰤨",           // nf-md-wifi
        wifiOff: "󰤭",        // nf-md-wifi_off
        bluetooth: "󰂯",      // nf-md-bluetooth
        bluetoothOff: "󰂲",   // nf-md-bluetooth_off
        volumeHigh: "󰕾",     // nf-md-volume_high
        volumeMedium: "󰖀",   // nf-md-volume_medium
        volumeLow: "󰕿",      // nf-md-volume_low
        volumeMute: "󰝟",     // nf-md-volume_mute
        brightnessHigh: "󰃠", // nf-md-brightness_6
        brightnessMedium: "󰃟", // nf-md-brightness_5
        brightnessLow: "󰃞",  // nf-md-brightness_4

        // UI Navigation & Notifications
        bell: "󰂜",           // nf-md-bell_outline
        chevronRight: "󰅂",   // nf-md-chevron_right
        chevronDown: "󰅀",    // nf-md-chevron_down
        close: "󰅖",          // nf-md-close
        settings: "󰒓",       // nf-md-cog
        link: "󰌹",           // nf-md-link
        lock: "󰌾"            // nf-md-lock
    })

    readonly property string wallpaperPath: c("wallpaperPath", "")

    property string fontFamily: "IBM Plex"
    // Nerd Font glyphs (Theme.icons) aren't in the IBM Plex family, so icon
    // text needs a font that actually has them.
    readonly property string fontIcon: "Symbols Nerd Font"

    property int fontSize: 10
    readonly property int fontXs: 9
    readonly property int fontSm: 11
    readonly property int fontMd: 13
    readonly property int fontLg: 16
    readonly property int fontXl: 18

    property int trayFontSize: 8
    property int trayIconSize: 14

    property int radius: 10
    readonly property int radiusXs: 4
    readonly property int radiusMd: 14
    readonly property int radiusLg: 20

    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16

    Component.onCompleted: loadColors()
    function loadColors() {
        var comp = Qt.createComponent(
            "file:///home/ajrom/.cache/quickshell/Colors.qml?t=" + Date.now(),
            Component.PreferSynchronous
        )
        if (comp.status === Component.Ready) {
            var newColors = comp.createObject(root)
            var old = colorsObj
            colorsObj = newColors 
            if (old) old.destroy()
        } else if (comp.status === Component.Error) {
            console.warn("Colors.qml load error:", comp.errorString())
        }
    }

    property var ipc: Io.IpcHandler {
        target: "theme"
        function reload() { root.loadColors() }
    }
}
