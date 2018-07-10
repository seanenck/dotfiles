#!/usr/bin/python
"""Provide quick-shift left/right by 4 spaces."""
import vim


def is_space_chr(strvalue, idx):
    """Check if it is a space."""
    return len(strvalue) > idx and strvalue[idx] == ' '


def is_tab_chr(strvalue, idx):
    """Check if it is a tab."""
    return len(strvalue) > idx and strvalue[idx] == '\t'


def get_layouts(strvalue):
    """Get spacing layouts."""
    is_space_one = is_space_chr(strvalue, 0)
    is_space_two = is_space_chr(strvalue, 1)
    is_space_three = is_space_chr(strvalue, 2)
    is_space_four = is_space_chr(strvalue, 3)
    is_tab = is_tab_chr(strvalue, 0)
    is_four = is_space_one and is_space_two \
        and is_space_three and is_space_four
    is_two = is_space_one and is_space_two
    return (is_two, is_four, is_tab)


def main():
    """Entry point."""
    try:
        from os.path import splitext, basename
        use_tab = False
        base_name = basename(vim.current.window.buffer.name)
        file_name, extension = splitext(base_name)
        if extension in ['.go'] or file_name in ['Makefile']:
            use_tab = True
        pos = vim.current.window.cursor
        direction = vim.eval("a:direction") == "1"
        if pos and pos[0] >= 0 and pos[1] >= 0:
            row = pos[0] - 1
            cur = vim.current.buffer[row]
            if len(cur) >= 0:
                new_cur = None
                change = 0
                layout = get_layouts(cur)
                is_two = layout[0]
                is_four = layout[1]
                is_tab = layout[2]
                if direction:
                    adding = "    "
                    if is_tab or use_tab:
                        adding = "\t"
                    elif is_two and not is_four:
                        adding = "  "
                    new_cur = adding + cur
                    change = len(adding)
                else:
                    if is_tab or is_four or is_two:
                        if is_tab:
                            new_cur = cur[1:]
                        elif is_four:
                            new_cur = cur[4:]
                        elif is_two:
                            new_cur = cur[2:]
                        change = len(new_cur) - len(cur)
                if new_cur is not None:
                    vim.current.window.cursor = (row + 1, pos[1] + change)
                    vim.current.buffer[row] = new_cur
    except Exception as e:
        print(str(e))


if __name__ == '__main__':
    main()
