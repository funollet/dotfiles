-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

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

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

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

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.floating,
    --awful.layout.suit.floating,
    --awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
    -- tag 5 has layout 'floating'
    tags[s] = awful.tag({ 5, }, s, layouts[-1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })
-- [todo] - menu: /usr/bin/plasma-windowed simplelauncher

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    ---- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    ---- Create a tasklist widget
    --mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 28 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- KDE has no widget to see which layout is selected. Workaround: use libnotify.
-- TODO: callback it with a signal.
function echo_layout()
    naughty.notify({ title="Awesome layout", text=awful.layout.getname() })
end

function toggle_visibility(class_name)
    local is_class = function (c)
       return awful.rules.match(c, {class = class_name})
    end

    for c in awful.client.iterate(is_class) do
        c.minimized = not c.minimized
        if not c.minimized then
            client.focus = c
            c:raise()
        end
    end
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Standard program
    -- original spawn terminal: Ctrl-Alt-n
    -- original krunner:        Alt-Space
    awful.key({ modkey,           }, "Return",function () awful.util.spawn(terminal) end),
    awful.key({ modkey            }, "r",     function () awful.util.spawn("krunner") end),
    awful.key({ modkey            }, "e",     function () awful.util.spawn("dolphin") end),
    awful.key({ "Control", Alt_L  }, "l", function () awful.util.spawn("xdg-screensaver lock") end),
    awful.key({                   }, "F7", function () toggle_visibility("Telegram") end),
    awful.key({                   }, "F8", function () toggle_visibility("Slack") end),
    awful.key({ }, "F9", function () awful.util.spawn("toggle-window.sh pidgin_conversation") end),
    awful.key({ }, "F12", function () awful.util.spawn("toggle-window.sh pidgin_buddy_list") end),
    --awful.key({ modkey }, "p", function() menubar.show() end),
    --awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
    --awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    --awful.key({ modkey }, "x",
    --          function ()
    --              awful.prompt.run({ prompt = "Run Lua code: " },
    --              mypromptbox[mouse.screen].widget,
    --              awful.util.eval, nil,
    --              awful.util.getdir("cache") .. "/history_eval")
    --          end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit),


    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "h",      awful.tag.viewprev       ),
    awful.key({ modkey,           }, "l",      awful.tag.viewnext       ),

    -- Layout manipulation
    -- focus windows
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    -- move windows around the layout
    --awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    --awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Control" }, "k", function () awful.client.swap.byidx( -1)    end),

    awful.key({ modkey,           }, "o",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "i",     function () awful.tag.incmwfact(-0.05)    end),

    awful.key({ Alt_L,            }, "Tab", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    --awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    --awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),

    awful.key({ modkey,           }, "space",
        function () awful.layout.inc(layouts,  1) ; echo_layout()
        end),
    awful.key({ modkey, "Shift"   }, "space",
        function () awful.layout.inc(layouts, -1) ; echo_layout()
        end),

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
      end),
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


clientkeys = awful.util.table.join(
    -- original fullscreen: W-f
    -- original floating:   W-Control-space
    awful.key({ modkey,           }, "v",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "f",      awful.client.floating.toggle ),
    awful.key({ "Control", Alt_L  }, "x",      function (c) c:kill() end),
    -- Swap focused client with master.
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end)
    --awful.key({ modkey,           }, "n",
    --    function (c)
    --        -- The client currently has the input focus, so it cannot be
    --        -- minimized, since minimized clients can't have the focus.
    --        c.minimized = true
    --    end),
    --awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    --awful.key({ modkey,           }, "m",
    --    function (c)
    --        c.maximized_horizontal = not c.maximized_horizontal
    --        c.maximized_vertical   = not c.maximized_vertical
    --    end)
)


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, max_tag do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + max_tag,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + max_tag,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + max_tag,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + max_tag,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}








