#!/usr/bin/python
"""Perform a git-diff output."""
import vim
import os
import subprocess


DIFF_ALL_SHOW = "0"
DIFF_ONE_SHOW = "1"
DIFF_ALL_TEXT = "2"


def main():
    """Main entry point."""
    try:
        do_buf = vim.eval("a:buffer")
        do_all = do_buf in [DIFF_ALL_SHOW, DIFF_ALL_TEXT]
        display = do_buf in [DIFF_ALL_SHOW, DIFF_ONE_SHOW]
        file_name = vim.current.buffer.name
        dir_path = os.path.dirname(file_name)
        command = ["git",
                   "diff",
                   "--exit-code"]
        if os.path.exists(os.path.join(dir_path, ".git")):
            if not do_all:
                command.append(file_name)
            with open(os.devnull, 'w') as DEVNULL:
                proc = subprocess.Popen(command,
                                        cwd=dir_path,
                                        stdout=DEVNULL,
                                        stderr=subprocess.STDOUT).wait()
                if proc == 0 or not display:
                    changes = "changes detected"
                    if proc == 0:
                        changes = "no " + changes
                    if not do_all:
                        changes += " to {}".format(file_name)
                    print(changes)
                else:
                    if display:
                        command = ["cd",
                                   dir_path,
                                   "&&"] + [x for x in
                                            command if x != "--exit-code"]
                        cmd = "\ ".join(command)
                        vim.command(":vert new +read!{}".format(cmd))
        else:
            print("not a git repo")
    except Exception as e:
        print(str(e))


if __name__ == '__main__':
    main()
