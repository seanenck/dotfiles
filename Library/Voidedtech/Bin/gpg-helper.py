#!/usr/bin/python
"""Help manage gpg runtimes."""
import datetime
import subprocess
import os

_CACHE = "/Users/enck/Library/Caches/com.voidedtech.Gpg"
_DT = "%Y%m%d"


def main():
    """Program entry."""
    if not os.path.exists(_CACHE):
        os.makedirs(_CACHE)
    check = os.path.join(_CACHE, "check")
    kill = True
    dt = datetime.datetime.now().strftime(_DT)
    if os.path.exists(check):
        with open(check, "r") as f:
            last = f.read().strip()
            if last == dt:
                kill = False
    with open(check, "w") as f:
        f.write(dt)
    if kill:
        subprocess.run(["killall", "gpg-agent"],
                       stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL)


if __name__ == "__main__":
    main()
