-- BEBRA-PC Hyprland config (Hyprland >= 0.55, Lua config)
-- https://wiki.hypr.land/Configuring/Start/

local colors_ok, colors = pcall(require, "hyprland-colors")


require("autostart")
require("keybinds")


-- -------------------------------------------------------
--  MONITORS
-- -------------------------------------------------------
hl.monitor({ output = "DP-2", mode = "2560x1440@200", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-3", mode = "1920x1080@180", position = "2560x250", scale = 1 })

-- -------------------------------------------------------
--  ENVIRONMENT
-- -------------------------------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Original-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Original-Ice")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- -------------------------------------------------------
--  LOOK AND FEEL
-- -------------------------------------------------------
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border   = colors_ok and ("rgba(" .. string.sub(colors.primary, 5) .. "ff)") or "rgba(cdd6f4ff)",
            inactive_border = colors_ok and ("rgba(" .. string.sub(colors.surface, 5) .. "ff)") or "rgba(313244aa)",
        },
        layout = "dwindle",
        resize_on_border = true,
        allow_tearing = true,
    },

    decoration = {
        rounding         = 4,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur             = {
            enabled           = true,
            size              = 3,
            passes            = 2,
            vibrancy          = 0.1696,
            new_optimizations = true,
        },
    },

    input = {
        kb_layout     = "us,ru",
        kb_options    = "grp:alt_shift_toggle",
        follow_mouse  = 1,
        sensitivity   = 0,
        accel_profile = "flat",
        touchpad      = { natural_scroll = false },
    },

    dwindle = {
        preserve_split = true,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        vrr                     = 1,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,
    },
})

-- -------------------------------------------------------
--  ANIMATIONS
-- -------------------------------------------------------
hl.curve("default", { type = "bezier", points = { { 0.12, 0.92 }, { 0.08, 1.0 } } })
hl.curve("wind", { type = "bezier", points = { { 0.12, 0.92 }, { 0.08, 1.0 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.18, 0.95 }, { 0.22, 1.03 } } })
hl.curve("liner", { type = "bezier", points = { { 1.0, 1.0 }, { 1.0, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "wind", style = "popin 60%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "overshot", style = "popin 60%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "overshot", style = "popin 60%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "default", style = "popin" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 24, bezier = "liner", style = "loop" })

-- -------------------------------------------------------
--  WINDOW RULES
-- -------------------------------------------------------
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Workspace 2 rules (AyuGram, Discord, SoundCloud Desktop)
hl.window_rule({
    match = { class = "^com\\.ayugram\\.desktop$" },
    workspace = "2",
    float = true,
    size = "451 1056",
    move = "12 12",
})
hl.window_rule({
    match = { class = "^discord$" },
    workspace = "2",
    float = true,
    size = "1431 521",
    move = "477 12",
})
hl.window_rule({
    match = { class = "^python3$", title = "^SoundCloud Desktop$" },
    workspace = "2",
    float = true,
    size = "1431 521",
    move = "477 547",
})

hl.window_rule({
    name = "deadlocked",
    match = {
        title = "^deadlocked_overlay$"
    },
    no_blur = true,
})

-- Float
hl.window_rule({ match = { class = "^(hyprpwcenter|blueman-manager|nm-connection-editor)$" }, float = true })

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Fix Steam popups / child windows erratic behavior
hl.window_rule({
    match = {
        class = "^(steam)$",
        title = "^$",
    },
    stay_focused = true,
    no_anim = true,
    no_initial_focus = true, -- не тянет фокус клавиатуры при открытии попапа
    pin = true,              -- не улетает при смене воркспейса, пока попап открыт
})

-- Fix JetBrains IDE popups/dialogs (Find, Search Everywhere, context menus)
hl.window_rule({
    name = "jetbrains-dialogs-float",
    match = { class = "^(jetbrains-.+)$", float = true },
    float = true,
})
hl.window_rule({
    name = "jetbrains-dialog-focus",
    match = { class = "^(jetbrains-.*)$", float = true },
    stay_focused = true,
})
hl.window_rule({
    name = "jetbrains-tooltips",
    match = { class = "^(jetbrains-.*)$", title = "^(win.*)$" },
    no_initial_focus = true,
})
hl.window_rule({
    name = "jetbrains-min-size",
    match = { class = "^(jetbrains-.*)$", title = "^$", float = true },
    min_size = "800 600",
})

-- Adapted legacy window rules
-- Idle Inhibit rules
hl.window_rule({
    match = { class = "^(.*celluloid.*)$|^(.*mpv.*)$|^(.*vlc.*)$" },
    idle_inhibit = "fullscreen",
})
hl.window_rule({
    match = { class = "^(.*[Ss]potify.*)$" },
    idle_inhibit = "fullscreen",
})
hl.window_rule({
    match = { class = "^(.*LibreWolf.*)$|^(.*floorp.*)$|^(.*brave-browser.*)$|^(.*firefox.*)$|^(.*chromium.*)$|^(.*zen.*)$|^(.*vivaldi.*)$" },
    idle_inhibit = "fullscreen",
})

-- Picture-in-Picture
hl.window_rule({
    name = "hyde_picture_in_picture_tags",
    match = {
        title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$",
    },
    tag = "+picture-in-picture",
})
hl.window_rule({
    name = "hyde_picture_in_picture",
    match = {
        title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$",
    },
    tag = "+hyde_picture_in_picture",
    float = true,
    keep_aspect_ratio = true,
    move = "(monitor_w*0.73) (monitor_h*0.72)",
    size = "(monitor_w*0.25) (monitor_h*0.25)",
    pin = true,
})

-- Opacity rules
hl.window_rule({ match = { class = "^firefox$" }, opacity = "0.90 0.90 1" })
hl.window_rule({ match = { class = "^zen$" }, opacity = "0.90 0.90 1" })
hl.window_rule({ match = { class = "^brave-browser$" }, opacity = "0.90 0.90 1" })
hl.window_rule({ match = { class = "^code-oss$" }, opacity = "0.80 0.80 1" })

-- Tearing for games
hl.window_rule({ match = { class = "steam_app_.*" }, immediate = true })
hl.window_rule({ match = { class = "gamescope" }, immediate = true })

-- Layer rules
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

-- For Noctalia Color templates
pcall(function() require("noctalia").apply_theme() end)
