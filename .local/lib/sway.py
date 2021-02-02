from i3ipc import Connection, Event
import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("mode")
    parser.add_argument("-fullscreen-height", type=float, default=0.95)
    parser.add_argument("-fullscreen-width", type=float, default=0.99)
    parser.add_argument("-screen-offset-height", type=int, default=5)
    parser.add_argument("-screen-offset-width", type=int, default=5)
    parser.add_argument("-master-scale-width", type=float, default=0.65)
    parser.add_argument("-master-scale-height", type=float, default=0.95)
    parser.add_argument("-resize-rate", type=int, default=50)
    args = parser.parse_args()
    i3 = Connection()
    do_master = False
    if args.mode == "fullscreen":
        _fullscreen(i3, args.fullscreen_width, args.fullscreen_height, args.screen_offset_width, args.screen_offset_height)
    elif args.mode == "master" or do_master:
        _set_master(i3, args.master_scale_width, args.master_scale_height, args.screen_offset_width, args.screen_offset_height, True)
    elif args.mode == "move-focus":
        _move_focus(i3)
    elif args.mode == "reset":
        _reset(i3)
    elif args.mode == "workspace-focus":
        _workspace_focus(i3)
    elif args.mode == "resize-right":
        _resize(i3, True, args.screen_offset_width, args.screen_offset_height, args.resize_rate)
    elif args.mode == "resize-left":
        _resize(i3, False, args.screen_offset_width, args.screen_offset_height, args.resize_rate)
    elif args.mode in ["move-left", "move-right", "move-up", "move-down"]:
        _move(i3, args.mode.replace("move-", ""))


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


def _move(i3, mode):
    focused = i3.get_tree().find_focused()
    is_floating = focused.type == "floating_con"
    if is_floating:
        _command(focused, "move {}".format(mode))
        return
    windows = [x for x in focused.workspace() if x != focused and x.name]
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

def _workspace_focus(i3):
    focused = i3.get_tree().find_focused()
    windows = [x for x in focused.workspace() if x != focused]
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

def _resize(i3, right, offset_width, offset_height, resize_rate):
    focused = i3.get_tree().find_focused()
    is_floating = focused.type == "floating_con"
    if not is_floating:
        cmd = "shrink"
        if right:
            cmd = "grow"
        _command(focused, "resize {} width 10".format(cmd))
        return
    delta = resize_rate
    if not right:
        delta = -1 * delta
    w = focused.rect.width + delta
    active = [x for x in i3.get_outputs() if x.focused][0]
    w_offset = active.rect.x + offset_width
    h_offset = active.rect.y + offset_height
    _command(focused, "resize set width {}".format(w))
    _command(focused, "move absolute position {} {}".format(w_offset, h_offset))


def _reset(i3):
    focused = i3.get_tree().find_focused()
    windows = [x for x in focused.workspace() if x != focused]
    for w in [focused] + windows:
        _command(w, "floating disable")


def _move_focus(i3):
    focused = i3.get_tree().find_focused()
    _command(focused, "move window to output right")
    _command(i3, "focus output right")


def _fullscreen(i3, to_width, to_height, offset_width, offset_height):
    focused = i3.get_tree().find_focused()
    is_floating = focused.type == "floating_con"
    if is_floating:
        _command(focused, "floating disable")
        return
    active = [x for x in i3.get_outputs() if x.focused][0]
    w = int(active.rect.width * to_width)
    h = int(active.rect.height * to_height)
    _command(focused, "floating enable")
    _command(focused, "resize set width {} height {}".format(w, h))
    _command(focused, "move absolute position {} {}".format(active.rect.x + offset_width, active.rect.y + offset_height))


def _command(obj, command):
    error = False
    for i in obj.command(command):
        if not i.success:
            error = True
    return error


def _set_master(i3, to_width, to_height, offset_width, offset_height, root_call):
    focused = i3.get_tree().find_focused()
    windows = [x for x in focused.workspace() if x != focused]
    if len(windows) == 0:
        return
    active = [x for x in i3.get_outputs() if x.focused][0]
    if active.rect.width < active.rect.height:
        return
    if root_call:
        if focused.type == "floating_con":
            w = focused.rect.width / active.rect.width
            _set_master(i3, w, to_height, offset_width, offset_height, False)
            return
    w = int(active.rect.width * to_width)
    h = int(active.rect.height * to_height)
    w_offset = active.rect.x + offset_width
    h_offset = active.rect.y + offset_height
    _command(focused, "floating enable")
    _command(focused, "resize set width {} height {}".format(w, h))
    _command(focused, "move absolute position {} {}".format(w_offset, h_offset))
    # display window minus the master + gaps
    sub_w = active.rect.width - w - (offset_width * 3)
    sub_h = int(h / len(windows))
    idx = 0
    for window in windows:
        _command(window, "floating enable")
        _command(window, "resize set width {} height {}".format(sub_w, sub_h - offset_height))
        use_height = offset_height
        if idx == 0:
            use_height = 0
        _command(window, "move absolute position {} {}".format(w_offset + offset_width + w, use_height + h_offset + sub_h * idx))
        idx += 1
    

if __name__ == "__main__":
    main()
