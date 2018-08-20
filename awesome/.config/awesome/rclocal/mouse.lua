local awful = require("awful")

-- Mouse bindings over the desktop
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end), -- right button: show menu 
    awful.button({ }, 4, awful.tag.viewnext),                  -- wheel: changes tag
    awful.button({ }, 5, awful.tag.viewprev),
    awful.button({ }, 6, awful.tag.viewprev), -- wheel lateral button: changes tag
    awful.button({ }, 7, awful.tag.viewnext)
))


-- Mouse actions for the client.
-- This variable is used on window_rules
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    -- wheel lateral button: changes tag
    awful.button({ }, 6, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
    awful.button({ }, 7, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end)
    )
