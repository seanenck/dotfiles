#!/usr/bin/python3
"""Git helpers/modules."""
import os
import subprocess
import common

_CMDS = []
_CMDS.append((["update-index", "-q", "--refresh"], None))
_CMDS.append((["diff-index", "--name-only", "HEAD", "--"], None))
_CMDS.append((["status", "-sb"], "ahead"))
_CMDS.append((["ls-files", "--other", "--exclude-standard"], None))


def _get_folders(env):
    """Get git-controlled folders."""
    dirs = []
    for d in os.listdir(env.PERM_LOCATION):
        dirs.append(os.path.join(env.PERM_LOCATION, d))
    dirs.append(os.path.join(env.HOME, "workspace"))
    results = []
    results.append("/etc")
    results.append(env.HOME)
    for d in dirs:
        for check in os.listdir(d):
            fpath = os.path.join(d, check)
            if os.path.isdir(fpath):
                if os.path.exists(os.path.join(fpath, ".git")):
                    results.append(fpath)
    return results


def _get_changes(directory):
    """Get changes in a directory."""
    cwd = os.getcwd()
    os.chdir(directory)
    results = []
    for c in _CMDS:
        out, err = common.get_output_or_error(["git"] + c[0])
        if err is not None:
            continue
        stdout = out.decode("utf-8")
        if not stdout:
            continue
        out = stdout.split("\n")
        out = [x for x in out if x]
        filtered = c[1]
        if filtered is not None:
            check = [x for x in out if filtered in x]
            if len(check) == 0:
                continue
            out = check
        results += out
    os.chdir(cwd)
    return results


def _get_all_changes(env):
    """Get git changes."""
    results = {}
    total = 0
    for f in sorted(_get_folders(env)):
        r = _get_changes(f)
        len_r = len(r)
        if len_r > 0:
            results[f] = r
            total += len_r
    return (results, total)


def status(env, stdout):
    """Get git status."""
    r = _get_all_changes(env)
    total = r[1]
    if total > 0 and stdout is not None:
        stdout.write("uncommitted changes:\n")
        common.red_text()
        results = r[0]
        for k in sorted(results.keys()):
            stdout.write(k + "\n")
            for o in results[k]:
                stdout.write("    ->  {}\n".format(o))
        common.normal_text()
    return total
