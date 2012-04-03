==================
awesome-metalgamer
==================

This repository contains mostly widgets I wrote for the `Awesome Window Manager <http://awesome.naquadah.org/>`_.

All of this is `GPL3+ <http://www.gnu.org/licenses/gpl-3.0.txt>`_.

Note: I use the current git master version of awesome. So this won't work with awesome 3.4.

How to install
--------------

For system wide use, you have to put the directory `metalgamer` into `/usr/share/awesome/lib/`.

::
    
    $ pwd
    /usr/share/awesome/lib

    $ tree -l
    .
    ├── awful
    │   ├── ..
    │   ├── ..
    ├── gears
    │   ├── ..
    │   ├── ..
    ├── metalgamer
    │   ├── init.lua
    │   ├── util.lua
    │   └── widgets.lua
    ├── vicious
    │   ├── ..
    │   ├── ..
    └── wibox
        ├── ..

For personal use, you have to put the directory `metalgamer` into your config folder, normally `/home/YOUR-USERNAME/.config/awesome`.

::
    
    $ pwd
    /home/dennis/.config/awesome

    $ tree -l
    .
    ├── metalgamer
    │   ├── init.lua
    │   ├── util.lua
    │   └── widgets.lua
    └── rc.lua

You have to install the luafilesystem, because the `run_once` function I use
is completly written in Lua.

On Archlinux:

::

    # pacman -S luafilesystem

Using it
--------

You have to include this module into your `rc.lua`

::

    require("metalgamer")
    metalgamer.widgets.terminal = "urxvtc"
    metalgamer.widgets.browser = "firefox"

Some widgets require a terminal or a browser, so you need to set them as well.

Widgets
-------

Each function returns a widget that can be used in wiboxes.

**In a nutshell:**

You need to write the code snippets in your `rc.lua` and adding these to your
wiboxes. For more clarity look into my `rc.lua` `here <https://github.com/the-metalgamer/Evolution-Dotfile/blob/master/.config/awesome/rc.lua>`_.

Deluge:
=======

Shows the torrents which are currently in deluge. Using `deluge-console`.

::

    mydeluge = metalgamer.widgets.deluge()

The function takes a table as an optional argument. That table may contain:

::
    
    .timeout: When should the widget be updated. Defaults to 30 seconds.
    .ip: Which IP address should be used to connect to. Defaults to localhost.
    .port: Which port should be used. Defaults to 58846.
    .username: Which user should be used. Defaults to empty string.
    .password: Which password should be used. Defaults to empty string.
    .prefix: Should there be a prefix in the text displayed in the wibox. Defaults to Deluge:

Returns a textbox with the following information.

::

    PREFIX D: Current amount of downloading torrents -  S: Current amount of
    seeding torrents - Q: Current amount of queued torrents - P: Current
    amount of paused torrents - T: Total of current torrents

A click on the widget will call the following:

    - Left mouse button: `deluge-console pause \*`
    - Right mouse button: `deluge-console resume \*`
    

**Example:**

::
    
    mydeluge = metalgamer.widgets.deluge()

    Returns:

    Deluge: D: 2 - S: 1 - Q: 0 - P: 2 - T: 5


Internal IP:
============

Shows the IP address of a given network interface. Gathers information from  `ip addr show`

::

    myintip = metalgamer.widgets.intip()

The function takes a table as an optional argument. That table may contain:

::

    .timeout: When should the widget be updated. Defaults to 600 seconds
    .interface: Which interface should be used. Defaults to eth0
    .prefix: Which prefix should be displayed. Defaults to Int. IP: 

Returns a textbox with the following information.

::

    PREFIX IP of the given interface

A click with the left mouse button on the widget will update the widget.

**Example:**

::

    myintip = metalgamer.widgets.intip({ interface = "wlan0", prefix = "wlan0: "})
    
    Returns:

    wlan0: 192.168.1.74

External IP:
============

Shows the external ip. Gathers information from http://ifconfig.me using `curl`

::

    myextip = metalgamer.widgets.extip()

The function takes a table as an optional argument. That table may contain:

::

    .timeout: When should the widget be updated. Defaults to 600 seconds
    .interface: Which network interface should be used.Defaults to nil
    .prefix: Which prefix should be displayed. Defaults to Ext. IP: 

Returns a textbox with the following information.

::

    PREFIX external ip


A click on the widget will call the following:

    - Left mouse button: Update the widget
    - Right mouse button: Will open http://ifconfig.me in your `browser`
    
**Example:**

::

    myextip = metalgamer.widgets.extip({ prefix = "wlan0 ext. ip: ", interface = "wlan0"})

    Returns:

    wlan0 ext. ip: 94.252.111.236

**Attention:** This widget will make your startup slower due it needs to connect to an server.

