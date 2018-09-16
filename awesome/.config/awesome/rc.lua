-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
local beautiful = require("beautiful")
--local lain = require("lain")
-- notification library
local naughty = require("naughty")
-- Widget and layout library
local wibox = require("wibox")
local volume_control = require("volume-control")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
--require("awful.hotkeys_popup.keys")



-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.font          = "sans 11"
local titlebars_enabled = false
-- This is used later as the default terminal and editor to run.
terminal = "konsole"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
max_tag = 5

-- An external mouse has been detected. This enables/disables custom
-- actions for a specific device.
-- [TODO] - mouse_external should be a function that detects devices
local mouse_external = true

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"     -- Super
Alt_L = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}



----------------------------------------------------------------------
----------------------------------------------------------------------

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}




----------------------------------------------------------------------
----------------------------------------------------------------------

-- Widget not used but useful for hotkeys.
volumecfg = volume_control({})

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])
end)


----------------------------------------------------------------------
----------------------------------------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)




----------------------------------------------------------------------
----------------------------------------------------------------------

-- Some mouse actions are disabled when only a trackpad is present:
-- wheel lateral button is easy to control on a mouse/trackball but
-- on a trackpad it is too easy to misfire with 2-fingers vertical
-- scroll.
if mouse_external then
    -- Mouse bindings over the desktop
    root.buttons(awful.util.table.join(
        awful.button({ }, 6, awful.tag.viewprev), -- wheel lateral button: changes tag
        awful.button({ }, 7, awful.tag.viewnext)
    ))

    -- mouse actions for the client.
    -- This variable is used on window_rules
    clientbuttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize),
        -- wheel lateral button: changes tag
        awful.button({ }, 6, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
        awful.button({ }, 7, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
        )
else
    -- Mouse actions for the client.
    -- This variable is used on window_rules
    clientbuttons = awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize)
        )
end



----------------------------------------------------------------------
----------------------------------------------------------------------

