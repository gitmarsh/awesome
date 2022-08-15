local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local function my_button(text, cb)
end




systray = wibox.widget.systray({
        style    = {
            bg = "#ff0000",
            forced_width = dpi(45),

        },
        layout   = {
            spacing = dpi(45),
            spacing_widget = wibox.widget.separator,
            icon_spacing = 3,
--            forced_width = dpi(45),
--            layout  = wibox.layout.fixed.horizontal
           -- layout  = wibox.layout.flex.horizontal
        },
        widget_template = {
                    id     = "icon_role",
                    align  = "center",
           		   valign = "center",
                   forced_width = dpi(45),
                    widget = wibox.widget.imagebox,
                },

})

beautiful.systray_icon_spacing = dpi(150)
beautiful.systray_icon_size = dpi(5)
beautiful.bg_systray = "#808080"




-- Create the box
local wiboxkey = wibox({visible = true, ontop = true, x = 540, y = 980, height = 50, width = 1000})

-- Place it at the center of the screen
--awful.placement.centered(keybox)

-- Set transparent bg
wiboxkey.bg = "#00000000"

-- Put its items in a shaped container
wiboxkey:setup {
    -- Container
    {
        -- Items go here
        forced_num_cols = 1,
        forced_num_rows = 1,
        homogeneous = true,
        expand = true,
        wibox.widget.systray({visible = true, align = "center", width = 200, height = 40}),
        layout = wibox.layout.grid
    },
    -- The real background color
    bg = "#11000FF",
    -- The real, anti-aliased shape
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background()
}
