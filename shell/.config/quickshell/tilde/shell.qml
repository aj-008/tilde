//@ pragma IconTheme Adwaita
import Quickshell

import "root:/"
import "root:/Panels/Bar"
import "root:/Panels/ControlCenter"
import "root:/Panels/Dashboard"
import "root:/Panels/Launcher"
import "root:/Panels/WallpaperPicker"
import "root:/Panels/NotificationPopup"
import "root:/Panels/PowerMenu"

ShellRoot {
    ControlCenterWindow {}
    Bar {}
    Dashboard {}
    Launcher {}
    WallpaperPanel {}
    NotificationPopup {}
    PowerMenu {
        id: powerMenu
    }
}
