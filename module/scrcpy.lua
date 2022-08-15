local awful = require('awful')
local ruled = require('ruled')
local beautiful = require('beautiful')
local app = require('configuration.apps').default.scrcpy
local client_keys = require('configuration.client.keys')
local client_buttons = require('configuration.client.buttons')
local scrcpy_id = nil
local scrcpy_client = nil
local scrcpy_opened = false

local scrcpy_properties = function()
	return {
		skip_decoration = true,
		titlebars_enabled = false,
		switch_to_tags = false,
		opacity = 0.95,
		floating = true,
		skip_taskbar = true,
		ontop = true,
		above = true,
		sticky = true,
		hidden = not scrcpy_opened,
		maximized_horizontal = true,
		skip_center = true,
		round_corners = false,
		keys = client_keys,
		buttons = client_buttons,
		placement = awful.placement.top,
		shape = beautiful.client_shape_rectangle
	}
end

ruled.client.connect_signal(
	'request::rules',
	function()
		ruled.client.append_rule {
			id         = 'scrcpy',
			rule_any   = { 
				instance = { 
					'scrcpy'
				}
			},
			properties = scrcpy_properties()
		}
	end
)

local create_scrcpy = function()
	-- Check if there's already an instance of 'QuakeTerminal'.
	-- If yes, recover it - use it again.
	local scrcpy_win = function (c)
		return ruled.client.match(c, {instance = 'scrcpy'})
	end
	for c in awful.client.iterate(scrcpy_win) do
		-- 'Scrcpy' instance detected
		-- Re-apply its properties
		ruled.client.execute(c, scrcpy_properties())
		scrcpy_id = c.pid
		c:emit_signal('request::activate')
		return
	end
	-- No 'scrcpy' instance, spawn one
	scrcpy_id = awful.spawn(app, scrcpy_properties())
end

local scrcpy_open = function()
	scrcpy_client.hidden = false
	scrcpy_client:emit_signal('request::activate')
end

local scrcpy_close = function()
	scrcpy_client.hidden = true
end

local scrcpy_toggle = function()
	scrcpy_opened = not scrcpy_opened
	if not scrcpy_client then
		create_scrcpy()
	else
		if scrcpy_opened then
			scrcpy_open()
		else
			scrcpy_close()
		end
	end
end

awesome.connect_signal(
	'module::scrcpy_win:toggle',
	function()
		scrcpy_toggle();
	end
)

client.connect_signal(
	'manage',
	function(c)
		if c.pid == scrcpy_id then
			scrcpy_client = c
		end
	end
)

client.connect_signal(
	'unmanage',
	function(c)
		if c.pid == scrcpy_id then
			scrcpy_opened = false
			scrcpy_client = nil
		end
	end
)
