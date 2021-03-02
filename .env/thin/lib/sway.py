"""Sway management via ipc."""
from i3ipc import Connection, Event
import argparse
import subprocess
import os


def main():
    """Program entry."""
    parser = argparse.ArgumentParser()
    parser.add_argument("mode")
    parser.add_argument("-fullscreen-height", type=float, default=0.965)
    parser.add_argument("-fullscreen-width", type=float, default=0.99)
    parser.add_argument("-screen-offset-height", type=int, default=5)
    parser.add_argument("-screen-offset-width", type=int, default=5)
    parser.add_argument("-master-scale-width", type=float, default=0.65)
    parser.add_argument("-master-scale-height", type=float, default=0.965)
    parser.add_argument("-master-scale-minimum", type=float, default=0.5)
    parser.add_argument("-resize-rate", type=int, default=50)
    parser.add_argument("-grid-bar", type=int, default=30)
    parser.add_argument("-laptop-display", default="eDP-1")
    parser.add_argument("-laptop-resolution", default="3840x2160")
    parser.add_argument("-desktop-secondary", default="DP-2")
    parser.add_argument("-desktop-transform", default="90")
    args = parser.parse_args()
    i3 = Connection()
    do_master = False
    if args.mode == "focus-model":
        i3.on(Event.WINDOW_FOCUS, _focus_model_handler)
        i3.main()
    elif args.mode == "sleep":
        if _is_laptop():
            subprocess.call(["systemctl", "suspend"])
    elif args.mode == "displays":
        if _is_laptop():
            subprocess.call(["swaymsg",
                             "output",
                             args.laptop_display,
                             "pos",
                             "0",
                             "0",
                             "res",
                             args.laptop_resolution])
        else:
            subprocess.call(["swaymsg",
                             "output",
                             args.desktop_secondary,
                             "transform",
                             args.desktop_transform])
    elif args.mode == "fullscreen":
        _fullscreen(i3,
                    args.fullscreen_width,
                    args.fullscreen_height,
                    args.screen_offset_width,
                    args.screen_offset_height)
    elif args.mode == "master" or do_master:
        _set_master(i3,
                    args.master_scale_width,
                    args.master_scale_height,
                    args.master_scale_minimum,
                    args.screen_offset_width,
                    args.screen_offset_height)
    elif args.mode == "move-focus":
        _move_focus(i3)
    elif args.mode in ["reset", "reset-all"]:
        _reset(i3, "all" in args.mode)
    elif args.mode == "workspace-focus":
        _workspace_focus(i3)
    elif args.mode in ["resize-right", "resize-left"]:
        _resize(i3,
                "right" in args.mode,
                args.screen_offset_width,
                args.screen_offset_height,
                args.resize_rate)
    elif args.mode in ["move-left", "move-right", "move-up", "move-down"]:
        _move(i3, args.mode.replace("move-", ""))
    elif args.mode == "kill":
        _quit_reset(i3)
    elif args.mode == "grid":
        _grid(i3,
              args.screen_offset_width,
              args.screen_offset_height,
              args.grid_bar)


def _is_laptop():
    return os.path.exists("/sys/class/power_supply/BAT0")


def _focus_model_handler(i3, e):
    try:
        focused = i3.get_tree().find_focused()
        if _is_floating(focused):
            return
        windows = _get_unfocused(focused)
        for w in windows:
            if _is_floating(w):
                return
        mode = "splitv"
        if focused.rect.width > focused.rect.height:
            mode = "splith"
        i3.command(mode)
    except Exception as e:
        pass


def _positional_compare(mode):
    if mode == "up":
        def _top(o):
            return o.rect.y
        return _top
    elif mode == "down":
        def _bottom(o):
            return o.rect.y + o.rect.height
        return _bottom
    elif mode == "left":
        def _left(o):
            return o.rect.x
        return _left
    elif mode == "right":
        def _right(o):
            return o.rect.x + o.rect.width
        return _right


def _is_floating(target):
    return target.type == "floating_con"


def _get_unfocused(focused):
    return [x for x in focused.workspace() if x != focused and x.name]


def _fit_grid(windows,
              offset_width,
              offset_height,
              max_width,
              max_height,
              target_width,
              target_height,
              dry_run):
    pos_x = offset_width
    pos_y = offset_height
    for w in windows:
        if pos_x + target_width > max_width:
            pos_y += target_height + offset_height
            pos_x = offset_width
            if dry_run:
                if pos_y + target_height > max_height:
                    return False
        if not dry_run:
            _set_floating(w, True)
            _command(w, "resize set width {} height {}".format(target_width,
                                                               target_height))
            _command(w, "move absolute position {} {}".format(pos_x, pos_y))
        pos_x += target_width + offset_width
    return True


def _grid(i3, offset_width, offset_height, bar):
    active = _get_active_output(i3)
    if active.rect.height > active.rect.width:
        return
    focused = i3.get_tree().find_focused()
    windows = [focused] + _get_unfocused(focused)
    active_width = active.rect.width - offset_width - offset_width
    active_height = active.rect.height - offset_height - offset_height - bar
    ratio = active_height / active_width
    use_w = None
    use_h = None

    def _make_grid(use_width, use_height, dry_run):
        return _fit_grid(windows,
                         offset_width,
                         offset_height,
                         active_width,
                         active_height,
                         use_width,
                         use_height,
                         dry_run)
    for x in reversed(range(0, active_width, 5)):
        ratio_y = int(x * ratio)
        if _make_grid(x, ratio_y, True):
            use_w = x
            use_h = ratio_y
            break
    if use_w is None or use_h is None:
        return
    _make_grid(use_w, use_h, False)


