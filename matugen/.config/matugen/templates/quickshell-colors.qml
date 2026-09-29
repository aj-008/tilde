import QtQuick

QtObject {
    property color background: "{{colors.background.default.hex}}"
    property color foreground: "{{colors.on_background.default.hex}}"
    property color surface: "{{colors.surface.default.hex}}"
    property color muted: "{{colors.surface_variant.default.hex}}"
    property color accent: "{{colors.primary.default.hex}}"
    property color secondary: "{{colors.secondary.default.hex}}"
    property color tertiary: "{{colors.tertiary.default.hex}}"
    property color error: "{{colors.error.default.hex}}"
    property string wallpaperPath: "{{image}}"
}
