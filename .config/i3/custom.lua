local home = "/home/enck/"
local bin  = home .. ".bin/"
local status = bin .. "status "

function call(script)
    return conky_parse('${exec ' .. script .. '}')
end

function conky_ac()
    return call("cat /sys/class/power_supply/AC/online")
end

function json_text(data)
    return '{ "full_text": ' .. data .. '}'
end

function conky_locking()
    local res = call(bin .. "locking status")
    if res == '' or res == nil then
        return ""
    else
        return json_text(res) .. ','
    end
end

function conky_online()
    call(status .. "online")
    return conky_parse("${if_existing " .. home .. ".tmp/.isonline}0${else}1${endif}")
end

function conky_percent(val)
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

function conky_status()
    local results = {}
    local k, v
    for k, v in pairs({"errors", "git", "email", "brightness"}) do
        local stat = call(status .. v)
        table.insert(results, stat) 
    end
    local output = ""
    local first = true
    for k, v in pairs(results) do
        local valid = true
        if v == '' or v == nil then
            valid = false
        end
        if valid then
            if first then
                first = false
            else
                output = output .. ','
            end
            output = output .. json_text(v)
        end
    end
    if not first then
        output = output .. ','
    end
    return output
end
