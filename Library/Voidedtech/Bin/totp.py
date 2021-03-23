#!/usr/bin/python3
"""TOTP generation."""
import sys
import os
import datetime
import subprocess
import time
import argparse

_PASS_TOTP = "keys/totp"


def _list(store_dir, offset):
    """List totp options."""
    d = os.path.join(store_dir, offset)
    for f in sorted(os.listdir(d)):
        yield f.replace(".gpg", "")


def _display(key, store_dir, offset):
    """Display totp tokens."""
    if key not in list(_list(store_dir, offset)):
        print("invalid request")
        return
    last_second = -1
    running_count = 0
    use_env = {}
    use_env["PATH"] = os.getenv("PATH")
    use_env["PASSWORD_STORE_DIR"] = store_dir
    totp = os.path.join(offset, key)
    val = _get_output(["pass", "show", totp], env=use_env)
    token = val.decode("utf-8").strip()
    if not token:
        print("invalid token")
        return
    is_first = True
    while True:
        if is_first:
            is_first = False
        else:
            time.sleep(0.5)
        running_count += 1
        if running_count > 120:
            print("exiting")
            return
        output = []
        n = datetime.datetime.now()
        if n.second == last_second:
            continue
        last_second = n.second
        left = 60 - n.second
        expiring = "{}, expires: {} (seconds)".format(n.strftime("%H:%M:%S"),
                                                      left)
        output.append(expiring)
        val = _get_output(["oathtool", "--base32", "--totp", token], None)
        oath = val.decode("utf-8").strip()
        msg = "\n{}\n    {}".format(key, oath)
        output.append(msg)
        subprocess.call(["clear"])
        if left < 10:
            _red_text()
        else:
            _normal_text()
        output.append("\n-> CTRL+C to exit")
        line = "\n".join(output).strip()
        print(line)
        _normal_text()


def _get_output(command, env):
    """Get output or error from command."""
    p = subprocess.Popen(command, stdout=subprocess.PIPE, env=env)
    output, err = p.communicate()
    if err is not None and err != b'':
        print(err)
        raise Exception("command failed")
    return output


def _text_color(color):
    """Output terminal text in a color."""
    sys.stdout.write("\033[{}m".format(color))


def _red_text():
    """Make red text in terminal."""
    _text_color("1;31")


def _normal_text():
    """Reset text in terminal."""
    _text_color("0")


def main():
    """Program entry."""
    parser = argparse.ArgumentParser()
    parser.add_argument("mode")
    parser.add_argument("--offset", default="keys/totp")
    args = parser.parse_args()
    store = os.environ["PASSWORD_STORE_DIR"]
    if not os.path.exists(store):
        print("no store found (missing?)")
        return
    if not os.path.exists(os.path.join(store, args.offset)):
        print("offset not found")
        return
    if args.mode == "list":
        for listing in _list(store, args.offset):
            print(listing)
    else:
        try:
            _display(args.mode, store, args.offset)
        finally:
            _normal_text()


if __name__ == "__main__":
    main()
