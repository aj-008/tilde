pragma Singleton
import Quickshell

Singleton {
    id: root
    property bool open: false
    property string page: "wifi" // starting page

    function openPage(p) {
        page = p
        open = true
    }
    function close() {
        open = false
    }
    function toggle(p) {
        if (open && page === p) {
            open = false
        } else {
            page = p
            open = true
        }
    }
}
