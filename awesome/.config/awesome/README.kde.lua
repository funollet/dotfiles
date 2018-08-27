--
-- [todo] - KDE menu: /usr/bin/plasma-windowed simplelauncher
--

-- KDE has no widget to see which layout is selected. Workaround: use libnotify.
-- TODO: callback it with a signal.
function echo_layout()
    naughty.notify({ title="Awesome layout", text=awful.layout.getname() })
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "space",
        function () awful.layout.inc(layouts,  1) ; echo_layout()
        end),
    awful.key({ modkey, "Shift"   }, "space",
        function () awful.layout.inc(layouts, -1) ; echo_layout()
        end)
)


-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    { rule = { type = "desktop" },
    },
    { rule = { class = "krunner" },
      properties = { floating = true, sticky = true, size_hints_honor = false, y=32 }
    },

    ---- ::KDE config:: --
    { rule = { class = "Plasma" },
      properties = { floating = true,sticky=true, size_hints_honor = true } },
    { rule = { class = "Plasma", type = "dock" },
      properties = { x = 0, y = 0, size_hints_honor = false } },
    { rule = { class = "Plasma-desktop" },
      properties = { floating = true, size_hints_honor = true,maximized_horizontal = false, maximized_vertical = false } }
}
-- }}}



-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

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
end)
