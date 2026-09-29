-- ~/.config/hypr/keybinds.lua

local mainMod = "SUPER"
local term    = "foot"

--------------------------------------------------------------------------
-- Apps / core actions
--------------------------------------------------------------------------
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("firefox --profile ~/.config/mozilla/firefox/jxpfrbmw.default-release"))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("qutebrowser"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("blueman-manager"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("spotify-launcher"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(
    "sh -c 'AREA=$(slurp -w 0) && sleep 0.5 && grim -g \"$AREA\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png'"
))
hl.bind("CTRL        + TAB", hl.dsp.exec_cmd("rofi -show window"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("foot --app-id=pdf-selector -e bash -c '/home/ajrom/.local/bin/pdf-selector'"))
hl.bind(mainMod .. " + EQUAL", hl.dsp.exec_cmd("qs -c tilde ipc call dashboard toggle"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("qs -c tilde ipc call launcher toggle"))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("qs -c tilde ipc call wallpaperPicker toggle"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("yazi-toggle"))
hl.bind("ALT + F", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = 0 }))

hl.bind("SUPER+SHIFT+P", function()
    local w = hl.get_active_window()
    if not w then return end

    if w.fullscreen_client ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0 }))
        hl.dispatch(hl.dsp.window.float({ action = "disable" }))
        return
    end

    local mon   = w.monitor
    local scale = mon.scale or 1
    local mw    = mon.width  / scale
    local mh    = mon.height / scale
    local tw, th = 640, 360

    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
    hl.dispatch(hl.dsp.window.resize({ exact = true, x = tw, y = th }))
    hl.dispatch(hl.dsp.window.move({ x = mw - tw - 20, y = mh - th - 60 }))
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
end)


--------------------------------------------------------------------------
-- Workspaces 
--------------------------------------------------------------------------
for i = 1, 8 do
    hl.bind("ALT + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("ALT + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + TAB", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mainMod .. " + SHIFT + GRAVE", hl.dsp.window.move({ workspace = "special:scratch" }))

hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))

--------------------------------------------------------------------------
-- Focus / move windows 
--------------------------------------------------------------------------
hl.bind(mainMod .. " + M", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + N", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + E", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + I", hl.dsp.window.move({ direction = "right" }))

--------------------------------------------------------------------------
-- Audio / mic 
--------------------------------------------------------------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

--------------------------------------------------------------------------
-- Brightness
--------------------------------------------------------------------------
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

--------------------------------------------------------------------------
-- Keyboard layout switcher
--------------------------------------------------------------------------
hl.bind("CTRL + SHIFT + 0", hl.dsp.exec_cmd("hyprctl switchxkblayout current next"), { description = "Switch keyboard layout" })

