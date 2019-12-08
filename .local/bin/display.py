#!/usr/bin/python3
"""Subsystem operations (displays)."""
import argparse
import common
import subprocess
import time

_MAIN = "eDP-1"
_VLEFT = "DP-2-1"
_HRIGHT = "DP-2-8"
_EXTERNAL = "HDMI-1"

_UNKNOWN_BRIGHTNESS = -1
_FULL_BRIGHT = 1.0
_MID_BRIGHT = 0.9
_LOW_BRIGHT = 0.3
_LOW_RANGE = 35
_MID_RANGE = 95
_DOWN = "down"
_UP = "up"
_LOW = "low"
_MID = "mid"
_ALL_DISPLAYS = [_MAIN, _VLEFT, _HRIGHT]
_MODE = ["--mode", "2560x1440"]
LOW_BACKLIGHT = _LOW
MID_BACKLIGHT = _MID


def _get_displays(filtered=" "):
    """Get displays."""
    out, err = common.get_output_or_error(["xrandr"])
    if err:
        return []
    connected = "{}connected".format(filtered)
    objects = [x.strip() for x in out.decode("utf-8").split("\n")]
    results = []
    for l in objects:
        if connected not in l:
            continue
        results.append(l.split(" ")[0])
    return set(results + [_VLEFT, _HRIGHT])


def backlight(sub):
    """Handle backlight."""
    bright = get_brightness()
    if sub == _LOW:
        backlight(_DOWN)
        backlight(_DOWN)
        return
    elif sub == "high":
        backlight(_UP)
        backlight(_UP)
        return
    elif sub == _MID:
        backlight(_LOW)
        backlight(_UP)
        return
    is_up = sub == _UP
    is_down = sub == _DOWN
    if bright == _UNKNOWN_BRIGHTNESS:
        if is_up:
            bright = _LOW_BRIGHT
        if is_down:
            bright = _FULL_BRIGHT
    else:
        if bright < _LOW_RANGE:
            if is_up:
                bright = _MID_BRIGHT
            if is_down:
                return
        elif bright < _MID_RANGE:
            if is_up:
                bright = _FULL_BRIGHT
            if is_down:
                bright = _LOW_BRIGHT
        elif bright > _MID_RANGE:
            if is_up:
                return
            if is_down:
                bright = _MID_BRIGHT
        else:
            return
    _set_brightness(str(bright), _get_displays())


def _set_brightness(value, displays):
    for d in displays:
        subprocess.call(["xrandr", "--output", d, "--brightness", value])


def change_workspaces(command):
    """Change workspace."""
    displays = _get_displays()
    if _MAIN not in displays:
        print("missing main display")
        return
    is_docked = command == "docked"
    is_mobile = command == "mobile"
    is_external = command == "external"
    if not is_docked and not is_mobile and not is_external:
        return
    not_main = [x for x in displays if x != _MAIN]
    for d in not_main:
        subprocess.call(["xrandr", "--output", d, "--off"])
    time.sleep(1)
    subprocess.call(["xrandr", "--output", _MAIN, "--primary"] + _MODE)
    if is_external:
        subprocess.call(["xrandr", "--output", _EXTERNAL, "--auto", "--right-of", _MAIN])
        return
    if is_docked:
        subprocess.call(["xrandr",
                         "--output",
                         _VLEFT,
                         "--auto",
                         "--left-of",
                         _MAIN,
                         "--rotate",
                         "right"])
        subprocess.call(["xrandr",
                         "--output",
                         _HRIGHT,
                         "--auto",
                         "--right-of",
                         _MAIN])
        time.sleep(1)
        _set_brightness(str(_MID_BRIGHT), _ALL_DISPLAYS)
    time.sleep(1)
    for n in ["dwm", "dunst"]:
        subprocess.call(["pkill", n])


def on():
    """Force displays on."""
    subprocess.call(["xset", "-display", ":0", "dpms", "force", "on"])


def get_brightness():
    """Get brightness."""
    out, err = common.get_output_or_error(["xrandr",
                                           "--current",
                                           "--verbose"])
    if err is None:
        lines = [float(x.strip().split(":")[1].strip())
                 for x in out.decode("utf-8").split("\n")
                 if "Brightness" in x]
        len_l = len(lines)
        if len_l > 0:
            return int(sum(lines) / len_l * 100)
    return _UNKNOWN_BRIGHTNESS
