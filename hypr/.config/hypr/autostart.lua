-- ~/.config/hypr/autostart.lua

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("xsettingsd")
    hl.exec_cmd("quickshell -c tilde")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("foot --server")
end)

