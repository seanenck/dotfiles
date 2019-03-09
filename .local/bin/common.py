#!/usr/bin/python
"""Common environment processing."""
import os
import io
from subprocess import Popen, PIPE


class Object(object):
    """Environment object."""

    pass


def read_env():
    """Read the environment for my user."""
    home_env = os.environ["HOME"]
    home = os.path.join(home_env, ".config/home/common")
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
