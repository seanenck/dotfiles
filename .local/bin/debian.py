#!/usr/bin/python3
"""Debian environments handling."""
import os
import common

MANIFEST = "manifest"
DEB = ".deb"
DISTS = "dists"
DELIMITER = ":"
IS_ALL = "all"
MIRROR = "voidedtech.com"
DEB_BUILD_ROOT = "/" + os.path.join("opt", "build", "packages")
DEB_BUILD_DIR = os.path.join(DEB_BUILD_ROOT, "workdir")


def parse_manifest(manifest_file):
    """Parse the pool manifest."""
    if not os.path.exists(manifest_file):
        raise Exception("invalid manifest")
    results = []
    with open(manifest_file, 'r') as f:
        for l in f:
            parts = l.strip().split(DELIMITER)
            if len(parts) != 3:
                print("invalid entry: " + l)
            o = common.Object()
            o.repo = parts[0]
            o.filter = parts[1]
            o.deb = parts[2]
            results.append(o)
    return results
