-- Hyprland config for the laptop rice. Lives at ~/.config/hypr/hyprland.lua
-- Written for Hyprland 0.57 (Lua config). Reference: https://wiki.hypr.land/configuring/
-- Palette is documented in README.md. Keybindings mirror the old sway setup.

------------------
---- SETTINGS ----
------------------

-- Switches for the heavier effects. Turn these off to save battery.
local fancy = {
    rotating_border = true, -- spins the border gradient; redraws every frame, so it costs battery
    blur            = true,
    shadows         = true,
    dim_inactive    = true,
}

local terminal = "alacritty"
local menu     = "pkill wofi || wofi --show drun"

local c = {
    bg      = "1d1e31",
    surface = "2d2350",
    muted   = "565a85",
    text    = "d6d8f0",
    accent  = "9d7cd8",
    cyan    = "72daea",
    red     = "ff5555",
}

local function rgba(hex, alpha)
    return "rgba(" .. hex .. (alpha or "ff") .. ")"
end


------------------
---- MONITORS ----
------------------

-- Laptop panel plus anything plugged in. List outputs with: hyprctl monitors
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,
        col = {
            active_border   = { colors = { rgba(c.accent), rgba(c.cyan) }, angle = 45 },
            inactive_border = rgba(c.muted, "aa"),
        },
        resize_on_border = true,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        dim_inactive     = fancy.dim_inactive,
        dim_strength     = 0.12,
        dim_special      = 0.3,

        shadow = {
            enabled        = fancy.shadows,
            range          = 18,
            render_power   = 3,
            color          = rgba(c.accent, "55"),
            color_inactive = rgba("000000", "77"),
        },

        blur = {
            enabled  = fancy.blur,
            size     = 8,
            passes   = 3,
            noise    = 0.02,
            vibrancy = 0.25,
            popups   = true,
            special  = true,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true, -- needed for Super+E to toggle the split
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },

    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        touchpad = {
            natural_scroll          = true,
            tap_to_click            = true,
            disable_while_typing    = true,
            middle_button_emulation = true,
        },
    },
})

-- Curves
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},   {0.32, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5},  {0.75, 1} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},      {1, 1}    } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0},   {0.1, 1}  } })
hl.curve("bouncy",       { type = "spring", mass = 1, stiffness = 260, damping = 16 })

-- Animations (speed is in tenths of a second)
hl.animation({ leaf = "global",           enabled = true, speed = 10,  bezier = "default" })
hl.animation({ leaf = "windows",          enabled = true, speed = 5,   spring = "bouncy",       style = "slide" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 4,   spring = "bouncy",       style = "popin 80%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 2,   bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "border",           enabled = true, speed = 5,   bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",      enabled = fancy.rotating_border, speed = 80, bezier = "linear", style = "loop" })
hl.animation({ leaf = "fadeIn",           enabled = true, speed = 1.7, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fade",             enabled = true, speed = 3,   bezier = "quick" })
hl.animation({ leaf = "layers",           enabled = true, speed = 3.8, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 4,   bezier = "easeOutQuint", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4,   bezier = "easeOutQuint", style = "slidefadevert 20%" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 7,   bezier = "quick" })

-- Three-finger swipe changes workspace
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })


--------------------
---- WORKSPACES ----
--------------------

local workspaceNames = {
    [1]  = "1: Terminals",
    [2]  = "2: Browser",
    [3]  = "3: Editor",
    [10] = "10: System",
}
for id, name in pairs(workspaceNames) do
    hl.workspace_rule({ workspace = tostring(id), default_name = name })
end


---------------------
---- KEYBINDINGS ----
---------------------

local mod = "SUPER"

-- hl.bind with a description, so `hyprctl binds` and the preview page can list it
local function bind(keys, action, description, flags)
    flags = flags or {}
    flags.description = description
    return hl.bind(keys, action, flags)
end

local exitCmd = [[printf 'No\nYes, log out' | wofi --dmenu --prompt 'You pushed the die button. Is it time?' | grep -q '^Yes' && (command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()')]]
local shotFull   = [[mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%F_%H-%M-%S).png]]
local shotRegion = [[grim -g "$(slurp)" - | wl-copy]]

-- Basics
bind(mod .. " + Return",      hl.dsp.exec_cmd(terminal),                  "Terminal")
bind(mod .. " + D",           hl.dsp.exec_cmd(menu),                      "Launcher")
bind(mod .. " + SHIFT + Q",   hl.dsp.window.close(),                      "Close window")
bind(mod .. " + SHIFT + C",   hl.dsp.reload_config(),                     "Reload config")
bind(mod .. " + SHIFT + E",   hl.dsp.exec_cmd(exitCmd),                   "Exit Hyprland")
bind(mod .. " + escape",      hl.dsp.exec_cmd("loginctl lock-session"),   "Lock screen")
bind(mod .. " + N",           hl.dsp.exec_cmd("makoctl dismiss"),         "Dismiss notification")
bind(mod .. " + SHIFT + N",   hl.dsp.exec_cmd("makoctl restore"),         "Bring back last notification")

-- Focus and move: i3-style j k l ; plus the arrow keys
local directions = {
    { "j", "left" }, { "k", "down" }, { "l", "up" }, { "semicolon", "right" },
    { "left", "left" }, { "down", "down" }, { "up", "up" }, { "right", "right" },
}
for _, d in ipairs(directions) do
    bind(mod .. " + " .. d[1],           hl.dsp.focus({ direction = d[2] }),       "Focus " .. d[2])
    bind(mod .. " + SHIFT + " .. d[1],   hl.dsp.window.move({ direction = d[2] }), "Move window " .. d[2])
end

-- Workspaces
for i = 1, 10 do
    local key = tostring(i % 10) -- workspace 10 is on the 0 key
    bind(mod .. " + " .. key,           hl.dsp.focus({ workspace = i }),                     "Switch to workspace " .. i)
    bind(mod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i, follow = false }), "Send window to workspace " .. i)
