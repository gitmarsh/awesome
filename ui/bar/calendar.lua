local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi
local naughty = require('naughty')


local rubato = require("modules.rubato")
awesome.register_xproperty("WM_CLASS","string")

local styles = {}
local function rounded_shape(size, partial)
    if partial then
        return function(cr, width, height)
            gears.shape.rectangle(cr, width + 5, height, 11)
        end
    else
        return function(cr, width, height)
            gears.shape.rectangle(cr, width, height, size)
        end
    end
end
styles.month = {padding = 5, bg_color = '#555555', shape = rounded_shape(10)}
-- styles.normal = {shape = rounded_shape(5)}
styles.focus = {
    fg_color = nord.nord12, -- Current day Color
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = rounded_shape(5, true)
}
styles.header = {
    fg_color = "#50fa7b", -- Month Name Color
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = rounded_shape(10)
}
styles.weekday = {
    fg_color = "#ECEFF1", -- Day Color
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = rounded_shape(5)
}
local function decorate_cell(widget, flag, date)
    if flag == 'monthheader' and not styles.monthheader then flag = 'header' end
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end
    local d = {
        year = date.year,
        month = (date.month or 1),
        day = (date.day or 1)
    }
    local weekday = tonumber(os.date('%w', os.time(d)))
    local ret = wibox.widget {
        {
            widget,
            margins = (props.padding or 2) + (props.border_width or 0),
            widget = wibox.container.margin
        },
        fg = props.fg_color or '#999999',
        widget = wibox.container.background
    }
    return ret
end

local cal = wibox.widget {

    date = os.date('*t'),
    font = 'Product Sans 13',
    fn_embed = decorate_cell,
    -- start_sunday = true,
    widget = wibox.widget.calendar.month

}

local calWidget = wibox.widget {
    {
        nil,
        {
            cal, 
            margins = dpi(16), 
            widget = wibox.container.margin
        },
        nil,
        layout = wibox.layout.flex.horizontal
    },
    resize = true,
    bg = beautiful.bg_normal,
    widget = wibox.container.background
}

local calendar = awful.popup {
    ontop = true,
    visible = false,
    y = beautiful.wibar_height + beautiful.useless_gap*2,
    -- shape = gears.shape.rounded_rect,
    -- border_width = 1,
    -- border_color = "#282828",
    widget = calWidget
}


local panel_timed = rubato.timed {
    intro = 0.1,
    duration = 0.3,
    easing = rubato.quadratic,
    subscribed = function(pos)
        if pos >= awful.screen.focused().geometry.width then
            calendar.visible = false
        end
        calendar.x = pos 
    end
}

panel_timed.target = awful.screen.focused().geometry.width

calendar:set_xproperty("WM_CLASS", "calendar")

cal:buttons(
        awful.util.table.join(
                awful.button({}, 4, function()
                    local a = cal:get_date()
                    a.month = a.month + 1
                    cal:set_date(nil)
                    cal:set_date(a)
                    -- calendar:set_widget(calWidget)
                end),
                awful.button({}, 5, function()
                    local a = cal:get_date()
                    a.month = a.month - 1
                    cal:set_date(nil)
                    cal:set_date(a)
                    -- calendar:set_widget(calWidget)
                end)
        )
)

function cal_toggle()
    if calendar.x == awful.screen.focused().geometry.width then
        calendar.visible = true
        panel_timed.target = awful.screen.focused().geometry.width - calendar.width - beautiful.useless_gap*2
    else
        panel_timed.target = awful.screen.focused().geometry.width
    end

    -- if popup.visible then
    --     -- to faster render the calendar refresh it and just hide
    --     cal:set_date(nil) -- the new date is not set without removing the old one
    --     cal:set_date(os.date('*t'))
    --     popup:set_widget(nil) -- just in case
    --     popup:set_widget(calWidget)
    --     popup.visible = not popup.visible
    -- else        
    --     awful.placement.top_right(popup, { margins = { top = 40, right = 5}, parent = awful.screen.focused() })

    --     popup.visible = true

    -- end
    
end

return cal
