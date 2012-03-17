local awful = awful
local wibox = wibox
local timer = timer
local string = string
local beautiful = beautiful
local image = image
local io = io
local math = math
local os = os
local pairs = pairs
local tonumber = tonumber
local metalgamer = metalgamer

module("metalgamer.widgets")

-- Deluge widget
function deluge(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 30
    local ip = args.ip or "localhost"
    local port = args.port or "58846"
    local username = args.username or ""
    local password = args.password or ""

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

        mydeluge:set_text(string.format("D: %d - S: %d - Q: %d - P: %d - T: %d", downloading, seeding, queued, paused, total))

    end
    mydelugeupdate()

    local mydelugetimer = timer({ timeout = refresh_timeout })
    mydelugetimer:connect_signal("timeout", mydelugeupdate)
    mydelugetimer:start()

    return mydeluge
end

-- Int IP
function intip(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 600
    local interface = args.interface or "eth0"

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
        
        myintip:set_text(ip)
    end
    myintipupdate()

    local myintiptimer = timer({ timeout = refresh_timeout })
    myintiptimer:connect_signal("timeout", myintipupdate)
    myintiptimer:start()

    return myintip
end

-- Ext ip
function extip(args)
    local args = args or {}
    local interface = args.interface or nil
    local refresh_timeout = args.timeout or 600

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
		
        myextip:set_text(ret)
    end
    myextipupdate()

    local myextiptimer = timer({ timeout = refresh_timeout })
    myextiptimer:connect_signal("timeout", myextipupdate)
    myextiptimer:start()

    return myextip
end

-- Running processes
function runningprocesses(args)
    local args = args or {}
    local refresh_timeout = args.timeout or 5
    local user = args.user or ""

    local myrp = wibox.widget.textbox()
    local myrpupdate = function()
        local f = io.popen("ps --no-header aux")
        local ret = f:read("*all")
        f:close()

        local processes = 0
        for w in string.gfind(ret, user) do
            processes = processes + 1
        end

        myrp:set_text(string.format("%d", processes))
    end
    myrpupdate()

    local myrptimer = timer({ timeout = refresh_timeout })
    myrptimer:connect_signal("timeout", myrpupdate)
    myrptimer:start()

    return myrp
end

--Cpufreq
function cpufreq(args)
	local args = args or {}
	local cpu = args.cpu or "cpu0"
	local refresh_timeout = args.timeout or 61
	
	local mycpufreq = wibox.widget.textbox()
	local mycpufrequpdate = function()
		local f = io.open("/sys/devices/system/cpu/"..cpu.."/cpufreq/scaling_governor")
		local governor = f:read("*all")
		f:close()
	
		mycpufreq:set_text(governor)
	end
	mycpufrequpdate()
	
	local mycpufreqtimer = timer({ timeout = refresh_timeout })
	mycpufreqtimer:connect_signal("timeout", mycpufrequpdate)
	mycpufreqtimer:start()
	
	return mycpufreq
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
function battery(args)
    local args = args or {}
    local bat = args.battery or "BAT0"
    local refersh_timeout = args.refresh_timeout or 10

    local mybattery = wibox.widget.textbox()
    
    local mybatteryupdate = function()
        
        local first_line = metalgamer.util.first_line
    
        local present = first_line("/sys/class/power_supply/" .. bat .. "/present")
        if present == "1"
        then
        
            local rate = first_line("/sys/class/power_supply/" .. bat .. "/current_now")

            local ratev = first_line("/sys/class/power_supply/" .. bat .. "/voltage_now")

            local rem = first_line("/sys/class/power_supply/" .. bat .. "/charge_now")

            local tot = first_line("/sys/class/power_supply/" .. bat .. "/charge_full")

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

    return mybattery
end
