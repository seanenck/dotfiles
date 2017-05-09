#!/usr/bin/python
import vim
import sys

try:
    print(sys.argv)
    # https://docs.python.org/3/library/stdtypes.html
    dot_attr = set(dir(object) + ["__" + x + "__" for x in ["dict", "class", "bases", "name", "qualname", "mro", "subclasses"]])
    pos = vim.current.window.cursor
    if pos and pos[0] > 0 and pos[1] > 0:
        row = pos[0] - 1
        col = pos[1]
        cur = vim.current.buffer[row]
        ch = cur[col]
        # test.__setattr__(test test)
        if ch == ".":
            remaining = []
            after_attr = ""
            col_off = col + 1
            after = cur[col_off:]
            replacing = ""
            #is_after = False
            #reversing = True
            #for attr in dot_attr:
            #    if is_after:
            #        remaining.append(attr)
            #    if after.startswith(attr):
            #        after_attr = attr
            #        is_after = True
            #    if not is_after and reversing:
            #        remaining.append(attr)
            #if not is_after:
            #    remaining = [x for x in dot_attr]
            #replacing = None
            #if len(remaining) == 0:
            #    replacing = ""
            #else:
            #    replacing = remaining[0]
            new_cur = cur[0:col_off] + replacing + cur[col_off + len(after_attr):]
            print(new_cur)
            #vim.current.buffer[row] = new_cur
except Exception as e:
    print(str(e))
