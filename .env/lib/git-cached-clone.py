#!/usr/bin/python
"""Handles caching clones from git."""
import argparse
import os
from pathlib import Path
import hashlib
import subprocess
import shutil
import datetime
import json


class Stats(object):
    """Stats management for cached objects."""

    _touched_key = "touched"
    _vers = "1.0.0"
    _vers_key = "version"

    def __init__(self, path):
        """Init the object."""
        self._file = os.path.join(path, "stats")
        self._dt = datetime.datetime.now().timestamp()
        self._last_touched = 0

    def load(self):
        """Load stats from cache dir."""
        if os.path.exists(self._file):
            with open(self._file, 'r') as f:
                j = json.loads(f.read())
                if j[self._vers_key] == self._vers:
                    self._last_touched = float(j[self._touched_key])

    def needs_maintenance(self, minutes):
        """Indicate if maintenance is needed."""
        delta = (self._dt - self._last_touched) / 60
        if delta > minutes:
            self._last_touched = self._dt
            return True
        return False

    def save(self):
        """Save stats to disk."""
        with open(self._file, 'w') as f:
            j = json.dumps({self._vers_key: self._vers,
                            self._touched_key: self._last_touched})
            f.write(j)


def main():
    """Program entry."""
    home = str(Path.home())
    parser = argparse.ArgumentParser()
    parser.add_argument("remote", type=str, help="remote to cache/clone")
    parser.add_argument("--maintain-minutes",
                        default=60,
                        help="minutes between maintenance")
    parser.add_argument("--cache",
                        default=os.path.join(home, ".ccg"),
                        help="cache directory")
    args = parser.parse_args()
    hash_object = hashlib.md5()
    hash_object.update(args.remote.encode("utf-8"))
    h = hash_object.hexdigest()
    path = os.path.join(args.cache, h)
    if not os.path.exists(path):
        os.makedirs(path)
    print("caching => {} is {}".format(args.remote, h))
    if len(os.listdir(path)) == 0:
        subprocess.call(["git", "clone", args.remote], cwd=path)
    work_dir = os.getcwd()
    maintenance = []
    stats = Stats(path)
    stats.load()
    if stats.needs_maintenance(args.maintain_minutes):
        maintenance += ["gc"]
    stats.save()
    for d in os.listdir(path):
        p = os.path.join(path, d)
        if not os.path.isdir(p):
            continue
        cwd = os.path.join(work_dir, d)
        if os.path.exists(cwd):
            raise Exception("already exists")
        for f in ["fetch", "pull"] + maintenance:
            print("{:<8}=> {}".format(f, p))
            subprocess.call(["git", "-C", p, f])
        shutil.copytree(p, cwd)


if __name__ == "__main__":
    main()

