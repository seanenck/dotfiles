#!/usr/bin/python3
"""Inject email directly into maildir."""
import mailbox
import email
import argparse
import os
from email.mime.message import MIMEMessage
import email.utils
from email.mime.text import MIMEText
import common

ACCOUNTS = [common.GMAIL_ACCOUNT, common.FMAIL_ACCOUNT]


def _countdirs(dirs, account, ind):
    """Count dir emails."""
    cnt = 0
    for d in dirs:
        cnt += len(os.listdir(d))
    if cnt > 0:
        return "{} {}({})".format(cnt, account, ind)


def count(env):
    """Get unread counts."""
    results = []
    for a in ACCOUNTS:
        unread = []
        new = []
        acct = os.path.join(env.MAIL_DIR, a)
        for root, dirs, _ in os.walk(acct):
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
        results.append(_countdirs(new, a, "n"))
        results.append(_countdirs(unread, a, "u"))
    return [x for x in results if x]


def main():
    """Program entry."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--address", type=str)
    parser.add_argument("--maildir", type=str)
    parser.add_argument("--subject", type=str)
    parser.add_argument("--input", type=str)
    parser.add_argument("--plaintext", action="store_true")
    args = parser.parse_args()
    if not args.address or not args.subject:
        print("address and subject required")
        return
    if not args.maildir or not os.path.exists(args.maildir):
        print("maildir does not exist")
        return
    with open(args.input, 'r') as f:
        if args.plaintext:
            msg = MIMEText(f.read())
        else:
            message = mailbox.email.message_from_file(f)
            msg = MIMEMessage(message)
    msg.add_header("To", args.address)
    msg.add_header("From", args.address)
    msg.add_header("Subject", args.subject)
    msg.add_header("Date", email.utils.formatdate(localtime=True))
    maildir = mailbox.Maildir(args.maildir)
    maildir.add(msg)


if __name__ == "__main__":
    main()
