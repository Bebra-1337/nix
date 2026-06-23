-- autostart.lua
-- With UWSM, most daemons are managed as systemd user services.
-- Enable them once: systemctl --user enable hyprpaper hypridle dunst
-- They start automatically via graphical-session.target.
--
-- Only use hl.exec_cmd for things without a .service unit.
local hyprcapture = require("hyprcapture_path")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprctl plugin load " .. hyprcapture.so .. " && hyprctl eval 'hl.config({ plugin = { hyprcapture = { helper = \"" .. hyprcapture.ui .. "\" } } })'")
    hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
    hl.exec_cmd("uwsm app -- noctalia-shell")
end)

