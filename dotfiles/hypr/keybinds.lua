-- keybinds.lua

local mod = "SUPER"
local ipc = "noctalia msg"

-- ── Apps ──
hl.bind(mod .. " + T", hl.dsp.exec_cmd("uwsm app -- kitty"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd("uwsm app -- thunar"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd("uwsm app -- vivaldi"))
hl.bind(mod .. " + A", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
hl.bind(mod .. " + C", hl.dsp.exec_cmd("uwsm app -- zeditor"))
hl.bind(mod .. " + code:59", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher /emo"))

-- ── Window management ──
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F11", hl.dsp.window.fullscreen())
-- hl.bind(mod .. " + P",          hl.dsp.window.pseudo())
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

-- ── Focus ──
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind(mod .. " + L", hl.dsp.exec_cmd(ipc .. " session lock"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd(ipc .. " panel-toggle session"))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))

-- ── Move windows ──
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- ── Resize ──
hl.bind(mod .. " + CTRL + left", hl.dsp.window.resize({ x = -50, y = 0 }), { repeating = true })
hl.bind(mod .. " + CTRL + right", hl.dsp.window.resize({ x = 50, y = 0 }), { repeating = true })
hl.bind(mod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -50 }), { repeating = true })
hl.bind(mod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 50 }), { repeating = true })

-- ── Workspaces ──
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ── Scratchpad ──
-- hl.bind(mod .. " + S",          hl.dsp.workspace.toggle_special("magic"))
-- hl.bind(mod .. " + SHIFT + S",  hl.dsp.window.move({ workspace = "special:magic" }))

-- ── Scroll workspaces / mouse ──
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- ── Screenshots & Recording (Custom Walker Menu) ──
hl.bind(mod .. " + S", hl.dsp.exec_cmd(ipc .. " screenshot-region"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(ipc .. " screenshot-fullscreen"))


-- ── Clipboard ──
hl.bind(mod .. " + V", hl.dsp.exec_cmd(ipc .. " panel-toggle clipboard"))

-- ── Audio & Media ──
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
