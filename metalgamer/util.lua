-- Grab environment
local awful = awful
local naughty = naughty
local mouse = mouse
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local client = client
local io = io
local screen = screen
local math = math
local lfs = lfs
local type = type
local assert = assert
local coroutine = coroutine
local tonumber = tonumber
local os = os
local timer = timer

module("metalgamer.util")

-- Read the first line of a file or return nil
-- Taken from vain.util

function first_line(f)
    local fp = io.open(f)

    if not fp
    then
        return nil
    end
    
    local content = fp:read("*l")
    fp:close()
    return content
end

-- Spawn cmd if no client can be fount matching properties
-- If such a client can be found, pop first tag it is visible, and give it
-- focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients. Possible
-- entries: any properties of the client object

function run_or_raise(cmd, properties)
    local clients = client.get()
    local focused = awful.client.next(0)
    local findex = 0
    local matched_clients = {}
    local n = 0
    for i, c in pairs(clients) do
        -- make an array of matched clients
        if match(properties, c)
        then
            n = n + 1
            matched_clients[n] = c
            if c == focused
            then
                findex = n
            end
        end
    end
    if n > 0
    then
        local c = matched_clients[1]
        -- if the focused window matched switch focus to next in list
        if 0 < findex and findex < n
        then
            c = matched_clients[findex + 1]
        end
        local ctags = c:tags()
        if table.getn(ctags) == 0
        then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
        else
            -- Otherwise, pop to first tag client is visible on
            awful.tag.viewonly(ctags[1])
        end
        -- And then focus the client
        client.focus = c
        c:raise()
        return
    end
    awful.util.spawn(cmd)
end

-- Return true if all paris in table1 are present in table2
function match (table1, table2)
    for k, v in pairs(table1) do
        if table2[k] ~= v and not table2[k]:find(v)
        then
            return false
        end
    end
    return true
end

-- {{{ Run program once

local function processwalker()
    local function yieldprocess()
        for dir in lfs.dir("/proc") do
            -- All directories in /proc containing a number, represent a process
            if tonumber(dir) ~= nil
            then
                local f, err = io.open("/proc/"..dir.."/cmdline")
                if f 
                then
                    local cmdline = f:read("*all")
                    f:close()
                    if cmdline ~= ""
                    then
                        coroutine.yield(cmdline)
                    end
                end
            end
        end
    end
    return coroutine.wrap(yieldprocess)
end

function run_once(process, cmd)
    assert(type(process) == "string")
    local regex_killer = {
        ["+"] = "%+", ["-"] = "%-",
        ["*"] = "%*", ["?"] = "%?" }
    
    for p in processwalker() do
        if p:find(process:gsub("[-+*?]", regex_killer))
        then
            return
        end
    end
    return awful.util.spawn(cmd or process)
end
--- }}}

-- Random Wallpaper

function randomwallpaper(args)
    local args = args or {}
    local wallpaperdir = args.wallpaperdir
    local mintimeout = args.mintimeout or 300
    local maxtimeout = args.maxtimeout or 600
    
    -- seed and "pop a few"
    math.randomseed( os.time() )
    for i=1,1000 do
        tmp=math.random(0,1000)
    end

    x = 0

    -- setup the timer
    
    randomwallpapertimer = timer({ timeout = x })
    randomwallpapertimer:connect_signal("timeout",
            function()
            
                -- tell awsetbg to randomly choose a wallpaper from your
                -- wallpaper directory
                
                awful.util.spawn("awsetbg -F -r " .. wallpaperdir, false)
                
                --stop the time (we don't need multiple instances running at
                    --the same time)
                randomwallpapertimer:stop()
                
                -- define the intervall in which the next wallpaper change
                -- should occur in seconds
                -- in this casew anytime between 5 and 10 minutes
                x = math.random(mintimeout,maxtimeout)
                
                randomwallpapertimer.timeout = x
                
                randomwallpapertimer:start()
                end
    )
    randomwallpapertimer:start()
end

