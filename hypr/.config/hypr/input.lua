-- ~/.config/hypr/input.lua

hl.config({
    input = {
        kb_layout  = "us,us",
        kb_variant = "colemak_dh,",

        sensitivity  = 0.3,
        follow_mouse = 1,

        touchpad = {
            natural_scroll        = true,
            tap_to_click          = true,
            disable_while_typing  = true,
        }
    },

})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
