-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local use_font = "DejaVu Sans 12"

local sysclock = wibox.widget.textclock("    %a %Y-%m-%d %X ", 1)
sysclock.font = use_font

local USER_HOME = "/home/enck/"
local HOME_BIN = USER_HOME .. ".local/bin/"
local STATS = HOME_BIN .. "status "
local SYS_ONLINE = USER_HOME .. ".cache/home/tmp/sys.online"

local function format_output(output)
    return "    " .. output
end

local function call(script)
    local f = io.popen(script, 'r')
    local s = f:read('*a')
    f:close()
    return s:match("^%s*(.-)%s*$")
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f ~= nil then
       io.close(f)
       return true
   else
       return false
   end
end

local function locking()
    local res = call(HOME_BIN .. "locking status")
    if res == '' or res == nil then
        return ""
    else
        return format_output(res)
    end
end

local function online()
    local avail = file_exists(SYS_ONLINE)
    call(STATS .. "online")
end

local function ipv4(prefix, iface, online)
    local addr = call("ip addr | grep " .. iface .. " | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/' | grep '[0-9][0-9]*\\.[0-9][0-9]*\\.[0-9][0-9]*\\.[0-9][0-9]*$' | sed 's/^/" .. prefix .. ": /g'")
    if addr == '' or addr == nil then
        return nil
    else
        return addr
    end
end

local function network()
    local avail = online()
    local wired = ipv4("E", "enp0s31f6", avail)
    local wireless = ipv4("W", "wlp58s0", avail)
    if wired == nil and wireless == nil then
        naughty.notify({ title = "WARNING", text = "OFFLINE", bg = "#ff0000", timeout = 5 })
        return format_output("OFFLINE")
    else
        local out = ""
        if wired ~= nil then
            out = out .. format_output(wired)
        end
        if wireless ~= nil then
            out = out .. format_output(wireless)
        end
        return out
    end
end

local function stats()
    local results = ""
    for k, v in pairs({"git", "email"}) do
        local stat = call(STATS .. v)
        if stat ~= '' and stat ~= nil then
            results = results .. format_output(stat)
        end
    end
    return results
end

local function brightness()
    local res = tonumber(call('xrandr --current --verbose | grep "Brightness" | cut -d ":" -f 2 | sed "s/0\\.//g" | sed "s/1\\.0/100/g" | tail -n 1 | awk \'{printf "%3.0f", $1}\' | sed "s/^[ \\t]*//g"'))
    local val = string.format("%3d", res)
    return format_output("* " .. val .. "%")
end

local function battery()
    local battery = 0
    local power = "("
    local drain = tonumber(call("cat /sys/class/power_supply/AC/online")) == 0
    for k, v in pairs({"0", "1"}) do
        local perc = tonumber(call("cat /sys/class/power_supply/BAT" .. v .. "/capacity"))
        battery = battery + perc
        power = power .. string.format("%3d", perc)
        if k == 1 then
            power = power .. ","
        end
    end
    power = power .. ")%"
    local bind = "+"
    if drain then
        bind = "-"
        if battery < 20 then
            naughty.notify({ title = "WARNING", text = "BATTERY LOW", bg = "#ff0000", timeout = 30 })
        end
    end
    return format_output("[" .. bind .. "]" .. power)
end

local lock_widget = wibox.widget{
    markup = locking(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

local battery_widget = wibox.widget{
    markup = battery(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

local function volume_cmd(cmd)
    return call(HOME_BIN .. "volume " .. cmd)
end

local function volume()
    local muted = volume_cmd("ismute") == "true"
    local sound = ""
    if muted then
        sound = "|"
    else
        sound = "="
    end
    sound = "&lt;" .. sound .. string.format(" %3d%%", tonumber(volume_cmd("volume")))
    return format_output(sound)
end

local net_widget = wibox.widget{
    markup = network(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

local stats_widget = wibox.widget{
    markup = stats(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

local brightness_widget = wibox.widget{
    markup = brightness(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

local volume_widget = wibox.widget{
    markup = volume(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

local function setup_timers()
    local thirty = timer({timeout = 30})
    thirty:connect_signal("timeout", function()
        battery_widget:set_markup(battery())
        net_widget:set_markup(network())
    end)
    thirty:start()
    local ten = timer({timeout = 10})
    ten:connect_signal("timeout", function()
        volume_widget:set_markup(volume())
        brightness_widget:set_markup(brightness())
        stats_widget:set_markup(stats())
        lock_widget:set_markup(locking())
    end)
    ten:start()
end

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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.font = use_font

terminal = "kitty"
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
}
-- }}}

-- {{{ Helper functions
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
-- }}}

local function set_wallpaper(s)
    gears.wallpaper.set("#333333")
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create widgets
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all)
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            lock_widget,
            stats_widget,
            battery_widget,
            brightness_widget,
            volume_widget,
            net_widget,
            sysclock,
            wibox.widget.systray(),
            s.mylayoutbox,
        },
    }
end)
-- }}}

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
    awful.key({ modkey,           }, "d", function () awful.spawn("dmenu-local -i -l 10 -fn '-*-terminal-medium-*-*-*-18-*-*-*-*-*-*-*'") end,
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

    awful.key({ modkey,           }, "Up",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "Down",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift" }, "Up",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift" }, "Down",     function () awful.tag.incncol(-1, nil, true)    end,
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

-- Bind all key numbers to tags.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Move client to tag.
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

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
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

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

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

-- Add a titlebar if titlebars_enabled is set to true in the rules.
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
setup_timers()
