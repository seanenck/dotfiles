#!/usr/bin/python
import threading
import subprocess
import time
import os

_VM = "/Users/enck/VM/"
_CACHE = "/Users/enck/Library/Caches/com.voidedtech.VM"
_STDOUT = _CACHE + "/stdout"
_STDERR = _CACHE + "/stderr"


def _vm():
    with open(_STDOUT, "w") as o:
        with open(_STDERR, "w") as e:
            subprocess.run([_VM + "vftool/build/vftool",
                            "-k",
                            _VM + "vmlinuz",
                            "-i",
                            _VM + "initrd.img",
                            "-d",
                            _VM + "disk.img",
                            "-m",
                            "4096",
                            "-a",
                            "console=hvc0 root=/dev/vda"],
                            stdout=o,
                            stderr=e,
                            bufsize=1)


def main():
    """Program entry."""
    if not os.path.exists(_CACHE):
        os.makedirs(_CACHE)
    for f in [_STDOUT, _STDERR]:
        if os.path.exists(f):
            os.remove(f)
    t = threading.Thread(target=_vm)
    t.start()
    tty = None
    while tty is None:
        time.sleep(1)
        if os.path.exists(_STDERR):
            with open(_STDERR, "r") as f:
                for line in f:
                    idx = line.find("Waiting for connection to:")
                    if idx > 0:
                        tty = line[idx+26:].strip()
    subprocess.run(["screen", tty])


if __name__ == "__main__":
    main()
