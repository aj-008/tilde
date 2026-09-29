-- ~/.config/hypr/windowrules.lua

hl.window_rule({
    name  = "pdf-selector",
    match = { class = "pdf-selector" },
    float = true,
    size  = { 1000, 600 },
    center = true,
})

hl.window_rule({
    name  = "scratchpad-term",
    match = { class = "foot", title = "scratchpad" },
    float = true,
    size  = { 1000, 750 },
    center = true,
})

hl.window_rule({
    name  = "filepicker",
    match = { class = "filepicker" },
    float = true,
    size  = { 1100, 700 },
    center = true,
})


hl.window_rule({
    match = { float = true, pin = false },
    size = { 500, 200 },
    center = true,
})

hl.window_rule({
    name  = "ytpip",
    match = { title = "^ytpip$" },
    float = true,
    pin   = true,
    keep_aspect_ratio = true,
    border_size = 0,
    rounding = 0,
    no_initial_focus = true,
    size = { 560, 315 },
    move = "monitor_w-window_w-20 monitor_h-window_h-20",
})
