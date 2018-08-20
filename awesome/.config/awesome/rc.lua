local awful = require("awful")
require("awful.autofocus")
--local lain = require("lain")

-- This is used later as the default terminal and editor to run.
terminal = "konsole"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
max_tag = 5

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
Alt_L = "Mod1"


require("rclocal.error")
require("rclocal.themes")
require("rclocal.tags")
require("rclocal.menus")
require("rclocal.wibox_setup")
require("rclocal.signals")
require("rclocal.mouse")
require("rclocal.keybindings")
require("rclocal.window_rules")

-- autorun programs
awful.util.spawn_with_shell("~/.config/awesome/autorun.sh")

-- TODO:
--   * scrot
--   * xdg-menu
--   * add new client on the slave area; would be enough doing this for new teminals?
--   * split in multiple files (kde/no-kde, per workstation, docked/undocked)
--
-- Suspend and lock on lid down. https://wiki.archlinux.org/index.php/Power_management#Sleep_hooks
-- 
--   [Unit]
--   Description=Lock the screen on resume from suspend
--   
--   [Service]
--   User=jordif
--   Environment=DISPLAY=:0
--   ExecStart=/usr/bin/slock
--   
--   [Install]
--   WantedBy=suspend.target
