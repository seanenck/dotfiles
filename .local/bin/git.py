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
_MAX_CHANGES = 50


def _is_git_dir(d):
    return os.path.exists(os.path.join(d, ".git"))


def _get_folders(env):
    """Get git-controlled folders."""
    dirs = []
    for r, _, _ in os.walk(env.PERM_LOCATION):
        d = os.path.join(r, ".git")
        if os.path.exists(d):
            dirs.append(r)
    dirs.append(os.path.join(env.HOME, "workspace"))
    results = []
    results.append("/etc")
    results.append(env.HOME)
    for d in dirs:
        if _is_git_dir(d):
            results.append(d)
        for check in os.listdir(d):
            fpath = os.path.join(d, check)
            if os.path.isdir(fpath):
                if _is_git_dir(fpath):
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
            if len_r > _MAX_CHANGES:
                r = r[0:_MAX_CHANGES]
                r.append("...")
            results[f] = r
            total += len_r
    return (results, total)


def status(env, out):
    """Get git status."""
    r = _get_all_changes(env)
    total = r[1]
    if total > 0 and out is not None:
        out.write("uncommitted changes:\n")
        results = r[0]
        for k in sorted(results.keys()):
            out.write(k + "\n")
            for o in results[k]:
                out.write("    ->  {}\n".format(o))
    return total
