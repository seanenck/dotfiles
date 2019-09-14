#!/usr/bin/python3
"""Volume control."""
import subprocess


def status():
    """Get current volume status."""
    totals = []
    for l in _pactl():
        if "Volume" not in l:
            continue
        if "Base" in l:
            continue
        percents = l.split("/")
        for p in percents:
            if "%" not in p:
                continue
            totals.append(p.replace("%", "").strip())
    avg = 0
    if len(totals) > 0:
        avg = int(sum([int(x) for x in totals]) / len(totals))
    return avg > 0


def _pactl():
    """Call pactl."""
    p = subprocess.Popen(["pactl",
                          "list",
                          "sinks"],
                         stdout=subprocess.PIPE)
    output, err = p.communicate()
    if err:
        raise err
    rc = p.returncode
    if rc != 0:
        raise Exception("unable to read pactl")
    return output.decode("utf-8").split("\n")


def _change_volume_settings(command, value):
    """Change a volume setting."""
    for i in range(0, 5):
        subprocess.call(["pactl",
                         command,
                         str(i),
                         str(value)])


def ismute():
    """Check if muted."""
    result = False
    for l in _pactl():
        if "Mute: yes" in l:
            result = True
            break
    return result


def volume(change):
    """Change the volume."""
    actual = 0
    if change > 0:
        actual = 1000
    _change_volume_settings("set-sink-volume", actual)


def mute(force=False):
    """Mute volume."""
    mute = 1
    if not force:
        if ismute():
            mute = 0
    _change_volume_settings("set-sink-mute", mute)
