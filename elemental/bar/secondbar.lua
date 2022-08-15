local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local apps = require("apps")

local keys = require("keys")
local helpers = require("helpers")

-- Helper function that creates a button widget
local create_button = function (symbol, color, bg_color, hover_color)
    local widget = wibox.widget {
        font = "icomoon 14",
        align = "center",
        id = "icon_role",
        valign = "center",
        markup = helpers.colorize_text(symbol, color),
        widget = wibox.widget.textbox()
    }

    local section = wibox.widget {
        widget,
        forced_width = dpi(70),
        bg = bg_color,
        widget = wibox.container.background
    }

    -- Hover animation
    section:connect_signal("mouse::enter", function ()
        section.bg = hover_color
    end)
    section:connect_signal("mouse::leave", function ()
        section.bg = bg_color
    end)

    -- helpers.add_hover_cursor(section, "hand1")

    return section
end

local exit = create_button("", x.color6, x.color8.."C0",x.color8.."E0")
exit:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        exit_screen_show()
    end)
))

local volume_symbol = ""
local volume_muted_color = x.color8
local volume_unmuted_color = x.color5
local volume = create_button(volume_symbol, volume_unmuted_color, x.color8.."30", x.color8.."50")

volume:buttons(gears.table.join(
    -- Left click - Mute / Unmute
    awful.button({ }, 1, function ()
        helpers.volume_control(0)
    end),
    -- Right click - Run or raise volume control client
    awful.button({ }, 3, apps.volume),
    -- Scroll - Increase / Decrease volume
    awful.button({ }, 4, function ()
        helpers.volume_control(5)
    end),
    awful.button({ }, 5, function ()
        helpers.volume_control(-5)
    end)
))

awesome.connect_signal("evil::volume", function(_, muted)
    local t = volume:get_all_children()[1]
    if muted then
        t.markup = helpers.colorize_text(volume_symbol, volume_muted_color)
    else
        t.markup = helpers.colorize_text(volume_symbol, volume_unmuted_color)
    end
end)

local microphone_symbol = ""
local microphone_muted_color = x.color8
local microphone_unmuted_color = x.color3
local microphone = create_button(microphone_symbol, microphone_unmuted_color, x.color8.."60", x.color8.."80")

microphone:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        awful.spawn.with_shell("amixer -D pulse sset Capture toggle &> /dev/null")
    end)
))

awesome.connect_signal("evil::microphone", function(muted)
    local t = microphone:get_all_children()[1]
    if muted then
        t.markup = helpers.colorize_text(microphone_symbol, microphone_muted_color)
    else
        t.markup = helpers.colorize_text(microphone_symbol, microphone_unmuted_color)
    end
end)

local music = create_button("", x.color4, x.color8.."90", x.color8.."B0")

music:buttons(gears.table.join(
    awful.button({ }, 1, apps.music),
    awful.button({ }, 3, apps.music),
    -- Scrolling: Adjust mpd volume
    awful.button({ }, 4, function ()
        awful.spawn.with_shell("mpc volume +5")
    end),
    awful.button({ }, 5, function ()
        awful.spawn.with_shell("mpc volume -5")
    end)
))

local sandwich = create_button("", x.color1, x.color8.."30", x.color8.."50")
sandwich:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        app_drawer_show()
    end),
    awful.button({ }, 2, apps.scratchpad),
    awful.button({ }, 3, function ()
        tray_toggle()
    end)
))


local tag_colors_empty = { "#00000000", "#00000000", "#00000000", "#00000000", "#00000000", "#00000000", "#00000000", "#00000000", "#00000000", "#00000000", }

local tag_colors_urgent = {
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background,
    x.background
}

local tag_colors_focused = {
    x.color1,
    x.color5,
    x.color4,
    x.color6,
    x.color2,
    x.color3,
    x.color1,
    x.color5,
    x.color4,
    x.color6,
}

local tag_colors_occupied = {
    x.color1.."55",
    x.color5.."55",
    x.color4.."55",
    x.color6.."55",
    x.color2.."55",
    x.color3.."55",
    x.color1.."55",
    x.color5.."55",
    x.color4.."55",
    x.color6.."55",
}

