#!/usr/bin/python
"""Provides simple completion of python builtin attrs/dirs."""
import vim
import types

IS_ERROR = "Error"

# https://docs.python.org/3/library/stdtypes.html
ADDED_ATTRS = ["__" + x + "__" for x in ["dict",
                                         "class",
                                         "bases",
                                         "name",
                                         "qualname",
                                         "mro",
                                         "subclasses"]]

DOT_ATTR = dir(object) + ADDED_ATTRS
ALL_BUILTINS = [x for x in dir(__builtins__) if not x.endswith("Warning") \
                                            and not x.endswith("Exception")]
AVAIL_BUILTINS = [x for x in ALL_BUILTINS if not x.endswith(IS_ERROR) and \
                                            (x[0] >= 'Z' or x[0] <= 'A')]
ERRORS = [x for x in ALL_BUILTINS if x.endswith(IS_ERROR)] 
IS_RAISE = "raise"


def get_selections(segment, inputs, reversing):
    """Get selections given input."""
    matched = None
    input_set = list(reversed(sorted(set(inputs))))
    result = ""
    lst = "" 
    nxt = ""
    for ins in input_set:
        if matched:
            nxt = ins
            break
        if segment.startswith(ins):
            matched = ins
        if not matched:
            lst = ins
    if not matched:
        matched = ""
    if reversing:
        result = lst
    else:
        result = nxt
    return (result, matched)


def main():
    """Main entry point."""
    try:
        pos = vim.current.window.cursor
        if pos and pos[0] > 0 and pos[1] > 0:
            row = pos[0] - 1
            col = pos[1]
            cur = vim.current.buffer[row]
            ch = cur[col]
            reversing = vim.eval("a:direction") == "1"
            col_off = col + 1
            after = cur[col_off:]
            selections = None
            use_values = None
            if ch == ".":
                use_values = DOT_ATTR
            if ch == " ":
                use_values = AVAIL_BUILTINS
                len_raise = len(IS_RAISE) + 1
                if len(cur) >= len_raise and col >= len_raise:
                    if cur[col - len(IS_RAISE):col] == IS_RAISE:
                        use_values = ERRORS
                use_values = [x + "(" for x in use_values]
            if use_values:
                selections = get_selections(after, use_values, reversing)
            if selections is not None:
                replacing = selections[0]
                after_attr = selections[1]
                new_cur = "{}{}{}".format(cur[0:col_off],
                                          replacing,
                                          cur[col_off + len(after_attr):])
                vim.current.buffer[row] = new_cur
    except Exception as e:
        print(str(e))


if __name__ == '__main__':
    main()
