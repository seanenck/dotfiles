local bin
local status
local tmp
local i3files
local reset_status
local sysonline

function read_env()
    bin = os.getenv("HOME_BIN") .. "/"
    status = bin .. "status "
    tmp = os.getenv("USER_TMP")
    i3files = tmp .. "i3."
    reset_status = os.getenv("STATUS_RESET")
    sysonline = os.getenv("SYS_ONLINE")
end

function call(script)
    local f = io.popen(script, 'r')
    local s = f:read('*a')
    f:close()
    return s:match("^%s*(.-)%s*$") 
end

function volume(cmd)
    return call(bin .. "volume " .. cmd)
end

function sleeping()
    call("sleep 1")
end

function ac()
    return tonumber(call("cat /sys/class/power_supply/AC/online"))
end

function locking()
    local res = call(bin .. "locking status")
    if res == '' or res == nil then
        return nil
    else
        return res
    end
end

function brightness()
    local res = tonumber(call('xrandr --current --verbose | grep "Brightness" | cut -d ":" -f 2 | sed "s/0\\.//g" | sed "s/1\\.0/100/g" | tail -n 1 | awk \'{printf "%3.0f", $1}\' | sed "s/^[ \\t]*//g"'))
    local val = string.format("%3d", res)
    return "* " .. val .. "%"
end

function online(last)
    local avail = file_exists(sysonline)
    if not avail or last >= 30 then
        call(status .. "online")
    end
    return avail
end

function percent(val)
    local num = tonumber(conky_parse(val))
    local val
    val = num
    if num < 100 then
        val = " " .. val
        if num < 10 then
            val = " " .. val
        end
    end
    return val
end

function file_exists(name)
   local f=io.open(name,"r")
   if f ~= nil then
       io.close(f)
       return true
   else
       return false
   end
end

function updates()
    call(status)
end

function stats()
    local results = {}
    local k, v
    for k, v in pairs({"git", "email"}) do
        local stat = call(status .. v)
        if stat ~= '' and stat ~= nil then
            table.insert(results, stat)
        end
    end
    return results
end

function primary(cache)
    local outputs = {}
    local battery = 0
    local power = "("
    local k, v
    if cache.power ~= nil and cache.battery ~= nil then
        power = cache.power
        battery = cache.battery
    else
        for k, v in pairs({"0", "1"}) do
            local perc = tonumber(call("cat /sys/class/power_supply/BAT" .. v .. "/capacity"))
            battery = battery + perc
            power = power .. string.format("%3d", perc)
            if k == 1 then
                power = power .. ","
            end
        end
        cache.power = power
        cache.battery = battery
    end
    power = power .. ")%"
    local bind = "-"
    local drain = ac() == 0
    local lowBat = false
    if drain then
        if battery < 20 then
            lowBat = true
            cache.battery = nil
            cache.power = nil
        end
    else
        bind = "+"
    end
    cache.update_interval = cache.update_interval + 1
    if cache.update_interval > 2 then
        cache.update_interval = 0
        updates()
    end
    local avail = online(cache.last_online)
    if avail then
        cache.last_online = cache.last_online + 1
        if cache.last_online > 30 then
            cache.last_online = 0
        end
    else
        cache.last_online = 0
    end
    table.insert(outputs, locking())
    for k, v in pairs(stats()) do
        table.insert(outputs, v)
    end
    table.insert(outputs, brightness())
    local mute = volume("ismute") == "true"
    local vol = tonumber(volume("volume"))
    local sound = ""
    if mute then
        sound = "<|"
    else
        sound = "<="
    end
    sound = sound .. string.format(" %3d%%", vol)
    table.insert(outputs, sound)
    local dispBat = "[" .. bind .. "]" .. power
    table.insert(outputs, dispBat)
    local wireless = cache.wireless
    local wired = cache.wired
    local reset = false
    if not avail then
        reset = true
    end
    if cache.wireless ~= nil and cache.wired ~= nil then
        reset = true
    end
    cache.netcount = cache.netcount + 1
    if cache.netcount > 60 then
        cache.netcount = 0
        reset = true
    end
    if reset then
        cache.wireless = nil
        cache.wired = nil
    end
    if cache.wireless == nil then
        wireless = ipv4("W", "wlp58s0", avail)
        cache.wireless = wireless
    end
    if cache.wired == nil then
        wired = ipv4("E", "enp0s31f6", avail)
        cache.wired = wired
    end
    table.insert(outputs, wireless)
    table.insert(outputs, wired)
    if cache.wired == nil and cache.wireless == nil then
        table.insert(outputs, "OFFLINE")
    end
    return outputs
end

function ipv4(prefix, iface, online)
    local addr = call("ip addr | grep " .. iface .. " | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d'/' | grep '[0-9][0-9]*\\.[0-9][0-9]*\\.[0-9][0-9]*\\.[0-9][0-9]*$' | sed 's/^/" .. prefix .. ": /g'")
    if addr == '' or addr == nil then
        return nil 
    else
        return addr
    end
end

function main()
    local running = true
    local cache = {}
    cache.last_online = 0
    cache.update_interval = 5
    cache.netcount = 0
    local idx = 0
    while running do
        local values = {}
        values = primary(cache)
        for k, v in pairs(values) do
            local out = v
            print(out)
        end
        sleeping()
        idx = idx + 1
        if idx > 30 then
            idx = 0
            cache.battery = nil
            cache.power = nil
        end
        if file_exists(reset_status) then
            call("rm -f " .. reset_status)
            return
        end
    end
end

read_env()
while true do
    main()
    sleeping()
end