local mtextclock = wibox.widget {
 format = '<span color="#3fa6973">%a %b %d, %H:%M</span>',
 widget = wibox.widget.textclock,
    font = "ubuntu mono bold 18",
    align = "center",
    forced_width = dpi(2100),
}
local mytextclock = wibox.widget {
  widget = wibox.container.background,
--  bg = beautiful.bg_normal,
  buttons = {
    awful.button({}, 1, function()
      require"ui.popup.calender"()
    end),
  },
  {
    widget = wibox.container.margin,
    margins = 1,
    {
      widget = wibox.widget.textclock '<span color="#fa6973">%a %b %d %H:%M</span>',
      font =  "ubuntu mono bold 18",
      align = "center",
      forced_width = dpi(1920),
    },
  },
}

local email_widget, email_icon = require("pimpwidgets.email-widget.email")




-- Helper function that updates a taglist item
local update_taglist = function (item, tag, index)
    if tag.selected then
        item.bg = tag_colors_focused[index]
    elseif tag.urgent then
        item.bg = tag_colors_urgent[index]
    elseif #tag:clients() > 0 then
        item.bg = tag_colors_occupied[index]
    else
        item.bg = tag_colors_empty[index]
    end
end

awful.screen.connect_for_each_screen(function(s)
    -- Create a taglist for every screen
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = keys.taglist_buttons,
        layout = wibox.layout.flex.horizontal,
        widget_template = {
            widget = wibox.container.background,
            create_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
            update_callback = function(self, tag, index, _)
                update_taglist(self, tag, index)
            end,
        }
    }

    -- Create a tasklist for every screen
    s.mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = keys.tasklist_buttons,
        style    = {
            font = "ubuntu mono",
            bg = x.color8,
	    disable_icon = false
        },
        layout   = {
            spacing = dpi(25),
            spacing_widget = wibox.widget.separator,
            layout  = wibox.layout.fixed.horizontal
           -- layout  = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    id     = "icon_role",
                    align  = "center",
		    valign = "center",
                    widget = wibox.widget.imagebox,
                },
		
		left = dpi(15),
                right = dpi(15),
                -- Add margins to top and bottom in order to force the
                -- text to be on a single line, if needed. Might need
                -- to adjust them according to font size.
                top  = dpi(2),
                bottom = dpi(2),
                widget = wibox.container.margin
            },
         --   shape = helpers.rrect(dpi(20)),
        --   border_width = dpi(1),
          --  border_color = x.color6,
            id = "bg_role",
           --  id = "background_role",
          --  shape = gears.shape.rounded_bar,
            widget = wibox.container.background,
        },
    }
        -- Create a system tray widget
    s.systray = wibox.widget.systray{
        screen   = s,
        style    = {
            bg = "#11000FF",
            systray_icon_spacing = dpi(45),

        },
        layout   = {
            spacing = dpi(45),
            spacing_widget = wibox.widget.separator,
            icon_spacing = 3,
--            layout  = wibox.layout.fixed.horizontal
           -- layout  = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    id     = "icon_role",
                    align  = "center",
           		    valign = "center",
                    widget = wibox.widget.imagebox,
                },
		
		left = dpi(45),
                left = dpi(45),
                -- Add margins to top and bottom in order to force the
                -- text to be on a single line, if needed. Might need
                -- to adjust them according to font size.
                top  = dpi(2),
                bottom = dpi(2),
                widget = wibox.container.margin
            },
         --   shape = helpers.rrect(dpi(20)),
        --   border_width = dpi(1),
          --  border_color = x.color6,
            id = "bg_role",
           --  id = "background_role",
          --  shape = gears.shape.rounded_bar,
            widget = wibox.container.background,
        },
    }

