#!/usr/bin/python
"""
handles processing and naming i3 workspaces based on content
"""

import i3ipc
import subprocess 
import os

conn = i3ipc.Connection()
window_cache = {}
devnull = open(os.devnull, 'w')


def uncurl(obj):
    """uncurl nest nodes down."""
    children = []
    for node in obj.nodes:
        for opened in uncurl(node):
            children.append(opened)
        children.append(node)
    return children


def on_change(self, event):
    """on interested changes, call this."""
    try:
        tree = conn.get_tree()
        for t in tree.workspaces():
            rename_workspaces(t)
    except:
        pass


def rename_workspaces(e):
    """rename a workspace."""
    all_nodes = []
    for node in uncurl(e):
        if node is None or node.window_class is None:
            continue
        all_nodes.append(node)
    named = str(e.num)
    if len(all_nodes) > 0:
        names = [x.window_class[0:20] for x in all_nodes]
        named = named + ":" + ",".join(names)
    named = named.lower()
    if e.num in window_cache and window_cache[e.num] == named:
        return
    window_cache[e.num] = named
    subprocess.call(["i3-msg", "rename workspace \"{}\" to \"{}\"".format(e.name, named)], stdout=devnull, stderr=subprocess.STDOUT)

conn.on('workspace', on_change)
conn.on('window', on_change)
conn.main()
