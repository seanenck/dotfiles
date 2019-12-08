#!/usr/bin/python3
import common
import subprocess
import time

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
LOW_BACKLIGHT = _LOW
MID_BACKLIGHT = _MID


class Display(object):
    """Display object."""

    def __init__(self):
        self._main = None
        self._vleft = None
        self._hright = None
        self._external = None
        self._candock = False
        self._canext = False
        self._displays = []
        self._mode = ["--mode", "2560x1440"]

    @staticmethod
    def new():
        d = Display()
        displays = Display._get_displays()
        for disp in displays:
            name = disp[0]
            d._displays.append(name)
            conn = not disp[1]
            if "HDMI" in name:
                if conn:
                    d._external = name
                    d._canext = True
            elif name.startswith("eDP"):
                if conn:
                    d._main = name
            elif name.startswith("DP"):
                if conn:
                    if name.endswith("8"):
                        d._hright = name
                    elif name.endswith("1"):
                        d._vleft = name
        if d._hright and d._vleft:
            d._candock = True
        return d

    @staticmethod
    def _get_displays():
        """Get displays."""
        out, err = common.get_output_or_error(["xrandr"])
        if err:
            return []
        objects = [x.strip() for x in out.decode("utf-8").split("\n")]
        results = []
        for l in objects:
            if "connected" not in l:
                continue
            discon = "disconnected" in l
            results.append((l.split(" ")[0], discon))
        return results


    def brightness(self, value):
        for d in self._displays:
            subprocess.call(["xrandr", "--output", d, "--brightness", value])


    def change(self, command):
        """Change workspace."""
        if self._main is None:
            print("no main display")
            return
        is_docked = command == "docked"
        is_mobile = command == "mobile"
        is_ext = command == "external"
        if not is_docked and not is_mobile and not is_ext:
            print("no command")
            return
        for d in self._displays:
            if d == self._main:
                continue
            subprocess.call(["xrandr", "--output", d, "--off"])
        time.sleep(1)
        subprocess.call(["xrandr", "--output", self._main, "--primary"] + self._mode)
        if is_ext:
            if self._canext:
                subprocess.call(["xrandr", "--output", self._external, "--auto", "--right-of", self._main])
        if is_docked:
            if self._candock:
                subprocess.call(["xrandr",
                                 "--output",
                                 self._vleft,
                                 "--auto",
                                 "--left-of",
                                 self._main,
                                 "--rotate",
                                 "right"])
                subprocess.call(["xrandr",
                                 "--output",
                                 self._hright,
                                 "--auto",
                                 "--right-of",
                                 self._main])
        if is_ext or is_docked:
            time.sleep(1)
            self.brightness(str(_MID_BRIGHT))
        time.sleep(1)
        for n in ["dwm", "dunst"]:
            subprocess.call(["pkill", n])


def change_workspaces(command):
    """Change workspace."""
    Display.new().change(command)


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
    Display.new().brightness(str(bright))
