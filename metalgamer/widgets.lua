local awful = awful
local wibox = wibox
local timer = timer
local string = string
local beautiful = beautiful
local naughty = naughty
local image = image
local io = io
local math = math
local os = os
local pairs = pairs
local tonumber = tonumber
local lfs = lfs
local table = table
local ipairs = ipairs
local metalgamer = metalgamer

module("metalgamer.widgets")

terminal = ""
browser = ""

-- Deluge widget
function deluge(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 30
    local ip = args.ip or "localhost"
    local port = args.port or "58846"
    local username = args.username or ""
    local password = args.password or ""
    local prefix = args.prefix or "Deluge: "

    local mydeluge = wibox.widget.textbox()
    local mydelugeupdate = function()
        local connection = io.popen("deluge-console connect "..ip..":"..port.." "..username.." "..password)
        local f = io.popen("deluge-console info")
        local ret = f:read("*all")
        connection:close()
        f:close()
        
        local downloading = 0
        local seeding = 0
        local paused = 0
        local queued = 0
        local total = 0
        
        for w in string.gfind(ret, "Downloading") do
            downloading = downloading + 1
        end

        for w in string.gfind(ret, "Seeding") do
            seeding = seeding + 1
        end
        for w in string.gfind(ret, "Paused") do
            paused = paused + 1
        end

        for w in string.gfind(ret, "Queued") do
            queued = queued + 1
        end

        for w in string.gfind(ret, "Name") do
            total = total + 1
        end

        mydeluge:set_text(string.format("%s D: %d - S: %d - Q: %d - P: %d - T: %d", prefix, downloading, seeding, queued, paused, total))

    end
    mydelugeupdate()

    local mydelugetimer = timer({ timeout = refresh_timeout })
    mydelugetimer:connect_signal("timeout", mydelugeupdate)
    mydelugetimer:start()

    mydeluge:buttons(awful.util.table.join(
                awful.button({}, 1, function () awful.util.spawn("deluge-console pause *", false) end),
                awful.button({}, 3, function () awful.util.spawn("deluge-console resume *", false) end)
                )
            )
    
    return mydeluge
end

-- Int IP
function intip(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 600
    local interface = args.interface or "eth0"
    local prefix = args.prefix or "Int. IP: "

    local myintip = wibox.widget.textbox()
    local myintipupdate = function()
        local f = io.popen("ip addr show "..interface)
        local ret = f:read("*all")
        f:close()
        
        local i, j = string.find(ret, "%d+%.%d+%.%d+%.%d+")
        
        if i == nil then
            ip = "N/A"
        else
            ip = string.sub(ret, i, j)
        end
        
        local text = prefix .. ip
        myintip:set_text(text)
    end
    myintipupdate()

    local myintiptimer = timer({ timeout = refresh_timeout })
    myintiptimer:connect_signal("timeout", myintipupdate)
    myintiptimer:start()

    myintip:buttons(awful.util.table.join(
                awful.button({}, 1, function() myintipupdate() end)
                )
            )

    return myintip
end

-- Ext ip
function extip(args)
    local args = args or {}
    local interface = args.interface or nil
    local refresh_timeout = args.timeout or 600
    local prefix = args.prefix or "Ext. IP: "

    local myextip = wibox.widget.textbox()
    local myextipupdate = function()
        if interface == nil then
            local f = io.popen("curl ifconfig.me")
            local ret = f:read("*all")
            f:close()
        else
            local f = io.popen("curl --interface "..interface.." ifconfig.me")
            local ret = f:read("*all")
            f:close()
        end
        
        local text = prefix .. ret
        myextip:set_text(text)
    end
    myextipupdate()

    local myextiptimer = timer({ timeout = refresh_timeout })
    myextiptimer:connect_signal("timeout", myextipupdate)
    myextiptimer:start()

    myextip:buttons(awful.util.table.join(
                awful.button({}, 1, function() myextipupdate() end),
                awful.button({}, 3, function() awful.util.spawn(browser .. " http://ifconfig.me", false) end)
                )
            ) 

    return myextip
end

-- Netcfg
function netcfg(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 600
    local prefix = args.prefix or "Netcfg: "
    local command = "sudo netcfg "
    local mynetcfg = wibox.widget.textbox()
    local mynetcfgupdate = function ()
        local profiles = {}
        local active_profiles = {}

        local f = io.popen("find /etc/network.d/ -maxdepth 1 -type f | grep -v wpaconf | cut -b 16-")

        for line in f:lines() do
            if line ~= nil then
                table.insert(profiles, line)
            end
        end
        f:close()

        local f = io.popen("ls -1 /run/network/profiles")
        for line in f:lines() do
            if line ~= nil then
                table.insert(active_profiles, line)
            end
        end
        f:close()

        local menuitems = {}

        for key,file in ipairs(profiles) do
            item = {}
            table.insert(item, file)
            table.insert(item, command .. file)
            table.insert(menuitems, item)
        end

        netcfgmenu = awful.menu({items = menuitems})

        local text = prefix .. (active_profiles[1] or "N/A") 

        mynetcfg:set_text(text)
    end
    mynetcfgupdate()

    local mynetcfgtimer = timer({ timeout = refresh_timeout })
    mynetcfgtimer:connect_signal("timeout", mynetcfgupdate)
    mynetcfgtimer:start()

    mynetcfg:buttons(awful.util.table.join(
                awful.button({}, 1, function() mynetcfgupdate() end),
                awful.button({}, 3, function() netcfgmenu:toggle() end)
                )
            ) 

    return mynetcfg
end

-- Running processes
function runningprocesses(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 5
    local user = args.user or ""
    local prefix = args.prefix or "Running processes: "

    local myrp = wibox.widget.textbox()
    local myrpupdate = function()
        local f = io.popen("ps --no-header aux")
        local ret = f:read("*all")
        f:close()

        local processes = 0
        for w in string.gfind(ret, user) do
            processes = processes + 1
        end

        local text = prefix .. string.format("%d", processes)
        myrp:set_text(text)
    end
    myrpupdate()

    local myrptimer = timer({ timeout = refresh_timeout })
    myrptimer:connect_signal("timeout", myrpupdate)
    myrptimer:start()

    myrp:buttons(awful.util.table.join(
                awful.button({}, 1, function() awful.util.spawn(terminal .. " -e htop") end)
                )
            )

    return myrp
end

-- Governor
function governor(args)
    local args = args or {}
    local cpu = args.cpu or "cpu0"
    local refresh_timeout = args.timeout or 61
    local prefix = args.prefix or "cpu0: "
    local command = "sudo cpufreq-set -r -g "


    local mygovernor = wibox.widget.textbox()
    local mygovernorupdate = function()
        local f = io.open("/sys/devices/system/cpu/"..cpu.."/cpufreq/scaling_governor")
        local governor = f:read("*all")
        f:close()
        
        local f = io.open("/sys/devices/system/cpu/".. cpu .. "/cpufreq/scaling_available_governors")
        local content = f:read("*all")
        f:close()

        local governors = metalgamer.utils.split(content, " ")

        local menuitems = {}

        for key, file in ipairs(governors) do
            item = {}
            table.insert(item, file)
            table.insert(item, command .. file)
            table.insert(menuitems, item)
    
        governormenu = awful.menu({items = menuitems})    
        

        local text = prefix .. governor
        mygovernor:set_text(text)
    end
    mygovernorupdate()
    
    local mygovernortimer = timer({ timeout = refresh_timeout })
    mygovernortimer:connect_signal("timeout", mygovernorupdate)
    mygovernortimer:start()
    
    mygovernor:buttons(awful.util.table.join(
                awful.button({}, 1, function()
                    mygovernorupdate() end),
                awful.button({}, 3, function() governormenu:toggle() end)
                )
            )

    return mygovernor
end

--Mpdplay
function mpdplay(args)
    local args = args or {}

    local mympdplay = wibox.widget.textbox()
    mympdplay:set_text("▶")

    mympdplay:buttons(awful.util.table.join(
                awful.button({}, 1, function() awful.util.spawn("mpc toggle", false) end)
                )
    )

    return mympdplay
end

--Mpdpause
function mpdpause(args)
    local args = args or {}

    local mympdpause = wibox.widget.textbox()
    mympdpause:set_text("❚❚")
    
    mympdpause:buttons(awful.util.table.join(
                awful.button({}, 1, function() awful.util.spawn("mpc pause", false) end),
                awful.button({}, 3, function() awful.util.spawn("mpc stop", false) end)
                )
    )

    return mympdpause
end

--Mpdnext
function mpdnext(args)
    local args = args or {}

    local mympdnext = wibox.widget.textbox()
    mympdnext:set_text("⇥")

    mympdnext:buttons(awful.util.table.join(
                awful.button({}, 1, function() awful.util.spawn("mpc next", false) end)
                )
    )

    return mympdnext
end

--Mpdprev
function mpdprev(args)
    local args = args or {}
    
    local mympdprev = wibox.widget.textbox()
    mympdprev:set_text("⇤")

    mympdprev:buttons(awful.util.table.join(
                awful.button({}, 1, function() awful.util.spawn("mpc prev", false) end)
                )
    )

    return mympdprev
end

--Mpdvolup
function mpdvolup(args)
    local args = args or {}

    local mympdvolup = wibox.widget.textbox()
    mympdvolup:set_text("+")

    mympdvolup:buttons(awful.util.table.join(
                awful.button({}, 1, function() awful.util.spawn("mpc volume +1", false) end),
                awful.button({}, 3, function() awful.util.spawn("mpc volume 100", false) end),
                awful.button({}, 4, function() awful.util.spawn("mpc volume +1", false) end)
                )
    )

    return mympdvolup
end

--Mpdvoldown
function mpdvoldown(args)
    local args = args or {}

    local mympdvoldown = wibox.widget.textbox()
    mympdvoldown:set_text("-")

    mympdvoldown:buttons(awful.util.table.join(
                awful.button({}, 1, function() awful.util.spawn("mpc volume -1", false) end),
                awful.button({}, 3, function() awful.util.spawn("mpc volume 50", false) end),
                awful.button({}, 5, function() awful.util.spawn("mpc volume -1", false) end)
                )
    )

    return mympdvoldown
end

--Mpdvolume
function mpdvolume(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 1

    local mympdvolume = wibox.widget.textbox()
    local mympdvolumeupdate = function()
        local f = io.popen("mpc volume")
        local ret = f:read("*all")
        f:close()

        local i, j = string.find(ret, "%d+%%")
        if i == nil then
            volume = "N/A"
        else
            volume = string.sub(ret, i, j)
        end

        mympdvolume:set_text(volume)
    end
    mympdvolumeupdate()

    local mympdvolumetimer = timer({ timeout = refresh_timeout })
    mympdvolumetimer:connect_signal("timeout", mympdvolumeupdate)
    mympdvolumetimer:start()

    mympdvolume:buttons(awful.util.table.join(
                awful.button({}, 4, function() awful.util.spawn("mpc volume +1", false) end),
                awful.button({}, 5, function() awful.util.spawn("mpc volume -1", false) end)
                )
    )

    return mympdvolume
end

-- Battery
-- Taken from vain.widgets and updated to use it with awesome current git
-- version
function battery(args)
    local args = args or {}
    local bat = args.battery or "BAT0"
    local refersh_timeout = args.refresh_timeout or 10

    local mybattery = wibox.widget.textbox()
    
    local mybatteryupdate = function()
        
        local first_line = metalgamer.util.first_line
        local file_exists = metalgamer.util.exists
        
        local present = first_line("/sys/class/power_supply/" .. bat .. "/present")
        if present == "1"
        then
        
            local powercheck = file_exists("/sys/class/power_supply" .. bat .. "/current_now")

            if powercheck == "1" then
        
                rate = first_line("/sys/class/power_supply/" .. bat .. "/current_now")
            elseif powercheck == "0" then
                rate = first_line("/sys/class/power_supply/" .. bat .. "/power_now")
            else
                rate = 1
            end

            local ratev = first_line("/sys/class/power_supply/" .. bat .. "/voltage_now")
            
            local check = file_exists("/sys/class/power_supply/" .. bat .. "/charge_now")

            if check  == "1" then
                rem = first_line("/sys/class/power_supply/" .. bat .. "/charge_now")
            elseif check == "0" then
                rem = first_line("/sys/class/power_supply/" .. bat .. "/energy_now")
            else
                rem = 1
            end


            if check == "1" then
                tot = first_line("/sys/class/power_supply/" .. bat .. "/charge_full")
            elseif check == "0" then
                tot = first_line("/sys/class/power_supply/" .. bat .. "/energy_full")
            else
                tot = 1
            end

            local status = first_line("/sys/class/power_supply/" .. bat .. "/status")

            local time_rat = 0
            
            if status == "Charging"
            then
                status = "c"
                time_rat = (tot - rem) / rate
            elseif status == "Discharging"
            then
                status = "d"
                time_rat = rem / rate
            elseif status == "Full"
            then
                status = "f"
            else
                status = "u"
            end

            local hrs = math.floor(time_rat)
            local min = (time_rat - hrs) * 60
            local time = string.format("%02d:%02d", hrs,min)
            
            local perc = string.format("%d%%", (rem / tot) * 100)
            text = status .. " " .. perc .. " " .. time

        else
            text = "no battery"
        end

        mybattery:set_text(text)
    end
    
    mybatteryupdate()
    
    local mybatterytimer = timer({ timeout = refersh_timeout })
    mybatterytimer:connect_signal("timeout", mybatteryupdate)
    mybatterytimer:start()

    mybattery:buttons(awful.util.table.join(
                awful.button({}, 1, function()
                    mybatteryupdate() end)
                )
            )

    return mybattery
end

