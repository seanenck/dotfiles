local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")

local widgets = {}
use_font = "DejaVu Sans 12"
widgets.font = use_font

local USER_HOME = "/home/enck/"
local HOME_BIN = USER_HOME .. ".local/bin/"
local STATS = HOME_BIN .. "status "
local USER_TMP = USER_HOME .. ".cache/home/tmp/"
local SYS_ONLINE = USER_TMP .. "sys.online"
local STAT_RESET = USER_TMP .. "stats.reset"

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

local function notification(message)
    naughty.notify({ title = "WARNING", text = message, bg = "#ff0000", timeout = 5, position = "bottom_right" })
end

local function network()
    local avail = online()
    local wired = ipv4("E", "enp0s31f6", avail)
    if wired == nil then
        wired = ipv4("E", "enx0050b6abfe1b", avail)
    end
    local wireless = ipv4("W", "wlp3s0", avail)
    if wired == nil and wireless == nil then
        notification("offline")
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
            notification("battery low")
        end
    end
    return format_output("[" .. bind .. "]" .. power)
end

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

widgets.lock_widget = wibox.widget{
    markup = locking(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

widgets.battery_widget = wibox.widget{
    markup = battery(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

widgets.net_widget = wibox.widget{
    markup = network(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

widgets.stats_widget = wibox.widget{
    markup = stats(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

widgets.brightness_widget = wibox.widget{
    markup = brightness(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

widgets.volume_widget = wibox.widget{
    markup = volume(),
    align  = 'center',
    valign = 'center',
    font = use_font,
    widget = wibox.widget.textbox
}

widgets.sysclock = wibox.widget.textclock("    %a %Y-%m-%d %X ", 1)
widgets.sysclock.font = use_font

function widgets.setup_timers()
    local t = timer({timeout = 1})
    local cnt = 0
    t:connect_signal("timeout", function()
        if file_exists(STAT_RESET) then
            cnt = 11
            call("rm -f " .. STAT_RESET)
        end
        if cnt > 10 then
            widgets.battery_widget:set_markup(battery())
            widgets.net_widget:set_markup(network())
            widgets.volume_widget:set_markup(volume())
            widgets.brightness_widget:set_markup(brightness())
            widgets.stats_widget:set_markup(stats())
            widgets.lock_widget:set_markup(locking())
            cnt = 0
        else
            cnt = cnt + 1
        end
    end)
    t:start()
end

return widgets
