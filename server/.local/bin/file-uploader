#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import argparse
import threading
import email
import datetime
import hashlib
import os
import mimetypes

global lock
lock = threading.Lock()

_STATIC = "/static/"
_POST = "/saveto"
_GET = "/store"
_TARGET = os.path.join(os.environ["HOME"], "Downloads")
_UPLOAD_HTML = """
<!DOCTYPE html>
<html lang="en" class="notranslate" translate="no">
<head>
<meta charset="UTF-8">
<title>uploader</title>
<style>
body
{
    font-family: "Helvetica Neue", Helvetica, Arial, sans-serif;
    font-size: 20px;
    padding-top: 20px;
    margin-left: auto;
    margin-right: auto;
    width: 70%;
}
</style>
</head>
<body>
    <form
      id="form"
      enctype="multipart/form-data"
      action="{POST}"
      method="POST"
    >
      <input class="input file-input" type="file" name="file" multiple />
      <hr />
      {FILES}
      <hr />
      <br />
      <button class="button" type="submit">Submit</button>
      <hr />
      <br />
    </form>
    </body>
</html>
""".replace(
    "{POST}", _POST
)


def _parse(typed: str, data: bytes) -> None:
    s = """MIME-Version: 1.0
Content-Type: {}

""".format(
        typed
    )
    buf = s.encode() + data
    msg = email.message_from_bytes(buf)
    ts = datetime.datetime.now()
    formatted = ts.strftime("%H%M%S")
    unix = str((ts - datetime.datetime(1970, 1, 1)).total_seconds()).encode("utf-8")
    day = str(ts.day)
    if len(day) == 1:
        day = "0" + day
    count = 0
    if not msg.is_multipart():
        print("no multipart detected?")
        return
    for part in msg.get_payload():
        filename = part.get_param("filename", header="content-disposition")
        payload = part.get_payload(decode=True)
        name = ""
        for c in filename.lower():
            allowed = False
            if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
                allowed = True
            elif c in ["-", ".", "_"]:
                allowed = True
            if allowed:
                name = "{}{}".format(name, c)
        if len(name) == 0:
            print("unable to parse file: {}".format(filename))
            continue
        parts = name.split(".")
        ext = parts[-1]
        h = hashlib.new("sha256")
        h.update(str(count).encode("utf-8"))
        h.update(name.encode("utf-8"))
        h.update(unix)
        count += 1
        name = "{}.T_{}.{}".format(day, formatted, h.hexdigest()[0:7])
        target = os.path.join(_TARGET, "{}.{}".format(name, ext))
        with open(target, "wb") as f:
            f.write(payload)


class UploadHandler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        with lock:
            if self.path == _GET:
                self.send_response(200)
                self.end_headers()
                files = []
                for file in os.listdir(_TARGET):
                    if file.startswith("."):
                        continue
                    files.append("<a href='{}{}'>{}</a>".format(_STATIC, file, file))
                if len(files) == 0:
                    files = ["none"]
                html = _UPLOAD_HTML.replace("{FILES}", "<br />".join(files))
                self.wfile.write(html.encode("utf-8"))
            elif self.path.startswith(_STATIC):
                stripped = self.path.replace(_STATIC, "", 1)
                t, _ = mimetypes.guess_type(stripped, strict=False)
                data = None
                with open(os.path.join(_TARGET, stripped), "rb") as f:
                    data = f.read()
                length = len(data)
                self.send_response(200)
                if t:
                    self.send_header("content-type", t)
                self.send_header("content-length", length)
                self.end_headers()
                self.wfile.write(data)
            else:
                self.send_error(403)

    def do_POST(self) -> None:
        with lock:
            length = self.headers.get("content-length")
            ct = self.headers.get("content-type")
            if length and ct:
                field_data = self.rfile.read(int(length))
                _parse(str(ct), field_data)
            self.send_response(303)
            self.send_header("Location", _GET)
            self.end_headers()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--address", type=str, default="0.0.0.0")
    parser.add_argument("--port", type=int, default=8080)
    args = parser.parse_args()
    print("binding: {}:{}{}".format(args.address, args.port, _GET))
    httpd = HTTPServer((args.address, args.port), UploadHandler)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
