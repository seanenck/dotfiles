#!/usr/bin/python
"""Status management."""
import subprocess
import sys
import os


_DAEMON = "daemon"
_SESSION = "statusdaemon"
_TMUX = "/opt/homebrew/bin/tmux"
_NOTIFY = "/opt/homebrew/bin/terminal-notifier"
_CACHE = "/Users/enck/Library/Caches/status.cache"
_GIT_DIR = "/Users/enck/Git/"


def _git(repo, args):
    p = subprocess.Popen(["git", "-C", repo] + args,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    o, e = p.communicate()
    if e is not None and e != b'':
        print("failed git command")
        print(e)
        return ""
    return o.decode("utf-8")


def _git_status(repo):
    count = 0
    args = ["git", "-C", repo]
    if _git(repo, ["update-index", "-q", "--refresh"]) != "":
        count += 1
    if _git(repo, ["diff-index", "--name-only", "HEAD", "--"]) != "":
        count += 1
    ahead = _git(repo, ["status", "-sb"])
    if ahead != "":
        if "ahead" in ahead:
            count += 1
    if _git(repo, ["ls-files", "--other", "--exclude-standard"]) != "":
        count += 1
    return count


def _new_status(cat, message):
    return "{}: {}".format(cat, message)


def _check_git():
    dirs = ["/Users/enck/"]
    for d in os.listdir(_GIT_DIR):
        dirs += [os.path.join(_GIT_DIR, d)]
    for d in dirs:
        if os.path.exists(os.path.join(d, ".git")):
            if _git_status(d) > 0:
                dir_name = os.path.dirname(d)
                text = _new_status("git", dir_name)
                yield text


def _daemon():
    import time
    while True:
        try:
            items = []
            for item in _check_git():
                items += [item]
            if len(items) > 0:
                current = ""
                if os.path.exists(_CACHE):
                    with open(_CACHE, "r") as f:
                        current = f.read().strip()
                new = "\n".join(sorted(items)).strip()
                if new != current:
                    with open(_CACHE, "w") as f:
                        f.write(new)
            else:
                if os.path.exists(_CACHE):
                    os.remove(_CACHE)
            if os.path.exists(_CACHE):
                mtime = os.path.getmtime(_CACHE)
                t = time.time()
                delta = (t - mtime) / 60 / 60
                if delta > 1:
                    with open(_CACHE, "r") as f:
                        content = f.read()
                    subprocess.run([_NOTIFY,
                                    "-title",
                                    "Status",
                                    "-message",
                                    content])
                    os.remove(_CACHE)
        except Exception as e:
            print("error processing")
            print(e)
        time.sleep(60)


def _handle_tmux(force, stop):
    has = False
    if subprocess.run([_TMUX,
                       "has-session",
                       "-t",
                       _SESSION],
                      stdout=subprocess.DEVNULL,
                      stderr=subprocess.DEVNULL).returncode == 0:
        has = True
    if force or stop:
        if has:
            subprocess.run([_TMUX,
                            "kill-session",
                            "-t",
                            _SESSION],
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)
            has = False
    if stop:
        return
    if not has:
        subprocess.run([_TMUX,
                        "new",
                        "-d",
                        "-s",
                        _SESSION,
                        "python3",
                        "/Users/enck/.bin/status.py",
                        "daemon"])


def main():
    arg = None
    if len(sys.argv) > 1:
        arg = sys.argv[1]
    force = False
    stop = False
    noop = True
    if arg is not None:
        noop = False
        if arg == _DAEMON:
            _daemon()
            return
        elif arg == "Restart":
            force = True
        elif arg == "Stop":
            stop = True
    print("Restart")
    print("Stop")
    if noop:
        return
    _handle_tmux(force, stop)


if __name__ == "__main__":
    main()
