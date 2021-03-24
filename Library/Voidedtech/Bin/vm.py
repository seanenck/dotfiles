#!/usr/bin/python
import threading
import subprocess
import time
import os
import argparse

_VM = "/Users/enck/VM/"
_CACHE = "/Users/enck/Library/Caches/com.voidedtech.VM"
_STDOUT = _CACHE + "/stdout"
_STDERR = _CACHE + "/stderr"


def _vm(memory, args):
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
                            memory,
                            "-a",
                            "console=hvc0 root=/dev/vda"] + args,
                            stdout=o,
                            stderr=e,
                            bufsize=1)


def main():
    """Program entry."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--memory", default="4096")
    parser.add_argument("--mount", action="store_true")
    parser.add_argument("--mount-size", default="100M")
    parser.add_argument("--mount-file", default=_VM + "mount")
    args = parser.parse_args()
    mount = []
    if args.mount:
        mount_file = args.mount_file + ".dmg"
        if os.path.exists(mount_file):
            os.remove(mount_file)
        rt = subprocess.run(["hdiutil",
                             "create",
                             args.mount_file,
                             "-size",
                             args.mount_size,
                             "-srcfolder",
                             os.getcwd(),
                             "-fs",
                             "exFAT",
                             "-format",
                             "UDRW"]).returncode
        if rt != 0:
            print("unable to create mount image")
            return
        mount += ["-d", mount_file]
    if not os.path.exists(_CACHE):
        os.makedirs(_CACHE)
    for f in [_STDOUT, _STDERR]:
        if os.path.exists(f):
            os.remove(f)
    t = threading.Thread(target=_vm, args=(args.memory, mount))
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
