#!/usr/bin/python

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GObject
import subprocess
import os
import sys

_IS_UNLOCK = 0
_IS_SUSPEND = 1
_BRIGHTNESS = 'xrandr --current --verbose | grep "Brightness" | cut -d ":" -f 2 | sed "s/0\.//g" | sed "s/1\.0/100/g" | tail -n 1 | awk \'{printf "%3.0f", $1}\' | sed "s/^[ \t]*//g"'
_LOCKED = """
#!/bin/bash
source /home/enck/.bin/common
if [ -e $DISPLAY_UN ]; then
    echo """ + str(_IS_UNLOCK) + """
else
    if [ -e $DISPLAY_EN ]; then
        echo """ + str(_IS_SUSPEND) + """
    else
        echo 2
    fi
fi
"""

def _call(command):
    """Make a call, get change (else None)."""
    try:
        ret = subprocess.check_output(command, shell=True, executable='/bin/bash').decode("ascii").strip()
        return int(ret)
    except Exception as e:
        pass
    return None

def _locked(val):
    """Get locking image."""
    img = "display"
    if val == _IS_UNLOCK:
        img = "unlocked"
    elif val == _IS_SUSPEND:
        img = "running"
    return img
            

def locked(last, icon):
    """Locking status."""
    val = _call(_LOCKED)
    val = _handle_val(val, last, _locked, icon)
    if val:
        last = val
    return last

def _handle_val(val, last, callback, icon):
    """Handle value switching."""
    if val is not None:
        if last != val:
            img = callback(val)
            icon.set_image(img)

def _brightness(val):
    use = "low"
    if val > 50:
        use = "mid"
    if val > 90:
        use = "high"
    return use + "-bright" 

def brightness(last, icon):
    """Get brightness."""
    val = _call(_BRIGHTNESS)
    val = _handle_val(val, last, _brightness, icon)
    if val:
        last = val
    return last
    

class Generic:

    def __init__(self, callback, image_path):
        """Init the instance."""
        self.statusicon = Gtk.StatusIcon()
        self._images = image_path
        self._callback = callback
        self._last = None
        self.set_image("unknown")
        self.on_timeout()

    def set_image(self, image):
        """Set icon image."""
        self.statusicon.set_from_file(os.path.join(self._images, image + ".png"))

    def on_timeout(self):
        """On timeout do a callback."""
        self._last = self._callback(self._last, self)
        # has to have timeout added
        GObject.timeout_add(3000, self.on_timeout)


def main():
    """Entry point."""
    path = sys.argv[1]
    Generic(brightness, path)
    Generic(locked, path)
    Gtk.main()

if __name__ == "__main__":
    main()
