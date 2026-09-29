hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 2,
        border_size = 1,

        col = {
            -- overridden by colors.lua at runtime
            active_border   = "rgb(b4befe)",
            inactive_border = "rgb(313244)",
        },

        layout = "dwindle",
        float_gaps = 6,
        resize_on_border = true,
    },

    decoration = {
        rounding = 8,

        blur = {
            enabled            = true,
            size               = 6,
            passes             = 3,
            new_optimizations  = true,
            xray               = false,
        },

    },

    misc = {
        disable_hyprland_logo = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",             enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",          enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "layers",              enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersIn",            enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersOut",           enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "fade",                enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "workspaces",          enabled = true, speed = 5, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
