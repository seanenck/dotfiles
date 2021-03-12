#!/usr/bin/python
import os
import subprocess
import datetime
import socket


_KEYS = ["systems", "repos", "dropbear"]


def main():
    """Program entry."""
    host = socket.gethostname()
    now = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    for f in _KEYS:
        name = "{}.{}".format(f, now)
        path = os.path.join(os.environ["HOME"], ".ssh", host)
        key = os.path.join(path, name)
        subprocess.run(["ssh-keygen",
                        "-t",
                        "ed25519",
                        "-N",
                        "''",
                        "-f",
                        key,
                        ])
        subprocess.run(["ln", "-sf", key, os.path.join(path, f)])


if __name__ == "__main__":
    main()
