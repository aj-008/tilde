// FocusState.qml
pragma Singleton
import QtQuick

QtObject {
    property Item fullscreenItem: null
    readonly property bool active: fullscreenItem !== null
}
