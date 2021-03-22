#!/usr/bin/python
"""Status management."""
import subprocess
import http.server
import socketserver
import os
import email.utils as utils

_PORT = 8000
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


def _normalize(cat, string):
    normalized = cat + "_"
    for c in string.lower():
        if (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9'):
            normalized += c
        else:
            normalized += "_"
    return normalized


def _check_git():
    dt = utils.formatdate(localtime=True)
    dirs = ["/Users/enck/"]
    for d in os.listdir(_GIT_DIR):
        dirs += [os.path.join(_GIT_DIR, d)]
    for d in dirs:
        if os.path.exists(os.path.join(d, ".git")):
            if _git_status(d) > 0:
                yield """<item><title>Git: {}</title>
<pubDate>{}</pubDate>
<description>Staged changes: {}</description></item>
""".format(d, dt, d)

def main():
    class FeedHandler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header('Content-type', 'text/xml')
            self.end_headers()
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