-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus = awful.client.focus.filter,
          raise = true,
          keys = clientkeys,
          size_hints_honor = true,
          buttons = clientbuttons
      },
    },

    { rule = { type = "desktop" },
    },
    -- Plugin-container == Flashplayer
    { rule_any = { class = { "Plugin-container", "Hamster", "Pavucontrol", "Spotify", "Vlc" } },
      properties = { floating = true }
    },
    { rule = { class = "krunner" },
      properties = { floating = true, sticky = true, size_hints_honor = false, y=32 }
    },
    { rule = { class = "Pidgin" },
      properties = { floating = true, sticky = true, size_hints_honor = false }
    },
    { rule = { class = "Slack" },
      properties = {
          tag = tags[1][4],
          hidden = true, skip_taskbar = true, floating = true, sticky = true, maximized = false,
          --size_hints_honor = false,
          width=1000, height=800, x=400, y=100 }
    },
    { rule = { class = "Telegram" },
      properties = {
          tag = tags[1][4],
          hidden = true, skip_taskbar = true, floating = true, sticky = true, maximized = false,
          --size_hints_honor = false,
          width=800, height=600, x=500, y=100 }
    },
    { rule = { class = "lxqt-panel", type = "dock" },
      properties = { y = 0, size_hints_honor = false }
    },

    --{ rule = {
    --    class = "Yakuake" },
    --    properties = {
    --        floating = true, ontop = true, above = true, size_hints_honor = true,
    --        width=1366, maximized_horizontal = true
    --} },
    --{ rule = { class = "Firefox" }, properties = { tag = tags[1][0] } },

    ---- ::KDE config:: --
    { rule = { class = "Plasma" },
      properties = { floating = true,sticky=true, size_hints_honor = true } },
    { rule = { class = "Plasma", type = "dock" },
      properties = { x = 0, y = 0, size_hints_honor = false } },
    { rule_any = { class = { "Plasma-desktop", "gimp", "pinentry", "MPlayer" },
      properties = { floating = true, size_hints_honor = true,maximized_horizontal = false, maximized_vertical = false } } }
}
-- }}}



-- {{{ Signals
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

    -- ::For KDE::
    -- Move the desktop to the bottom so it doesn't get focus on tag switching
    -- FIXME: Doesn't work perfectly (breaks when awesome is restarted)
    if c.class == "Plasma" and c.type == "desktop" then
        --c:lower()
        c:unmanage() -- essentially kill it
    end

    -- ::For KDE::
    -- Move plasmoids under the mouse (without going offscreen) and size them according
    -- to their requirements (specified in _minimum_ size hints)
    -- TODO: Avoid struts (probably not struts per se)
    if c.class == "Plasma-desktop" and c.type ~= "dock" and c.skip_taskbar then
        c:geometry( { width = c.size_hints.min_width, height = c.size_hints.min_height } )
        awful.placement.under_mouse(c)
        awful.placement.no_offscreen(c)
        -- FIXME: This has no effect (46 is the width of the plasma panel)
        --c:geometry( { x = c.x + 46 } )
    end

    local titlebars_enabled = false
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
-- }}}

-- TODO:
--   * add new client on the slave area; would be enough doing this for new teminals?
--   * launch 'kmix' at session start
--   * use Alt+Tab to switch client


--
--      W-x                         execute Lua command
--      W-r     Alt-Space           run command
--      W-Return                    open terminal
--      W---C-r                     restart awesome
--      W-S---q                     quit awesome
--
--
--
--      W-Space  W-S-Space          set next/prev layout
--      W-h      W-l                go prev/next tag
--  --C-W-h  --C-W-l                move client to prev/next tag
--
--  ----W-j  ----W-k                focus prev/next client
--  --C-W-j  --C-W-k                swap client with prev/next client
--           --C-W-Return           swap focused client with master
--
--      W-i      W-o                decr./increment master area
--
--      W-Tab                       last switched client
--      W-u                         jump to urgent client
--      W-f                         toggle floating
--      W-v                         toggle fullscreen
--