local ssystray = create_button("s.systray", x.color1, x.color8.."30", x.color8.."50")
ssystray:buttons(gears.table.join(
    awful.button({ }, 1, function ()
        app_drawer_show()
    end),
    awful.button({  }, 2, apps.scratchpad),
    awful.button({  }, 3, function ()
        tray_toggle()
    end)
))

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox.resize = true
    s.mylayoutbox.forced_width  = beautiful.wibar_height - dpi(5)
    s.mylayoutbox.forced_height = beautiful.wibar_height - dpi(5)
    s.mylayoutbox:buttons(gears.table.join(
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end),
    awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create the wibox
    s.mywibox = awful.wibar({screen = s, visible = true, ontop = true, type = "dock", position = "top"})
    s.mywibox.height = dpi(25)
    -- s.mywibox.width = beautiful.wibar_width

    -- For antialiasing
    -- The actual background color is defined in the wibar items
    -- s.mywibox.bg = "#00000000"
--     s.mywibox.bg = "#11000FF"
 s.mypromptbox = awful.widget.prompt()
    -- s.mywibox.bg = x.color8
    -- s.mywibox.bg = x.foreground
    s.mywibox.bg = x.background.."88"
    -- s.mywibox.bg = x.background
    -- s.mywibox.bg = x.color0
     s.mywibox.opacity = 1

         local function system_tray()
local mysystray = wibox.widget.systray(){
    style = {
    systray_icon_spacing = 10,
    

             },
         }

		mysystray.base_size = beautiful.systray_icon_size

		local widget = wibox.widget({
			widget = wibox.container.constraint,
			strategy = "max",
			width = dpi(0),
			{
				widget = wibox.container.margin,
				margins = dpi(10),
				mysystray,
			},
		})

		local system_tray_animation = animation:new({
			easing = animation.easing.linear,
			duration = 0.125,
			update = function(self, pos)
				widget.width = pos
			end,
		})

		local arrow = wbutton.text.state({
			text_normal_bg = beautiful.accent,
			normal_bg = beautiful.wibar_bg,
			font = beautiful.icon_font .. "Round ",
			size = 18,
			text = "",
			on_turn_on = function(self)
				system_tray_animation:set(400)
				self:set_text("")
			end,
			on_turn_off = function(self)
				system_tray_animation:set(0)
				self:set_text("")
			end,
		})

		return wibox.widget({
			layout = wibox.layout.fixed.horizontal,
			arrow,
			widget,
		})
    end

    -- Bar placement
    awful.placement.maximize_horizontally(s.mywibox)

beautiful.systray_icon_spacing = dpi(20)
beautiful.systray_icon_size = dpi(5)
beautiful.bg_systray = "#808080"
    -- Wibar items
    -- Add or remove widgets here
        screen[1].mywibox:setup {
    screen[1].systray,
    
--   mysystray,

{
    screen[1].mytasklist,
	screen[1].mypromptbox,
	spacing = 10,
	spacing_widget = wibox.widget.separator,
	layout = wibox.layout.fixed.horizontal
},
 -- s.systray,
    {

            mytextclock,
            sandwich,
            volume,
            microphone,
            music,
            exit,
            layout = wibox.layout.fixed.horizontal
        },

        layout = wibox.layout.align.horizontal
   }

--spacing        = 10,
--spacing_widget = wibox.widget.separator,
--layout = wibox.layout.fixed.horizontal,
--s.mytasklist,


--spacing        = 10,
--spacing_widget = wibox.widget.separator,
--l:wq
--ayout = wibox.layout.fixed.horizontal,
--mytextclock,
    
--{
 --          volume,
   --         microphone,
     --       music,
       --     exit,
         --   layout = wibox.layout.fixed.horizontal
        --}
--}




    -- Create the top bar
    s.mytopwibox = wibox.container.only_on_screen(( awful.wibar({screen = s, visible = true, ontop = false, type = "dock", position = "top", height = dpi(5)})()
    -- Bar placement
    awful.placement.maximize_horizontally(s.mytopwibox)
    s.mytopwibox.bg = "#111111FF"

    s.mytopwibox:setup {
        widget = s.mytaglist,
    }
    

    -- Create a system tray widget
    -- s.systray = wibox.widget.systray()



    -- Place bar at the bottom and add margins
    -- awful.placement.bottom(s.mywibox, {margins = beautiful.screen_margin * 2})
    -- Also add some screen padding so that clients do not stick to the bar
    -- For "awful.wibar"
    -- s.padding = { bottom = s.padding.bottom + beautiful.screen_margin * 2 }
    -- For "wibox"
    -- s.padding = { bottom = s.mywibox.height + beautiful.screen_margin * 2 }

end)

-- We have set the wibar(s) to be ontop, but we do not want it to be above fullscreen clients
local function no_wibar_ontop(c)
    local s = awful.screen.focused()
    if c.fullscreen then
        s.mywibox.ontop = false
    else
        s.mywibox.ontop = true
    end
end

client.connect_signal("focus", no_wibar_ontop)
client.connect_signal("unfocus", no_wibar_ontop)
client.connect_signal("property::fullscreen", no_wibar_ontop)

-- Every bar theme should provide these fuctions
function wibars_toggle()
    local s = awful.screen.focused()
    s.mywibox.visible = not s.mywibox.visible
    s.mytopwibox.visible = not s.mytopwibox.visible
end

