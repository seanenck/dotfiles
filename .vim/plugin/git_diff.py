#!/usr/bin/python
"""Perform a git-diff output."""
import vim
import os
import subprocess


def main():
    """Main entry point."""
    try:
        file_name = vim.current.buffer.name
        dir_path = os.path.dirname(file_name)
        command = ["git",
                   "diff",
                   "--exit-code",
                   file_name]
        with open(os.devnull, 'w') as DEVNULL:
            proc = subprocess.Popen(command, 
                                    cwd=dir_path,
                                    stdout=DEVNULL,
                                    stderr=subprocess.STDOUT).wait()
            if proc == 0:
                print('no changes to {}'.format(file_name))
            else:
                command = ["cd",
                           dir_path,
                           "&&"] + [x for x in command if x != "--exit-code"]
                cmd = "\ ".join(command)
                vim.command(":vert new +read!{}".format(cmd))
    except Exception as e:
        print(str(e))


if __name__ == '__main__':
    main()
