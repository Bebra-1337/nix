-- autostart.lua
-- With UWSM, most daemons are managed as systemd user services.
-- Only use hl.exec_cmd for things without a .service unit.
hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
    hl.exec_cmd("uwsm app -- noctalia")
    hl.exec_cmd("uwsm app -- steam -silent")
    hl.exec_cmd("uwsm app -- bebrasoundcloud")
end)
