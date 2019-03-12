#!/usr/bin/python3
import common
import sys
import os
import time
import subprocess

_ACCOUNTS = [common.GMAIL_ACCOUNT, common.FMAIL_ACCOUNT]


def _countdirs(dirs, account, ind):
    """Count dir emails."""
    cnt = 0
    for d in dirs:
        cnt += len(os.listdir(d))
    if cnt > 0:
        print("{} {}({})".format(cnt, account, ind))


def _count(env):
    """Get unread counts."""
    for a in _ACCOUNTS:
        unread = []
        new = []
        acct = os.path.join(env.MAIL_DIR, a)
        for root, dirs, files in os.walk(acct):
            for d in dirs:
                rootd = os.path.join(root, d)
                if "Trash" in rootd:
                    continue
                if d == "cur":
                    if "Filtered" in rootd or "Spam" in rootd:
                        if "Filtered/Automated" not in rootd:
                            unread.append(rootd)
                elif d == "new":
                    new.append(rootd)
        _countdirs(new, a, "n")
        _countdirs(unread, a, "u")


def _mbsync(env):
    """Run mbsync."""


def _imap(env):
    """Run imap sync."""
    if not common.is_online():
        return


def _client(env, account):
    """Connect an email client."""
    if account not in _ACCOUNTS:
        return
    trigger = os.path.join(env.USER_TMP, "mail.trigger")
    open(trigger, 'w').close()
    time.sleep(0.5)
    muttrc = os.path.join(env.HOME, ".mutt", "{}.muttrc".format(account))
    subprocess.call(["mutt", "-F", muttrc], cwd=env.XDG_DOWNLOAD_DIR)
    time.sleep(0.25)


def main():
    """Program entry."""
    args = sys.argv
    env = common.read_env()
    if len(args) <= 1:
        _imap(env)
        return
    commands = args[1:]
    cmd = commands[0]
    has_sub = False
    if len(commands) > 1:
        has_sub = True
        commands = commands[1:]
    if cmd == "client":
        if not has_sub:
            print("client required")
            return
        _client(env, commands[0])
    elif cmd == "search":
        if not has_sub:
            print("search term(s) required")
            return
        _search(env, commands)
    elif cmd == "connected":
        _connected(env)
    elif cmd == "count":
        _count(env)
    else:
        print("unknown command")


if __name__ == "__main__":
    main()