function toggle_visibility(class_name)
    -- [TODO] - toggle_visibility fails on empty tags
    local is_class = function (c)
       return awful.rules.match(c, {class = class_name})
    end

    --local curidx = awful.tag.getidx()     -- idx of the current tag
    local tags = awful.tag.gettags(client.focus.screen)
    for c in awful.client.iterate(is_class) do
        if c.minimized then
            client.focus = c
            c.minimized = false
            c.sticky = true
            c:raise()
            --c.move_to_tag(tags[curidx])    -- move to current tag
        else
            c.minimized = true
            c.sticky = false
            awful.client.movetotag(tags[#tags], c)     -- move to last tag
        end
    end
--
--    for c in awful.client.iterate(is_class) do
--        c.sticky = not c.sticky
--        if c.sticky then
--            client.focus = c
--            c:raise()
--        end
--    end
end




globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    -- Standard program
    -- original spawn terminal: Ctrl-Alt-n
    -- original krunner:        Alt-Space
    awful.key({ modkey,           }, "Return",function () awful.util.spawn(terminal) end,
              {description="Open a terminal", group="awesome"}),
    awful.key({ modkey            }, "r",     function () awful.util.spawn("lxqt-runner") end,
              {description="Run command", group="awesome"}),
    --awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
    --          {description = "run prompt", group = "launcher"}),
    awful.key({ modkey            }, "e",     function () awful.util.spawn("pcmanfm-qt") end),
    awful.key({ "Control", Alt_L  }, "l", function () awful.util.spawn("xscreensaver-command -lock") end),
    --awful.key({ "Control", Alt_L  }, "l", function () awful.util.spawn("xdg-screensaver lock") end),
    --awful.key({                   }, "F7", function () awful.util.spawn("toggle-window.sh Telegram") end),
    --awful.key({                   }, "F8", function () awful.util.spawn("toggle-window.sh Slack") end),
    awful.key({                   }, "F7", function () toggle_visibility("Telegram") end),
    --awful.key({                   }, "F8", function () toggle_visibility("Slack") end),
    --awful.key({ }, "F9", function () awful.util.spawn("toggle-window.sh pidgin_conversation") end),
    --awful.key({ }, "F12", function () awful.util.spawn("toggle-window.sh pidgin_buddy_list") end),
    -- volume control
    awful.key({}, "XF86AudioRaiseVolume",     function() volumecfg:up() end),
    awful.key({}, "XF86AudioLowerVolume",     function() volumecfg:down() end),
    awful.key({}, "XF86AudioMute",            function() volumecfg:toggle() end),
    awful.key({ modkey            }, "Prior", function() volumecfg:up() end),
    awful.key({ modkey            }, "Next",  function() volumecfg:down() end),
    awful.key({ modkey            }, "m",     function() volumecfg:toggle() end),
    ---- Brightness
    awful.key({}, "XF86MonBrightnessDown", function () awful.util.spawn("light -U 15") end),
    awful.key({}, "XF86MonBrightnessUp",   function () awful.util.spawn("light -A 15") end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description="Jump to 'urgent' client", group="awesome - tags"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
            { description = "restart awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
            { description = "quit awesome", group = "awesome"}),


    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "h",      awful.tag.viewprev       ,
        { description = "(/l) view prev/next tag", group = "awesome - tags"}),
    awful.key({ modkey,           }, "l",      awful.tag.viewnext       ),

    -- Layout manipulation
    -- focus windows
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end,
        { description = "focus next client", group = "awesome - client"}),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    -- move windows around the layout
    --awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    --awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "n", function () awful.screen.focus_relative( 1) end,
            { description = "focus next screen", group = "awesome - screens"}),
    --
    awful.key({ modkey, "Control" }, "j", function () awful.client.swap.byidx(  0)    end,
              {description = "(/k) swap client with prev/next client", group = "awesome - layout"}),

    awful.key({ modkey, "Control" }, "k", function () awful.client.swap.byidx( -1)    end),

    awful.key({ modkey, "Shift"   }, "i",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "i",     function () awful.tag.incmwfact(-0.05)    end,
              {description = "decrease master width (Shift reverses)", group = "awesome - layout"}),

    --awful.key({ Alt_L,            }, "Tab", function () awful.screen.focus_relative( 0) end),
    awful.key({ Alt_L,            }, "Tab",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end,
        { description = "focus next client", group = "awesome - client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "last switched client", group = "awesome"}),
        

    --awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    --awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),

    awful.key({ modkey,           }, "space",
        function () awful.layout.inc(1, client.focus.screen, layouts) end,
        { description = "Next layout (Shift reverses)", group = "awesome - layout"}),
    awful.key({ modkey, "Shift"   }, "space",
        function () awful.layout.inc(-1, client.focus.screen, layouts) end),

    --awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Drag window left / right
    --awful.key({ modkey, }, "Up",
    awful.key({ modkey, "Control" }, "h",
       function (c)
            local curidx = awful.tag.getidx()
            local tags = awful.tag.gettags(client.focus.screen)

            if curidx == 1 then
                awful.client.movetotag(tags[#tags])
            else
                awful.client.movetotag(tags[curidx - 1])
            end
            awful.tag.viewidx(-1)
        end,
        { description = "Drag window to next/prev tag", group = "awesome - tags"}),
    --awful.key({ modkey, }, "Down",
    awful.key({ modkey, "Control" }, "l",
      function (c)
            local curidx = awful.tag.getidx()
            local tags = awful.tag.gettags(client.focus.screen)

            if curidx == #tags then
                awful.client.movetotag(tags[1])
            else
                awful.client.movetotag(tags[curidx + 1])
            end
            awful.tag.viewidx(1)
      end)
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, max_tag do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        --awful.key({ modkey }, "#" .. i + max_tag,
        awful.key({ modkey }, i,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag "..i, group = "tag"}),
        -- Toggle tag display.
        --awful.key({ modkey, "Control" }, "#" .. i + max_tag,
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag "..i, group = "tag"}),
        -- Move client to tag.
        --awful.key({ modkey, "Shift" }, "#" .. i + max_tag,
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag "..i, group = "tag"}),
        -- Toggle tag on focused client.
        --awful.key({ modkey, "Control", "Shift" }, "#" .. i + max_tag,
        awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag " .. i, group = "tag"})
    )
end

root.keys(globalkeys)



-- Keybindings for the client.
-- Table used in window_rules
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
            function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "fullscreen (toggle)", group = "awesome - client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
            { description = "floating (toggle)", group = "awesome - client"}),
    awful.key({ "Control", Alt_L  }, "x",      function (c) c:kill() end,
            { description = "kill window", group = "awesome - client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
            { description = "Swap focused client with master", group = "awesome - layout"}),
    --awful.key({ modkey,           }, "n",
    --    function (c)
    --        -- The client currently has the input focus, so it cannot be
    --        -- minimized, since minimized clients can't have the focus.
    --        c.minimized = true
    --    end),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "awesome - screens"})
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    --awful.key({ modkey,           }, "m",
    --    function (c)
    --        c.maximized = not c.maximized
    --        c:raise()
    --    end ,
    --    {description = "(un)maximize", group = "client"}),
    --awful.key({ modkey, "Control" }, "m",
    --    function (c)
    --        c.maximized_vertical = not c.maximized_vertical
    --        c:raise()
    --    end ,
    --    {description = "(un)maximize vertically", group = "client"}),
    --awful.key({ modkey, "Shift"   }, "m",
    --    function (c)
    --        c.maximized_horizontal = not c.maximized_horizontal
    --        c:raise()
    --    end ,
    --    {description = "(un)maximize horizontally", group = "client"})
)



----------------------------------------------------------------------
----------------------------------------------------------------------

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
                     placement = awful.placement.no_overlap + awful.placement.no_offscreen
     }
    },

    { rule_any = { class = { 
        "Plugin-container", "Hamster", "Pavucontrol", "Spotify", "Vlc", "VirtualBox",
        "keepassx2", "Pidgin"
      } },
      properties = { floating = true }
    },
    { rule = { class = "krunner" },
      properties = { floating = true, sticky = true, size_hints_honor = false, x=800, y=100 }
    },
    { rule = { class = "Slack" },
      properties = {
          tag = "5",
          --hidden = true, skip_taskbar = true, sticky = true,
          floating = true, maximized = false, sticky = false,
          --size_hints_honor = false,
          width=1200, height=800,
          placement = awful.placement.centered
      }
    },
    { rule = { class = "Telegram" },
      properties = {
          tag = "5",
          --hidden = true, skip_taskbar = true,
          floating = true, maximized = false, sticky = false,
          --size_hints_honor = false,
          width=1000, height=600,
          placement = awful.placement.centered
      }
    },
    { rule = { class = "lxqt-panel", type = "dock" },
      properties = { size_hints_honor = false }
    },
    --
    --{ rule = {
    --    class = "Yakuake" },
    --    properties = {
    --        floating = true, ontop = true, above = true, size_hints_honor = true,
    --        width=1366, maximized_horizontal = true
    --} },
    { rule = { class = "Firefox" },
      properties = { tag = "1" } },
    { rule_any = {
        class = { "gimp", "pinentry", "MPlayer" },
      }, properties = { floating = true, size_hints_honor = true, maximized_horizontal = false, maximized_vertical = false } 
    }
}
----------------------------------------------------------------------
----------------------------------------------------------------------