Running processes:
==================

Shows the current running processes, using `ps`.

::

    myrp = metalgamer.widgets.runningprocesses()


The function takes a table as an optional argument. That table may contain:

::

    .timeout: When should the widget be updated. Defaults to 5 seconds
    .user: Filter by what user. Defaults to an empty string.
    .prefix: Which prefix should be displayed. Defaults to Running processes: .

Returns a textbox with the following information.

::

    PREFIX Current amount of running processes

A click with the left mouse button on the widget will call `htop` in your
`terminal`

**Example:**

::

    myrp = metalgamer.widgets.runningprocesses({ user = "dennis" })

    Returns:

    Running processes: 27


Governor:
=========

Shows the current scaling governor of a given cpu core. You need to have `cpufreq` installed. Reads it directly from `/sys/devices/cpu/cpu0/cpufreq/scaling_governor`

::

    mygovernor = metalgamer.widgets.governor()

The function takes a table as an optional argument. That table may contain:

::

    .cpu: Which cpu core should be used. Defaults to cpu0
    .timeout: When should the widget be updated. Defaults to 61 seconds.
    .prefix: Which prefix should be displayed. Defaults to cpu0:

Returns a textbox with the following information.

::

    PREFIX Scaling governor

A left mouse button click on the widget will update the widget.

**Example:**

::
    
    mygovernor = metalgamer.widgets.governor({ cpu = "cpu1", prefix = "cpu1: "})

    Returns:

    cpu1: performance
    

MPD Play button:
================

Shows ▶ which will call `mpc toggle` on left mouse button click.

::

    mympdplay = metalgamer.widgets.mpdplay()


MPD Pause button:
=================

Shows ❚❚ which will call on click the following:

    - Left mouse button click: `mpc pause`
    - Right mouse button click: `mpc stop`

::

    mympdpause = metalgamer.widgets.mpdpause()

MPD Next button:
================

Shows ⇥ which will call `mpc next` on left mouse button click.

::
    
    mympdnext = metalgamer.widgets.mpdnext()

MPD Prev button:
================

Shows ⇤ which will call `mpc prev` on left mouse button click.

::

    mympdprev = metalgamer.widgets.mpdprev()

MPD Volume up button:
=====================

Shows + which will call on click the following:

    - Left click: `mpc volume +1`
    - Right click: `mpc volume 100`
    - Mousewheel up: `mpc volume +1`

::

    mympdvolup = metalgamer.widgets.mpdvolup()


MPD Volume down button:
=======================

Shows - which will call on click the following:

    - Left click: `mpc volume -1`
    - Right click: `mpc volume 50`
    - Mousewheel down: `mpc volume -1`

::

    mympdvoldown = metalgamer.widgets.mpdvoldown()


MPD Volume:
===========

Shows the current mpd volume. Gathers information using `mpc volume`

::

    mympdvolume = metalgamer.widgets.mpdvolume()

The function takes a table as an optional argument. That table may contain:

::

    .timeout: When should the widget be updated. Defaults to 1 second.


A click on the widget will call the following:

    - Mousewheel up: `mpc volume +1`
    - Mousewheel down: `mpc volume -1`

Return a textbox with the following information:

::

    Current mpd volume%

**Example:**

::
    
    mympdvolume = metalgamer.widgets.mpdvolume({ timeout = 10})

    Returns:

    100%

Battery:
========

This widget is taken from `awesome-vain <https://github.com/vain/awesome-vain>`_, but I updated it so it can be used with the current git version of awesome.

Show the remaining time and capacity of your laptop battery. Uses the `/sys` filesytem

::

    mybattery = metalgamer.widgets.battery()

The function takes a table as an optional argument. That table may contain:

::

    .timeout: When should the widget be updated. Defaults to 10 seconds
    .bat: What battery should be used. Defaults to BAT0

Returns a textbox with the following information:

::

    Status current percentage remaining time

Status can be the following:

    - f = full
    - d = discharging
    - c = charging
    - u = unkown

A left mouse button click on the widget will update the widget.

**Example:**

::

    mybattery = metalgamer.widgets.battery()

    Returns:

    d 100% 04:50

Utility functions
-----------------

First line:
===========

This function is taken from `awesome-vain <https://github.com/vain/awesome-vain>`_.

Read the first line of a file or return nil.

Run or raise:
=============

This function is taken from official `awesome wiki/Run_or_raise <http://awesome.naquadah.org/wiki/Run_or_raise>`_.

Spawn cmd if no client can be found matching properties.
If such a client can be found, pop first tag it is visible, and give it focus.

Run once:
=========

This function is taken from official `awesome wiki/autostart <http://awesome.naquadah.org/wiki/Autostart>`_.

You need to have luafilesystem installed.

Run program once.