def _move(i3, mode):
    focused = i3.get_tree().find_focused()
    if _is_floating(focused):
        _command(focused, "move {}".format(mode))
        return
    windows = _get_unfocused(focused)
    if len(windows) == 0:
        return
    fxn = _positional_compare(mode)
    focus_pos = fxn(focused)
    can = False
    for w in windows:
        if can:
            break
        w_pos = fxn(w)
        if mode in ["up", "left"]:
            if w_pos <= focus_pos:
                can = True
        elif mode in ["down", "right"]:
            if w_pos >= focus_pos:
                can = True
    if can:
        _command(focused, "move {}".format(mode))


def _quit_reset(i3):
    focused = i3.get_tree().find_focused()
    if len([x for x in focused.workspace()]) != 0:
        _command(focused, "kill")
    else:
        _reset(i3, True)


def _workspace_focus(i3):
    focused = i3.get_tree().find_focused()
    windows = _get_unfocused(focused)
    if len(windows) == 0:
        return
    sort = {}
    lowest = None
    for w in windows:
        if lowest is None:
            lowest = w
        else:
            if lowest.id > w.id:
                lowest = w
        if w.id > focused.id:
            sort[w.id] = w
    obj = sorted(sort.keys())
    if len(obj) > 0:
        lowest = sort[obj[0]]
    _command(lowest, "focus")


def _get_active_output(i3):
    return [x for x in i3.get_outputs() if x.focused][0]


def _resize(i3, right, offset_width, offset_height, resize_rate):
    focused = i3.get_tree().find_focused()
    if not _is_floating(focused):
        cmd = "shrink"
        if right:
            cmd = "grow"
        _command(focused, "resize {} width 10".format(cmd))
        return
    delta = resize_rate
    if not right:
        delta = -1 * delta
    w = focused.rect.width + delta
    active = _get_active_output(i3)
    w_offset = active.rect.x + offset_width
    h_offset = active.rect.y + offset_height
    _command(focused, "resize set width {}".format(w))
    _command(focused, "move absolute position {} {}".format(w_offset,
                                                            h_offset))


def _reset(i3, force):
    focused = i3.get_tree().find_focused()
    if not focused:
        return
    windows = [x for x in focused.workspace() if x != focused]
    split_mode = "splith"
    for w in [focused] + windows:
        if split_mode == "splitv":
            split_mode = "splith"
        else:
            split_mode = "splitv"
        i3.command(split_mode)
        _set_floating(w, False)
        if force and not w.name:
            _command(w, "kill")


def _move_focus(i3):
    focused = i3.get_tree().find_focused()
    _command(focused, "move window to output right")
    _command(i3, "focus output right")


def _fullscreen(i3, to_width, to_height, offset_width, offset_height):
    focused = i3.get_tree().find_focused()
    if _is_floating(focused):
        _set_floating(focused, False)
        return
    active = _get_active_output(i3)
    w = int(active.rect.width * to_width)
    h = int(active.rect.height * to_height)
    mv_width = active.rect.x + offset_width
    mv_height = active.rect.y + offset_height
    _set_floating(focused, True)
    _command(focused, "resize set width {} height {}".format(w, h))
    _command(focused, "move absolute position {} {}".format(mv_width,
                                                            mv_height))


def _command(obj, command):
    error = False
    for i in obj.command(command):
        if not i.success:
            error = True
    return error


def _set_floating(w, floating):
    if floating:
        _command(w, "floating enable")
        _command(w, "border pixel 10")
    else:
        _command(w, "floating disable")
        _command(w, "border normal 2")


def _set_master(i3, to_width, to_height, minimum, offset_width, offset_height):
    focused = i3.get_tree().find_focused()
    windows = _get_unfocused(focused)
    if len(windows) == 0:
        return
    active = _get_active_output(i3)
    if active.rect.width < active.rect.height:
        return
    if minimum is not None:
        if _is_floating(focused):
            w = focused.rect.width / active.rect.width
            if w < minimum:
                w = minimum
            _set_master(i3, w, to_height, None, offset_width, offset_height)
            return
    w = int(active.rect.width * to_width)
    h = int(active.rect.height * to_height)
    w_offset = active.rect.x + offset_width
    h_offset = active.rect.y + offset_height
    _set_floating(focused, True)
    _command(focused, "resize set width {} height {}".format(w, h))
    _command(focused, "move absolute position {} {}".format(w_offset,
                                                            h_offset))
    # display window minus the master + gaps
    sub_w = active.rect.width - w - (offset_width * 3)
    sub_h = int(h / len(windows))
    sub_h_offset = sub_h - offset_height
    idx = 0
    for window in windows:
        _set_floating(window, True)
        _command(window,
                 "resize set width {} height {}".format(sub_w, sub_h_offset))
        use_height = offset_height
        if idx == 0:
            use_height = 0
        use_height = use_height + h_offset + (sub_h * idx)
        use_width = w_offset + offset_width + w
        _command(window,
                 "move absolute position {} {}".format(use_width, use_height))
        idx += 1


if __name__ == "__main__":
    main()
