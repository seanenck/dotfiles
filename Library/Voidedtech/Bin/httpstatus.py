#!/usr/bin/python
"""Status management."""
import subprocess
import http.server
import socketserver
import os
import time
import email.utils as utils

_PORT = 8000
_HOME = "/Users/enck"
_GIT_DIR = _HOME + "/Git/"
_CACHE_DIR = _HOME + "/Library/Caches/com.voidedtech.Status"


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


def _check_git():
    dt = utils.formatdate(localtime=True)
    dirs = [_HOME]
    for d in os.listdir(_GIT_DIR):
        dirs += [os.path.join(_GIT_DIR, d)]
    for d in dirs:
        if os.path.exists(os.path.join(d, ".git")):
            if _git_status(d) > 0:
                yield """<item><title>Git: {}</title>
<pubDate>{}</pubDate>
<description>Staged changes: {}</description></item>
""".format(d, dt, d)


def _bundle():
    cached = os.path.join(_CACHE_DIR, "bundle")
    if not os.path.exists(cached):
        os.makedirs(cached)
    cached = os.path.join(cached, "last")
    if os.path.exists(cached):
        mtime = os.path.getmtime(cached)
        t = time.time()
        delta = (t - mtime) / 60 / 60 / 24
        if delta < 1:
            return
    subprocess.run(["brew",
                    "bundle",
                    "dump"], cwd=_HOME + "/Library/Voidedtech/Config/")
    with open(cached, "w") as f:
        f.write("")


def main():
    class FeedHandler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header('Content-type', 'text/xml')
            self.end_headers()
            _bundle()
            items = "\n".join(list(_check_git()))
            self.wfile.write(bytes("""<rss version="2.0">
<channel>
<title>Local System</title>
{}
</channel></rss>""".format(items), "utf-8"))

    with socketserver.TCPServer(("", 8000), FeedHandler) as httpd:
        httpd.serve_forever()


if __name__ == "__main__":
    main()
