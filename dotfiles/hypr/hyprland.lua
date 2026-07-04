-- BEBRA-PC Hyprland config (Hyprland >= 0.55, Lua config)
-- https://wiki.hypr.land/Configuring/Start/

local colors_ok, colors = pcall(require, "hyprland-colors")


require("autostart")
require("keybinds")


-- -------------------------------------------------------
--  MONITORS
-- -------------------------------------------------------
hl.monitor({ output = "DP-2", mode = "1920x1080@180",  position = "0x0", scale = 1 })
hl.monitor({ output = "DP-3", disabled = true })

-- -------------------------------------------------------
--  ENVIRONMENT
-- -------------------------------------------------------
hl.env("XCURSOR_SIZE",                    "24")
hl.env("XCURSOR_THEME",                   "Bibata-Original-Ice")
hl.env("HYPRCURSOR_SIZE",                 "24")
hl.env("HYPRCURSOR_THEME",                "Bibata-Original-Ice")
hl.env("GBM_BACKEND",                     "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME",       "nvidia")
hl.env("LIBVA_DRIVER_NAME",               "nvidia")
hl.env("NVD_BACKEND",                     "direct")
hl.env("NIXOS_OZONE_WL",                  "1")
hl.env("QT_QPA_PLATFORM",                 "wayland")
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
        rounding       = 8,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.95,
        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = 0xee0d0d0d,
        },
        blur = {
            enabled          = true,
            size             = 6,
            passes           = 3,
            vibrancy         = 0.1696,
            new_optimizations = true,
        },
    },

    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity  = 0,
        accel_profile = "flat",
        touchpad = { natural_scroll = false },
    },

    dwindle = {
        preserve_split  = true,
        smart_resizing  = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        vrr                      = 1,
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
    },
})

-- -------------------------------------------------------
--  ANIMATIONS
-- -------------------------------------------------------
hl.curve("expo",      { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("wind",      { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winIn",     { type = "bezier", points = { {0.1,  1.1}, {0.1, 1.1}  } })
hl.curve("winOut",    { type = "bezier", points = { {0.3,  -0.3}, {0, 1}     } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick",     { type = "bezier", points = { {0.15, 0}, {0.1, 1}      } })

hl.animation({ leaf = "global",      enabled = true, speed = 6,    bezier = "default"     })
hl.animation({ leaf = "windows",     enabled = true, speed = 5,    bezier = "expo",        style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5,    bezier = "winIn",       style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 4,    bezier = "winOut",      style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,    bezier = "wind",        style = "slide" })
hl.animation({ leaf = "fade",        enabled = true, speed = 8,    bezier = "quick"       })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,    bezier = "expo",        style = "slide" })
hl.animation({ leaf = "layers",      enabled = true, speed = 4,    bezier = "expo",        style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 10,   bezier = "default"     })

-- -------------------------------------------------------
--  WINDOW RULES
-- -------------------------------------------------------
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Float
hl.window_rule({ match = { class = "^(hyprpwcenter|blueman-manager|nm-connection-editor)$" }, float = true })
hl.window_rule({ match = { xwayland = true, float = true, fullscreen = false, pin = false, class = "^$", title = "^$" }, no_focus = true })

-- Tearing for games
hl.window_rule({ match = { class = "steam_app_.*" }, immediate = true })
hl.window_rule({ match = { class = "gamescope"    }, immediate = true })

-- Layer rules
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })

-- For Noctalia Color templates
pcall(function() require("noctalia").apply_theme() end)
