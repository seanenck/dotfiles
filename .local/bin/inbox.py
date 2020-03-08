#!/usr/bin/python3
"""Inject email directly into maildir."""
import mailbox
import email
import argparse
import os
from email import encoders
from email.mime.base import MIMEBase
import email.utils
from email.mime.text import MIMEText


def main():
    """Program entry."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--address", type=str, default="enckse@voidedtech.com")
    parser.add_argument("--maildir", type=str, default="/home/enck/.mutt/imap/fastmail/Filtered/Automated/")
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
    readmode = "r"
    if not args.plaintext:
        readmode += "b"
    with open(args.input, readmode) as f:
        if args.plaintext:
            msg = MIMEText(f.read())
        else:
            msg = MIMEBase('application', 'zip')
            msg.set_payload(f.read())
            encoders.encode_base64(msg)
            msg.add_header('Content-Disposition',
                           'attachment',
                           filename=args.input)
            message = mailbox.email.message_from_file(f)
    msg.add_header("To", args.address)
    msg.add_header("From", args.address)
    msg.add_header("Subject", args.subject)
    msg.add_header("Date", email.utils.formatdate(localtime=True))
    maildir = mailbox.Maildir(args.maildir)
    maildir.add(msg)


if __name__ == "__main__":
    main()
