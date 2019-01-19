local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local widgets = require("widgets")

local use_font = widgets.font

local sysclock = wibox.widget.textclock("    %a %Y-%m-%d %X ", 1)
sysclock.font = use_font

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                         position = "bottom_left",
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
                         position = "bottom_left",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.font = use_font

terminal = "kitty"
modkey = "Mod1"

awful.layout.layouts = {
    awful.layout.suit.tile.top,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.left
}

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

local function set_wallpaper(s)
    gears.wallpaper.set("#333333")
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    s.mytaglist = awful.widget.taglist(
        s,
        awful.widget.taglist.filter.all,
        nil,
        {
            spacing = 10,
            layout  = wibox.layout.fixed.horizontal,
            bg_occupied = "#464646"
        }
    )

    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags)
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            widgets.lock_widget,
            widgets.stats_widget,
            widgets.battery_widget,
            widgets.brightness_widget,
            widgets.volume_widget,
            widgets.net_widget,
            sysclock,
            wibox.widget.systray(),
            s.mylayoutbox,
        },
    }
end)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
))
-- }}}

local function move_focus(s, dir)
    local screen = s.focus_relative(dir)
    if screen ~= nil then
        s.focus(screen.index)
    end
end

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "h",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,           }, "Left", function () awful.client.focus.byidx( 1) end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "Right", function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, }, "Tab", function () move_focus(awful.screen, 1) end,
              {description = "focus the right screen", group = "screen"}),
    awful.key({ modkey, "Shift" }, "Tab", function () move_focus(awful.screen, -1) end,
              {description = "focus the left screen", group = "screen"}),
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "d", function () awful.spawn("dmenu-local -i -l 10 -fn '-*-terminal-medium-*-*-*-18-*-*-*-*-*-*-*' -m " .. mouse.screen.index - 1) end,
              {description = "start dmenu", group = "launcher"}),
    awful.key({ modkey,           }, "s", function () awful.spawn("subsystem autoclip now") end,
              {description = "quick clip", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "e", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    -- Workspaces
    awful.key({ modkey, "Shift"   }, "m", function () awful.spawn("subsystem workspaces 1") end,
              {description = "mobile workspace", group = "system"}),
    awful.key({ modkey, "Shift"   }, "o", function () awful.spawn("subsystem workspaces 2") end,
              {description = "dock workspace", group = "system"}),

    awful.key({ modkey, "Shift"   }, "Up",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Down",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Control" }, "Up",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "Down",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),

    -- locking
    awful.key({ modkey, "Shift"    }, "x", function () awful.spawn("locking toggle") end,
              {description = "toggle locking", group = "system"}),
    awful.key({ modkey, "Shift"    }, "l", function () awful.spawn("locking lock") end,
              {description = "lock", group = "system"}),
    awful.key({ modkey, "Shift"    }, "s", function () awful.spawn("locking sleep") end,
              {description = "suspend", group = "system"}),
   -- Volume Keys
   awful.key({}, "XF86AudioLowerVolume", function ()  awful.util.spawn("volume dec", false)  end),
   awful.key({}, "XF86AudioRaiseVolume", function ()  awful.util.spawn("volume inc", false)  end),
   awful.key({}, "XF86AudioMute", function () awful.util.spawn("volume togglemute", false)  end),
   -- Brightness
   awful.key({}, "XF86MonBrightnessUp", function () awful.util.spawn("subsystem backlight up", false) end),
   awful.key({}, "XF86MonBrightnessDown", function () awful.util.spawn("subsystem backlight down", false) end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Shift" }, "space", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "n",      function (c) c:move_to_screen()               end,
              {description = "move to next screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "n",      function (c) c:move_to_screen(c.screen.index-1)               end,
              {description = "move to last screen", group = "client"})
)

for i = 1, 5 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end))

root.keys(globalkeys)

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

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },
}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("request::titlebars", function(c)
    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- autoruns
awful.spawn.with_shell("subsystem workspaces 1")
awful.spawn.with_shell("xautolock -time 5 -locker '/home/enck/.local/bin/locking lock'")
awful.spawn.with_shell("status")
widgets.setup_timers()