end
bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), "Next workspace")
bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), "Previous workspace")

-- Layout
bind(mod .. " + F",             hl.dsp.window.fullscreen(),                      "Toggle fullscreen")
bind(mod .. " + SHIFT + F",     hl.dsp.window.fullscreen({ mode = "maximized" }), "Toggle maximize")
bind(mod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }),       "Toggle floating")
bind(mod .. " + E",             hl.dsp.layout("togglesplit"),                    "Toggle split direction")
bind(mod .. " + B",             hl.dsp.layout("preselect r"),                    "Open next window to the right")
bind(mod .. " + V",             hl.dsp.layout("preselect d"),                    "Open next window below")
bind(mod .. " + P",             hl.dsp.window.pseudo(),                          "Toggle pseudotile")
bind(mod .. " + W",             hl.dsp.group.toggle(),                           "Toggle tabbed group")
bind(mod .. " + Tab",           hl.dsp.group.next(),                             "Next tab in group")
bind(mod .. " + SHIFT + Tab",   hl.dsp.group.prev(),                             "Previous tab in group")

-- Scratchpad (a special workspace)
bind(mod .. " + minus",         hl.dsp.workspace.toggle_special("scratch"),                         "Show or hide scratchpad")
bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratch", follow = false }), "Send window to scratchpad")

-- Mouse: drag to move, right-drag to resize
bind(mod .. " + mouse:272", hl.dsp.window.drag(),   "Drag window",   { mouse = true })
bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- Resize mode
bind(mod .. " + R", hl.dsp.submap("resize"), "Resize mode")
hl.define_submap("resize", function()
    local step = 20
    local sizes = {
        { "j", -step, 0, "Shrink width" },  { "left",  -step, 0, "Shrink width" },
        { "semicolon", step, 0, "Grow width" }, { "right", step, 0, "Grow width" },
        { "l", 0, -step, "Shrink height" }, { "up",    0, -step, "Shrink height" },
        { "k", 0, step, "Grow height" },    { "down",  0, step, "Grow height" },
    }
    for _, s in ipairs(sizes) do
        bind(s[1], hl.dsp.window.resize({ x = s[2], y = s[3], relative = true }), s[4], { repeating = true })
    end
    bind("Return",     hl.dsp.submap("reset"), "Leave resize mode")
    bind("escape",     hl.dsp.submap("reset"), "Leave resize mode")
    bind(mod .. " + R", hl.dsp.submap("reset"), "Leave resize mode")
end)

-- Screenshots
bind("Print",             hl.dsp.exec_cmd(shotFull),   "Screenshot to ~/Pictures/Screenshots")
bind("SHIFT + Print",     hl.dsp.exec_cmd(shotRegion), "Screenshot a region to the clipboard")
bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(shotRegion), "Screenshot a region to the clipboard")

-- Laptop media keys (work on the lock screen too)
bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), "Volume up",       { locked = true, repeating = true })
bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      "Volume down",     { locked = true, repeating = true })
bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     "Mute speakers",   { locked = true })
bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   "Mute microphone", { locked = true })
bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  "Brightness up",   { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  "Brightness down", { locked = true, repeating = true })
bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                           "Play or pause",   { locked = true })
bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                           "Play or pause",   { locked = true })
bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                 "Next track",      { locked = true })
bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                             "Previous track",  { locked = true })


---------------
---- RULES ----
---------------

hl.window_rule({
    name  = "suppress-maximize-events", -- apps can't maximize themselves
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

hl.window_rule({
    name  = "stay-awake-when-fullscreen", -- videos and games keep hypridle away
    match = { class = ".*" },
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name   = "float-volume-control",
    match  = { class = "^(org.pulseaudio.pavucontrol|pavucontrol)$" },
    float  = true,
    size   = { 720, 480 },
    center = true,
})

hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "^Picture-in-Picture$" },
    float = true,
    pin   = true,
    size  = { 480, 270 },
    move  = { "monitor_w - window_w - 20", "monitor_h - window_h - 20" },
})

-- Blur behind the bar, launcher and notifications
hl.layer_rule({ name = "glass-waybar",        match = { namespace = "^waybar$" },        blur = fancy.blur, ignore_alpha = 0.1 })
hl.layer_rule({ name = "glass-wofi",          match = { namespace = "^wofi$" },          blur = fancy.blur, ignore_alpha = 0.1, animation = "popin 90%" })
hl.layer_rule({ name = "glass-notifications", match = { namespace = "^notifications$" }, blur = fancy.blur, ignore_alpha = 0.1, animation = "slide right" })
