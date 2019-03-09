#!/usr/bin/python
"""Common environment processing."""
import os
from subprocess import Popen, PIPE


class Object(object):
    """Environment object."""

    pass


def touch(file_name):
    """Create an empty file."""
    open(file_name, 'a').close()


def read_env(file_name="home/common"):
    """Read the environment for my user."""
    home_env = os.environ["HOME"]
    home = os.path.join(home_env, ".config", file_name)
    p = Popen(["bash",
               "-c",
               "source " + home + "; _exports"],
              stdout=PIPE)
    output, err = p.communicate()
    if err:
        raise err
    rc = p.returncode
    if rc != 0:
        raise Exception("unable to read exports")
    lines = [x for x in output.decode("utf-8").split("\n") if x]
    result = Object()
    result.HOME = home_env
    for l in lines:
        parts = l.split("=")
        key = parts[0]
        value = "=".join(parts[1:])
        setattr(result, key, value)
    return result
