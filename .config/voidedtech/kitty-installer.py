#!/usr/bin/python3

from __future__ import (
    absolute_import, division, print_function, unicode_literals
)

import atexit
import json
import os
import platform
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import datetime

is_macos = 'darwin' in sys.platform.lower()

_CACHE = "/Users/enck/Library/Caches/kitty-installer"
unicode = str
raw_input = input
import urllib.request as urllib

def encode_for_subprocess(x):
    return x


def run(*args):
    if len(args) == 1:
        args = shlex.split(args[0])
    args = list(map(encode_for_subprocess, args))
    ret = subprocess.Popen(args).wait()
    if ret != 0:
        raise SystemExit(ret)


class Reporter:  # {{{

    def __init__(self, fname):
        self.fname = fname
        self.last_percent = 0

    def __call__(self, blocks, block_size, total_size):
        percent = (blocks*block_size)/float(total_size)
        report = '\rDownloaded {:.1%}         '.format(percent)
        if percent - self.last_percent > 0.05:
            self.last_percent = percent
            print(report, end='')
            sys.stdout.flush()
# }}}


def get_latest_release_data():
    print('Checking for latest release on GitHub...')
    req = urllib.Request('https://api.github.com/repos/kovidgoyal/kitty/releases/latest', headers={'Accept': 'application/vnd.github.v3+json'})
    try:
        res = urllib.urlopen(req).read().decode('utf-8')
    except Exception as err:
        raise SystemExit('Failed to contact {} with error: {}'.format(req.get_full_url(), err))
    data = json.loads(res)
    html_url = data['html_url'].replace('/tag/', '/download/').rstrip('/')
    for asset in data.get('assets', ()):
        name = asset['name']
        if name.endswith('.dmg'):
            return html_url + '/' + name, asset['size']
    raise SystemExit('Failed to find the installer package on github')


def do_download(url, size, dest):
    print('Will download and install', os.path.basename(dest))
    reporter = Reporter(os.path.basename(dest))

    # Get content length and check if range is supported
    rq = urllib.urlopen(url)
    headers = rq.info()
    sent_size = int(headers['content-length'])
    if sent_size != size:
        raise SystemExit('Failed to download from {} Content-Length ({}) != {}'.format(url, sent_size, size))
    with open(dest, 'wb') as f:
        while f.tell() < size:
            raw = rq.read(8192)
            if not raw:
                break
            f.write(raw)
            reporter(f.tell(), 1, size)
    rq.close()
    if os.path.getsize(dest) < size:
        raise SystemExit('Download failed, try again later')
    print('\rDownloaded {} bytes'.format(os.path.getsize(dest)))


def clean_cache(cache, fname):
    for x in os.listdir(cache):
        if fname not in x:
            os.remove(os.path.join(cache, x))


def download_installer():
    url, size = get_latest_release_data()
    fname = url.rpartition('/')[-1]
    cache = _CACHE
    if not os.path.exists(cache):
        os.makedirs(cache)
    clean_cache(cache, fname)
    dest = os.path.join(cache, fname)
    if os.path.exists(dest) and os.path.getsize(dest) == size:
        print('Using previously downloaded', fname)
        return dest
    if os.path.exists(dest):
        os.remove(dest)
    do_download(url, size, dest)
    return dest


def macos_install(state, week, dmg, dest='/Applications'):
    mp = tempfile.mkdtemp()
    atexit.register(shutil.rmtree, mp)
    run('hdiutil', 'attach', dmg, '-mountpoint', mp)
    try:
        os.chdir(mp)
        app = 'kitty.app'
        d = os.path.join(dest, app)
        if os.path.exists(d):
            shutil.rmtree(d)
        dest = os.path.join(dest, app)
        run('ditto', '-v', app, dest)
        print('Successfully installed kitty into', dest)
        with open(state, "w") as f:
            f.write(week)
    finally:
        os.chdir('/')
        run('hdiutil', 'detach', mp)


def main():
    state = os.path.join(_CACHE, "success")
    week = str(datetime.datetime.now().isocalendar()[1])
    force = False
    if len(sys.argv) > 1:
        if sys.argv[1] == "--force":
            force = True
    if os.path.exists(state) and not force:
        with open(state, "r") as f:
            if f.read().strip() == week:
                print("recent update performed, '--force' to force upgrade")
                return
    installer = download_installer()
    macos_install(state, week, installer, dest="/Applications")


if __name__ == '__main__':
    main()
