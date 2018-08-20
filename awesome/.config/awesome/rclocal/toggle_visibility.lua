local awful = require("awful")
awful.rules = require("awful.rules")

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

