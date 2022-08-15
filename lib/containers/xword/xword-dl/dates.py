#!/usr/bin/env python3
"""Handle date generation."""
import datetime
import argparse


def main():
    """Program entry."""
    p = argparse.ArgumentParser()
    p.add_argument("--since", required=True)
    p.add_argument("--until", required=True)
    args, _ = p.parse_known_args()
    s = datetime.datetime.strptime(args.since, "%Y-%m-%d")
    u = datetime.datetime.strptime(args.until, "%Y-%m-%d")
    if u <= s:
        print("invalid request, until <= since")
        exit(1)
    d = (u - s).days
    start = 0
    while start <= d:
        print((u + datetime.timedelta(days=start * -1)).strftime("%Y-%m-%d"))
        start += 1


if __name__ == "__main__":
    main()
