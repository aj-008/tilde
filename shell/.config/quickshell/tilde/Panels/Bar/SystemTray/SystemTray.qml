import QtQuick.Layouts
import QtQuick
import "root:/"



RowLayout {
    spacing: 12
    BluetoothIndicator {}
    Wifi {}
    Volume {}
    Memory {}
    Battery {} 
}
