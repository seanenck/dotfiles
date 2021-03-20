#!/usr/bin/python
"""Status management."""
import subprocess
import sys
import os
import json


_DAEMON = "daemon"
_SESSION = "statusdaemon"
_TMUX = "/opt/homebrew/bin/tmux"
_NOTIFY = "/opt/homebrew/bin/terminal-notifier"
_CACHE_DIR = "/Users/enck/Library/Caches/com.voidedtech.Status/"
_GIT_DIR = "/Users/enck/Git/"
_TITLE = "title"
_PAYLOAD = "payload"
_SHOW_NOW = os.path.join(_CACHE_DIR, "show_now")


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


def _normalize(cat, string):
    normalized = cat + "_"
    for c in string.lower():
        if (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9'):
            normalized += c
        else:
            normalized += "_"
    return normalized


def _check_git():
    dirs = ["/Users/enck/"]
    for d in os.listdir(_GIT_DIR):
        dirs += [os.path.join(_GIT_DIR, d)]
    for d in dirs:
        if os.path.exists(os.path.join(d, ".git")):
            normal = _normalize("git", d)
            file_path = os.path.join(_CACHE_DIR, normal)
            exists = os.path.exists(file_path)
            if _git_status(d) > 0:
                if not exists:
                    with open(file_path, 'w') as f:
                        j = {}
                        j[_TITLE] = "Staged:{}".format(d)
                        j[_PAYLOAD] = "Commit or push changes"
                        f.write(json.dumps(j))
            else:
                if exists:
                    os.remove(file_path)


def _daemon():
    import time
    if not os.path.exists(_CACHE_DIR):
        os.makedirs(_CACHE_DIR)
    threshold = 60
    count = 0
    while True:
        try:
            show = False
            if os.path.exists(_SHOW_NOW):
                show = True
                os.remove(_SHOW_NOW)
                count = threshold + 1
            if count > threshold:
                _check_git()
                for obj in os.listdir(_CACHE_DIR):
                    if obj == _SHOW_NOW:
                        continue
                    path = os.path.join(_CACHE_DIR, obj)
                    mtime = os.path.getmtime(path)
                    t = time.time()
                    delta = (t - mtime) / 60 / 60
                    if delta > 1 or show:
                        content = ""
                        title = ""
                        with open(path, "r") as f:
                            j = json.loads(f.read())
                            content = j[_PAYLOAD]
                            title = j[_TITLE]
                        subprocess.run([_NOTIFY,
                                        "-title",
                                        title,
                                        "-message",
                                        content])
                        os.remove(path)
            count = 0
        except Exception as e:
            print("error processing")
            print(e)
        time.sleep(1)
        count += 1


def _running():
    if subprocess.run([_TMUX,
                       "has-session",
                       "-t",
                       _SESSION],
                      stdout=subprocess.DEVNULL,
                      stderr=subprocess.DEVNULL).returncode == 0:
        return True
    return False


def _handle_tmux(force, stop):
    has = False
    if _running():
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
        elif arg == "Show":
            with open(_SHOW_NOW, "w") as f:
                f.write("")
    print("Restart")
    print("Stop")
    print("Show")
    print("----")
    status = "STOPPED"
    if _running():
        status = "RUNNING"
    print("Status: {}".format(status))
    if noop:
        return
    _handle_tmux(force, stop)


if __name__ == "__main__":
    main()
