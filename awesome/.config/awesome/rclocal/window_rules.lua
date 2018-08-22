local awful = require("awful")
awful.rules = require("awful.rules")
local beautiful = require("beautiful")


-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    { rule = { type = "desktop" },
    },
    -- Plugin-container == Flashplayer
    { rule_any = { class = { 
        "Plugin-container", "Hamster", "Pavucontrol", "Spotify", "Vlc", "VirtualBox",
        "keepassx"
    } },
      properties = { floating = true }
    },
    { rule = { class = "krunner" },
      properties = { floating = true, sticky = true, size_hints_honor = false, y=64 }
    },
    { rule = { class = "Pidgin" },
      properties = { floating = true, sticky = true, size_hints_honor = false }
    },
    { rule = { class = "Slack" },
      properties = {
          tag = "5",
          --hidden = true, skip_taskbar = true, sticky = true,
          floating = true, maximized = false, sticky = false,
          --size_hints_honor = false,
          width=1200, height=800, x=400, y=100 }
    },
    { rule = { class = "Telegram" },
      properties = {
          tag = "5",
          --hidden = true, skip_taskbar = true,
          floating = true, maximized = false, sticky = false,
          --size_hints_honor = false,
          width=1000, height=600, x=500, y=100 }
    },
    { rule = { class = "lxqt-panel", type = "dock" },
      properties = { y = 0, size_hints_honor = false }
    },
    --
    --{ rule = {
    --    class = "Yakuake" },
    --    properties = {
    --        floating = true, ontop = true, above = true, size_hints_honor = true,
    --        width=1366, maximized_horizontal = true
    --} },
    --{ rule = { class = "Firefox" }, properties = { tag = "1" } },
    --
    { rule_any = { class = { "Plasma-desktop", "gimp", "pinentry", "MPlayer" },
      properties = { floating = true, size_hints_honor = true,maximized_horizontal = false, maximized_vertical = false } } }
}
